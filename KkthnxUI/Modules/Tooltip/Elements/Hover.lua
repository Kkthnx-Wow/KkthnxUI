local K, _, L = unpack(KkthnxUI)
local Module = K:GetModule("Tooltip")

local _G = _G
local string_match = _G.string.match
local string_split = _G.string.split
local tonumber = _G.tonumber

local BOSS = _G.BOSS
local C_EncounterJournal_GetSectionInfo = _G.C_EncounterJournal.GetSectionInfo
local EJ_GetEncounterInfo = _G.EJ_GetEncounterInfo
local EJ_GetInstanceInfo = _G.EJ_GetInstanceInfo
local GameTooltip = _G.GameTooltip
local GetDifficultyInfo = _G.GetDifficultyInfo
local INSTANCE = _G.INSTANCE
local NUM_CHAT_WINDOWS = _G.NUM_CHAT_WINDOWS

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
	quest = true,
	spell = true,
	talent = true,
	unit = true,
}

function Module:HyperLink_SetPet(link)
	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", -3, 5)
	GameTooltip:Show()

	local _, speciesID, level, breedQuality, maxHealth, power, speed = string_split(":", link)
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
	local _, idType, id, diffID = string_split(":", link)
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
	local linkType = string_match(link, "^([^:]+)")
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
