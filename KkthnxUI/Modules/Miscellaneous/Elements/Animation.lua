local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local SOUND_LEGENDARY_LOOT = SOUNDKIT.UI_LEGENDARY_LOOT_TOAST
local PlaySound = PlaySound

local needAnimation

local function PlayLogoAnimation()
	if needAnimation then
		Module.logoFrame:Show()
		K:UnregisterEvent(Module, PlayLogoAnimation)
		needAnimation = false
	end
end

local function CreateLogo()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(512, 256)
	frame:SetPoint("CENTER", UIParent, "BOTTOM", -500, GetScreenHeight() * 0.618)
	frame:SetFrameStrata("HIGH")
	frame:SetAlpha(0)
	frame:Hide()

	local texture = frame:CreateTexture()
	texture:SetAllPoints()
	texture:SetTexture(C["Media"].Textures.LogoTexture)

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetPoint("BOTTOM", texture, 0, 6)
	text:SetFontObject(K.UIFont)
	text:SetFont(select(1, text:GetFont()), 32)
	text:SetText(K.Title .. " " .. K.GreyColor .. K.Version .. "|r")

	local delayTime, timer1, timer2, timer3 = 0, 0.5, 2, 0.2

	local animation = frame:CreateAnimationGroup()

	animation.move1 = animation:CreateAnimation("Translation")
	animation.move1:SetOffset(480, 0)
	animation.move1:SetDuration(timer1)
	animation.move1:SetStartDelay(delayTime)

	animation.fadeIn = animation:CreateAnimation("Alpha")
	animation.fadeIn:SetFromAlpha(0)
	animation.fadeIn:SetToAlpha(1)
	animation.fadeIn:SetDuration(timer1)
	animation.fadeIn:SetSmoothing("IN")
	animation.fadeIn:SetStartDelay(delayTime)

	delayTime = delayTime + timer1

	animation.move2 = animation:CreateAnimation("Translation")
	animation.move2:SetOffset(80, 0)
	animation.move2:SetDuration(timer2)
	animation.move2:SetStartDelay(delayTime)

	delayTime = delayTime + timer2

	animation.move3 = animation:CreateAnimation("Translation")
	animation.move3:SetOffset(-40, 0)
	animation.move3:SetDuration(timer3)
	animation.move3:SetStartDelay(delayTime)

	delayTime = delayTime + timer3

	animation.move4 = animation:CreateAnimation("Translation")
	animation.move4:SetOffset(480, 0)
	animation.move4:SetDuration(timer1)
	animation.move4:SetStartDelay(delayTime)

	animation.fadeOut = animation:CreateAnimation("Alpha")
	animation.fadeOut:SetFromAlpha(1)
	animation.fadeOut:SetToAlpha(0)
	animation.fadeOut:SetDuration(timer1)
	animation.fadeOut:SetSmoothing("OUT")
	animation.fadeOut:SetStartDelay(delayTime)

	frame:SetScript("OnShow", function()
		animation:Play()
	end)
	animation:SetScript("OnFinished", function()
		frame:Hide()
	end)
	animation.fadeIn:SetScript("OnFinished", function()
		PlaySound(SOUND_LEGENDARY_LOOT)
	end)

	Module.logoFrame = frame
end

local function CheckLogoStatus(isInitialLogin)
	if isInitialLogin and not (IsInInstance() and InCombatLockdown()) then
		needAnimation = true
		CreateLogo()
		K:RegisterEvent("PLAYER_STARTED_MOVING", PlayLogoAnimation)
	end
	K:UnregisterEvent(Module, CheckLogoStatus)
end

local function CreateLoginAnimation()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", CheckLogoStatus)

	SlashCmdList["KKUI_PLAYLOGO"] = function()
		if not Module.logoFrame then
			CreateLogo()
		end
		Module.logoFrame:Show()
		if K.isDeveloper then
			print("Play logo")
		end
	end
	SLASH_KKUI_PLAYLOGO1 = "/klogo"
end

Module:RegisterMisc("LoginAnimation", CreateLoginAnimation)
