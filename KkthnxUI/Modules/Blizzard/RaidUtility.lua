local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("RaidUtility", "AceEvent-3.0")

local _G = _G
local unpack, pairs = unpack, pairs
local tinsert = table.insert
local find = string.find

local CreateFrame = _G.CreateFrame
local IsInInstance = _G.IsInInstance
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local InCombatLockdown = _G.InCombatLockdown
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local InitiateRolePoll = _G.InitiateRolePoll
local DoReadyCheck = _G.DoReadyCheck
local ToggleFriendsFrame = _G.ToggleFriendsFrame

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: DisbandRaidButton, ROLE_POLL, RoleCheckButton, READY_CHECK, ReadyCheckButton
-- GLOBALS: RaidControlButton, CompactRaidFrameManager, RaidUtilityPanel, RAID_CONTROL
-- GLOBALS: CompactRaidFrameManagerDisplayFrameHiddenModeToggle, RaidUtility_ShowButton
-- GLOBALS: CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
-- GLOBALS: CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, CLOSE
-- GLOBALS: CompactRaidFrameManagerDisplayFrameLockedModeToggle, RaidUtility_CloseButton
-- GLOBALS: CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll

local PANEL_HEIGHT = 100

-- Check if We are Raid Leader or Raid Officer
local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if ((IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

-- Change border when mouse is inside the button
local function ButtonEnter(self)
	self:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
end

-- Change border back to normal when mouse leaves button
local function ButtonLeave(self)
	self:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
end

-- Function to create buttons in this module
function Module:CreateUtilButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text, texture)
	local b = CreateFrame("Button", name, parent, template)
	b:SetWidth(width)
	b:SetHeight(height)
	b:SetPoint(point, relativeto, point2, xOfs, yOfs)
	b:HookScript("OnEnter", ButtonEnter)
	b:HookScript("OnLeave", ButtonLeave)
	b:SetTemplate("Transparent")

	if text then
		local t = b:CreateFontString(nil,"OVERLAY", b)
		t:FontTemplate()
		t:SetPoint("CENTER", b, "CENTER", 0, -1)
		t:SetJustifyH("CENTER")
		t:SetText(text)
		b:SetFontString(t)
	elseif texture then
		local t = b:CreateTexture(nil,"OVERLAY",nil)
		t:SetTexture(texture)
		t:SetPoint("TOPLEFT", b, "TOPLEFT", K.Mult, -K.Mult)
		t:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -K.Mult, K.Mult)
	end
end

function Module:ToggleRaidUtil(event)
	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil")
		return
	end

	if CheckRaidStatus() then
		if RaidUtilityPanel.toggled == true then
			RaidUtility_ShowButton:Hide()
			RaidUtilityPanel:Show()
		else
			RaidUtility_ShowButton:Show()
			RaidUtilityPanel:Hide()
		end
	else
		RaidUtility_ShowButton:Hide()
		RaidUtilityPanel:Hide()
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", "ToggleRaidUtil")
	end
end

function Module:OnInitialize()
	if C["Raidframe"].RaidUtility == false then return end

	-- Create main frame
	local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", UIParent, "SecureHandlerClickTemplate")
	RaidUtilityPanel:SetTemplate("Transparent")
	RaidUtilityPanel:SetWidth(230)
	RaidUtilityPanel:SetHeight(PANEL_HEIGHT)
	RaidUtilityPanel:SetPoint("TOP", UIParent, "TOP", -400, 2)
	RaidUtilityPanel:SetFrameLevel(3)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata("HIGH")

	-- Show Button
	self:CreateUtilButton("RaidUtility_ShowButton", UIParent, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 136, 18, "TOP", UIParent, "TOP", -400, 4, RAID_CONTROL, nil)
	RaidUtility_ShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel)
	RaidUtility_ShowButton:SetAttribute("_onclick", ([=[
	local raidUtil = self:GetFrameRef("RaidUtilityPanel")
	local closeButton = raidUtil:GetFrameRef("RaidUtility_CloseButton")
	self:Hide()
	raidUtil:Show()

	local point = self:GetPoint()
	local raidUtilPoint, closeButtonPoint, yOffset
	if string.find(point, "BOTTOM") then
		raidUtilPoint = "BOTTOM"
		closeButtonPoint = "TOP"
		yOffset = 1
	else
		raidUtilPoint = "TOP"
		closeButtonPoint = "BOTTOM"
		yOffset = -1
	end

	yOffset = yOffset * (tonumber(%d))

	raidUtil:ClearAllPoints()
	closeButton:ClearAllPoints()
	raidUtil:SetPoint(raidUtilPoint, self, raidUtilPoint)
	closeButton:SetPoint(raidUtilPoint, raidUtil, closeButtonPoint, 0, yOffset)
	]=]):format(-4 + 4 * 3))

	RaidUtility_ShowButton:SetScript("OnMouseUp", function() RaidUtilityPanel.toggled = true end)
	RaidUtility_ShowButton:SetMovable(true)
	RaidUtility_ShowButton:SetClampedToScreen(true)
	RaidUtility_ShowButton:SetClampRectInsets(0, 0, -1, 1)
	RaidUtility_ShowButton:RegisterForDrag("RightButton")
	RaidUtility_ShowButton:SetFrameStrata("HIGH")
	RaidUtility_ShowButton:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)

	RaidUtility_ShowButton:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		local point = self:GetPoint()
		local xOffset = self:GetCenter()
		local screenWidth = UIParent:GetWidth() / 2
		xOffset = xOffset - screenWidth
		self:ClearAllPoints()
		if find(point, "BOTTOM") then
			self:SetPoint("BOTTOM", UIParent, "BOTTOM", xOffset, -1)
		else
			self:SetPoint("TOP", UIParent, "TOP", xOffset, 1)
		end
	end)

	-- Close Button
	self:CreateUtilButton("RaidUtility_CloseButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 136, 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -1, CLOSE, nil)
	RaidUtility_CloseButton:SetFrameRef("RaidUtility_ShowButton", RaidUtility_ShowButton)
	RaidUtility_CloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide() self:GetFrameRef("RaidUtility_ShowButton"):Show()]=])
	RaidUtility_CloseButton:SetScript("OnMouseUp", function() RaidUtilityPanel.toggled = false end)
	RaidUtilityPanel:SetFrameRef("RaidUtility_CloseButton", RaidUtility_CloseButton)

	-- Disband Raid button
	self:CreateUtilButton("DisbandRaidButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -5, "Disband Group", nil)
	DisbandRaidButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			StaticPopup_Show("DISBAND_RAID")
		end
	end)

	-- Role Check button
	self:CreateUtilButton("RoleCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", DisbandRaidButton, "BOTTOM", 0, -5, ROLE_POLL, nil)
	RoleCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			InitiateRolePoll()
		end
	end)

	--[[-- MainTank Button
	self:CreateUtilButton("MainTankButton", RaidUtilityPanel, "SecureActionButtonTemplate, UIMenuButtonStretchTemplate", (DisbandRaidButton:GetWidth() / 2) - 2, 18, "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, -5, MAINTANK, nil)
	MainTankButton:SetAttribute("type", "maintank")
	MainTankButton:SetAttribute("unit", "target")
	MainTankButton:SetAttribute("action", "toggle")

	-- MainAssist Button
	self:CreateUtilButton("MainAssistButton", RaidUtilityPanel, "SecureActionButtonTemplate, UIMenuButtonStretchTemplate", (DisbandRaidButton:GetWidth() / 2) - 2, 18, "TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, -5, MAINASSIST, nil)
	MainAssistButton:SetAttribute("type", "mainassist")
	MainAssistButton:SetAttribute("unit", "target")
	MainAssistButton:SetAttribute("action", "toggle")--]]

	-- Ready Check button
	self:CreateUtilButton("ReadyCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth() * 0.75, 18, "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, -5, READY_CHECK, nil)
	ReadyCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			DoReadyCheck()
		end
	end)

	-- Raid Control Panel
	self:CreateUtilButton("RaidControlButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth(), 18, "TOPLEFT", ReadyCheckButton, "BOTTOMLEFT", 0, -5, "Raid Menu", nil)
	RaidControlButton:SetScript("OnMouseUp", function()
		ToggleFriendsFrame(4)
	end)

	local buttons = {
		"DisbandRaidButton",
		"RoleCheckButton",
		"ReadyCheckButton",
		"RaidControlButton",
		"RaidUtility_ShowButton",
		"RaidUtility_CloseButton"
	}

	if CompactRaidFrameManager then
		-- Reposition/Resize and Reuse the World Marker Button
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetPoint("TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, -5)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent("RaidUtilityPanel")
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetHeight(18)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetWidth(RoleCheckButton:GetWidth() * 0.22)

		-- Put other stuff back
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:ClearAllPoints()
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLockedModeToggle, "TOPLEFT", 0, 1)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameHiddenModeToggle, "TOPRIGHT", 0, 1)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:ClearAllPoints()
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPLEFT", 0, 1)
		CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPRIGHT", 0, 1)

		tinsert(buttons, "CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton")
	else
		StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
	end

	-- Reskin Stuff
	for i, button in pairs(buttons) do
		local f = _G[button]
		f.BottomLeft:SetAlpha(0)
		f.BottomRight:SetAlpha(0)
		f.BottomMiddle:SetAlpha(0)
		f.TopMiddle:SetAlpha(0)
		f.TopLeft:SetAlpha(0)
		f.TopRight:SetAlpha(0)
		f.MiddleLeft:SetAlpha(0)
		f.MiddleRight:SetAlpha(0)
		f.MiddleMiddle:SetAlpha(0)

		f:SetHighlightTexture("")
		f:SetDisabledTexture("")
		f:HookScript("OnEnter", ButtonEnter)
		f:HookScript("OnLeave", ButtonLeave)
		f:SetTemplate("Black", true)
	end

	-- Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "ToggleRaidUtil")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ToggleRaidUtil")
end