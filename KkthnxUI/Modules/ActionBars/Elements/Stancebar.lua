local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.stanceBar

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreateStancebar()
	local padding, margin = 0, 6
	local num = NUM_STANCE_SLOTS
	local buttonList = {}
	local layout = C["ActionBar"].Layout.Value
	local buttonSize = C["ActionBar"].StancePetSize

	-- Make A Frame That Fits The Size Of All Microbuttons
	local frame = CreateFrame("Frame", "KkthnxUI_StanceBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * buttonSize + (num - 1) * margin + 2 * padding)
	frame:SetHeight(buttonSize + 2 * padding + 2)
	if layout == "Four Stacked" then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -60, 164}
	elseif layout == "3x4 Boxed arrangement" then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -60, 44}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -60, 124}
	end

	-- Stance Bar
	-- Move The Buttons Into Position And Reparent Them
	_G.StanceBarFrame:SetParent(frame)
	_G.StanceBarFrame:EnableMouse(false)
	_G.StanceBarLeft:SetTexture(nil)
	_G.StanceBarMiddle:SetTexture(nil)
	_G.StanceBarRight:SetTexture(nil)

	for i = 1, num do
		local button = _G["StanceButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding + 1)
		else
			local previous = _G["StanceButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	PossessBarFrame:SetParent(frame)
	PossessBarFrame:EnableMouse(false)
	PossessBackground1:SetTexture(nil)
	PossessBackground2:SetTexture(nil)

	for i = 1, NUM_POSSESS_SLOTS do
		local button = _G["PossessButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding + 1)
		else
			local previous = _G["PossessButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- create drag frame and drag functionality
	if K.ActionBars.userPlaced then
		frame.mover = K.Mover(frame, "StanceBar", "StanceBar", frame.Pos)
	end

	-- Create the mouseover functionality
	if C["ActionBar"].FadeStanceBar and FilterConfig.fader then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end