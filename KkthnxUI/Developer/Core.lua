local K, C, L = unpack(KkthnxUI)

K.Devs = {
	["Kkthnx-Arena 52"] = true,
	["Kkthnx-Oribos"] = true,
    ["Ashanarra-Oribos"] = true
}

local function isDeveloper()
	return K.Devs[K.Name.."-"..K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

local DEV = K:NewModule("Playground")

local _G = _G
local string_gsub = _G.string.gsub

local C_AzeriteEssence_GetEssenceInfo = _G.C_AzeriteEssence.GetEssenceInfo
local C_CurrencyInfo_GetCurrencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo
local C_PetBattles_GetAbilityInfoByID = _G.C_PetBattles.GetAbilityInfoByID
local C_PetJournal_GetPetInfoBySpeciesID = _G.C_PetJournal.GetPetInfoBySpeciesID
local C_Soulbinds_GetConduitSpellID = _G.C_Soulbinds.GetConduitSpellID
local GetAchievementInfo = _G.GetAchievementInfo
local GetItemIcon = _G.GetItemIcon
local GetPvpTalentInfoByID = _G.GetPvpTalentInfoByID
local GetSpellTexture = _G.GetSpellTexture
local GetTalentInfoByID = _G.GetTalentInfoByID

local chatIconCache = {}
local eventList = {
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_WHISPER_INFORM",
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_INSTANCE_CHAT",
	"CHAT_MSG_INSTANCE_CHAT_LEADER",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_RAID_WARNING",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_WHISPER_INFORM",
	"CHAT_MSG_LOOT",
	"CHAT_MSG_CURRENCY",
}

local function GetHyperlink(hyperlink, texture)
	if (not texture) then
		return hyperlink
	else
		return "|T"..texture..":0:0:0:0:64:64:5:59:5:59|t"..hyperlink
	end
end

local function AddChatIcon(link, linkType, id)
	if not link then
		return
	end

	if chatIconCache[link] then
		return chatIconCache[link]
	end

	local texture
	if linkType == "spell" or linkType == "enchant" then
		texture = GetSpellTexture(id)
	elseif linkType == "item" or linkType == "keystone" then
		texture = GetItemIcon(id)
	elseif linkType == "talent" then
		texture = select(3, GetTalentInfoByID(id))
	elseif linkType == "pvptal" then
		texture = select(3, GetPvpTalentInfoByID(id))
	elseif linkType == "achievement" then
		texture = select(10, GetAchievementInfo(id))
	elseif linkType == "currency" then
		local info = C_CurrencyInfo_GetCurrencyInfo(id)
		texture = info and info.iconFileID
	elseif linkType == "battlepet" then
		texture = select(2, C_PetJournal_GetPetInfoBySpeciesID(id))
	elseif linkType == "battlePetAbil" then
		texture = select(3, C_PetBattles_GetAbilityInfoByID(id))
	elseif linkType == "azessence" then
		local info = C_AzeriteEssence_GetEssenceInfo(id)
		texture = info and info.icon
	elseif linkType == "conduit" then
		local spell = C_Soulbinds_GetConduitSpellID(id, 1)
		texture = spell and GetSpellTexture(spell)
	end

	chatIconCache[link] = GetHyperlink(link, texture)

	return chatIconCache[link]
end

local function AddTradeIcon(link, id)
	if not link then
		return
	end

	if not chatIconCache[link] then
		chatIconCache[link] = GetHyperlink(link, GetSpellTexture(id))
	end

	return chatIconCache[link]
end

function DEV:ChatLinkfilter(_, msg, ...)
	-- if C["Chat"].Icons then
		msg = string_gsub(msg, "(|c%x%x%x%x%x%x%x%x.-|H(%a+):(%d+).-|h.-|h.-|r)", AddChatIcon)
		msg = string_gsub(msg, "(|c%x%x%x%x%x%x%x%x.-|Htrade:[^:]-:(%d+).-|h.-|h.-|r)", AddTradeIcon)
	-- end

	return false, msg, ...
end

function DEV:OnEnable()
	for _, event in pairs(eventList) do
		ChatFrame_AddMessageEventFilter(event, DEV.ChatLinkfilter)
	end
end