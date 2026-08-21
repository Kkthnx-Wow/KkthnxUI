--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/PetBar.lua
	Purpose:
		The pet action bar. Reuses Blizzard's pet buttons: reparent them onto our
		own bar, skin them, and lay them out in a row. Blizzard keeps driving the
		pet action state. Shown only while a pet with an action bar exists.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("ActionBars")

local _G = _G
local ceil = math.ceil
local floor = math.floor

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

	local size, space, perRow = cfg.Size, cfg.Space, cfg.PerRow
	local count = #bar.buttons
	local rows = ceil(count / perRow)
	bar:SetSize(perRow * size + (perRow - 1) * space, rows * size + (rows - 1) * space)
	for i, button in ipairs(bar.buttons) do
		button:SetSize(size, size)
		local col = (i - 1) % perRow
		local row = floor((i - 1) / perRow)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", bar, "TOPLEFT", col * (size + space), -row * (size + space))
	end

	K.CreateMover(bar, "PetBar", "Pet Bar", { "BOTTOM", UIParent, "BOTTOM", 0, 210 }, bar:GetWidth(), bar:GetHeight())

	-- Only visible with a controllable pet, and never in a pet battle.
	RegisterStateDriver(bar, "visibility", "[petbattle] hide; [pet] show; hide")
	self:SetupFade(bar, cfg)

	self.bars.PetBar = bar
	return bar
end
