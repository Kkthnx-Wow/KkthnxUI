local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local NUM_POSSESS_SLOTS = _G.NUM_POSSESS_SLOTS
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreateStancebar()
	local padding, margin, size = 2, 6, 28
	local num = NUM_STANCE_SLOTS
	local buttonList = {}

	-- Make A Frame That Fits The Size Of All Microbuttons
	local frame = CreateFrame("Frame", "KkthnxUI_StanceBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -70, 124}
	frame:SetScale(1)

	-- Stance Bar
	-- Move The Buttons Into Position And Reparent Them
	StanceBarFrame:SetParent(frame)
	StanceBarFrame:EnableMouse(false)
	StanceBarLeft:SetTexture(nil)
	StanceBarMiddle:SetTexture(nil)
	StanceBarRight:SetTexture(nil)

	for i = 1, num do
		local button = _G["StanceButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(size, size)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["StanceButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	-- Possess Bar
	-- Move The Buttons Into Position And Reparent Them
	PossessBarFrame:SetParent(frame)
	PossessBarFrame:EnableMouse(false)
	PossessBackground1:SetTexture(nil)
	PossessBackground2:SetTexture(nil)

	for i = 1, NUM_POSSESS_SLOTS do
		local button = _G["PossessButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(size, size)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["PossessButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "StanceBar", "StanceBar", frame.Pos)

	if C["ActionBar"].StanceFade == true and K.BarFaderConfig then
		K.CreateButtonFrameFader(frame, buttonList)
	end
end