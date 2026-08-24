--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Auras/Core.lua
	Purpose:
		The player buff and debuff display by the minimap. Built on Blizzard's
		Midnight CustomAuraContainer intrinsic (via K.CreateAuraContainer), since
		12.1 no longer lets an addon read auras from tainted code. Blizzard renders
		the buttons untainted and we style them through the wrapper. If the
		intrinsic is unavailable we leave Blizzard's own buff frames in place so
		the player still sees their auras.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("Auras")

local _G = _G
local CreateFrame = CreateFrame

-- ---------------------------------------------------------------------------
-- Hide the Blizzard aura frames
-- ---------------------------------------------------------------------------

function Module:HideBlizzard()
	local hidden = _G.KKUI_HiddenParent
	if not hidden then
		hidden = CreateFrame("Frame", "KKUI_HiddenParent", UIParent)
		hidden:Hide()
	end
	for _, name in ipairs({ "BuffFrame", "DebuffFrame" }) do
		local frame = _G[name]
		if frame then
			frame:UnregisterAllEvents()
			frame:SetParent(hidden)
			if frame.numHideableBuffs then
				frame.numHideableBuffs = 0
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Enable
-- ---------------------------------------------------------------------------

-- One movable aura block: a fixed-size holder carries the mover grab box, and the
-- (dynamically sized) container hangs off the holder's top-right corner, growing
-- left then down.
local function BuildBlock(key, label, filter, size, point, cancel)
	local db = C.Auras
	local step = size + db.Spacing
	local holder = CreateFrame("Frame", "KKUI_" .. key .. "Anchor", UIParent)
	holder:SetSize(db.PerRow * step, 2 * step)
	K.CreateMover(holder, key, label, point, db.PerRow * step, 2 * step, "TOPRIGHT")

	return K.CreateAuraContainer(UIParent, {
		point = { "TOPRIGHT", holder, "TOPRIGHT", 0, 0 },
		size = size,
		perRow = db.PerRow,
		spacing = db.Spacing,
		anchorPoint = "TOPRIGHT",
		growthH = "Left",
		growthV = "Down",
		unit = "player",
		dispelBorder = filter == "HARMFUL",
		-- The initializer reads cancel at the top level, so it must live here and not
		-- only on the slot, or right-click cancel is never wired onto the buttons.
		cancel = cancel,
		slots = {
			{ key = filter == "HELPFUL" and "buffs" or "debuffs", filter = filter, max = 40, cancel = cancel },
		},
	})
end

function Module:OnEnable()
	if not C.Auras.Enable then
		return
	end

	local db = C.Auras
	local minimap = _G.Minimap or UIParent

	-- Buffs to the left of the minimap, debuffs below it, both movable.
	self.Buffs = BuildBlock("PlayerBuffs", "Player Buffs", "HELPFUL", db.BuffSize, { "TOPRIGHT", minimap, "TOPLEFT", -6, 0 }, true)
	self.Debuffs = BuildBlock("PlayerDebuffs", "Player Debuffs", "HARMFUL", db.DebuffSize, { "TOPRIGHT", minimap, "BOTTOMRIGHT", 0, -6 }, false)

	-- Only take over Blizzard's own aura frames when ours actually built, so a
	-- client without the intrinsic still shows buffs the default way.
	if self.Buffs and self.Debuffs then
		self:HideBlizzard()
	end
end
