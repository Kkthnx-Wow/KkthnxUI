local K, C, L = select(2, ...):unpack()

-- Wow API
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local SetCVar = SetCVar

-- Kill all stuff on default UI that we don't need
local DisableBlizzard = CreateFrame("Frame")
DisableBlizzard:RegisterEvent("PLAYER_LOGIN")
DisableBlizzard:SetScript("OnEvent", function(self, event)
	if addon == "Blizzard_AchievementUI" then
		if C.Tooltip.Enable then
			hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
		end
	end

	function PetFrame_Update() end

	function PlayerFrame_AnimateOut() end
	function PlayerFrame_AnimFinished() end
	function PlayerFrame_ToPlayerArt() end
	function PlayerFrame_ToVehicleArt() end


	if C.Minimap.Garrison == true then
		GarrisonLandingPageTutorialBox:Kill()
	end
	HelpOpenTicketButtonTutorial:Kill()
	HelpPlate:Kill()
	HelpPlateTooltip:Kill()
	TalentMicroButtonAlert:Kill()
	EJMicroButtonAlert:Kill()

	if C.Cooldown.Enable then
		SetCVar("countdownForCooldowns", 0)
		InterfaceOptionsActionBarsPanelCountdownCooldowns:Kill()
	end

	if C.Chat.Enable then
		SetCVar("chatStyle", "im")
	end

	if C.Minimap.Enable then
		InterfaceOptionsDisplayPanelRotateMinimap:Kill()
	end

	if C.ActionBar.Enable then
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
	end
end)