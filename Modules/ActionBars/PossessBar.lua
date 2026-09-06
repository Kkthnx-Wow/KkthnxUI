--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/PossessBar.lua
	Purpose:
		The possess bar: the small set of buttons shown while you control another
		unit (mind control, some vehicles and cutscene mounts). We reuse Blizzard's
		possess buttons, reparent them onto our own movable bar, skin them, and lay
		them in a row. Blizzard keeps driving what each button does and when it is
		shown.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("ActionBars")

local _G = _G
local ceil = math.ceil
local floor = math.floor

local NUM_POSSESS_SLOTS = _G.NUM_POSSESS_SLOTS or 2

function Module:CreatePossessBar()
	local cfg = C.ActionBar.PossessBar
	if not cfg or not cfg.Enable then
		return
	end

	local bar = CreateFrame("Frame", "KKUI_PossessBar", UIParent, "SecureHandlerStateTemplate")
	bar.key = "PossessBar"
	bar.buttons = {}

	for i = 1, NUM_POSSESS_SLOTS do
		local button = _G["PossessButton" .. i]
		if button then
			button:SetParent(bar)
			self:StyleAuxButton(button)
			bar.buttons[i] = button
		end
	end

	if #bar.buttons == 0 then
		return
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

	K.CreateMover(bar, "PossessBar", L["Possess Bar"], { "BOTTOM", UIParent, "BOTTOM", 0, 280 }, bar:GetWidth(), bar:GetHeight())

	-- Only visible while possessing something, and never in a pet battle.
	RegisterStateDriver(bar, "visibility", "[petbattle] hide; [possessbar] show; hide")
	self:SetupFade(bar, cfg)

	self.bars.PossessBar = bar
	return bar
end
