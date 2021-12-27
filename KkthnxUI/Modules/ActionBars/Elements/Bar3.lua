local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local SHOW_MULTIBAR2_TEXT = _G.SHOW_MULTIBAR2_TEXT
local UIParent = _G.UIParent

local cfg = C.Bars.Bar3
local margin, padding = C.Bars.BarMargin, C.Bars.BarPadding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	local layout = C["ActionBar"].Layout.Value
	if layout == 3 then
		frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
		frame:SetHeight(size + 2 * padding)
	elseif layout == 4 then
		frame:SetWidth(18 * size + 19 * margin + 2 * padding)
		frame:SetHeight(2 * size + margin + 2 * padding)
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

	local frame = CreateFrame("Frame", "KKUI_ActionBar3", UIParent, "SecureHandlerStateTemplate")
	if layout == 3 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 4}
	elseif layout == 4 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 4}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 84}
	end

	_G.MultiBarBottomRight:SetParent(frame)
	_G.MultiBarBottomRight:EnableMouse(false)
	_G.MultiBarBottomRight.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarBottomRightButton"..i]
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
		button:ClearAllPoints()

		if layout == 4 then
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif (i == 4) then
				local previous = _G["MultiBarBottomRightButton1"]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			elseif i == 7 then
				button:SetPoint("TOPRIGHT", frame, -2 * (cfg.size + margin) - padding, -padding)
			elseif i == 10 then
				local previous = _G["MultiBarBottomRightButton7"]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			else
				local previous = _G["MultiBarBottomRightButton"..i - 1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		else
			if i == 1 then
				button:SetPoint("LEFT", frame, padding, 0)
			else
				local previous = _G["MultiBarBottomRightButton"..i - 1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, cfg.size, num)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if C.Bars.Bar3.fader then
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end