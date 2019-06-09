local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreateBar5()
	local padding, margin, size = 0, 6, 34
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Style.Value

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar5", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(size + 2  *  padding)
	frame:SetHeight(num * size + (num - 1) * margin + 2 * padding)
	if layout == 1 or layout == 4 or layout == 5 then
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -(frame:GetWidth() + 10), 0}
	else
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -4, 0}
	end
	frame:SetScale(1)

	-- Move The Buttons Into Position And Reparent Them
	MultiBarLeft:SetParent(frame)
	MultiBarLeft:EnableMouse(false)
	hooksecurefunc(MultiBarLeft, "SetScale", function(self, scale)
		if scale < 1 then
			self:SetScale(1)
		end
	end)

	for i = 1, num do
		local button = _G["MultiBarLeftButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("TOPRIGHT", frame, -padding, -padding)
		else
			local previous = _G["MultiBarLeftButton"..i-1]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "Bar5", "Bar5", frame.Pos)

	if C["ActionBar"].Bar5Fade == true and K.BarFaderConfig then
		K.CreateButtonFrameFader(frame, buttonList)
	end
end