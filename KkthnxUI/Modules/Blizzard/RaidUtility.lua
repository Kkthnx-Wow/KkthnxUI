local K, C, L = select(2, ...):unpack()
--if C.Blizzard.RaidTools ~= true then return end

-- Raid Utility(by Elv22)
local Movers = K.Movers
local Anchor = CreateFrame("Frame", "KkthnxUIRaidUtilityAnchor", UIParent)
Anchor:SetSize(160, 21)
Anchor:SetPoint(unpack(C.Position.RaidUtility))
Movers:RegisterFrame(Anchor)

local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", UIParent)
RaidUtilityPanel:SetPoint("TOPLEFT", Anchor, "TOPLEFT", 0, 0)
RaidUtilityPanel:SetTemplate("Transparent")
RaidUtilityPanel:SetSize(160, 148)

local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if ((IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

local function CreateButton(Name, Parent, Template, Width, Height, Point, RelativeTo, Point2, xOfs, yOfs, Text)
	local RaidUtilityButton = CreateFrame("Button", Name, Parent, Template)
	RaidUtilityButton:SetWidth(Width)
	RaidUtilityButton:SetHeight(Height + 2)
	RaidUtilityButton:SetFrameLevel(3)
	RaidUtilityButton:SetPoint(Point, RelativeTo, Point2, xOfs, yOfs)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata("HIGH")
	RaidUtilityButton:SkinButton()
	if Text then
		RaidUtilityButton.Text = RaidUtilityButton:CreateFontString(nil, "OVERLAY")
		RaidUtilityButton.Text:SetFont(C.Media.Font, 11)
		RaidUtilityButton.Text:SetShadowOffset(K.Mult, -K.Mult)
		RaidUtilityButton.Text:SetPoint("CENTER", 0, -1)
		RaidUtilityButton.Text:SetJustifyH("CENTER")
		RaidUtilityButton.Text:SetText(Text)
	end
end

CreateButton("RaidUtilityShowButton", UIParent, "UIPanelButtonTemplate, SecureHandlerClickTemplate", RaidUtilityPanel:GetWidth(), 18, "TOP", RaidUtilityPanel, "TOP", 0, 0, RAID_CONTROL)
RaidUtilityShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel)
RaidUtilityShowButton:SetAttribute("_onclick", [=[self:Hide(); self:GetFrameRef("RaidUtilityPanel"):Show();]=])
RaidUtilityShowButton:SetFrameStrata("HIGH")

CreateButton("RaidUtilityCloseButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureHandlerClickTemplate", RaidUtilityPanel:GetWidth() - 8, 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -4, CLOSE)
RaidUtilityCloseButton:SetFrameRef("RaidUtilityShowButton", RaidUtilityShowButton)
RaidUtilityCloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtilityShowButton"):Show();]=])
RaidUtilityCloseButton:SetScript("OnMouseUp", function(self) RaidUtilityPanel.toggled = false end)

CreateButton("RaidUtilityDisbandButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -8, L_RAID_UTIL_DISBAND)
RaidUtilityDisbandButton:SetScript("OnMouseUp", function(self) StaticPopup_Show("DISBAND_RAID") end)

CreateButton("RaidUtilityConvertButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityDisbandButton, "BOTTOM", 0, -8, UnitInRaid("player") and CONVERT_TO_PARTY or CONVERT_TO_RAID)
RaidUtilityConvertButton:SetScript("OnMouseUp", function(self)
	if UnitInRaid("player") then
		ConvertToParty()
		RaidUtilityConvertButton:SetText(CONVERT_TO_RAID)
	elseif UnitInParty("player") then
		ConvertToRaid()
		RaidUtilityConvertButton:SetText(CONVERT_TO_PARTY)
	end
end)

CreateButton("RaidUtilityRoleButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityConvertButton, "BOTTOM", 0, -8, ROLE_POLL)
RaidUtilityRoleButton:SetScript("OnMouseUp", function()
	if CheckRaidStatus() then
		InitiateRolePoll()
	end
end)

CreateButton("RaidUtilityMainTankButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureActionButtonTemplate", (RaidUtilityDisbandButton:GetWidth() / 2) - 4, 18, "TOPLEFT", RaidUtilityRoleButton, "BOTTOMLEFT", 0, -8, TANK)
RaidUtilityMainTankButton:SetAttribute("type", "maintank")
RaidUtilityMainTankButton:SetAttribute("unit", "target")
RaidUtilityMainTankButton:SetAttribute("action", "toggle")

CreateButton("RaidUtilityMainAssistButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureActionButtonTemplate", (RaidUtilityDisbandButton:GetWidth() / 2) - 4, 18, "TOPRIGHT", RaidUtilityRoleButton, "BOTTOMRIGHT", 0, -8, MAINASSIST)
RaidUtilityMainAssistButton:SetAttribute("type", "mainassist")
RaidUtilityMainAssistButton:SetAttribute("unit", "target")
RaidUtilityMainAssistButton:SetAttribute("action", "toggle")

CreateButton("RaidUtilityReadyCheckButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityRoleButton:GetWidth() * 0.75, 18, "TOPLEFT", RaidUtilityMainTankButton, "BOTTOMLEFT", 0, -8, READY_CHECK)
RaidUtilityReadyCheckButton:SetScript("OnMouseUp", function()
	if CheckRaidStatus() then
		DoReadyCheck()
	end
end)

CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetPoint("TOPRIGHT", RaidUtilityMainAssistButton, "BOTTOMRIGHT", 0, -8)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent("RaidUtilityPanel")
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetHeight(20)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetWidth(RaidUtilityRoleButton:GetWidth() * 0.18)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:StripTextures(true)
CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SkinButton()

local MarkTexture = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:CreateTexture(nil, "OVERLAY")
MarkTexture:SetTexture("Interface\\RaidFrame\\Raid-WorldPing")
MarkTexture:SetPoint("CENTER", 0, -1)

local function ToggleRaidUtil(self, event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil")
		return
	end

	if CheckRaidStatus() then
		if RaidUtilityPanel.toggled == true then
			RaidUtilityShowButton:Hide()
			RaidUtilityPanel:Show()
		else
			RaidUtilityShowButton:Show()
			RaidUtilityPanel:Hide()
		end
	else
		RaidUtilityShowButton:Hide()
		RaidUtilityPanel:Hide()
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil")
	end
end

local LeadershipCheck = CreateFrame("Frame")
LeadershipCheck:RegisterEvent("PLAYER_ENTERING_WORLD", "ToggleRaidUtil")
LeadershipCheck:RegisterEvent("GROUP_ROSTER_UPDATE", "ToggleRaidUtil")
LeadershipCheck:SetScript("OnEvent", ToggleRaidUtil)