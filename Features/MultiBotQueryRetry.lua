--------------------------------------------------------------------------------
-- MultiBotQueryRetry
-- FIX(2026-11-12): 机器人信息按钮"不是每次都显示信息"的根因修复。
-- 机制: 点击信息按钮后插件发 whisper "co ?" -> 机器人回 "Strategies: ..." -> 发 "nc ?"
--       -> 回非战斗策略 -> 渲染面板。
-- 机器人刚被邀请、还在 mod-playerbots 登录队列中未完成上线时, 发给它的 whisper
-- 会被服务端静默丢弃(玩家对象尚未进入世界), 整条查询链无声卡死,
-- 表现为"必须下线再上线一两次才显示信息"。
-- 本模块对所有 co ?/nc ? 查询武装自动重试(2.5 秒间隔, 最多 3 次),
-- 收到对应响应即解除; 超限后在聊天区提示, 不再无声失败。
--------------------------------------------------------------------------------

local MAX_ATTEMPTS = 3
local RETRY_DELAY = 2.5
local MAX_ROUNDS = 2 -- 超时自动补查轮数(1=原行为, 2=补查一轮后才终审还原)
local ROUND_PAUSE = 4 -- 补查轮之前的间隔秒数
local MAX_ACTIVE_CHAINS = 3 -- 全局同时在途查询链上限, 超出的新链自动顺延

-- FIX(2026-11-15 十轮): 重试/顺延计时改走 MultiBot.ScheduleAfter(常驻 OnUpdate 调度帧)。
-- 根因见 Engine.lua ScheduleAfter 注释: TimerAfter 底层 !!!ClassicAPI C_Timer.After 的
-- 动画池回调 11-15 10:42 后全体静默失效——查询重试、超时还原、顺延循环全部哑火,
-- 切换后延迟刷新也就永远发不出("关不掉/开着不亮只能手动右键")。不可用时回落 TimerAfter。
local function After(pDelay, pFn)
	if(MultiBot.ScheduleAfter ~= nil) then return MultiBot.ScheduleAfter(pDelay, pFn) end
	if(type(TimerAfter) == "function") then return TimerAfter(pDelay, pFn) end
end
-- FIX(2026-11-16 十二轮): 重试/补查补发前重设 waitFor。
-- 根因: waitFor 可能被非策略流量劫持(背包开着时机器人"吃/喝/装备"喊话 → INVENTORY,
-- 墓地喊话 → "你好"), 补发查询的应答到达时阶段不符被误路由丢弃 → 整链超时 →
-- 面板按旧栈还原(绿框常亮的另一成因)。补发时把阶段拨回本查询应有的值。
local function reassertWaitFor(pName, pCmd)
	local tBtn = MultiBot.getBot and MultiBot.getBot(pName)
	if(tBtn == nil) then return end
	if(pCmd == "co ?") then tBtn.waitFor = "CO"
	elseif(pCmd == "nc ?") then tBtn.waitFor = "NC" end
end
-- FIX(2026-11-14 三轮): 点开关后面板"卡在旧状态需手动右键刷新"的加固。
-- 实测(11-14 10:35:31 CommLog)查询应答存在系统性丢失: 9 bot 并发查询 5 个连 3 次重试都超时,
-- 超时还原会把面板重画回旧栈 → 按钮又变亮 → 用户被迫手动右键补查。
-- 加固两招:
--   ① 超时后不立即"终审", 先自动隔 4 秒补查一整轮(服务端忙完一轮后通常能应答)——
--      把"用户手动右键"变成"插件自动再试", 只有第二轮仍全超时才还原+提示;
--   ② 全局并发查询链上限: 同时在途的查询链超过 MAX_ACTIVE_CHAINS 时新链自动顺延,
--      消除"一次点击风暴把 whisper 打丢"的突发丢包模式(与逐 bot 在途保护互补)。

local function scheduleCheck(pName, pEntry)
	After(RETRY_DELAY, function()
		local tCur = MultiBot._queryRetry and MultiBot._queryRetry[pName]
		if(tCur ~= pEntry) then return end -- 已被响应解除或被新查询替换

		if(pEntry.attempts >= MAX_ATTEMPTS) then
			-- FIX(2026-11-14 三轮): 第一轮超时不立即终审, 隔 4 秒自动补查一整轮。
			-- 典型场景: 用户点开关后, 服务端正忙(机器人集中上线/战斗/队列积压),
			-- 7.5 秒重试窗口内应答不来 → 旧逻辑直接还原旧栈, 用户看到"点了没变绿框还在",
			-- 只能手动右键补查。现在插件自动在服务端空闲后再查一轮, 无需人工干预。
			if((pEntry.round or 1) < MAX_ROUNDS) then
				pEntry.round = (pEntry.round or 1) + 1
				pEntry.attempts = 0
				-- LOG(2026-11-12): 补查轮开始写入通信日志(仅调试记录模式)
				if(MultiBot.CommLogEnabled and MultiBot.AddCommLog ~= nil) then
					MultiBot.AddCommLog("info", pName, MultiBot.TF("查询 %s 第%s轮超时, %s秒后自动补查第%s轮",
						pEntry.cmd, pEntry.round - 1, ROUND_PAUSE, pEntry.round))
				end
				After(ROUND_PAUSE, function()
					local tCur = MultiBot._queryRetry and MultiBot._queryRetry[pName]
					if(tCur ~= pEntry) then return end -- 已被响应解除或被新查询替换
					-- LOG(2026-11-12): 补查发送写入通信日志(仅调试记录模式)
					if(MultiBot.CommLogEnabled and MultiBot.AddCommLog ~= nil) then
						MultiBot.AddCommLog("send", pName, MultiBot.TF("%s (自动补查 第%s轮)", pEntry.cmd, pEntry.round))
					end
					reassertWaitFor(pName, pEntry.cmd)
					SendChatMessage(pEntry.cmd, "WHISPER", nil, pName)
					pEntry.attempts = pEntry.attempts + 1
					scheduleCheck(pName, pEntry)
				end)
				return
			end
			MultiBot._queryRetry[pName] = nil
			print(MultiBot.TF("|cffff6060[MultiBot]|r %s 未响应策略查询(%s)——机器人可能尚未完全上线或响应丢失, 可稍后重试。", pName, pEntry.cmd))
			-- FIX(2026-11-13): 超限后按"最后一次已知真实策略栈"重画还原该机器人面板。
			-- 消除切换指令(待确认压暗/互斥预测互灭)的残留状态, 面板回到已知真实状态——
			-- 未获确认的切换不代表生效(上方提示已说明), 但面板绝不停留在假状态。
			local tUnits = MultiBot.frames and MultiBot.frames["MultiBar"]
				and MultiBot.frames["MultiBar"].frames and MultiBot.frames["MultiBar"].frames["Units"]
			local tBtn = tUnits and tUnits.buttons and tUnits.buttons[pName]
			if(tBtn ~= nil and tBtn.class ~= nil and MultiBot["add" .. tBtn.class] ~= nil) then
				local tFrame = tUnits.addFrame(pName, tBtn.x - tBtn.size - 2, tBtn.y + 2)
				tFrame.class = tBtn.class
				tFrame.name = tBtn.name
				MultiBot["add" .. tBtn.class](tFrame, tBtn.combat, tBtn.normal)
				if(MultiBot.addEvery) then MultiBot.addEvery(tFrame, tBtn.combat, tBtn.normal) end
				if(MultiBot.MarkDefaultStrategies) then
					MultiBot.MarkDefaultStrategies(tFrame, tBtn.class, tBtn.combat, tBtn.normal)
				end
				-- FIX(2026-11-14): 还原重画后同样同步根按钮绿框
				if(MultiBot.SyncRootButtons) then MultiBot.SyncRootButtons(tFrame) end
				print(MultiBot.TF("|cffffd100[MultiBot]|r %s 面板已还原到最近已知状态(本次切换未获确认, 不代表已生效)。", pName))
			end
			-- LOG(2026-11-12): 查询超时写入通信日志(仅调试记录模式)
			if(MultiBot.CommLogEnabled and MultiBot.AddCommLog ~= nil) then
				MultiBot.AddCommLog("info", pName, MultiBot.TF("查询 %s 超时(%s次无响应)——机器人可能未完全上线, 应答丢失", pEntry.cmd, MAX_ATTEMPTS))
			end
			return
		end

		pEntry.attempts = pEntry.attempts + 1
		-- LOG(2026-11-12): 自动重试发送写入通信日志(仅调试记录模式)
		if(MultiBot.CommLogEnabled and MultiBot.AddCommLog ~= nil) then
			MultiBot.AddCommLog("send", pName, MultiBot.TF("%s (自动重试 %s/%s)", pEntry.cmd, pEntry.attempts, MAX_ATTEMPTS))
		end
		reassertWaitFor(pName, pEntry.cmd)
		SendChatMessage(pEntry.cmd, "WHISPER", nil, pName)
		scheduleCheck(pName, pEntry)
	end)
end

-- 发送策略查询并武装重试; pStage 仅用于调试标识("CO"/"NC")
-- pForce=true 供查询链内部续段使用(CO分支发 nc ?), 绕过在途保护
function MultiBot.SendQuery(pName, pCmd, pStage, pForce)
	if(pName == nil or pName == "") then return end
	MultiBot._queryRetry = MultiBot._queryRetry or {}
	-- FIX(2026-11-14 二轮): 链路在途保护。
	-- 同一机器人的应答只有 "Strategies: " 一种格式, co/nc 无法从内容区分归属; 若上一条查询链
	-- 未走完(co ? 已回、nc ? 未回)又发出新查询, 新应答会被旧的 waitFor 阶段误收——非战斗列表
	-- 被写进战斗串, 面板按污染数据重画出假状态。在途时自动顺延, 直到链路空闲再发出。
	if(pForce ~= true and MultiBot._queryRetry[pName] ~= nil) then
		After(0.5, function() MultiBot.SendQuery(pName, pCmd, pStage, pForce) end)
		return
	end
	-- FIX(2026-11-14 三轮): 全局并发上限。11-14 10:35:31 实测 9 bot 同时查询 5 个连 3 次重试
	-- 都收不到应答——whisper 风暴式并发是丢包的直接诱因。这里限制同时在途链数,
	-- 超出的查询自动顺延(0.5 秒循环), 与逐 bot 在途保护互补。
	if(pForce ~= true and type(After) == "function") then
		local tActive = 0
		for _ in pairs(MultiBot._queryRetry) do tActive = tActive + 1 end
		if(tActive >= MAX_ACTIVE_CHAINS) then
			After(0.5, function() MultiBot.SendQuery(pName, pCmd, pStage, pForce) end)
			return
		end
	end
	-- FIX(2026-11-16 十二轮): 不再清"切换后刷新"标记——旧实现发出任何查询都清
	-- _refreshQueued, 会把点击后 1.5s 延迟刷新任务误杀(在途旧链的 nc ? 续段/Hello/
	-- 批量刷新落在窗口内时, 切换后查询从未发出 = 绿框常亮根因)。刷新任务的生命周期
	-- 现在完全由 Engine.ScheduleStrategyRefresh 自管理(最后点击时刻+自续期)。
	-- FIX(2026-11-14 二轮): waitFor 只在查询真正发出时设置, 消除"先改阶段、应答未到"的错位窗口
	if(pCmd == "co ?") then
		local tBtn = MultiBot.getBot and MultiBot.getBot(pName)
		if(tBtn ~= nil) then tBtn.waitFor = "CO" end
	end
	local tEntry = { cmd = pCmd, stage = pStage or "", attempts = 1 }
	MultiBot._queryRetry[pName] = tEntry
	-- LOG(2026-11-12): 策略查询写入通信日志(仅调试记录模式)
	if(MultiBot.CommLogEnabled and MultiBot.AddCommLog ~= nil) then
		MultiBot.AddCommLog("send", pName, pCmd)
	end
	SendChatMessage(pCmd, "WHISPER", nil, pName)
	scheduleCheck(pName, tEntry)
end

-- FIX(2026-11-12): 只武装监视不重复发送。
-- 策略切换指令(co +xxx,? / nc +xxx,?)本身就会让机器人回 "Strategies: ...",
-- 切换后无需再补发一条查询; 只需挂上重试监视——若切换应答在超时内没回来
-- (机器人未上线/whisper 被丢弃), 由重试线程补发查询并提示。
function MultiBot.ArmQueryWatch(pName, pCmd, pStage)
	if(pName == nil or pName == "") then return end
	if(type(TimerAfter) ~= "function") then return end
	MultiBot._queryRetry = MultiBot._queryRetry or {}
	local tEntry = { cmd = pCmd, stage = pStage or "", attempts = 0 }
	MultiBot._queryRetry[pName] = tEntry
	scheduleCheck(pName, tEntry)
end

-- 收到预期响应后解除重试
function MultiBot.ClearQuery(pName)
	if(MultiBot._queryRetry) then MultiBot._queryRetry[pName] = nil end
end
