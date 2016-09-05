local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- LUA API
local _G = _G

-- WOW API
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetShapeshiftFormInfo = GetShapeshiftFormInfo
local PetHasActionBar = PetHasActionBar

-- PET AND SHAPESHIFT BARS STYLE FUNCTION
K.ShiftBarUpdate = function(...)
	if InCombatLockdown() then return end
	local NumForms = GetNumShapeshiftForms()
	local Texture, Name, IsActive, IsCastable, Button, Icon, Cooldown, Start, Duration, Enable
	local PetSize = C.ActionBar.ButtonSize
	local Spacing = C.ActionBar.ButtonSpace

	if NumForms == 0 then
		Panels.StanceBar:SetAlpha(0)
	else
		Panels.StanceBar:SetAlpha(1)
		Panels.StanceBar.Backdrop:SetSize((PetSize * NumForms) + (Spacing * (NumForms + 1)), PetSize + (Spacing * 2))
		Panels.StanceBar.Backdrop:SetPoint("TOPLEFT", 0, 0)

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