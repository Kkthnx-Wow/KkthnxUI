local K = unpack(select(2, ...))
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

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar2", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * FilterConfig.size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(FilterConfig.size + 2 * padding)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 44}

	-- Move The Buttons Into Position And Reparent Them
	_G.MultiBarBottomLeft:SetParent(frame)
	_G.MultiBarBottomLeft:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarBottomLeftButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(FilterConfig.size, FilterConfig.size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["MultiBarBottomLeftButton"..i-1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	if K.ActionBars.userPlaced then
		K.Mover(frame, SHOW_MULTIBAR1_TEXT, "Bar2", frame.Pos)
	end

	if FilterConfig.fader then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end