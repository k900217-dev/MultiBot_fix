--------------------------------------------------------------------------------
-- MultiBotStrategyLog (2026-11-12)
-- 策略通信日志: 记录插件 <-> 机器人之间所有"策略相关"的 whisper 往返,
-- 用于核对服务端真实策略栈(co ? / nc ? 应答)与指令是否生效。
--
-- 记录内容:
--   ▶ 发送  插件发出的策略指令(co +xxx / nc +xxx / co ? / nc ?)与查询重试
--   ◀ 接收  机器人回信 "Strategies: ..." —— 服务端真实策略栈(权威数据)
--   ⓘ 状态  查询超时等异常(机器人未上线/应答丢失)
--
-- 服务端权威对照:
--   机器人对 "co ?" 的应答由服务端 Engine::ListStrategies() 生成,
--   内容就是服务端策略栈本身, 比本地点击状态(乐观切换)可靠。
--   服务器侧另有全量流水: logs\Playerbots.log 中 "bot名 S:+策略 / S:-策略"
--   (Engine::LogAction), 可用 tools\strategy_log_report.py 离线重放。
--
-- 使用: /mblog 打开/关闭日志面板(鼠标滚轮滚动, 可拖动)。
--------------------------------------------------------------------------------

MultiBot.commlog = MultiBot.commlog or {}
MultiBot.commlog.entries = MultiBot.commlog.entries or {}
MultiBot.commlog.max = 400

-- 调试模式开关(默认关闭 = 原来的模式, 零记录零开销):
-- 勾选(插件设置面板"策略通信日志")才进入记录模式; 不勾选时所有挂钩直接旁路,
-- 行为与本功能加入之前完全一致。开关状态持久化在 MultiBotSave["CommLogEnabled"]。
MultiBot.CommLogEnabled = false

function MultiBot.SetCommLogEnabled(pFlag)
	MultiBot.CommLogEnabled = (pFlag == true)
	if(type(MultiBotSave) == "table") then
		MultiBotSave["CommLogEnabled"] = MultiBot.IF(MultiBot.CommLogEnabled, "true", "false")
	end
	if(MultiBot.CommLogEnabled) then
		-- 开启: 恢复上次保存的历史(内存为空时); 若面板已建则销毁, 下次 /mblog 重建并回放全部历史
		MultiBot.LoadCommLog()
		if(_panel ~= nil) then _panel:Hide() end
		_panel = nil
		_smf = nil
		print("|cff00ff00[MultiBot]|r 策略通信日志: 调试记录模式已开启(输入 /mblog 查看面板)。")
	else
		-- 关闭: 清空内存记录, 回到"原来的模式"
		MultiBot.commlog.entries = {}
		if(_smf ~= nil) then _smf:Clear() end
		print("|cff00ff00[MultiBot]|r 策略通信日志: 已关闭, 恢复默认模式。")
	end
end

-- 登录时恢复开关状态(ADDON_LOADED 阶段调用)
function MultiBot.RestoreCommLogSetting()
	if(type(MultiBotSave) == "table" and MultiBotSave["CommLogEnabled"] == "true") then
		MultiBot.CommLogEnabled = true
		MultiBot.LoadCommLog()
	end
end

local _panel = nil
local _smf = nil
local _paused = false

local COLOR = {
	send = "|cffffd200", -- 黄: 发送
	recv = "|cff60ff60", -- 绿: 接收(服务端真值)
	info = "|cff808080", -- 灰: 状态/异常
	reset = "|r",
}

-- 判定 whisper 指令是否属于"策略类"(co/nc/de 开头, 含查询与切换)
function MultiBot.IsStrategyCommand(pAction)
	if(type(pAction) ~= "string") then return false end
	local tType = string.match(pAction, "^(%a+)%s") or (string.match(pAction, "^(%a+)$"))
	return tType == "co" or tType == "nc" or tType == "de"
end

-- 核心记录入口
-- pDir: "send" | "recv" | "info"
function MultiBot.AddCommLog(pDir, pName, pText)
	-- 双保险: 未开启调试模式时本函数是绝对空操作(即使调用方漏检开关也不会记录)
	if(not MultiBot.CommLogEnabled or MultiBot.commlog == nil) then return end
	local tColor = COLOR[pDir] or COLOR.info
	local tStamp = date("%m-%d %H:%M:%S")
	local tEntry = { time = tStamp, dir = pDir, name = tostring(pName or "?"), text = tostring(pText or "") }
	table.insert(MultiBot.commlog.entries, tEntry)
	-- 环形上限: 超限移除最旧
	while(#MultiBot.commlog.entries > MultiBot.commlog.max) do table.remove(MultiBot.commlog.entries, 1) end

	if(_smf ~= nil and not _paused) then
		local tArrow = MultiBot.IF(pDir == "send", "▶", MultiBot.IF(pDir == "recv", "◀", "ⓘ"))
		_smf:AddMessage("|cff66ccff[" .. tStamp .. "]|r " .. tColor .. tArrow .. " " .. tEntry.name .. "|r: " .. tEntry.text)
	end
end

-- 面板构建(Core\MultiBotInit.lua 之后加载, 此时 MultiBot 主框架已就绪)
local function buildPanel()
	if(_panel ~= nil) then return end

	_panel = MultiBot.newFrame(MultiBot, -700, -560, 32, 442, 520)
	_panel:SetMovable(true)
	_panel:Hide()

	-- 背景底板(放在挡板之上不可行, 直接用贴图分层: BACKGROUND)
	local tBg = _panel:CreateTexture(nil, "BACKGROUND")
	tBg:SetAllPoints(_panel)
	tBg:SetTexture("Interface\\AddOns\\MultiBot\\Textures\\Black.blp")
	tBg:SetAlpha(0.92)

	_panel.addText("Title", "策略通信日志 (Strategy Comm Log)", "CENTER", -140, 498, 12)
	_panel.movButton("Move", -406, 492, 34)

	_panel.wowButton("X", -30, 492, 15, 18, 13)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(_panel)
	end

	_panel.wowButton("清空", -120, 494, 42, 18, 11)
	.doLeft = function(pButton)
		MultiBot.commlog.entries = {}
		if(_smf ~= nil) then _smf:Clear() end
	end

	_panel.wowButton("暂停", -170, 494, 42, 18, 11)
	.doLeft = function(pButton)
		_paused = not _paused
		pButton.text:SetText("|cffffcc00" .. MultiBot.IF(_paused, "继续", "暂停") .. "|r")
	end

	-- 滚动日志区(创建于挡板/按钮之后 => 帧层级更高, 保证滚轮可达)
	_smf = CreateFrame("ScrollingMessageFrame", nil, _panel)
	_smf:SetPoint("BOTTOMRIGHT", -20, 8)
	_smf:SetSize(405, 470)
	_smf:SetInsertMode("TOP")
	_smf:SetFading(false)
	_smf:SetMaxLines(500)
	_smf:SetFontObject("ChatFontNormal")
	_smf:EnableMouseWheel(true)
	_smf:SetScript("OnMouseWheel", function(self, pDelta)
		if(pDelta > 0) then self:ScrollUp() else self:ScrollDown() end
	end)

	-- 回放历史(重建面板时)
	local tEntries = MultiBot.commlog.entries
	for i = #tEntries, 1, -1 do
		local tEntry = tEntries[i]
		local tColor = COLOR[tEntry.dir] or COLOR.info
		local tArrow = MultiBot.IF(tEntry.dir == "send", "▶", MultiBot.IF(tEntry.dir == "recv", "◀", "ⓘ"))
		_smf:AddMessage("|cff66ccff[" .. tEntry.time .. "]|r " .. tColor .. tArrow .. " " .. tEntry.name .. "|r: " .. tEntry.text)
	end
end

-- 斜杠命令: /mblog [save|clear]
-- save: 立即把日志写入 SavedVariables(测试后务必执行, /reload 不触发退出保存)
-- clear: 清空内存日志(不删除已保存的)
SLASH_MULTIBOTLOG1 = "/mblog"
SlashCmdList["MULTIBOTLOG"] = function(pMsg)
	pMsg = string.gsub(pMsg or "", "^%s+", "")
	pMsg = string.gsub(pMsg, "%s+$", "")
	if(pMsg == "save") then
		if(not MultiBot.CommLogEnabled) then
			print("|cffff6060[MultiBot]|r 调试记录模式未开启——请在 插件设置(MultiBot) 中勾选\"策略通信日志\"。")
			return
		end
		MultiBot.SaveCommLog()
		print("|cff00ff00[MultiBot]|r 策略通信日志已保存(" .. #MultiBot.commlog.entries .. " 条)——退出游戏后数据保留, 可供离线分析。")
		return
	end
	if(_panel == nil) then buildPanel() end
	if(pMsg == "clear") then
		MultiBot.commlog.entries = {}
		if(_smf ~= nil) then _smf:Clear() end
		print("|cff00ff00[MultiBot]|r 内存日志已清空(已保存的历史仍在存档文件中)。")
		return
	end
	-- mark: 插入切割标记——标记之后产生的记录才属于"正式测试"
	if(string.match(pMsg, "^mark")) then
		if(not MultiBot.CommLogEnabled) then
			print("|cffff6060[MultiBot]|r 调试记录模式未开启——请先在 插件设置(/mbopt → MultiBot) 中勾选\"策略通信日志\"。")
			return
		end
		local tNote = string.match(pMsg, "^mark%s+(.+)$") or "标记"
		MultiBot.AddCommLog("info", "════", "切割标记: " .. tNote .. " ════")
		print("|cff00ff00[MultiBot]|r 已插入切割标记(" .. tNote .. ")——之后产生的记录属于本轮正式测试。")
		return
	end
	-- 未开启调试模式: 面板打开但显示提示, 不记录任何内容
	if(not MultiBot.CommLogEnabled and _smf ~= nil and _smf:GetNumMessages() == 0) then
		_smf:AddMessage("|cff808080调试记录模式未开启——在 插件设置(/mbopt → MultiBot) 中勾选\"策略通信日志\"后开始记录。|r")
	end
	MultiBot.ShowHideSwitch(_panel)
end

-- 持久化: 保存/恢复(SavedVariablesPerCharacter = MultiBotSave)
-- 目的: 测试产生的日志不能只存在内存(/reload 与断线都会丢),
--       保存后位于 WTF\Account\<账号>\<服务器>\<角色>\SavedVariables\MultiBot.lua,
--       离线分析直接读该文件即可。
function MultiBot.SaveCommLog()
	if(type(MultiBotSave) ~= "table") then return end
	local tKeep = {}
	local tFrom = math.max(1, #MultiBot.commlog.entries - 299)
	for i = tFrom, #MultiBot.commlog.entries do
		local tEntry = MultiBot.commlog.entries[i]
		table.insert(tKeep, { tEntry.time, tEntry.dir, tEntry.name, tEntry.text })
	end
	MultiBotSave["CommLog"] = tKeep
end

function MultiBot.LoadCommLog()
	if(not MultiBot.CommLogEnabled) then return end -- 仅调试模式生效
	if(type(MultiBotSave) ~= "table" or type(MultiBotSave["CommLog"]) ~= "table") then return end
	-- 只在当前内存为空时恢复, 避免重复叠加
	if(#MultiBot.commlog.entries > 0) then return end
	for _, tRow in ipairs(MultiBotSave["CommLog"]) do
		if(type(tRow) == "table" and #tRow >= 4) then
			table.insert(MultiBot.commlog.entries, {
				time = tostring(tRow[1]), dir = tostring(tRow[2]),
				name = tostring(tRow[3]), text = tostring(tRow[4]),
			})
		end
	end
end
