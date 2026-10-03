--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/MoveFrames.lua
	Purpose:
		Drag Blizzard's windows where you want them and have them stay there.

		EXPERIMENTAL. Read the notes before changing anything here.

		Making a window movable is the easy half. The hard half is that most of
		them are owned by the UI panel system, and UpdateUIPanelPositions does an
		unconditional ClearAllPoints followed by SetPoint on every managed frame
		with no check for whether the player placed it, so a dragged window snaps
		back the next time any panel opens.

		The way out is in ShowUIPanel itself: a frame with no "area" attribute
		takes an early return and is shown without ever reaching the panel
		manager. HideUIPanel has the same early return, so closing still behaves.

		What is not established is whether writing those attributes taints the show
		path. ShowUIPanel reads "area" from secure code, and a value written by
		insecure code can taint whoever reads it. Nothing in the reference set
		touches the panel layout this way (only a world map fix does, for one frame),
		so there is no known safe precedent. That is why this is off by default and
		why everything else here is kept as small as it can be:

			- State lives in weak tables of ours. Nothing is written onto a Blizzard
			  frame as a field.
			- The drag handle is our own frame laid over the title bar. Blizzard's
			  title container is not touched, so its mouse state and scripts are
			  left as they were.
			- Only HookScript is used on Blizzard frames, never SetScript.

		Positions are saved per frame and re-applied on show, because a window
		that forgets where it was put is worse than one that never moved.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("MoveFrames")

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local ipairs, pairs = ipairs, pairs
local tinsert = table.insert
local setmetatable = setmetatable

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

-- The strip across the title bar that starts a drag. Same geometry Blizzard's own
-- title container uses on the shared panel template (30 in from the left to clear
-- the portrait, 24 in from the right to clear the close button, 20 tall), so the
-- window's buttons are never covered.
local HANDLE_LEFT = 30
local HANDLE_RIGHT = 24
local HANDLE_HEIGHT = 20

-- All state is kept here, keyed by frame, so no field is ever written onto a
-- Blizzard frame. Weak keys let a frame that goes away take its entry with it.
local tracked = setmetatable({}, { __mode = "k" }) -- window -> saved key name
local windowOf = setmetatable({}, { __mode = "k" }) -- our handle -> its window
local detached = {} -- names already added to UISpecialFrames, so a rescan cannot add one twice

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
	if not detached[name] then
		detached[name] = true
		tinsert(_G.UISpecialFrames, name)
	end
end

local function Restore(frame)
	local name = tracked[frame]
	local saved = name and SavedPoint(name)
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

local function OnDragStart(handle)
	-- Dragging a secure frame in combat is a taint risk for no benefit, and the
	-- window is rarely the thing that matters mid pull.
	if InCombatLockdown() then
		return
	end
	windowOf[handle]:StartMoving()
end

local function OnDragStop(handle)
	local frame = windowOf[handle]
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
	db[tracked[frame]] = { point, relativePoint, K.Pixel.Snap(x), K.Pixel.Snap(y) }
	K:SetConfig({ "Misc", "MovedFrames" }, db)
end

local function MakeMovable(frame, name)
	if not frame or tracked[frame] or frame:GetObjectType() ~= "Frame" then
		return
	end
	tracked[frame] = name

	frame:SetMovable(true)
	frame:SetClampedToScreen(true)

	-- Dragging the body does not work, because every one of these windows is
	-- covered by children that take the mouse first, so the parent never sees the
	-- drag. Our own strip over the title bar takes it instead. It is a child of the
	-- window so it moves and hides with it, and it is ours, so enabling its mouse
	-- and giving it drag scripts changes nothing on a Blizzard frame.
	local handle = CreateFrame("Frame", nil, frame)
	handle:SetPoint("TOPLEFT", frame, "TOPLEFT", HANDLE_LEFT, -1)
	handle:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -HANDLE_RIGHT, -1)
	handle:SetHeight(HANDLE_HEIGHT)
	handle:SetFrameLevel(frame:GetFrameLevel() + 20)
	handle:EnableMouse(true)
	handle:RegisterForDrag("LeftButton")
	handle:SetScript("OnDragStart", OnDragStart)
	handle:SetScript("OnDragStop", OnDragStop)
	windowOf[handle] = frame

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
