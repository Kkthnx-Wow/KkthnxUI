local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = C.ActionBars.petBar

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local padding, margin = 0, 6

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(size + 2 * padding + 2)
	if not frame.mover then
		frame.mover = K.Mover(frame, "Pet Actionbar", "PetBar", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

function Module:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}
	local layout = C["ActionBar"].Layout.Value
	local buttonSize = C["ActionBar"].StancePetSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KKUI_PetActionBar", UIParent, "SecureHandlerStateTemplate")
	if layout == "Four Stacked" then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 164}
	elseif layout == "3x4 Boxed arrangement" then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 44}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 123}
	end

	-- Move The Buttons Into Position And Reparent Them
	if C["ActionBar"].PetBar then
		_G.PetActionBarFrame:SetParent(frame)
		_G.PetActionBarFrame:EnableMouse(false)
		_G.SlidingActionBarTexture0:SetTexture(nil)
		_G.SlidingActionBarTexture1:SetTexture(nil)

		for i = 1, num do
			local button = _G["PetActionButton"..i]
			table_insert(buttonList, button)
			table_insert(Module.buttons, button)
			button:ClearAllPoints()

			if i == 1 then
				button:SetPoint("LEFT", frame, padding, 0)
			else
				local previous = _G["PetActionButton"..i - 1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, buttonSize, num)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create the mouseover functionality
	if C["ActionBar"].FadePetBar and FilterConfig.fader then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end
end