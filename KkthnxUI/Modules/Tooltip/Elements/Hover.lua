local K, L = KkthnxUI[1], KkthnxUI[3]
local Module = K:GetModule("Tooltip")

local strmatch, strsplit, tonumber = string.match, string.split, tonumber
local INSTANCE, BOSS = INSTANCE, BOSS
local BattlePetToolTip_Show = BattlePetToolTip_Show
local C_EncounterJournal_GetSectionInfo = C_EncounterJournal.GetSectionInfo
local EJ_GetInstanceInfo, EJ_GetEncounterInfo, GetDifficultyInfo = EJ_GetInstanceInfo, EJ_GetEncounterInfo, GetDifficultyInfo

local orig1, orig2, sectionInfo = {}, {}, {}
local linkTypes = {
	achievement = true,
	azessence = true,
	conduit = true,
	currency = true,
	enchant = true,
	glyph = true,
	instancelock = true,
	item = true,
	keystone = true,
	mawpower = true,
	mount = true,
	quest = true,
	spell = true,
	talent = true,
	unit = true,
}

function Module:HyperLink_SetPet(link)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", -3, 5)
	GameTooltip:Show()
	local _, speciesID, level, breedQuality, maxHealth, power, speed = strsplit(":", link)
	BattlePetToolTip_Show(tonumber(speciesID), tonumber(level), tonumber(breedQuality), tonumber(maxHealth), tonumber(power), tonumber(speed))
end

function Module:HyperLink_GetSectionInfo(id)
	local info = sectionInfo[id]
	if not info then
		info = C_EncounterJournal_GetSectionInfo(id)
		sectionInfo[id] = info
	end
	return info
end

function Module:HyperLink_SetJournal(link)
	local _, idType, id, diffID = strsplit(":", link)
	local name, description, icon, idString
	if idType == "0" then
		name, description = EJ_GetInstanceInfo(id)
		idString = INSTANCE .. "ID:"
	elseif idType == "1" then
		name, description = EJ_GetEncounterInfo(id)
		idString = BOSS .. "ID:"
	elseif idType == "2" then
		local info = Module:HyperLink_GetSectionInfo(id)
		name, description, icon = info.title, info.description, info.abilityIcon
		name = icon and "|T" .. icon .. ":20:20:0:0:64:64:5:59:5:59:20|t " .. name or name
		idString = L["Section"] .. "ID:"
	end
	if not name then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", -3, 5)
	GameTooltip:AddDoubleLine(name, GetDifficultyInfo(diffID))
	GameTooltip:AddLine(description, 1, 1, 1, 1)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(idString, K.InfoColor .. id)
	GameTooltip:Show()
end

function Module:HyperLink_SetTypes(link)
	GameTooltip.__isHoverTip = true
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", -3, 5)
	GameTooltip:SetHyperlink(link)
	GameTooltip:Show()
end

function Module:HyperLink_OnEnter(link, ...)
	local linkType = strmatch(link, "^([^:]+)")
	if linkType then
		if linkType == "battlepet" then
			Module.HyperLink_SetPet(self, link)
		elseif linkType == "journal" then
			Module.HyperLink_SetJournal(self, link)
		elseif linkTypes[linkType] then
			Module.HyperLink_SetTypes(self, link)
		end
	end

	if orig1[self] then
		return orig1[self](self, link, ...)
	end
end

function Module:HyperLink_OnLeave(_, ...)
	BattlePetTooltip:Hide()
	GameTooltip:Hide()
	GameTooltip.__isHoverTip = nil

	if orig2[self] then
		return orig2[self](self, ...)
	end
end

for i = 1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame" .. i]
	orig1[frame] = frame:GetScript("OnHyperlinkEnter")
	frame:SetScript("OnHyperlinkEnter", Module.HyperLink_OnEnter)
	orig2[frame] = frame:GetScript("OnHyperlinkLeave")
	frame:SetScript("OnHyperlinkLeave", Module.HyperLink_OnLeave)
end

local function hookCommunitiesFrame(event, addon)
	if addon == "Blizzard_Communities" then
		CommunitiesFrame.Chat.MessageFrame:SetScript("OnHyperlinkEnter", Module.HyperLink_OnEnter)
		CommunitiesFrame.Chat.MessageFrame:SetScript("OnHyperlinkLeave", Module.HyperLink_OnLeave)

		K:UnregisterEvent(event, hookCommunitiesFrame)
	end
end
K:RegisterEvent("ADDON_LOADED", hookCommunitiesFrame)
