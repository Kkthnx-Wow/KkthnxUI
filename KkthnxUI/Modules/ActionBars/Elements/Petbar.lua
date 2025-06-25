local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

local _G = _G
local tinsert = tinsert

local margin = 6

local function hasPetActionHighlightMark(index)
	return PET_ACTION_HIGHLIGHT_MARKS[index]
end

function Module:UpdatePetBar()
	local petActionButton, petActionIcon, petAutoCastOverlay
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		petActionButton = self.actionButtons[i]
		petActionIcon = petActionButton.icon
		petAutoCastOverlay = petActionButton.AutoCastOverlay
		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)
		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end
		petActionButton.isToken = isToken
		if spellID then
			local spell = Spell:CreateFromSpellID(spellID)
			petActionButton.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
				petActionButton.tooltipSubtext = spell:GetSpellSubtext()
			end)
		end
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
		petAutoCastOverlay:SetShown(autoCastAllowed)
		petAutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled)
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

		SharedActionButton_RefreshSpellHighlight(petActionButton, hasPetActionHighlightMark(i))
	end
	self:UpdateCooldowns()
	self.rangeTimer = -1
end

function Module.PetBarOnEvent(event)
	if event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar:UpdateCooldowns()
	else
		Module.UpdatePetBar(PetActionBar)
	end
end

function Module:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Pet Actionbar", "PetBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, margin })
	Module.movers[10] = frame.mover

	for i = 1, num do
		local button = _G["PetActionButton" .. i]
		button:SetParent(frame)
		tinsert(buttonList, button)
		tinsert(Module.buttons, button)

		local hotkey = button.HotKey
		if hotkey then
			hotkey:ClearAllPoints()
			hotkey:SetPoint("TOPRIGHT", 0, -2)
		end
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	Module:PetBarOnEvent()
	K:RegisterEvent("UNIT_PET", Module.PetBarOnEvent)
	K:RegisterEvent("UNIT_FLAGS", Module.PetBarOnEvent)
	K:RegisterEvent("PET_UI_UPDATE", Module.PetBarOnEvent)
	K:RegisterEvent("PET_BAR_UPDATE", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_CONTROL_LOST", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_CONTROL_GAINED", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_TARGET_CHANGED", Module.PetBarOnEvent)
	K:RegisterEvent("PET_BAR_UPDATE_USABLE", Module.PetBarOnEvent)
	K:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", Module.PetBarOnEvent)
	K:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", Module.PetBarOnEvent)
end
