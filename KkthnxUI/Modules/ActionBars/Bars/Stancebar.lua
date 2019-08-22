local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.stanceBar

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_POSSESS_SLOTS = _G.NUM_POSSESS_SLOTS
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreateStancebar()
	local padding, margin = 0, 6
	local num = NUM_STANCE_SLOTS
	local buttonList = {}

	-- Make A Frame That Fits The Size Of All Microbuttons
	local frame = CreateFrame("Frame", "KkthnxUI_StanceBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * FilterConfig.size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(FilterConfig.size + 2 * padding + 2)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -70, 124}

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
		button:SetSize(FilterConfig.size, FilterConfig.size)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding + 1)
		else
			local previous = _G["StanceButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	-- Possess Bar
	-- Move The Buttons Into Position And Reparent Them
	_G.PossessBarFrame:SetParent(frame)
	_G.PossessBarFrame:EnableMouse(false)
	_G.PossessBackground1:SetTexture(nil)
	_G.PossessBackground2:SetTexture(nil)

	for i = 1, NUM_POSSESS_SLOTS do
		local button = _G["PossessButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(FilterConfig.size, FilterConfig.size)
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

	-- create drag frame and drag functionality
	if K.ActionBars.userPlaced then
		K.Mover(frame, "StanceBar", "StanceBar", frame.Pos)
	end

	-- create the mouseover functionality
	if FilterConfig.fader then
		K.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end