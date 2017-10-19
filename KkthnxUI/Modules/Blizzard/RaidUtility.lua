local K, C, L = unpack(select(2, ...))
local mod = K:NewModule("RaidUtility", "AceEvent-3.0")

local function CheckRaidStatus()
    local inInstance, instanceType = IsInInstance()
    if ((GetNumSubgroupMembers() > 0 and not UnitInRaid("player")) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and not (inInstance and (instanceType == "pvp" or instanceType == "arena")) then
        return true
    else
        return false
    end
end

function mod:CreateButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text, texture)
    local b = CreateFrame("Button", name, parent, template)
    b:SetWidth(width)
    b:SetHeight(height)
    b:SetPoint(point, relativeto, point2, xOfs, yOfs)
    b:EnableMouse(true)
    if text then
        local t = b:CreateFontString(nil,"OVERLAY", b)
        t:SetFont(C["Media"].Font, 12)
        t:SetPoint("TOPLEFT")
        t:SetPoint("BOTTOMRIGHT")
        t:SetJustifyH("CENTER")
        t:SetText(text)
        b:SetFontString(t)
    elseif texture then
        local t = b:CreateTexture(nil, "OVERLAY", nil)
        t:SetTexture(texture)
        t:SetPoint("TOPLEFT", b, "TOPLEFT", K.Mult, -K.Mult)
        t:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -K.Mult, K.Mult)
    end
    b:SetFrameStrata("HIGH")
end

local function DisbandRaidGroup()
    if InCombatLockdown() then return end -- Prevent user error in combat

    if UnitInRaid("player") then
        for i = 1, GetNumGroupMembers() do
            local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
            if online and name ~= R.myname then
                UninviteUnit(name)
            end
        end
    else
        for i = MAX_PARTY_MEMBERS, 1, -1 do
            if UnitExists("party"..i) then
                UninviteUnit(UnitName("party"..i))
            end
        end
    end
    LeaveParty()
end

function mod:OnInitialize()
    local panel_height = ((K.Scale(5)*5) + (K.Scale(20)*5))

    --Create main frame
    local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", UIParent)
    RaidUtilityPanel:SetFrameLevel(1)
    RaidUtilityPanel:SetHeight(panel_height)
    RaidUtilityPanel:SetWidth(230)
    RaidUtilityPanel:SetFrameStrata("BACKGROUND")
    RaidUtilityPanel:SetPoint("TOP", UIParent, "TOP", 0, 1)
    RaidUtilityPanel:SetFrameLevel(3)
    RaidUtilityPanel.toggled = false
    RaidUtilityPanel:SetTemplate("Transparent", true)

    --Show Button
    self:CreateButton("RaidUtilityShowButton", UIParent, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 80, 18, "TOP", UIParent, "TOP", 0, 2, L["团队工具"], nil)
    RaidUtilityShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel)
    RaidUtilityShowButton:SetAttribute("_onclick", [=[self:Hide(); self:GetFrameRef("RaidUtilityPanel"):Show();]=])
    RaidUtilityShowButton:SetScript("OnMouseUp", function(self) RaidUtilityPanel.toggled = true end)

    --Close Button
    self:CreateButton("RaidUtilityCloseButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate, SecureHandlerClickTemplate", 80, 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -1, CLOSE, nil)
    RaidUtilityCloseButton:SetFrameRef("RaidUtilityShowButton", RaidUtilityShowButton)
    RaidUtilityCloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtilityShowButton"):Show();]=])
    RaidUtilityCloseButton:SetScript("OnMouseUp", function(self) RaidUtilityPanel.toggled = false end)

    --Disband Raid button
    self:CreateButton("DisbandRaidButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, K.Scale(18), "TOP", RaidUtilityPanel, "TOP", 0, K.Scale(-5), "Disband group", nil)
    DisbandRaidButton:SetScript("OnMouseUp", function(self)
            if CheckRaidStatus() then
                StaticPopup_Show("DISBAND_RAID")
            end
        end)

    --Role Check button
    self:CreateButton("RoleCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RaidUtilityPanel:GetWidth() * 0.8, K.Scale(18), "TOP", DisbandRaidButton, "BOTTOM", 0, K.Scale(-5), ROLE_POLL, nil)
    RoleCheckButton:SetScript("OnMouseUp", function(self)
            if CheckRaidStatus() then
                InitiateRolePoll()
            end
        end)

    --MainTank Button
    self:CreateButton("MainTankButton", RaidUtilityPanel, "SecureActionButtonTemplate, UIMenuButtonStretchTemplate", (DisbandRaidButton:GetWidth() / 2) - K.Scale(2), K.Scale(18), "TOPLEFT", RoleCheckButton, "BOTTOMLEFT", 0, K.Scale(-5), MAINTANK, nil)
    MainTankButton:SetAttribute("type", "maintank")
    MainTankButton:SetAttribute("unit", "target")
    MainTankButton:SetAttribute("action", "toggle")

    --MainAssist Button
    self:CreateButton("MainAssistButton", RaidUtilityPanel, "SecureActionButtonTemplate, UIMenuButtonStretchTemplate", (DisbandRaidButton:GetWidth() / 2) - K.Scale(2), K.Scale(18), "TOPRIGHT", RoleCheckButton, "BOTTOMRIGHT", 0, K.Scale(-5), MAINASSIST, nil)
    MainAssistButton:SetAttribute("type", "mainassist")
    MainAssistButton:SetAttribute("unit", "target")
    MainAssistButton:SetAttribute("action", "toggle")

    --Ready Check button
    self:CreateButton("ReadyCheckButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth() * 0.75, K.Scale(18), "TOPLEFT", MainTankButton, "BOTTOMLEFT", 0, K.Scale(-5), READY_CHECK, nil)
    ReadyCheckButton:SetScript("OnMouseUp", function(self)
            if CheckRaidStatus() then
                DoReadyCheck()
            end
        end)

    --Reposition/Resize and Reuse the World Marker Button
    CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:ClearAllPoints()
    CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetPoint("TOPRIGHT", MainAssistButton, "BOTTOMRIGHT", 0, K.Scale(-5))
    CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetParent("RaidUtilityPanel")
    CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetHeight(K.Scale(18))
    CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton:SetWidth(RoleCheckButton:GetWidth() * 0.22)

    --Put other stuff back
    CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:ClearAllPoints()
    CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLockedModeToggle, "TOPLEFT", 0, 1)
    CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameHiddenModeToggle, "TOPRIGHT", 0, 1)

    CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:ClearAllPoints()
    CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMLEFT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPLEFT", 0, 1)
    CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateRolePoll:SetPoint("BOTTOMRIGHT", CompactRaidFrameManagerDisplayFrameLeaderOptionsInitiateReadyCheck, "TOPRIGHT", 0, 1)

    -- Raid Control Panel
    self:CreateButton("RaidControlButton", RaidUtilityPanel, "UIMenuButtonStretchTemplate", RoleCheckButton:GetWidth(), K.Scale(18), "TOPLEFT", ReadyCheckButton, "BOTTOMLEFT", 0, K.Scale(-5), RAID_CONTROL, nil)
    RaidControlButton:SetScript("OnMouseUp", function(self)
            ToggleFriendsFrame(4)
        end)

    -- Reskin Stuff
    do
        local buttons = {
            "CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton",
            "DisbandRaidButton",
            "MainTankButton",
            "MainAssistButton",
            "RoleCheckButton",
            "ReadyCheckButton",
            "RaidControlButton",
            "RaidUtilityShowButton",
            "RaidUtilityCloseButton"
        }
        CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton.SetNormalTexture = function() end
        CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton.SetPushedTexture = function() end
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
            -- f:SetTemplate("Transparent", true)
        end
    end

    local function ToggleRaidUtil(self, event)
        if InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
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
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
        end
    end

    --Automatically show/hide the frame if we have RaidLeader or RaidOfficer
    local LeadershipCheck = CreateFrame("Frame")
    LeadershipCheck:RegisterEvent("GROUP_ROSTER_UPDATE")
    LeadershipCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
    LeadershipCheck:SetScript("OnEvent", ToggleRaidUtil)
end