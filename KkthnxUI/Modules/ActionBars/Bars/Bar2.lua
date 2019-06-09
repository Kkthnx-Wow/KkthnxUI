local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreateBar2()
	local padding, margin, size = 0, 6, 34
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Style.Value

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar2", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(size + 2*padding)
	if layout == 5 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -120, 44}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 44}
	end
	frame:SetScale(1)

	-- Move The Buttons Into Position And Reparent Them
	MultiBarBottomLeft:SetParent(frame)
	MultiBarBottomLeft:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarBottomLeftButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(size, size)
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
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "Bar2", "Bar2", frame.Pos)

	if C["ActionBar"].Bar2Fade == true and K.BarFaderConfig then
		K.CreateButtonFrameFader(frame, buttonList)
	end
end