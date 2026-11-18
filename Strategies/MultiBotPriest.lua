MultiBot.addPriest = function(pFrame, pCombat, pNormal)
	-- FIX(2026-11-12): 四个主策略按钮(治疗/暗影/神圣治疗/神圣伤害)在服务端是"兄弟策略",
	-- co +任一 个会自动顶掉其余三个(Engine::addStrategy 的 sibling 机制), 服务端永远只会
	-- 保留一个。这里把点击时的本地互灭补全(原版各按钮只互灭部分, 多点几下能同时点亮
	-- 多个互斥按钮), 配合切换后的自动回查, 面板与服务端真实栈保持一致。
	--
	-- 另注: "神圣-治疗"(holy dps)本身自带治疗触发(队友低血量:盾/快速治疗, 中血量:恢复),
	-- 是"主打伤害、顺手奶"的混合策略; 想要"治疗为主、有空才打伤害"应改用
	-- DPS控制菜单里的"治疗DPS"(healer dps), 它可与 heal 叠加(非互斥)。
	pFrame.addButton("Heal", 0, 0, "spell_holy_aspiration", MultiBot.tips.priest.heal).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +heal,?", "co -heal,?", pButton.getName())) then
			pButton.getButton("Shadow").setDisable()
			pButton.getButton("HolyHeal").setDisable()
			pButton.getButton("HolyDps").setDisable()
			pButton.getButton("Dps").setDisable()
		end
	end

	-- BUFF --

	pFrame.addButton("Buff", -30, 0, "spell_holy_power", MultiBot.tips.priest.buff).setDisable()
	.doLeft = function(pButton)
		-- FIX(2026-11-14): co 改 nc。服务端 buff 是非战斗引擎出厂默认(AiFactory::AddDefaultNonCombatStrategies
		-- 通用段 "buff"), 原发 co 指令只作用于战斗引擎——开=战斗栈加副本(灯亮), 关=只删战斗副本,
		-- nc 默认副本仍在(渲染双串检查), 表现为"只能开不能关"(CommLog 11-14 截图实测 co -rshadow 关不掉)。
		MultiBot.OnOffActionToTarget(pButton, "nc +buff,?", "nc -buff,?", pButton.getName())
	end

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.tips.priest.playbook.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	--local tFrame = pFrame.addFrame("Playbook", -62, 30)
	--tFrame:Hide()

	--tFrame.addButton("ShadowDebuff", 0, 0, "spell_shadow_demonicempathy", MultiBot.tips.priest.playbook.shadowDebuff).setDisable()

	local playbookFrame = pFrame.addFrame("Playbook", -62, 30)
    playbookFrame:Hide()

    playbookFrame.addButton("ShadowDebuff", 0, 0, "spell_shadow_demonicempathy", MultiBot.tips.priest.playbook.shadowDebuff).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +shadow debuff,?", "co -shadow debuff,?", pButton.getName())) then
			pButton.getButton("DpsDebuff").setEnable()
		else
			pButton.getButton("DpsDebuff").setDisable()
		end
	end

	--tFrame.addButton("ShadowAoe", 0, 26, "spell_arcane_arcanetorrent", MultiBot.tips.priest.playbook.shadowAoe).setDisable()
	 playbookFrame.addButton("ShadowAoe", 0, 26, "spell_arcane_arcanetorrent", MultiBot.tips.priest.playbook.shadowAoe).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +shadow aoe,?", "co -shadow aoe,?", pButton.getName())
	end

	--tFrame.addButton("Shadow", 0, 52, "spell_holy_devotion", MultiBot.tips.priest.playbook.shadow).setDisable()
	playbookFrame.addButton("Shadow", 0, 52, "spell_holy_devotion", MultiBot.tips.priest.playbook.shadow).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +shadow,?", "co -shadow,?", pButton.getName())) then
			pButton.getButton("Heal").setDisable()
			pButton.getButton("HolyHeal").setDisable()
			pButton.getButton("HolyDps").setDisable()
			pButton.getButton("Dps").setEnable()
		else
			pButton.getButton("Dps").setDisable()
		end
	end

	-- HOLY (PLAYBOOK) --
	--tFrame.addButton("HolyHeal", 0, 78, "spell_holy_guardianspirit", MultiBot.tips.priest.playbook.holyheal).setDisable()
	playbookFrame.addButton("HolyHeal", 0, 78, "spell_holy_guardianspirit", MultiBot.tips.priest.playbook.holyheal).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +holy heal,?", "co -holy heal,?", pButton.getName())) then
			pButton.getButton("Heal").setDisable()
			pButton.getButton("Shadow").setDisable()
			pButton.getButton("HolyDps").setDisable()
			pButton.getButton("Dps").setDisable()
		end
	end

	--tFrame.addButton("HolyDps", 0, 102, "spell_holy_holybolt", MultiBot.tips.priest.playbook.holydps).setDisable()
	playbookFrame.addButton("HolyDps", 0, 102, "spell_holy_holybolt", MultiBot.tips.priest.playbook.holydps).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +holy dps,?", "co -holy dps,?", pButton.getName())) then
			pButton.getButton("Heal").setDisable()
			pButton.getButton("Shadow").setDisable()
			pButton.getButton("HolyHeal").setDisable()
			pButton.getButton("Dps").setDisable()
		end
	end

   -- SHADOW RESISTANCE --
   -- (Expose 'rshadow' pour Shadow Protection)
   --tFrame.addButton("ShadowRes", 0, 128, "spell_shadow_antishadow", MultiBot.tips.priest.playbook.rshadow).setDisable()
   playbookFrame.addButton("ShadowRes", 0, 128, "spell_shadow_antishadow", MultiBot.tips.priest.playbook.rshadow).setDisable()
   .doLeft = function(pButton)
       -- FIX(2026-11-14): co 改 nc。服务端暗影防护(rshadow)是牧师非战斗引擎出厂默认
       -- (AddDefaultNonCombatStrategies CLASS_PRIEST: "dps assist","cure","rshadow"),
       -- 原 co 指令关不掉 nc 副本 → "只能开不能关"(11-14 截图实测)。
       MultiBot.OnOffActionToTarget(pButton, "nc +rshadow,?", "nc -rshadow,?", pButton.getName())
   end

	-- DPS --

	pFrame.addButton("DpsControl", -90, 0, "ability_warrior_challange", MultiBot.tips.priest.dps.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DpsControl"))
	end

	--local tFrame = pFrame.addFrame("DpsControl", -92, 30)
	--tFrame:Hide()

	--tFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.priest.dps.dpsAssist).setDisable()
    local dpsControlFrame = pFrame.addFrame("DpsControl", -92, 30)
    dpsControlFrame:Hide()

    dpsControlFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.priest.dps.dpsAssist).setDisable()
	.doLeft = function(pButton)
		-- 该按钮实际发送 "healer dps"(治疗者输出)。服务端 healer dps 注册在非互斥工厂,
		-- 可与 DPS范围攻击/坦克辅助/主策略叠加, 不做任何互灭(FIX 2026-11-12 下午)。
		MultiBot.OnOffActionToTarget(pButton, "co +healer dps,?", "co -healer dps,?", pButton.getName())
	end

	--tFrame.addButton("DpsDebuff", 0, 26, "spell_holy_restoration", MultiBot.tips.priest.dps.dpsDebuff).setDisable()
	dpsControlFrame.addButton("DpsDebuff", 0, 26, "spell_holy_restoration", MultiBot.tips.priest.dps.dpsDebuff).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +shadow debuff,?", "co -shadow debuff,?", pButton.getName())) then
			pButton.getButton("ShadowDebuff").setEnable()
		else
			pButton.getButton("ShadowDebuff").setDisable()
		end
	end

	--tFrame.addButton("DpsAoe", 0, 52, "spell_holy_surgeoflight", MultiBot.tips.priest.dps.dpsAoe).setDisable()
	dpsControlFrame.addButton("DpsAoe", 0, 52, "spell_holy_surgeoflight", MultiBot.tips.priest.dps.dpsAoe).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps aoe,?", "co -dps aoe,?", pButton.getName())) then
			-- 服务端互斥组(AssistStrategyContext): dps aoe / dps assist / tank assist 三选一
			pButton.getButton("TankAssist").setDisable()
		end
	end

	--tFrame.addButton("Dps", 0, 78, "spell_holy_divinepurpose", MultiBot.tips.priest.dps.dps).setDisable()
	dpsControlFrame.addButton("Dps", 0, 78, "spell_holy_divinepurpose", MultiBot.tips.priest.dps.dps).setDisable()
	.doLeft = function(pButton)
		-- 服务端 "dps" 是暗影策略(ShadowPriestStrategy)的注册别名, 与手册里的"暗影"完全等价
		if(MultiBot.OnOffActionToTarget(pButton, "co +shadow,?", "co -shadow,?", pButton.getName())) then
			pButton.getButton("Shadow").setEnable()
			pButton.getButton("Heal").setDisable()
			pButton.getButton("HolyHeal").setDisable()
			pButton.getButton("HolyDps").setDisable()
		else
			pButton.getButton("Shadow").setDisable()
		end
	end

	-- ASSIST --

	pFrame.addButton("TankAssist", -120, 0, "ability_warrior_innerrage", MultiBot.tips.priest.tankAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +tank assist,?", "co -tank assist,?", pButton.getName())) then
			-- 服务端互斥组: 只互灭 DpsAoe(DpsAssist按钮=healer dps, 可叠加, 不灭)
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	-- STRATEGIES --

	-- FIX(2026-11-09): 按钮状态改为整名匹配, 替代原来的子串匹配。
	-- 服务端策略栈按"注册名"存, 同一策略可有多个注册名(牧师: disc/heal 同指 DiscPriestStrategy,
	-- holy/holy heal 同指 HolyHealPriestStrategy, shadow/dps 同指 ShadowPriestStrategy)。
	-- 原子串匹配两层不准: ①漏亮——戒律牧师栈里登记名是"disc", "heal"按钮显示灰但策略实际在跑;
	-- ②误亮——"holy heal"/"healer dps" 都包含 "heal" 子串, 会点亮 Heal 按钮;
	-- ③漏亮——"shadow," 无法匹配列表末尾的策略名(Engine::ListStrategies 末尾无逗号)。
	-- FIX(2026-11-12): ① 四个主策略按钮改为互斥组同步(服务端 sibling 机制保证至多一个,
	--   渲染时强制整组只亮一个, 消除"多个互斥按钮同时亮"的假象);
	--   ② DPS控制菜单的"DPS"按钮与"暗影"等价(服务端 dps 是 shadow 的别名), 随暗影同步点亮;
	--   ③ 可叠加策略(shadow debuff/aoe, healer dps, dps aoe, tank assist, buff, rshadow)
	--      改用共享整名匹配 MultiBot.hasStrat, 消除子串误命中; buff/rshadow 同时查战斗
	--      与非战斗两个策略串(点击端发的是 co, 服务端注册在 nc 组, 两边都可能存)。
	local function hasStrat(list, name)
		return MultiBot.hasStrat(list, name)
	end

	local healOn     = hasStrat(pCombat, "heal") or hasStrat(pCombat, "disc")
	local shadowOn   = hasStrat(pCombat, "shadow") or hasStrat(pCombat, "dps")
	local holyHealOn = hasStrat(pCombat, "holy heal") or hasStrat(pCombat, "holy")
	local holyDpsOn  = hasStrat(pCombat, "holy dps")

	-- 主策略互斥组: 服务端保证至多一个在栈里; 若(异常残留)同时出现多个, 按优先级只亮第一个
	local primary = nil
	if(healOn) then primary = "Heal"
	elseif(shadowOn) then primary = "Shadow"
	elseif(holyHealOn) then primary = "HolyHeal"
	elseif(holyDpsOn) then primary = "HolyDps" end
	MultiBot.SyncExclusiveGroup(pFrame, { "Heal", "Shadow", "HolyHeal", "HolyDps" }, primary)

	-- DPS控制菜单的"DPS"按钮 = 暗影策略(别名入口), 随暗影同步
	local tDpsBtn = pFrame.getButton("Dps")
	if(tDpsBtn ~= nil) then
		if(shadowOn) then tDpsBtn.setEnable() else tDpsBtn.setDisable() end
	end

	-- 可叠加策略(与主策略不互斥, 可自由组合)
	if(hasStrat(pCombat, "shadow debuff") or hasStrat(pCombat, "dps debuff")) then
		pFrame.getButton("ShadowDebuff").setEnable()
		pFrame.getButton("DpsDebuff").setEnable()
	end
	if(hasStrat(pCombat, "shadow aoe")) then pFrame.getButton("ShadowAoe").setEnable() end
	if(hasStrat(pCombat, "healer dps")) then pFrame.getButton("DpsAssist").setEnable() end
	if(hasStrat(pCombat, "dps aoe")) then pFrame.getButton("DpsAoe").setEnable() end
	if(hasStrat(pCombat, "tank assist")) then pFrame.getButton("TankAssist").setEnable() end
	-- DPS辅助三件套(dps assist/dps aoe/tank assist)是服务端互斥组(AssistStrategyContext)。
	-- DpsAssist 按钮实际是 healer dps(可叠加), 不参与本组; "dps assist"无对应按钮,
	-- 但若栈中是它, DpsAoe/TankAssist 都应保持熄灭。
	local tAssist = nil
	if(hasStrat(pCombat, "dps aoe")) then tAssist = "DpsAoe"
	elseif(hasStrat(pCombat, "tank assist")) then tAssist = "TankAssist" end
	MultiBot.SyncExclusiveGroup(pFrame, { "DpsAoe", "TankAssist" }, tAssist)
	if(hasStrat(pCombat, "buff") or hasStrat(pNormal, "buff")) then pFrame.getButton("Buff").setEnable() end
	if(hasStrat(pCombat, "rshadow") or hasStrat(pNormal, "rshadow")) then pFrame.getButton("ShadowRes").setEnable() end
end