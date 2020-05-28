local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.actionBar5

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local SHOW_MULTIBAR4_TEXT = _G.SHOW_MULTIBAR4_TEXT
local UIParent = _G.UIParent

function Module:CreateBar5()
	local padding, margin = 0, 6
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Layout.Value
	local buttonSize = C["ActionBar"].RightButtonSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar5", UIParent, "SecureHandlerStateTemplate")
	if layout == "Four Stacked" then
		frame:SetWidth(num * buttonSize + (num - 1) * margin + 2 * padding)
		frame:SetHeight(buttonSize + 2 * padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 124}
	else
		frame:SetWidth(buttonSize + 2  *  padding)
		frame:SetHeight(num * buttonSize + (num - 1) * margin + 2 * padding)
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -(frame:GetWidth() + 10), 0}
	end

	-- Move The Buttons Into Position And Reparent Them
	_G.MultiBarLeft:SetParent(frame)
	_G.MultiBarLeft:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarLeftButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()
		if layout == "Four Stacked" then
			if i == 1 then
				button:SetPoint("LEFT", frame, padding, 0)
			else
				local previous = _G["MultiBarLeftButton"..i - 1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		else
			if i == 1 then
				button:SetPoint("TOPRIGHT", frame, -padding, -padding)
			else
				local previous = _G["MultiBarLeftButton"..i - 1]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			end
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if K.ActionBars.userPlaced then
		frame.mover = K.Mover(frame, SHOW_MULTIBAR4_TEXT, "Bar5", frame.Pos)
	end

	if C["ActionBar"].FadeRightBar2 and FilterConfig.fader then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end