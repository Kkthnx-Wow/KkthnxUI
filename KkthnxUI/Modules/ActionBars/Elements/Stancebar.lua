local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local tinsert = tinsert
local margin, padding = 6, 0

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

-- Updates the stance bar
function Module:UpdateStance()
	-- Check if the player is in combat
	local inCombat = InCombatLockdown()

	-- Get the number of available shapeshift forms
	local numForms = GetNumShapeshiftForms()

	-- Declare variables to be used later
	local texture, isActive, isCastable
	local icon, cooldown
	local start, duration, enable

	-- Loop through all the action buttons
	for i, button in pairs(self.actionButtons) do
		-- If not in combat, hide the button
		if not inCombat then
			button:Hide()
		end

		-- Get the button icon
		icon = button.icon

		-- Check if the button corresponds to a valid shapeshift form
		if i <= numForms then
			-- Get information about the shapeshift form
			texture, isActive, isCastable = GetShapeshiftFormInfo(i)
			icon:SetTexture(texture)

			-- Show/hide the button and its cooldown depending on whether the form has a texture and the player is not in combat
			cooldown = button.cooldown
			if texture then
				if not inCombat then
					button:Show()
				end
				cooldown:Show()
			else
				cooldown:Hide()
			end

			-- Set the cooldown on the button
			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_Set(cooldown, start, duration, enable)

			-- Set the button's checked status depending on whether the form is active
			button:SetChecked(isActive)

			-- Set the color of the button icon depending on whether the form is castable
			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0) -- white
			else
				icon:SetVertexColor(0.4, 0.4, 0.4) -- gray
			end
		end
	end
end

-- Called when the event fires for updating the stance bar
function Module:StanceBarOnEvent()
	Module:UpdateStanceBar() -- Update the stance bar
	Module.UpdateStance(StanceBar) -- Update the stance
end

-- Creates the stance bar
function Module:CreateStanceBar()
	-- Return if the stance bar is not enabled in the config
	if not C["ActionBar"].ShowStance then
		return
	end

	local buttonList = {}
	local frame = CreateFrame("Frame", "KKUI_ActionBarStance", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "StanceBar", "StanceBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, margin })
	Module.movers[11] = frame.mover

	-- Stance buttons
	local numForms = GetNumShapeshiftForms()
	for i = 1, numForms do
		local button = _G["StanceButton" .. i]
		button:SetParent(frame)
		tinsert(buttonList, button)
		tinsert(Module.buttons, button)
	end
	frame.buttons = buttonList

	-- Set the parent of the stance bar to the new frame
	StanceBar:SetParent(frame)

	-- Disable mouse interaction with the stance bar
	StanceBar:EnableMouse(false)

	-- Unregister all events from the default stance bar
	StanceBar:UnregisterAllEvents()

	-- Register events for updating the stance bar
	K:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", Module.StanceBarOnEvent)

	-- Set up the frame visibility state driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)
end
