local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local SwPlay = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\SwPlay"
local SwReset = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\SwReset"
local SwPause = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\SwPause"

local function SkinStopwatch()
	StopwatchFrame:StripTextures()
	StopwatchFrame:CreateBackdrop()
	StopwatchFrame.Backdrop:SetPoint("TOPLEFT", 0, -17)
	StopwatchFrame.Backdrop:SetPoint("BOTTOMRIGHT", 0, 2)

	StopwatchTabFrame:StripTextures()
	StopwatchCloseButton:SkinCloseButton()
	StopwatchCloseButton:SetSize(32, 32)
	StopwatchCloseButton:SetPoint("TOPRIGHT", 12, 12)

	-- Play/Pause and Reset buttons
	StopwatchPlayPauseButton:CreateBackdrop()
	StopwatchPlayPauseButton:SetSize(12, 12)
	StopwatchPlayPauseButton:SetNormalTexture(SwPlay)
	StopwatchPlayPauseButton:SetHighlightTexture("")
	StopwatchPlayPauseButton.Backdrop:SetOutside(StopwatchPlayPauseButton, 2, 2)
	StopwatchPlayPauseButton:SetPoint("RIGHT", StopwatchResetButton, "LEFT", -6, 0)

	StopwatchResetButton:SkinButton()
	StopwatchResetButton:SetSize(16, 16)
	StopwatchResetButton:SetNormalTexture(SwReset)
	StopwatchResetButton:SetPoint("BOTTOMRIGHT", StopwatchFrame, "BOTTOMRIGHT", -4, 6)

	StopwatchTitle:SetPoint("TOP", 0, 3)
	StopwatchTitle:FontTemplate()

	local function SetPlayTexture()
		StopwatchPlayPauseButton:SetNormalTexture(SwPlay)
	end

	local function SetPauseTexture()
		StopwatchPlayPauseButton:SetNormalTexture(SwPause)
	end

	hooksecurefunc("Stopwatch_Play", SetPauseTexture)
	hooksecurefunc("Stopwatch_Pause", SetPlayTexture)
	hooksecurefunc("Stopwatch_Clear", SetPlayTexture)
end

Module.SkinFuncs["Blizzard_TimeManager"] = SkinStopwatch