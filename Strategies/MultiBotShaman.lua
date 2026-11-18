MultiBot.addShaman = function(pFrame, pCombat, pNormal)
	pFrame.addButton("Heal", 0, 0, "spell_holy_aspiration", MultiBot.tips.shaman.heal).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +heal,?", "co -heal,?", pButton.getName())) then
			pButton.getButton("Caster").setDisable()
			pButton.getButton("Melee").setDisable()
		end
	end

	-- FIX(2026-11-17 三十六轮): 删除"非战斗图腾"面板(整组按钮+面板)。
	-- 依据: 按钮发 nc ±bmana / nc ±bdps, 但 bmana/bdps 只在法师/猎人策略上下文注册,
	-- 萨满没有这两个策略 → Engine::addStrategy 取不到策略就静默忽略, 按钮实际无效。
	-- 萨满的非战斗图腾由默认图腾策略(stoneskin/flametongue/mana spring/wrath of air 等)负责。

	-- FIX(2026-11-17 三十六轮): 删除"战斗图腾"面板(整组按钮+面板)。
	-- 同因: co ±bmana / co ±bdps 在萨满策略上下文里不存在, 点击无效。
	-- 战斗图腾同样由默认图腾策略控制(元素/增强/恢复各有自己的四根默认图腾)。

	-- PLAYBOOK --

	-- 三十八轮: 删除两个图腾面板后整体左移 60px 补位(原 -30/-60 空位)
	pFrame.addButton("Playbook", -30, 0, "inv_misc_book_06", MultiBot.tips.shaman.playbook.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local playbookFrame = pFrame.addFrame("Playbook", -32, 30)
	playbookFrame:Hide()

	-- FIX(2026-11-17 三十六轮): 删除策略手册里的"图腾"按钮。
	-- 它发 co ±totems, 但服务端没有名为 "totems" 的策略 → 死键(静默忽略)。
	-- 具体图腾请用屏幕上的"团队萨满图腾控制"快捷条(按 bot×元素 发 co +<具体图腾策略>)。

	playbookFrame.addButton(
		"CasterAoe", 0, 0, "spell_nature_lightningoverload",
		MultiBot.tips.shaman.playbook.casterAoe
	).setDisable()
	.doLeft = function(pButton)
		-- FIX(2026-11-13): 死按钮修复(方案A)。服务端无"caster aoe"; 组合指令=切元素(caster->ele)+aoe, 关=只移除aoe
		MultiBot.OnOffActionToTarget(pButton, "co +caster,+aoe,?", "co -aoe,?", pButton.getName())
	end

	playbookFrame.addButton("Caster", 0, 26, "spell_nature_lightning", MultiBot.tips.shaman.playbook.caster).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +caster,?", "co -caster,?", pButton.getName())) then
			pButton.getButton("Melee").setDisable()
			pButton.getButton("Heal").setDisable()
		end
	end

	playbookFrame.addButton(
		"MeleeAoe", 0, 52, "ability_warrior_shockwave",
		MultiBot.tips.shaman.playbook.meleeAoe
	).setDisable()
	.doLeft = function(pButton)
		-- FIX(2026-11-13): 死按钮修复(方案A)。服务端无"melee aoe"; 组合指令=切增强(melee->enh)+aoe, 关=只移除aoe
		MultiBot.OnOffActionToTarget(pButton, "co +melee,+aoe,?", "co -aoe,?", pButton.getName())
	end

	playbookFrame.addButton("Melee", 0, 78, "ability_parry", MultiBot.tips.shaman.playbook.melee).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +melee,?", "co -melee,?", pButton.getName())) then
			pButton.getButton("Caster").setDisable()
			pButton.getButton("Heal").setDisable()
		end
	end

	-- UTILITAIRE : CURE --
	pFrame.addButton("Cure", -120, 0, "Ability_Creature_Poison_02", MultiBot.tips.shaman.playbook.cure).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "co +cure,?", "co -cure,?", pButton.getName())
	end

	-- STRATEGIES:PLAYBOOK --
	-- FIX(2026-11-12): 改整名匹配 + 主策略互斥组同步。
	-- 原子串匹配误亮: "heal" 命中 "healer dps" -> 只有治疗协助输出时 Heal 也亮;
	-- 服务端三主策略(caster/melee/heal)互斥(sibling), 渲染时强制整组只亮一个。
	local tPrimary = nil
	-- FIX(2026-11-13): 主策略检查名改用服务端栈名。别名注册: +caster->ele, +melee->enh, +heal->resto
	-- (源码 ShamanCombatStrategyFactoryInternal creators 别名, 第一轮日志实测栈名 ele/resto)。
	if(MultiBot.hasStrat(pCombat, "ele")) then tPrimary = "Caster"
	elseif(MultiBot.hasStrat(pCombat, "enh")) then tPrimary = "Melee"
	elseif(MultiBot.hasStrat(pCombat, "resto")) then tPrimary = "Heal" end
	MultiBot.SyncExclusiveGroup(pFrame, { "Caster", "Melee", "Heal" }, tPrimary)

	-- 三十六轮: "totems" 策略不存在, 对应的启用法已随按钮删除。
	-- FIX(2026-11-13): Aoe 按钮亮灯条件同步为"主策略栈名+aoe"组合(服务端无"xx aoe"复合名)
	if(MultiBot.hasStrat(pCombat, "enh") and MultiBot.hasStrat(pCombat, "aoe")) then pFrame.getButton("MeleeAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "ele") and MultiBot.hasStrat(pCombat, "aoe")) then pFrame.getButton("CasterAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "cure")) then pFrame.getButton("Cure").setEnable() end

	-- DPS --

	pFrame.addButton("DpsControl", -60, 0, "ability_warrior_challange", MultiBot.tips.shaman.dps.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DpsControl"))
	end

	local dpsControlFrame = pFrame.addFrame("DpsControl", -62, 30)
	dpsControlFrame:Hide()

	dpsControlFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.shaman.dps.dpsAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps assist,?", "co -dps assist,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	dpsControlFrame.addButton("DpsAoe", 0, 26, "spell_holy_surgeoflight", MultiBot.tips.shaman.dps.dpsAoe).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps aoe,?", "co -dps aoe,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAssist").setDisable()
		end
	end

	-- HEALER DPS --
	dpsControlFrame.addButton("HealerDps", 0, 52, "INV_Alchemy_Elixir_02", MultiBot.tips.shaman.dps.healerdps).setDisable()
	.doLeft = function(pButton)
		-- 服务端"healer dps"注册在非互斥工厂(ShamanStrategyFactoryInternal), 可与
		-- DPS辅助/DPS范围攻击/坦克辅助及任意主策略叠加, 不做任何互灭。
		MultiBot.OnOffActionToTarget(pButton, "co +healer dps,?", "co -healer dps,?", pButton.getName())
	end

	-- ASSIST --

	pFrame.addButton("TankAssist", -90, 0, "ability_warrior_innerrage", MultiBot.tips.shaman.tankAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +tank assist,?", "co -tank assist,?", pButton.getName())) then
			pButton.getButton("DpsAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	-- STRATEGIES --
	-- FIX(2026-11-12 下午): DPS辅助/范围攻击/坦克辅助是服务端互斥组(AssistStrategyContext,
	--   sibling), 同步时强制整组只亮一个; 治疗者-DPS 在非互斥工厂, 独立点亮不参与该组。
	if(MultiBot.hasStrat(pCombat, "dps assist")) then pFrame.getButton("DpsAssist").setEnable() end
	if(MultiBot.hasStrat(pCombat, "dps aoe")) then pFrame.getButton("DpsAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "healer dps")) then pFrame.getButton("HealerDps").setEnable() end
	if(MultiBot.hasStrat(pCombat, "tank assist")) then pFrame.getButton("TankAssist").setEnable() end
	local tAssist = nil
	if(MultiBot.hasStrat(pCombat, "dps assist")) then tAssist = "DpsAssist"
	elseif(MultiBot.hasStrat(pCombat, "dps aoe")) then tAssist = "DpsAoe"
	elseif(MultiBot.hasStrat(pCombat, "tank assist")) then tAssist = "TankAssist" end
	MultiBot.SyncExclusiveGroup(pFrame, { "DpsAssist", "DpsAoe", "TankAssist" }, tAssist)

end