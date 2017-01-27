local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

-- Lua API
local _G = _G
local unpack = unpack

-- Wow API
local AutoCastShine_AutoCastStart = _G.AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = _G.AutoCastShine_AutoCastStop
local GetNumShapeshiftForms = _G.GetNumShapeshiftForms
local GetPetActionInfo = _G.GetPetActionInfo
local GetPetActionSlotUsable = _G.GetPetActionSlotUsable
local GetShapeshiftFormCooldown = _G.GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = _G.GetShapeshiftFormInfo
local InCombatLockdown = _G.InCombatLockdown
local IsPetAttackAction = _G.IsPetAttackAction
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local PetActionButton_StartFlash = _G.PetActionButton_StartFlash
local PetActionButton_StopFlash = _G.PetActionButton_StopFlash
local PetHasActionBar = _G.PetHasActionBar
local SetDesaturation = _G.SetDesaturation

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ShiftHolder, CooldownFrame_Set, StanceBarFrame

-- PET AND SHAPESHIFT BARS STYLE FUNCTION
K.ShiftBarUpdate = function(...)
	local numForms = GetNumShapeshiftForms()
	local texture, name, isActive, isCastable
	local button, icon, cooldown
	local start, duration, enable
	for i = 1, NUM_STANCE_SLOTS do
		button = _G["StanceButton"..i]
		icon = _G["StanceButton"..i.."Icon"]
		if i <= numForms then
			texture, name, isActive, isCastable = GetShapeshiftFormInfo(i)
			icon:SetTexture(texture)

			cooldown = _G["StanceButton"..i.."Cooldown"]
			if texture then
				cooldown:SetAlpha(1)
			else
				cooldown:SetAlpha(0)
			end

			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_Set(cooldown, start, duration, enable)

			if isActive then
				StanceBarFrame.lastSelected = button:GetID()
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

K.PetBarUpdate = function(...)
	local petActionButton, petActionIcon, petAutoCastableTexture, petAutoCastShine
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local buttonName = "PetActionButton"..i
		petActionButton = _G[buttonName]
		petActionIcon = _G[buttonName.."Icon"]
		petAutoCastableTexture = _G[buttonName.."AutoCastable"]
		petAutoCastShine = _G[buttonName.."Shine"]
		local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(i)

		if not isToken then
			petActionIcon:SetTexture(texture)
			petActionButton.tooltipName = name
		else
			petActionIcon:SetTexture(_G[texture])
			petActionButton.tooltipName = _G[name]
		end

		petActionButton.isToken = isToken
		petActionButton.tooltipSubtext = subtext

		if isActive and name ~= "PET_ACTION_FOLLOW" then
			petActionButton:SetChecked(true)
			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(petActionButton)
			end
		else
			petActionButton:SetChecked(false)
			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(petActionButton)
			end
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

		if name then
			if not C.ActionBar.Grid then
				petActionButton:SetAlpha(1)
			end
		else
			if not C.ActionBar.Grid then
				petActionButton:SetAlpha(0)
			end
		end

		if texture then
			if GetPetActionSlotUsable(i) then
				SetDesaturation(petActionIcon, nil)
			else
				SetDesaturation(petActionIcon, 1)
			end
			petActionIcon:Show()
		else
			petActionIcon:Hide()
		end

		if not PetHasActionBar() and texture and name ~= "PET_ACTION_FOLLOW" then
			PetActionButton_StopFlash(petActionButton)
			SetDesaturation(petActionIcon, 1)
			petActionButton:SetChecked(false)
		end
	end
end