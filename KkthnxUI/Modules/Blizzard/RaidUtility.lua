local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("RaidUtility", "AceEvent-3.0")

local _G = _G
local unpack, ipairs, pairs, next = unpack, ipairs, pairs, next
local tinsert, twipe, tsort = table.insert, table.wipe, table.sort
local find = string.find

local CreateFrame = CreateFrame
local IsInInstance = IsInInstance
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local InCombatLockdown = InCombatLockdown
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local InitiateRolePoll = InitiateRolePoll
local DoReadyCheck = DoReadyCheck
local ToggleFriendsFrame = ToggleFriendsFrame
local GetNumGroupMembers = GetNumGroupMembers
local GetTexCoordsForRole = GetTexCoordsForRole
local GetRaidRosterInfo = GetRaidRosterInfo
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local GameTooltip = GameTooltip
local GameTooltip_Hide = GameTooltip_Hide

K["RaidUtility"] = Module

local PANEL_HEIGHT = 100
local CLASS_COLOR = K.Class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class])

--Check if We are Raid Leader or Raid Officer
local function CheckRaidStatus()
	local inInstance, instanceType = IsInInstance()
	if ((IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
		return true
	else
		return false
	end
end

local function ButtonEnter(self)
	if self.Backdrop then self = self.Backdrop end
	if not C["General"].ColorTextures then -- Fix a rare nil error
		self:SetBackdropBorderColor(CLASS_COLOR.r, CLASS_COLOR.g, CLASS_COLOR.b, 1)
	end
	self:SetBackdropColor(CLASS_COLOR.r * .15, CLASS_COLOR.g * .15, CLASS_COLOR.b * .15, C["Media"].BackdropColor[4])
end

local function ButtonLeave(self)
	if self.Backdrop then self = self.Backdrop end
	if not C["General"].ColorTextures then -- Fix a rare nil error
		self:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 1)
	end
	self:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
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
		local t = b:CreateFontString(nil, "OVERLAY", b)
		t:FontTemplate()
		t:SetPoint("CENTER", b, "CENTER", 0, -1)
		t:SetJustifyH("CENTER")
		t:SetText(text)
		b:SetFontString(t)
	elseif texture then
		local t = b:CreateTexture(nil, "OVERLAY", nil)
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

-- Credits oRA3 for the RoleIcons
local function sortColoredNames(a, b)
	return a:sub(11) < b:sub(11)
end

local roleIconRoster = {}
local function onEnter(self)
	twipe(roleIconRoster)

	for i = 1, NUM_RAID_GROUPS do
		roleIconRoster[i] = {}
	end

	local role = self.role
	local point = K.GetScreenQuadrant(RaidUtility_ShowButton)
	local bottom = point and find(point, "BOTTOM")
	local left = point and find(point, "LEFT")

	local anchor1 = (bottom and left and "BOTTOMLEFT") or (bottom and "BOTTOMRIGHT") or (left and "TOPLEFT") or "TOPRIGHT"
	local anchor2 = (bottom and left and "BOTTOMRIGHT") or (bottom and "BOTTOMLEFT") or (left and "TOPRIGHT") or "TOPLEFT"
	local anchorX = left and 2 or -2

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(anchor1, self, anchor2, anchorX, 0)
	GameTooltip:SetText(_G["INLINE_" .. role .. "_ICON"] .. _G[role])

	local name, group, class, groupRole, color, coloredName, _
	for i = 1, GetNumGroupMembers() do
		name, _, group, _, _, class, _, _, _, _, _, groupRole = GetRaidRosterInfo(i)
		if name and groupRole == role then
			color = class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class])
			coloredName = ("|cff%02x%02x%02x%s"):format(color.r * 255, color.g * 255, color.b * 255, name:gsub("%-.+", "*"))
			tinsert(roleIconRoster[group], coloredName)
		end
	end

	for group, list in ipairs(roleIconRoster) do
		tsort(list, sortColoredNames)
		for _, name in ipairs(list) do
			GameTooltip:AddLine(("[%d] %s"):format(group, name), 1, 1, 1)
		end
		roleIconRoster[group] = nil
	end

	GameTooltip:Show()
end

local function RaidUtility_PositionRoleIcons()
	local point = K.GetScreenQuadrant(RaidUtility_ShowButton)
	local left = point and find(point, "LEFT")
	RaidUtilityRoleIcons:ClearAllPoints()
	if left then
		RaidUtilityRoleIcons:SetPoint("LEFT", RaidUtilityPanel, "RIGHT", 6, 0)
	else
		RaidUtilityRoleIcons:SetPoint("RIGHT", RaidUtilityPanel, "LEFT", -6, 0)
	end
end

local count = {}
local function UpdateIcons(self)
	local raid = IsInRaid()
	local party --= IsInGroup() --We could have this in party :thinking:

	if not (raid or party) then
		self:Hide()
		return
	else
		self:Show()
		RaidUtility_PositionRoleIcons()
	end

	twipe(count)

	local role
	for i = 1, GetNumGroupMembers() do
		role = UnitGroupRolesAssigned((raid and "raid" or "party")..i)
		if role and role ~= "NONE" then
			count[role] = (count[role] or 0) + 1
		end
	end

	if (not raid) and party then -- only need this party (we believe)
		local myRole = K.GetPlayerRole()
		if myRole then
			count[myRole] = (count[myRole] or 0) + 1
		end
	end

	for role, icon in next, RaidUtilityRoleIcons.icons do
		icon.count:SetText(count[role] or 0)
	end
end

function Module:OnInitialize()
	if C["Raidframe"].RaidUtility == false then return end

	--Create main frame
	local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", UIParent, "SecureHandlerClickTemplate")
	RaidUtilityPanel:SetTemplate("Transparent")
	RaidUtilityPanel:SetWidth(230)
	RaidUtilityPanel:SetHeight(PANEL_HEIGHT)
	RaidUtilityPanel:SetPoint("TOP", UIParent, "TOP", -400, 1)
	RaidUtilityPanel:SetFrameLevel(3)
	RaidUtilityPanel.toggled = false
	RaidUtilityPanel:SetFrameStrata("HIGH")

	--Show Button
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
	]=]):format(-6 + 4 * 3))
	RaidUtility_ShowButton:SetScript("OnMouseUp", function()
		RaidUtilityPanel.toggled = true
		RaidUtility_PositionRoleIcons()
	end)
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
	RaidUtility_CloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtility_ShowButton"):Show();]=])
	RaidUtility_CloseButton:SetScript("OnMouseUp", function() RaidUtilityPanel.toggled = false end)
	RaidUtilityPanel:SetFrameRef("RaidUtility_CloseButton", RaidUtility_CloseButton)

	-- Role Icons
	local RoleIcons = CreateFrame("Frame", "RaidUtilityRoleIcons", RaidUtilityPanel)
	RoleIcons:SetPoint("LEFT", RaidUtilityPanel, "RIGHT", 6, 0)
	RoleIcons:SetSize(36, PANEL_HEIGHT)
	RoleIcons:SetTemplate("Transparent")
	RoleIcons:RegisterEvent("PLAYER_ENTERING_WORLD")
	RoleIcons:RegisterEvent("GROUP_ROSTER_UPDATE")
	RoleIcons:SetScript("OnEvent", UpdateIcons)

	RoleIcons.icons = {}

	local roles = {"TANK", "HEALER", "DAMAGER"}
	for i, role in ipairs(roles) do
		local frame = CreateFrame("Frame", "$parent_"..role, RoleIcons)
		if i == 1 then
			frame:SetPoint("BOTTOM", 0, 4)
		else
			frame:SetPoint("BOTTOM", _G["RaidUtilityRoleIcons_"..roles[i-1]], "TOP", 0, 4)
		end

		frame:SetSize(28, 28)

		local texture = frame:CreateTexture(nil, "OVERLAY")
		texture:SetTexture(337499)

		local texA, texB, texC, texD = GetTexCoordsForRole(role)
		texture:SetTexCoord(texA, texB, texC, texD)

		local texturePlace = 2
		texture:SetPoint("TOPLEFT", frame, "TOPLEFT", -texturePlace, texturePlace)
		texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", texturePlace, -texturePlace)
		frame.texture = texture

		local count = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		count:SetPoint("BOTTOMRIGHT", -2, 2)
		count:SetText(0)
		frame.count = count

		frame.role = role
		frame:SetScript("OnEnter", onEnter)
		frame:SetScript("OnLeave", GameTooltip_Hide)

		RoleIcons.icons[role] = frame
	end

	-- Disband Raid button
	self:CreateUtilButton("DisbandRaidButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -5, L["Blizzard"].Disband_Group, nil)
	DisbandRaidButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			K.StaticPopup_Show("DISBAND_RAID")
		end
	end)

	-- Role Check button
	self:CreateUtilButton("RoleCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", DisbandRaidButton, "BOTTOM", 0, -6, ROLE_POLL, nil)
	RoleCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			InitiateRolePoll()
		end
	end)

	-- Ready Check button
	self:CreateUtilButton("ReadyCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth() * 0.75, 18, "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, -6, READY_CHECK, nil)
	ReadyCheckButton:SetScript("OnMouseUp", function()
		if CheckRaidStatus() then
			DoReadyCheck()
		end
	end)

	-- Raid Control Panel
	self:CreateUtilButton("RaidControlButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth(), 18, "TOPLEFT", ReadyCheckButton, "BOTTOMLEFT", 0, -6, L["Blizzard"].Raid_Menu, nil)
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
		CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetPoint("TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, -6)
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
		K.StaticPopup_Show("WARNING_BLIZZARD_ADDONS")
	end

	--Reskin Stuff
	for _, button in pairs(buttons) do
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
		f:SetTemplate("Transparent", true)
	end

	-- Automatically show/hide the frame if we have RaidLeader or RaidOfficer
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "ToggleRaidUtil")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "ToggleRaidUtil")
end