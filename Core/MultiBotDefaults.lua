-- FIX(2026-11-10): 出厂默认策略标识
--
-- 背景: 机器人上线时的初始策略由服务端 mod-playerbots 源码硬编码决定
-- (AiFactory::AddDefaultCombatStrategies, 按 职业×天赋档 查表), 不在任何 conf 里。
-- 本文件把这张映射表内置到插件, 用于在策略条上标记"哪些策略属于该职业该天赋的出厂默认":
--   - 属于当前天赋变量的出厂默认策略 -> 图标左上角绿色小点 + tooltip 追加"出厂默认策略"
--   - 用户手动叠加的策略(co +xxx) -> 无标记, 与默认策略视觉区分
--
-- FIX(2026-11-16 十三轮): 绿点不再要求按钮"当前已点亮"——默认策略被手动关闭(暗态)时
-- 也显示绿点, 便于识别"哪些是出厂默认、可以重新开启"。亮灭仍完全由服务端策略状态决定,
-- 绿点只表达"出厂默认"身份, 不表达开关状态。
-- 例外(宁可没有, 不可标错): 条件性默认策略在暗态时无法确认服务端是否真的加载了它,
-- 仍只在策略栈里出现时才标——healer dps(受限地图不加)/boost(仅 solo 未组队)/
-- 法师 fire 档的 fire/frostfire(按法术二选一, 都关着时无法区分)。

-- 精确整名匹配(逗号分隔策略串), 与子串匹配 isInside 区分, 避免别名误命中
MultiBot.hasStrategy = function(pList, pName)
	for token in string.gmatch(pList or "", "[^,]+") do
		if(string.gsub(token, "^%s+", "") == pName) then return true end
	end
	return false
end

-- 天赋档推断规则: 按顺序取 combat 策略串里的特征策略名(精确整名匹配), 返回档位 key
MultiBot.StrategySpecRules = {
	Priest      = { {"shadow", "shadow"}, {"holy heal", "holy"}, {"disc", "disc"}, {"heal", "disc"} },
	DeathKnight = { {"unholy", "unholy"}, {"frost", "frost"}, {"blood", "blood"} },
	Druid       = { {"balance", "balance"}, {"resto", "resto"}, {"cat", "cat"}, {"bear", "bear"} },
	Mage        = { {"arcane", "arcane"}, {"frostfire", "fire"}, {"fire", "fire"}, {"frost", "frost"} },
	Paladin     = { {"prot", "prot"}, {"holy", "holy"}, {"ret", "ret"} },
	Hunter      = { {"bm", "bm"}, {"mm", "mm"}, {"surv", "surv"} },
	Rogue       = { {"combat", "combat"}, {"assassin", "assassin"} },
	Shaman      = { {"ele", "ele"}, {"resto", "resto"}, {"enh", "enh"} },
	Warlock     = { {"affli", "affli"}, {"demo", "demo"}, {"destro", "destro"} },
	Warrior     = { {"prot", "prot"}, {"arms", "arms"}, {"fury", "fury"} },
}

-- 出厂默认策略 -> 策略条按钮名映射
-- FIX(2026-11-14): 按服务端源码全量重建(AiFactory::AddDefaultCombatStrategies + AddDefaultNonCombatStrategies,
-- 快照 d750b4b3 = 本机 20261016 构建)。旧表建于 11-10, 当时多数主策略按钮存在"检查名≠栈名"错位
-- (heal/resto、dps/ret、tank/prot 等)而从不点亮, 故 heal 系主策略条目缺失; 本版补齐:
--   ①治疗主策略: 骑士holy→Heal / 德鲁伊resto→Heal / 萨满resto→Heal / 牧师disc→Heal
--   ②伤害辅助(dps assist): 各职业默认都有, 旧表牧师系缺失(注意: 牧师面板无真 dps assist 按钮,
--     "DpsAssist"按钮发的是 healer dps, 牧师的 dps assist 默认无按钮表示, 无法标点)
--   ③条件默认: aoe 类(talent+aoe 组合检查按钮)、healer dps(仅治疗天赋, IsHeal 时服务端才加)
-- 十三轮起暗态也标绿点; 条件性默认(healer dps/boost/法师fire档fire与frostfire)暗态不标, 见文件头。
MultiBot.StrategyDefaults = {
	Priest = {
		disc   = { ["disc"] = "Heal", ["healer dps"] = "DpsAssist" },
		holy   = { ["holy heal"] = "HolyHeal", ["healer dps"] = "DpsAssist" },
		shadow = { ["shadow"] = "Shadow", ["shadow debuff"] = "ShadowDebuff", ["shadow aoe"] = "ShadowAoe" },
	},
	DeathKnight = {
		-- FIX(2026-11-18 五十轮): 绿点从根按钮 Presence 移到里面的子按钮。
		-- 根 Presence 的职责是"显示当前灵界状态"(按策略栈换图标点亮), 不是默认策略条目;
		-- 默认的是哪一种灵界, 标记就应落在 Unholy/Frost/Blood 对应子按钮上。
		-- 代价: 灵界子面板收起时绿点不可见, 展开即可看到。
		blood  = { ["blood"] = "Blood", ["tank assist"] = "TankAssist" },
		frost  = { ["frost"] = "Frost", ["frost aoe"] = "FrostAoe", ["dps assist"] = "DpsAssist" },
		unholy = { ["unholy"] = "Unholy", ["unholy aoe"] = "UnholyAoe", ["dps assist"] = "DpsAssist" },
	},
	Druid = {
		balance = { ["balance"] = "Caster", ["dps assist"] = "DpsAssist", ["aoe"] = "CasterAoe" },
		resto   = { ["resto"] = "Heal", ["dps assist"] = "DpsAssist", ["healer dps"] = "HealerDps" },
		cat     = { ["cat"] = "Cat", ["dps assist"] = "DpsAssist", ["aoe"] = "CatAoe" },
		bear    = { ["bear"] = "Bear", ["tank assist"] = "TankAssist" },
	},
	Mage = {
		arcane = { ["arcane"] = "Arcane", ["bdps"] = "NonCombatDps", ["dps assist"] = "DpsAssist", ["aoe"] = "ArcaneAoe" },
		fire   = { ["fire"] = "Fire", ["frostfire"] = "FrostFire", ["bdps"] = "NonCombatDps", ["dps assist"] = "DpsAssist", ["aoe"] = "FireAoe" },
		frost  = { ["frost"] = "Frost", ["bmana"] = "NonCombatMana", ["dps assist"] = "DpsAssist", ["aoe"] = "FrostAoe" },
	},
	Paladin = {
		-- 祝福(bsanc/bwisdom/bmight)由顶部动态"祝福"按钮(Seal)指示; 光环(barmor/baoe/bcast)由
		-- 动态"光环"按钮(NonCombatAura)指示——祝福/光环面板内的四个子按钮无渲染点亮逻辑, 不能标记
		prot = { ["prot"] = "Tank", ["tank assist"] = "TankAssist", ["bsanc"] = "Seal", ["bmight"] = "Seal", ["barmor"] = "NonCombatAura" },
		holy = { ["holy"] = "Heal", ["dps assist"] = "DpsAssist", ["healer dps"] = "HealerDps", ["bwisdom"] = "Seal", ["bcast"] = "NonCombatAura" },
		ret  = { ["ret"] = "Dps", ["dps assist"] = "DpsAssist", ["bmight"] = "Seal", ["baoe"] = "NonCombatAura" },
	},
	Hunter = {
		bm   = { ["dps assist"] = "DpsAssist", ["bdps"] = "NonCombatDps" },
		mm   = { ["dps assist"] = "DpsAssist", ["bdps"] = "NonCombatDps" },
		surv = { ["dps assist"] = "DpsAssist", ["bdps"] = "NonCombatDps" },
	},
	Rogue = {
		combat   = { ["dps assist"] = "DpsAssist", ["boost"] = "Boost" },
		assassin = { ["dps assist"] = "DpsAssist", ["boost"] = "Boost" },
	},
	Shaman = {
		ele   = { ["ele"] = "Caster", ["dps assist"] = "DpsAssist", ["aoe"] = "CasterAoe" },
		resto = { ["resto"] = "Heal", ["dps assist"] = "DpsAssist", ["healer dps"] = "HealerDps" },
		enh   = { ["enh"] = "Melee", ["dps assist"] = "DpsAssist", ["aoe"] = "MeleeAoe" },
	},
	Warlock = {
		affli  = { ["dps assist"] = "DpsAssist" },
		demo   = { ["dps assist"] = "DpsAssist", ["meta melee"] = "MetaMelee" },
		destro = { ["dps assist"] = "DpsAssist" },
	},
	Warrior = {
		prot = { ["prot"] = "Tank", ["tank assist"] = "TankAssist" },
		arms = { ["dps assist"] = "DpsAssist" },
		fury = { ["dps assist"] = "DpsAssist" },
	},
}

-- 从 combat 策略串推断天赋档
MultiBot.InferStrategySpec = function(pClass, pCombat)
	local rules = MultiBot.StrategySpecRules[pClass]
	if(rules == nil) then return nil end
	for _, rule in ipairs(rules) do
		if(MultiBot.hasStrategy(pCombat, rule[1])) then return rule[2] end
	end
	return nil
end

-- 天赋档中文显示名: 绿点 tooltip 里标明"这套默认策略是按哪一系算出来的",
-- 便于发现"换了天赋但策略/标记仍是旧档"的情况。
MultiBot.StrategySpecLabels = {
	Priest      = { disc = "戒律", holy = "神圣", shadow = "暗影" },
	DeathKnight = { blood = "鲜血", frost = "冰霜", unholy = "邪恶" },
	Druid       = { balance = "平衡", resto = "恢复", cat = "野性(猫)", bear = "野性(熊)" },
	Mage        = { arcane = "奥术", fire = "火焰", frost = "冰霜", frostfire = "霜火" },
	Paladin     = { prot = "防护", holy = "神圣", ret = "惩戒" },
	Hunter      = { bm = "野兽掌握", mm = "射击", surv = "生存" },
	Rogue       = { combat = "战斗", assassin = "刺杀" },
	Shaman      = { ele = "元素", resto = "恢复", enh = "增强" },
	Warlock     = { affli = "痛苦", demo = "恶魔", destro = "毁灭" },
	Warrior     = { prot = "防护", arms = "武器", fury = "狂怒" },
}

-- 给按钮打默认策略标记: 左上角绿色小点 + tooltip 追加说明(只追加一次)
MultiBot.MarkDefaultStrategyButton = function(pButton, pSpecLabel)
	if(pButton.defaultMark) then return end
	pButton.defaultMark = true

	local dotSize = math.max(4, math.floor(pButton.size * 0.18))
	local dot = pButton:CreateTexture(nil, "OVERLAY")
	dot:SetTexture("Interface\\Buttons\\White8x8")
	dot:SetVertexColor(0.20, 0.95, 0.45, 1)
	dot:SetPoint("TOPLEFT", pButton, "TOPLEFT", 2, -2)
	dot:SetSize(dotSize, dotSize)
	pButton.defaultDot = dot

	if(type(pButton.tip) == "string") then
		if(not string.find(pButton.tip, "出厂默认", 1, true)) then
			local specTxt = ""
			if(pSpecLabel ~= nil and pSpecLabel ~= "") then specTxt = " · 天赋:" .. tostring(pSpecLabel) end
			pButton.tip = pButton.tip .. "\n|cff2ecc71◆ 出厂默认策略" .. specTxt .. "(按天赋出厂加载; 绿点不代表当前开启)|r"
		end
	end
end

-- 入口: 策略条渲染完成后调用(MultiBotHandler 收到 "Strategies: " 响应处)
MultiBot.MarkDefaultStrategies = function(pFrame, pClass, pCombat, pNormal)
	local classTable = MultiBot.StrategyDefaults[pClass]
	if(classTable == nil) then return end

	local botName = tostring(pFrame.name or "?")
	-- FIX(2026-11-14 三轮): 绿点只锚定"真实天赋", 彻底取消栈推断回退。
	-- 11-14 13:32 实测: 检测静默失败时回退 InferStrategySpec(从当前栈反推), 惩戒骑士点坦克
	-- 后栈=prot → 被当防护天赋 → Tank/TankAssist 误打绿点——正是用户报告的现象。
	-- 原则(UI 真实性): 拿不到机器人真实天赋就坚决不打绿点(宁可没有, 不可标错)。
	-- FIX(2026-11-15 十一轮): 变量来源定型为"手动录入 + 书按钮切换", NotifyInspect 自动
	-- 观察检测已移除(见 MultiBotTalentDetect.lua 头注释); 无变量 → 无绿点。
	-- 录入入口: Ctrl+左键点击机器人头像按钮(Units 列表)。
	local spec = nil
	local tRawSpec = nil
	local tTalent = MultiBot.TalentCache ~= nil and MultiBot.TalentCache[botName] or nil
	if(tTalent ~= nil and tTalent.spec ~= nil) then
		tRawSpec = tTalent.spec
		-- FIX(2026-11-16 十五轮): 变量存原始 key(frostfire/emo/as), 绿点按档位查表,
		-- 此处换算(frostfire→fire 等; 映射表由 TalentDetect 暴露为 MultiBot.TalentSpecMap)
		spec = (MultiBot.TalentSpecMap and MultiBot.TalentSpecMap[tRawSpec]) or tRawSpec
	end
	-- 德鲁伊野性系: 天赋面板只有一栏(Feral Combat), 缓存值 "feral" 需按栈里的 cat/bear 细分
	if(spec == "feral") then
		if(MultiBot.hasStrategy(pCombat, "cat")) then spec = "cat"
		elseif(MultiBot.hasStrategy(pCombat, "bear")) then spec = "bear"
		else spec = nil end
	end

	-- 记录本次诊断, 便于后续扩展(斜杠命令/其它模块读取)
	MultiBot.lastStrategyDiagnostic = { name = botName, class = pClass, spec = spec }

	-- FIX(2026-11-11): 推断不出天赋档 = 策略栈里没有任何该职业的天赋特征策略。
	-- 常见成因: ① 机器人存有手动策略(playerbots_db_store), 上线时 PlayerbotRepository::Load
	-- 会 ClearStrategies + 整栈替换, 把出厂默认盖掉; ② 刚换过天赋, 而服务端没有天赋变更监听。
	-- 这两种情况最容易让人误以为"天赋换了策略也该跟着变", 故给一次不刷屏的提示。
	if(spec == nil) then
		MultiBot._specHintAt = MultiBot._specHintAt or {}
		local now = time()
		if((MultiBot._specHintAt[botName] or 0) + 120 < now) then
			MultiBot._specHintAt[botName] = now
			if(DEFAULT_CHAT_FRAME) then
				-- FIX(2026-11-16 十二轮): 文案更新——自动观察检测已移除(十一轮),
				-- "靠近自动重试"不再成立; 指引用户走两个权威写入源
				DEFAULT_CHAT_FRAME:AddMessage("|cffffaa00[MultiBot 策略]|r " .. botName
					.. ": 尚未设置天赋变量, 绿点(出厂默认策略标记)暂不显示——Ctrl+左键点击该机器人头像可录入, 书按钮确认切换天赋也会自动设置。")
			end
		end
		return
	end

	local list = classTable[spec]
	if(list == nil) then return end

	-- 十五轮: 优先按原始 key 取显示名(霜火法显示"霜火"而非档位名"火焰"), 回退档位名
	local tLabels = MultiBot.StrategySpecLabels[pClass]
	local specLabel = (tLabels and (tLabels[tRawSpec] or tLabels[spec])) or spec
	-- FIX(2026-11-16 十三轮): 暗态绿点——默认策略即使被手动关闭(不在策略栈里)也标点。
	-- 条件性默认在暗态时无法确认服务端是否真加载 → 仍只在栈里出现时才标(宁可没有不可标错):
	--   healer dps: IsRestrictedHealerDPSMap 受限地图不加(AiFactory.cpp:415)
	--   boost: 仅 solo/随机 bot 未组队时加(AiFactory.cpp:419-424)
	--   法师 fire 档 fire/frostfire: 按 HasSpell(霜火箭)+HasAura(冰霜碎片) 二选一(AiFactory.cpp:313)
	local tDarkSkip = { ["healer dps"] = true, ["boost"] = true }
	for strat, btnName in pairs(list) do
		local tInStack = MultiBot.hasStrategy(pCombat, strat) or MultiBot.hasStrategy(pNormal, strat)
		local tConditional = tDarkSkip[strat]
			or (pClass == "Mage" and spec == "fire" and (strat == "fire" or strat == "frostfire"))
		-- FIX(2026-11-17 三十七轮): 法师 AOE 默认策略 "aoe" 有两个按钮——火法 FireAoe / 霜火 FrostFireAoe。
		-- 旧表把 aoe 写死给 FireAoe, 霜火法会出现"FireAoe 暗着却带绿点、真正亮的 FrostFireAoe 没绿点"。
		-- 按当前战斗栈里的树名选择按钮(栈是服务端权威状态), 只要 aoe 在栈里就说明该树默认带 AOE。
		local tBtnName = btnName
		if(pClass == "Mage" and strat == "aoe") then
			tBtnName = MultiBot.hasStrategy(pCombat, "frostfire") and "FrostFireAoe" or "FireAoe"
		end
		if(tInStack or not tConditional) then
			local tButton = pFrame.getButton(tBtnName)
			if(tButton ~= nil) then
				MultiBot.MarkDefaultStrategyButton(tButton, specLabel)
			end
		end
	end
end
