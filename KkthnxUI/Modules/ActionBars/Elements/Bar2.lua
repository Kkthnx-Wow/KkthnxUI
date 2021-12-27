local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local SHOW_MULTIBAR1_TEXT = _G.SHOW_MULTIBAR1_TEXT
local UIParent = _G.UIParent

local cfg = C.Bars.Bar2
local margin, padding = C.Bars.BarMargin, C.Bars.BarPadding

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	local layout = C["ActionBar"].Layout.Value
	if layout == 3 then
		frame:SetWidth(3 * size + (3 - 1) * margin + 2 * padding)
		frame:SetHeight(4 * size + (4 - 1) * margin + 2 * padding)
	else
		frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
		frame:SetHeight(size + 2 * padding)
	end

	if not frame.mover then
		frame.mover = K.Mover(frame, SHOW_MULTIBAR1_TEXT, "Bar2", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Module:CreateBar2()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Layout.Value

	local frame = CreateFrame("Frame", "KKUI_ActionBar2", UIParent, "SecureHandlerStateTemplate")
	if layout == 3 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 305, 124}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 44}
	end

	_G.MultiBarBottomLeft:SetParent(frame)
	_G.MultiBarBottomLeft:EnableMouse(false)
	_G.MultiBarBottomLeft.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarBottomLeftButton"..i]
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
		button:ClearAllPoints()

		if layout == 3 then
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, padding)
			elseif (i - 1) % 3 == 0 then
				local previous = _G["MultiBarBottomLeftButton"..i - 3]
				button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, margin * (-1))
			else
				local previous = _G["MultiBarBottomLeftButton"..i - 1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		else
			if i == 1 then
				button:SetPoint("BOTTOMLEFT", frame, padding, padding)
			else
				local previous = _G["MultiBarBottomLeftButton"..i - 1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, cfg.size, num)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end