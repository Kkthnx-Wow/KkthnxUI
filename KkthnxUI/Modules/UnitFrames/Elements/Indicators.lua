--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Elements/Indicators.lua
	Purpose:
		The small status icons: raid marker, combat, resting, quest, leader, role,
		ready check, resurrect, summon.

		Every icon sits inside the health bar rather than poking out above it.
		Group frames are laid out by a secure header, so anything that overflowed
		the frame would land on the neighbour above.

		Threat is the exception: instead of yet another icon it recolours the
		health border, which is far easier to read mid pull.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build
local oUF = K.oUF

local IsSecret = K.IsSecret
local CreateColor = CreateColor
local DebuffTypeColor = DebuffTypeColor
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit

-- ---------------------------------------------------------------------------
-- Mouseover and target-select highlight
-- ---------------------------------------------------------------------------

-- Show the select texture while this frame's unit is the current target. Runs
-- for every frame on PLAYER_TARGET_CHANGED, so a party member lighting up the
-- moment you target them is handled without a per-unit event.
local function SelectUpdate(self)
	local highlight = self.KKUI_Select
	if not highlight then
		return
	end
	local unit = self.unit
	local isTarget = unit and UnitExists(unit) and UnitIsUnit(unit, "target")
	highlight:SetShown(not IsSecret(isTarget) and isTarget and true or false)
end

local function SelectForceUpdate(element)
	return SelectUpdate(element.__owner)
end

local function SelectEnable(self)
	if self.KKUI_SelectHighlight then
		self.KKUI_SelectHighlight.__owner = self
		self.KKUI_SelectHighlight.ForceUpdate = SelectForceUpdate
		self:RegisterEvent("PLAYER_TARGET_CHANGED", SelectUpdate, true)
		return true
	end
end

local function SelectDisable(self)
	if self.KKUI_SelectHighlight then
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", SelectUpdate)
	end
end

oUF:AddElement("KKUI_SelectHighlight", SelectUpdate, SelectEnable, SelectDisable)

-- A hover texture shown while the cursor is over the frame, and a select texture
-- shown while the frame's unit is the target. Both frame the health bar's border
-- with the given atlases. The element above drives the select texture.
function Build.Highlight(self, hoverAtlas, selectAtlas)
	local anchor = self.Health or self

	local hover = anchor:CreateTexture(nil, "OVERLAY", nil, 6)
	hover:SetPoint("TOPLEFT", anchor, "TOPLEFT", -1, 1)
	hover:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, -1)
	hover:SetAtlas(hoverAtlas, false)
	hover:SetBlendMode("ADD")
	hover:Hide()
	self.KKUI_Hover = hover
	self:HookScript("OnEnter", function()
		hover:Show()
	end)
	self:HookScript("OnLeave", function()
		hover:Hide()
	end)

	-- The target-select glow is only wanted on the group frames, where picking a
	-- member out of the grid matters. Player, target, focus, and boss frames skip
	-- it (you always know what those are), so only the hover glow above applies.
	if self.mystyle == "party" or self.mystyle == "raid" then
		local selectTex = anchor:CreateTexture(nil, "OVERLAY", nil, 7)
		selectTex:SetPoint("TOPLEFT", anchor, "TOPLEFT", -1, 1)
		selectTex:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 1, -1)
		selectTex:SetAtlas(selectAtlas, false)
		selectTex:SetBlendMode("ADD")
		selectTex:Hide()
		self.KKUI_Select = selectTex

		-- Marker so oUF enables the select element (it drives KKUI_Select).
		self.KKUI_SelectHighlight = self.KKUI_SelectHighlight or {}
	end
end

-- Small helper so every icon below is one line.
local function Icon(parent, size, ...)
	local texture = parent:CreateTexture(nil, "OVERLAY")
	texture:SetSize(size, size)
	texture:SetPoint(...)
	return texture
end

-- ---------------------------------------------------------------------------
-- Threat on the health border
-- ---------------------------------------------------------------------------

local function ThreatPostUpdate(element, _, status, color)
	local frame = element.__owner
	frame.__threatColor = (status and status > 0) and color or nil
	Module.RefreshHealthBorder(frame)
end

function Build.Threat(self)
	-- oUF wants a widget it can show, hide, and tint. We only care about the
	-- colour it hands to PostUpdate, so the widget itself stays invisible.
	local proxy = self.Health:CreateTexture(nil, "OVERLAY")
	proxy:SetSize(1, 1)
	proxy:SetPoint("CENTER")
	proxy:SetAlpha(0)
	proxy.PostUpdate = ThreatPostUpdate

	self.ThreatIndicator = proxy
	return proxy
end

-- ---------------------------------------------------------------------------
-- Dispellable debuff highlight (party / raid)
-- ---------------------------------------------------------------------------

-- ColorMixins for each dispel type, built once from the game table so the border
-- refresh can call color:GetRGB() like it does for threat.
local dispelColors
local function DispelColor(name)
	if not dispelColors then
		dispelColors = {}
		for kind, c in pairs(DebuffTypeColor or {}) do
			if type(c) == "table" and c.r then
				dispelColors[kind] = CreateColor(c.r, c.g, c.b)
			end
		end
	end
	return name and dispelColors[name]
end

-- Colour the health border for the first dispellable debuff on the unit. Aura
-- fields can be secret in Midnight, so the dispel type is only trusted when it
-- reads as a plain string. Implemented as a real oUF element so oUF drives it on
-- UNIT_AURA and, crucially, re-runs it when a header child is handed a new unit
-- (otherwise a recycled raid frame keeps the previous member's border colour).
local function Update(self, _, unit)
	if unit and unit ~= self.unit then
		return
	end
	unit = self.unit
	if not unit then
		return
	end

	local color
	for i = 1, 40 do
		local data = K.GetAuraData(unit, i, "HARMFUL")
		if not data then
			break
		end
		local dispel = data.dispelName
		-- Only highlight debuffs this class can actually remove, so it never
		-- nags you about a school you cannot dispel.
		if dispel and not IsSecret(dispel) and K.CanDispel and K.CanDispel[dispel] then
			local c = DispelColor(dispel)
			if c then
				color = c
				break
			end
		end
	end

	self.__dispelColor = color
	Module.RefreshHealthBorder(self)
end

local function Path(self, ...)
	return (self.DispelHighlight.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local element = self.DispelHighlight
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate
		self:RegisterEvent("UNIT_AURA", Path)
		return true
	end
end

local function Disable(self)
	local element = self.DispelHighlight
	if element then
		self:UnregisterEvent("UNIT_AURA", Path)
		self.__dispelColor = nil
		Module.RefreshHealthBorder(self)
	end
end

oUF:AddElement("DispelHighlight", Path, Enable, Disable)

-- The element only needs a truthy table for oUF to enable and drive it, the work
-- happens on the shared health border, so there is no widget to position.
function Build.DispelHighlight(self)
	self.DispelHighlight = {}
end

-- ---------------------------------------------------------------------------
-- Indicator sets
-- ---------------------------------------------------------------------------

-- Everything a unit gets regardless of type. Corners are assigned once, here and
-- in the sets below, so no two icons ever land on the same one:
--   top left     resting, quest, leader, assistant
--   top right    raid marker
--   bottom left  group role
--   bottom right combat, raid role
-- Text always runs down the middle, so it stays clear of all four.
function Build.Indicators(self, size)
	local health = self.Health

	self.RaidTargetIndicator = Icon(health, size or 14, "TOPRIGHT", health, "TOPRIGHT", -1, -1)

	Build.PhaseIndicator(self)
	Build.Threat(self)
end

-- Shows a phase icon when the unit is in a different phase or war-mode shard, so
-- an out-of-phase group member reads clearly. oUF drives its visibility.
function Build.PhaseIndicator(self)
	local frame = CreateFrame("Frame", nil, self.Health)
	frame:SetSize(18, 18)
	frame:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	local icon = frame:CreateTexture(nil, "OVERLAY")
	icon:SetAllPoints()
	frame.Icon = icon
	self.PhaseIndicator = frame
	return frame
end

-- The animated "Zzz" sleep loop Blizzard plays on its player frame: a 7x6, 42
-- frame flipbook driven by Blizzard's own FlipBook animation, so it renders
-- exactly the way the default frame does. We just wear it in the portrait corner
-- and only run the loop while it is actually shown (resting).
local REST_ATLAS = "UI-HUD-UnitFrame-Player-Rest-Flipbook"

local function BuildRestingFlipbook(self, anchor, size)
	local rest = CreateFrame("Frame", nil, self)
	rest:SetSize(size, size)
	-- Sit on the top-left corner of the portrait.
	rest:SetPoint("CENTER", anchor, "TOPLEFT", 3, -3)
	rest:SetFrameLevel(self:GetFrameLevel() + 6)

	local tex = rest:CreateTexture(nil, "OVERLAY")
	tex:SetAllPoints()
	tex:SetAtlas(REST_ATLAS)

	local group = rest:CreateAnimationGroup()
	group:SetLooping("REPEAT")
	local flip = group:CreateAnimation("FlipBook")
	flip:SetTarget(tex)
	flip:SetDuration(1.5)
	flip:SetFlipBookRows(7)
	flip:SetFlipBookColumns(6)
	flip:SetFlipBookFrames(42)
	flip:SetFlipBookFrameWidth(0) -- 0 lets the flipbook derive the frame size
	flip:SetFlipBookFrameHeight(0)
	flip:SetSmoothing("NONE")
	rest.Anim = group

	-- Only run the loop while resting, so a hidden icon is not animating for
	-- nothing. oUF shows/hides the element, we just start and stop the loop.
	rest.PostUpdate = function(element, isResting)
		if isResting then
			element.Anim:Play()
		else
			element.Anim:Stop()
		end
	end

	return rest
end

-- Player only: combat and resting flags.
function Build.PlayerIndicators(self)
	local health = self.Health

	self.CombatIndicator = Icon(health, 20, "LEFT", health, "LEFT", 4, 0)
	-- Prefer the portrait corner, falling back to the health bar if the frame has
	-- no portrait.
	self.RestingIndicator = BuildRestingFlipbook(self, self.Portrait or health, 22)
end

-- Target and focus: the quest badge, so quest mobs stand out at a glance.
function Build.QuestIndicator(self)
	self.QuestIndicator = Icon(self.Health, 14, "TOPLEFT", self.Health, "TOPLEFT", 1, -1)
end

-- Fade a frame while its unit is out of range, so an unreachable target or group
-- member reads as dimmed. oUF drives the alpha from its range check.
function Build.Range(self)
	if not C.Unitframe.RangeFade then
		return
	end
	self.Range = {
		insideAlpha = 1,
		outsideAlpha = C.Unitframe.RangeAlpha or 0.4,
	}
	return self.Range
end

-- Party and raid: everything a healer needs to see on a roster.
function Build.GroupIndicators(self)
	local health = self.Health

	-- Leader and assistant share a corner. Only one can ever be shown.
	self.LeaderIndicator = Icon(health, 12, "TOPLEFT", health, "TOPLEFT", 1, -1)
	self.AssistantIndicator = Icon(health, 12, "TOPLEFT", health, "TOPLEFT", 1, -1)

	-- Clean role glyphs from the modern icon set. Only tank and healer are worth
	-- showing, a DPS icon on every damage dealer is pure noise, so hide that role.
	self.GroupRoleIndicator = Icon(health, 12, "BOTTOMLEFT", health, "BOTTOMLEFT", 1, 1)
	self.GroupRoleIndicator.PostUpdate = function(element, role)
		if role == "TANK" then
			element:SetAtlas("icons_64x64_tank")
			element:Show()
		elseif role == "HEALER" then
			element:SetAtlas("icons_64x64_heal")
			element:Show()
		else
			element:Hide()
		end
	end
	self.RaidRoleIndicator = Icon(health, 11, "BOTTOMRIGHT", health, "BOTTOMRIGHT", -1, 1)

	-- Transient overlays. They only appear for a few seconds at a time, so they
	-- are allowed to sit right over the middle of the bar.
	self.ReadyCheckIndicator = Icon(health, 16, "CENTER", health, "CENTER", 0, 0)
	self.ResurrectIndicator = Icon(health, 18, "CENTER", health, "CENTER", 0, 0)
	self.SummonIndicator = Icon(health, 18, "CENTER", health, "CENTER", 0, 0)

	-- Fade members who are out of range so they read as unreachable.
	Build.Range(self)
end
