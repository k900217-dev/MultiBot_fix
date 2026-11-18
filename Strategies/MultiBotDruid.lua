MultiBot.addDruid = function(pFrame, pCombat, pNormal)
	pFrame.addButton("Heal", 0, 0, "spell_holy_aspiration", MultiBot.tips.druid.heal).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +heal,?", "co -heal,?", pButton.getName())) then
			pButton.getButton("Caster").setDisable()
			pButton.getButton("Tank").setDisable()
			pButton.getButton("Bear").setDisable()
			pButton.getButton("Cat").setDisable()
			pButton.getButton("Dps").setDisable()
		end
	end

	-- BUFF --

	pFrame.addButton("Buff", -30, 0, "spell_holy_power", MultiBot.tips.druid.buff).setDisable()
	.doLeft = function(pButton)
		MultiBot.OnOffActionToTarget(pButton, "nc +buff,?", "nc -buff,?", pButton.getName())
	end

	-- PLAYBOOK --

	pFrame.addButton("Playbook", -60, 0, "inv_misc_book_06", MultiBot.tips.druid.playbook.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("Playbook"))
	end

	local tFrame = pFrame.addFrame("Playbook", -62, 30)
	tFrame:Hide()

	tFrame.addButton("CasterDebuff", 0, 0, "ability_druid_cower", MultiBot.tips.druid.playbook.casterDebuff).setDisable()
	.doLeft = function(pButton)
		-- FIX(2026-11-13): 死按钮修复(方案A)。服务端无"caster debuff"; 施法者形态=balance 策略(枭兽),
		-- 减益(精灵之火/虫群/月火)为 balance 触发器自动附带。开=+balance, 关=-balance。
		if(MultiBot.OnOffActionToTarget(pButton, "co +balance,?", "co -balance,?", pButton.getName())) then
			pButton.getButton("DpsDebuff").setEnable()
		else
			pButton.getButton("DpsDebuff").setDisable()
		end
	end

	tFrame.addButton("CasterAoe", 0, 26, "spell_arcane_starfire", MultiBot.tips.druid.playbook.casterAoe).setDisable()
	.doLeft = function(pButton)
		-- FIX(2026-11-13): 死按钮修复(方案A)。组合指令=施法者(balance)+aoe(飓风), 关=只移除aoe
		MultiBot.OnOffActionToTarget(pButton, "co +balance,+aoe,?", "co -aoe,?", pButton.getName())
	end

	tFrame.addButton("Caster", 0, 52, "spell_nature_starfall", MultiBot.tips.druid.playbook.caster).setDisable()
	.doLeft = function(pButton)
		-- FIX(2026-11-13): 死按钮修复(方案A)。服务端施法者策略注册名是 balance(无"caster")
		if(MultiBot.OnOffActionToTarget(pButton, "co +balance,?", "co -balance,?", pButton.getName())) then
			pButton.getButton("Heal").setDisable()
			pButton.getButton("Tank").setDisable()
			pButton.getButton("Bear").setDisable()
			pButton.getButton("Cat").setDisable()
			pButton.getButton("Dps").setDisable()
		end
	end

	tFrame.addButton("CatAoe", 0, 78, "ability_druid_bash", MultiBot.tips.druid.playbook.catAoe).setDisable()
	.doLeft = function(pButton)
		-- FIX(2026-11-13): 死按钮修复(方案A)。服务端无"cat aoe"; 组合指令=猫形态+aoe(横扫), 关=只移除aoe
		MultiBot.OnOffActionToTarget(pButton, "co +cat,+aoe,?", "co -aoe,?", pButton.getName())
	end

	tFrame.addButton("Cat", 0, 104, "ability_druid_catform", MultiBot.tips.druid.playbook.cat).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +cat,?", "co -cat,?", pButton.getName())) then
			pButton.getButton("Caster").setDisable()
			pButton.getButton("Heal").setDisable()
			pButton.getButton("Tank").setDisable()
			pButton.getButton("Bear").setDisable()
			pButton.getButton("Dps").setEnable()
		else
			pButton.getButton("Dps").setDisable()
		end
	end

	tFrame.addButton("Bear", 0, 130, "ability_racial_bearform", MultiBot.tips.druid.playbook.bear).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +bear,?", "co -bear,?", pButton.getName())) then
			pButton.getButton("Caster").setDisable()
			pButton.getButton("Heal").setDisable()
			pButton.getButton("Cat").setDisable()
			pButton.getButton("Dps").setDisable()
			pButton.getButton("Tank").setEnable()
		else
			pButton.getButton("Tank").setDisable()
		end
	end

   -- Missin MELEE --
   tFrame.addButton("Melee", 0, 156, "ability_parry", MultiBot.tips.druid.playbook.melee).setDisable()
   .doLeft = function(pButton)
     if(MultiBot.OnOffActionToTarget(pButton, "co +melee,?", "co -melee,?", pButton.getName())) then
       pButton.getButton("Caster").setDisable()
       pButton.getButton("Heal").setDisable()
     end
   end

	-- DPS --

	pFrame.addButton("DpsControl", -90, 0, "ability_warrior_challange", MultiBot.tips.druid.dps.master)
	.doLeft = function(pButton)
		MultiBot.ShowHideSwitch(pButton.getFrame("DpsControl"))
	end

	--local tFrame = pFrame.addFrame("DpsControl", -92, 30)
	--tFrame:Hide()

	local tDpsFrame = pFrame.addFrame("DpsControl", -92, 30)
	tDpsFrame:Hide()

	--tFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.druid.dps.dpsAssist).setDisable()
	tDpsFrame.addButton("DpsAssist", 0, 0, "spell_holy_heroism", MultiBot.tips.druid.dps.dpsAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps assist,?", "co -dps assist,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	--tFrame.addButton("DpsDebuff", 0, 26, "spell_holy_restoration", MultiBot.tips.druid.dps.dpsDebuff).setDisable()
	tDpsFrame.addButton("DpsDebuff", 0, 26, "spell_holy_restoration", MultiBot.tips.druid.dps.dpsDebuff).setDisable()
	.doLeft = function(pButton)
		-- FIX(2026-11-13): 死按钮修复(方案A)。同 CasterDebuff: 服务端施法者=balance, 减益自动附带
		if(MultiBot.OnOffActionToTarget(pButton, "co +balance,?", "co -balance,?", pButton.getName())) then
			pButton.getButton("CasterDebuff").setEnable()
		else
			pButton.getButton("CasterDebuff").setDisable()
		end
	end

	-- tFrame.addButton("DpsAoe", 0, 52, "spell_holy_surgeoflight", MultiBot.tips.druid.dps.dpsAoe).setDisable()
	tDpsFrame.addButton("DpsAoe", 0, 52, "spell_holy_surgeoflight", MultiBot.tips.druid.dps.dpsAoe).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +dps aoe,?", "co -dps aoe,?", pButton.getName())) then
			pButton.getButton("TankAssist").setDisable()
			pButton.getButton("DpsAssist").setDisable()
		end
	end

    -- Missing HEALER DPS --
    --tFrame.addButton("HealerDps", 0, 130, "INV_Alchemy_Elixir_02", MultiBot.tips.druid.dps.healerdps).setDisable()
	tDpsFrame.addButton("HealerDps", 0, 130, "INV_Alchemy_Elixir_02", MultiBot.tips.druid.dps.healerdps).setDisable()
    .doLeft = function(pButton)
      -- healer dps 注册在非互斥工厂, 可与一切策略叠加, 不做互灭
      MultiBot.OnOffActionToTarget(pButton, "co +healer dps,?", "co -healer dps,?", pButton.getName())
    end

	--tFrame.addButton("Dps", 0, 78, "spell_holy_divinepurpose", MultiBot.tips.druid.dps.dps).setDisable()
	tDpsFrame.addButton("Dps", 0, 78, "spell_holy_divinepurpose", MultiBot.tips.druid.dps.dps).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +cat,?", "co -cat,?", pButton.getName())) then
			pButton.getButton("Caster").setDisable()
			pButton.getButton("Tank").setDisable()
			pButton.getButton("Bear").setDisable()
			pButton.getButton("Heal").setDisable()
			pButton.getButton("Cat").setEnable()
		else
			pButton.getButton("Cat").setDisable()
		end
	end

    -- OFF-HEAL --
    --tFrame.addButton("OffHeal", 0, 104, "spell_nature_healingtouch", MultiBot.tips.druid.dps.offheal).setDisable()
	tDpsFrame.addButton("OffHeal", 0, 104, "spell_nature_healingtouch", MultiBot.tips.druid.dps.offheal).setDisable()
        .doLeft = function(pButton)
            if (MultiBot.OnOffActionToTarget(
                    pButton, "co +offheal,?", "co -offheal,?",
                    pButton.getName())) then

                -- offheal 注册在非互斥工厂, 可叠加(FIX 2026-11-12: 原互灭错误)
            end
        end

	-- ASSIST --

	pFrame.addButton("TankAssist", -120, 0, "ability_warrior_innerrage", MultiBot.tips.druid.tankAssist).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +tank assist,?", "co -tank assist,?", pButton.getName())) then
			pButton.getButton("DpsAssist").setDisable()
			pButton.getButton("DpsAoe").setDisable()
		end
	end

	-- TANK --

	pFrame.addButton("Tank", -150, 0, "ability_warrior_shieldmastery", MultiBot.tips.druid.tank).setDisable()
	.doLeft = function(pButton)
		if(MultiBot.OnOffActionToTarget(pButton, "co +tank,?", "co -tank,?", pButton.getName())) then
			pButton.getButton("Caster").setDisable()
			pButton.getButton("Heal").setDisable()
			pButton.getButton("Dps").setDisable()
			pButton.getButton("Cat").setDisable()
			pButton.getButton("Bear").setEnable()
		else
			pButton.getButton("Bear").setDisable()
		end
	end

	-- STRATEGIES --
	-- FIX(2026-11-12): 改整名匹配 + 主形态互斥组同步。
	-- 原子串匹配误亮: "heal" 命中 "healer dps"/"offheal", "melee" 命中 "melee aoe";
	-- 服务端四主策略(caster/cat/bear/heal)互斥(sibling), 渲染时强制整组只亮一个。
	local tPrimary = nil
	-- FIX(2026-11-13): 主策略检查名改用服务端栈名。服务端施法者策略注册名是 balance(无"caster");
	-- balance/cat/bear/heal 同属 DruidDruidStrategyFactoryInternal(supportsSiblings=true) 服务端原生互斥。
	if(MultiBot.hasStrat(pCombat, "balance")) then tPrimary = "Caster"
	elseif(MultiBot.hasStrat(pCombat, "cat")) then tPrimary = "Cat"
	elseif(MultiBot.hasStrat(pCombat, "bear")) then tPrimary = "Bear"
	-- FIX(2026-11-14): 治疗检查名改用服务端栈名 resto。+heal 是别名, 进栈后以注册名
	-- resto 存储(CommLog 11-14 10:36 实测: 点治疗后栈出现 resto) → 生效但不亮。
	elseif(MultiBot.hasStrat(pCombat, "resto")) then tPrimary = "Heal" end
	MultiBot.SyncExclusiveGroup(pFrame, { "Caster", "Cat", "Bear", "Heal" }, tPrimary)

	if(MultiBot.hasStrat(pNormal, "buff")) then pFrame.getButton("Buff").setEnable() end
	-- FIX(2026-11-13): Debuff/Aoe 按钮亮灯条件同步为组合检查(服务端无"caster debuff"/"xx aoe"复合名);
	-- 减益由 balance 触发器自动附带, CasterDebuff 与 Caster 同为 balance 激活态, 两键会同亮(功能一致)。
	if(MultiBot.hasStrat(pCombat, "balance")) then pFrame.getButton("CasterDebuff").setEnable() end
	if(MultiBot.hasStrat(pCombat, "balance") and MultiBot.hasStrat(pCombat, "aoe")) then pFrame.getButton("CasterAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "cat") and MultiBot.hasStrat(pCombat, "aoe")) then pFrame.getButton("CatAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "dps assist")) then pFrame.getButton("DpsAssist").setEnable() end
	if(MultiBot.hasStrat(pCombat, "dps aoe")) then pFrame.getButton("DpsAoe").setEnable() end
	if(MultiBot.hasStrat(pCombat, "cat")) then pFrame.getButton("Dps").setEnable() end
	if(MultiBot.hasStrat(pCombat, "tank assist")) then pFrame.getButton("TankAssist").setEnable() end
	-- DPS辅助/DPS范围攻击/坦克辅助是服务端互斥组(AssistStrategyContext), 渲染时强制只亮一个
	local tAssist = nil
	if(MultiBot.hasStrat(pCombat, "dps assist")) then tAssist = "DpsAssist"
	elseif(MultiBot.hasStrat(pCombat, "dps aoe")) then tAssist = "DpsAoe"
	elseif(MultiBot.hasStrat(pCombat, "tank assist")) then tAssist = "TankAssist" end
	MultiBot.SyncExclusiveGroup(pFrame, { "DpsAssist", "DpsAoe", "TankAssist" }, tAssist)

	if(MultiBot.hasStrat(pCombat, "bear")) then pFrame.getButton("Tank").setEnable() end
	if(MultiBot.hasStrat(pCombat, "healer dps")) then pFrame.getButton("HealerDps").setEnable() end
	if(MultiBot.hasStrat(pCombat, "melee")) then pFrame.getButton("Melee").setEnable() end
	if(MultiBot.hasStrat(pCombat, "offheal")) then pFrame.getButton("OffHeal").setEnable() end
end