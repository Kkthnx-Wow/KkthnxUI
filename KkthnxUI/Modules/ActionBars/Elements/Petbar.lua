local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

-- Cached globals
local AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop
local GetPetActionInfo = GetPetActionInfo
local GetPetActionSlotUsable = GetPetActionSlotUsable
local IsPetAttackAction = IsPetAttackAction
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local PET_ACTION_HIGHLIGHT_MARKS = PET_ACTION_HIGHLIGHT_MARKS
local SharedActionButton_RefreshSpellHighlight = SharedActionButton_RefreshSpellHighlight

local margin = 6

local function hasPetActionHighlightMark(index)
	return PET_ACTION_HIGHLIGHT_MARKS[index]
end

-- Update pet action buttons
function Module:UpdatePetBar()
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		-- Get the action button and its subcomponents
		petActionButton = self.actionButtons[i]
		petActionIcon = petActionButton.icon
		petAutoCastableTexture = petActionButton.AutoCastable
		petAutoCastShine = petActionButton.AutoCastShine

		-- Get info about the pet action
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)

		-- Set icon and tooltip for pet action
		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end

		-- Set pet action button data
		petActionButton.isToken = isToken

		-- Load spell data and set tooltip subtext
		if spellID then
			local spell = Spell:CreateFromSpellID(spellID)
			petActionButton.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
				petActionButton.tooltipSubtext = spell:GetSpellSubtext()
			end)
		end

		-- Set button visual state based on whether it is active or not
		if isActive then
			if IsPetAttackAction(i) then
				petActionButton:StartFlash()
				-- the checked texture looks a little confusing at full alpha (looks like you have an extra ability selected)
				petActionButton:GetCheckedTexture():SetAlpha(0.5)
			else
				petActionButton:StopFlash()
				petActionButton:GetCheckedTexture():SetAlpha(1.0)
			end
			petActionButton:SetChecked(true)
		else
			petActionButton:StopFlash()
			petActionButton:SetChecked(false)
		end

		-- Show or hide the auto-castable texture
		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end

		-- Start or stop the auto-cast shine animation
		if autoCastEnabled then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
		end

		-- Set icon color based on whether the action is usable or not
		if texture then
			if GetPetActionSlotUsable(i) then
				petActionIcon:SetVertexColor(1, 1, 1)
			else
				petActionIcon:SetVertexColor(0.4, 0.4, 0.4)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end

		-- Refresh spell highlight
		SharedActionButton_RefreshSpellHighlight(petActionButton, hasPetActionHighlightMark(i))
	end

	-- Update cooldowns and range timer
	self:UpdateCooldowns()
	self.rangeTimer = -1
end

-- Function to handle events that update the pet action bar
function Module.PetBarOnEvent(event)
	-- If the event is PET_BAR_UPDATE_COOLDOWN, call UpdateCooldowns for the pet action bar
	if event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar:UpdateCooldowns()
	-- Otherwise, call UpdatePetBar for the pet action bar
	else
		Module.UpdatePetBar(PetActionBar)
	end
end

-- Create pet action bar
function Module:CreatePetActionBar()
	-- Number of pet action slots
	local numPetActions = NUM_PET_ACTION_SLOTS
	-- Empty table to hold pet action buttons
	local petActionButtons = {}

	-- Create the frame for the pet action bar
	local frame = CreateFrame("Frame", "KKUI_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	-- Set the mover for the frame
	frame.mover = K.Mover(frame, "Pet Actionbar", "PetBar", { "BOTTOM", _G.KKUI_ActionBar3, "TOP", 0, margin })
	-- Add the mover to the movers list
	Module.movers[10] = frame.mover

	-- Loop through each pet action slot
	for i = 1, numPetActions do
		-- Get the pet action button
		local petActionButton = _G["PetActionButton" .. i]
		-- Set the parent of the pet action button to the frame
		petActionButton:SetParent(frame)
		-- Add the pet action button to the list of pet action buttons
		table.insert(petActionButtons, petActionButton)
		-- Add the pet action button to the list of all action buttons
		table.insert(Module.buttons, petActionButton)

		-- Set the position of the hotkey text
		local hotkey = petActionButton.HotKey
		if hotkey then
			hotkey:ClearAllPoints()
			hotkey:SetPoint("TOPRIGHT", 0, -2)
		end
	end

	-- Set the list of pet action buttons for the frame
	frame.buttons = petActionButtons

	-- Set the visibility state for the frame
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Set the events that will trigger updates to the pet action bar
	local events = {
		"UNIT_PET",
		"UNIT_FLAGS",
		"PET_UI_UPDATE",
		"PET_BAR_UPDATE",
		"PLAYER_CONTROL_LOST",
		"PLAYER_CONTROL_GAINED",
		"PLAYER_TARGET_CHANGED",
		"PET_BAR_UPDATE_USABLE",
		"PET_BAR_UPDATE_COOLDOWN",
		"UPDATE_VEHICLE_ACTIONBAR",
		"PLAYER_MOUNT_DISPLAY_CHANGED",
		"PLAYER_FARSIGHT_FOCUS_CHANGED",
	}

	-- Call the PetBarOnEvent function to update the pet action bar
	Module:PetBarOnEvent()

	-- Register each event with the PetBarOnEvent function
	for _, event in ipairs(events) do
		K:RegisterEvent(event, Module.PetBarOnEvent)
	end
end
