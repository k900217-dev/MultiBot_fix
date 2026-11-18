MultiBot.CLEAR = function(pString, pAmount, o1, o2, o3)
	for i = 1, pAmount, 1 do
		if(o1 == nil) then
			pString = MultiBot.doReplace(pString, "|cff%w%w%w%w%w%w", "")
			pString = MultiBot.doReplace(pString, "|h", "")
			pString = MultiBot.doReplace(pString, "|r", "")
		else
			if(o1 ~= nil) then pString = MultiBot.doReplace(pString, o1, "") end
			if(o2 ~= nil) then pString = MultiBot.doReplace(pString, o1, "") end
			if(o3 ~= nil) then pString = MultiBot.doReplace(pString, o1, "") end
		end
	end

	return pString
end

MultiBot.CASE = function(pCondition, pDefault, oCase1, oCase2, oCase3, oCase4, oCase5, oCase6, oCase7, oCase8, oCase9)
	if(pCondition == 1 and oCase1 ~= nil) then return oCase1 end
	if(pCondition == 2 and oCase2 ~= nil) then return oCase2 end
	if(pCondition == 3 and oCase3 ~= nil) then return oCase3 end
	if(pCondition == 4 and oCase4 ~= nil) then return oCase4 end
	if(pCondition == 5 and oCase5 ~= nil) then return oCase5 end
	if(pCondition == 6 and oCase6 ~= nil) then return oCase6 end
	if(pCondition == 7 and oCase7 ~= nil) then return oCase7 end
	if(pCondition == 8 and oCase8 ~= nil) then return oCase8 end
	if(pCondition == 9 and oCase9 ~= nil) then return oCase9 end
	return pDefault
end

MultiBot.IF = function(pCondition, pSuccess, pFailure)
	if(pCondition) then return pSuccess else return pFailure end
end

MultiBot.doSlash = function(pCommand, pArguments)
	local tCommand = string.upper(string.sub(pCommand, 2))

	for tKey, tFunc in pairs(SlashCmdList) do
		if(tKey == tCommand) then
			tFunc(pArguments)
			return true
		end
	end

	SendChatMessage(MultiBot.info.command, "SAY")
	return false
end

MultiBot.doDot = function(pCommand, oArguments)
	SendChatMessage(pCommand .. " " .. oArguments)
	return false
end

MultiBot.doDotWithTarget = function(pCommand, oArguments)
	local tName = UnitName("target")

	if(tName ~= nil and tName ~= "Unknown Entity") then
		if(oArguments ~= nil)
		then SendChatMessage(pCommand .. " " .. tName .. " " .. oArguments)
		else SendChatMessage(pCommand .. " " .. tName)
		end

		return true
	end

	SendChatMessage(MultiBot.info.target, "SAY")
	return false
end

MultiBot.doSplit = function(pString, pPattern)
    if not pString or pString == "" then -- Secure function if pString empty
        return {}
    end
	local tResult = {}
	local tStart = 1
	local tFrom, tTo = string.find(pString, pPattern, tStart)

	while tFrom do
		table.insert(tResult, string.sub(pString, tStart, tFrom - 1))
		tStart = tTo + 1
		tFrom, tTo = string.find(pString, pPattern, tStart)
	end

	table.insert(tResult, string.sub(pString, tStart))
	return tResult
end

MultiBot.doReplace = function(pString, pSearch, pReplace)
	local tFrom, tTo = string.find(pString, pSearch)
	if(tFrom == nil or tTo == nil) then return pString end
	return string.sub(pString, 1, tFrom - 1) .. pReplace .. string.sub(pString, tTo + 1)
end

MultiBot.doRemove = function(pIndex, pName)
	if(pIndex == nil) then return end
	local tFound = 0

	--for i = 1, table.getn(pIndex) do
	for i = 1, #pIndex do
		if(pIndex[i] == pName) then
			tFound = i
			break
		end
	end

	if(tFound == 0) then return false end
	table.remove(pIndex, tFound)
	return true
end

MultiBot.doRepos = function(pIndex, pOffsetX)
	local tButton = MultiBot.frames["MultiBar"].buttons[pIndex]
	local tFrame = MultiBot.frames["MultiBar"].frames[pIndex]
	if(tButton == nil) then tButton = MultiBot.frames["MultiBar"].frames["Left"].buttons[pIndex] end
	if(tFrame == nil) then tFrame = MultiBot.frames["MultiBar"].frames["Left"].frames[pIndex] end
	if(tButton == nil) then tButton = MultiBot.frames["MultiBar"].frames["Right"].buttons[pIndex] end
	if(tFrame == nil) then tFrame = MultiBot.frames["MultiBar"].frames["Right"].frames[pIndex] end
	if(tButton ~= nil) then tButton.setPoint(tButton.x + pOffsetX, tButton.y) end
	if(tFrame ~= nil) then tFrame.setPoint(tFrame.x + pOffsetX, tFrame.y) end
	return true
end

MultiBot.isActive = function(pName)
	for key, value in pairs(MultiBot.index.actives) do if(value == pName) then return true end end
	return false
end

--[[MultiBot.isInside = function(pString, p1stPattern, o2ndPattern, o3rdPattern,
    o4thPattern, o5thPattern, o6thPattern, o7thPattern, o8thPattern, o9thPattern)
	if(pString == nil) then return false end
	if(p1stPattern ~= nil and string.find(pString, p1stPattern)) then return true end
	if(o2ndPattern ~= nil and string.find(pString, o2ndPattern)) then return true end
	if(o3rdPattern ~= nil and string.find(pString, o3rdPattern)) then return true end
	if(o4thPattern ~= nil and string.find(pString, o4thPattern)) then return true end
	if(o5thPattern ~= nil and string.find(pString, o5thPattern)) then return true end
	if(o6thPattern ~= nil and string.find(pString, o6thPattern)) then return true end
	if(o7thPattern ~= nil and string.find(pString, o7thPattern)) then return true end
	if(o8thPattern ~= nil and string.find(pString, o8thPattern)) then return true end
	if(o9thPattern ~= nil and string.find(pString, o9thPattern)) then return true end
	return false
end]]--

MultiBot.isInside = function(pString, ...)
	if(pString == nil) then return false end
	for i = 1, select("#", ...) do
		local pattern = select(i, ...)
		if(pattern ~= nil and string.find(pString, pattern)) then
			return true
		end
	end
	return false
end

--[[MultiBot.beInside = function(pString, p1stPattern, o2ndPattern, o3rdPattern,
    o4thPattern, o5thPattern, o6thPattern, o7thPattern, o8thPattern, o9thPattern)
	if(pString == nil) then return false end
	if(p1stPattern ~= nil and nil == string.find(pString, p1stPattern)) then return false end
	if(o2ndPattern ~= nil and nil == string.find(pString, o2ndPattern)) then return false end
	if(o3rdPattern ~= nil and nil == string.find(pString, o3rdPattern)) then return false end
	if(o4thPattern ~= nil and nil == string.find(pString, o4thPattern)) then return false end
	if(o5thPattern ~= nil and nil == string.find(pString, o5thPattern)) then return false end
	if(o6thPattern ~= nil and nil == string.find(pString, o6thPattern)) then return false end
	if(o7thPattern ~= nil and nil == string.find(pString, o7thPattern)) then return false end
	if(o8thPattern ~= nil and nil == string.find(pString, o8thPattern)) then return false end
	if(o9thPattern ~= nil and nil == string.find(pString, o9thPattern)) then return false end
	return true
end]]--

MultiBot.beInside = function(pString, ...)
	if(pString == nil) then return false end
	for i = 1, select("#", ...) do
		local pattern = select(i, ...)
		if(pattern ~= nil and nil == string.find(pString, pattern)) then
			return false
		end
	end
	return true
end

MultiBot.isRoster = function(pRoster, pName)
	for key, value in pairs(MultiBot.index[pRoster]) do if(pName == value) then return true end end
	return false
end

MultiBot.isMember = function(pName)
	-- FIX(2026-11-18 五十轮): 原判据 GetNumRaidMembers() > 5 漏掉 5 人小队转团队(正好 5 人)的情形,
	-- 此时 raid 循环不执行、party 计数为 0, 整队成员都被当成"不在队" →
	-- 刷新时对已在队的机器人重复发 .playerbot bot add 再 /invite, 客户端报"他们不能加入我们的队伍"。
	if(pName == nil) then return false end

	local tRaid = GetNumRaidMembers()
	if(tRaid > 0) then
		for i = 1, tRaid do
			if(UnitName("raid" .. i) == pName) then return true end
		end
	end

	local tParty = GetNumPartyMembers()
	for i = 1, tParty do
		if(UnitName("party" .. i) == pName) then return true end
	end

	if(UnitName("player") == pName) then
		return true
	end

	return false
end

MultiBot.isTarget = function()
	local tName = UnitName("target")

	if(tName ~= nil and tName ~=  "Unknown Entity") then
		return true
	end

	SendChatMessage(MultiBot.info.target, "SAY")
	return false
end

MultiBot.isUnit = function(pUnit)
	local tName = UnitName(pUnit)

	if(tName == nil or tName == "Unknown Entity") then
		return false
	end

	return true
end

-- Safe texture resolver to avoid calling string.sub on nil and to normalize paths
-- Returns a usable texture path string. Falls back to the question mark icon.
MultiBot.SafeTexturePath = function(pTexture)
	-- Guard: nil or non-string => fallback
	if type(pTexture) ~= "string" or pTexture == "" then
		return "Interface\\Icons\\INV_Misc_QuestionMark"
	end
	-- Si l’appelant fournit déjà un chemin (avec / ou \), on le considère explicite
	-- et on le renvoie tel quel, après normalisation vers "\"
    local tex = pTexture:gsub("/", "\\")
	if tex:find("\\", 1, true) then
		return tex
	end
	-- Normalize: only prefix when not already an Interface path
	local head = string.sub(tex, 1, 9)
	local needsPrefix = string.lower(head) ~= "interface"
	if needsPrefix then
        return "Interface\\Icons\\" .. tex
	end
    return tex
end



-- 四十九轮: 自绘 FontString 统一改用客户端本地字体。
-- 原 "Fonts\\ARIALN.ttf" 没有中文字形 → 背包/法术书/天赋面板里的中文标题与法术名显示成"?"
-- (tooltip 走 GameFontNormal, 所以悬浮正常)。STANDARD_TEXT_FONT 在 zhCN=Fonts\ARKai_T.ttf,
-- enUS=Fonts\FRIZQT__.TTF, 与客户端语言一致。
MultiBot.GetUIFont = function()
	local tFont = nil
	if(type(STANDARD_TEXT_FONT) == "string" and STANDARD_TEXT_FONT ~= "") then
		tFont = STANDARD_TEXT_FONT
	end
	if(tFont == nil and GameFontNormal ~= nil and GameFontNormal.GetFont ~= nil) then
		tFont = select(1, GameFontNormal:GetFont())
	end
	return tFont or "Fonts\\ARIALN.ttf"
end

--[[MultiBot.toClass = function(pClass)
	local pLower = string.lower(pClass)
	local pStart = string.sub(pLower, 1, 5)

	for i = 1, 10 do
		local tOutput = MultiBot.data.classes.output[i]
		local tInput = MultiBot.data.classes.input[i]
		local tLower = string.lower(tInput)
		local tStart = string.sub(tLower, 1, 5)

		if(pClass == tInput) then return tOutput end
		if(pLower == tLower) then return tOutput end
		if(pStart == tStart) then return tOutput end
	end

	local tClass = string.lower(string.sub(pClass, 1, 1) .. string.sub(pClass, 4, 4))
	if(tClass == "te" or tClass == "dt") then return "DeathKnight" end
	if(tClass == "di" or tClass == "di") then return "Druid" end
	if(tClass == "jg" or tClass == "ht") then return "Hunter" end
	if(tClass == "mi" or tClass == "me") then return "Mage" end
	if(tClass == "pa" or tClass == "pa") then return "Paladin" end
	if(tClass == "pe" or tClass == "pe") then return "Priest" end
	if(tClass == "su" or tClass == "ru") then return "Rogue" end
	if(tClass == "sa" or tClass == "sm") then return "Shaman" end
	if(tClass == "he" or tClass == "wl") then return "Warlock" end
	if(tClass == "ke" or tClass == "wr") then return "Warrior" end
	if(pClass == "dk") then return "DeathKnight" end
	return "Unknown"
end]]--

-- Classe refactor
-- Sauvegarde l’ancienne version si elle existait avant refactor
if not MultiBot._toClass_legacy and type(MultiBot.toClass) == "function" then
  MultiBot._toClass_legacy = MultiBot.toClass
end

-- Nouvelle version avec fallback
MultiBot.toClass = function(pClass)
  if MultiBot.NormalizeClass then
    local canon = MultiBot.NormalizeClass(pClass)
    if canon then return canon end
  end
  if MultiBot._toClass_legacy then
    return MultiBot._toClass_legacy(pClass)
  end
  return "Unknown"
end

MultiBot.toUnit = function(pName)
	-- FIX(2026-11-18 五十四轮): 原判据 GetNumRaidMembers() > 5 漏掉正好 5 人的团队,
	-- 此时 raid 循环不执行、party 计数为 0 → 返回 nil, 天赋按钮误报"超出范围"。
	local tRaid = GetNumRaidMembers()
	if(tRaid > 0) then
		for i = 1, tRaid do
			if(UnitName("raid" .. i) == pName) then
				return "raid" .. i
			end
		end
	end

	if(GetNumPartyMembers() > 0) then
		for i = 1, GetNumPartyMembers() do
			if(UnitName("party" .. i) == pName) then
				return "party" .. i
			end
		end
	end

	if(UnitName("player") == pName) then
		return "player"
	end

	return nil
end

-- 职业缓存(2026-11-16 十四轮): 3.3.5 客户端对离线好友的职业一律返回 Unknown
-- (客户端限制, 服务端 roster 也只带本账号角色的职业, 随机账号机器人不覆盖)。
-- 在线时把真实职业写入 MultiBotDB.botClass(与 botSpec 同一存档, 跨登录持久),
-- 离线显示 Unknown 时回退缓存。局限: 从未上线过的机器人首次仍显示 Unknown。
MultiBot.ClassCacheSet = function(pName, pClass)
	if(pName == nil or pName == "" or pClass == nil or pClass == "Unknown") then return end
	if(MultiBotDB ~= nil) then
		MultiBotDB.botClass = MultiBotDB.botClass or {}
		MultiBotDB.botClass[pName] = pClass
	end
end

MultiBot.ClassCacheGet = function(pName)
	if(pName ~= nil and MultiBotDB ~= nil and MultiBotDB.botClass ~= nil) then
		return MultiBotDB.botClass[pName]
	end
	return nil
end

MultiBot.toTip = function(pClass, pLevel, pName)
	-- 十四轮: 职业显示本地化(内部注册名 Paladin → 客户端语言职业名, zhCN=圣骑士)
	local tDisplay = (MultiBot.GetClassDisplay and MultiBot.GetClassDisplay(pClass)) or pClass
	-- 十六轮: 职业后追加天赋变量中文名(职业后面、姓名前面), 与录入下拉/书按钮同源。
	-- 无变量不显示(宁可没有, 不可标错); 查不到中文名时显示原始 key(真实存储值)。
	local tSpec = (MultiBot.GetTalentSpecDisplay and MultiBot.GetTalentSpecDisplay(pName, pClass)) or nil
	if(tSpec ~= nil) then tDisplay = tDisplay .. "(" .. tSpec .. ")" end
	local tTip = tDisplay .. " - "
	if(pLevel ~= nil) then tTip = tTip .. pLevel .. " - " end
	tTip = tTip .. pName .. MultiBot.tips.unit.button
	tTip = MultiBot.doReplace(tTip, "NAME", pName)
	tTip = MultiBot.doReplace(tTip, "NAME", pName)
	tTip = MultiBot.doReplace(tTip, "NAME", pName)
	return tTip
end

-- FIX(2026-11-17 四十轮): Alt+左键 = 只刷新这一行机器人的策略名单。
-- 等价"单位控制按钮右键"里的 RefreshStrategiesFor 单人版: 只对该机器人发 co ? 查询,
-- 服务端回 "Strategies: ..." 后该行按钮重新渲染; 其他机器人不受影响。
-- 自身角色(UnitName("player"))不消费, 交回原 doLeft。
MultiBot.RefreshBotByName = function(pName)
	if(pName == nil or pName == "") then return false end
	if(pName == UnitName("player")) then return false end
	if(MultiBot.SendQuery ~= nil) then
		MultiBot.SendQuery(pName, "co ?", "CO")
	else
		SendChatMessage("co ?", "WHISPER", nil, pName)
	end
	return true
end

MultiBot.OnButtonAltClick = function(pButton)
	if(pButton == nil or pButton.name == nil or pButton.class == nil) then return false end
	return MultiBot.RefreshBotByName(pButton.name)
end

--[[MultiBot.toPoint = function(pFrame)
	local tX = pFrame:GetRight()
	local tY = pFrame:GetBottom()
	local tResolution = MultiBot.doSplit(({ GetScreenResolutions() })[GetCurrentResolution()], "x")
	local tHeight = tonumber(tResolution[2])
	local tWidth = tonumber(tResolution[1])
	local tScale = 1 / tWidth * MultiBot:GetRight()
	return math.floor(tX - (tWidth * tScale)), math.floor(tY)
end]]--

MultiBot.toPoint = function(pFrame)
    -- Mesurer par rapport au parent global stable et arrondir à l’unité.
    local uiRight = (UIParent and UIParent:GetRight()) or GetScreenWidth()
    local xRight  = pFrame:GetRight() or 0
    local yBottom = pFrame:GetBottom() or 0
    -- Offset vers BOTTOMRIGHT (négatif ou nul)
    local offX = xRight - uiRight
    local offY = yBottom
    -- Arrondi au plus proche pour éviter la dérive cumulée
    return math.floor(offX + 0.5), math.floor(offY + 0.5)
end

MultiBot.RaidPool = function(pUnit, oWho)
	if(pUnit ~= "player" and MultiBot.getBot(pUnit) == nil) then return end

	local tGender = MultiBot.CASE(UnitSex(pUnit), "[U]", "[N]", "[M]", "[F]")
	local tLocalClass, tClass = UnitClass(pUnit)
	local tLocalRace, tRace = UnitRace(pUnit)
	local tLevel = UnitLevel(pUnit)
	local tName = UnitName(pUnit)
	local tIndex = { 4, 5, 6 }
	local tTabs = {}
	--local tScore = ""
	local tScore

	if(oWho ~= nil) then
		local tWho = MultiBot.CLEAR(oWho, 20)
		tWho = MultiBot.doReplace(tWho, "beast mastery", "Beast-Mastery")
		tWho = MultiBot.doReplace(tWho, "feral combat", "Feral-Combat")
		tWho = MultiBot.doReplace(tWho, "Blood Elf", "Blood-Elf")
		tWho = MultiBot.doReplace(tWho, "Night Elf", "Night-Elf")

		tParts = MultiBot.doSplit(tWho, ", ")
		tSpace = MultiBot.doSplit(tParts[1], " ")
		tScore = MultiBot.doSplit(tParts[2], " ")[1]

		if(MultiBot.isInside(tSpace[5], "/")) then tIndex = { 5, 6, 7 } else
		if(MultiBot.isInside(tSpace[6], "/")) then tIndex = { 6, 7, 8 } else
		if(MultiBot.isInside(tSpace[7], "/")) then tIndex = { 7, 8, 9 }
		end end end

		tTabs = MultiBot.doSplit(strsub(tSpace[tIndex[1]], 2, strlen(tSpace[tIndex[1]]) - 1), "/")

		if(tGender == nil) then tGender = tSpace[2] end
		if(tClass == nil) then tClass = MultiBot.toClass(tSpace[tIndex[2]]) end
		if(tRace == nil) then tRace = tSpace[1] end
		if(tName == nil) then tName = pUnit end
		if(tLevel == nil) then tLevel = substr(MultiBot.doSplit(tSpace[tIndex[3]], " ")[1], 2) end
	else
		tScore = MultiBot.ItemLevel(pUnit)
		tTabs[1] = GetNumTalents(1)
		tTabs[2] = GetNumTalents(2)
		tTabs[3] = GetNumTalents(3)
	end

	   --[[-- [SAFETY] tTabs doivent être numériques
       tTabs[1] = tonumber(tTabs[1]) or 0
       tTabs[2] = tonumber(tTabs[2]) or 0
       tTabs[3] = tonumber(tTabs[3]) or 0

       -- [SAFETY] iLevel : toujours un nombre, même si tScore est vide ou textuel
       local iLevel = nil
       do
         if type(tScore) == "number" then
           iLevel = tScore
           tScore = tostring(tScore)               -- on garde tScore chaîne pour l’enregistrement final
         elseif type(tScore) == "string" then
           -- prend le DERNIER nombre trouvé dans la chaîne (ex: "GS: 5120" -> 5120)
           for d in string.gmatch(tScore, "(%d+)") do iLevel = tonumber(d) end
         end
         if not iLevel then iLevel = tonumber(tLevel) end
         if not iLevel then iLevel = (UnitLevel and UnitLevel(pUnit)) or 0 end
       end]]--

	-- [SAFETY] tTabs doivent être numériques
	tTabs[1] = tonumber(tTabs[1]) or 0
	tTabs[2] = tonumber(tTabs[2]) or 0
	tTabs[3] = tonumber(tTabs[3]) or 0

	local tTabIndex = MultiBot.IF(tTabs[3] > tTabs[2] and tTabs[3] > tTabs[1], 3, MultiBot.IF(tTabs[2] > tTabs[3] and tTabs[2] > tTabs[1], 2, 1))
	local tSpecial = MultiBot.CLEAR(MultiBot.info.talent[MultiBot.toClass(tClass) .. tTabIndex], 1)

	if(tLocalClass == nil) then tLocalClass = tClass end
	if(tLocalRace == nil) then tLocalRace = tRace end

	MultiBotGlobalSave[tName] =  tLocalRace .. "," .. tGender .. "," .. tSpecial .. "," .. tTabs[1] .. "/" .. tTabs[2] .. "/" .. tTabs[3] .. "," .. tLocalClass .. "," .. tLevel .. "," .. tScore
end

--[[MultiBot.ItemLevel = function(pUnit)
	local tTitan = IsSpellKnown(49152) -- Titan's Grip
	local tCount = 16
	local tScore = 0

	for i = 1, 18, 1 do
		local tItem = GetInventoryItemLink(pUnit, i)
		if(tItem ~= nil and i ~= 4) then
			--local iName, iLink, iRare, iLevel, iMinLevel, iType, iSubType, iStack, iEquipLoc = GetItemInfo(tItem)
			local _, _, _, iLevel, _, _, _, _, iEquipLoc = GetItemInfo(tItem)
			if((i == 16 and iEquipLoc ~= "INVTYPE_2HWEAPON") or (i == 16 and tTitan) or (i == 17)) then tCount = 17 end
			tScore = tScore + iLevel
		end
	end

	return floor(tScore / tCount), tCount
end--]]

-- New Score formula
MultiBot.ItemLevel = function(pUnit)
	-- Calcule un “ilvl moyen” dans l’esprit de GetAverageItemLevel :
	--  - les slots vides comptent comme ilvl 0 (on divise toujours par 16 ou 17)
	--  - 2M sans Titan's Grip : 16 slots (pas d’off-hand possible)
	--  - 1M / 2x1M / 2M avec Titan's Grip : 17 slots (main + off-hand)
	--  - on garde la même plage de slots que le code d’origine (1..18) et on ignore la chemise.

	local hasTitanGrip = IsSpellKnown and IsSpellKnown(49152) or false

	local hasMainHand  = false
	local mainIs2H     = false
	local hasOffhand   = false

	local score = 0

	for slot = 1, 18 do
		-- On ignore la chemise (slot 4)
		if slot ~= 4 then
			local link = GetInventoryItemLink(pUnit, slot)
			if link then
				local _, _, _, iLevel, _, _, _, _, equipLoc = GetItemInfo(link)
				iLevel = iLevel or 0

				-- Gestion des slots arme principale / main gauche
				if slot == 16 then
					hasMainHand = true
					if equipLoc == "INVTYPE_2HWEAPON" then
						mainIs2H = true
					end
				elseif slot == 17 then
					hasOffhand = true
				end

				score = score + iLevel
			end
		end
	end

	-- Nombre de slots "théoriques" comme le client :
	--  - 16 si 2M sans Titan's Grip
	--  - 17 dès qu’un off-hand est possible ou présent
	local count = 16
	if (hasMainHand and not mainIs2H) or (hasMainHand and hasTitanGrip) or hasOffhand then
		count = 17
	end

	if count <= 0 then
		return 0, 0
	end

	return floor(score / count), count
end

MultiBot.SavePortal = function(pButton)
	local tSave = MultiBot.IF(pButton.goMap == nil, "", pButton.goMap)
	tSave = tSave .. ";" .. (math.ceil(pButton.goX * 1000) / 1000)
	tSave = tSave .. ";" .. (math.ceil(pButton.goY * 1000) / 1000)
	tSave = tSave .. ";" .. (math.ceil(pButton.goZ * 1000) / 1000)
	tSave = tSave .. ";" .. pButton.tip
	tSave = tSave .. ";" .. MultiBot.IF(pButton.state, 1, 0)
	return tSave
end

MultiBot.LoadPortal = function(pButton, pValue)
	local tValue = MultiBot.doSplit(pValue, ";")
	pButton.goMap = tonumber(tValue[1])
	pButton.goX = tonumber(tValue[2])
	pButton.goY = tonumber(tValue[3])
	pButton.goZ = tonumber(tValue[4])
	pButton.tip = tValue[5]
	if(tValue[6] == "1")
	then pButton.setEnable()
	else pButton.setDisable()
	end
end

MultiBot.SpellToMacro = function(pName, pSpell, pTexture)
	--local tGlobal, tAmount = GetNumMacros()
	local _, tAmount = GetNumMacros()

	if(pSpell == nil or pSpell == 0) then
		return SendChatMessage(MultiBot.info.spell, "SAY")
	end
	if(tAmount == 18) then
		return SendChatMessage(MultiBot.info.macro, "SAY")
	end

	local tMacro = string.sub(pName, 1, 14) .. tAmount
	--local tSpell, tIcon, tBody = GetMacroInfo(tMacro)
	local tSpell = GetMacroInfo(tMacro)

	if(tSpell == nil) then
		-- Sécurité : si l’icône n’est pas définie dans MultiBot.spellbook.icons,
		-- on utilise une icône par défaut (index 1).
		local icon = 1
		if MultiBot.spellbook and MultiBot.spellbook.icons then
			icon = MultiBot.spellbook.icons[pTexture] or 1
		end
		CreateMacro(tMacro, icon, "/t " .. pName .. " cast " .. pSpell, true)
	end
	PickupMacro(tMacro)
end

MultiBot.ActionToTarget = function(pAction, oTarget)
	local tName = MultiBot.IF(oTarget == nil, UnitName("target"), oTarget)

	if(tName ~= nil and tName ~= "Unknown Entity") then
		-- LOG(2026-11-12): 策略类 whisper 指令(co/nc/de 开头)写入通信日志
		-- (面板: /mblog), 只记发送, 不拦截指令本身。仅在调试记录模式(设置面板勾选)下生效。
		if(MultiBot.CommLogEnabled and MultiBot.AddCommLog ~= nil and MultiBot.IsStrategyCommand ~= nil and MultiBot.IsStrategyCommand(pAction)) then
			MultiBot.AddCommLog("send", tName, pAction)
		end
		SendChatMessage(pAction, "WHISPER", nil, tName)
		return true
	end

	SendChatMessage(MultiBot.info.target, "SAY")
	return false
end

MultiBot.ActionToTargetOrGroup = function(pAction)
	local tName = UnitName("target")

	if(tName ~= nil and tName ~= "Unknown Entity") then
		SendChatMessage(pAction, "WHISPER", nil, tName)
		return true
	end

	if(GetNumRaidMembers() > 5) then
		SendChatMessage(pAction, "RAID")
		return true
	end

	if(GetNumPartyMembers() > 0) then
		SendChatMessage(pAction, "PARTY")
		return true
	end

	SendChatMessage(MultiBot.info.neither, "SAY")
	return false
end

MultiBot.ActionToGroup = function(pAction)
	if(GetNumRaidMembers() > 5) then
		SendChatMessage(pAction, "RAID")
		return true
	end

	if(GetNumPartyMembers() > 0) then
		SendChatMessage(pAction, "PARTY")
		return true
	end

	SendChatMessage(MultiBot.info.group, "SAY")
	return false
end

MultiBot.SelectToTarget = function(pParent, pIndex, pTexture, pAction, oTarget)
	-- FIX(2026-11-14 二轮): 同 OnOffActionToTarget, 剥离 ",?" 并走防抖全量查询, 避免应答错位污染 waitFor 阶段
	pAction = string.gsub(pAction or "", ",%s*%?$", "")
	if(MultiBot.ActionToTarget(pAction, oTarget)) then
		local tFrame = pParent.frames[pIndex]
		local tButton = pParent.buttons[pIndex]
		tButton.setTexture(pTexture)
		tFrame:Hide()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(tFrame) end
		local tName = oTarget
		if(tName == nil or tName == "") then tName = UnitName("target") end
		MultiBot.ScheduleStrategyRefresh(tName)
		return true
	end

	return false
end

MultiBot.SelectToTargetButton = function(pParent, pIndex, pTexture, pAction, oTarget)
	local tFrame = pParent.frames[pIndex]
	local tButton = pParent.buttons[pIndex]
	tButton.doLeft = function(pButton) MultiBot.ActionToTarget(pAction, oTarget) end
	tButton.setTexture(pTexture)
	tFrame:Hide()
	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(tFrame) end
	return true
end

MultiBot.SelectToGroupButtonWithTarget = function(pParent, pIndex, pTexture, pAction)
	local tFrame = pParent.frames[pIndex]
	local tButton = pParent.buttons[pIndex]
	tButton.doLeft = function(pButton) if(MultiBot.isTarget()) then MultiBot.ActionToGroup(pAction) end end
	tButton.setTexture(pTexture)
	tFrame:Hide()
	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(tFrame) end
	return true
end

MultiBot.SelectToGroupButton = function(pParent, pIndex, pTexture, pAction)
	local tFrame = pParent.frames[pIndex]
	local tButton = pParent.buttons[pIndex]
	tButton.doLeft = function(pButton) MultiBot.ActionToGroup(pAction) end
	tButton.setTexture(pTexture)
	tFrame:Hide()
	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(tFrame) end
	return true
end

MultiBot.SelectToGroup = function(pParent, pIndex, pTexture, pAction)
	if(MultiBot.ActionToGroup(pAction)) then
		local tFrame = pParent.frames[pIndex]
		local tButton = pParent.buttons[pIndex]
		tButton.setTexture(pTexture)
		tFrame:Hide()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(tFrame) end
		return true
	end

	return false
end

MultiBot.Select = function(pParent, pIndex, pTexture)
	local tFrame = pParent.frames[pIndex]
	local tButton = pParent.buttons[pIndex]
	tButton.setTexture(pTexture)
	tFrame:Hide()
	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(tFrame) end
	return true
end

MultiBot.ShowHideSwitch = function(pFrame)
	if(pFrame:IsVisible()) then
		pFrame:Hide()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(pFrame) end
		return false
	end

	pFrame:Show()
	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(pFrame) end
	return true
end

-- FIX(2026-11-12): 通用整名策略匹配(按逗号分词, 去首尾空格后精确比较)。
-- 服务端 "Strategies: a, b, c" 为逗号+空格分隔。各职业面板同步段原先多用 isInside 子串匹配:
--   "heal"  会误命中 "healer dps" / "offheal"
--   "fire," 会误命中 "frostfire,"
--   "dps"   会误命中 "dps aoe" / "dps assist" / "dps debuff"
--   "tank"  会误命中 "tank assist"
-- 造成互斥按钮被误点亮/或漏亮。涉及策略名判断的同步段统一改用本函数。
MultiBot.hasStrat = function(pList, pName)
	for w in string.gmatch(pList or "", "[^,]+") do
		local token = string.gsub(w, "^%s+", "")
		token = string.gsub(token, "%s+$", "")
		if(token == pName) then return true end
	end
	return false
end

-- FIX(2026-11-12): 互斥组同步。服务端对"主策略"(如牧师 heal/shadow/holy heal/holy dps)
-- 有兄弟策略(sibling)机制, 同一时刻至多一个在栈里; 但面板按钮状态由点击处理局部互灭,
-- 互灭不全时会出现"两个互斥按钮同时亮"的假象。渲染时用本函数强制: 只亮 litName, 组内其余全灭。
-- litName 为 nil 时整组全灭(如机器人当前没有任何主策略)。
MultiBot.SyncExclusiveGroup = function(pFrame, pGroup, pLit)
	for i = 1, #pGroup do
		local btn = pFrame.getButton(pGroup[i])
		if(btn ~= nil) then
			if(pGroup[i] == pLit) then btn.setEnable() else btn.setDisable() end
		end
	end
end

-- FIX(2026-11-14): 根按钮随子列联动(需求: "DPS控制"里任一策略开启, 根按钮亮绿框; 全关才灭)。
-- 规则: 策略面板的子框架(pFrame.frames[X])若存在同名根按钮(pFrame.buttons[X],
-- 如 DpsControl/Playbook), 则子框架内任一按钮 state==true 时根按钮亮绿框, 否则灰。
-- 在每次策略条全量渲染完成后调用(Handler 回信分支 + QueryRetry 超时还原分支)。
MultiBot.SyncRootButtons = function(pFrame)
	if(pFrame == nil or pFrame.frames == nil) then return end
	for name, sub in pairs(pFrame.frames) do
		local root = pFrame.buttons and pFrame.buttons[name]
		if(root ~= nil and root.setEnable ~= nil) then
			local lit = false
			if(sub.buttons ~= nil) then
				for _, btn in pairs(sub.buttons) do
					if(btn.state == true) then lit = true break end
				end
			end
			if(lit) then
				root.setEnable()
			elseif(root.state ~= true) then
				-- 仅在渲染层本就没点亮时才灭: 骑士祝福/光环、DK光环等"动态根按钮"由渲染直接
				-- setEnable(指示当前祝福/光环), SyncRootButtons 不得覆盖它们的亮灭
				root.setDisable()
			end
		end
	end
end

MultiBot.OnOffActionToTarget = function(pButton, pOn, pOff, pTarget)
	-- FIX(2026-11-13): 状态同步去乐观化(要求: UI 必须真实反映服务端策略栈, 不做任何预测性亮灭)。
	-- 旧逻辑: 点击瞬间本地翻转按钮亮灭("乐观切换")。指令未生效时(bot 离线/whisper 丢弃/服务端拒绝),
	-- 按钮停留在错误状态直至下次全量重画——即"点了没生效但还是点亮了"; 互斥按钮也存在双亮窗口。
	-- 新逻辑: 点击后按钮保持点击前状态, 仅压暗(SetAlpha 0.5)表示"指令在途, 未获确认";
	-- 真实亮灭完全由机器人回信 "Strategies: ..." 触发的全量重渲染决定(addButton 重画会 Hide 旧按钮, 压暗自动清除)。
	-- 应答超时由 MultiBotQueryRetry 超限分支按"最近已知栈"重画还原并提示(不存在卡在假状态的面板)。
	-- FIX(2026-11-14 二轮): 剥离指令尾部的 ",?" 询问后缀——切换指令不再请求机器人即时回信。
	-- 根因: 每个机器人只有一个 waitFor 状态位, 而服务端对 co/nc 的应答同为 "Strategies: ..." 格式,
	-- 无法从内容区分归属; 一旦上一条查询链未走完(co ? 已回、nc ? 在途)又发生新的点击/查询,
	-- waitFor 被覆盖, 随后到达的非战斗列表会被 CO 分支误收、写进战斗串, 面板按污染数据重画出假状态。
	-- 因此切换后不依赖切换自带应答, 统一走 ScheduleStrategyRefresh 延迟全量查询(见下,
	-- 五轮: 延迟 1.5s 避开服务端触发器参数覆盖窗口)。
	pOn = string.gsub(pOn or "", ",%s*%?$", "")
	pOff = string.gsub(pOff or "", ",%s*%?$", "")
	-- FIX(2026-11-16 十二轮·主根因): 旧写法 `ActionToTarget(pOff,...) and false or nil`
	-- 是 Lua 陷阱——`true and false or nil` 恒为 nil(x and false or y 永远返回 y)。
	-- 后果: "关"指令成功发出后 tState 恒 nil → 走下方"指令未发出"早退分支 →
	-- 不压暗、不翻转 state、ScheduleStrategyRefresh 从未被调用 = "关了绿框常亮,
	-- 右键才灭; 关不先暗; 再点一次还是发关指令"。11-15 11:31~11:32 CommLog 逐条实证
	-- (三条"关"全无刷新, 第二条 -food 证明 state 未翻转; 右键重画后 +food 的刷新正常)。
	-- "开"分支 `and true or nil` 恰好正常, 故十一轮来"开好用关不好用"。改用显式 if。
	local tState
	if(pButton.state) then
		if(MultiBot.ActionToTarget(pOff, pTarget)) then tState = false end
	else
		if(MultiBot.ActionToTarget(pOn, pTarget)) then tState = true end
	end
	if(tState == nil) then
		-- 指令未发出(无有效目标): 不压暗不预测, 返回点击前的预测值保持调用方兼容
		return not pButton.state
	end
	-- FIX(2026-11-14): 恢复"点一下开/再点一下关"的开关记忆。
	-- 11-13 去乐观化删掉了本地翻转, 但 state 标志也随之不再变化——若应答渲染未发生
	-- (回信丢失/面板未重画), 下一次点击会重复发送同一条指令, 表现为"只有开没有关"。
	-- 现只翻转内部 state 标志(不改视觉, 视觉仍只有"压暗=指令在途");
	-- 真实亮灭依旧由回信渲染/超时还原决定, state 仅是两次点击之间的开关方向记忆。
	pButton.state = tState
	-- 待确认视觉态: 压暗(只影响本次点击的按钮; 重画/还原时随旧按钮一起消失)
	if(pButton.SetAlpha ~= nil) then pButton:SetAlpha(0.5) end
	-- FIX(2026-11-14 二轮): 切换后不再挂 waitFor 等切换自带应答, 改为防抖 0.6s 后统一走
	-- "co ? -> nc ? -> 重画"标准查询链(与右键刷新同一链路, 实测可靠)。
	-- 好处: ①连点多次自动合并为一次最终查询, 面板反映服务端最终真相;
	-- ②查询链在途时 SendQuery 内部自动顺延, 应答永不错位;
	-- ③切换 whisper 若丢失, 查询结果如实还原旧状态(不造假), 再点一次即可。
	if(pTarget ~= nil and pTarget ~= "" and pTarget ~= UnitName("player")) then
		MultiBot.ScheduleStrategyRefresh(pTarget)
	end
	return tState
end

-- FIX(2026-11-14 五轮): 刷新查询延迟 1.5 秒发出——根治"+"切换指令被服务端吞掉。
-- 根因(基线源码 ChatCommandTrigger.cpp:15): 机器人把 whisper 命令存进触发器的"单个 param
-- 字段", 到下一次 AI tick 才执行, 后到的同名命令会直接覆盖先到的参数(param = paramName)。
-- 切换与查询同拍发出时, 查询把切换参数覆盖 → 切换指令从未到达策略引擎。
-- CommLog 14:12 实测: 三次"+"切换全部丢失( warrior 连存档行都没有, 骑士/德鲁伊存档串
-- 无 prot/bear), 而间隔 2 秒的"-tank"成功存档 —— 覆盖窗口 ≈ 机器人 AI tick(~0.5~1s)。
-- 旧"立即发送"(四轮)把窗口开到最大 = 点了完全无反应; 旧 0.6s 防抖大多躲过但不可靠。
-- 1.5s: 切换先在机器人 tick 执行完, 查询再读真实栈, 竞态窗口归零。
-- 排队合并: 见下方十二轮重写(_refreshLastClick 最后点击时刻 + 自续期任务)。
-- FIX(2026-11-15 十轮): 内部调度器 ScheduleAfter——关键延迟任务不再依赖 TimerAfter。
-- 根因(CommLog 11-15 10:42 实测): 10:42:26/10:42:33 两条"关"指令(co -tank assist/co -tank)
-- 都已发出且服务端已生效(10:42:46 查询栈里 prot/tank assist 已消失), 但切换后 1.5s 的延迟
-- 刷新查询从未发出; 43:32 的"开"(邵鼎皓 co +melee)同样无刷新。即 TimerAfter(底层是
-- !!!ClassicAPI 的 C_Timer.After 动画池实现, 与 WeakAuras/Questie/Details 等共用同一全局
-- C_Timer)的定时回调自 10:42:24 后全部静默失效——任务注册成功但 OnFinished 永不触发,
-- 面板从此再无自动重画 = "开了不亮/关了不灭, 必须手动右键刷新"。
-- (2026-11-16 十二轮更正: 十轮把"关"的无刷新也归因于定时器死亡是误诊——
--  真凶是 OnOffActionToTarget 的 `and false or nil` 陷阱, "关"从未调度刷新,
--  见该函数内十二轮注释。ScheduleAfter 本身保留, 它治的是"开"链路的定时器风险。)
-- 方案: 自建常驻 OnUpdate 调度帧(引用挂 MultiBot 表, 永不被 GC, 不经 C_Timer 对象池),
-- 任务带到期时间, 每任务 pcall 隔离, 出错在聊天区提示。TimerAfter 仅作不可用时兜底。
MultiBot._scheduleTasks = MultiBot._scheduleTasks or {}
MultiBot._scheduleSeq = MultiBot._scheduleSeq or 0
MultiBot.ScheduleAfter = function(pDelay, pFn)
	if(type(pFn) ~= "function") then return end
	if(MultiBot._scheduleFrame == nil) then
		local frame = CreateFrame("Frame", nil, UIParent)
		MultiBot._scheduleFrame = frame -- 常驻引用, 防止匿名帧被GC
		frame:SetScript("OnUpdate", function(self)
			local tNow = GetTime()
			local tTasks = MultiBot._scheduleTasks
			for id, task in pairs(tTasks) do
				if(tNow >= task.due) then
					tTasks[id] = nil
					local tOK, tErr = pcall(task.fn)
					if(not tOK) then
						print("|cffff6060[MultiBot]|r 延迟任务执行出错: " .. tostring(tErr))
					end
				end
			end
		end)
	end
	MultiBot._scheduleSeq = MultiBot._scheduleSeq + 1
	MultiBot._scheduleTasks[MultiBot._scheduleSeq] = { due = GetTime() + math.max(pDelay or 0, 0), fn = pFn }
	return MultiBot._scheduleSeq
end

-- FIX(2026-11-16 十二轮): 重写切换后刷新调度——根治"明明已关, 绿框还亮, 右键才灭"。
-- 根因(完整静态梳理, 与十轮修的定时器死亡无关, 是逻辑竞态):
--   ① 误杀: 旧 1.5s 任务带"_refreshQueued 标记被清就中止"守卫, 而 SendQuery 发出
--      任何查询都清该标记——点击时已在途的旧查询链的 nc ? 续段、Hello 查询、
--      右键 Units 根按钮的全员批量刷新, 只要落在 1.5s 窗口内就会清掉标记 →
--      任务到点自杀 → 切换后的查询从未发出 → 面板停留切换前状态(绿框常亮)。
--      连点两个按钮(第一下的刷新链还在途时点第二下)/批量刷新后点开关必现。
--   ② 合并不延期: 旧 3s 合并窗口内第二次点击并入第一次的任务, 任务仍按第一次的
--      时间点发出, 距最后一次切换可能不足 1.5s → 九轮"触发器参数覆盖"竞态复活。
-- 新设计: 每 bot 记录最后点击时刻, 单任务自续期——到点检查"距最后点击是否已满
--   1.5s", 不满按剩余时间续排, 满则必发查询; 任务永不因外部查询而中止。
--   SendQuery 不再触碰刷新标记(职责归任务自身); 在途保护/并发上限仍由 SendQuery
--   负责, 查询最终发出时必然晚于最后一次切换 1.5s+, 两个竞态同时归零。
MultiBot._refreshLastClick = MultiBot._refreshLastClick or {}
MultiBot._refreshTaskOn = MultiBot._refreshTaskOn or {}
MultiBot.ScheduleStrategyRefresh = function(pName)
	if(pName == nil or pName == "" or pName == UnitName("player")) then return end
	MultiBot._refreshLastClick[pName] = GetTime()
	if(MultiBot._refreshTaskOn[pName]) then return end -- 已有自续期任务, 最后点击时刻已更新
	MultiBot._refreshTaskOn[pName] = true
	local function finish()
		MultiBot._refreshLastClick[pName] = nil
		MultiBot._refreshTaskOn[pName] = nil
		if(MultiBot.SendQuery ~= nil) then MultiBot.SendQuery(pName, "co ?", "CO") end
	end
	local function tick()
		local tLast = MultiBot._refreshLastClick[pName]
		if(tLast == nil) then MultiBot._refreshTaskOn[pName] = nil return end
		local tWait = 1.5 - (GetTime() - tLast)
		if(tWait > 0) then
			-- 窗口内又有新点击: 按剩余时间续排, 保证查询晚于最后一次切换 1.5s
			if(type(MultiBot.ScheduleAfter) == "function") then MultiBot.ScheduleAfter(tWait, tick)
			elseif(type(TimerAfter) == "function") then TimerAfter(tWait, tick)
			else finish() end
			return
		end
		finish()
	end
	if(type(MultiBot.ScheduleAfter) == "function") then MultiBot.ScheduleAfter(1.5, tick)
	elseif(type(TimerAfter) == "function") then TimerAfter(1.5, tick)
	else finish() end
end

MultiBot.OnOffSwitch = function(pButton)
	if(pButton.state) then
		pButton.setDisable()
		return false
	end

	pButton.setEnable()
	return true
end

-- CLICK BLOCKER --
-- Fond invisible placé sous les barres de boutons (et leurs zones extensibles) afin
-- d'empêcher les clics de "traverser" l'UI dans les espaces entre boutons.

MultiBot._clickBlockerQueue = MultiBot._clickBlockerQueue or {}

local function _mbQueueClickBlockerUpdate(f)
	if(not f or not f.clickBlocker) then return end
	MultiBot._clickBlockerQueue[f] = true

	if(not MultiBot._clickBlockerTicker) then
		MultiBot._clickBlockerTicker = CreateFrame("Frame", nil, UIParent)
		MultiBot._clickBlockerTicker.running = false
	end

	local t = MultiBot._clickBlockerTicker
	if(t.running) then return end

	t.running = true
	t:SetScript("OnUpdate", function(self)
		self:SetScript("OnUpdate", nil)
		self.running = false

		local queue = MultiBot._clickBlockerQueue
		MultiBot._clickBlockerQueue = {}
		for frame in pairs(queue) do
			if(MultiBot.UpdateClickBlocker) then
				MultiBot.UpdateClickBlocker(frame)
			end
		end
	end)
end

-- Demande une mise à jour pour le frame et tous ses parents MultiBot.newFrame (cascade).
function MultiBot.RequestClickBlockerUpdate(frame)
	local f = frame
	while(f) do
		_mbQueueClickBlockerUpdate(f)
		f = f.parent
	end
end

-- FIX(2026-11-12): 挡板从"全按钮包围盒"改为"按行聚类铺设"。
-- 旧行为问题: 策略面板(机器人图标上方的竖列+多列布局)的包围盒把按钮之间的
-- 整块空隙全部盖死 —— 尤其竖列方向约130px高的空带, 恰好压住右段上方、
-- 背包物品的位置(11-08 修的是跨框架合并包围盒, 单框架内部稀疏布局仍会挡)。
-- 新行为: 把可见按钮按 Bottom 坐标聚类成"行", 每行一条挡板(覆盖行内相邻
-- 按钮间的横向空隙, 保持防误点设计); 竖向不再连成整块, 空隙释放给游戏。
function MultiBot.UpdateClickBlocker(frame)
	local cb = frame and frame.clickBlocker
	if(not cb) then return end

	local function hideAll()
		cb:Hide()
		if(frame.clickBlockerExtras) then
			for _, ex in pairs(frame.clickBlockerExtras) do ex:Hide() end
		end
	end

	-- 诊断开关(MultiBlockerDebug): kill 模式下强制全部隐藏, 节拍器不会重新打开
	if(MultiBot._blockersDisabled) then
		hideAll()
		return
	end

	if(not frame:IsShown()) then
		hideAll()
		return
	end

	local brx, bry = frame:GetRight(), frame:GetBottom()
	if(not brx or not bry) then
		hideAll()
		return
	end

	-- 收集本框架自身可见按钮的矩形
	local rects = {}
	if(frame.buttons) then
		for _, b in pairs(frame.buttons) do
			if(b and b.IsShown and b:IsShown() and b.GetLeft) then
				local l, r, bt, tp = b:GetLeft(), b:GetRight(), b:GetBottom(), b:GetTop()
				if(l and r and bt and tp) then
					rects[#rects + 1] = { l = l, r = r, b = bt, t = tp }
				end
			end
		end
	end

	if(#rects == 0) then
		-- 没有任何可见按钮 -> 不需要挡板
		hideAll()
		return
	end

	-- 按 Bottom 聚类成行(容差12px: 同一视觉行的按钮底部坐标抖动范围内)
	table.sort(rects, function(a, b2) return a.b < b2.b end)
	local rows = {}
	local cur
	for i = 1, #rects do
		local rc = rects[i]
		if(cur and (rc.b - cur.b) <= 12) then
			if(rc.l < cur.l) then cur.l = rc.l end
			if(rc.r > cur.r) then cur.r = rc.r end
			if(rc.t > cur.t) then cur.t = rc.t end
		else
			cur = { l = rc.l, r = rc.r, b = rc.b, t = rc.t }
			rows[#rows + 1] = cur
		end
	end

	-- 铺设: 第1条用主挡板(兼容诊断工具的归属识别), 其余用 extras 池
	local pad = 2
	for i = 1, #rows do
		local blk = cb
		if(i > 1) then
			blk = frame.clickBlockerExtras[i - 1]
			if(not blk) then
				blk = CreateFrame("Frame", nil, frame)
				blk:EnableMouse(true)
				blk.texture = blk:CreateTexture(nil, "BACKGROUND")
				blk.texture:SetAllPoints(blk)
				blk.texture:SetTexture("Interface\\Buttons\\WHITE8X8")
				blk.texture:SetVertexColor(0, 0, 0, 0)
				frame.clickBlockerExtras[i - 1] = blk
			end
		end
		local row = rows[i]
		blk:ClearAllPoints()
		blk:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", (row.r - brx) + pad, (row.b - bry) - pad)
		blk:SetPoint("TOPLEFT", frame, "BOTTOMRIGHT", (row.l - brx) - pad, (row.t - bry) + pad)
		blk:SetFrameLevel(frame:GetFrameLevel())
		blk:Show()
	end
	-- 多余的旧挡板隐藏(extras 索引 i-1 用于第 i 行, 已用 1..#rows-1)
	if(frame.clickBlockerExtras) then
		for idx, ex in pairs(frame.clickBlockerExtras) do
			if(idx >= #rows) then ex:Hide() end
		end
	end
end

-- 全量刷新: 遍历 MultiBot.frames 树, 重算所有 blocker (兜底用)
function MultiBot.RefreshAllClickBlockers()
	local function walk(f)
		if(not f) then return end
		if(f.clickBlocker) then
			MultiBot.UpdateClickBlocker(f)
		end
		if(f.frames) then
			for _, sf in pairs(f.frames) do walk(sf) end
		end
	end
	if(MultiBot.frames) then
		for _, fr in pairs(MultiBot.frames) do walk(fr) end
	end
end

-- FIX(2026-09-20): 兜底节拍器。
-- 部分收起/切换路径不会触发 OnHide hook (直接 :Hide() 绕过 doHide/ShowHideSwitch),
-- 导致 blocker 残留旧区域。每 0.3s 全量校验一次, 自动纠正任何残留。
do
	-- FIX(2026-11-15 十轮): beat 引用挂到 MultiBot 表(原局部变量出 do 块即失引用,
	-- 匿名帧可能被GC, 节拍器静默死亡后 blocker 残留区域不再被纠正)
	local beat = CreateFrame("Frame", nil, UIParent)
	MultiBot._blockerBeat = beat
	beat.elapsed = 0
	beat:SetScript("OnUpdate", function(self, dt)
		self.elapsed = self.elapsed + dt
		if(self.elapsed >= 0.3) then
			self.elapsed = 0
			if(MultiBot.RefreshAllClickBlockers) then
				MultiBot.RefreshAllClickBlockers()
			end
		end
	end)
end

-- MULTIBOT:FRAME --

MultiBot.newFrame = function(pParent, pX, pY, pSize, oWidth, oHeight, oAlign)
	local frame = CreateFrame("Frame", nil, pParent)
	frame:SetPoint(MultiBot.IF(oAlign ~= nil, oAlign, "BOTTOMRIGHT"), pX, pY)
	frame:Show()

	if(oWidth ~= nil and oHeight ~= nil)
	then frame:SetSize(oWidth, oHeight)
	else frame:SetSize(pSize, pSize)
	end

	frame.buttons = {}
	frame.frames = {}
	frame.texts = {}

	frame.parent = pParent
	frame.height = MultiBot.IF(oHeight ~= nil, oHeight, pSize)
	frame.width = MultiBot.IF(oWidth ~= nil, oWidth, pSize)
	frame.align = MultiBot.IF(oAlign ~= nil, oAlign, "BOTTOMRIGHT")
	frame.size = pSize
	frame.x = pX
	frame.y = pY

	-- click blocker: absorbe les clics dans les espaces entre boutons
	-- FIX(2026-11-12): 除主挡板外新增按行挡板池(clickBlockerExtras),
	-- 由 UpdateClickBlocker 按"按钮行"精确铺设, 不再整块包围盒。
	frame.clickBlocker = CreateFrame("Frame", nil, frame)
	frame.clickBlocker:SetFrameLevel(frame:GetFrameLevel())
	frame.clickBlocker:EnableMouse(true)
	frame.clickBlocker.texture = frame.clickBlocker:CreateTexture(nil, "BACKGROUND")
	frame.clickBlocker.texture:SetAllPoints(frame.clickBlocker)
	frame.clickBlocker.texture:SetTexture("Interface\\Buttons\\WHITE8X8")
	frame.clickBlocker.texture:SetVertexColor(0, 0, 0, 0) -- fond totalement transparent
	frame.clickBlocker:SetAllPoints(frame)
	frame.clickBlockerExtras = {}

	frame:HookScript("OnShow", function() if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(frame) end end)
	frame:HookScript("OnHide", function() if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(frame) end end)
	-- ADD --

	frame.addTexture = function(pTexture)
		if(frame.texture ~= nil) then frame.texture:Hide() end
		frame.texture = frame:CreateTexture(nil, "BACKGROUND")
		frame.texture:SetTexture(MultiBot.SafeTexturePath(pTexture))
		frame.texture:SetAllPoints(frame)
		frame.texture:Show()
		return frame.texture
	end

	--frame.addModel = function(pName, pX, pY, pWidth, pHeight, oScale)
	frame.addModel = function(pName, x, y, pWidth, pHeight, oScale)
		if(frame.model ~= nil) then frame.model:Hide() end
		frame.model = CreateFrame("DressUpModel", "MyModel" .. pName, frame)
		--frame.model:SetPoint("CENTER", pX, pY)
		frame.model:SetPoint("CENTER", x, y)
		frame.model:SetSize(pWidth, pHeight)
		frame.model:SetUnit(pName)
		if(oScale ~= nil) then frame.model:SetScale(oScale) end
		return frame.model
	end

	--frame.addText = function(pIndex, pText, pAlign, pX, pY, pSize)
	frame.addText = function(pIndex, pText, pAlign, x, y, fontSize)
		if(frame.texts[pIndex] ~= nil) then frame.texts[pIndex]:Hide() end
		frame.texts[pIndex] = frame:CreateFontString(nil, "ARTWORK")
		--frame.texts[pIndex]:SetFont("Fonts\\ARIALN.ttf", pSize, "PLAIN")
		--frame.texts[pIndex]:SetPoint(pAlign, pX, pY)
        frame.texts[pIndex]:SetFont(MultiBot.GetUIFont(), fontSize, "PLAIN")
        frame.texts[pIndex]:SetPoint(pAlign, x, y)
		frame.texts[pIndex]:SetText(pText)
		frame.texts[pIndex]:Show()
		return frame.texts[pIndex]
	end

	--frame.wowButton = function(pName, pX, pY, pWidth, pHeight, pSize)
	frame.wowButton = function(pName, x, y, pWidth, pHeight, size)
		if(frame.buttons[pName] ~= nil) then frame.buttons[pName]:Hide() end
		--frame.buttons[pName] = MultiBot.wowButton(frame, pName, pX, pY, pWidth, pHeight, pSize)
		frame.buttons[pName] = MultiBot.wowButton(frame, pName, x, y, pWidth, pHeight, size)
		return frame.buttons[pName]
	end

	--frame.addButton = function(pName, pX, pY, pTexture, pTip, oTemplate)
	frame.addButton = function(pName, x, y, pTexture, pTip, oTemplate)
		if(frame.buttons[pName] ~= nil) then frame.buttons[pName]:Hide() end
		--frame.buttons[pName] = MultiBot.newButton(frame, pX, pY, frame.size, pTexture, pTip, oTemplate)
		frame.buttons[pName] = MultiBot.newButton(frame, x, y, frame.size, pTexture, pTip, oTemplate)
		return frame.buttons[pName]
	end

	--frame.movButton = function(pName, pX, pY, pSize, pTip, oFrame)
	frame.movButton = function(pName, x, y, size, pTip, oFrame)
		if(frame.buttons[pName] ~= nil) then frame.buttons[pName]:Hide() end
		--frame.buttons[pName] = MultiBot.movButton(frame, pX, pY, pSize, pTip, oFrame)
		frame.buttons[pName] = MultiBot.movButton(frame, x, y, size, pTip, oFrame)
		return frame.buttons[pName]
	end

	--frame.boxButton = function(pName, pX, pY, pSize, pState)
	frame.boxButton = function(pName, x, y, size, pState)
		if(frame.buttons[pName] ~= nil) then frame.buttons[pName]:Hide() end
		--frame.buttons[pName] = MultiBot.boxButton(frame, pX, pY, pSize, pState)
		frame.buttons[pName] = MultiBot.boxButton(frame, x, y, size, pState)
		return frame.buttons[pName]
	end

	--frame.catButton = function(pName, pX, pY, pWidth, pHeight)
	frame.catButton = function(pName, x, y, pWidth, pHeight)
		if(frame.buttons[pName] ~= nil) then frame.buttons[pName]:Hide() end
		--frame.buttons[pName] = MultiBot.catButton(frame, pX, pY, pWidth, pHeight)
		frame.buttons[pName] = MultiBot.catButton(frame, x, y, pWidth, pHeight)
		return frame.buttons[pName]
	end

	--frame.addFrame = function(pName, pX, pY, oSize, oWidth, oHeight)
	frame.addFrame = function(pName, x, y, oSize, subWidth, subHeight)
		if(frame.frames[pName] ~= nil) then frame.frames[pName]:Hide() end
		--frame.frames[pName] = MultiBot.newFrame(frame, pX, pY, MultiBot.IF(oSize ~= nil, oSize, frame.size - 4), oWidth, oHeight)
		frame.frames[pName] = MultiBot.newFrame(frame, x, y, MultiBot.IF(oSize ~= nil, oSize, frame.size - 4), subWidth, subHeight)
		return frame.frames[pName]
	end

	-- SET --

	--[[frame.setPoint = function(pX, pY)
		frame:SetPoint("BOTTOMRIGHT", pX, pY)
		frame.x = pX
		frame.y = pY]]--
    frame.setPoint = function(x, y)
        frame:SetPoint("BOTTOMRIGHT", x, y)
        frame.x = x
        frame.y = y
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(frame) end
		return frame
	end

	frame.setButton = function(pIndex, pTexture, pTip)
		frame.buttons[pIndex].setButton(pTexture, pTip)
		return frame
	end

	frame.setTexture = function(pTexture)
		frame.texture:SetTexture(MultiBot.SafeTexturePath(pTexture))
		frame.texture:SetAllPoints(frame)
		frame.texture:Show()
		return frame
	end

	frame.setText = function(pIndex, pText)
		frame.texts[pIndex]:SetText(pText)
		frame.texts[pIndex]:Show()
		return frame
	end

	frame.setLevel = function(pLevel)
		frame:SetFrameLevel(pLevel)
		return frame
	end

	frame.setAlpha = function(pAlpha)
		frame:SetAlpha(pAlpha)
		return frame
	end

	-- GET --

	frame.getButton = function(pIndex)
		if(frame.buttons[pIndex] ~= nil) then
			return frame.buttons[pIndex]
		end

		for key, value in pairs(frame.frames) do
			local tButton = value.getButton(pIndex)
			if(tButton ~= nil) then return tButton end
		end

		return nil
	end

	frame.getFrame = function(pIndex)
		if(frame.frames[pIndex] ~= nil) then
			return frame.frames[pIndex]
		end

		for key, value in pairs(frame.frames) do
			local tFrame = value.getFrame(pIndex)
			if(tFrame ~= nil) then return tFrame end
		end

		return nil
	end

	frame.getClass = function()
		if(frame.class ~= nil) then return frame.class end
		return frame.parent.getClass()
	end

	frame.getName = function()
		if(frame.name ~= nil) then return frame.name end
		return frame.parent.getName()
	end

	frame.get = function()
		if(frame.name ~= nil) then return frame end
		return frame.parent.get()
	end

	-- DO --

	frame.doShow = function()
		frame:Show()
		return frame
	end

	frame.doHide = function()
		frame:Hide()
		return frame
	end

	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(frame) end

	return frame
end

-- MULTIBOT:BUTTON --

MultiBot.newButton = function(pParent, pX, pY, pSize, pTexture, pTip, oTemplate)
	local button = CreateFrame("Button", nil, pParent, MultiBot.IF(oTemplate ~= nil, oTemplate, "ActionButtonTemplate"))
	button:SetPoint("BOTTOMRIGHT", pX, pY)
	button:SetSize(pSize, pSize)
	button:Show()

	button.icon = button:CreateTexture(nil, "BACKGROUND")
	button.icon:SetTexture(MultiBot.SafeTexturePath(pTexture))
	button.icon:SetAllPoints(button)
	button.icon:Show()

	button.border = button:CreateTexture(nil, "ARTWORK")
	button.border:SetTexture("Interface\\AddOns\\MultiBot\\Icons\\border.blp")
	button.border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	button.border:SetSize(pSize + 4, pSize + 4)
	button.border:Hide()

	-- FIX(2026-11-10): 已选(启用)态视觉增强。border.blp 为灰度贴图(调色板已验证),
	-- 可用 SetVertexColor 安全染色: 选中时描边染绿 + 外圈柔光(ADD 混合), 比原单层边框醒目。
	button.glow = button:CreateTexture(nil, "ARTWORK")
	button.glow:SetTexture("Interface\\AddOns\\MultiBot\\Icons\\border.blp")
	button.glow:SetBlendMode("ADD")
	button.glow:SetVertexColor(0.20, 0.95, 0.45, 0.45)
	button.glow:SetAllPoints(button.border)
	button.glow:Hide()

	button:EnableMouse(true)
	button:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	button:SetHighlightTexture("Interface/Buttons/ButtonHilight-Square", "ADD")
	button:SetPushedTexture("Interface/Buttons/UI-Quickslot-Depress")
	button:SetNormalTexture("")

	--button.texture = pTexture
    button.texture = MultiBot.SafeTexturePath(pTexture)
	button.parent = pParent
	button.size = pSize
	button.tip = pTip
	button.x = pX
	button.y = pY
	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	button:HookScript("OnShow", function() if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end end)
	button:HookScript("OnHide", function() if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end end)

	-- ADD --

	button.addMacro = function(pType, pMacro)
		button:SetAttribute("macrotext", pMacro);
		button:SetAttribute(pType, "macro");
		return button
	end

	-- SET --

    button.setPoint = function(x, y)
        button:SetPoint("BOTTOMRIGHT", x, y)
        button.x = x
        button.y = y
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
		return button
	end

    button.setButton = function(texture, tip)
        local safe = MultiBot.SafeTexturePath(texture)
        button.icon:SetTexture(safe)
		button.icon:SetAllPoints(button)
        button.texture = safe
        button.tip = tip
		return button
	end

    button.setTexture = function(texture)
        local safe = MultiBot.SafeTexturePath(texture)
        button.icon:SetTexture(safe)
		button.icon:SetAllPoints(button)
        button.texture = safe
		return button
	end

    button.setHighlight = function(texture)
        button:SetHighlightTexture(texture, "ADD")
		return button
	end

	button.setAmount = function(pAmount)
		if(button.amount ~= nil) then button.amount:Hide() end
		button.amount = button:CreateFontString(nil, "ARTWORK")
		button.amount:SetFont(MultiBot.GetUIFont(), 13, "OUTLINE")
		button.amount:SetPoint("BOTTOMRIGHT", 0, 0)
		button.amount:SetText(pAmount)
		return button
	end

	button.setDisable = function(oBorder)
		button.icon:SetDesaturated(1)
		if(oBorder == nil) then oBorder = true end
		if(oBorder) then
			button.border:Hide()
			button.glow:Hide()
			button.border:SetVertexColor(1, 1, 1)
		end
		button.state = false
		return button
	end

	button.setEnable = function(oBorder)
		button.icon:SetDesaturated(nil)
		if(oBorder == nil) then oBorder = true end
		if(oBorder) then
			-- FIX(2026-11-10): 选中态 = 绿色描边 + 柔光圈
			button.border:SetVertexColor(0.20, 0.95, 0.45)
			button.border:Show()
			button.glow:Show()
		end
		button.state = true
		return button
	end

	-- GET --

	button.getButton = function(pIndex)
		return button.parent.get().getButton(pIndex)
	end

	button.getFrame = function(pIndex)
		return button.parent.get().getFrame(pIndex)
	end

	button.getClass = function()
		return button.parent.getClass()
	end

	button.getName = function()
		return button.parent.getName()
	end

	button.get = function()
		return button.parent.get()
	end

	-- DO --

	button.doHide = function()
		button:SetPoint("BOTTOMRIGHT", button.x, button.y)
		button:SetSize(button.size, button.size)
		button:Hide()
		return button
	end

	button.doShow = function()
		button:SetPoint("BOTTOMRIGHT", button.x, button.y)
		button:SetSize(button.size, button.size)
		button:Show()
		return button
	end

	-- EVENT --

	button:SetScript("OnEnter", function()
		if(type(button.tip) == "string") then
			GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT", 0 - button.size, 2)
			if(string.sub(button.tip, 1, 1) == "|") then GameTooltip:SetHyperlink(button.tip) else GameTooltip:SetText(button.tip) end
			GameTooltip:Show()
			return
		end

		if(type(button.tip) == "table") then
			button.tip:Show()
			return
		end
	end)

	button:SetScript("OnLeave", function()
		button:SetPoint("BOTTOMRIGHT", button.x, button.y)
		button:SetSize(button.size, button.size)

		button.border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		button.border:SetSize(button.size + 4, button.size + 4)

		if(type(button.tip) == "string") then GameTooltip:Hide() end
		if(type(button.tip) == "table") then button.tip:Hide() end
	end)

	button:SetScript("PostClick", function(pSelf, pEvent)
		button:SetPoint("BOTTOMRIGHT", button.x - 1, button.y + 1)
		button:SetSize(button.size - 2, button.size - 2)

		button.border:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
		button.border:SetSize(button.size + 2, button.size + 2)

		if(type(button.tip) == "string") then GameTooltip:Hide() end
		if(type(button.tip) == "table") then button.tip:Hide() end

		if(pEvent == "LeftButton" and IsAltKeyDown() and MultiBot.OnButtonAltClick ~= nil
			and MultiBot.OnButtonAltClick(button)) then
			-- 四十轮: Alt+左键 = 单行刷新该机器人策略(替代右键单位控制的单人版), 不再派发 doLeft
			return
		end
		if(pEvent == "LeftButton" and IsControlKeyDown() and MultiBot.OnButtonCtrlClick ~= nil
			and MultiBot.OnButtonCtrlClick(button)) then
			-- FIX(2026-11-15 十一轮): Ctrl+左键扩展点——OnButtonCtrlClick 返回 true 表示本次点击
			-- 被扩展功能消费(当前唯一用途: 机器人头像按钮上的"天赋变量录入界面",
			-- 见 MultiBotTalentDetect.lua), 不再派发原 doLeft; 普通点击/无Ctrl 完全走原行为
			return
		end
		if(pEvent == "RightButton" and button.doRight ~= nil) then button.doRight(button) end
		if(pEvent == "LeftButton" and button.doLeft ~= nil) then button.doLeft(button) end
	end)

	return button
end

-- BUTTON:WOW --

MultiBot.wowButton = function(pParent, pName, pX, pY, pWidth, pHeight, pSize)
	local button = CreateFrame("Button", nil, pParent, "UIPanelButtonTemplate")
	button:SetPoint("BOTTOMRIGHT", pX, pY)
	button:SetSize(pWidth, pHeight)
	button:Show()

	button.text = button:CreateFontString(nil, "ARTWORK")
	button.text:SetFont(MultiBot.GetUIFont(), pSize, "OUTLINE")
	button.text:SetPoint("CENTER", 0, 0)
	button.text:SetText("|cffffcc00" .. pName .. "|r")
	button.text:Show()

	button:EnableMouse(true)
	button:RegisterForClicks("LeftButtonDown", "RightButtonDown")

	button.parent = pParent
	button.state = true
	button.y = pY
	button.x = pX

	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end

	button:HookScript("OnShow", function()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	end)

	button:HookScript("OnHide", function()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	end)

	-- GET --

	button.getButton = function(pIndex)
		return button.parent.get().getButton(pIndex)
	end

	button.getFrame = function(pIndex)
		return button.parent.get().getFrame(pIndex)
	end

	button.getClass = function()
		return button.parent.getClass()
	end

	button.getName = function()
		return button.parent.getName()
	end

	button.get = function()
		return button.parent.get()
	end

	-- SET --

	button.setDisable = function()
		local tex = button:GetNormalTexture()
		if tex then tex:SetDesaturated(1) end
		button.state = false
		return button
	end

	button.setEnable = function()
		local tex = button:GetNormalTexture()
		if tex then tex:SetDesaturated(nil) end
		button.state = true
		return button
	end

	-- DO --

	button.doHide = function()
		button:Hide()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
		return button
	end

	button.doShow = function()
		button:Show()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
		return button
	end

	-- EVENT --

	button:SetScript("OnEnter", function()
	end)

	button:SetScript("OnLeave", function()
		button.text:SetPoint("CENTER", 0, 0)
	end)

	button:SetScript("OnClick", function(pSelf, pEvent)
		button.text:SetPoint("CENTER", -1, -1)
		if(pEvent == "RightButton" and button.doRight ~= nil) then button.doRight(button) end
		if(pEvent == "LeftButton" and button.doLeft ~= nil) then button.doLeft(button) end
	end)

	return button
end

-- BUTTON:MOVE --

MultiBot.movButton = function(pParent, pX, pY, pSize, pTip, oFrame)
	local button = CreateFrame("Button", nil, pParent)
	button:SetPoint("BOTTOMRIGHT", pX, pY)
	button:SetSize(pSize, pSize)
	button:Show()

	button:EnableMouse(true)
	button:RegisterForClicks("RightButtonDown")
	button:RegisterForDrag("RightButton")

	button.parent = pParent
	button.frame = oFrame
	button.size = pSize
	button.tip = pTip
	button.x = pX
	button.y = pY

	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end

	button:HookScript("OnShow", function()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	end)

	button:HookScript("OnHide", function()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	end)

	-- EVENT --

	button:SetScript("OnEnter", function()
		GameTooltip:SetOwner(button, "ANCHOR_TOPRIGHT", 0 - button.size, 2)
		GameTooltip:SetText(button.tip)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	button:SetScript("OnClick", function(pSelf, pEvent)
		GameTooltip:Hide()
	end)

	button:SetScript("OnDragStart", function()
		if(button.frame ~= nil) then button.frame:StartMoving() else button.parent:StartMoving() end
	end)

	button:SetScript("OnDragStop", function()
		if(button.frame ~= nil) then button.frame:StopMovingOrSizing() else button.parent:StopMovingOrSizing() end
	end)

	return button
end

-- BUTTON:BOX --

MultiBot.boxButton = function(pParent, pX, pY, pSize, pState)
	local button = CreateFrame("CheckButton", nil, pParent, "ChatConfigCheckButtonTemplate");
	button:SetPoint("BOTTOMRIGHT", pX, pY)
	button:SetHitRectInsets(0, 0, 0, 0)
	button:SetSize(pSize, pSize)
	button:SetChecked(pState)
	button:Show()

	button.parent = pParent
	button.state = pState
	button.size = pSize
	button.x = pX
	button.y = pY

	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end

	button:HookScript("OnShow", function()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	end)

	button:HookScript("OnHide", function()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	end)

	-- GET --

	button.getButton = function(pIndex)
		return button.parent.get().getButton(pIndex)
	end

	button.getFrame = function(pIndex)
		return button.parent.get().getFrame(pIndex)
	end

	button.getClass = function()
		return button.parent.getClass()
	end

	button.getName = function()
		return button.parent.getName()
	end

	button.get = function()
		return button.parent.get()
	end

	-- DO --

	button.doHide = function()
		button:Hide()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
		return button
	end

	button.doShow = function()
		button:Show()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
		return button
	end

	-- EVENT --

	button:SetScript("OnClick", function()
		if(button.doClick ~= nil) then button.doClick(button) end
	end)

	return button;
end

-- BUTTON:CAT --

MultiBot.catButton = function(pParent, pX, pY, pWidth, pHeight)
	local button = CreateFrame("CheckButton", nil, pParent, "SecureActionButtonTemplate");
	button:SetPoint("BOTTOMRIGHT", pX, pY)
	button:SetSize(pWidth, pHeight)
	button:Show()

	button.parent = pParent
	if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end

	button:HookScript("OnShow", function()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	end)

	button:HookScript("OnHide", function()
		if(MultiBot.RequestClickBlockerUpdate) then MultiBot.RequestClickBlockerUpdate(button.parent) end
	end)

	-- EVENT --

	button:SetScript("OnClick", function()
		if(button.doClick ~= nil) then button.doClick(button) end
	end)

	return button;
end

-- MULTIBOT:ADD --

MultiBot.addFrame = function(pName, pX, pY, pSize)
	local tFrame = MultiBot.newFrame(MultiBot, pX, pY, pSize)
	MultiBot.frames[pName] = tFrame
	return tFrame
end

-- MULTIBOT: SELL ALL BOTS --
-- Envoie une commande de vente à tous les bots listés dans l’onglet "Units".
-- pCommand : "s *" (tout le gris) ou "s vendor" (tout ce qui est vendable).
MultiBot.SellAllBots = function(pCommand)
	-- Par défaut : vendre tous les objets gris (safe)
	pCommand = pCommand or "s *"

	if not MultiBot.isTarget or not MultiBot.isTarget() then
		return 0
	end

	local frames = MultiBot.frames
	if not frames then return 0 end

	local multiBar = frames["MultiBar"]
	if not multiBar or not multiBar.frames or not multiBar.frames["Units"] then
		return 0
	end

	local units = multiBar.frames["Units"]
	if not units.buttons then
		return 0
	end

	CancelTrade()

	local count = 0

	for key, btn in pairs(units.buttons) do
		if type(btn) == "table" then
			local botName = btn.name or (btn.getName and btn.getName()) or key
			if botName and botName ~= "" then
				SendChatMessage(pCommand, "WHISPER", nil, botName)
				count = count + 1
			end
		end
	end

	-- Si une fenêtre d’inventaire est ouverte, on la rafraîchit pour le bot affiché
	if MultiBot.inventory and MultiBot.inventory:IsVisible() and MultiBot.RefreshInventory then
		MultiBot.RefreshInventory(0.5)
	end

	return count
end

-- MULTIBOT: MAINTENANCE ALL BOTS --
-- Envoie la commande "maintenance" à tous les bots listés dans l’onglet "Units".
MultiBot.MaintenanceAllBots = function()
	local frames = MultiBot.frames
	if not frames then return 0 end

	local multiBar = frames["MultiBar"]
	if not multiBar or not multiBar.frames or not multiBar.frames["Units"] then
		return 0
	end

	local units = multiBar.frames["Units"]
	if not units.buttons then
		return 0
	end

	CancelTrade()

	local count = 0

	for key, btn in pairs(units.buttons) do
		if type(btn) == "table" then
			local botName = btn.name or (btn.getName and btn.getName()) or key
			if botName and botName ~= "" then
				SendChatMessage("maintenance", "WHISPER", nil, botName)
				count = count + 1
			end
		end
	end

	-- Si une fenêtre d’inventaire est ouverte, on peut la rafraîchir pour refléter d’éventuels changements
	if MultiBot.inventory and MultiBot.inventory:IsVisible() and MultiBot.RefreshInventory then
		MultiBot.RefreshInventory(0.5)
	end

	return count
end

--[[MultiBot.addSelf = function(pClass, pName)
MultiBot.dprint("addSelf", pName, pClass) -- DEBUG
	if(MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] ~= nil) then return MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] end
	local tClass = MultiBot.toClass(pClass)
	local tButton = MultiBot.frames["MultiBar"].frames["Units"].addButton(pName, 0, 0, "inv_misc_head_clockworkgnome_01", MultiBot.tips.unit.selfbot)
	if(MultiBot.index.classes.players[tClass] == nil) then MultiBot.index.classes.players[tClass] = {} end
	table.insert(MultiBot.index.classes.players[tClass], pName)
	-- table.insert(MultiBot.index.players, pName)
	table.insert(MultiBot.index.players, pName); MultiBot.dprint("players++", pName, "total", table.getn(MultiBot.index.players)) -- DEBUG
	tButton.roster = "players"
	tButton.class = tClass
	tButton.name = pName
	-- Si ce joueur est en favoris, on rafraîchit l’index
	if MultiBot.IsFavorite and MultiBot.IsFavorite(pName) and MultiBot.UpdateFavoritesIndex then
		MultiBot.UpdateFavoritesIndex()
	end
	return tButton
end]]--

MultiBot.addSelf = function(pClass, pName)
  local units = MultiBot.frames["MultiBar"].frames["Units"]
  local btn   = units.buttons[pName]
  local tClass = (MultiBot.toClass and MultiBot.toClass(pClass)) or (pClass or "Unknown")
  tClass = tClass or "Unknown"
  if not btn then
    btn = units.addButton(pName, 0, 0, "inv_misc_head_clockworkgnome_01", MultiBot.tips.unit.selfbot)
  end
  -- Assurer la présence dans les index (sans doublons)
  MultiBot.index.classes.players[tClass] = MultiBot.index.classes.players[tClass] or {}
  local byClass = MultiBot.index.classes.players[tClass]
  local found = false
  for i=1,#byClass do if byClass[i] == pName then found = true; break end end
  if not found then table.insert(byClass, pName) end
  local pidx = MultiBot.index.players
  local found2 = false
  for i=1,#pidx do if pidx[i] == pName then found2 = true; break end end
  if not found2 then table.insert(pidx, pName) end
  btn.roster = "players"
  btn.class  = tClass
  btn.name   = pName
  if MultiBot.IsFavorite and MultiBot.IsFavorite(pName) and MultiBot.UpdateFavoritesIndex then
    MultiBot.UpdateFavoritesIndex()
  end
  return btn
end

--[[MultiBot.addPlayer = function(pClass, pName)
MultiBot.dprint("addPlayer", pName, pClass) -- DEBUG
	if(MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] ~= nil) then return MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] end
	local tClass = MultiBot.toClass(pClass)
	local tTexture = "Interface\\AddOns\\MultiBot\\Icons\\class_" .. string.lower(tClass) .. ".blp"
	local tButton = MultiBot.frames["MultiBar"].frames["Units"].addButton(pName, 0, 0, tTexture, MultiBot.toTip(tClass, nil, pName))
	if(MultiBot.index.classes.players[tClass] == nil) then MultiBot.index.classes.players[tClass] = {} end
	table.insert(MultiBot.index.classes.players[tClass], pName)
	table.insert(MultiBot.index.players, pName)
	tButton.roster = "players"
	tButton.class = tClass
	tButton.name = pName
	return tButton
end]]--

MultiBot.addPlayer = function(pClass, pName)
  local units = MultiBot.frames["MultiBar"].frames["Units"]
  local btn   = units.buttons[pName]
  local tClass = (MultiBot.toClass and MultiBot.toClass(pClass)) or (pClass or "Unknown")
  tClass = tClass or "Unknown"
  MultiBot.ClassCacheSet(pName, tClass) -- 十四轮: roster 职业来自服务端数据库, 写入缓存
  local tTexture = "Interface\\AddOns\\MultiBot\\Icons\\class_" .. string.lower(tClass) .. ".blp"
  if not btn then
    btn = units.addButton(pName, 0, 0, tTexture, MultiBot.toTip(tClass, nil, pName))
  else
    if btn.icon and tTexture then btn.icon:SetTexture(MultiBot.SafeTexturePath(tTexture)) end
  end
  -- Assurer la présence dans les index (sans doublons)
  MultiBot.index.classes.players[tClass] = MultiBot.index.classes.players[tClass] or {}
  local byClass = MultiBot.index.classes.players[tClass]
  local found = false
  for i=1,#byClass do if byClass[i] == pName then found = true; break end end
  if not found then table.insert(byClass, pName) end
  local pidx = MultiBot.index.players
  local found2 = false
  for i=1,#pidx do if pidx[i] == pName then found2 = true; break end end
  if not found2 then table.insert(pidx, pName) end
  btn.roster = "players"
  btn.class  = tClass
  btn.name   = pName
  return btn
end

--[[local function MB_InsertUnique(pTable, pValue)
  if(pTable == nil) then return end
  for i = 1, table.getn(pTable) do
    if(pTable[i] == pValue) then return end
  end
  table.insert(pTable, pValue)
end]]--
local function MB_InsertUnique(pTable, pValue)
  if(pTable == nil) then return end
  for i = 1, #pTable do
    if(pTable[i] == pValue) then return end
  end
  table.insert(pTable, pValue)
end

MultiBot.addMember = function(pClass, pLevel, pName)
	--[[if(MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] ~= nil) then return MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] end
	local tClass = MultiBot.toClass(pClass)
	local tTexture = "Interface\\AddOns\\MultiBot\\Icons\\class_" .. string.lower(tClass) .. ".blp"
	local tButton = MultiBot.frames["MultiBar"].frames["Units"].addButton(pName, 0, 0, tTexture, MultiBot.toTip(tClass, pLevel, pName))
	if(MultiBot.index.classes.members[tClass] == nil) then MultiBot.index.classes.members[tClass] = {} end
	table.insert(MultiBot.index.classes.members[tClass], pName)
	table.insert(MultiBot.index.members, pName)
	tButton.roster = "members"
	tButton.class = tClass
	tButton.name = pName
	return tButton]]--
  local tUnits = MultiBot.frames["MultiBar"].frames["Units"]
  local tButton = tUnits.buttons[pName]
  local tClass = MultiBot.toClass(pClass)
  local tTexture = "Interface\\AddOns\\MultiBot\\Icons\\class_" .. string.lower(tClass) .. ".blp"
  if(tButton == nil) then
    tButton = tUnits.addButton(pName, 0, 0, tTexture, MultiBot.toTip(tClass, pLevel, pName))
  else
    if(tButton.setButton ~= nil) then
      tButton.setButton(tTexture, MultiBot.toTip(tClass, pLevel, pName))
    end
  end
  if(MultiBot.index.classes.members[tClass] == nil) then MultiBot.index.classes.members[tClass] = {} end
  MB_InsertUnique(MultiBot.index.classes.members[tClass], pName)
  MB_InsertUnique(MultiBot.index.members, pName)
  tButton.roster = "members"
  tButton.class = tClass
  tButton.name = pName
  tButton.level = pLevel -- 十六轮: 供天赋变量变更后重建 tooltip(等级不丢)
  return tButton
end

MultiBot.addFriend = function(pClass, pLevel, pName)
	--[[if(MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] ~= nil) then return MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] end
	local tClass = MultiBot.toClass(pClass)
	local tTexture = "Interface\\AddOns\\MultiBot\\Icons\\class_" .. string.lower(tClass) .. ".blp"
	local tButton = MultiBot.frames["MultiBar"].frames["Units"].addButton(pName, 0, 0, tTexture, MultiBot.toTip(tClass, pLevel, pName))
	if(MultiBot.index.classes.friends[tClass] == nil) then MultiBot.index.classes.friends[tClass] = {} end
	table.insert(MultiBot.index.classes.friends[tClass], pName)
	table.insert(MultiBot.index.friends, pName)
	tButton.roster = "friends"
	tButton.class = tClass
	tButton.name = pName
	return tButton]]--

  local tUnits = MultiBot.frames["MultiBar"].frames["Units"]
  local tButton = tUnits.buttons[pName]
  local tClass = MultiBot.toClass(pClass)
  -- 十四轮: 离线好友职业=Unknown 时回退职业缓存; 在线拿到真实职业时写入缓存
  if(tClass == "Unknown") then
    local tCached = MultiBot.ClassCacheGet(pName)
    if(tCached ~= nil) then tClass = tCached end
  else
    MultiBot.ClassCacheSet(pName, tClass)
  end
  -- 职业从 Unknown(或旧值)修正时, 清掉旧分类索引里的残留, 避免职业筛选重复
  if(tButton ~= nil and tButton.class ~= nil and tButton.class ~= tClass) then
    local tOld = MultiBot.index.classes.friends[tButton.class]
    if(tOld ~= nil) then
      for i = #tOld, 1, -1 do
        if(tOld[i] == pName) then table.remove(tOld, i) end
      end
    end
  end
  local tTexture = "Interface\\AddOns\\MultiBot\\Icons\\class_" .. string.lower(tClass) .. ".blp"
  if(tButton == nil) then
    tButton = tUnits.addButton(pName, 0, 0, tTexture, MultiBot.toTip(tClass, pLevel, pName))
  else
    if(tButton.setButton ~= nil) then
      tButton.setButton(tTexture, MultiBot.toTip(tClass, pLevel, pName))
    end
  end
  if(MultiBot.index.classes.friends[tClass] == nil) then MultiBot.index.classes.friends[tClass] = {} end
  MB_InsertUnique(MultiBot.index.classes.friends[tClass], pName)
  MB_InsertUnique(MultiBot.index.friends, pName)
  tButton.roster = "friends"
  tButton.class = tClass
  tButton.name = pName
  tButton.level = pLevel -- 十六轮: 供天赋变量变更后重建 tooltip(等级不丢)
  return tButton
end

MultiBot.addActive = function(pClass, pLevel, pName)
	if(MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] ~= nil) then return MultiBot.frames["MultiBar"].frames["Units"].buttons[pName] end
	local tClass = MultiBot.toClass(pClass)
	MultiBot.ClassCacheSet(pName, tClass) -- 十四轮: 进组机器人在线, UnitClass 是权威职业, 写入缓存
	local tTexture = "Interface\\AddOns\\MultiBot\\Icons\\class_" .. string.lower(tClass) .. ".blp"
	local tButton = MultiBot.frames["MultiBar"].frames["Units"].addButton(pName, 0, 0, tTexture, MultiBot.toTip(tClass, pLevel, pName))
	tButton.roster = "actives"
	tButton.class = tClass
	tButton.name = pName
	tButton.level = pLevel -- 十六轮: 供天赋变量变更后重建 tooltip(等级不丢)
	return tButton
end

-- MULTIBOT:GET --

MultiBot.getBot = function(pName)
	return MultiBot.frames["MultiBar"].frames["Units"].buttons[pName]
end

-- MULTIBOT:INVENTORY REFRESH --
-- Rafraîchit l’inventaire du bot actuellement affiché dans la frame Inventory
-- en rejouant le même flux que le bouton "Inventory" (waitFor = "INVENTORY" + "items").
MultiBot.RefreshInventory = function(delay)
	-- Si la frame d’inventaire n’est pas visible ou pas encore initialisée, on ne fait rien
	if not MultiBot.inventory or not MultiBot.inventory:IsVisible() then
		return false
	end

	local botName = MultiBot.inventory.name
	if not botName or botName == "" then
		return false
	end

	-- On retrouve le bouton "Units" correspondant à ce bot
	local frames   = MultiBot.frames
	if not frames then return false end

	local multiBar = frames["MultiBar"]
	if not multiBar or not multiBar.frames or not multiBar.frames["Units"] then
		return false
	end

	local units = multiBar.frames["Units"]
	if not units.buttons or not units.buttons[botName] then
		return false
	end

	local function doRefresh()
		-- Entre le moment où on programme le refresh et l’exécution, il est possible
		-- que la frame ou le bouton n’existent plus : on recheck.
		if not units.buttons or not units.buttons[botName] then
			return
		end

		-- On relance le flux INVENTORY -> ITEM comme lors de l’ouverture de l’inventaire
		units.buttons[botName].waitFor = "INVENTORY"
		SendChatMessage("items", "WHISPER", nil, botName)
	end

	-- Si on a un délai > 0 et TimerAfter dispo, on planifie le refresh un peu plus tard
	if type(delay) == "number" and delay > 0 and MultiBot.TimerAfter then
		MultiBot.TimerAfter(delay, doRefresh)
	else
		-- Sinon on rafraîchit immédiatement (comportement d’origine)
		doRefresh()
	end

	return true
end