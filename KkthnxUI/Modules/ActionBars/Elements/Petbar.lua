local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

-- WoW / Lua locals
local _G = _G
local tinsert = tinsert

local GetPetActionInfo = GetPetActionInfo
local GetPetActionSlotUsable = GetPetActionSlotUsable
local IsPetAttackAction = IsPetAttackAction
local RegisterStateDriver = RegisterStateDriver
local SharedActionButton_RefreshSpellHighlight = SharedActionButton_RefreshSpellHighlight
local CreateFrame = CreateFrame
local UIParent = UIParent
local Spell = Spell

local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local PET_ACTION_HIGHLIGHT_MARKS = PET_ACTION_HIGHLIGHT_MARKS

-- Constants
local MARGIN = 6

local function hasPetActionHighlightMark(index)
	return PET_ACTION_HIGHLIGHT_MARKS and PET_ACTION_HIGHLIGHT_MARKS[index]
end

local function CancelSpellLoad(button)
	local cancelFunc = button and button.spellDataLoadedCancelFunc
	if cancelFunc then
		cancelFunc()
		button.spellDataLoadedCancelFunc = nil
	end
end

function Module:UpdatePetBarUsable(frame)
	frame = frame or PetActionBar
	if not frame or not frame.actionButtons then
		return
	end

	for i = 1, NUM_PET_ACTION_SLOTS do
		local petActionButton = frame.actionButtons[i]
		if not petActionButton then
			break
		end

		local petActionIcon = petActionButton.icon
		if petActionIcon and petActionIcon:IsShown() then
			if GetPetActionSlotUsable(i) then
				petActionIcon:SetVertexColor(1, 1, 1)
			else
				petActionIcon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end

		-- Comment: Highlight marks can change due to pet states; keep it cheap on usable updates
		SharedActionButton_RefreshSpellHighlight(petActionButton, hasPetActionHighlightMark(i))
	end
end

function Module:UpdatePetBar(frame)
	frame = frame or PetActionBar
	if not frame or not frame.actionButtons then
		return
	end

	-- Comment: Full refresh (used on PET_BAR_UPDATE/PET_UI_UPDATE/etc.)
	for i = 1, NUM_PET_ACTION_SLOTS do
		local petActionButton = frame.actionButtons[i]
		if not petActionButton then
			break
		end

		local petActionIcon = petActionButton.icon
		local petAutoCastOverlay = petActionButton.AutoCastOverlay

		local name, texture, isToken, isActive, autoCastAllowed, autoCastEnabled, spellID = GetPetActionInfo(i)

		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end

		petActionButton.isToken = isToken

		-- Comment: Prevent piling up async spell-load callbacks when the pet bar updates frequently
		if spellID and Spell and Spell.CreateFromSpellID then
			if petActionButton._kkSpellID ~= spellID then
				petActionButton._kkSpellID = spellID
				CancelSpellLoad(petActionButton)

				local spell = Spell:CreateFromSpellID(spellID)
				petActionButton.spellDataLoadedCancelFunc = spell:ContinueWithCancelOnSpellLoad(function()
					petActionButton.tooltipSubtext = spell:GetSpellSubtext()
				end)
			end
		else
			if petActionButton._kkSpellID ~= nil then
				petActionButton._kkSpellID = nil
				petActionButton.tooltipSubtext = nil
				CancelSpellLoad(petActionButton)
			end
		end

		if isActive then
			if IsPetAttackAction(i) then
				petActionButton:StartFlash()
				-- Comment: Checked alpha looks confusing at full alpha (looks like multiple selections)
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

		if petAutoCastOverlay then
			petAutoCastOverlay:SetShown(autoCastAllowed)
			petAutoCastOverlay:ShowAutoCastEnabled(autoCastEnabled)
		end

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

	frame:UpdateCooldowns()
	frame.rangeTimer = -1
end

function Module.PetBarOnEvent(event, unit)
	-- Comment: Unit-gated events (skip spam from raid/party pets)
	if (event == "UNIT_PET" or event == "UNIT_FLAGS") and unit and unit ~= "player" and unit ~= "pet" then
		return
	end

	-- Comment: UNIT_FLAGS can fire frequently; it only needs a cheap usability/highlight refresh
	if event == "UNIT_FLAGS" then
		Module:UpdatePetBarUsable(PetActionBar)
		return
	end

	if event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar:UpdateCooldowns()
		return
	end

	if event == "PET_BAR_UPDATE_USABLE" or event == "PLAYER_TARGET_CHANGED" then
		Module:UpdatePetBarUsable(PetActionBar)
		return
	end

	Module:UpdatePetBar(PetActionBar)
end

function Module:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Pet Actionbar", "PetBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, MARGIN })
	Module.movers[10] = frame.mover

	for i = 1, num do
		local button = _G["PetActionButton" .. i]
		if not button then
			break
		end

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

	-- Comment: Do an initial refresh once; events handle incremental updates after that
	Module:UpdatePetBar(PetActionBar)

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
