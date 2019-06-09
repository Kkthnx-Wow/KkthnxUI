local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreateBar3()
	local padding, margin, size = 0, 6, 34
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Style.Value

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar3", UIParent, "SecureHandlerStateTemplate")
	if layout == 4 then
		frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
		frame:SetHeight(size + 2 * padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 84}
	elseif layout == 5 then
		frame:SetWidth(6 * size + 5 * margin + 2 * padding)
		frame:SetHeight(2 * size + margin + 2 * padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 240, 4}
	else
		frame:SetWidth(19 * size + 13 * margin + 2 * padding)
		frame:SetHeight(2 * size + margin + 2 * padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 4}
	end
	frame:SetScale(1)

	-- Move The Buttons Into Position And Reparent Them
	MultiBarBottomRight:SetParent(frame)
	MultiBarBottomRight:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBarBottomRightButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			if layout == 4 then
				button:SetPoint("LEFT", frame, padding, 0)
			else
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			end
		elseif (i == 4 and layout < 4) or (i == 7 and layout == 5) then
			local previous = _G["MultiBarBottomRightButton1"]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		elseif i == 7 and layout < 4 then
			local previous = _G["MultiBarBottomRightButton3"]
			button:SetPoint("LEFT", previous, "RIGHT", 13 * size + 9 * margin, 0)
		elseif i == 10 and layout < 4 then
			local previous = _G["MultiBarBottomRightButton7"]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		else
			local previous = _G["MultiBarBottomRightButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "Bar3", "Bar3", frame.Pos)

	if C["ActionBar"].Bar3Fade == true and K.BarFaderConfig then
		K.CreateButtonFrameFader(frame, buttonList)
	end
end