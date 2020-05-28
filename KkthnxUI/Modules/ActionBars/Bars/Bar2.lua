local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.actionBar2

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local SHOW_MULTIBAR1_TEXT = _G.SHOW_MULTIBAR1_TEXT
local UIParent = _G.UIParent

function Module:CreateBar2()
	local padding, margin = 0, 6
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Layout.Value
	local buttonSize = C["ActionBar"].DefaultButtonSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar2", UIParent, "SecureHandlerStateTemplate")
	if layout == "3x4 Boxed arrangement" then
		frame:SetWidth(3 * buttonSize + (3 - 1) * margin + 2 * padding)
		frame:SetHeight(4 * buttonSize + (4 - 1) * margin + 2 * padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 305, 124}
	else
		frame:SetWidth(num * buttonSize + (num - 1) * margin + 2 * padding)
		frame:SetHeight(buttonSize + 2 * padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 44}
	end

	-- Move The Buttons Into Position And Reparent Them
	_G.MultiBarBottomLeft:SetParent(frame)
	_G.MultiBarBottomLeft:EnableMouse(false)

	if layout == "3x4 Boxed arrangement" then
		for i = 1, num do
			local button = _G["MultiBarBottomLeftButton"..i]
			table_insert(buttonList, button) -- Add The Button Object To The List
			button:SetSize(buttonSize, buttonSize)
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, padding)
			elseif (i-1)%3 == 0 then
				local previous = _G["MultiBarBottomLeftButton"..i-3]
				button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, margin*(-1))
			else
				local previous = _G["MultiBarBottomLeftButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		end
	else
		for i = 1, num do
			local button = _G["MultiBarBottomLeftButton"..i]
			table_insert(buttonList, button) -- Add The Button Object To The List
			button:SetSize(buttonSize, buttonSize)
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", frame, padding, padding)
			else
				local previous = _G["MultiBarBottomLeftButton"..i-1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	if K.ActionBars.userPlaced then
		frame.mover = K.Mover(frame, SHOW_MULTIBAR1_TEXT, "Bar2", frame.Pos)
	end

	if FilterConfig.fader then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end