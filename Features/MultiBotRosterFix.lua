
-- ============================================================
--  MultiBot RosterFix.lua
--  FIX(2026-11-12): 机器人图标"问号"自愈
--
--  现象: 队伍中的机器人, 图标行有时停留在 class_unknown(问号),
--        tooltip 刷不出人物信息; 把机器人下线重招才恢复。
--  根因: 图标职业信息只依赖服务端发来的 roster 消息("Bot roster: ..."),
--        消息丢失/乱序/解析失败后没有任何补正机制, Unknown 状态永久残留。
--  修复: 客户端定期用队伍名单对账 —— UnitClass(unit) 是客户端本地的
--        权威数据, 不依赖任何服务器消息; 对 class 为 Unknown 的机器人
--        图标自动补正(图标/tooltip/索引), 无需重招。
--        机器人不在队伍中时保持原样(不猜职业)。
-- ============================================================

local MultiBot = _G["MultiBot"] or {}
_G["MultiBot"] = MultiBot

if MultiBot._rosterFixLoaded then return end
MultiBot._rosterFixLoaded = true

-- 按名字找队伍/团队中的 unit token
local function FindUnitByName(pName)
    if pName == nil or pName == "" then return nil end
    if UnitIsUnit("player", pName) or UnitName("player") == pName then return "player" end
    local n = GetNumPartyMembers()
    for i = 1, n do
        if UnitName("party" .. i) == pName then return "party" .. i end
    end
    local r = GetNumRaidMembers()
    for i = 1, r do
        if UnitName("raid" .. i) == pName then return "raid" .. i end
    end
    return nil
end

-- 对账: 把 Units 行里 class==Unknown 且在队伍中的机器人图标补正
local function ReconcileBotIcons()
    if not MultiBot.frames then return end
    local multiBar = MultiBot.frames["MultiBar"]
    if not multiBar or not multiBar.frames then return end
    local units = multiBar.frames["Units"]
    if not units or not units.buttons then return end

    for name, btn in pairs(units.buttons) do
        if type(name) == "string" and type(btn) == "table"
            and btn.roster == "players"
            and (btn.class == nil or btn.class == "Unknown") then

            local unit = FindUnitByName(name)
            if unit and UnitIsPlayer(unit) then
                local _, rawClass = UnitClass(unit)
                local cls = MultiBot.toClass and MultiBot.toClass(rawClass) or rawClass
                if cls and cls ~= "Unknown" then
                    -- addPlayer 的更新路径: 已存在的按钮只刷图标/索引/class
                    MultiBot.addPlayer(cls, name)
                    -- 补刷新 tooltip(更新路径不含 tip)
                    local level = UnitLevel(unit)
                    if btn.tip ~= nil and MultiBot.toTip then
                        btn.tip = MultiBot.toTip(cls, level, name)
                        btn.level = level -- 十六轮: 供天赋变量变更后重建 tooltip(等级不丢)
                    end
                end
            end
        end
    end
end

MultiBot.ReconcileBotIcons = ReconcileBotIcons

-- 定期对账(4秒) + 入队事件即时对账(延迟1秒等名单稳定)
do
    local beat = CreateFrame("Frame", nil, UIParent)
    beat.elapsed = 0
    beat:SetScript("OnUpdate", function(self, dt)
        self.elapsed = self.elapsed + dt
        if self.elapsed >= 4 then
            self.elapsed = 0
            ReconcileBotIcons()
        end
    end)

    local evt = CreateFrame("Frame")
    evt:RegisterEvent("GROUP_ROSTER_UPDATE")
    evt:RegisterEvent("PLAYER_ENTERING_WORLD")
    evt:SetScript("OnEvent", function()
        if TimerAfter then
            TimerAfter(1, ReconcileBotIcons)
        else
            ReconcileBotIcons()
        end
    end)
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00MultiBot 机器人图标自愈模块已加载 (问号图标将自动补正)。|r")
