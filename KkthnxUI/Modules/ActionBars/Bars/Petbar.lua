local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreatePetbar()
	local padding, margin, size = 0, 6, 32
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_PetActionBar", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * size + (num - 1) * margin + 2 * padding + 20)
	frame:SetHeight(size + 2 * padding + 2)
	frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 124}
	frame:SetScale(1)

	-- Move The Buttons Into Position And Reparent Them
	PetActionBarFrame:SetParent(frame)
	PetActionBarFrame:EnableMouse(false)
	SlidingActionBarTexture0:SetTexture(nil)
	SlidingActionBarTexture1:SetTexture(nil)

	for i = 1, num do
		local button = _G["PetActionButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(size, size)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("LEFT", frame, padding, 0)
		else
			local previous = _G["PetActionButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end

		local cd = _G["PetActionButton"..i.."Cooldown"]
		cd:SetAllPoints(button)
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "PetBar", "PetBar", frame.Pos)

	if C["ActionBar"].PetFade == true and K.BarFaderConfig then
		K.CreateButtonFrameFader(frame, buttonList)
	end
end