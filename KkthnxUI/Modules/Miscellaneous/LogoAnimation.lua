
local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local soundID = _G.SOUNDKIT.UI_LEGENDARY_LOOT_TOAST
local PlaySound = _G.PlaySound
local IsInInstance = _G.IsInInstance
local InCombatLockdown = _G.InCombatLockdown
local SlashCmdList = _G.SlashCmdList
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local GetScreenHeight = _G.GetScreenHeight

local needAnimation
function Module:LogoPlayAnimation()
	if needAnimation then
		Module.logoFrame:Show()
		K:UnregisterEvent(self, Module.Logo_PlayAnimation)
		needAnimation = false
	end
end

function Module:LogoCheckStatus(isInitialLogin)
	if isInitialLogin and not (IsInInstance() and InCombatLockdown()) then
		needAnimation = true
		Module:LogoCreate()
		K:RegisterEvent("PLAYER_STARTED_MOVING", Module.LogoPlayAnimation)
	end
	K:UnregisterEvent(self, Module.Logo_CheckStatus)
end

function Module:LogoCreate()
	Module.logoFrame = CreateFrame("Frame", nil, UIParent)
	Module.logoFrame:SetSize(300, 150)
	Module.logoFrame:SetPoint("CENTER", UIParent, "BOTTOM", -500, GetScreenHeight() * 0.618)
	Module.logoFrame:SetFrameStrata("HIGH")
	Module.logoFrame:SetAlpha(0)
	Module.logoFrame:Hide()

	local logoTexture = Module.logoFrame:CreateTexture()
	logoTexture:SetAllPoints()
	logoTexture:SetTexture(C["Media"].Logo)

	local delayTime = 0
	local timer1 = 0.5
	local timer2 = 2
	local timer3 = 0.2

	local logoAnimation = Module.logoFrame:CreateAnimationGroup()

	logoAnimation.firstMove = logoAnimation:CreateAnimation("Translation")
	logoAnimation.firstMove:SetOffset(480, 0)
	logoAnimation.firstMove:SetDuration(timer1)
	logoAnimation.firstMove:SetStartDelay(delayTime)

	logoAnimation.fadeIn = logoAnimation:CreateAnimation("Alpha")
	logoAnimation.fadeIn:SetFromAlpha(0)
	logoAnimation.fadeIn:SetToAlpha(1)
	logoAnimation.fadeIn:SetDuration(timer1)
	logoAnimation.fadeIn:SetSmoothing("IN")
	logoAnimation.fadeIn:SetStartDelay(delayTime)

	delayTime = delayTime + timer1

	logoAnimation.secondMove = logoAnimation:CreateAnimation("Translation")
	logoAnimation.secondMove:SetOffset(80, 0)
	logoAnimation.secondMove:SetDuration(timer2)
	logoAnimation.secondMove:SetStartDelay(delayTime)

	delayTime = delayTime + timer2

	logoAnimation.thirdMove = logoAnimation:CreateAnimation("Translation")
	logoAnimation.thirdMove:SetOffset(-40, 0)
	logoAnimation.thirdMove:SetDuration(timer3)
	logoAnimation.thirdMove:SetStartDelay(delayTime)

	delayTime = delayTime + timer3

	logoAnimation.fourthMove = logoAnimation:CreateAnimation("Translation")
	logoAnimation.fourthMove:SetOffset(480, 0)
	logoAnimation.fourthMove:SetDuration(timer1)
	logoAnimation.fourthMove:SetStartDelay(delayTime)

	logoAnimation.fadeOut = logoAnimation:CreateAnimation("Alpha")
	logoAnimation.fadeOut:SetFromAlpha(1)
	logoAnimation.fadeOut:SetToAlpha(0)
	logoAnimation.fadeOut:SetDuration(timer1)
	logoAnimation.fadeOut:SetSmoothing("OUT")
	logoAnimation.fadeOut:SetStartDelay(delayTime)

	Module.logoFrame:SetScript("OnShow", function()
		logoAnimation:Play()
	end)

	logoAnimation:SetScript("OnFinished", function()
		Module.logoFrame:Hide()
	end)

	logoAnimation.fadeIn:SetScript("OnFinished", function()
		PlaySound(soundID, "master")
	end)
end

function Module:CreateLogoAnimation()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.LogoCheckStatus)

	SlashCmdList["KKUI_PLAYLOGO"] = function()
		if not Module.logoFrame then
			Module:Logo_Create()
		end

		Module.logoFrame:Show()

		if K.isDeveloper then
			print("Play logo")
		end
	end

	_G.SLASH_KKUI_PLAYLOGO1 = "/klogo"
end