local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

local soundID = SOUNDKIT.UI_LEGENDARY_LOOT_TOAST
local PlaySound = PlaySound

local needAnimation

function Module:Logo_PlayAnimation()
	if needAnimation then
		Module.logoFrame:Show()
		K:UnregisterEvent(self, Module.Logo_PlayAnimation)
		needAnimation = false
	end
end

function Module:Logo_CheckStatus(isInitialLogin)
	if isInitialLogin and not (IsInInstance() and InCombatLockdown()) then
		needAnimation = true
		Module:Logo_Create()
		K:RegisterEvent("PLAYER_STARTED_MOVING", Module.Logo_PlayAnimation)
	end
	K:UnregisterEvent(self, Module.Logo_CheckStatus)
end

function Module:Logo_Create()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(512, 256)
	frame:SetPoint("CENTER", UIParent, "BOTTOM", -500, GetScreenHeight() * 0.618)
	frame:SetFrameStrata("HIGH")
	frame:SetAlpha(0)
	frame:Hide()

	local tex = frame:CreateTexture()
	tex:SetAllPoints()
	tex:SetTexture(C["Media"].Textures.LogoTexture)

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetPoint("BOTTOM", tex, 0, 6)
	text:SetFontObject(K.UIFont)
	text:SetFont(select(1, text:GetFont()), 32)
	text:SetText(K.Title .. " " .. K.GreyColor .. K.Version .. "|r")

	local delayTime = 0
	local timer1 = 0.5
	local timer2 = 2
	local timer3 = 0.2

	local anim = frame:CreateAnimationGroup()

	anim.move1 = anim:CreateAnimation("Translation")
	anim.move1:SetOffset(480, 0)
	anim.move1:SetDuration(timer1)
	anim.move1:SetStartDelay(delayTime)

	anim.fadeIn = anim:CreateAnimation("Alpha")
	anim.fadeIn:SetFromAlpha(0)
	anim.fadeIn:SetToAlpha(1)
	anim.fadeIn:SetDuration(timer1)
	anim.fadeIn:SetSmoothing("IN")
	anim.fadeIn:SetStartDelay(delayTime)

	delayTime = delayTime + timer1

	anim.move2 = anim:CreateAnimation("Translation")
	anim.move2:SetOffset(80, 0)
	anim.move2:SetDuration(timer2)
	anim.move2:SetStartDelay(delayTime)

	delayTime = delayTime + timer2

	anim.move3 = anim:CreateAnimation("Translation")
	anim.move3:SetOffset(-40, 0)
	anim.move3:SetDuration(timer3)
	anim.move3:SetStartDelay(delayTime)

	delayTime = delayTime + timer3

	anim.move4 = anim:CreateAnimation("Translation")
	anim.move4:SetOffset(480, 0)
	anim.move4:SetDuration(timer1)
	anim.move4:SetStartDelay(delayTime)

	anim.fadeOut = anim:CreateAnimation("Alpha")
	anim.fadeOut:SetFromAlpha(1)
	anim.fadeOut:SetToAlpha(0)
	anim.fadeOut:SetDuration(timer1)
	anim.fadeOut:SetSmoothing("OUT")
	anim.fadeOut:SetStartDelay(delayTime)

	frame:SetScript("OnShow", function()
		anim:Play()
	end)
	anim:SetScript("OnFinished", function()
		frame:Hide()
	end)
	anim.fadeIn:SetScript("OnFinished", function()
		PlaySound(soundID)
	end)

	Module.logoFrame = frame
end

function Module:CreateLoginAnimation()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Logo_CheckStatus)

	SlashCmdList["KKUI_PLAYLOGO"] = function()
		if not Module.logoFrame then
			Module:Logo_Create()
		end
		Module.logoFrame:Show()
		if K.isDeveloper then
			print("Play logo")
		end
	end
	SLASH_KKUI_PLAYLOGO1 = "/klogo"
end
Module:RegisterMisc("LoginAnimation", Module.CreateLoginAnimation)
