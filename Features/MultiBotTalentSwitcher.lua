
-- ============================================================
--  MultiBot TalentSwitcher.lua
--  天赋循环切换：每次点击按钮，目标机器人切换到下一个天赋
--  同时发送 3 条密语:
--    1. talents spec <英文天赋> pve  (切天赋, 服务端随即按新天赋重建默认策略)
--    2. autogear reset blue/purple   (清空已穿装备, 按新天赋重配;
--                                     品质按机器人当前装备自动检测:
--                                     蓝->blue 保持蓝, 紫->purple 保持紫)
--    3. reset botAI                  (清策略存档 + 按当前天赋重建默认策略,
--                                     防止下次上线被旧存档覆盖)
--  目标：当前选中的玩家机器人（必须在队伍中）
--
--  品质保持机制 (2026-11-11):
--    点击后先 NotifyInspect 观察目标, 读取观察物品链接的颜色代码:
--      a335ee(史诗)/ff8000(传说)/00ccff(神器)/e6cc80(传家宝) => 紫装机器人
--      其余(0070dd 精良及以下)                               => 蓝装机器人
--    检测结果记入 MultiBotDB.botQuality (跨登录保留, 紫装标记为"粘性":
--    一次检测到紫装后即使将来某次检测失败也不会被降级成 blue)。
--    观察失败(不在视野/太远)时回退到记忆值, 无记忆则默认 blue。
--    手动覆盖 (2026-11-16 十六轮起与切天赋解绑, 只换装不切天赋):
--      Alt+点击按钮 = 只按紫装重配装备; Ctrl+点击按钮 = 只按蓝装重配装备
--      (不切天赋、不动天赋变量、不 reset botAI 清策略存档)。
--
--  确认弹窗闸门 (2026-11-12 c):
--    切换序列会真实地重置天赋并删除已穿装备再重配——对随机/addclass bot 无害,
--    但对"自建账号"(AllowAccountBots 拉起的自有角色)是真实数据损失。
--    现在点击后先弹静态确认框, 明示后果与"请勿对真实账号角色使用"警告,
--    确认后才执行; 取消不消耗循环序号、不改动品质记忆。
--
--  服务端前置条件: conf Playerbots.AutoGearQualityLimit >= 4
--    (AutoGearAction 中 quality = min(请求值, 该配置); 只有 conf 放开到 4
--     purple 参数才不会被压回蓝装。)
--
--  移植自 UnBot/TalentSwitcher.lua (2026-06-21)
-- ============================================================

local MultiBot = _G["MultiBot"] or {}
_G["MultiBot"] = MultiBot

-- 防止重复加载
if MultiBot._talentSwitcherLoaded then return end
MultiBot._talentSwitcherLoaded = true

-- 职业-天赋数据表
MultiBot.talentData = {
["Druid"]    = { {"balance",  MultiBot.T("鸟德")},  {"bear",   MultiBot.T("熊德")},  {"resto",   MultiBot.T("奶德")},  {"cat",     MultiBot.T("猫德")} },
["Warlock"]  = { {"affli",    MultiBot.T("痛苦术")}, {"demo",   MultiBot.T("恶魔术")}, {"destro",  MultiBot.T("毁灭术")} },
["Mage"]     = { {"arcane",   MultiBot.T("奥法")},  {"frostfire",MultiBot.T("霜火法")},{"fire",    MultiBot.T("火法")}, {"frost",   MultiBot.T("冰法")} },
["Shaman"]   = { {"ele",      MultiBot.T("电萨")},  {"enh",    MultiBot.T("增强萨")}, {"resto",   MultiBot.T("奶萨")} },
["Death Knight"] = { {"blood",MultiBot.T("血DK")},  {"frost",  MultiBot.T("冰DK")},  {"unholy",  MultiBot.T("邪DK")}, {"double aura blood",MultiBot.T("双光环DK")} },
["Priest"]   = { {"disc",     MultiBot.T("戒律牧")}, {"holy",  MultiBot.T("神牧")},  {"shadow",  MultiBot.T("暗牧")} },
["Rogue"]    = { {"as",       MultiBot.T("刺杀贼")}, {"combat",MultiBot.T("战斗贼")}, {"subtlety",MultiBot.T("敏锐贼")} },
["Hunter"]   = { {"bm",       MultiBot.T("兽王")},  {"mm",    MultiBot.T("射击")},  {"surv",    MultiBot.T("生存猎")} },
["Paladin"]  = { {"holy",     MultiBot.T("奶骑")},  {"prot",  MultiBot.T("防骑")},  {"ret",     MultiBot.T("惩戒骑")} },
["Warrior"]  = { {"arms",     MultiBot.T("武器战")}, {"fury", MultiBot.T("狂暴战")}, {"prot",    MultiBot.T("防战")} },
}

-- 中文职业名映射（用于显示）
MultiBot.talentClassNameCN = {
    ["Druid"]        = MultiBot.T("德鲁伊"),
    ["Warlock"]      = MultiBot.T("术士"),
    ["Mage"]         = MultiBot.T("法师"),
    ["Shaman"]       = MultiBot.T("萨满"),
    ["Death Knight"] = MultiBot.T("DK"),
    ["Priest"]       = MultiBot.T("牧师"),
    ["Rogue"]        = MultiBot.T("潜行者"),
    ["Hunter"]       = MultiBot.T("猎人"),
    ["Paladin"]      = MultiBot.T("圣骑士"),
    ["Warrior"]      = MultiBot.T("战士"),
}

-- 每个机器人的当前天赋索引 [targetName] = index
MultiBot.talentCycleIndex = {}

-- 机器人品质档案 (跨登录持久化, 由 SavedVariablesPerCharacter 的 MultiBotDB 承载)
-- MultiBotDB.botQuality[name] = "purple" | "blue" | nil
MultiBotDB = MultiBotDB or {}

-- 职业名标准化（UnitClass 可能返回 HUNTER / Deathknight 等各种格式）
local specialClassMap = {
    ["Deathknight"]   = "Death Knight",
    ["DEATHKNIGHT"]   = "Death Knight",
    ["deathknight"]   = "Death Knight",
}

local function NormalizeClassName(rawClass)
    if (rawClass == nil or rawClass == "") then return rawClass end
    local mapped = specialClassMap[rawClass]
    if (mapped ~= nil) then return mapped end
    -- 全大写 / 全小写 / 其它特殊格式: 统一为 Title Case
    local first = string.sub(rawClass, 1, 1):upper()
    local rest  = string.sub(rawClass, 2):lower()
    return first .. rest
end

-- 工具函数：打印信息
local function PrintInfo(msg)
    if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00cccc" .. msg .. "|r")
    else
        print(msg)
    end
end

-- ============================================================
--  装备品质检测 (3.3.5 无 INSPECT_READY 事件, 用延时轮询观察数据)
-- ============================================================

-- 紫装及以上品质的物品链接颜色代码
-- a335ee=史诗 | ff8000=传说 | 00ccff=神器 | e6cc80=传家宝
local EPIC_LINK_COLORS = {
    ["a335ee"] = true,
    ["ff8000"] = true,
    ["00ccff"] = true,
    ["e6cc80"] = true,
}

-- FIX(2026-11-12): 3.3.5 客户端 GetInventoryItemLink("inspect", slot) 的链接
-- 颜色是按本地物品缓存生成的——玩家没见过的物品(如机器人身上的 ICC 史诗)
-- 缓存未命中时颜色退化为白色, 纯看颜色会把紫装机器人误判成蓝装。
-- 现在同时解析链接里的 itemID 并用 GetItemInfo 查权威品质; 未缓存物品先调用
-- GetItemInfo 触发客户端向服务器请求物品数据, 轮询的后续轮次里缓存到达后再判。

-- 扫描观察目标的已装备物品, 返回四元组:
--   total   = 读到的已装备物品链接数 (0 = 观察数据还没到)
--   epic    = 确认为史诗及以上的件数
--   unknown = 颜色为白/普通但本地缓存未命中的件数 (需等下一轮重试)
--   slots   = 观察到物品的槽位数(诊断用)
local function ScanInspectData()
    local total, epic, unknown = 0, 0, 0
    for slot = 1, 19 do
        local link = GetInventoryItemLink("inspect", slot)
        if link and link ~= "" then
            total = total + 1
            local col = link:match("|c(%x%x%x%x%x%x%x%x)")
            local rgb = col and string.sub(col, 3) or ""  -- 跳过 alpha 两位
            if EPIC_LINK_COLORS[rgb] then
                epic = epic + 1
            else
                local itemID = tonumber(link:match("item:(%d+)"))
                if itemID then
                    local _, _, quality = GetItemInfo(itemID)
                    if quality and quality >= 4 then
                        epic = epic + 1
                    elseif not quality then
                        -- 缓存未命中: 调用即触发 CMSG_ITEM_QUERY, 等下一轮重试
                        GetItemInfo(itemID)
                        unknown = unknown + 1
                    end
                end
            end
        end
    end
    return total, epic, unknown
end

-- 兼容旧调用: 只取品质结论
local function ScanInspectQuality()
    local total, epic, unknown = ScanInspectData()
    if total == 0 then return nil end
    if unknown > 0 then return nil end  -- 还有未判定的物品, 视为数据不完整
    return epic > 0 and 4 or 3
end

-- 品质档案读写
local function GetRememberedQuality(name)
    if type(MultiBotDB) == "table" and type(MultiBotDB.botQuality) == "table" then
        return MultiBotDB.botQuality[name]
    end
    return nil
end

local function RememberQuality(name, detectedQ)
    if name == nil or detectedQ == nil then return end
    MultiBotDB = MultiBotDB or {}
    MultiBotDB.botQuality = MultiBotDB.botQuality or {}
    if detectedQ == 4 then
        -- 紫装记忆为粘性: 检测到一次就保留 (蓝装检测不覆盖, 防止
        -- 装备被清空后再检测时误把紫装机器人降级成蓝装)
        MultiBotDB.botQuality[name] = "purple"
    else
        -- 仅当没有更高级记忆时记为蓝装
        if MultiBotDB.botQuality[name] ~= "purple" then
            MultiBotDB.botQuality[name] = "blue"
        end
    end
end

local function ClearQualityMemory(name)
    if type(MultiBotDB) == "table" and type(MultiBotDB.botQuality) == "table" then
        MultiBotDB.botQuality[name] = nil
    end
end

-- 检测目标机器人装备品质, 完成后回调 callback(qualityOrNil, diag)
-- quality: 4=紫装 3=蓝装 nil=检测失败
-- diag: 诊断表 {links=观察物品数, epic=史诗件数, unknown=缓存未命中件数, reason=失败原因}
function MultiBot.DetectBotQuality(callback)
    local unit = "target"
    local name = UnitName(unit)
    if (name == nil or name == "" or not UnitIsPlayer(unit)) then
        callback(nil, { reason = "no_target" })
        return
    end
    -- 目标是自己时不观察
    if UnitIsUnit and UnitIsUnit(unit, "player") then
        callback(nil, { reason = "self" })
        return
    end
    -- 观察需要目标可检视(队伍成员且距离较近); 不可检视时直接回退
    if CanInspect and not CanInspect(unit) then
        callback(nil, { reason = "cannot_inspect" })
        return
    end
    if NotifyInspect then
        NotifyInspect(unit)
    else
        callback(nil, { reason = "no_api" })
        return
    end

    -- FIX(2026-11-12): 轮次增加到 5 次(0.4s 间隔, 最长约 2 秒), 因为未缓存物品
    -- 需要一次服务器往返(CMSG_ITEM_QUERY)后 GetItemInfo 才有品质;
    -- 只要还有 unknown(缓存未命中)就继续轮询, 全部判定后才下结论。
    local attempts = 0
    local MAX_ATTEMPTS = 5
    -- FIX(2026-11-13): 完整性门槛——观察到的槽位太少时"全是蓝"不可信
    -- (史诗件所在槽位可能未送达), 不足以下"蓝装"结论, 继续轮询;
    -- 轮询耗尽仍不完整则按检测失败处理(回退记忆)。19槽中常规装备约16槽。
    local CONFIDENT_MIN_LINKS = 14
    local lastDiag = { reason = "no_data" }
    local function tryScan()
        -- 目标已切换/丢失时观察数据不可信
        if not UnitExists("target") or UnitName("target") ~= name then
            if ClearInspect then ClearInspect() end
            callback(nil, { reason = "target_lost" })
            return
        end
        local total, epic, unknown = ScanInspectData()
        lastDiag = { links = total, epic = epic, unknown = unknown }
        if total > 0 and unknown == 0 and total >= CONFIDENT_MIN_LINKS then
            -- 数据完整: 任意史诗及以上 => 紫装, 否则蓝装
            if ClearInspect then ClearInspect() end
            callback(epic > 0 and 4 or 3, lastDiag)
            return
        end
        attempts = attempts + 1
        if attempts < MAX_ATTEMPTS and type(TimerAfter) == "function" then
            TimerAfter(0.4, tryScan)
        else
            if total > 0 and unknown == 0 and total < CONFIDENT_MIN_LINKS then
                lastDiag.reason = "incomplete"
            end
            if ClearInspect then ClearInspect() end
            callback(nil, lastDiag)
        end
    end

    if type(TimerAfter) == "function" then
        TimerAfter(0.4, tryScan)
    else
        -- 无计时器环境: 只试一次
        local total, epic, unknown = ScanInspectData()
        if ClearInspect then ClearInspect() end
        if total > 0 and unknown == 0 then
            callback(epic > 0 and 4 or 3, { links = total, epic = epic, unknown = unknown })
        else
            callback(nil, { links = total, epic = epic, unknown = unknown, reason = "single_shot" })
        end
    end
end

-- 根据检测值/记忆值/强制值 决定 autogear reset 的品质参数
-- 返回 "purple" / "blue"
local function ResolveGearParam(name, detectedQ, forced)
    if forced == "purple" then return "purple" end
    if forced == "blue" then return "blue" end
    local remembered = GetRememberedQuality(name)
    if detectedQ == 4 then
        RememberQuality(name, 4)
        return "purple"
    elseif detectedQ == 3 then
        -- FIX(2026-11-13): 检测为蓝装但粘性记忆为紫装时, 保守按紫装。
        -- 原因: 装备降级不可逆(autogear reset 会删除已穿装备), 而观察数据
        -- 可能不完整(史诗件所在槽位未送达)导致误判; 显式降级请用 Ctrl+点击。
        if remembered == "purple" then return "purple" end
        RememberQuality(name, 3)
        return "blue"
    end
    -- 检测失败: 回退到记忆值 (粘性紫装), 无记忆默认蓝装
    if remembered == "purple" then return "purple" end
    return "blue"
end

-- ============================================================
--  核心：循环切换目标天赋并发送 3 条密语
--  forced: nil=自动检测 | "purple"=强制紫装 | "blue"=强制蓝装
-- ============================================================

-- 确认弹窗定义 (text 的两个 %s 由 StaticPopup_Show 的 arg1/arg2 填充)
StaticPopupDialogs["MULTIBOT_TALENT_CONFIRM"] = {
    text = MultiBot.T("确认对 |cffffd700%s|r 执行天赋切换？\n\n"
        .. "|cffff6060警告: 已穿装备将被删除并重新配置, 天赋将被重置!|r\n"
        .. "|cffff2020特别提示: 请勿对真实账号(自建账号)的角色使用!|r\n\n"
        .. "目标天赋: |cffffff00%s|r"),
    button1 = MultiBot.T("确认切换"),
    button2 = MultiBot.T("取消"),
    OnAccept = function(self, data)
        if data and MultiBot.CycleTalentConfirmed then
            MultiBot.CycleTalentConfirmed(data)
        end
    end,
    OnCancel = function(self, data)
        PrintInfo(MultiBot.T("|cff888888[天赋切换] 已取消, 未做任何改动。|r"))
    end,
    timeout = 30,
    whileDead = 1,
    hideOnEscape = 1,
    showAlert = 1,
    preferredIndex = 3,
}

-- ============================================================
--  只换装不切天赋 (2026-11-16 十六轮, 用户要求):
--  Alt/Ctrl+点击书按钮 = 仅 "autogear reset purple/blue"。
--  与完整切换的差异: 不发 talents spec、不清天赋变量、不 reset botAI
--  (后者会清除机器人手动保存的策略存档, 只换装时必须跳过)。
-- ============================================================

-- 只换装确认弹窗 (arg1=机器人名, arg2=品质中文名)
StaticPopupDialogs["MULTIBOT_REGEAR_CONFIRM"] = {
    text = MultiBot.T("确认对 |cffffd700%s|r 只重配装备？\n\n"
        .. "|cffff6060警告: 已穿装备将被删除并重新配置!|r\n"
        .. "|cffff2020特别提示: 请勿对真实账号(自建账号)的角色使用!|r\n\n"
        .. "品质档位: |cffffff00%s|r\n"
        .. "|cff888888本次不切换天赋、不重置策略。|r"),
    button1 = MultiBot.T("确认重配"),
    button2 = MultiBot.T("取消"),
    OnAccept = function(self, data)
        if data and MultiBot.RegearOnlyConfirmed then
            MultiBot.RegearOnlyConfirmed(data)
        end
    end,
    OnCancel = function(self, data)
        PrintInfo(MultiBot.T("|cff888888[装备重配] 已取消, 未做任何改动。|r"))
    end,
    timeout = 30,
    whileDead = 1,
    hideOnEscape = 1,
    showAlert = 1,
    preferredIndex = 3,
}

-- 实际执行体 (确认后调用)
function MultiBot.RegearOnlyConfirmed(data)
    local targetName = data.name
    local forced     = data.forced -- "purple" | "blue"
    if (targetName == nil or targetName == "" or forced == nil) then return end

    -- 品质记忆同步 (与切换路径一致: Alt 记紫装粘性; Ctrl 清粘性后记蓝装)
    if forced == "purple" then
        RememberQuality(targetName, 4)
        PrintInfo(MultiBot.T("|cffffaa00[装备重配] Alt 检测到: 强制按 |cffffd700紫装|cffffaa00 重配装备|r"))
    else
        ClearQualityMemory(targetName)
        RememberQuality(targetName, 3)
        PrintInfo(MultiBot.T("|cffffaa00[装备重配] Ctrl 检测到: 强制按 |cff0070dd蓝装|cffffaa00 重配装备 (已清除粘性紫装记忆)|r"))
    end

    -- 作废在途的切换序列 (若正在 3 秒等待窗口内, 以本次操作为准, 防交错)
    MultiBot._talentSeq = (MultiBot._talentSeq or 0) + 1

    SendChatMessage("autogear reset " .. forced, "WHISPER", nil, targetName)

    local qualityCN = forced == "purple" and MultiBot.T("|cffffd700紫装|r") or MultiBot.T("|cff0070dd蓝装|r")
    PrintInfo(MultiBot.TF(
        "|cff00ff00[装备重配] |r|cff00ccff%s|r"
        .. " |cff888888只重配装备, 不切天赋、不重置策略|r"
        .. "\n|cff00ff44  装备: |cffffd700autogear reset %s|r |cff888888(已发送, 品质: %s)|r"
        .. "\n|cffff2020  特别提示: 装备删除后不可恢复!|r",
        targetName, forced, qualityCN
    ))
    if PlaySound then PlaySound("igMainMenuOptionCheckBoxOn") end
end

-- 入口: 校验目标 -> 弹确认框 -> 确认后只换装
function MultiBot.RegearOnly(targetName, forced)
    if (targetName == nil or targetName == "") then
        PrintInfo(MultiBot.T("|cffff0000[装备重配]|r 没有选择目标，请先选中一个队伍中的机器人。"))
        return
    end
    if (not UnitIsPlayer("target")) then
        PrintInfo(MultiBot.T("|cffff0000[装备重配]|r 目标不是玩家，请选中一个玩家机器人。"))
        return
    end
    local isParty = UnitInParty("target")
    local isRaid  = UnitInRaid("target")
    if (isParty == nil and isRaid == nil) then
        PrintInfo(MultiBot.TF("|cffff0000[装备重配]|r %s 不在你的队伍中。", targetName))
        return
    end
    if (forced ~= "purple" and forced ~= "blue") then
        PrintInfo(MultiBot.T("|cffff0000[装备重配]|r 未指定品质 (Alt=紫装, Ctrl=蓝装)。"))
        return
    end

    local data = { name = targetName, forced = forced }
    if StaticPopup_Show then
        StaticPopup_Show("MULTIBOT_REGEAR_CONFIRM", targetName,
            forced == "purple" and MultiBot.T("紫装") or MultiBot.T("蓝装"), data)
    else
        MultiBot.RegearOnlyConfirmed(data)
    end
end

-- 实际执行体 (确认弹窗点"确认切换"后调用)
function MultiBot.CycleTalentConfirmed(data)
    local targetName  = data.name
    local forced      = data.forced
    local talents     = data.talents
    local cnClassName = data.cnClassName
    local nextIndex   = data.nextIndex

    local englishName = talents[nextIndex][1]
    local chineseName = talents[nextIndex][2]

    -- 手动强制时同步档案 (放在确认后: 取消弹窗不应改动品质记忆)
    if forced == "purple" then
        RememberQuality(targetName, 4)
        PrintInfo(MultiBot.T("|cffffaa00[天赋切换] Alt 检测到: 强制按 |cffffd700紫装|cffffaa00 重配装备|r"))
    elseif forced == "blue" then
        ClearQualityMemory(targetName)
        RememberQuality(targetName, 3)
        PrintInfo(MultiBot.T("|cffffaa00[天赋切换] Ctrl 检测到: 强制按 |cff0070dd蓝装|cffffaa00 重配装备 (已清除粘性紫装记忆)|r"))
    end

    -- FIX(2026-09-20): 天赋切换与装备刷新不能同时发送。
    -- 旧行为三条密语连发, 服务端尚在处理 talents spec 时刷新装备已到达,
    -- 导致按"旧天赋"刷新装备。现在: 切天赋 -> 等3秒(服务端完成切换加点) -> 装备
    --                                  -> 等1秒 -> reset botAI
    -- 连续点击时序号校验自动作废旧的任务, 以最后一次为准。
    --
    -- FIX(2026-11-11): 装备命令由 ".playerbot bot init=Epic" 改为 "autogear reset"。
    -- init=xxx 实际执行 PlayerbotFactory::Randomize(false) 全量重建: 除重配装备外
    -- 还会洗掉刚点的天赋(InitTalentsTree 按 RandomClassSpecProb 随机重掷)、改等级、
    -- 清技能/任务/背包, 与"换天赋"目的直接冲突; 且服务端命令表为全小写
    -- "init=epic", 大写 "init=Epic" 按源码会落 "unknown command"。
    --
    -- FIX(2026-11-11 b): autogear reset 显式携带品质参数 blue/purple。
    -- AutoGearAction 逻辑: quality = min(请求品质, conf AutoGearQualityLimit);
    -- conf 已调至 4(史诗), 因此蓝装机器人发 "autogear reset blue"(精良)、
    -- 紫装机器人发 "autogear reset purple"(史诗), 各自保持原有品质档位。
    -- 品质检测在点击瞬间进行(观察目标装备链接颜色), 早于 3 秒后的装备清空。
    MultiBot._talentSeq = (MultiBot._talentSeq or 0) + 1
    local mySeq = MultiBot._talentSeq

    -- 循环序号推进移到确认后 (取消时不消耗)
    MultiBot.talentCycleIndex[targetName] = nextIndex

    -- FIX(2026-11-14): 清真实天赋缓存——切换后旧缓存会误导绿点(出厂默认策略)标记。
    -- (2026-11-16 注释更新: 自动观察检测已移除; 新值由下方 RunSequence 里的
    --  TalentCacheSetManual 直写。此处清理兜底"直写失败档位"(如敏锐贼)不残留旧值)
    if(MultiBot.TalentCache ~= nil) then MultiBot.TalentCache[targetName] = nil end

    -- 实际执行序列 (gearParam 为 "blue"/"purple", source 为来源说明)
    local function RunSequence(gearParam, source)
        if MultiBot._talentSeq ~= mySeq then return end

        -- 1) 切换天赋（立即发送）
        local command = "talents spec " .. englishName .. " pve"
        SendChatMessage(command, "WHISPER", nil, targetName)

        -- FIX(2026-11-14 四轮): 书按钮直写真实天赋缓存(用户建议)。
        -- 切换指令是我们自己发的, 目标天赋就是权威答案——直写绿点缓存并持久化,
        -- 该机器人不再依赖观察检测(观察有距离/异步/通道互斥等失败点)。
        -- 注意: 这里必须晚于上面 talentCycleIndex 处的 TalentCache 清理, 否则会被清掉。
        if(MultiBot.TalentCacheSetManual ~= nil) then
            if(MultiBot.TalentCacheSetManual(targetName, englishName)) then
                PrintInfo(MultiBot.TF("|cff00ff44[天赋切换] 绿点档位已同步: |cffffff00%s → %s|r", targetName, englishName))
            else
                PrintInfo(MultiBot.TF("|cffffaa00[天赋切换] 提示: %s 无服务端默认策略表, 该机器人绿点暂不显示。|r", englishName))
            end
        end

        local function DelayedInit()
            if MultiBot._talentSeq ~= mySeq then return end
            SendChatMessage("autogear reset " .. gearParam, "WHISPER", nil, targetName)
            if type(TimerAfter) == "function" then
                TimerAfter(1, function()
                    if MultiBot._talentSeq ~= mySeq then return end
                    SendChatMessage("reset botAI", "WHISPER", nil, targetName)
                end)
            else
                SendChatMessage("reset botAI", "WHISPER", nil, targetName)
            end
        end

        if type(TimerAfter) == "function" then
            TimerAfter(3, DelayedInit)
        else
            DelayedInit()  -- 兜底: 无计时器环境退化为旧行为
        end

        -- 聊天反馈
        local nextNextIndex = nextIndex + 1
        if (nextNextIndex > #talents) then nextNextIndex = 1 end
        local totalStr = tostring(#talents)
        local qualityCN = gearParam == "purple" and MultiBot.T("|cffffd700紫装|cff888888") or MultiBot.T("|cff0070dd蓝装|cff888888")
        PrintInfo(MultiBot.TF(
            "|cff00ff00[天赋切换] |r|cff00ccff%s|r(%s)"
            .. " -> |cffffff00%s|r"
            .. " |cff888888[%s/%s]|r"
            .. "\n|cff00ff44  密语: |cffffd700%s|r"
            .. "\n|cff00ff44  装备: |cffffd700autogear reset %s|r |cff888888(3秒后, 按新天赋重配; 品质:%s %s)|r"
            .. "\n|cff00ff44  AI重置: |cffffd700reset botAI|r |cff888888(4秒后, 重建策略并清除旧策略存档)|r"
            .. "\n|cffaaaaaa  下次点击: |cffffd700%s"
            .. "|r (共%s种天赋循环)|r"
            .. "\n|cffaaaaaa  Alt/Ctrl+点击: 只重配装备不切天赋 (Alt=紫装, Ctrl=蓝装)|r"
            .. "\n|cffff2020  特别提示: 请勿对真实账号(自建账号)的角色使用, 装备删除后不可恢复!|r"
            .. "\n|cffffaa00  策略说明: |cffddddddtalents spec 与 reset botAI 都会按新天赋自动重建默认策略, 并清除旧策略存档;"
            .. "该机器人之前手动保存的策略(co/nc)会被清掉, 如需保留请先备份。|r",
            targetName, cnClassName, chineseName, tostring(nextIndex), totalStr,
            command, gearParam, qualityCN, source,
            talents[nextNextIndex][2], totalStr
        ))

        if PlaySound then PlaySound("igMainMenuOptionCheckBoxOn") end
    end

    -- 先做品质检测(最长约2秒, 含未缓存物品的补查轮询), 再执行序列
    MultiBot.DetectBotQuality(function(detectedQ, diag)
        if MultiBot._talentSeq ~= mySeq then return end
        local gearParam = ResolveGearParam(targetName, detectedQ, forced)
        local source
        if forced == "purple" or forced == "blue" then
            source = MultiBot.T("(手动强制)")
        elseif detectedQ == 4 or detectedQ == 3 then
            local d = diag or {}
            if detectedQ == 3 and gearParam == "purple" then
                -- FIX(2026-11-13): 检测与粘性紫装记忆冲突, 保守按紫装
                source = MultiBot.T("(检测到蓝装但与紫装记忆冲突, 保守按紫装; 显式降级请 Ctrl+点击)")
            else
                source = MultiBot.TF("(实时观察: 物品%s件/史诗%s件)", tostring(d.links or "?"), tostring(d.epic or "?"))
            end
        else
            local d = diag or {}
            local why = d.reason == "cannot_inspect" and MultiBot.T("目标不可检视")
                or d.reason == "target_lost" and MultiBot.T("观察期间目标切换")
                or d.reason == "no_data" and MultiBot.T("未收到观察数据(距离太远?)")
                or d.reason == "incomplete" and MultiBot.TF("观察数据不完整(槽位%s件, 不足14)", tostring(d.links or "?"))
                or d.reason == "single_shot" and MultiBot.T("物品信息未全部缓存")
                or tostring(d.reason or MultiBot.T("未知"))
            source = MultiBot.TF("(检测失败: %s; 用了记忆/默认蓝装, 可Alt+点击强制紫装)", why)
        end
        RunSequence(gearParam, source)
    end)
end

-- 入口: 校验目标 -> 弹确认框 -> 确认后执行
function MultiBot.CycleTalent(targetName, forced)
    if (targetName == nil or targetName == "") then
        PrintInfo(MultiBot.T("|cffff0000[天赋切换]|r 没有选择目标，请先选中一个队伍中的机器人。"))
        return
    end
    if (not UnitIsPlayer("target")) then
        PrintInfo(MultiBot.T("|cffff0000[天赋切换]|r 目标不是玩家，请选中一个玩家机器人。"))
        return
    end
    local isParty = UnitInParty("target")
    local isRaid  = UnitInRaid("target")
    if (isParty == nil and isRaid == nil) then
        PrintInfo(MultiBot.TF("|cffff0000[天赋切换]|r %s 不在你的队伍中。", targetName))
        return
    end

    local _, rawClass = UnitClass("target")
    local englishClass = NormalizeClassName(rawClass)

    local talents = MultiBot.talentData[englishClass]
    if (talents == nil or #talents == 0) then
        local cnName = MultiBot.talentClassNameCN[englishClass] or englishClass or MultiBot.T("未知")
        PrintInfo(MultiBot.TF("|cffff0000[天赋切换]|r 未找到职业 %s 的天赋配置。", cnName))
        return
    end

    -- 只预览下一个天赋, 序号推进移到确认后 (取消时不消耗)
    local currentIndex = MultiBot.talentCycleIndex[targetName] or 0
    local nextIndex = currentIndex + 1
    if (nextIndex > #talents) then nextIndex = 1 end
    local chineseName = talents[nextIndex][2]
    local cnClassName = MultiBot.talentClassNameCN[englishClass] or englishClass

    local data = {
        name = targetName,
        forced = forced,
        talents = talents,
        englishClass = englishClass,
        cnClassName = cnClassName,
        nextIndex = nextIndex,
    }

    if StaticPopup_Show then
        StaticPopup_Show("MULTIBOT_TALENT_CONFIRM", targetName, chineseName, data)
    else
        -- 无弹窗环境兜底: 直接执行
        MultiBot.CycleTalentConfirmed(data)
    end
end

-- 显示当前目标的天赋列表
function MultiBot.ShowTalentList()
    local targetName = UnitName("target")
    local _, rawClass = UnitClass("target")
    local englishClass = NormalizeClassName(rawClass)

    if (targetName == nil or targetName == "") then
        PrintInfo(MultiBot.T("|cff888888[天赋列表] 没有选择目标。用法: 选中机器人后输入 /mbt 查看可用天赋，或点击动作条按钮循环切换。"))
        return
    end

    local talents = MultiBot.talentData[englishClass]
    if (talents == nil or #talents == 0) then
        local cnName = MultiBot.talentClassNameCN[englishClass] or englishClass or MultiBot.T("未知")
        PrintInfo(MultiBot.TF("|cff888888[天赋列表] 职业 %s 无天赋配置。", cnName))
        return
    end

    local cnClassName = MultiBot.talentClassNameCN[englishClass] or englishClass
    local curIdx = MultiBot.talentCycleIndex[targetName] or 0
    local remembered = GetRememberedQuality(targetName)

    PrintInfo(MultiBot.TF("|cff00ff00--- %s (%s) 可用天赋 ---|r", targetName, cnClassName))
    for i, t in ipairs(talents) do
        local mark = ""
        if (i == curIdx) then
            mark = MultiBot.T(" |cffffff00[当前]|r")
        elseif (i == curIdx + 1 or (curIdx >= #talents and i == 1)) then
            mark = MultiBot.T(" |cff00ff00[下一次]|r")
        end
        PrintInfo(MultiBot.TF("  |cffcccccc%s.|r |cffffff00%s|r (|cff888888talents spec %s pve|r)%s", tostring(i), t[2], t[1], mark))
    end
    if remembered == "purple" then
        PrintInfo(MultiBot.T("|cffaaaaaa装备品质档案: |cffffd700紫装|r (换天赋时自动按紫装重配; Ctrl+点击只按蓝装重配不切天赋)|r"))
    elseif remembered == "blue" then
        PrintInfo(MultiBot.T("|cffaaaaaa装备品质档案: |cff0070dd蓝装|r (换天赋时自动按蓝装重配)|r"))
    end
    PrintInfo(MultiBot.TF("|cff888888共 %s 种天赋，点击按钮循环切换(需确认); Alt/Ctrl+点击=只重配装备不切天赋(Alt=紫, Ctrl=蓝)|r", tostring(#talents)))
    PrintInfo(MultiBot.T("|cffff2020[天赋切换] 特别提示: 请勿对真实账号(自建账号)的角色使用——装备删除后不可恢复!|r"))
end

-- ============================================================
-- 聊天命令 /mbt 或 /multibottalent
-- ============================================================
-- 诊断命令: 观察目标并打印原始数据, 用于排查品质检测链路
local function DiagnoseInspect()
    local name = UnitName("target")
    if name == nil or name == "" then
        PrintInfo(MultiBot.T("|cffff0000[品质诊断]|r 没有目标。"))
        return
    end
    if not UnitIsPlayer("target") then
        PrintInfo(MultiBot.T("|cffff0000[品质诊断]|r 目标不是玩家。"))
        return
    end
    if CanInspect and not CanInspect("target") then
        PrintInfo(MultiBot.T("|cffff0000[品质诊断]|r CanInspect=false, 目标不可检视(需在队伍且近距离)。"))
        return
    end
    NotifyInspect("target")
    local attempts = 0
    local function show()
        attempts = attempts + 1
        local total, epic, unknown = ScanInspectData()
        PrintInfo(MultiBot.TF(
            "|cff00ff00[品质诊断] 第%d次轮询 %s: |r观察物品=%d 史诗=%d 缓存未命中=%d%s",
            attempts, name, total, epic, unknown,
            (total > 0 and unknown == 0) and (MultiBot.T(" => 判定: ") .. (epic > 0 and MultiBot.T("|cffffd700紫装|r") or MultiBot.T("|cff0070dd蓝装|r"))) or MultiBot.T(" => 数据不完整, 继续等待")))
        if (total == 0 or unknown > 0) and attempts < 5 then
            TimerAfter(0.4, show)
        else
            if ClearInspect then ClearInspect() end
            if total == 0 then
                PrintInfo(MultiBot.T("|cffff0000[品质诊断]|r 5次轮询均未收到观察数据: 服务器未响应观察或距离过远。"))
            end
        end
    end
    TimerAfter(0.4, show)
end

SLASH_MULTIBOTTALENT1 = "/mbt"
SLASH_MULTIBOTTALENT2 = "/multibottalent"
SlashCmdList["MULTIBOTTALENT"] = function(msg)
    msg = msg or ""
    if msg == "cycle" or msg == "next" or msg == "循环" then
        MultiBot.CycleTalent(UnitName("target"))
    elseif msg == "gear purple" or msg == "只换紫" then
        MultiBot.RegearOnly(UnitName("target"), "purple")
    elseif msg == "gear blue" or msg == "只换蓝" then
        MultiBot.RegearOnly(UnitName("target"), "blue")
    elseif msg == "purple" or msg == "紫" then
        MultiBot.CycleTalent(UnitName("target"), "purple")
    elseif msg == "blue" or msg == "蓝" then
        MultiBot.CycleTalent(UnitName("target"), "blue")
    elseif msg == "detect" or msg == "诊断" then
        DiagnoseInspect()
    else
        MultiBot.ShowTalentList()
    end
end

-- ============================================================
-- 集成到 MultiBot 动作条
-- 注意: MultiBot 没有全局 MultiBot.addButton, 只有 frame.addButton
--       MultiBar 的子框架: Left / Right / Main / Units 等
--       这里挂到 Right 框架的空闲位置 (现有按钮到 x=272 为止, 306 空闲)
-- ============================================================
local BUTTON_NAME = "TalentSwitcher"
-- FIX(2026-11-13): 306→272。右行按钮链(Quest0/Drink34/Release68/Revive102/AllBots136/Afk170/SelfAfk204/Loot238)
-- 每格34px 连续排布, 306 会留出一个空格; 272 紧贴 Loot, 全行零空格。
local BUTTON_POS_X = 272
local BUTTON_POS_Y = 0

local function GetTalentButtonParent()
    if not MultiBot.frames then return nil end
    local multiBar = MultiBot.frames["MultiBar"]
    if not multiBar or not multiBar.frames then return nil end
    -- 优先 Right 框架
    local tRight = multiBar.frames["Right"]
    if tRight and tRight.addButton then return tRight end
    -- 回退 Left
    local tLeft = multiBar.frames["Left"]
    if tLeft and tLeft.addButton then return tLeft end
    return nil
end

local function RegisterTalentButton()
    local parent = GetTalentButtonParent()
    if not parent then return false end

    -- 防止重复注册
    if parent.buttons and parent.buttons[BUTTON_NAME] then
        return true
    end

    local tipText = MultiBot.T("循环切换目标机器人天赋\n"
        .. "  1) talents spec <天赋> pve (立即)\n"
        .. "  2) autogear reset blue/purple (3秒后, 按新天赋重配装备;\n"
        .. "     品质自动保持: 蓝->蓝, 紫->紫)\n"
        .. "  3) reset botAI (4秒后, 重建策略并清旧存档)\n"
        .. "|cffff2020特别提示: 请勿对真实账号(自建账号)的角色使用!\n"
        .. "  装备删除后不可恢复, 点击后会弹确认框|r\n"
        .. "|cff00ccffAlt+点击: 只按紫装重配装备(不切天赋)\n"
        .. "Ctrl+点击: 只按蓝装重配装备(不切天赋)|r\n"
        .. "聊天命令 /mbt 查看天赋列表, /mbt cycle 循环切换")

    local btn = parent.addButton(
        BUTTON_NAME, BUTTON_POS_X, BUTTON_POS_Y,
        "Interface\\Icons\\INV_Misc_Book_01",
        tipText
    )

    if not btn then return false end

    btn.doLeft = function()
        -- 十六轮: Alt/Ctrl+点击 = 只换装不切天赋 (Alt=紫装, Ctrl=蓝装);
        -- 普通左键 = 完整切换(切天赋+按检测品质换装+重置AI), 行为不变。
        if IsAltKeyDown() then
            MultiBot.RegearOnly(UnitName("target"), "purple")
        elseif IsControlKeyDown() then
            MultiBot.RegearOnly(UnitName("target"), "blue")
        else
            MultiBot.CycleTalent(UnitName("target"))
        end
    end
    MultiBot.talentButton = btn

    return true
end

-- 暴露给外部/调试
MultiBot.RegisterTalentButton = RegisterTalentButton

-- 1) 直接尝试注册 (本文件在 .toc 中最后加载, 此时 MultiBar/Right 已创建)
local ok = RegisterTalentButton()

-- 2) 若失败, 再挂事件重试
if not ok then
    local RegisterFrame = CreateFrame("Frame")
    RegisterFrame:RegisterEvent("PLAYER_LOGIN")
    RegisterFrame:RegisterEvent("ADDON_LOADED")
    RegisterFrame:SetScript("OnEvent", function(self, event, arg)
        if event == "ADDON_LOADED" and arg ~= "MultiBot" then return end
        if RegisterTalentButton() then
            self:UnregisterEvent("PLAYER_LOGIN")
            self:UnregisterEvent("ADDON_LOADED")
            self:SetScript("OnEvent", nil)
        end
    end)
end

if ok then
    PrintInfo(MultiBot.T("|cff00ff00MultiBot 天赋切换模块已加载 (按钮已注册, 品质保持: 蓝/紫自动检测, 点击需确认)。命令: /mbt|r"))
else
    PrintInfo(MultiBot.T("|cff00ff00MultiBot 天赋切换模块已加载 (按钮待注册, 品质保持: 蓝/紫自动检测, 点击需确认)。命令: /mbt|r"))
end
