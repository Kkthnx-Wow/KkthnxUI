local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Databars", "AceEvent-3.0")

local _G = _G
local min = math.min
local format = string.format

local C_ArtifactUI_GetEquippedArtifactInfo = _G.C_ArtifactUI.GetEquippedArtifactInfo
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local CanPrestige = _G.CanPrestige
local CreateFrame = _G.CreateFrame
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GameTooltip = _G.GameTooltip
local GetExpansionLevel = _G.GetExpansionLevel
local GetFactionInfo = _G.GetFactionInfo
local GetFriendshipReputation = _G.GetFriendshipReputation
local GetFriendshipReputationRanks = _G.GetFriendshipReputationRanks
local GetHonorRestState = _G.GetHonorRestState
local GetMaxPlayerHonorLevel = _G.GetMaxPlayerHonorLevel
local GetNumFactions = _G.GetNumFactions
local GetPetExperience = _G.GetPetExperience
local GetSpellInfo = _G.GetSpellInfo
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local GetXPExhaustion = _G.GetXPExhaustion
local HasArtifactEquipped = _G.HasArtifactEquipped
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local IsXPUserDisabled = _G.IsXPUserDisabled
local Minimap = _G.Minimap
local REPUTATION, STANDING = _G.REPUTATION, _G.STANDING
local ShowUIPanel = _G.ShowUIPanel
local SocketInventoryItem = _G.SocketInventoryItem
local ToggleCharacter = _G.ToggleCharacter
local UIParent = _G.UIParent
local UnitHonor = _G.UnitHonor
local UnitHonorLevel = _G.UnitHonorLevel
local UnitHonorMax = _G.UnitHonorMax
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local function GetExperience(unit)
    if(unit == "pet") then
        return GetPetExperience()
    else
        return UnitXP(unit), UnitXPMax(unit)
    end
end

local function Bar_OnShow(self)
    self:SetPoint("TOPLEFT", self.anchorFrame, "BOTTOMLEFT", 0, -5)
    self:SetPoint("TOPRIGHT", self.anchorFrame, "BOTTOMRIGHT", 0, -5)
end

local function Bar_OnHide(self)
    self:SetPoint("TOPLEFT", self.anchorFrame, "BOTTOMLEFT", 0, self.height)
    self:SetPoint("TOPRIGHT", self.anchorFrame, "BOTTOMRIGHT", 0, self.height)
end

function Module:CreateBar(name, anchorFrame, height)
    local bar = CreateFrame("StatusBar", name, K.PetBattleHider)
    bar:SetTemplate("Transparent")
    bar:SetFrameStrata("LOW")
    bar:SetHeight(height)
    bar.height = height
    bar:SetStatusBarTexture(C["Media"].Texture)
    bar.anchorFrame = anchorFrame
    bar:SetScript("OnShow", Bar_OnShow)
    bar:SetScript("OnHide", Bar_OnHide)
    Bar_OnShow(bar)

    bar.text = bar:CreateFontString(nil, "OVERLAY")
    bar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, "", "CENTER")
    bar.text:SetShadowOffset(1.25, -1.25)
    bar.text:SetSize(bar:GetWidth() - 10, height) -- This way we prevent run off text.
    bar.text:SetPoint("CENTER")

    bar.spark = bar:CreateTexture(nil, "ARTWORK", nil, 1)
    bar.spark:SetWidth(12)
    bar.spark:SetHeight(bar.height * 3)
    bar.spark:SetTexture(C["Media"].Spark)
    bar.spark:SetBlendMode("ADD")
    bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

    --Module:UpdateDimensions()

    return bar
end

function Module:CreateExpBar()
    self.ExpBar = self:CreateBar("KkthnxUIExpBar", Minimap, 12)
    self.ExpBar:SetStatusBarColor(0, 0.4, 1, .8)

    self.ExpBar.RestedExpBar = CreateFrame("StatusBar", nil, self.ExpBar)
    self.ExpBar.RestedExpBar:SetAllPoints()
    self.ExpBar.RestedExpBar:SetStatusBarTexture(C["Media"].Texture)
    self.ExpBar.RestedExpBar:SetStatusBarColor(1, 0, 1, 0.2)
    self.ExpBar.RestedExpBar:SetFrameLevel(self.ExpBar:GetFrameLevel())

    self.ExpBar:SetScript("OnEvent", self.UpdateExpBar)
    self.ExpBar:RegisterEvent("PLAYER_LEVEL_UP")
    self.ExpBar:RegisterEvent("PLAYER_XP_UPDATE")
    self.ExpBar:RegisterEvent("UPDATE_EXHAUSTION")
    self.ExpBar:RegisterEvent("UPDATE_EXPANSION_LEVEL")
    self.ExpBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    self.ExpBar:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, self)

        local cur, max = GetExperience("player")
        local rested = GetXPExhaustion()
        GameTooltip:AddLine("Experience")
        GameTooltip:AddLine(" ")

        GameTooltip:AddDoubleLine("XP:", format(" %d / %d (%d%%)", cur, max, cur/max * 100), 1, 1, 1)
        GameTooltip:AddDoubleLine("Remaining:", format(" %d (%d%% - %d ".."Bars"..")", max - cur, (max - cur) / max * 100, 20 * (max - cur) / max), 1, 1, 1)

        if rested then
            GameTooltip:AddDoubleLine("XP:", format("+%d (%d%%)", rested, rested / max * 100), 1, 1, 1)
        end

        GameTooltip:Show()
    end)

    self.ExpBar:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function Module:UpdateExpBar()
    local bar = self.ExpBar or KkthnxUIExpBar
    local hideXP = ((UnitLevel("player") == MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]) or IsXPUserDisabled())

    if hideXP then
        bar:Hide()
    elseif not hideXP then
        bar:Show()

        local cur, max = GetExperience("player")
        if max <= 0 then max = 1 end
        bar:SetMinMaxValues(0, max)
        bar:SetValue(cur - 1 >= 0 and cur - 1 or 0)
        bar:SetValue(cur)

        local rested = GetXPExhaustion()
        local text = ""

        if rested and rested > 0 then
            bar.RestedExpBar:SetMinMaxValues(0, max)
            bar.RestedExpBar:SetValue(min(cur + rested, max))

            text = format("%d%% R:%d%%", cur / max * 100, rested / max * 100)
        else
            bar.RestedExpBar:SetMinMaxValues(0, 1)
            bar.RestedExpBar:SetValue(0)

            text = format("%d%%", cur / max * 100)
        end

        bar.text:SetText(text)
    end
end

local PRESTIGE_TEXT = PVP_PRESTIGE_RANK_UP_TITLE..HEADER_COLON
function Module:CreateHonorBar()
    self.HonorBar = self:CreateBar("KkthnxUIHonorBar", self.ExpBar, 12)
    self.HonorBar:SetStatusBarColor(240/255, 114/255, 65/255)
    self.HonorBar:SetMinMaxValues(0, 325)
    self.HonorBar:SetScript("OnEvent", self.UpdateHonorBar)
    self.HonorBar:RegisterEvent("HONOR_XP_UPDATE")
    self.HonorBar:RegisterEvent("HONOR_PRESTIGE_UPDATE")
    self.HonorBar:RegisterEvent("PLAYER_FLAGS_CHANGED")
    self.HonorBar:RegisterEvent("PLAYER_ENTERING_WORLD")
    self.HonorBar:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, self)

        local current = UnitHonor("player")
        local max = UnitHonorMax("player")
        local level = UnitHonorLevel("player")
        local levelmax = GetMaxPlayerHonorLevel()
        local prestigeLevel = UnitPrestige("player")

        GameTooltip:AddLine(HONOR)

        GameTooltip:AddDoubleLine("Current Level:", level, 1, 1, 1)
        GameTooltip:AddDoubleLine(PRESTIGE_TEXT, prestigeLevel, 1, 1, 1)
        GameTooltip:AddLine(" ")

        if (CanPrestige()) then
            GameTooltip:AddLine(PVP_HONOR_PRESTIGE_AVAILABLE)
        elseif (level == levelmax) then
            GameTooltip:AddLine(MAX_HONOR_LEVEL)
        else
            GameTooltip:AddDoubleLine("Honor XP:", format(" %d / %d (%d%%)", current, max, current/max * 100), 1, 1, 1)
            GameTooltip:AddDoubleLine("Honor Remaining:", format(" %d (%d%% - %d ".."Bars"..")", max - current, (max - current) / max * 100, 20 * (max - current) / max), 1, 1, 1)
        end
        GameTooltip:Show()
    end)

    self.HonorBar:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.HonorBar:SetScript("OnMouseUp", function(self)
        ToggleTalentFrame(3) --3 is PvP
    end)
end

function Module:UpdateHonorBar(event, unit)
    if event == "HONOR_PRESTIGE_UPDATE" and unit ~= "player" then return end
    if event == "PLAYER_FLAGS_CHANGED" and unit ~= "player" then return end

    local bar = self.HonorBar or KkthnxUIHonorBar
    local showHonor = UnitLevel("player") >= MAX_PLAYER_LEVEL
    local isInInstance, instanceType = IsInInstance()

    if not showHonor then
        bar:Hide()
    else
        bar:Show()

        local current = UnitHonor("player")
        local max = UnitHonorMax("player")
        local level = UnitHonorLevel("player")
        local levelmax = GetMaxPlayerHonorLevel()

        --Guard against division by zero, which appears to be an issue when zoning in/out of dungeons
        if max == 0 then max = 1 end

        if (level == levelmax) then
            -- Force the bar to full for the max level
            bar:SetMinMaxValues(0, 1)
            bar:SetValue(1)
        else
            bar:SetMinMaxValues(0, max)
            bar:SetValue(current)
        end

        local text = ""

        if (CanPrestige()) then
            text = PVP_HONOR_PRESTIGE_AVAILABLE
        elseif (level == levelmax) then
            text = MAX_HONOR_LEVEL
        else
            text = format("%d%%", current / max * 100)
        end

        bar.text:SetText(text)
    end
end

function Module:CreateRepBar()
    self.RepBar = self:CreateBar("KkthnxUIRepBar", self.HonorBar, 12)
    self.RepBar:SetScript("OnEvent", self.UpdateRepBar)
    self.RepBar:RegisterEvent("UPDATE_FACTION")
    self.RepBar:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    self.RepBar:RegisterEvent("UPDATE_FACTION")
    self.RepBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    self.RepBar:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, self)

        local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

        if (C_Reputation_IsFactionParagon(factionID)) then
            local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
            min, max = 0, threshold
            value = currentValue % threshold
            if hasRewardPending then
                value = value + threshold
            end
        end

        local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
        if name then
            GameTooltip:AddLine(name)
            GameTooltip:AddLine(" ")

            GameTooltip:AddDoubleLine(STANDING..":", friendID and friendTextLevel or _G["FACTION_STANDING_LABEL"..reaction], 1, 1, 1)
            GameTooltip:AddDoubleLine(REPUTATION..":", format("%d / %d (%d%%)", value - min, max - min, (value - min) / ((max - min == 0) and max or (max - min)) * 100), 1, 1, 1)
        end
        GameTooltip:Show()
    end)

    self.RepBar:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.RepBar:SetScript("OnMouseUp", function(self)
        ToggleCharacter("ReputationFrame")
    end)
end

local backupColor = FACTION_BAR_COLORS[1]
local FactionStandingLabelUnknown = UNKNOWN
function Module:UpdateRepBar(event)
    local bar = self.RepBar or KkthnxUIRepBar

    local ID
    local isFriend, friendText, standingLabel
    local name, reaction, min, max, value, factionID = GetWatchedFactionInfo()

    if (C_Reputation_IsFactionParagon(factionID)) then
        local currentValue, threshold, _, hasRewardPending = C_Reputation_GetFactionParagonInfo(factionID)
        min, max = 0, threshold
        value = currentValue % threshold
        if hasRewardPending then
            value = value + threshold
        end
    end

    local numFactions = GetNumFactions()

    if not name then
        bar:Hide()
    elseif name then
        bar:Show()

        local color = FACTION_BAR_COLORS[reaction] or backupColor
        bar:SetStatusBarColor(color.r, color.g, color.b)

        bar:SetMinMaxValues(min, max)
        bar:SetValue(value)

        for i = 1, numFactions do
            local factionName, _, standingID, _, _, _, _, _, _, _, _, _, _, factionID = GetFactionInfo(i)
            local friendID, _, _, _, _, _, friendTextLevel = GetFriendshipReputation(factionID)
            if factionName == name then
                if friendID ~= nil then
                    isFriend = true
                    friendText = friendTextLevel
                else
                    ID = standingID
                end
            end
        end

        if ID then
            standingLabel = _G["FACTION_STANDING_LABEL"..ID]
        else
            standingLabel = FactionStandingLabelUnknown
        end

        -- Prevent a division by zero
        local maxMinDiff = max - min
        if (maxMinDiff == 0) then
            maxMinDiff = 1
        end

        local text = format("%s: %d%% [%s]", name, ((value - min) / (maxMinDiff) * 100), isFriend and friendText or standingLabel)

        bar.text:SetText(text)
    end
end

function Module:CreateArtiBar()
    self.ArtiBar = self:CreateBar("KkthnxUIArtiBar", self.RepBar, 12)
    self.ArtiBar:SetStatusBarColor(.901, .8, .601)
    self.ArtiBar:Hide()

    self.ArtiBar:SetScript("OnEvent", function() self:UpdateArtiBar() end)
    self.ArtiBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    self.ArtiBar:RegisterEvent("ARTIFACT_XP_UPDATE")
    self.ArtiBar:RegisterEvent("UNIT_INVENTORY_CHANGED")
    self.ArtiBar:RegisterEvent("BAG_UPDATE_DELAYED")

    self.ArtiBar:SetScript("OnEnter", function(self)
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, self)

        local _, _, artifactName, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
        local numPointsAvailableToSpend, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)

        GameTooltip:AddDoubleLine(ARTIFACT_POWER, artifactName, nil, nil, nil, 0.90, 0.80, 0.50)
        GameTooltip:AddLine(" ")

        local remaining = xpForNextPoint - xp

        GameTooltip:AddDoubleLine("XP:", format(" %s / %s (%d%%)", K.ShortValue(xp), K.ShortValue(xpForNextPoint), xp/xpForNextPoint * 100), 1, 1, 1)
        GameTooltip:AddDoubleLine("Remaining:", format(" %s (%d%% - %d %s)", K.ShortValue(xpForNextPoint - xp), remaining / xpForNextPoint * 100, 20 * remaining / xpForNextPoint, "Bars"), 1, 1, 1)
        if (numPointsAvailableToSpend > 0) then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(format(ARTIFACT_POWER_TOOLTIP_BODY, numPointsAvailableToSpend), nil, nil, nil, true)
        end

        GameTooltip:Show()
    end)

    self.ArtiBar:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.ArtiBar:SetScript("OnMouseUp", function(self)
        if not ArtifactFrame or not ArtifactFrame:IsShown() then
            ShowUIPanel(SocketInventoryItem(16))
        elseif ArtifactFrame and ArtifactFrame:IsShown() then
            HideUIPanel(ArtifactFrame)
        end
    end)
end

function Module:UpdateArtiBar(event, unit)
    if (event == "UNIT_INVENTORY_CHANGED" and unit ~= "player") then
        return
    end

    local bar = self.ArtiBar or KkthnxUIArtiBar
    local showArtifact = HasArtifactEquipped()

    if not showArtifact then
        bar:Hide()
    elseif showArtifact and not InCombatLockdown() then
        bar:Show()

        local _, _, _, _, totalXP, pointsSpent, _, _, _, _, _, _, artifactTier = C_ArtifactUI_GetEquippedArtifactInfo()
        local _, xp, xpForNextPoint = MainMenuBar_GetNumArtifactTraitsPurchasableFromXP(pointsSpent, totalXP, artifactTier)

        bar:SetMinMaxValues(0, xpForNextPoint)
        bar:SetValue(xp)

        local text = format("%d%%", xp / xpForNextPoint * 100)

        bar.text:SetText(text)
    end
end

-- function Module:UpdateDimensions(height)
-- self.bar:SetHeight(height)
-- self.bar.height = height

-- self.bar.text:SetFont(C["Media"].Font, C["Media"].FontSize - 1, C["DataBars"].Outline and "OUTLINE" or "", "CENTER")
-- self.bar.text:SetShadowOffset(C["DataBars"].Outline and 0 or 1.25, C["DataBars"].Outline and -0 or -1.25)
-- end

function Module:OnEnable()
    self:CreateExpBar()
    self:CreateHonorBar()
    self:CreateRepBar()
    self:CreateArtiBar()
end