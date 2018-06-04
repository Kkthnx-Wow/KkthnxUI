local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("VersionCheck", "AceEvent-3.0")

local _G = _G
local gsub = gsub
local tonumber = tonumber

local GetAddOnMetadata = _G.GetAddOnMetadata
local GetRealmName = _G.GetRealmName
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local IsInRaid = _G.IsInRaid
local RegisterAddonMessagePrefix = _G.RegisterAddonMessagePrefix
local SendAddonMessage = _G.SendAddonMessage
local UnitName = _G.UnitName

local Version = tonumber(GetAddOnMetadata("KkthnxUI", "Version"))
local MyName = UnitName("player") .. "-" .. GetRealmName()
MyName = gsub(MyName, "%s+", "")

function Module:CheckIt(event, prefix, message, _, sender)
	if (event == "CHAT_MSG_ADDON") then
		if (prefix ~= "KkthnxUIVersion") or (sender == MyName) then
			return
		end

		if (tonumber(message) > Version) then -- We recieved a higher version, we're outdated. :(
			K.Print(L["Miscellaneous"].UIOutdated)
			self:UnregisterEvent("CHAT_MSG_ADDON")
		end
	else
		-- Tell everyone what version we use.
		local Channel

		if IsInRaid() then
			Channel = (not IsInRaid(LE_PARTY_CATEGORY_HOME) and IsInRaid(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "RAID"
		elseif IsInGroup() then
			Channel = (not IsInGroup(LE_PARTY_CATEGORY_HOME) and IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and "INSTANCE_CHAT" or "PARTY"
		elseif IsInGuild() then
			Channel = "GUILD"
		end

		if Channel then -- Putting a small delay on the call just to be certain it goes out.
			K.Delay(2, SendAddonMessage, "KkthnxUIVersion", Version, Channel)
		end
	end
end

function Module:OnInitialize()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckIt")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "CheckIt")
	self:RegisterEvent("CHAT_MSG_ADDON", "CheckIt")

	RegisterAddonMessagePrefix("KkthnxUIVersion")
end