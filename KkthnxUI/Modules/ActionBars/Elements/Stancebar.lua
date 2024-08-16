local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- Utility functions
local tinsert = tinsert

-- Layout constants
local margin, padding = 6, 0

-- Number of stance slots (default to 10 if not defined)
local num = NUM_STANCE_SLOTS or 10

function Module:UpdateStanceBar()
	-- Check if the player is in combat
	if InCombatLockdown() then
		return
	end

	-- Get the stance bar frame
	local frame = _G["KKUI_ActionBarStance"]
	if not frame then
		return
	end

	-- Get the size, font size, and number of buttons per row for the stance bar
	local size = C["ActionBar"].BarStanceSize
	local fontSize = C["ActionBar"].BarStanceFont
	local perRow = C["ActionBar"].BarStancePerRow

	-- Calculate the number of columns and rows required for the buttons
	local column = math.min(num, perRow)
	local rows = math.ceil(num / perRow)
	local buttons = frame.buttons

	local button, buttonX, buttonY

	-- Iterate through all buttons
	for i = 1, num do
		button = buttons[i]
		-- check if the button is defined
		if not button then
			break
		end
		-- Set the size of the button
		button:SetSize(size, size)
		-- Calculate the position of the button
		buttonX = ((i - 1) % perRow) * (size + margin) + padding
		buttonY = math.floor((i - 1) / perRow) * (size + margin) + padding
		-- Clear any previous position and set the new position
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonX, -buttonY)
		-- Update the font size of the button
		Module:UpdateFontSize(button, fontSize)
	end

	-- Set the width and height of the frame based on the number of columns and rows
	frame:SetWidth(column * size + (column - 1) * margin + 2 * padding)
	frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
	-- Set the size of the mover
	frame.mover:SetSize(size, size)
end

function Module:UpdateStance()
	local inCombat = InCombatLockdown()
	local numForms = GetNumShapeshiftForms()
	local texture, isActive, isCastable
	local icon, cooldown
	local start, duration, enable

	for i, button in pairs(self.actionButtons) do
		if not inCombat then
			button:Hide()
		end
		icon = button.icon
		if i <= numForms then
			texture, isActive, isCastable = GetShapeshiftFormInfo(i)
			icon:SetTexture(texture)

			--Cooldown stuffs
			cooldown = button.cooldown
			if texture then
				if not inCombat then
					button:Show()
				end
				cooldown:Show()
			else
				cooldown:Hide()
			end
			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_Set(cooldown, start, duration, enable)

			if isActive then
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

function Module:StanceBarOnEvent()
	Module:UpdateStanceBar()
	Module.UpdateStance(StanceBar)
end

function Module:CreateStancebar()
	local buttonList = {}
	local frame = CreateFrame("Frame", "KKUI_ActionBarStance", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "StanceBar", "StanceBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, margin })
	Module.movers[11] = frame.mover

	-- StanceBar
	StanceBar:SetParent(frame)
	StanceBar:EnableMouse(false)
	StanceBar:UnregisterAllEvents()

	for i = 1, num do
		local button = _G["StanceButton" .. i]
		button:SetParent(frame)
		tinsert(buttonList, button)
		tinsert(Module.buttons, button)
	end
	frame.buttons = buttonList

	-- Fix stance bar updating
	Module:StanceBarOnEvent()
	K:RegisterEvent("UPDATE_SHAPESHIFT_FORM", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", Module.StanceBarOnEvent)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", not C["ActionBar"].ShowStance and "hide" or frame.frameVisibility)
end
