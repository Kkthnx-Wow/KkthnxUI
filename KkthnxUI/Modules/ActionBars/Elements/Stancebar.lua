local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
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

function Module:UpdateStance()
	-- Store whether the player is in combat or not, and the number of forms available
	local inCombat = InCombatLockdown()
	local numForms = GetNumShapeshiftForms()
	local texture, isActive, isCastable
	local icon, cooldown
	local start, duration, enable

	-- Iterate over all buttons in the self.actionButtons table
	for i, button in pairs(self.actionButtons) do
		-- Only update the button if the form is available
		if i <= numForms then
			-- Get the texture, active status, and castable status of the form
			texture, isActive, isCastable = GetShapeshiftFormInfo(i)
			icon = button.icon
			-- Set the texture of the button's icon
			icon:SetTexture(texture)

			-- Get the cooldown information for the form
			cooldown = button.cooldown
			start, duration, enable = GetShapeshiftFormCooldown(i)
			-- Set the cooldown information for the button's cooldown frame
			CooldownFrame_Set(cooldown, start, duration, enable)
			-- Show or hide the cooldown frame based on whether the form has a texture
			cooldown:SetShown(texture ~= nil)

			-- Check or uncheck the button depending on whether the form is active
			if isActive then
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end

			-- Set the color of the icon based on whether the form is castable
			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end

			if not inCombat then
				button:SetShown(texture ~= nil)
			end
		end
	end
end

function Module:StanceBarOnEvent()
	Module:UpdateStanceBar()
	Module.UpdateStance(StanceBar)
end

function Module:CreateStancebar()
	if not C["ActionBar"].ShowStance then
		return
	end

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
	K:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", Module.StanceBarOnEvent)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)
end
