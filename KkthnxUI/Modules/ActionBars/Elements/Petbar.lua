local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local cfg = C.Bars.BarPet
local margin = C.Bars.BarMargin

local function hasPetActionHighlightMark(index)
	return PET_ACTION_HIGHLIGHT_MARKS[index]
end

function Module:UpdatePetBar()
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		petActionButton = self.actionButtons[i]
		petActionIcon = petActionButton.icon
		petAutoCastableTexture = petActionButton.AutoCastable
		petAutoCastShine = petActionButton.AutoCastShine

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

		if autoCastAllowed then
			petAutoCastableTexture:Show()
		else
			petAutoCastableTexture:Hide()
		end

		if autoCastEnabled then
			AutoCastShine_AutoCastStart(petAutoCastShine)
		else
			AutoCastShine_AutoCastStop(petAutoCastShine)
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
	frame.mover = K.Mover(frame, "Pet Actionbar", "PetBar", { "BOTTOM", _G.KKUI_ActionBar3, "TOP", 0, margin })
	Module.movers[7] = frame.mover

	-- todo
	PetActionBar:SetParent(frame)
	PetActionBar:EnableMouse(false)
	PetActionBar:UnregisterAllEvents()

	for i = 1, num do
		local button = _G["PetActionButton" .. i]
		button:SetParent(frame)
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
	end
	frame.buttons = buttonList
	-- stylua: ignore
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; [pet] show; hide"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	-- Fix pet bar updating
	Module:PetBarOnEvent()
	K:RegisterEvent("UNIT_PET", Module.PetBarOnEvent)
	K:RegisterEvent("UNIT_FLAGS", Module.PetBarOnEvent)
	K:RegisterEvent("PET_UI_UPDATE", Module.PetBarOnEvent)
	K:RegisterEvent("PET_BAR_UPDATE", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_CONTROL_LOST", Module.PetBarOnEvent)
	K:RegisterEvent("PET_BAR_UPDATE_USABLE", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_CONTROL_GAINED", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_TARGET_CHANGED", Module.PetBarOnEvent)
	K:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", Module.PetBarOnEvent)
	K:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED", Module.PetBarOnEvent)
	K:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED", Module.PetBarOnEvent)
end
