--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/StanceBar.lua
	Purpose:
		The stance / shapeshift bar. Stances are not a LibActionButton type, so we
		reuse Blizzard's stance buttons: reparent them onto our own bar, skin them,
		and re-lay the row whenever the available forms change. Blizzard still
		drives the underlying stance state.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("ActionBars")

local _G = _G
local ceil = math.ceil
local floor = math.floor
local InCombatLockdown = InCombatLockdown
local GetNumShapeshiftForms = GetNumShapeshiftForms

local NUM_STANCE_SLOTS = 10

-- Re-lay the visible stance buttons into our grid. Out of combat only, since it
-- moves protected buttons.
function Module:LayoutStanceBar()
	local bar = self.bars.StanceBar
	if not bar or InCombatLockdown() then
		return
	end
	local cfg = C.ActionBar.StanceBar
	local size, space, perRow = cfg.Size, cfg.Space, cfg.PerRow

	local shown = GetNumShapeshiftForms() or 0
	local rows = shown > 0 and ceil(shown / perRow) or 1
	local cols = shown > 0 and (shown < perRow and shown or perRow) or 1
	bar:SetSize(cols * size + (cols - 1) * space, rows * size + (rows - 1) * space)

	for i, button in ipairs(bar.buttons) do
		button:SetSize(size, size)
		local col = (i - 1) % perRow
		local row = floor((i - 1) / perRow)
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", bar, "TOPLEFT", col * (size + space), -row * (size + space))
	end
end

function Module:CreateStanceBar()
	local cfg = C.ActionBar.StanceBar
	if not cfg or not cfg.Enable then
		return
	end
	-- The bar is always built, even when the class has no forms yet. Druids,
	-- warriors, and the like learn forms as they level, and the count can read
	-- zero at login before it settles, so bailing here would leave them without
	-- a stance bar for the rest of the session. Visibility is driven live from
	-- the form count in UpdateStanceVisibility instead.

	local bar = CreateFrame("Frame", "KKUI_StanceBar", UIParent, "SecureHandlerStateTemplate")
	bar.key = "StanceBar"
	bar.buttons = {}

	for i = 1, NUM_STANCE_SLOTS do
		local button = _G["StanceButton" .. i]
		if button then
			button:SetParent(bar)
			self:StyleAuxButton(button)
			bar.buttons[i] = button
		end
	end

	self.bars.StanceBar = bar

	self:LayoutStanceBar()
	self:SetupFade(bar, cfg)

	-- Size first so the mover box matches, with a sane fallback when the class
	-- has no forms yet at login.
	local w = bar:GetWidth()
	local h = bar:GetHeight()
	if not w or w <= 0 then
		w, h = cfg.Size, cfg.Size
	end
	K.CreateMover(bar, "StanceBar", "Stance Bar", { "BOTTOM", UIParent, "BOTTOM", 0, 250 }, w, h)

	-- Re-lay whenever the set of forms changes, and once on entering the world.
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", function()
		Module:LayoutStanceBar()
		Module:UpdateStanceVisibility(bar)
	end)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		Module:LayoutStanceBar()
		Module:UpdateStanceVisibility(bar)
	end)

	self:UpdateStanceVisibility(bar)
	return bar
end

-- Show the bar only when the class actually has forms, and never over a pet
-- battle, vehicle, or override bar. The form count is a plain value, but the
-- driver swap is protected, so defer it out of combat when needed.
function Module:UpdateStanceVisibility(bar)
	bar = bar or (self.bars and self.bars.StanceBar)
	if not bar then
		return
	end
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
			Module:UnregisterEvent("PLAYER_REGEN_ENABLED")
			Module:UpdateStanceVisibility(bar)
		end)
		return
	end
	if (GetNumShapeshiftForms() or 0) > 0 then
		RegisterStateDriver(bar, "visibility", "[petbattle][vehicleui][overridebar] hide; show")
	else
		UnregisterStateDriver(bar, "visibility")
		bar:Hide()
	end
end
