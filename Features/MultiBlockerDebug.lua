-- MultiBlockerDebug.lua — 点击拦截诊断工具 (FIX 2026-09-20, 升级 2026-11-08)
-- 背景: "子菜单收起后区域仍不能操控游戏" 经两轮修复仍有残留, 盲猜效率太低。
-- 本工具让游戏自己指出: 鼠标下的点击到底被谁吃掉了。
--
-- 用法:
--   /mbblocker         切换"悬停诊断"模式: 把鼠标移到点不动的区域,
--                      拦截帧会被红色高亮, 聊天框打印它的详情(截图发回即可定位)
--   /mbblocker list    一次性列出当前所有"可见且接收鼠标"的大块头框架(带坐标尺寸)
--   /mbblocker kill    强制隐藏全部 blocker (配合 Engine._blockersDisabled)
--   /mbblocker restore 恢复 blocker
--   /mbblocker         再输入一次关闭诊断
--
-- 升级 2026-11-08:
--   * MultiBot 框架全部是匿名帧(名字不含 MB_/MultiBot), 旧版按名字识别会把
--     本插件的挡板误报成"[其他插件拦截]"。现改为结构识别:
--     newFrame 对象带有 .buttons/.frames/.clickBlocker 字段, 链上任一命中即为本插件。
--   * 挡板帧会进一步报告归属(注册表路径, 如 MultiBar.frames.Right)与按钮审计,
--     直接解释挡板为什么是这个尺寸。
--   * 修复地址提取(3.3.5 tostring 无 0x 前缀), 两条消息可通过地址比对是否同一帧。
--
-- 原理: GetMouseFocus() 返回当前吃掉鼠标事件的最高优先级帧;
--       若它返回 WorldFrame 则该处点击没有被任何 UI 拦截。

local enabled    = false
local hoverFrame -- OnUpdate ticker
local marker     -- 红色高亮框
local lastFrame  -- 节流: 同一帧只报一次

-- 取帧地址(3.3.5 tostring 形如 "Frame: 1A2B3C4D", 无 0x 前缀)
local function FrameAddr(f)
	local s = tostring(f)
	return s:match("0x(%x+)") or s:match(": (%x+)") or s:match("(%x%x%x%x+)") or "?"
end

-- 结构识别: newFrame 创建的对象带 .buttons/.frames/.clickBlocker 特征字段;
-- 根对象即全局 MultiBot 框架本身。
local function IsMBStruct(f)
	if f == MultiBot then return true end
	if type(f) == "table" and type(f.buttons) == "table" and type(f.frames) == "table" then return true end
	return false
end

-- 沿父链找 MB 结构特征
local function IsMultiBotFrame(f)
	local cur, depth = f, 0
	while cur and depth < 14 do
		if IsMBStruct(cur) then return true, depth end
		cur = cur.GetParent and cur:GetParent() or nil
		depth = depth + 1
	end
	return false, nil
end

local function FramePath(f)
	local parts, cur, depth = {}, f, 0
	while cur and depth < 14 do
		local n = cur.GetName and cur:GetName() or nil
		local mark = IsMBStruct(cur) and "·MB" or ""
		if n then
			parts[#parts + 1] = n .. "(" .. FrameAddr(cur) .. ")" .. mark
		else
			parts[#parts + 1] = "anon[" .. FrameAddr(cur) .. "]" .. mark
		end
		cur = cur.GetParent and cur:GetParent() or nil
		depth = depth + 1
	end
	return table.concat(parts, " <- ")
end

-- 在 MultiBot.frames 注册表里按对象身份查找, 返回点分路径(如 MultiBar.frames.Right)
local function ResolveMBPath(f)
	if not MultiBot or not MultiBot.frames then return nil end
	if f == MultiBot then return "MultiBot(根)" end
	local function walk(node, path, depth)
		if depth > 8 or type(node) ~= "table" then return nil end
		if node == f then return path end
		if type(node.frames) == "table" then
			for name, sf in pairs(node.frames) do
				if type(sf) == "table" then
					local r = walk(sf, path .. "." .. name, depth + 1)
					if r then return r end
				end
			end
		end
		return nil
	end
	for name, fr in pairs(MultiBot.frames) do
		if type(fr) == "table" then
			local r = walk(fr, name, 1)
			if r then return r end
		end
	end
	return nil
end

-- 挡板审计: 报告归属 owner、可见按钮数与包围盒, 解释挡板尺寸的来源
local function AuditBlocker(cb)
	local owner = cb.GetParent and cb:GetParent() or nil
	if not owner then return "" end
	local path = ResolveMBPath(owner) or ("anon[" .. FrameAddr(owner) .. "]")
	local count, minL, maxR, minB, maxT, topBtn = 0
	if type(owner.buttons) == "table" then
		for _, b in pairs(owner.buttons) do
			if b and b.IsShown and b:IsShown() and b.GetLeft then
				local l, r, bt, tp = b:GetLeft(), b:GetRight(), b:GetBottom(), b:GetTop()
				if l and r and bt and tp then
					count = count + 1
					if not minL or l < minL then minL = l end
					if not maxR or r > maxR then maxR = r end
					if not minB or bt < minB then minB = bt end
					if not maxT or tp > maxT then
						maxT = tp
						topBtn = b
					end
				end
			end
		end
	end
	if count == 0 then
		return ("归属=%s | 该owner没有可见按钮, 挡板应为隐藏状态(若未隐藏即异常)"):format(path)
	end
	local w = maxR - minL
	local h = maxT - minB
	local topName = topBtn and topBtn.name or "?"
	local topPath = ""
	if topBtn and topBtn.GetParent and ResolveMBPath(topBtn:GetParent()) then
		topPath = " (位于 " .. ResolveMBPath(topBtn:GetParent()) .. ")"
	end
	return ("归属=%s | 可见按钮%d个, 包围盒%dx%d | 最高按钮=%s%s"):format(
		path, count, w, h, topName, topPath)
end

local function EnsureMarker()
	if marker then return marker end
	marker = CreateFrame("Frame", "MB_BlockerMarker", UIParent)
	marker:SetFrameStrata("TOOLTIP")
	marker:EnableMouse(false) -- 自绝于鼠标, 绝不当拦截者
	marker:SetMovable(false)
	local tex = marker:CreateTexture(nil, "BACKGROUND")
	tex:SetAllPoints(marker)
	tex:SetTexture("Interface\\Buttons\\WHITE8X8")
	tex:SetVertexColor(1, 0, 0, 0.30) -- 红色半透明填充
	local border = CreateFrame("Frame", nil, marker)
	border:SetAllPoints(marker)
	border:EnableMouse(false)
	border:SetBackdrop({
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		edgeSize = 12,
		insets   = { left = 0, right = 0, top = 0, bottom = 0 },
	})
	return marker
end

local function StartHover()
	if hoverFrame then return hoverFrame end
	hoverFrame = CreateFrame("Frame", "MB_BlockerHover", UIParent)
	hoverFrame:SetScript("OnUpdate", function()
		if not enabled then return end
		EnsureMarker()
		local f = GetMouseFocus()
		if not f or f == WorldFrame then
			marker:Hide()
			lastFrame = nil
			return
		end
		if f ~= lastFrame then
			lastFrame = f
			marker:ClearAllPoints()
			marker:SetAllPoints(f)
			marker:Show()
			local w = f:GetWidth() or 0
			local h = f:GetHeight() or 0
			local isMB = IsMultiBotFrame(f)
			-- 挡板判定: 它是父框架注册的 clickBlocker
			local parent = f.GetParent and f:GetParent() or nil
			local isCB = parent and parent.clickBlocker == f
			local strata = f.GetFrameStrata and f:GetFrameStrata() or "?"
			local tag
			if isMB and isCB then
				tag = "|cffff5555[MultiBot透明挡板]|r"
			elseif isMB then
				tag = "|cffff5555[MultiBot框架]|r"
			else
				tag = "|cff5599ff[非MultiBot]|r"
			end
			DEFAULT_CHAT_FRAME:AddMessage(("%s %s %dx%d strata=%s"):format(
				tag, f.GetFrameType and f:GetFrameType() or "?", w, h, strata))
			DEFAULT_CHAT_FRAME:AddMessage("  链: " .. FramePath(f))
			if isCB then
				DEFAULT_CHAT_FRAME:AddMessage("  " .. AuditBlocker(f))
			end
			if not isMB then
				DEFAULT_CHAT_FRAME:AddMessage("  (结构检查未发现 MultiBot 特征 — 可能真是其他插件, 请截图回传)")
			end
		end
	end)
	return hoverFrame
end

-- 一次性列出所有可见且接收鼠标的"大块头"(排除按钮/小控件, 避免刷屏)
local function ListMouseFrames()
	local out = {}
	local function walk(f, depth)
		if depth > 8 then return end
		local children = { f:GetChildren() }
		for _, c in ipairs(children) do
			if type(c) == "table" and c.IsVisible and c:IsVisible()
				and c.IsMouseEnabled and c:IsMouseEnabled() then
				local w = c.GetWidth and c:GetWidth() or 0
				local h = c.GetHeight and c:GetHeight() or 0
				local isBtn = c.IsObjectType and c:IsObjectType("Button")
				-- 大于 48x48 且不是按钮 -> 嫌疑"隐形挡板"
				if not isBtn and (w > 48 or h > 48) then
					local isMB = IsMultiBotFrame(c)
					local parentCB = c.GetParent and c:GetParent() or nil
					local isCB = parentCB and parentCB.clickBlocker == c
					local path = (parentCB and ResolveMBPath(parentCB)) or FrameAddr(c)
					local name = (c.GetName and c:GetName()) or ("anon[" .. FrameAddr(c) .. "]")
					local l = c.GetLeft and c:GetLeft() or -1
					local b = c.GetBottom and c:GetBottom() or -1
					local tag = isMB and "|cffff5555[MB]|r" or "|cff5599ff[??]|r"
					out[#out + 1] = ("%s %s %s %dx%d @(%d,%d)%s"):format(
						tag, c:GetFrameType(), name, w, h, l, b,
						isCB and (" <-挡板,归属=" .. path) or "")
				end
			end
			if c.GetChildren then walk(c, depth + 1) end
		end
	end
	walk(UIParent, 0)

	DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00=== 可见且接收鼠标的大框架 (共 " .. #out .. " 个) ===|r")
	for i, line in ipairs(out) do
		if i <= 40 then
			DEFAULT_CHAT_FRAME:AddMessage(line)
		end
	end
	if #out > 40 then
		DEFAULT_CHAT_FRAME:AddMessage(("... 其余 %d 条省略"):format(#out - 40))
	end
	if #out == 0 then
		DEFAULT_CHAT_FRAME:AddMessage("没有发现 >48px 的鼠标接收框架 — 拦截者可能是小控件或按钮, 请用悬停模式定位。")
	end
end

-- 快速二分: kill = 强制隐藏所有 blocker(配合 Engine._blockersDisabled 总开关);
-- restore = 恢复。kill 后若"点不动"的区域全部恢复可点 -> 问题就在 blocker 体系;
-- 若仍有区域点不动 -> 拦截者另有其人, 用悬停模式指认。
local function KillAllBlockers()
	MultiBot._blockersDisabled = true
	MultiBot.RefreshAllClickBlockers()
	DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MB诊断]|r 已强制隐藏全部 blocker。现在去测试: 若区域可点 = blocker 系问题; 仍点不动 = 其他拦截, 用 /mbblocker 悬停指认。")
end

local function RestoreAllBlockers()
	MultiBot._blockersDisabled = nil
	MultiBot.RefreshAllClickBlockers()
	DEFAULT_CHAT_FRAME:AddMessage("|cffff5555[MB诊断]|r blocker 已恢复。")
end

SLASH_MBBLOCKER1 = "/mbblocker"
SLASH_MBBLOCKER2 = "/mbblockerdebug"
SlashCmdList["MBBLOCKER"] = function(msg)
	msg = (msg or ""):lower():gsub("^%s+", ""):gsub("%s+$", "")
	if msg == "list" then
		ListMouseFrames()
		return
	end
	if msg == "kill" then
		KillAllBlockers()
		return
	end
	if msg == "restore" then
		RestoreAllBlockers()
		return
	end
	enabled = not enabled
	if enabled then
		StartHover()
		if hoverFrame then hoverFrame:Show() end
		DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[MB诊断]|r 悬停模式已开启: 鼠标移到点不动的区域, 红框=拦截者, 详情打印在聊天框。/mbblocker 关闭, /mbblocker list 列出全部, /mbblocker kill 临时关全部挡板。")
	else
		if hoverFrame then hoverFrame:Hide() end
		if marker then marker:Hide() end
		lastFrame = nil
		DEFAULT_CHAT_FRAME:AddMessage("|cffffcc00[MB诊断]|r 悬停模式已关闭。")
	end
end
