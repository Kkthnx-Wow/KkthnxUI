--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Manages and skins the Pet Action Bar.
-- - Design: Reparents Blizzard's PetActionButtons and implements custom update logic.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("ActionBar")

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache globals and pet-related APIs for high-frequency updates.
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

local MARGIN = 6

-- ---------------------------------------------------------------------------
-- PET BAR UTILITIES
-- ---------------------------------------------------------------------------

local function hasPetActionHighlightMark(index)
	return PET_ACTION_HIGHLIGHT_MARKS and PET_ACTION_HIGHLIGHT_MARKS[index]
end

-- REASON: Garbage collection and performance protection.
-- Cancels pending spell info requests if the button is updated or hidden.
local function CancelSpellLoad(button)
	local cancelFunc = button and button.spellDataLoadedCancelFunc
	if cancelFunc then
		cancelFunc()
		button.spellDataLoadedCancelFunc = nil
	end
end

-- REASON: Lightweight update path for events that only affect mana/energy or spell activation range.
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

		-- NOTE: Highlight marks (proc glows) can fluctuate rapidly; refresh them here.
		SharedActionButton_RefreshSpellHighlight(petActionButton, hasPetActionHighlightMark(i))
	end
end

-- REASON: Comprehensive update path for when pet abilities actually change (e.g. summoning different pet).
function Module:UpdatePetBar(frame)
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

		-- NOTE: Fetch subtext (e.g. "Rank 2") asynchronously to avoid frame stutters on initial pet load.
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

		-- REASON: Visual feedback for active pet states.
		-- Attack commands flash instead of showing a solid checked state to avoid confusion with toggles.
		if isActive then
			if IsPetAttackAction(i) then
				petActionButton:StartFlash()
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

-- ---------------------------------------------------------------------------
-- EVENT HANDLERS
-- ---------------------------------------------------------------------------

function Module.PetBarOnEvent(event, unit)
	-- NOTE: Filter out unit events from non-player/non-pet sources immediately for performance.
	if (event == "UNIT_PET" or event == "UNIT_FLAGS") and unit and unit ~= "player" and unit ~= "pet" then
		return
	end

	-- REASON: UNIT_FLAGS often triggers for harmless changes (buffs/debuffs)
	-- that only require a quick usability check rather than a full icon scan.
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

-- ---------------------------------------------------------------------------
-- BAR CREATION
-- ---------------------------------------------------------------------------

function Module:CreatePetbar()
	local num = NUM_PET_ACTION_SLOTS
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBarPet", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Pet Actionbar", "PetBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, MARGIN })
	Module.movers[10] = frame.mover

	-- REASON: reparent Blizzard's default pet buttons to our custom container.
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

	-- NOTE: Manage pet bar visibility based on game state (vehicle, override, etc.).
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	Module:UpdatePetBar(PetActionBar)

	-- Register all relevant events for pet bar management.
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
