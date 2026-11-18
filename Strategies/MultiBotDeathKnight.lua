MultiBot.addDeathKnight = function(pFrame, pCombat, pNormal)
	local tButton = pFrame.addButton("Presence", 0, 0, "spell_deathknight_bloodpresence", MultiBot.tips.deathknight.presence.master).setDisable()
	tButton.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Presence"))
	end

	local tFrame = pFrame.addFrame("Presence", -2, 30)
	tFrame:Hide()

	tFrame.addButton("Unholy", 0, 0, "spell_deathknight_unholypresence", MultiBot.tips.deathknight.presence.unholy)
	.doLeft = function(pButton)
		MultiBot.SelectToTarget(pButton.get(), "Presence", pButton.texture, "co +unholy,?", pButton.getName())
		--pButton.getButton("Presence").doRight = function(pButton)
		pButton.getButton("Presence").doRight = function()
			MultiBot.OnOffActionToTarget(pButton, "co +unholy,?", "co -unholy,?", pButton.getName())
		end
	end

	tFrame.addButton("Frost", 0, 26, "spell_deathknight_frostpresence", MultiBot.tips.deathknight.presence.frost)
	.doLeft = function(pButton)
		MultiBot.SelectToTarget(pButton.get(), "Presence", pButton.texture, "co +frost,?", pButton.getName())
		--pButton.getButton("Presence").doRight = function(pButton)
		pButton.getButton("Presence").doRight = function()
			MultiBot.OnOffActionToTarget(pButton, "co +frost,?", "co -frost,?", pButton.getName())
		end
	end

	tFrame.addButton("Blood", 0, 52, "spell_deathknight_bloodpresence", MultiBot.tips.deathknight.presence.blood)
	.doLeft = function(pButton)
		MultiBot.SelectToTarget(pButton.get(), "Presence", pButton.texture, "co +blood,?", pButton.getName())
		--pButton.getButton("Presence").doRight = function(pButton)
		pButton.getButton("Presence").doRight = function()
			MultiBot.OnOffActionToTarget(pButton, "co +blood,?", "co -blood,?", pButton.getName())
		end
	end

	-- SRATEGIES:PRESENCE ---
	-- FIX(2026-11-12): 改整名匹配(原子串匹配 "unholy"/"frost" 会误命中 "unholy aoe"/"frost aoe",
	-- 只开了 AoE 辅助的 DK, 灵界按钮也会被误点亮成对应灵界)

	if(MultiBot.hasStrat(pCombat, "unholy")) then
		tButton.setTexture("spell_deathknight_unholypresence").setEnable().doRight = function(pButton)
			MultiBot.OnOffActionToTarget(pButton, "co +unholy,?", "co -unholy,?", pButton.getName())
		end
	elseif(MultiBot.hasStrat(pCombat, "frost")) then
		tButton.setTexture("spell_deathknight_frostpresence").setEnable().doRight = function(pButton)
			MultiBot.OnOffActionToTarget(pButton, "co +frost,?", "co -frost,?", pButton.getName())
		end
	elseif(MultiBot.hasStrat(pCombat, "blood")) then
		tButton.setTexture("spell_deathknight_bloodpresence").setEnable().doRight = function(pButton)
			MultiBot.OnOffActionToTarget(pButton, "co +blood,?", "co -blood,?", pButton.getName())
		end
	end

	-- DPS --

	pFrame.addButton("DpsControl", -30, 0, "ability_warrior_challange", MultiBot.tips.deathknight.dps.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DpsControl"))
	end

	local tDpsFrame = pFrame.addFrame("DpsControl", -32, 30)
	tDpsFrame:Hide()

	--tFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.deathknight.dps.dpsAssist).setDisable()
	tDpsFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.deathknight.dps.dpsAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps assist,?", "co -dps assist,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	--tFrame.addButton("DpsAoe", 0, 26, "spell_holy_surgeoflight", MultiBot.tips.deathknight.dps.dpsAoe).setDisable()
	tDpsFrame.addButton("DpsAoe", 0, 26, "spell_holy_surgeoflight", MultiBot.tips.deathknight.dps.dpsAoe).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps aoe,?", "co -dps aoe,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAssist").setDisable()
		end
	end

    -- missing CLASS AOE (Frost/Unholy) --

    --tFrame.addButton("FrostAoe", 0, 52, "spell_frost_frostbolt02", "Frost Aoe").setDisable()
	tDpsFrame.addButton("FrostAoe", 0, 52, "spell_frost_frostbolt02", MultiBot.tips.deathknight.dps.frostAoe).setDisable()
    .doLeft = function(pButton)
        -- frost aoe 注册在非互斥工厂, 与 dps aoe/unholy aoe 均可叠加, 不做互灭
        MultiBot.OnOffActionToTarget(pButton, "co +frost aoe,?", "co -frost aoe,?", pButton.getName())
    end

    --*tFrame.addButton("UnholyAoe", 0, 78, "spell_fire_felflamering", "Unholy Aoe").setDisable()
	tDpsFrame.addButton("UnholyAoe", 0, 78, "spell_fire_felflamering", MultiBot.tips.deathknight.dps.unholyAoe).setDisable()
    .doLeft = function(pButton)
        -- unholy aoe 注册在非互斥工厂, 可叠加, 不做互灭
        MultiBot.OnOffActionToTarget(pButton, "co +unholy aoe,?", "co -unholy aoe,?", pButton.getName())
    end

	-- ASSIST --

	pFrame.addButton("TankAssist", -60, 0, "ability_warrior_innerrage", MultiBot.tips.deathknight.tankAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +tank assist,?", "co -tank assist,?", pButton.getName())) then
			pButton.getButton("DpsAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	-- STRATEGIES --

	if(MultiBot.hasStrat(pCombat, "dps aoe")) then pFrame.getButton("DpsAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "dps assist")) then pFrame.getButton("DpsAssist").setEnable() end
	if(MultiBot.hasStrat(pCombat, "tank assist")) then pFrame.getButton("TankAssist").setEnable() end
	-- DPS辅助/DPS范围攻击/坦克辅助是服务端互斥组(AssistStrategyContext), 渲染时强制只亮一个
	local tAssist = nil
	if(MultiBot.hasStrat(pCombat, "dps assist")) then tAssist = "DpsAssist"
	elseif(MultiBot.hasStrat(pCombat, "dps aoe")) then tAssist = "DpsAoe"
	elseif(MultiBot.hasStrat(pCombat, "tank assist")) then tAssist = "TankAssist" end
	MultiBot.SyncExclusiveGroup(pFrame, { "DpsAssist", "DpsAoe", "TankAssist" }, tAssist)

    if(MultiBot.isInside(pCombat, "frost aoe"))   then pFrame.getButton("FrostAoe").setEnable()   end
    if(MultiBot.isInside(pCombat, "unholy aoe"))  then pFrame.getButton("UnholyAoe").setEnable()  end
end