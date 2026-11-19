--------------------------------------------------------------------------------
-- MultiBotTalentDetect → 天赋变量模块(11-15 起改型)
--
-- FIX(2026-11-14): 绿点(出厂默认策略标记)锚定机器人"真实天赋"而非"当前策略栈推断"。
--   栈推断的问题: 手动点亮别的天赋对应的主策略后, 栈就不再反映天赋(如惩戒骑点坦克
--   → 栈里是 prot → 被反推成防护天赋 → 坦克按钮被误打绿点)。
--
-- FIX(2026-11-15 用户定型方案): 天赋变量的写入源只有两个, 都是权威数据:
--   ① 用户手动录入: Ctrl+左键点击机器人头像按钮(Units 列表/策略根按钮所在列) →
--      弹出录入界面, 下拉框选择中文天赋(选项与书按钮 MultiBot.talentData 同源)/清除;
--   ② 书按钮确认切换天赋(TalentSwitcher 确认执行体 RunSequence)→ TalentCacheSetManual
--      直写新档, 变量自动跟随(书按钮取消 = 零副作用, 变量不变)。
--   原"NotifyInspect 自动观察检测"整段移除(观察有距离/异步/与品质检测通道互斥等
--   失败面, 且与手动方案冗余)。
--
-- 存储: 会话缓存 MultiBot.TalentCache[name] = { spec = key, manual = true } +
--       跨登录持久化 MultiBotDB.botSpec[name](SavedVariablesPerCharacter, 登出落盘)。
--       十五轮起存原始 key(如 frostfire), 绿点消费端按 MultiBot.TalentSpecMap 换算档位。
-- 消费: MarkDefaultStrategies 只认缓存; 无变量 → 坚决不打绿点(宁可没有, 不可标错)。
--
-- 档位 key 说明:
--   - 德鲁伊 feral 与 cat/bear: 服务端野性档登记名 feral; MarkDefaultStrategies 会
--     按栈里的 cat/bear 细分绿点, 所以录入 balance/resto/cat/bear/feral 均可;
--   - 盗 subtlety 等服务端无出厂默认表的档位: 录入成功但绿点自然不标(无表可查)。
--------------------------------------------------------------------------------

local MultiBot = _G["MultiBot"]
if(MultiBot == nil) then return end
if(MultiBot._talentSpecLoaded) then return end
MultiBot._talentSpecLoaded = true

-- 档位 key 有效性集合(与 StrategyDefaults 的档位集合对齐; 书按钮通道共用本表校验)
local MANUAL_SPEC_KNOWN = {
	disc = true, holy = true, shadow = true,
	blood = true, frost = true, unholy = true,
	balance = true, feral = true, resto = true, cat = true, bear = true,
	arcane = true, fire = true,
	prot = true, ret = true,
	bm = true, mm = true, surv = true,
	assassin = true, combat = true,
	ele = true, enh = true,
	affli = true, demo = true, destro = true,
	arms = true, fury = true,
}
-- 英文名 → 服务端档位 key 的少量例外映射(书按钮 talents spec 用英文天赋名):
--   demo→demo / double aura blood→blood(服务端该预制主导系=鲜血, 绿点按鲜血档标)
--   as→assassin(服务端刺杀别名) / frostfire→fire(绿点档位按火焰算)
-- 另有两条"旧 key 兼容": emo→demo、doubleaurablood→blood(书按钮历史拼写, 仅旧存档会带)。
-- FIX(2026-11-16 十五轮): 映射只用于"绿点档位换算", 不再在写入时归一化——
--   旧版写入时就把 frostfire 折成 fire, 霜火/纯火的区分在存储时丢失, 书按钮切霜火法后
--   录入界面反查 fire 显示成"火法"。现在存储保留原始 key(frostfire/as/双光环等),
--   绿点消费端(MarkDefaultStrategies)再按本表换算档位。暴露为全局供 Defaults 使用。
local MANUAL_SPEC_MAP = {
	emo             = "demo",
	doubleaurablood = "blood",
	["double aura blood"] = "blood",
	["as"]          = "assassin",
	frostfire       = "fire",
}
MultiBot.TalentSpecMap = MANUAL_SPEC_MAP

-- 旧 key → 新 key, 只用于"显示/下拉反查"(不改存档值):
-- 三十一轮把书按钮的 emo/doubleaurablood 改成服务端原名, 旧存档仍可能存着旧写法。
local LEGACY_SPEC_ALIAS = { emo = "demo", doubleaurablood = "double aura blood" }

-- 各职业可选档位: 十二轮起直接读书按钮 MultiBot.talentData(单一数据源),
-- 不再维护手写提示表(旧表德鲁伊 5 key 与书按钮 4 项不同步, 已废弃)。

-- 变量写入后: 找到该机器人当前可见的策略条, 重跑绿点标记
local function reMarkAfterDetect(pName)
	local tUnits = MultiBot.frames and MultiBot.frames["MultiBar"]
		and MultiBot.frames["MultiBar"].frames and MultiBot.frames["MultiBar"].frames["Units"]
	local tBtn = tUnits and tUnits.buttons and tUnits.buttons[pName]
	local tFrame = tUnits and tUnits.frames and tUnits.frames[pName]
	-- 十六轮: 变量增删/切换后同步刷新 tooltip 首行(职业后追加天赋中文名)。
	-- 自身玩家按钮(tooltip=unit.selfbot 专用格式, roster="players")不适用 toTip 重建, 跳过。
	if(tBtn ~= nil and tBtn.roster ~= "players" and MultiBot.toTip ~= nil) then
		tBtn.tip = MultiBot.toTip(tBtn.class, tBtn.level, tBtn.name)
	end
	if(tBtn ~= nil and tFrame ~= nil and MultiBot.MarkDefaultStrategies ~= nil) then
		MultiBot.MarkDefaultStrategies(tFrame, tBtn.class, tBtn.combat, tBtn.normal)
	end
end

function MultiBot.TalentCacheSetManual(pName, pSpecKey)
	if(pName == nil or pName == "" or pSpecKey == nil) then return false end
	-- 校验按档位 key(映射后), 存储保留原始 key——霜火法(frostfire)不再被折成 fire
	local tKey = MANUAL_SPEC_MAP[pSpecKey] or pSpecKey
	if(not MANUAL_SPEC_KNOWN[tKey]) then return false end
	MultiBot.TalentCache = MultiBot.TalentCache or {}
	MultiBot.TalentCache[pName] = { spec = pSpecKey, manual = true }
	-- 跨登录持久化(重登后绿点立即准确)
	if(MultiBotDB ~= nil) then
		MultiBotDB.botSpec = MultiBotDB.botSpec or {}
		MultiBotDB.botSpec[pName] = pSpecKey
	end
	reMarkAfterDetect(pName)
	return true
end

-- 服务端天赋全名 → 天赋变量档位 key
--   目的: SetTalents 按钮(每行最后的剑图标)选完天赋后同步绿点变量。
--   规则: 剥掉末尾 " pve"/" pvp" 后缀即可——PVP 预制与同名 PVE 是同一主导树,
--         所以 PVP 直接沿用对应 PVE 的档位(不会标错绿点)。
--   例: "arms pve"/"arms pvp" → "arms"; "double aura blood pve" → "double aura blood"。
--   校验仍由 TalentCacheSetManual 负责(as→assassin / frostfire→fire / 双光环→blood 等)。
function MultiBot.SpecToTalentKey(pSpec)
	if(type(pSpec) ~= "string") then return nil end
	local tKey = pSpec:lower():gsub("^%s+", ""):gsub("%s+$", "")
	tKey = tKey:gsub("%s+pvp$", ""):gsub("%s+pve$", "")
	if(tKey == "") then return nil end
	return tKey
end

-- 清除某机器人的天赋变量(录入界面"清除"按钮): 绿点随之消失
function MultiBot.TalentCacheClear(pName)
	if(pName == nil or pName == "") then return end
	if(MultiBot.TalentCache ~= nil) then MultiBot.TalentCache[pName] = nil end
	if(MultiBotDB ~= nil and MultiBotDB.botSpec ~= nil) then MultiBotDB.botSpec[pName] = nil end
	reMarkAfterDetect(pName)
end

-- 从持久化档案回填缓存(只回填, 不覆盖本会话已有值; 幂等, 可重复调用)
-- FIX(2026-11-16 十七轮): "退出游戏后天赋变量不保存"根因——
--   MultiBotDB 是 SavedVariablesPerCharacter(角色存档), 而插件 .lua 在登录画面
--   就已执行; 文件作用域的一次性回填跑的时候角色存档还没载入(全局 MultiBotDB 为 nil),
--   于是本会话 TalentCache 永远是空的: 界面显示"未设置"、绿点缺失, 看着就像"没保存"。
--   /reload 时角色存档已在内存中, 所以 reload 后一直正常, 只有完整退出游戏才复现。
--   存档本身写入是好的(登出照常落盘), 缺的只是"进游戏后读回来"。
-- 修法: 回填抽成函数, 除文件作用域外再在角色存档载入后的三个时点各补一次。
function MultiBot.TalentCacheRestoreFromDB()
	local tDB = _G.MultiBotDB or MultiBotDB
	if(tDB == nil or tDB.botSpec == nil) then return false end
	MultiBot.TalentCache = MultiBot.TalentCache or {}
	local tChanged = false
	for tName, tKey in pairs(tDB.botSpec) do
		-- 十五轮起存档可能是原始 key(frostfire/emo/as), 校验同样先按档位映射
		if(MANUAL_SPEC_KNOWN[MANUAL_SPEC_MAP[tKey] or tKey] and MultiBot.TalentCache[tName] == nil) then
			MultiBot.TalentCache[tName] = { spec = tKey, manual = true }
			tChanged = true
		end
	end
	return tChanged
end

MultiBot.TalentCacheRestoreFromDB()

-- 角色存档载入晚于插件文件: 三个时点各补一次回填(幂等, 已有值不覆盖),
-- 回填成功后刷新已有按钮的 tooltip/绿点(按钮还没建时函数内部自会跳过)。
do
	local tRestore = CreateFrame("Frame")
	tRestore:RegisterEvent("ADDON_LOADED")
	tRestore:RegisterEvent("VARIABLES_LOADED")
	tRestore:RegisterEvent("PLAYER_ENTERING_WORLD")
	tRestore:SetScript("OnEvent", function(self, pEvent, pArg1)
		if(pEvent == "ADDON_LOADED" and pArg1 ~= "MultiBot") then return end
		if(MultiBot.TalentCacheRestoreFromDB()) then
			for tName in pairs(MultiBot.TalentCache or {}) do
				reMarkAfterDetect(tName)
			end
		end
	end)
end

--------------------------------------------------------------------------------
-- Ctrl+左键 录入界面
-- FIX(2026-11-16 十二轮): 三处整改(用户反馈):
--   ① 手填英文 key → 下拉框选中文天赋, 选项直接读书按钮同一张 MultiBot.talentData
--      表(单一数据源, 天然同步; 德鲁伊=鸟德/熊德/奶德/猫德 4 项, 不再是手写 5 key)
--   ② 串框: 旧版设置成功后弹窗滞留(DIALOG 层级+鼠标拦截), Ctrl 点下一个机器人时
--      点击被旧弹窗吃掉/旧框滞留 → 设置/清除成功后自动关窗, 每次打开按新机器人重建
--   ③ 当前变量按中文显示(反查书按钮表), 表外旧值(如 feral)原样显示 key
--------------------------------------------------------------------------------

-- 判定一个按钮是否为"机器人头像按钮"(Units 列表, 即策略根按钮所在列的机器人按钮):
-- 只有头像按钮被写入 roster/class/name 三件套, 面板策略按钮/工具按钮都没有 roster。
function MultiBot.OnButtonCtrlClick(pButton)
	if(pButton == nil or pButton.roster == nil or pButton.class == nil or pButton.name == nil) then
		return false
	end
	MultiBot.TalentSpecUIOpen(pButton.name, pButton.class)
	return true
end

local tPopup

-- 书按钮天赋表的职业 key 用 "Death Knight", 插件内部规范名是 "DeathKnight", 映射一层
local function talentListOf(pClass)
	if(MultiBot.talentData == nil) then return nil end
	if(pClass == "DeathKnight") then return MultiBot.talentData["Death Knight"] end
	return MultiBot.talentData[pClass]
end

-- 档位 key → 中文名(反查书按钮表; 先精确匹配再按例外映射匹配,
-- 避免法师 fire 被 frostfire→fire 映射抢先显示成"霜火法")
local function specCN(pClass, pSpecKey)
	local tList = talentListOf(pClass)
	if(tList == nil or pSpecKey == nil) then return nil end
	pSpecKey = LEGACY_SPEC_ALIAS[pSpecKey] or pSpecKey
	for _, t in ipairs(tList) do if(t[1] == pSpecKey) then return t[2] end end
	for _, t in ipairs(tList) do
		if((MANUAL_SPEC_MAP[t[1]] or t[1]) == pSpecKey) then return t[2] end
	end
	return nil
end

-- 十六轮: 单位按钮 tooltip 首行显示用——返回该机器人天赋变量的中文名。
-- 无变量返回 nil(宁可没有, 不可标错); 有变量但书按钮表查不到中文名时返回原始 key(真实存储值)。
function MultiBot.GetTalentSpecDisplay(pName, pClass)
	local tTalent = MultiBot.TalentCache ~= nil and MultiBot.TalentCache[pName] or nil
	if(tTalent == nil or tTalent.spec == nil or pClass == nil) then return nil end
	return specCN(pClass, tTalent.spec) or tTalent.spec
end

-- 下拉框选项构建: 与书按钮完全同源(MultiBot.talentData), 中文显示+英文 key 附注
-- FIX(2026-11-16 十三轮): 双钩选修复——钩选改为跟随"待确认选择"selKey(打开时初始化为
-- 已保存变量), 并在两处显式管理钩选, 不依赖 3.3.5 引擎 UIDropDownMenu 的自动行为:
--   ① 初始化时先清掉本层所有按钮的旧钩选(引擎复用按钮帧, 残留钩选不会被自动清除);
--   ② 点选某项时只钩该项、显式清掉同层其它项(旧版依赖 SetSelectedValue, 旧钩选残留
--      导致"保存后再选另一个 → 两个都钩上")。
local function dropDownInit(self, pLevel)
	if(tPopup == nil) then return end
	local tList = talentListOf(tPopup.botClass)
	if(tList == nil) then return end
	local tLevel = pLevel or 1
	local tLF = _G["DropDownList" .. tLevel]
	if(tLF ~= nil) then
		for i = 1, (UIDROPDOWNMENU_MAXBUTTONS or 0) do
			local tBtn = _G["DropDownList" .. tLevel .. "Button" .. i]
			if(tBtn ~= nil and tBtn.Uncheck ~= nil) then tBtn:Uncheck() end
		end
	end
	local tSel = tPopup.selKey
	for _, t in ipairs(tList) do
		local tKey = MANUAL_SPEC_MAP[t[1]] or t[1]
		local tInfo = UIDropDownMenu_CreateInfo()
		local tLabel = t[2] .. "  |cff888888(" .. t[1] .. ")|r"
		if(not MANUAL_SPEC_KNOWN[tKey]) then
			tLabel = tLabel .. MultiBot.T(" |cffff8888[无出厂默认表]|r")
		end
		tInfo.text = tLabel
		tInfo.value = t[1]
		tInfo.checked = (tSel == t[1])
		tInfo.func = function(pSelf)
			tPopup.selKey = t[1]
			UIDropDownMenu_SetText(tPopup.drop, t[2])
			-- 显式单选: 只钩当前项, 清掉同层其它钩选
			local tParent = pSelf ~= nil and pSelf:GetParent() or nil
			if(tParent ~= nil and tParent.GetName ~= nil) then
				for i = 1, (tParent.numButtons or 0) do
					local tBtn = _G[tParent:GetName() .. "Button" .. i]
					if(tBtn ~= nil) then
						if(tBtn.value == t[1]) then tBtn:Check() else tBtn:Uncheck() end
					end
				end
			end
		end
		UIDropDownMenu_AddButton(tInfo, pLevel)
	end
end

local function uiRefresh()
	if(tPopup == nil or not tPopup:IsShown()) then return end
	local tName, tClass = tPopup.botName, tPopup.botClass
	local tCNClass = MultiBot.talentClassNameCN
		and MultiBot.talentClassNameCN[tClass == "DeathKnight" and "Death Knight" or tClass] or tClass
	tPopup.header:SetText(MultiBot.TF("天赋变量 - %s (%s)", tName or "?", tCNClass or "?"))
	local tTalent = MultiBot.TalentCache ~= nil and MultiBot.TalentCache[tName] or nil
	local tCurKey = tTalent ~= nil and tTalent.spec or nil
	-- 三十一轮: 旧存档的 emo/doubleaurablood 归一成新 key 再反查/显示(不改存档值)
	if(tCurKey ~= nil and LEGACY_SPEC_ALIAS[tCurKey] ~= nil) then tCurKey = LEGACY_SPEC_ALIAS[tCurKey] end
	if(tCurKey ~= nil) then
		local tCN = specCN(tClass, tCurKey)
		tPopup.current:SetText(MultiBot.TF("|cff00ff44当前变量: %s%s|r", (tCN ~= nil and (tCN .. " / ") or ""), tCurKey))
	else
		tPopup.current:SetText(MultiBot.T("|cffff6060未设置(该机器人不打绿点)|r"))
	end
	-- 每次打开按当前机器人职业重建下拉选项(换机器人/换职业都正确)
	tPopup.selKey = nil
	UIDropDownMenu_Initialize(tPopup.drop, dropDownInit)
	UIDropDownMenu_SetWidth(tPopup.drop, 210)
	local tList = talentListOf(tClass)
	local tFound = nil
	if(tList ~= nil and tCurKey ~= nil) then
		for _, t in ipairs(tList) do if(t[1] == tCurKey) then tFound = t break end end
		if(tFound == nil) then
			for _, t in ipairs(tList) do
				if((MANUAL_SPEC_MAP[t[1]] or t[1]) == tCurKey) then tFound = t break end
			end
		end
	end
	if(tFound ~= nil) then
		tPopup.selKey = tFound[1]
		-- 十三轮: 不再调 SetSelectedValue(钩选由 dropDownInit/func 显式管理, 见上)
		UIDropDownMenu_SetText(tPopup.drop, tFound[2])
	elseif(tList == nil) then
		UIDropDownMenu_SetText(tPopup.drop, MultiBot.T("未知职业"))
	else
		UIDropDownMenu_SetText(tPopup.drop, MultiBot.T("请选择天赋"))
	end
end

function MultiBot.TalentSpecUIOpen(pName, pClass)
	if(tPopup == nil) then
		tPopup = CreateFrame("Frame", "MB_TalentSpecPopup", UIParent)
		tPopup:SetSize(320, 180)
		tPopup:SetPoint("CENTER", 0, 120)
		tPopup:SetFrameStrata("DIALOG")
		tPopup:SetMovable(true)
		tPopup:EnableMouse(true)
		tPopup:RegisterForDrag("LeftButton")
		tPopup:SetScript("OnDragStart", tPopup.StartMoving)
		tPopup:SetScript("OnDragStop", tPopup.StopMovingOrSizing)
		tPopup:SetBackdrop({
			bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
			tile     = true, tileSize = 32, edgeSize = 16,
			insets   = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		tPopup:SetScript("OnKeyDown", function(self, pKey)
			if(pKey == "ESCAPE") then self:Hide() end
		end)
		tPopup:EnableKeyboard(true)

		tPopup.header = tPopup:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		tPopup.header:SetPoint("TOP", 0, -12)

		tPopup.current = tPopup:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		tPopup.current:SetPoint("TOP", 0, -38)

		-- 下拉框(替代旧手填输入框): 选项与书按钮天赋表同源
		tPopup.drop = CreateFrame("Frame", "MB_TalentSpecDropDown", tPopup, "UIDropDownMenuTemplate")
		tPopup.drop:SetPoint("TOP", 0, -60)

		local tTip = tPopup:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		tTip:SetPoint("TOP", 0, -102)
		tTip:SetWidth(290)
		tTip:SetJustifyH("CENTER")
		tTip:SetTextColor(0.6, 0.75, 0.6)
		tTip:SetText(MultiBot.T("选项与书按钮天赋列表一致。变量来源: 手动录入 / 书按钮确认切换。|n绿点只标当前变量对应档位的出厂默认策略。"))

		-- 设置(确认) --
		tPopup.confirm = CreateFrame("Button", nil, tPopup, "UIPanelButtonTemplate")
		tPopup.confirm:SetSize(80, 24)
		tPopup.confirm:SetPoint("BOTTOMLEFT", 24, 18)
		tPopup.confirm:SetText(MultiBot.T("设置"))
		tPopup.confirm:SetScript("OnClick", function()
			local tInput = tPopup.selKey
			if(tInput == nil or tInput == "") then
				print(MultiBot.T("|cffff6060[MultiBot]|r 请先在下拉框中选择天赋。"))
				return
			end
			if(MultiBot.TalentCacheSetManual(tPopup.botName, tInput)) then
				local tSpec = MultiBot.TalentCache[tPopup.botName].spec
				local tCN = specCN(tPopup.botClass, tSpec)
				print(MultiBot.TF("|cff00ff44[MultiBot]|r %s 天赋变量已设置: %s%s(绿点已重标, 登出自动保存)。",
					tPopup.botName, (tCN ~= nil and (tCN .. " / ") or ""), tSpec))
				-- FIX(2026-11-16 十二轮): 设置成功即关窗——旧弹窗滞留会拦截下一次
				-- Ctrl+点击(DIALOG 层级+鼠标拦截), 表现为"点别的机器人还弹上一个的框"
				tPopup:Hide()
			else
				print(MultiBot.TF("|cffffaa00[MultiBot]|r %s 无服务端出厂默认策略表, 不写入变量(该档位绿点不显示)。", tInput))
			end
		end)

		-- 清除 --
		tPopup.clear = CreateFrame("Button", nil, tPopup, "UIPanelButtonTemplate")
		tPopup.clear:SetSize(80, 24)
		tPopup.clear:SetPoint("BOTTOMLEFT", 120, 18)
		tPopup.clear:SetText(MultiBot.T("清除"))
		tPopup.clear:SetScript("OnClick", function()
			MultiBot.TalentCacheClear(tPopup.botName)
			print(MultiBot.TF("|cffffaa00[MultiBot]|r %s 天赋变量已清除(绿点不显示, 直至重新录入/书按钮切换)。", tPopup.botName))
			tPopup:Hide() -- 同上: 清除后也关窗, 避免滞留拦截后续点击
		end)

		-- 关闭 --
		local tClose = CreateFrame("Button", nil, tPopup, "UIPanelButtonTemplate")
		tClose:SetSize(80, 24)
		tClose:SetPoint("BOTTOMRIGHT", -24, 18)
		tClose:SetText(MultiBot.T("关闭"))
		tClose:SetScript("OnClick", function() tPopup:Hide() end)

		local tX = CreateFrame("Button", nil, tPopup, "UIPanelCloseButton")
		tX:SetPoint("TOPRIGHT", -2, -2)
		tX:SetScript("OnClick", function() tPopup:Hide() end)
	end

	tPopup.botName = pName
	tPopup.botClass = pClass
	tPopup:Show()
	uiRefresh()
end
