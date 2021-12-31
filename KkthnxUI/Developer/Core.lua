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

local DEV = K:NewModule("Playground")

function DEV:CreateHideMadeByName()
	for i = 2, self:NumLines() do
		local line = _G[self:GetName().."TextLeft"..i]
		local text = line and line:GetText()
		if text and text ~= "" and string.match(text, string.gsub(_G.ITEM_CREATED_BY, "%%s", ".+")) then
			line:SetText("")
			break
		end
	end
end

-- Credit: TinyChat
local function GetHyperlink(hyperlink, texture)
	if (not texture) then
		return hyperlink
	else
		return "|T" .. texture .. ":0:0:0:0:64:64:5:59:5:59|t" .. hyperlink
	end
end

local cache = {}

local function AddChatIcon(link, linkType, id)
	if not link then
        return
    end

	if cache[link] then
        return cache[link]
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
		local info = C_CurrencyInfo.GetCurrencyInfo(id)
		texture = info and info.iconFileID
	elseif linkType == "battlepet" then
		texture = select(2, C_PetJournal.GetPetInfoBySpeciesID(id))
	elseif linkType == "battlePetAbil" then
		texture = select(3, C_PetBattles.GetAbilityInfoByID(id))
	elseif linkType == "azessence" then
		local info = C_AzeriteEssence.GetEssenceInfo(id)
		texture = info and info.icon
	elseif linkType == "conduit" then
		local spell = C_Soulbinds.GetConduitSpellID(id, 1)
		texture = spell and GetSpellTexture(spell)
	end

	cache[link] = GetHyperlink(link, texture)

	return cache[link]
end

local function AddTradeIcon(link, id)
	if not link then return end

	if not cache[link] then
		cache[link] = GetHyperlink(link, GetSpellTexture(id))
	end

	return cache[link]
end

function DEV:ChatLinkfilter(_, msg, ...)
	msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x.-|H(%a+):(%d+).-|h.-|h.-|r)", AddChatIcon)
	msg = gsub(msg, "(|c%x%x%x%x%x%x%x%x.-|Htrade:[^:]-:(%d+).-|h.-|h.-|r)", AddTradeIcon)

	return false, msg, ...
end

function DEV:OnEnable()
    GameTooltip:SetScript("OnTooltipSetItem", DEV.HideMadeByName)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", DEV.ChatLinkfilter)
end