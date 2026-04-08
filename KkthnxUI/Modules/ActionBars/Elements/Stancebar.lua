--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Manages and skins the Class Stance/Shapeshift Bar.
-- - Design: Reparents Blizzard's StanceButtons and provides custom layout controls.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache globals and shapeshift APIs for performance during stance switching.
local _G = _G
local tinsert = tinsert
local math_ceil = math.ceil
local math_floor = math.floor
local math_min = math.min

local CooldownFrame_Set = CooldownFrame_Set
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local CreateFrame = CreateFrame
local UIParent = UIParent

local MARGIN, PADDING = 6, 0
local NUM_SLOTS = NUM_STANCE_SLOTS or 10

-- ---------------------------------------------------------------------------
-- STANCE BAR UTILITIES
-- ---------------------------------------------------------------------------

local function GetStanceFrame()
	return _G.KKUI_ActionBarStance
end

-- COMPAT: Normalizes GetShapeshiftFormInfo return values across Retail and Classic clients.
-- REASON: Blizzard changed the return signature in newer patches; we wrap it to ensure
-- consistent access to texture, active state, and castability.
local function GetNormalizedShapeshiftFormInfo(index)
	local a, b, c, d, e = GetShapeshiftFormInfo(index)
	-- NOTE: Detect Retail-style returns (starts with icon, then active boolean).
	if type(b) == "boolean" or type(b) == "number" then
		return a, b and true or false, c and true or false, d or e
	end
	-- NOTE: Detect Classic-style returns (starts with icon, then name string).
	return a, c and true or false, d and true or false, e
end

-- ---------------------------------------------------------------------------
-- LAYOUT & UPDATES
-- ---------------------------------------------------------------------------

-- REASON: Recalculates the stance bar size and button positions based on user settings.
function Module:UpdateStanceBar()
	-- WARNING: Secure movement/layout is restricted in combat to prevent taints.
	if InCombatLockdown() then
		return
	end

	local frame = GetStanceFrame()
	if not frame or not frame.buttons then
		return
	end

	local size = C["ActionBar"].BarStanceSize
	local fontSize = C["ActionBar"].BarStanceFont
	local perRow = C["ActionBar"].BarStancePerRow

	-- NOTE: Safe clamp to prevent divide-by-zero if configuration is invalid.
	if not perRow or perRow < 1 then
		perRow = NUM_SLOTS
	end

	local column = math_min(NUM_SLOTS, perRow)
	local rows = math_ceil(NUM_SLOTS / perRow)
	local buttons = frame.buttons

	for i = 1, NUM_SLOTS do
		local button = buttons[i]
		if not button then
			break
		end

		button:SetSize(size, size)

		local buttonX = ((i - 1) % perRow) * (size + MARGIN) + PADDING
		local buttonY = math_floor((i - 1) / perRow) * (size + MARGIN) + PADDING

		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonX, -buttonY)

		Module:UpdateFontSize(button, fontSize)
	end

	frame:SetWidth(column * size + (column - 1) * MARGIN + 2 * PADDING)
	frame:SetHeight(size * rows + (rows - 1) * MARGIN + 2 * PADDING)
	frame.mover:SetSize(size, size)
end

-- NOTE: Lightweight update path for cooldown refreshes.
function Module:UpdateStanceCooldowns(frame)
	frame = frame or GetStanceFrame()
	if not frame or not frame.buttons then
		return
	end

	local numForms = GetNumShapeshiftForms()
	for i = 1, numForms do
		local button = frame.buttons[i]
		if not button then
			break
		end

		local start, duration, enable = GetShapeshiftFormCooldown(i)
		local cooldown = button.cooldown
		if cooldown then
			CooldownFrame_Set(cooldown, start, duration, enable)
		end
	end
end

-- NOTE: Lightweight update path for mana/energy availability.
function Module:UpdateStanceUsable(frame)
	frame = frame or GetStanceFrame()
	if not frame or not frame.buttons then
		return
	end

	local numForms = GetNumShapeshiftForms()
	for i = 1, numForms do
		local button = frame.buttons[i]
		if not button then
			break
		end

		local _, _, isCastable = GetNormalizedShapeshiftFormInfo(i)
		local icon = button.icon
		if icon then
			if isCastable then
				icon:SetVertexColor(1, 1, 1)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

-- NOTE: Lightweight update path for current active form (checked state).
function Module:UpdateStanceActive(frame)
	frame = frame or GetStanceFrame()
	if not frame or not frame.buttons then
		return
	end

	local numForms = GetNumShapeshiftForms()
	for i = 1, numForms do
		local button = frame.buttons[i]
		if not button then
			break
		end

		local _, isActive = GetNormalizedShapeshiftFormInfo(i)
		button:SetChecked(isActive and true or false)
	end
end

-- REASON: Performs a full refresh of all stance button properties (texture, visibility, state).
function Module:UpdateStance(frame)
	frame = frame or GetStanceFrame()
	if not frame or not frame.buttons then
		return
	end

	local inCombat = InCombatLockdown()
	local numForms = GetNumShapeshiftForms()

	for i = 1, NUM_SLOTS do
		local button = frame.buttons[i]
		if not button then
			break
		end

		local icon = button.icon
		local cooldown = button.cooldown

		if i <= numForms then
			local texture, isActive, isCastable = GetNormalizedShapeshiftFormInfo(i)

			if icon then
				icon:SetTexture(texture)
			end

			-- WARNING: Toggling button visibility (Show/Hide) triggers secure logic.
			-- We defer this until combat ends to avoid taints.
			if texture then
				if not inCombat then
					button:Show()
				end
				if cooldown then
					cooldown:Show()
				end
			else
				if not inCombat then
					button:Hide()
				end
				if cooldown then
					cooldown:Hide()
				end
			end

			local start, duration, enable = GetShapeshiftFormCooldown(i)
			if cooldown then
				CooldownFrame_Set(cooldown, start, duration, enable)
			end

			button:SetChecked(isActive and true or false)

			if icon then
				if isCastable then
					icon:SetVertexColor(1, 1, 1)
				else
					icon:SetVertexColor(0.4, 0.4, 0.4)
				end
			end
		else
			if not inCombat then
				button:Hide()
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- EVENT HANDLERS
-- ---------------------------------------------------------------------------

function Module.StanceBarOnEvent(event)
	local frame = GetStanceFrame()
	if not frame then
		return
	end

	-- REASON: Distinguish between layout-altering events and state-altering events
	-- to minimize redundant calculations.
	if event == "UPDATE_SHAPESHIFT_FORMS" then
		Module:UpdateStanceBar()
		Module:UpdateStance(frame)
		return
	end

	if event == "UPDATE_SHAPESHIFT_COOLDOWN" then
		Module:UpdateStanceCooldowns(frame)
		return
	end

	if event == "UPDATE_SHAPESHIFT_USABLE" then
		Module:UpdateStanceUsable(frame)
		return
	end

	if event == "UPDATE_SHAPESHIFT_FORM" then
		Module:UpdateStanceActive(frame)
		return
	end

	Module:UpdateStance(frame)
end

-- ---------------------------------------------------------------------------
-- BAR CREATION
-- ---------------------------------------------------------------------------

function Module:CreateStancebar()
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBarStance", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Stance Bar", "StanceBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, MARGIN })
	Module.movers[9] = frame.mover

	-- NOTE: Hijack Blizzard's stance buttons for our custom layout.
	for i = 1, NUM_SLOTS do
		local button = _G["StanceButton" .. i]
		if not button then
			break
		end

		button:SetParent(frame)

		tinsert(buttonList, button)
		tinsert(Module.buttons, button)
	end

	frame.buttons = buttonList

	-- NOTE: Determine visibility based on vehicle/override states.
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", not C["ActionBar"].ShowStance and "hide" or frame.frameVisibility)

	Module:UpdateStanceBar()
	Module:UpdateStance(frame)

	-- Register class-specific stance events.
	K:RegisterEvent("UPDATE_SHAPESHIFT_FORM", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", Module.StanceBarOnEvent)
end
