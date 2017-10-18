local _G = _G
local K, C, L = _G.unpack(_G.select(2, ...))
local Module = K:NewModule("Exprepbar", "AceEvent-3.0")
local LibArtiData = LibStub("LibArtifactData-1.0")

local _G = _G
local pairs, ipairs, select, string, unpack = pairs, ipairs, select, string, unpack
local format = string.format
local min = math.min

local CreateFrame = CreateFrame
local SocketInventoryItem = SocketInventoryItem
local GetSpellInfo = GetSpellInfo
local HideUIPanel = HideUIPanel
local UnitXP = UnitXP
local UnitXPMax = UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local GetExpansionLevel = GetExpansionLevel
local UnitLevel = UnitLevel
local UnitHonor = UnitHonor
local UnitHonorMax = UnitHonorMax
local UnitHonorLevel = UnitHonorLevel
local GetMaxPlayerHonorLevel = GetMaxPlayerHonorLevel
local CanPrestige = CanPrestige
local GetHonorRestState = GetHonorRestState
local GetWatchedFactionInfo = GetWatchedFactionInfo
local GetFriendshipReputation = GetFriendshipReputation
local ToggleCharacter = ToggleCharacter
local GetFriendshipReputationRanks = GetFriendshipReputationRanks
local HasArtifactEquipped = HasArtifactEquipped
local BreakUpLargeNumbers = BreakUpLargeNumbers
local ShowUIPanel = ShowUIPanel
local InCombatLockdown = InCombatLockdown
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon

local function AddPerks()
    local _, traits = LibArtiData:GetArtifactTraits()
    for _, data in pairs(traits) do
        local r, g, b = 1, 1, 1

        if data.bonusRanks > 0 then
            r, g, b = 0.4, 1, 0
        end

        if data.currentRank > 0 and not data.isStart then
            GameTooltip:AddDoubleLine(data.name, data.currentRank.."/"..data.maxRank, 1, 1, 1, r, g, b)
        end
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
    local bar = CreateFrame("StatusBar", name, UIParent, "AnimatedStatusBarTemplate")
    bar:SetTemplate("Transparent")
    bar:SetFrameLevel(3)
    bar:SetHeight(height)
    bar.height = height
    bar:SetStatusBarTexture(C["Media"].Texture)
    bar.anchorFrame = anchorFrame
    bar:SetScript("OnShow", Bar_OnShow)
    bar:SetScript("OnHide", Bar_OnHide)
    Bar_OnShow(bar)

    return bar
end

function Module:CreateExpBar()
    self.ExpBar = self:CreateBar("KkthnxUIExpBar", Minimap, 10)
    self.ExpBar:SetStatusBarColor(0, 0.4, 1, .8)

    self.ExpBar.RestedExpBar = CreateFrame("StatusBar", nil, self.ExpBar)
    self.ExpBar.RestedExpBar:SetAllPoints()
    self.ExpBar.RestedExpBar:SetStatusBarTexture(C["Media"].Texture)
    self.ExpBar.RestedExpBar:SetStatusBarColor(1, 0, 1, 0.2)
    self.ExpBar.RestedExpBar:SetFrameLevel(self.ExpBar:GetFrameLevel() + 2)

    self.ExpBar:SetScript("OnEvent", self.UpdateExpBar)
    self.ExpBar:RegisterEvent("PLAYER_LEVEL_UP")
    self.ExpBar:RegisterEvent("PLAYER_XP_UPDATE")
    self.ExpBar:RegisterEvent("UPDATE_EXHAUSTION")
    self.ExpBar:RegisterEvent("UPDATE_EXPANSION_LEVEL")
    self.ExpBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    self.ExpBar:SetScript("OnEnter", function(self)
        local min, max = UnitXP("player"), UnitXPMax("player")
        local rest = GetXPExhaustion()

        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
        GameTooltip:AddDoubleLine("Experience", format("%s/%s (%d%%)", min, max, min / max * 100), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        GameTooltip:AddDoubleLine("Remaining", format("%d (%d%%)", max - min, (max - min) / max * 100), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        if rest then
            GameTooltip:AddDoubleLine("Rested", format("%d (%d%%)", rest, rest / max * 100), 0, .56, 1, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
        end
        GameTooltip:Show()
    end)

    self.ExpBar:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function Module:UpdateExpBar()
    local XP, maxXP = UnitXP("player"), UnitXPMax("player")
    local restXP = GetXPExhaustion()
    local maxLevel = MAX_PLAYER_LEVEL_TABLE[GetExpansionLevel()]

    if UnitLevel("player") == maxLevel then
        self:Hide()
        self.RestedExpBar:Hide()
    else
        self:SetAnimatedValues(XP, 0, maxXP, UnitLevel("player"))

        if restXP then
            self.RestedExpBar:Show()
            self.RestedExpBar:SetMinMaxValues(min(0, XP), maxXP)
            self.RestedExpBar:SetValue(XP + restXP)
        else
            self.RestedExpBar:Hide()
        end
        self:Show()
    end
end

local PRESTIGE_TEXT = PVP_PRESTIGE_RANK_UP_TITLE..HEADER_COLON
function Module:CreateHonorBar()
    self.HonorBar = self:CreateBar("KkthnxUIHonorBar", self.ExpBar, 10)

    self.HonorBar:SetScript("OnEvent", self.UpdateHonorBar)
    self.HonorBar:RegisterEvent("HONOR_XP_UPDATE")
    self.HonorBar:RegisterEvent("HONOR_PRESTIGE_UPDATE")
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
end

function Module:UpdateHonorBar()
    local level = UnitHonorLevel("player")
    local levelmax = GetMaxPlayerHonorLevel()
    local isInInstance, instanceType = IsInInstance()

    if UnitLevel("player") < MAX_PLAYER_LEVEL or level == levelmax or not (instanceType == "pvp") or (instanceType == "arena") then -- No need to show this otherwise.
        self:Hide()
    else
        self:Show()
        local current = UnitHonor("player")
        local max = UnitHonorMax("player")

        if (level == levelmax) then
            self:SetAnimatedValues(1, 0, 1, level)
        else
            self:SetAnimatedValues(current, 0, max, level)
        end

        local exhaustionStateID = GetHonorRestState()
        if (exhaustionStateID == 1) then
            self:SetStatusBarColor(240/255, 65/255, 73/255)
        else
            self:SetStatusBarColor(240/255, 114/255, 65/255)
        end
    end
end

function Module:CreateRepBar()
    self.RepBar = self:CreateBar("KkthnxUIRepBar", self.HonorBar, 10)
    self.RepBar:SetScript("OnEvent", self.UpdateRepBar)
    self.RepBar:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
    self.RepBar:RegisterEvent("UPDATE_FACTION")
    self.RepBar:RegisterEvent("PLAYER_ENTERING_WORLD")

    self.RepBar:SetScript("OnEnter", function(self)
        local name, rank, start, cap, value, factionID = GetWatchedFactionInfo()
        if (C_Reputation.IsFactionParagon(factionID)) then
            local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
            start, cap, value = 0, threshold, currentValue
        end
        local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, self)
        GameTooltip:AddLine(name)
        if friendID then
            rank = 8
            GameTooltip:AddDoubleLine(STANDING, friendTextLevel, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, K["Colors"].reaction[rank][1], K["Colors"].reaction[rank][2], K["Colors"].reaction[rank][3])
        else
            GameTooltip:AddDoubleLine(STANDING, _G["FACTION_STANDING_LABEL"..rank], NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, K["Colors"].reaction[rank][1], K["Colors"].reaction[rank][2], K["Colors"].reaction[rank][3])
        end
        GameTooltip:AddDoubleLine(REPUTATION, string.format("%s/%s (%d%%)", value-start, cap-start, (value-start)/(cap-start)*100), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
        GameTooltip:AddDoubleLine("Remaining", string.format("%s", cap-value), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
        GameTooltip:Show()
    end)

    self.RepBar:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)

    self.RepBar:SetScript("OnMouseUp", function(self)
        GameTooltip:Hide()
        ToggleCharacter("ReputationFrame")
    end)
end

function Module:UpdateRepBar()
    local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold
    if GetWatchedFactionInfo() then
        local name, rank, min, max, value, factionID = GetWatchedFactionInfo()
        if (C_Reputation.IsFactionParagon(factionID)) then
            local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
            min, max, value = 0, threshold, currentValue
        end
        local level
        if (ReputationWatchBar.friendshipID) then
            friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel, friendThreshold, nextFriendThreshold = GetFriendshipReputation(factionID)
            level = GetFriendshipReputationRanks(factionID)
            if (nextFriendThreshold) then
                min, max, value = friendThreshold, nextFriendThreshold, friendRep
            else
                min, max, value = 0, 1, 1
            end
        else
            level = rank
        end
        max = max - min
        value = value - min
        min = 0
        self:SetAnimatedValues(value, min, max, level)
        if friendID then
            rank = 8
        end
        self:SetStatusBarColor(unpack(K["Colors"].reaction[rank]))
        self:Show()
    else
        self:Hide()
    end
end

function Module:CreateArtiBar()
    self.ArtiBar = self:CreateBar("KkthnxUIArtiBar", self.RepBar, 10)
    self.ArtiBar:SetStatusBarColor(.901, .8, .601)
    self.ArtiBar:Hide()

    LibArtiData.RegisterCallback(self, "ARTIFACT_POWER_CHANGED", "UpdateArtiBar")
    LibArtiData.RegisterCallback(self, "ARTIFACT_ADDED", "UpdateArtiBar")
    LibArtiData.RegisterCallback(self, "ARTIFACT_ACTIVE_CHANGED", "UpdateArtiBar")
    self.ArtiBar:SetScript("OnEvent", function() self:UpdateArtiBar() end)
    self.ArtiBar:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

    self.ArtiBar:SetScript("OnEnter", function(self)
        if HasArtifactEquipped() then
            local _, data = LibArtiData:GetArtifactInfo()

            GameTooltip:ClearLines()
            GameTooltip_SetDefaultAnchor(GameTooltip, self)
            GameTooltip:AddLine(string.format("%s (%s %d)", data.name, LEVEL, data.numRanksPurchased))
            GameTooltip:AddLine(ARTIFACT_POWER_TOOLTIP_TITLE:format(K.ShortValue(data.unspentPower), K.ShortValue(data.power), K.ShortValue(data.maxPower)), 1, 1, 1)
            if data.numRanksPurchasable > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(ARTIFACT_POWER_TOOLTIP_BODY:format(data.numRanksPurchasable), 0, 1, 0, true)
            end

            AddPerks()
            GameTooltip:Show()
        end
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

function Module:UpdateArtiBar()
    if HasArtifactEquipped() then
        local _, data = LibArtiData:GetArtifactInfo()
        if not data.numRanksPurchased then return end
        self.ArtiBar:SetAnimatedValues(data.power, 0, data.maxPower, data.numRanksPurchasable + data.numRanksPurchased)
        self.ArtiBar:Show()
    else
        self.ArtiBar:Hide()
    end
end

function Module:OnInitialize()
    self:CreateExpBar()
    self:CreateHonorBar()
    self:CreateRepBar()
    self:CreateArtiBar()
end