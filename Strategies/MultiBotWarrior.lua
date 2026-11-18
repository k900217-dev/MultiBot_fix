MultiBot.addWarrior = function(pFrame, pCombat, pNormal)
	pFrame.addButton("DpsControl", 0, 0, "ability_warrior_challange", MultiBot.tips.warrior.dps.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DpsControl"))
	end

	local tFrame = pFrame.addFrame("DpsControl", -2, 30)
	tFrame:Hide()

	tFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.warrior.dps.dpsAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps assist,?", "co -dps assist,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	tFrame.addButton("DpsAoe", 0, 26, "spell_holy_surgeoflight", MultiBot.tips.warrior.dps.dpsAoe).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps aoe,?", "co -dps aoe,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAssist").setDisable()
		end
	end

	-- ASSIST --

	pFrame.addButton("TankAssist", -30, 0, "ability_warrior_innerrage", MultiBot.tips.warrior.tankAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +tank assist,?", "co -tank assist,?", pButton.getName())) then
			pButton.getButton("DpsAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	-- TANK --

	pFrame.addButton("Tank", -60, 0, "ability_warrior_shieldmastery", MultiBot.tips.warrior.tank).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +tank,?", "co -tank,?", pButton.getName())
	end

	-- STRATEGIES --

	-- FIX(2026-11-12): "tank" 改整名匹配(原子串匹配会误命中 "tank assist")
	if(MultiBot.hasStrat(pCombat, "dps aoe")) then pFrame.getButton("DpsAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "dps assist")) then pFrame.getButton("DpsAssist").setEnable() end
	if(MultiBot.hasStrat(pCombat, "tank assist")) then pFrame.getButton("TankAssist").setEnable() end
	-- DPS辅助/DPS范围攻击/坦克辅助是服务端互斥组(AssistStrategyContext), 渲染时强制只亮一个
	local tAssist = nil
	if(MultiBot.hasStrat(pCombat, "dps assist")) then tAssist = "DpsAssist"
	elseif(MultiBot.hasStrat(pCombat, "dps aoe")) then tAssist = "DpsAoe"
	elseif(MultiBot.hasStrat(pCombat, "tank assist")) then tAssist = "TankAssist" end
	MultiBot.SyncExclusiveGroup(pFrame, { "DpsAssist", "DpsAoe", "TankAssist" }, tAssist)

	-- FIX(2026-11-14): 坦克检查名改用服务端栈名 prot。+tank 是别名, 进栈后以注册名
	-- prot 存储(CommLog 11-14 10:36 实测: 点坦克后栈出现 prot), 检查"tank"永不命中 → 生效但不亮。
	if(MultiBot.hasStrat(pCombat, "prot")) then pFrame.getButton("Tank").setEnable() end
end