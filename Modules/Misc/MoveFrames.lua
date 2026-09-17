--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/MoveFrames.lua
	Purpose:
		Drag Blizzard's windows where you want them and have them stay there.

		Making a window movable is the easy half. The hard half is that most of
		them are owned by the UI panel system, and UpdateUIPanelPositions does an
		unconditional ClearAllPoints followed by SetPoint on every managed frame
		with no check for whether the player placed it, so a dragged window snaps
		back the next time any panel opens.

		The way out is in ShowUIPanel itself: a frame with no "area" attribute
		takes an early return and is shown without ever reaching the panel
		manager. HideUIPanel has the same early return, so closing still behaves.
		Clearing that attribute is therefore the whole trick, and the frame is
		left alone from then on.

		Positions are saved per frame and re-applied on show, because a window
		that forgets where it was put is worse than one that never moved. Off by
		default.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("MoveFrames")

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local ipairs, pairs = ipairs, pairs
local tinsert = table.insert

-- The windows worth dragging. Anything Edit Mode already owns is left out, and
-- so is anything secure enough that moving it would risk taint in combat.
local FRAMES = {
	"CharacterFrame",
	"SpellBookFrame",
	"PlayerSpellsFrame",
	"CollectionsJournal",
	"EncounterJournal",
	"AchievementFrame",
	"FriendsFrame",
	"GuildFrame",
	"CommunitiesFrame",
	"PVPUIFrame",
	"LFGListFrame",
	"MailFrame",
	"MerchantFrame",
	"BankFrame",
	"TradeFrame",
	"QuestLogFrame",
	"GossipFrame",
	"QuestFrame",
	"TaxiFrame",
	"AuctionHouseFrame",
	"ProfessionsFrame",
	"InspectFrame",
	"ItemUpgradeFrame",
	"VoidStorageFrame",
	"TransmogrifyFrame",
	"WardrobeFrame",
	"ClassTrainerFrame",
	"GuildBankFrame",
	"MacroFrame",
	"WeeklyRewardsFrame",
	"DressUpFrame",
}

-- Matches the TitleContainer height on DefaultPanelBaseTemplate, so a window
-- without one gets a handle the same size as the rest.
local TITLE_HEIGHT = 20

local tracked = {}
-- Names already handed to UISpecialFrames, so a rescan cannot add one twice.
local detached = {}

local function SavedPoint(name)
	local db = C.Misc.MovedFrames
	return db and db[name]
end

-- Take the frame out of the panel system. With no area attribute, ShowUIPanel
-- and HideUIPanel both early out and hand the frame straight to Show or Hide,
-- which is what stops it being re-anchored behind our back.
--
-- allowOtherPanels keeps the remaining managed windows from being closed when
-- this one opens, since it is no longer part of the arrangement they share.
local function Detach(frame, name)
	frame:SetAttribute("UIPanelLayout-area", nil)
	frame:SetAttribute("UIPanelLayout-enabled", false)
	frame:SetAttribute("UIPanelLayout-allowOtherPanels", true)

	-- Escape closed these through the panel manager. Detached, they need to say
	-- so themselves or they can only be closed by their own button.
	if name and not detached[name] then
		detached[name] = true
		tinsert(_G.UISpecialFrames, name)
	end
end

local function Restore(frame)
	local saved = SavedPoint(frame.KKUI_MoveKey)
	if saved then
		frame:ClearAllPoints()
		frame:SetPoint(saved[1], UIParent, saved[2], saved[3], saved[4])
		return
	end

	-- The panel system was the only thing anchoring these windows, so a detached
	-- one that has never been dragged can end up with no points at all and render
	-- nowhere. Centre it the first time rather than leave it lost.
	if frame:GetNumPoints() == 0 then
		frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	end
end

-- The handle is not the window. Dragging is done from a strip across the title
-- bar, so these start and stop the window the handle belongs to.
local function OnDragStart(handle)
	-- Dragging a secure frame in combat is a taint risk for no benefit, and the
	-- window is rarely the thing that matters mid pull.
	if InCombatLockdown() then
		return
	end
	handle.KKUI_Window:StartMoving()
end

local function OnDragStop(handle)
	local frame = handle.KKUI_Window
	frame:StopMovingOrSizing()

	local point, _, relativePoint, x, y = frame:GetPoint()
	if not point then
		return
	end

	local db = C.Misc.MovedFrames
	if not db then
		db = {}
		C.Misc.MovedFrames = db
	end
	-- Snapped so a dragged window lands on the pixel grid like everything else.
	db[frame.KKUI_MoveKey] = { point, relativePoint, K.Pixel.Snap(x), K.Pixel.Snap(y) }
	K:SetConfig({ "Misc", "MovedFrames" }, db)
end

local function MakeMovable(frame, name)
	if not frame or tracked[frame] or frame:GetObjectType() ~= "Frame" then
		return
	end
	tracked[frame] = true

	frame.KKUI_MoveKey = name
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)

	-- Dragging the body does not work, because every one of these windows is
	-- covered by children that take the mouse first, so the parent never sees the
	-- drag. Blizzard already provides the right handle: DefaultPanelBaseTemplate
	-- gives most of them a TitleContainer across the title bar at frame level 510,
	-- above the rest of the window. Anything without one gets a strip of our own
	-- in the same place.
	local handle = frame.TitleContainer
	if not handle then
		handle = CreateFrame("Frame", nil, frame)
		handle:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
		handle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
		handle:SetHeight(TITLE_HEIGHT)
		handle:SetFrameLevel(frame:GetFrameLevel() + 20)
	end

	handle.KKUI_Window = frame
	handle:EnableMouse(true)
	handle:RegisterForDrag("LeftButton")
	handle:HookScript("OnDragStart", OnDragStart)
	handle:HookScript("OnDragStop", OnDragStop)
	frame.KKUI_Handle = handle

	Detach(frame, name)

	-- Re-apply on every show. Blizzard rebuilds a few of these windows as they
	-- open, so setting the point once at login does not hold.
	frame:HookScript("OnShow", Restore)
	if frame:IsShown() then
		Restore(frame)
	end
end

local function Scan()
	for _, name in ipairs(FRAMES) do
		MakeMovable(_G[name], name)
	end
end

-- Most of these windows live in load on demand addons, so the list is walked
-- again whenever one of them arrives rather than only at login.
function Module:ADDON_LOADED()
	Scan()
end

function Module:ResetPositions()
	K:SetConfig({ "Misc", "MovedFrames" }, {})
	for frame in pairs(tracked) do
		frame:ClearAllPoints()
	end
	K.Print("Frame positions reset. Reload to put them back where Blizzard had them.")
end

function Module:OnEnable()
	if not C.Misc.MoveFrames then
		return
	end

	Scan()
	self:RegisterEvent("ADDON_LOADED", "ADDON_LOADED")
end
