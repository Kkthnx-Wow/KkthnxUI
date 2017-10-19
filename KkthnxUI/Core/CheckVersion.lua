local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local tostring = tostring

-- Wow API
local IsInGroup = _G.IsInGroup
local IsInGuild = _G.IsInGuild
local IsInRaid = _G.IsInRaid
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE
local SendAddonMessage = _G.SendAddonMessage
local StaticPopup_Show = _G.StaticPopup_Show
local ChatEdit_FocusActiveWindow = _G.ChatEdit_FocusActiveWindow

local MyName = UnitName("player") .. "-" .. GetRealmName()
MyName = gsub(MyName, "%s+", "")

local function VersionCheck(_, event, prefix, message, _, sender)
	if (event == "CHAT_MSG_ADDON") then
		if (prefix ~= "KKTHNXUI_VERSION") or (sender == MyName) then -- NOTE: prefix is too long. look into this.
			return
		end

		if (tonumber(message) ~= nil and tonumber(message) > tonumber(K.Version)) then -- We recieved a higher version, we're outdated. :(
			K.Print(L.Misc.UIOutdated)
			if ((tonumber(message) - tonumber(K.Version)) >= 0.05) then
				StaticPopup_Show("KKTHNXUI_UPDATE")
			end
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
			K.Delay(2, SendAddonMessage, "KKTHNXUI_VERSION", K.Version, Channel)
		end
	end
end

RegisterAddonMessagePrefix("KKTHNXUI_VERSION")

local Module = CreateFrame("Frame")
Module:RegisterEvent("PLAYER_ENTERING_WORLD")
Module:RegisterEvent("GROUP_ROSTER_UPDATE")
Module:RegisterEvent("CHAT_MSG_ADDON")
Module:SetScript("OnEvent", VersionCheck)