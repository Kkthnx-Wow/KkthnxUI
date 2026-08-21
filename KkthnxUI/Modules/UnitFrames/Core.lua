--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Core.lua
	Purpose:
		UnitFrames module entry point. Owns the shared constants, the stacking
		helpers every element builder uses, and the spawn pass. The look of an
		individual unit lives in Units/, and reusable element builders live in
		Elements/.

		Geometry follows the original KkthnxUI: health and power are two separate
		bordered bars stacked with a gap, so a unit's outer height is
		Height + GAP + PowerHeight. Widgets that sit above the frame (name, class
		power, debuffs) and below it (buffs, castbar) are pushed onto two stacks
		so each builder only needs to know "put me next", not absolute offsets.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("UnitFrames")

local oUF = K.oUF

local CreateFrame = CreateFrame
local ipairs = ipairs
local pairs = pairs
local min = math.min
local ceil = math.ceil

local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES or 8

-- Gap between every detached box. Shared with the element builders.
Module.GAP = 6

-- Element builder registry, filled by the files under Elements/.
Module.Build = {}

-- Style functions, filled by the files under Units/. The key is also the oUF
-- style name so a spawn only needs to name the style it wants.
Module.Styles = {}

-- Live frames by config key, so the config GUI and other modules can reach them.
Module.frames = {}

-- Every styled frame, including header children. Settings that apply live walk
-- this rather than `frames`, which only holds the standalone units.
Module.all = {}

-- ---------------------------------------------------------------------------
-- Shared helpers
-- ---------------------------------------------------------------------------

function Module.Texture()
	return K.GetTexture(C.Unitframe.Texture)
end

-- Outer height of a unit: health, the gap, and the power bar when it has one.
-- Effective power bar height for a unit config: zero when the user has hidden the
-- power bar (ShowPower off), otherwise the configured height. One source of truth
-- so the frame size and the power builder always agree.
function Module.PowerHeight(cfg)
	if cfg.ShowPower == false then
		return 0
	end
	return cfg.PowerHeight or 0
end

function Module.TotalHeight(cfg, gap)
	local power = Module.PowerHeight(cfg)
	if power <= 0 then
		return cfg.Height
	end
	return cfg.Height + (gap or Module.GAP) + power
end

-- Push a widget onto the upward stack above the frame. Each widget spans the
-- frame width, which also gives aura groups the room they need to wrap.
function Module.StackUp(self, region, height)
	local anchor = self.__stackUp or self.Health or self
	region:SetHeight(height)
	region:SetPoint("BOTTOMLEFT", anchor, "TOPLEFT", 0, Module.GAP)
	region:SetPoint("BOTTOMRIGHT", anchor, "TOPRIGHT", 0, Module.GAP)
	self.__stackUp = region
	return region
end

-- Push a widget onto the downward stack below the frame.
function Module.StackDown(self, region, height)
	local anchor = self.__stackDown or self.Power or self.Health or self
	region:SetHeight(height)
	region:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -Module.GAP)
	region:SetPoint("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, -Module.GAP)
	self.__stackDown = region
	return region
end

-- Standard mouse wiring for a unit frame or a header child. `style` also lands
-- on the frame as `mystyle`, which some oUF elements read to decide whether to
-- stand down the Blizzard equivalent (the monk stagger bar, for one).
-- Blizzard's UnitFrame_OnEnter feeds self.unit straight into GameTooltip:SetUnit,
-- which errors when the unit is nil (an unassigned group slot, a frame mid-setup).
-- Guard it so hovering such a frame never throws.
local function SafeOnEnter(self)
	if self.unit and UnitExists(self.unit) then
		UnitFrame_OnEnter(self)
	end
end

function Module.EnableInteraction(self, style)
	self.mystyle = style
	self:RegisterForClicks("AnyUp")
	self:SetScript("OnEnter", SafeOnEnter)
	self:SetScript("OnLeave", UnitFrame_OnLeave)

	Module.all[#Module.all + 1] = self
end

-- ---------------------------------------------------------------------------
-- Spawn table
-- ---------------------------------------------------------------------------
-- Default anchors match the original KkthnxUI so an upgrade lands in the same
-- place. Anchor targets given as strings resolve to a frame spawned earlier.

Module.UnitDefs = {
	{ unit = "player", key = "Player", style = "Player", mover = "PlayerFrame", point = { "BOTTOM", "UIParent", "BOTTOM", -260, 320 } },
	{ unit = "target", key = "Target", style = "Target", mover = "TargetFrame", point = { "BOTTOM", "UIParent", "BOTTOM", 260, 320 } },
	{ unit = "targettarget", key = "TargetOfTarget", style = "Small", mover = "TargetOfTargetFrame", point = { "TOPLEFT", "Target", "BOTTOMRIGHT", 6, -6 } },
	{ unit = "pet", key = "Pet", style = "Small", mover = "PetFrame", point = { "TOPRIGHT", "Player", "BOTTOMLEFT", -6, -6 } },
	{ unit = "focus", key = "Focus", style = "Focus", mover = "FocusFrame", point = { "BOTTOMRIGHT", "Player", "TOPLEFT", -60, 200 } },
	{ unit = "focustarget", key = "FocusTarget", style = "Small", mover = "FocusTargetFrame", point = { "TOPLEFT", "Focus", "BOTTOMRIGHT", 6, -6 } },
}

-- Resolve an anchor token to a real frame.
function Module:ResolveAnchor(token)
	if token == "UIParent" or not token then
		return UIParent
	end
	local frame = self.frames[token]
	return frame or UIParent
end

-- ---------------------------------------------------------------------------
-- Spawning
-- ---------------------------------------------------------------------------

function Module:SpawnUnit(def)
	local cfg = C.Unitframe[def.key]
	if not cfg or not cfg.Enable then
		return
	end

	oUF:SetActiveStyle("KkthnxUI_" .. def.style)

	local frame = oUF:Spawn(def.unit, "KKUI_" .. def.key)
	frame:SetSize(cfg.Width, Module.TotalHeight(cfg))

	local point = def.point
	local mover = K.CreateMover(frame, def.mover, def.key, {
		point[1], self:ResolveAnchor(point[2]), point[3], point[4], point[5],
	}, frame:GetWidth(), frame:GetHeight())

	self.frames[def.key] = frame
	self[def.key] = frame
	frame.__mover = mover

	-- The portrait box spans the full frame height and wants to be square, which
	-- we can only do once the real height is known.
	if frame.PortraitHolder then
		frame.PortraitHolder:SetWidth(frame:GetHeight())
	end

	return frame
end

function Module:SpawnBoss()
	local cfg = C.Unitframe.Boss
	if not cfg or not cfg.Enable then
		return
	end

	oUF:SetActiveStyle("KkthnxUI_Boss")

	local height = Module.TotalHeight(cfg)
	local holder = CreateFrame("Frame", "KKUI_BossHolder", UIParent)
	holder:SetSize(cfg.Width, height * MAX_BOSS_FRAMES + cfg.Spacing * (MAX_BOSS_FRAMES - 1))
	K.CreateMover(holder, "BossFrames", "Boss Frames", { "BOTTOMRIGHT", UIParent, "RIGHT", -250, 140 }, holder:GetWidth(), holder:GetHeight())

	self.Boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		local frame = oUF:Spawn("boss" .. i, "KKUI_Boss" .. i)
		frame:SetSize(cfg.Width, height)
		if i == 1 then
			frame:SetPoint("TOPRIGHT", holder)
		else
			frame:SetPoint("TOPRIGHT", self.Boss[i - 1], "BOTTOMRIGHT", 0, -cfg.Spacing)
		end
		self.Boss[i] = frame
	end
	self.BossHolder = holder
end

-- Group headers. The child size has to be baked into the secure init snippet
-- because a header configures its children inside the restricted environment.
local function InitialConfig(width, height)
	return ([[
		self:SetWidth(%d)
		self:SetHeight(%d)
	]]):format(width, height)
end

function Module:SpawnParty()
	local cfg = C.Unitframe.Party
	if not cfg or not cfg.Enable then
		return
	end

	oUF:SetActiveStyle("KkthnxUI_Party")

	local height = Module.TotalHeight(cfg)
	-- SpawnHeader is (name, template, ...attributes). The full column recipe
	-- (maxColumns / unitsPerColumn / groupBy / sortMethod) is what a secure group
	-- header needs to actually lay out and show its children.
	-- The show* attributes only mark which unit kinds are eligible, a visibility
	-- state driver decides when the whole header is shown, mirroring the resource
	-- addons. That keeps party and raid from ever fighting over the same members.
	-- Party frames sit further apart than the raid so the debuff row beside each
	-- has room to breathe.
	local partySpacing = 24
	local header = oUF:SpawnHeader("KKUI_Party", nil,
		"showPlayer", true,
		"showSolo", cfg.ShowSolo,
		"showParty", true,
		"showRaid", true,
		"xOffset", 0,
		"yOffset", -partySpacing,
		"point", "TOP",
		"groupBy", "GROUP",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"sortMethod", "INDEX",
		"maxColumns", 1,
		"unitsPerColumn", 5,
		"columnSpacing", partySpacing,
		"columnAnchorPoint", "LEFT",
		"oUF-initialConfigFunction", InitialConfig(cfg.Width, height))

	header:SetSize(cfg.Width, height * 5 + partySpacing * 4)
	K.CreateMover(header, "PartyFrames", "Party", { "TOPLEFT", UIParent, "TOPLEFT", 50, -300 }, header:GetWidth(), header:GetHeight())

	-- Show in a party but stand down inside a raid, where the raid header takes
	-- over. Optionally stay up while solo for positioning.
	local visibility = "[group:party,nogroup:raid] show; hide"
	if cfg.ShowSolo then
		visibility = "[nogroup] show; " .. visibility
	end
	RegisterStateDriver(header, "visibility", visibility)

	self.Party = header
end

function Module:SpawnRaid()
	local cfg = C.Unitframe.Raid
	if not cfg or not cfg.Enable then
		return
	end

	oUF:SetActiveStyle("KkthnxUI_Raid")

	-- Child height is health + gap + power. Mana mode reserves the power slot so
	-- every frame stays the same size, non-mana members just fill it with health.
	local mode = cfg.PowerMode or "All"
	local powerHeight = (mode ~= "None") and (cfg.PowerHeight or 0) or 0
	local gap = powerHeight > 0 and (cfg.PowerGap or 6) or 0
	local height = cfg.Height + gap + powerHeight
	-- A single header lays out every group into columns via maxColumns/groupBy,
	-- which is simpler and more reliable than anchoring eight separate headers.
	local cols = min(cfg.GroupsPerRow, 8)

	-- How the columns are keyed. GROUP keeps raid groups together (the classic
	-- look). CLASS stacks each class. ROLE sorts by assigned role using Blizzard's
	-- ASSIGNEDROLE grouping, so tanks, then healers, then damage.
	local GROUP_ATTR = { GROUP = "GROUP", CLASS = "CLASS", ROLE = "ASSIGNEDROLE" }
	local GROUPING_ORDER = {
		GROUP = "1,2,3,4,5,6,7,8",
		CLASS = "WARRIOR,DEATHKNIGHT,DEMONHUNTER,PALADIN,MONK,ROGUE,DRUID,HUNTER,MAGE,WARLOCK,PRIEST,SHAMAN,EVOKER",
		ROLE = "TANK,HEALER,DAMAGER",
	}
	local groupByCfg = cfg.GroupBy or "GROUP"
	local groupBy = GROUP_ATTR[groupByCfg] or "GROUP"
	local groupingOrder = GROUPING_ORDER[groupByCfg] or GROUPING_ORDER.GROUP

	-- Raid-wide sorting spreads the whole raid across GroupsPerRow columns as one
	-- sorted list. Off keeps each raid group as its own column of five. Class and
	-- role grouping have no per-group meaning, so they force raid-wide on.
	local raidWide = cfg.RaidWide or groupByCfg ~= "GROUP"
	local perColumn = raidWide and ceil(40 / cols) or 5
	local maxColumns = raidWide and cols or 8
	local rows = raidWide and perColumn or 5

	-- Growth: which corner the grid builds from. All four keep vertical columns, so
	-- only the anchor point, the column direction, and the vertical step change.
	local ORIENT = {
		DOWN_RIGHT = { point = "TOP", column = "LEFT", down = true },
		DOWN_LEFT = { point = "TOP", column = "RIGHT", down = true },
		UP_RIGHT = { point = "BOTTOM", column = "LEFT", down = false },
		UP_LEFT = { point = "BOTTOM", column = "RIGHT", down = false },
	}
	local orient = ORIENT[cfg.Orientation] or ORIENT.DOWN_RIGHT
	local yOffset = orient.down and -Module.GAP or Module.GAP

	-- Order within a column: ascending (index order) or descending (reversed).
	local sortDir = cfg.SortDirection == "DESC" and "DESC" or "ASC"

	-- Single header, all groups. Vertical layout: units stack along a column, so the
	-- per-unit offset is vertical only (xOffset 0) and columnSpacing opens the gap
	-- between columns. A non-zero xOffset here staggers every frame sideways.
	local header = oUF:SpawnHeader("KKUI_Raid", nil,
		"showPlayer", true,
		"showParty", true,
		"showRaid", true,
		"showSolo", false,
		"xOffset", 0,
		"yOffset", yOffset,
		"point", orient.point,
		"groupBy", groupBy,
		"groupingOrder", groupingOrder,
		"sortMethod", "INDEX",
		"sortDir", sortDir,
		"maxColumns", maxColumns,
		"unitsPerColumn", perColumn,
		"columnSpacing", Module.GAP,
		"columnAnchorPoint", orient.column,
		"oUF-initialConfigFunction", InitialConfig(cfg.Width, height))

	header:SetSize(cols * cfg.Width + (cols - 1) * Module.GAP, height * rows + Module.GAP * (rows - 1))
	K.CreateMover(header, "RaidFrames", "Raid", { "TOPLEFT", UIParent, "TOPLEFT", 4, -180 }, header:GetWidth(), header:GetHeight())

	-- Only up inside a raid, the party header covers 5-man groups.
	RegisterStateDriver(header, "visibility", "[group:raid] show; hide")

	self.Raid = header

	-- Column labels only make sense keyed by group. Under class or role grouping a
	-- column no longer maps to a raid group, so the numbers would lie.
	if cfg.ShowGroupNumber and groupByCfg == "GROUP" and not raidWide then
		self:BuildRaidGroupLabels(header, cols, cfg.Width)
	end
end

-- A small numbered label above each column, since with one combined header every
-- raid group lands in its own column. Labels only show for groups that actually
-- have members, refreshed on roster changes.
function Module:BuildRaidGroupLabels(header, cols, width)
	local labels = {}
	for i = 1, cols do
		local fs = header:CreateFontString(nil, "OVERLAY")
		K.SetFont(fs, 12, K.FontOutlineStyle())
		fs:SetTextColor(0.6, 0.8, 1)
		fs:SetText(i)
		local x = (i - 1) * (width + Module.GAP) + width * 0.5
		fs:SetPoint("BOTTOM", header, "TOPLEFT", x, 3)
		fs:Hide()
		labels[i] = fs
	end
	self.raidGroupLabels = labels

	self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateRaidGroupLabels")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateRaidGroupLabels")
	self:UpdateRaidGroupLabels()
end

function Module:UpdateRaidGroupLabels()
	local labels = self.raidGroupLabels
	if not labels then
		return
	end

	-- Find the highest occupied raid subgroup so empty trailing labels stay hidden.
	local used = 0
	local members = IsInRaid() and GetNumGroupMembers() or 0
	for i = 1, members do
		local _, _, subgroup = GetRaidRosterInfo(i)
		if subgroup and subgroup > used then
			used = subgroup
		end
	end

	for i, fs in ipairs(labels) do
		fs:SetShown(i <= used)
	end
end

-- ---------------------------------------------------------------------------
-- Disable the Blizzard raid / party compact frames
-- ---------------------------------------------------------------------------
-- oUF:DisableBlizzard only handles the party unit frames, not the compact raid
-- container. Turn the raid profile off through its own setting (the sanctioned,
-- taint-safe path) and park the manager offscreen. Out of combat only.

function Module:DisableBlizzardRaid()
	if InCombatLockdown() then
		return
	end

	local hidden = _G.KKUI_HiddenParent
	if not hidden then
		hidden = CreateFrame("Frame", "KKUI_HiddenParent", UIParent)
		hidden:Hide()
	end

	if CompactPartyFrame then
		CompactPartyFrame:UnregisterAllEvents()
	end

	-- Ask the raid profile to stay hidden (harmless if the API is gone), then
	-- reparent the actual container and manager to a hidden frame. A hidden
	-- parent keeps them invisible even when Blizzard calls Show on them later.
	if CompactRaidFrameManager_SetSetting then
		CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
	if CompactRaidFrameContainer then
		CompactRaidFrameContainer:UnregisterAllEvents()
		CompactRaidFrameContainer:SetParent(hidden)
	end
	if CompactRaidFrameManager then
		CompactRaidFrameManager:UnregisterAllEvents()
		CompactRaidFrameManager:SetParent(hidden)
	end
end

-- ---------------------------------------------------------------------------
-- Lifecycle
-- ---------------------------------------------------------------------------

function Module:OnEnable()
	if not C.Unitframe.Enable then
		return
	end

	-- Apply our power/reaction palette to the oUF colour tables before any frame
	-- spawns. This runs here, not at file load, because the config table is only
	-- built at ADDON_LOADED.
	if K.ApplyUnitColors then
		K.ApplyUnitColors()
	end

	for name, style in pairs(Module.Styles) do
		oUF:RegisterStyle("KkthnxUI_" .. name, style)
	end

	-- Get the stock party/raid frames out of the way if we replace them.
	if C.Unitframe.Party.Enable or C.Unitframe.Raid.Enable then
		self:DisableBlizzardRaid()
	end

	for _, def in ipairs(Module.UnitDefs) do
		self:SpawnUnit(def)
	end

	self:SpawnBoss()
	self:SpawnParty()
	self:SpawnRaid()

	K.RefreshBorderColors()
end

-- ---------------------------------------------------------------------------
-- Test / preview mode
-- ---------------------------------------------------------------------------
-- Secure group headers can only show real units, so the preview forces the
-- party and raid headers to display you (and any real group members) while
-- solo. It is enough to position and style the frames without a group. Toggling
-- is out of combat only, since it changes secure header attributes.

function Module:ToggleTest()
	if InCombatLockdown() then
		K.Print("Cannot toggle test mode in combat.")
		return
	end

	self.testMode = not self.testMode
	local on = self.testMode

	-- Hide the real (secure) headers while previewing, so the mock frames are the
	-- only thing shown and nothing overlaps. Restore the normal drivers on off.
	if self.Party then
		if on then
			RegisterStateDriver(self.Party, "visibility", "hide")
		else
			self.Party:SetAttribute("showSolo", C.Unitframe.Party.ShowSolo or false)
			local visibility = "[group:party,nogroup:raid] show; hide"
			if C.Unitframe.Party.ShowSolo then
				visibility = "[nogroup] show; " .. visibility
			end
			RegisterStateDriver(self.Party, "visibility", visibility)
		end
	end

	if self.Raid then
		if on then
			RegisterStateDriver(self.Raid, "visibility", "hide")
		else
			self.Raid:SetAttribute("showSolo", false)
			RegisterStateDriver(self.Raid, "visibility", "[group:raid] show; hide")
		end
	end

	-- Mock boss / party / raid frames (with fake auras) so the whole group layout
	-- can be previewed and positioned while solo.
	if self.ShowTestFrames then
		self:ShowTestFrames(on)
	end

	if on then
		K.Print("Unit frame test mode ON. Boss, party, and raid previews are showing so you can position them.")
	else
		K.Print("Unit frame test mode OFF.")
	end
end
