--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Elements/Auras.lua
	Purpose:
		Buff and debuff displays for the unit frames, built on Blizzard's Midnight
		CustomAuraContainer intrinsic through K.CreateAuraContainer. Addons can no
		longer read auras from tainted code on 12.1, so Blizzard renders the aura
		buttons and we only style them.

		A tiny oUF element (KKUIAuras) keeps each frame's containers pointed at the
		frame's current unit, so target swaps, secure party/raid assignment, and
		nameplate recycling all repoint the auras automatically.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")
local Build = Module.Build
local oUF = K.oUF

local tinsert = table.insert
local floor = math.floor
local max = math.max
local pcall = pcall

-- ---------------------------------------------------------------------------
-- Unit tracking element
-- ---------------------------------------------------------------------------

-- Point every attached container at the frame's current unit. oUF calls this on
-- enable and whenever the unit changes (target/focus swap, group assignment,
-- nameplate add), so the containers always follow the right unit.
local function Update(self)
	local element = self.KKUIAuras
	local unit = self.unit
	if not element or not unit then
		return
	end
	for i = 1, #element do
		local container = element[i]
		pcall(container.SetUnit, container, unit)
		-- SetUnit to the same token (e.g. "target") is a no-op, so the container
		-- keeps the previous unit's auras when you retarget. UpdateAllAuras forces
		-- it to re-read the token's current unit.
		pcall(container.UpdateAllAuras, container)
	end
end

local function ForceUpdate(element)
	return Update(element.__owner)
end

local function Enable(self)
	if self.KKUIAuras then
		self.KKUIAuras.__owner = self
		self.KKUIAuras.ForceUpdate = ForceUpdate
		return true
	end
end

local function Disable() end

oUF:AddElement("KKUIAuras", Update, Enable, Disable)

-- Register a container so the element keeps it pointed at the frame's unit.
local function Track(self, container)
	if not container then
		return
	end
	self.KKUIAuras = self.KKUIAuras or {}
	tinsert(self.KKUIAuras, container)
end
-- Exposed so the nameplate style (a separate module) can track its container too.
K.TrackAuraContainer = Track

-- ---------------------------------------------------------------------------
-- Builders
-- ---------------------------------------------------------------------------

-- Debuffs sit above the frame and grow right then up, buffs below growing right
-- then down, filling the frame width.
function Build.Auras(self, cfg)
	local db = C.Unitframe.Auras
	local width = cfg.Width or 220
	local perRow = max(1, db.PerRow)
	local spacing = db.Spacing
	local size = max(8, floor((width - (perRow - 1) * spacing) / perRow))

	if cfg.Debuffs then
		local filter = db.OnlyPlayerDebuffs and "HARMFUL|PLAYER" or "HARMFUL"
		-- Sit 6px above the name gradient (the stack-up anchor) rather than the
		-- frame's top, so the debuffs clear the name texture cleanly.
		local anchorTo = self.__stackUp or self
		local container = K.CreateAuraContainer(self, {
			point = { "BOTTOMLEFT", anchorTo, "TOPLEFT", 0, Module.GAP },
			size = size,
			spacing = spacing,
			perRow = perRow,
			anchorPoint = "BOTTOMLEFT",
			growthH = "Right",
			growthV = "Up",
			dispelBorder = true,
			slots = { { key = "debuffs", filter = filter, max = db.NumDebuffs } },
		})
		self.KKUI_Debuffs = container
		Track(self, container)
	end

	if cfg.Buffs then
		local container = K.CreateAuraContainer(self, {
			point = { "TOPLEFT", self, "BOTTOMLEFT", 0, -Module.GAP },
			size = size,
			spacing = spacing,
			perRow = perRow,
			anchorPoint = "TOPLEFT",
			growthH = "Right",
			growthV = "Down",
			slots = { { key = "buffs", filter = "HELPFUL", max = db.NumBuffs, cancel = self.unit == "player" } },
		})
		self.KKUI_Buffs = container
		Track(self, container)
	end
end

-- Compact debuff row beside a group frame's health bar. side "right" clears the
-- party portrait, "left" is the default for the raid.
function Build.GroupDebuffs(self, count, size, side)
	local spacing = Module.GAP
	local point, anchorPoint, growthH
	if side == "right" then
		point = { "LEFT", self.Health, "RIGHT", spacing, 0 }
		anchorPoint, growthH = "BOTTOMLEFT", "Right"
	else
		point = { "RIGHT", self.Health, "LEFT", -spacing, 0 }
		anchorPoint, growthH = "BOTTOMRIGHT", "Left"
	end

	-- Healers usually only want debuffs they can act on, so default the group rows
	-- to the auras the player can dispel (Blizzard's own filter token). Toggle off
	-- to show every debuff.
	local filter = C.Unitframe.GroupDispelOnly and "HARMFUL|RAID_PLAYER_DISPELLABLE" or "HARMFUL"
	local container = K.CreateAuraContainer(self, {
		point = point,
		size = size,
		spacing = spacing,
		perRow = count,
		anchorPoint = anchorPoint,
		growthH = growthH,
		growthV = "Up",
		dispelBorder = true,
		slots = { { key = "gdebuffs", filter = filter, max = count } },
	})
	self.KKUI_Debuffs = container
	Track(self, container)
	return container
end
