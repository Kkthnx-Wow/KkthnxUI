local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.petBar

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreatePetbar()
	local padding, margin = 0, 6
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}
	local layout = C["ActionBar"].Layout.Value
	local buttonSize = C["ActionBar"].StancePetSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_PetActionBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * buttonSize + (num - 1) * margin + 2 * padding)
	frame:SetHeight(buttonSize + 2 * padding + 2)
	if layout == "Four Stacked" then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 164}
	elseif layout == "3x4 Boxed arrangement" then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 44}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 123}
	end

	-- Move The Buttons Into Position And Reparent Them
	_G.PetActionBarFrame:SetParent(frame)
	_G.PetActionBarFrame:EnableMouse(false)
	_G.SlidingActionBarTexture0:SetTexture(nil)
	_G.SlidingActionBarTexture1:SetTexture(nil)

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("LEFT", frame, padding, 0)
		else
			local previous = _G["PetActionButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end

		-- Cooldown Fix
		local cd = _G["PetActionButton"..i.."Cooldown"]
		cd:SetAllPoints(button)
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create drag frame and drag functionality
	if K.ActionBars.userPlaced then
		frame.mover = K.Mover(frame, "Pet Actionbar", "PetBar", frame.Pos)
	end

	-- Create the mouseover functionality
	if FilterConfig.fader then
		K.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end