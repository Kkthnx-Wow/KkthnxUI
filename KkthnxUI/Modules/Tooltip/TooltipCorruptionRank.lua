local K, C = unpack(select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G
local math_max = _G.math.max
local string_format = _G.string.format
local string_gmatch = _G.string.gmatch
local string_match = _G.string.match
local table_wipe = _G.table.wipe

local CORRUPTION_DESCRIPTION = _G.CORRUPTION_DESCRIPTION
local CORRUPTION_RESISTANCE_TOOLTIP_LINE = _G.CORRUPTION_RESISTANCE_TOOLTIP_LINE
local CORRUPTION_TOOLTIP_LINE = _G.CORRUPTION_TOOLTIP_LINE
local CORRUPTION_TOOLTIP_TITLE = _G.CORRUPTION_TOOLTIP_TITLE
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetSpellInfo = _G.GetSpellInfo
local ITEM_MOD_CORRUPTION = _G.ITEM_MOD_CORRUPTION
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsCorruptedItem = _G.IsCorruptedItem
local TOTAL_CORRUPTION_TOOLTIP_LINE = _G.TOTAL_CORRUPTION_TOOLTIP_LINE
local UnitGUID = _G.UnitGUID
local hooksecurefunc = _G.hooksecurefunc

local corruptionData = {
	["6483"] = {spellID = 315607, level = "I (|cffffffff8|r/12/16)", value = 8},
	["6484"] = {spellID = 315608, level = "II (8/|cffffffff12|r/16)", value = 12},
	["6485"] = {spellID = 315609, level = "III (8/12/|cffffffff16|r)", value = 16},
	["6474"] = {spellID = 315544, level = "I (|cffffffff10|r/15/20)", value = 10},
	["6475"] = {spellID = 315545, level = "II (10/|cffffffff15|r/20)", value = 15},
	["6476"] = {spellID = 315546, level = "III (10/15/|cffffffff20|r)", value = 20},
	["6471"] = {spellID = 315529, level = "I (|cffffffff10|r/15/20)", value = 10},
	["6472"] = {spellID = 315530, level = "II (10/|cffffffff15|r/20)", value = 15},
	["6473"] = {spellID = 315531, level = "III (10/15/|cffffffff20|r)", value = 20},
	["6480"] = {spellID = 315554, level = "I (|cffffffff10|r/15/20)", value = 10},
	["6481"] = {spellID = 315557, level = "II (10/|cffffffff15|r/20)", value = 15},
	["6482"] = {spellID = 315558, level = "III (10/15/|cffffffff20|r)", value = 20},
	["6477"] = {spellID = 315549, level = "I (|cffffffff10|r/15/20)", value = 10},
	["6478"] = {spellID = 315552, level = "II (10/|cffffffff15|r/20)", value = 15},
	["6479"] = {spellID = 315553, level = "III (10/15/|cffffffff20|r)", value = 20},
	["6493"] = {spellID = 315590, level = "I (|cffffffff17|r/28/45)", value = 17},
	["6494"] = {spellID = 315591, level = "II (17/|cffffffff28|r/45)", value = 28},
	["6495"] = {spellID = 315592, level = "III (17/28/|cffffffff45|r)", value = 45},
	["6437"] = {spellID = 315277, level = "I (|cffffffff10|r/15/20)", value = 10},
	["6438"] = {spellID = 315281, level = "II (10/|cffffffff15|r/20)", value = 15},
	["6439"] = {spellID = 315282, level = "III (10/15/|cffffffff20|r)", value = 20},
	["6555"] = {spellID = 318266, level = "I (|cffffffff15|r/20/35)", value = 15},
	["6559"] = {spellID = 318492, level = "II (15/|cffffffff20|r/35)", value = 20},
	["6560"] = {spellID = 318496, level = "III (15/20/|cffffffff35|r)", value = 35},
	["6556"] = {spellID = 318268, level = "I (|cffffffff15|r/20/35)", value = 15},
	["6561"] = {spellID = 318493, level = "II (15/|cffffffff20|r/35)", value = 20},
	["6562"] = {spellID = 318497, level = "III (15/20/|cffffffff35|r)", value = 35},
	["6558"] = {spellID = 318270, level = "I (|cffffffff15|r/20/35)", value = 15},
	["6565"] = {spellID = 318495, level = "II (15/|cffffffff20|r/35)", value = 20},
	["6566"] = {spellID = 318499, level = "III (15/20/|cffffffff35|r)", value = 35},
	["6557"] = {spellID = 318269, level = "I (|cffffffff15|r/20/35)", value = 15},
	["6563"] = {spellID = 318494, level = "II (15/|cffffffff20|r/35)", value = 20},
	["6564"] = {spellID = 318498, level = "III (15/20/|cffffffff35|r)", value = 35},
	["6549"] = {spellID = 318280, level = "I (|cffffffff25|r/35/60)", value = 25},
	["6550"] = {spellID = 318485, level = "II (25/|cffffffff35|r/60)", value = 35},
	["6551"] = {spellID = 318486, level = "III (25/35/|cffffffff60|r)", value = 60},
	["6552"] = {spellID = 318274, level = "I (|cffffffff20|r/50/75)", value = 20},
	["6553"] = {spellID = 318487, level = "II (20/|cffffffff50|r/75)", value = 50},
	["6554"] = {spellID = 318488, level = "III (20/50/|cffffffff75|r)", value = 75},
	["6547"] = {spellID = 318303, level = "I (|cffffffff12|r/30)", value = 12},
	["6548"] = {spellID = 318484, level = "II (12/|cffffffff30|r)", value = 30},
	["6537"] = {spellID = 318276, level = "I (|cffffffff25|r/50/75)", value = 25},
	["6538"] = {spellID = 318477, level = "II (25/|cffffffff50|r/75)", value = 50},
	["6539"] = {spellID = 318478, level = "III (25/50/|cffffffff75|r)", value = 75},
	["6543"] = {spellID = 318481, level = "I (|cffffffff10|r/35/66)", value = 10},
	["6544"] = {spellID = 318482, level = "II (10/|cffffffff35|r/66)", value = 35},
	["6545"] = {spellID = 318483, level = "III (10/35/|cffffffff66|r)", value = 66},
	["6540"] = {spellID = 318286, level = "I (|cffffffff15|r/35/66)", value = 15},
	["6541"] = {spellID = 318479, level = "II (15/|cffffffff35|r/66)", value = 35},
	["6542"] = {spellID = 318480, level = "III (15/35/|cffffffff66|r)", value = 66},
	["6573"] = {spellID = 318272, level = "(|cffffffff15|r)", value = 15},
	["6546"] = {spellID = 318239, level = "(|cffffffff15|r)", value = 15},
	["6571"] = {spellID = 318293, level = "(|cffffffff30|r)", value = 30},
	["6572"] = {spellID = 316651, level = "(|cffffffff50|r)", value = 50},
	["6567"] = {spellID = 318294, level = "(|cffffffff35|r)", value = 35},
	["6568"] = {spellID = 316780, level = "(|cffffffff25|r)", value = 25},
	["6570"] = {spellID = 318299, level = "(|cffffffff20|r)", value = 20},
	["6569"] = {spellID = 317290, level = "(|cffffffff25|r)", value = 25},
}

local corruptionDataFix = {
	["172199"] = "6571", -- Faralos, Empire's Dream
	["172200"] = "6572", -- Sk'shuul Vaz
	["172191"] = "6567", -- An'zig Vra
	["172193"] = "6568", -- Whispering Eldritch Bow
	["172198"] = "6570", -- Mar'kowa, the Mindpiercer
	["172197"] = "6569", -- Unguent Caress
	["172227"] = "6544", -- Shard of the Black Empire
	["172196"] = "6541", -- Vorzz Yoq'al
	["174106"] = "6550", -- Qwor N'lyeth
	["172189"] = "6548", -- Eyestalk of Il'gynoth
	["174108"] = "6553", -- Shgla'yos, Astral Malignity
	["172187"] = "6539", -- Devastation's Hour
}

local linkCache = {}
local corruptionR, corruptionG, corruptionB = .584, .428, .82
local summaries = {}
local cloakResString = "(%d+) "..ITEM_MOD_CORRUPTION_RESISTANCE
local essenceTextureIDs = {
	[2967101] = true,
	[3193842] = true,
	[3193843] = true,
	[3193844] = true,
	[3193845] = true,
	[3193846] = true,
	[3193847] = true,
}

function Module:Corruption_Search(link)
	local value = linkCache[link]
	if not value then
		local itemID, itemString = string_match(link, "item:(%d+):([%-?%d:]+)")
		local isCorruptedWeapon = corruptionDataFix[itemID]
		if isCorruptedWeapon then
			value = corruptionData[isCorruptedWeapon]
			linkCache[link] = value
		else
			for index in string_gmatch(itemString, "%d+") do
				if corruptionData[index] then
					value = corruptionData[index]
					linkCache[link] = value
					break
				end
			end
		end
	end
	return value
end

local function getIconString(icon)
	return string_format("|T%s:14:14:0:0:64:64:5:59:5:59|t ", icon)
end

function Module:Corruption_Convert(name, icon, level)
	for i = 5, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		local text = line:GetText()
		if text and string_match(text, ITEM_MOD_CORRUPTION) then
			-- line:SetText(text.." - "..getIconString(icon)..name.." "..level)
			line:SetText("+"..getIconString(icon)..name.." "..level)
			return
		end
	end
end

function Module:Corruption_UpdateSpell(value)
	if not value.name or not value.icon then
		value.name, _, value.icon = GetSpellInfo(value.spellID)
	end
end

function Module:Corruption_Update()
	local link = select(2, self:GetItem())
	if link and IsCorruptedItem(link) then
		local value = Module:Corruption_Search(link)
		if value then
			Module:Corruption_UpdateSpell(value)
			Module.Corruption_Convert(self, value.name, value.icon, value.level)
		end
	end
end

function Module:Corruption_Summary(unit)
	table_wipe(summaries)

	for i = 1, 17 do
		local link = GetInventoryItemLink(unit, i)
		if link and IsCorruptedItem(link) then
			local value = Module:Corruption_Search(link)
			if value then
				Module:Corruption_UpdateSpell(value)
				summaries[value] = (summaries[value] or 0) + 1
			end
		end
	end
end

function Module:Corruption_Total()
	local total = 0
	for value, count in next, summaries do
		local corruptionValue = value.value
		total = total + corruptionValue * count
	end

	return total
end

function Module:Corruption_AddSummary()
	GameTooltip:AddLine(" ")

	for value, count in next, summaries do
		GameTooltip:AddLine("+"..count.." "..getIconString(value.icon)..value.name.." "..value.level, corruptionR, corruptionG, corruptionB)
	end

	if not next(summaries) then
		GameTooltip:AddLine(NONE, corruptionR,corruptionG,corruptionB)
	end

	GameTooltip:Show()
end

function Module:Corruption_PlayerSummary()
	Module:Corruption_Summary("player")
	Module:Corruption_AddSummary()
end

function Module:Corruption_SearchEssence()
	local resistance = 0
	KkthnxUI_ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	KkthnxUI_ScanTooltip:SetInventoryItem(InspectFrame.unit, 2)

	for i = 1, 10 do
		local tex = _G[KkthnxUI_ScanTooltip:GetName().."Texture"..i]
		local texture = tex and tex:IsShown() and tex:GetTexture()
		if texture and essenceTextureIDs[texture] then
			resistance = 10
			break
		end
	end

	return resistance
end

function Module:Corruption_SearchCloak()
	local resistance = 0
	KkthnxUI_ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	KkthnxUI_ScanTooltip:SetInventoryItem(InspectFrame.unit, 15)

	for i = 1, KkthnxUI_ScanTooltip:NumLines() do
		local line = _G[KkthnxUI_ScanTooltip:GetName().."TextLeft"..i]
		local text = line and line:GetText()
		local value = text and string_match(text, cloakResString)
		if value then
			resistance = value
		end
	end

	return resistance
end

function Module:Corruption_InspectSummary()
	if not self.guid then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CORRUPTION_TOOLTIP_TITLE, 1,1,1)
	GameTooltip:AddLine(CORRUPTION_DESCRIPTION, 1,.8,0, 1)

	Module:Corruption_Summary(InspectFrame.unit)

	local total = Module:Corruption_Total()
	local essence = Module:Corruption_SearchEssence()
	local cloak = Module:Corruption_SearchCloak()
	local resistance = essence + cloak

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(CORRUPTION_TOOLTIP_LINE, total, 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(CORRUPTION_RESISTANCE_TOOLTIP_LINE, resistance, 1,1,1, 1,1,1)
	GameTooltip:AddDoubleLine(TOTAL_CORRUPTION_TOOLTIP_LINE, math_max((total - resistance), 0), corruptionR, corruptionG, corruptionB, corruptionR, corruptionG, corruptionB)

	Module:Corruption_AddSummary()
end

function Module:Corruption_CreateEye()
	if not InspectFrame.__eye then
		local eye = CreateFrame("Button", nil, InspectFrame)
		eye:SetPoint("BOTTOM", InspectHandsSlot, "TOP", 0, 10)
		eye:SetSize(50, 50)
		eye:SetScript("OnEnter", Module.Corruption_InspectSummary)
		eye:SetScript("OnLeave", K.HideTooltip)

		local tex = eye:CreateTexture()
		tex:SetPoint("TOPRIGHT", 18, 5)
		tex:SetSize(60, 60)
		tex:SetAtlas("bfa-threats-cornereye")

		local hl = eye:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints(tex)
		hl:SetAtlas("bfa-threats-cornereye")
		hl:SetBlendMode("ADD")

		InspectFrame.__eye = eye
	end
end

function Module:Corruption_UpdateInspect(...)
	if not InspectFrame then
		return
	end

	Module:Corruption_CreateEye()

	local guid = ...
	local eye = InspectFrame.__eye
	if InspectFrame.unit and UnitGUID(InspectFrame.unit) == guid then
		eye.guid = guid
	else
		eye.guid = nil
	end
end

function Module:CreateCorruptionRank()
	if not C["Tooltip"].CorruptionRank then
		return
	end

	if IsAddOnLoaded("CorruptionTooltips") then
		return
	end

	if IsAddOnLoaded("CorruptionNameTooltips") then
		return
	end

	GameTooltip:HookScript("OnTooltipSetItem", Module.Corruption_Update)
	ItemRefTooltip:HookScript("OnTooltipSetItem", Module.Corruption_Update)
	ShoppingTooltip1:HookScript("OnTooltipSetItem", Module.Corruption_Update)
	ShoppingTooltip2:HookScript("OnTooltipSetItem", Module.Corruption_Update)
	EmbeddedItemTooltip:HookScript("OnTooltipSetItem", Module.Corruption_Update)

	hooksecurefunc("CharacterFrameCorruption_OnEnter", Module.Corruption_PlayerSummary)
	CharacterStatsPane.ItemLevelFrame.Corruption:HookScript("OnEnter", Module.Corruption_PlayerSummary)
	K:RegisterEvent("INSPECT_READY", Module.Corruption_UpdateInspect)
end