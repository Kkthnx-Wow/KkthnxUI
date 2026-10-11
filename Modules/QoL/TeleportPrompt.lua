--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/TeleportPrompt.lua
	Purpose:
		When you join a Group Finder group for a dungeon you can teleport to, show
		a small prompt with the dungeon name and a button that casts the teleport.
		It closes when you enter the dungeon, leave the group, start a fight or
		cast the spell.

		Safety, since this touches the Group Finder and a protected button:
			The teleport spell is always a number from the table below, never a value
			read from the Group Finder, which can be hidden from addons.
			The button is made once at login. Its spell is only changed out of combat.
			Nothing on any Blizzard frame is hooked, replaced or written to.
			The dungeon is read on joining, when the game allows it, inside a protected
			call, so a hidden value can only make the prompt skip, never error.

		The table lists the teleports for the current season's dungeons. Each row is
		the teleport spell and the dungeon's id in the group finder. It needs the
		new season's rows each time the dungeon pool changes.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local C_SpellBook = C_SpellBook
local GetLFGDungeonInfo = GetLFGDungeonInfo
local C_LFGList = C_LFGList
local C_Spell = C_Spell
local pcall = pcall
local ipairs = ipairs
local lower = string.lower
local find = string.find

local SEASON_TELEPORTS = {
	{ spell = 1286801, dungeon = 3102 },
	{ spell = 1286804, dungeon = 3106 },
	{ spell = 1286807, dungeon = 3051 },
	{ spell = 1286809, dungeon = 3090 },
	{ spell = 1286812, dungeon = 3191 },
	{ spell = 393256, dungeon = 2361 },
	{ spell = 1286828, dungeon = 1694 },
	{ spell = 1286831, dungeon = 1785 },
}

local popup, button

-- The group finder name of the activity the joined group is for, or nil.
local function JoinedActivityName(searchResultID)
	local result = C_LFGList.GetSearchResultInfo(searchResultID)
	if not result or IsSecret(result) then
		return
	end
	local activities = result.activityIDs
	if not activities or IsSecret(activities) then
		return
	end
	local activityID = activities[1]
	if not activityID or IsSecret(activityID) then
		return
	end
	local info = C_LFGList.GetActivityInfoTable(activityID)
	local name = info and info.fullName
	if not name or IsSecret(name) then
		return
	end
	return lower(name)
end

-- The teleport the player knows for a dungeon name, if any.
local function TeleportFor(activityName)
	for _, row in ipairs(SEASON_TELEPORTS) do
		local dungeon = GetLFGDungeonInfo(row.dungeon)
		if dungeon and find(activityName, lower(dungeon), 1, true) and C_SpellBook.IsSpellKnown(row.spell) then
			return row.spell, dungeon
		end
	end
end

local function Hide()
	if popup then
		popup:Hide()
	end
end

local function Show(spellID, dungeon)
	-- The button is protected, so its spell can only change out of combat.
	if InCombatLockdown() then
		return
	end
	button:SetAttribute("spell", spellID)
	popup.Icon:SetTexture(C_Spell.GetSpellTexture(spellID))
	popup.Name:SetText(dungeon)
	popup:Show()
end

local function OnJoined(_, _, searchResultID)
	if not popup then
		return
	end
	local ok, name = pcall(JoinedActivityName, searchResultID)
	if not ok or not name then
		return
	end
	local spellID, dungeon = TeleportFor(name)
	if spellID then
		Show(spellID, dungeon)
	end
end

local function Build()
	popup = CreateFrame("Frame", "KKUI_TeleportPrompt", UIParent)
	popup:SetSize(180, 92)
	popup:SetFrameStrata("DIALOG")
	popup:Hide()
	K.CreateGradientBackground(popup, 0.92)
	K.CreateBorder(popup)

	local title = popup:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 11, K.FontOutlineStyle())
	title:SetPoint("TOP", 0, -8)
	title:SetText(L["Teleport to"])
	title:SetTextColor(K.Colors.muted[1], K.Colors.muted[2], K.Colors.muted[3])

	popup.Name = popup:CreateFontString(nil, "OVERLAY")
	K.SetFont(popup.Name, 13, K.FontOutlineStyle())
	popup.Name:SetPoint("TOP", title, "BOTTOM", 0, -3)
	popup.Name:SetWidth(164)
	popup.Name:SetWordWrap(false)

	button = CreateFrame("Button", "KKUI_TeleportButton", popup, "SecureActionButtonTemplate")
	button:SetSize(36, 36)
	button:SetPoint("BOTTOM", 0, 10)
	button:RegisterForClicks("AnyUp", "AnyDown")
	button:SetAttribute("type", "spell")
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints()
	button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	popup.Icon = button.Icon
	K.CreateBorder(button)
	button:HookScript("PostClick", Hide)

	K.CreateMover(popup, "TeleportPrompt", L["Teleport Prompt"], { "CENTER", UIParent, "CENTER", 0, 260 })
end

function Module:SetupTeleportPrompt()
	Build()
	self:RegisterEvent("LFG_LIST_JOINED_GROUP", OnJoined)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", Hide)
	self:RegisterEvent("GROUP_LEFT", Hide)
	self:RegisterEvent("PLAYER_REGEN_DISABLED", Hide)
end
