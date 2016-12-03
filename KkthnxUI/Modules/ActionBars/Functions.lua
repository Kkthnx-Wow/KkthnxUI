local K, C, L = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- Lua API
local _G = _G
local unpack = unpack

-- Wow API
local AutoCastShine_AutoCastStart = AutoCastShine_AutoCastStart
local AutoCastShine_AutoCastStop = AutoCastShine_AutoCastStop
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetPetActionInfo = GetPetActionInfo
local GetPetActionSlotUsable = GetPetActionSlotUsable
local GetShapeshiftFormCooldown = GetShapeshiftFormCooldown
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local InCombatLockdown = InCombatLockdown
local IsPetAttackAction = IsPetAttackAction
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS
local PetActionButton_StartFlash = PetActionButton_StartFlash
local PetActionButton_StopFlash = PetActionButton_StopFlash
local PetHasActionBar = PetHasActionBar
local SetDesaturation = SetDesaturation

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ShiftHolder, CooldownFrame_Set, StanceBarFrame

-- PET AND SHAPESHIFT BARS STYLE FUNCTION
K.ShiftBarUpdate = function(...)
	if InCombatLockdown() then return end
	local NumForms = GetNumShapeshiftForms()
	local Texture, Name, IsActive, IsCastable, Button, Icon, Cooldown, Start, Duration, Enable

	if NumForms == 0 then
		ShiftHolder:SetAlpha(0)
	else
		ShiftHolder:SetAlpha(1)

		for i = 1, NUM_STANCE_SLOTS do
			local ButtonName = "StanceButton"..i

			Button = _G[ButtonName]
			Icon = _G[ButtonName.."Icon"]

			if i <= NumForms then
				Texture, Name, IsActive, IsCastable = GetShapeshiftFormInfo(i)

				if not Icon then
					return
				end

				Icon:SetTexture(Texture)
				Cooldown = _G[ButtonName.."Cooldown"]

				if Texture then
					Cooldown:SetAlpha(1)
				else
					Cooldown:SetAlpha(0)
				end

				Start, Duration, Enable = GetShapeshiftFormCooldown(i)
				CooldownFrame_Set(Cooldown, Start, Duration, Enable)

				if IsActive then
					StanceBarFrame.lastSelected = Button:GetID()
					Button:SetChecked(true)

					if Button.Backdrop then
						Button.Backdrop:SetBackdropBorderColor(0, 1, 0)
					end
				else
					Button:SetChecked(false)

					if Button.Backdrop then
						Button.Backdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))
					end
				end

				if IsCastable then
					Icon:SetVertexColor(1.0, 1.0, 1.0)
				else
					Icon:SetVertexColor(0.4, 0.4, 0.4)
				end
			end
		end
	end
end

K.PetBarUpdate = function(...)
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		local ButtonName = "PetActionButton" .. i
		local PetActionButton = _G[ButtonName]
		local PetActionIcon = _G[ButtonName.."Icon"]
		local PetActionBackdrop = PetActionButton.Backdrop
		local PetAutoCastableTexture = _G[ButtonName.."AutoCastable"]
		local PetAutoCastShine = _G[ButtonName.."Shine"]
		local Name, SubText, Texture, IsToken, IsActive, AutoCastAllowed, AutoCastEnabled = GetPetActionInfo(i)

		if (not IsToken) then
			PetActionIcon:SetTexture(Texture)
			PetActionButton.tooltipName = Name
		else
			PetActionIcon:SetTexture(_G[Texture])
			PetActionButton.tooltipName = _G[Name]
		end

		PetActionButton.IsToken = IsToken
		PetActionButton.tooltipSubtext = SubText

		if (IsActive) then
			PetActionButton:SetChecked(1)

			if PetActionBackdrop then
				PetActionBackdrop:SetBackdropBorderColor(0, 1, 0)
			end

			if IsPetAttackAction(i) then
				PetActionButton_StartFlash(PetActionButton)
			end
		else
			PetActionButton:SetChecked()

			if PetActionBackdrop then
				PetActionBackdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))
			end

			if IsPetAttackAction(i) then
				PetActionButton_StopFlash(PetActionButton)
			end
		end

		if AutoCastAllowed then
			PetAutoCastableTexture:Show()
		else
			PetAutoCastableTexture:Hide()
		end

		if AutoCastEnabled then
			AutoCastShine_AutoCastStart(PetAutoCastShine)
		else
			AutoCastShine_AutoCastStop(PetAutoCastShine)
		end

		if Texture then
			if (GetPetActionSlotUsable(i)) then
				SetDesaturation(PetActionIcon, nil)
			else
				SetDesaturation(PetActionIcon, 1)
			end

			PetActionIcon:Show()
		else
			PetActionIcon:Hide()
		end

		if (not PetHasActionBar() and Texture and Name ~= "PET_ACTION_FOLLOW") then
			PetActionButton_StopFlash(PetActionButton)
			SetDesaturation(PetActionIcon, 1)
			PetActionButton:SetChecked(0)
		end
	end
end