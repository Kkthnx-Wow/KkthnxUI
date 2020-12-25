local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = C.ActionBars.actionBar3

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local SHOW_MULTIBAR2_TEXT = _G.SHOW_MULTIBAR2_TEXT
local UIParent = _G.UIParent

local padding, margin = 0, 6

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	local layout = C["ActionBar"].Layout.Value
	if layout == "3x4 Boxed arrangement" then
		frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
		frame:SetHeight(size + 2 * padding)
	else
		frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
		frame:SetHeight(size + 2 * padding)
	end

	if not frame.mover then
		frame.mover = K.Mover(frame, SHOW_MULTIBAR2_TEXT, "Bar3", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Module:CreateBar3()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Layout.Value
	local buttonSize = C["ActionBar"].DefaultButtonSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KKUI_ActionBar3", UIParent, "SecureHandlerStateTemplate")
	if layout == "3x4 Boxed arrangement" then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 4}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 84}
	end

	-- Move The Buttons Into Position And Reparent Them
	_G.MultiBarBottomRight:SetParent(frame)
	_G.MultiBarBottomRight:EnableMouse(false)
	_G.MultiBarBottomRight.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarBottomRightButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("LEFT", frame, padding, 0)
		else
			local previous = _G["MultiBarBottomRightButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, buttonSize, num)

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if C["ActionBar"].FadeBottomBar3 then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end