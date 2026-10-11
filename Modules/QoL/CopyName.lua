--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/CopyName.lua
	Purpose:
		Add "Copy Name" to the right click menu of players, so a full name and
		realm can be pasted into a whisper, an invite, a report or a website.

		Uses the menu system's own extension point, which runs the added entry in
		a protected-safe context, so the Blizzard menus are never replaced or
		hooked. Opens the text in a small box that is already selected.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret

-- The player menus. Each shares one context table with the player's name.
local TAGS = {
	"MENU_UNIT_SELF",
	"MENU_UNIT_PLAYER",
	"MENU_UNIT_ENEMY_PLAYER",
	"MENU_UNIT_PARTY",
	"MENU_UNIT_RAID_PLAYER",
	"MENU_UNIT_FRIEND",
	"MENU_UNIT_FRIEND_OFFLINE",
	"MENU_UNIT_TARGET",
	"MENU_UNIT_FOCUS",
	"MENU_UNIT_GUILD",
	"MENU_UNIT_GUILD_OFFLINE",
	"MENU_UNIT_COMMUNITIES_GUILD_MEMBER",
	"MENU_UNIT_COMMUNITIES_WOW_MEMBER",
	"MENU_UNIT_RECENT_ALLY",
	"MENU_UNIT_CHAT_ROSTER",
}

local function FullName(contextData)
	local name = contextData and contextData.name
	if not name or IsSecret(name) or name == "" then
		return
	end
	local server = contextData.server
	if server and not IsSecret(server) and server ~= "" then
		return name .. "-" .. server
	end
	return name
end

local function Extend(_, rootDescription, contextData)
	local name = FullName(contextData)
	if not name then
		return
	end
	rootDescription:CreateDivider()
	rootDescription:CreateButton(L["Copy Name"], function()
		K.ShowCopyText(L["Copy Name"], name)
	end)
end

function Module:SetupCopyName()
	for _, tag in ipairs(TAGS) do
		Menu.ModifyMenu(tag, Extend)
	end
end
