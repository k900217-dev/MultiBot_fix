MultiBot.addRogue = function(pFrame, pCombat, pNormal)
	pFrame.addButton("DpsControl", 0, 0, "ability_warrior_challange", MultiBot.tips.rogue.dps.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DpsControl"))
	end

	local tFrame = pFrame.addFrame("DpsControl", -2, 30)
	tFrame:Hide()

	tFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.rogue.dps.dpsAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps assist,?", "co -dps assist,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	tFrame.addButton("DpsAoe", 0, 26, "spell_holy_surgeoflight", MultiBot.tips.rogue.dps.dpsAoe).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps aoe,?", "co -dps aoe,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAssist").setDisable()
		end
	end

	tFrame.addButton("Dps", 0, 52, "spell_holy_divinepurpose", MultiBot.tips.rogue.dps.dps).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +dps,?", "co -dps,?", pButton.getName())
	end

	-- STEALTH (maintenir le camouflage HORS COMBAT)
	tFrame.addButton("Stealth", 0, 78, "ability_stealth",  MultiBot.tips.rogue.dps.stealth).setDisable()
	.doLeft = function(pButton)
		-- "stealth" est une stratégie non-combat : on la pousse côté pNormal
		-- FIX(2026-11-14): 原代码发 co 指令但 stealth 是非战斗策略, 且渲染检查 pNormal(nc串) —— 导致永远不亮且关不掉; 改为 nc 指令
		MultiBot.OnOffActionToTarget(pButton, "nc +stealth,?", "nc -stealth,?", pButton.getName())
	end

	-- STEALTHED (comportement EN CAMOUFLAGE en combat)
	tFrame.addButton("Stealthed", 0, 104, "ability_sap", MultiBot.tips.rogue.dps.stealthed).setDisable()
	.doLeft = function(pButton)
		-- Pour entrer en mode "stealthed", on coupe dps et on force stealthed ; l'inverse pour repasser en dps.
		if(MultiBot.OnOffActionToTarget(pButton, "co +stealthed,?", "co -stealthed,?", pButton.getName())) then
			pButton.getButton("Dps")      .setDisable()
			pButton.getButton("DpsAoe")   .setDisable()
			pButton.getButton("DpsAssist")   .setDisable()
		end
	end

	-- BOOST (active les CD offensifs : Adrenaline Rush, Blade Flurry, etc.)
	tFrame.addButton("Boost", 0, 130, "ability_mage_potentspirit", MultiBot.tips.rogue.dps.boost).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +boost,?", "co -boost,?", pButton.getName())
	end

	-- ASSIST --

	pFrame.addButton("TankAssist", -30, 0, "ability_warrior_innerrage", MultiBot.tips.rogue.tankAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +tank assist,?", "co -tank assist,?", pButton.getName())) then
			pButton.getButton("DpsAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	-- STRATEGIES --

	-- FIX(2026-11-12): "dps" 改整名匹配(原子串匹配会误命中 "dps aoe"/"dps assist")
	if(MultiBot.hasStrat(pCombat, "dps")) then pFrame.getButton("Dps").setEnable() end
	if(MultiBot.hasStrat(pCombat, "dps aoe")) then pFrame.getButton("DpsAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "dps assist")) then pFrame.getButton("DpsAssist").setEnable() end
	if(MultiBot.hasStrat(pCombat, "tank assist")) then pFrame.getButton("TankAssist").setEnable() end
	-- DPS辅助/DPS范围攻击/坦克辅助是服务端互斥组(AssistStrategyContext), 渲染时强制只亮一个
	local tAssist = nil
	if(MultiBot.hasStrat(pCombat, "dps assist")) then tAssist = "DpsAssist"
	elseif(MultiBot.hasStrat(pCombat, "dps aoe")) then tAssist = "DpsAoe"
	elseif(MultiBot.hasStrat(pCombat, "tank assist")) then tAssist = "TankAssist" end
	MultiBot.SyncExclusiveGroup(pFrame, { "DpsAssist", "DpsAoe", "TankAssist" }, tAssist)

	if(MultiBot.isInside(pNormal, "stealth")) then pFrame.getButton("Stealth").setEnable() end
	if(MultiBot.isInside(pCombat, "stealthed")) then pFrame.getButton("Stealthed").setEnable() end
	if(MultiBot.isInside(pCombat, "boost")) then pFrame.getButton("Boost").setEnable() end
end