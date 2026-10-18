--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/PetBar.lua
	Purpose:
		The pet action bar. Reuses Blizzard's pet buttons: reparent them onto our
		own bar, skin them, and lay them out in a row. Blizzard keeps driving the
		pet action state. Shown only while a pet with an action bar exists.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("ActionBars")

local _G = _G
local InCombatLockdown = InCombatLockdown

local NUM_PET_SLOTS = NUM_PET_ACTION_SLOTS or 10

function Module:CreatePetBar()
	local cfg = C.ActionBar.PetBar
	if not cfg or not cfg.Enable then
		return
	end

	local bar = CreateFrame("Frame", "KKUI_PetBar", UIParent, "SecureHandlerStateTemplate")
	bar.key = "PetBar"
	bar.buttons = {}

	for i = 1, NUM_PET_SLOTS do
		local button = _G["PetActionButton" .. i]
		if button then
			button:SetParent(bar)
			self:StyleAuxButton(button)
			bar.buttons[i] = button
		end
	end

	self.bars.PetBar = bar
	self:LayoutPetBar()

	K.CreateMover(bar, "PetBar", L["Pet Bar"], { "BOTTOM", UIParent, "BOTTOM", 0, 210 }, bar:GetWidth(), bar:GetHeight())

	-- Only visible with a controllable pet, and never in a pet battle or while an
	-- override, vehicle, possess, or shapeshift bar has taken over (some quests put
	-- a bonus bar on the pet state, which otherwise showed this bar spuriously).
	RegisterStateDriver(bar, "visibility", "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide")
	self:ApplyAuxHotKeys(bar, cfg)
	self:SetupFade(bar, cfg)

	return bar
end

-- Lay the pet buttons out from the current settings. Out of combat only.
function Module:LayoutPetBar()
	local bar = self.bars.PetBar
	if not bar then
		return
	end
	if InCombatLockdown() then
		K.DeferCombat("PetBarLayout", function()
			Module:LayoutPetBar()
		end)
		return
	end
	self:LayoutAuxGrid(bar, C.ActionBar.PetBar)
end
