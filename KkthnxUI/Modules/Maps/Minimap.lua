local K, C, L = unpack(select(2, ...))
if C.Minimap.Enable ~= true then return end

-- Lua API
local _G = _G
local strsub = strsub

-- Wow API
local GetMinimapShape = GetMinimapShape
local GetMinimapZoneText = GetMinimapZoneText
local GetPlayerMapPosition = GetPlayerMapPosition
local GetZonePVPInfo = GetZonePVPInfo
local IsInInstance = IsInInstance

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GarrisonLandingPageMinimapButton, Minimap, TimeManagerClockButton, GameTimeFrame
-- GLOBALS: HelpOpenWebTicketButton, FeedbackUIButton
-- GLOBALS: Minimap_ZoomIn, Minimap_ZoomOut, Minimap_ZoneColors, HelpOpenTicketButton

local Movers = K.Movers

local function GetLocTextColor()
    local pvpType = GetZonePVPInfo()
    if pvpType == "arena" then
        return 0.84, 0.03, 0.03
    elseif pvpType == "friendly" then
        return 0.05, 0.85, 0.03
    elseif pvpType == "contested" then
        return 0.9, 0.85, 0.05
    elseif pvpType == "hostile" then
        return 0.84, 0.03, 0.03
    elseif pvpType == "sanctuary" then
        return 0.035, 0.58, 0.84
    elseif pvpType == "combat" then
        return 0.84, 0.03, 0.03
    else
        return 0.9, 0.85, 0.05
    end
end

-- </ Minimap border > --
local MinimapAnchor = CreateFrame("Frame", "MinimapAnchor", UIParent)
MinimapAnchor:CreatePanel("Invisible", C.Minimap.Size, C.Minimap.Size, unpack(C.Position.Minimap))
Movers:RegisterFrame(MinimapAnchor)

local North = _G["MinimapNorthTag"]
local HiddenFrames = {
    "MinimapBorder",
    "MinimapBorderTop",
    "MinimapCluster",
    "MinimapNorthTag",
    "MiniMapTracking",
    "MiniMapVoiceChatFrame",
    "MiniMapWorldMapButton",
    "MinimapZoneTextButton",
    "MinimapZoomIn",
    "MinimapZoomOut",
    "VoiceChatTalkers",
}

for i, FrameName in pairs(HiddenFrames) do
    local Frame = _G[FrameName]
    Frame:Hide()

    if Frame.UnregisterAllEvents then
        Frame:UnregisterAllEvents()
    end

    North:SetTexture(nil)
end

local function PositionTicketButtons()
    HelpOpenTicketButton:ClearAllPoints()
    HelpOpenTicketButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0 or 0, 0 or 0)
    HelpOpenWebTicketButton:ClearAllPoints()
    HelpOpenWebTicketButton:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 0 or 0, 0 or 0)
end
hooksecurefunc("HelpOpenTicketButton_Move", PositionTicketButtons)

-- </ Hide Game Time > --
MinimapAnchor:RegisterEvent("PLAYER_LOGIN")
MinimapAnchor:RegisterEvent("ADDON_LOADED")
MinimapAnchor:SetScript("OnEvent", function(self, event, addon)
    if addon == "Blizzard_TimeManager" then
        TimeManagerClockButton:Kill()
    elseif addon == "Blizzard_FeedbackUI" then
        FeedbackUIButton:Kill()
    end
end)

if TimeManagerClockButton then
    TimeManagerClockButton:Kill()
end

if FeedbackUIButton then
    FeedbackUIButton:Kill()
end

-- </ Hide blob ring > --
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

-- </ Parent minimap into our frame > --
Minimap:SetParent(MinimapAnchor)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 4, -4)
Minimap:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", -4, 4)
Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
-- </ Backdrop > --
MinimapBackdrop:ClearAllPoints()
MinimapBackdrop:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 2, -2)
MinimapBackdrop:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", -2, 2)
MinimapBackdrop:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())

-- </ Mail > --
if MiniMapMailFrame then
    MiniMapMailFrame:ClearAllPoints()
    MiniMapMailFrame:SetPoint("BOTTOM", 0, 4)
    MiniMapMailFrame:SetFrameLevel(Minimap:GetFrameLevel() + 2)
    MiniMapMailBorder:Hide()
    MiniMapMailFrame:SetScale(1.2)
    MiniMapMailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")
end

-- </ QueueStatusMinimapButton > --
if QueueStatusMinimapButton then
    QueueStatusMinimapButton:ClearAllPoints()
    QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", Minimap, "BOTTOMRIGHT", 3, -4)
    QueueStatusMinimapButton:SetScale(1)
    QueueStatusFrame:SetScale(1)
end
QueueStatusMinimapButtonBorder:Hide()
QueueStatusFrame:SetClampedToScreen(true)

-- </ Garrison icon > --
if GarrisonLandingPageMinimapButton and K.Level > 89 then
    if C.Minimap.Garrison then
        GarrisonLandingPageMinimapButton:ClearAllPoints()
        GarrisonLandingPageMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, 1)
        GarrisonLandingPageMinimapButton:SetAlpha(1)
        GarrisonLandingPageMinimapButton:SetScale(0.6)

        GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Stop()
        GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim.Play = K.Noop
        GarrisonLandingPageMinimapButton.MinimapAlertAnim:Stop()
        GarrisonLandingPageMinimapButton.MinimapAlertAnim.Play = K.Noop

        if GarrisonLandingPageTutorialBox then
            GarrisonLandingPageTutorialBox:Kill()
        end

        if C.Minimap.FadeButtons then
            GarrisonLandingPageMinimapButton:SetAlpha(0)
            GarrisonLandingPageMinimapButton:HookScript("OnEnter", function() GarrisonLandingPageMinimapButton:FadeIn() end)
            GarrisonLandingPageMinimapButton:HookScript("OnLeave", function() GarrisonLandingPageMinimapButton:FadeOut() end)
        end
    end
end

if C.Minimap.Garrison == false then
    GarrisonLandingPageMinimapButton:Kill()
    GarrisonLandingPageMinimapButton.IsShown = function() return true end
end

-- </ Dungeon info > --
if MiniMapInstanceDifficulty and GuildInstanceDifficulty then
    MiniMapInstanceDifficulty:ClearAllPoints()
    MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, -1)
    MiniMapInstanceDifficulty:SetScale(1)
    GuildInstanceDifficulty:ClearAllPoints()
    GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, -1)
    GuildInstanceDifficulty:SetScale(1)
end
MiniMapInstanceDifficulty:SetParent(Minimap)
GuildInstanceDifficulty:SetParent(Minimap)

if MiniMapChallengeMode then
    MiniMapChallengeMode:ClearAllPoints()
    MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 8, -8)
    MiniMapChallengeMode:SetScale(1)
end
MiniMapChallengeMode:SetParent(Minimap)

if HelpOpenTicketButton and HelpOpenWebTicketButton then
    HelpOpenTicketButton:SetScale(1)
    HelpOpenWebTicketButton:SetScale(1)

    PositionTicketButtons()
end

if GameTimeFrame then
    if C.Minimap.Calendar then
        GameTimeFrame:SetParent(Minimap)
        GameTimeFrame:SetScale(0.6)
        GameTimeFrame:ClearAllPoints()
        GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -1, -2)
        GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
        GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
        GameTimeFrame:SetNormalTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Calendar.blp")
        GameTimeFrame:SetPushedTexture(nil)
        GameTimeFrame:SetHighlightTexture (nil)

        local GTFont = GameTimeFrame:GetFontString()
        GTFont:ClearAllPoints()
        GTFont:SetPoint("CENTER", 0, -5)
        GTFont:SetFont(C.Media.Font, 20)
        GTFont:SetTextColor(0.2, 0.2, 0.1, 0.9)
        if C.Minimap.FadeButtons then
            GameTimeFrame:SetAlpha(0)
            GameTimeFrame:HookScript("OnEnter", function() GameTimeFrame:FadeIn() end)
            GameTimeFrame:HookScript("OnLeave", function() GameTimeFrame:FadeOut() end)
        end
    else
        GameTimeFrame:Hide()
    end
end

-- </ Enable mouse scrolling > --
Minimap:EnableMouseWheel()
local function Zoom(self, direction)
    if(direction > 0) then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end
Minimap:SetScript("OnMouseWheel", Zoom)

-- </ For others mods with a minimap button, set minimap buttons position in square mode > --
function GetMinimapShape()
    return "SQUARE"
end

-- </ Set border texture > --
MinimapBackdrop:SetBackdrop(K.Backdrop)
MinimapBackdrop:SetBackdropColor(0.05, 0.05, 0.05, 0.0)
MinimapBackdrop:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
if C.Blizzard.ColorTextures == true then
    MinimapBackdrop:SetBackdropBorderColor(C.Blizzard.TexturesColor[1], C.Blizzard.TexturesColor[2], C.Blizzard.TexturesColor[3])
end
MinimapBackdrop:SetOutside(Minimap, 4, 4)

-- </ Set square map view > --
Minimap:SetMaskTexture("Interface\\BUTTONS\\WHITE8X8")
Minimap:SetArchBlobRingAlpha(0)
Minimap:SetQuestBlobRingAlpha(0)
MinimapBorder:Hide()

-- </ Set location font, and position > --
local MinimapZone = CreateFrame("Frame", "KkthnxUIMinimapZone", Minimap)
MinimapZone:SetSize(Minimap:GetWidth() + 4, 19)
MinimapZone:SetPoint("TOP", Minimap, 0, 2)
MinimapZone:SetFrameStrata(Minimap:GetFrameStrata())
MinimapZone:SetAlpha(0)

local MinimapZoneText = MinimapZone:CreateFontString("KkthnxUIMinimapZoneText", "Overlay")
MinimapZoneText:SetFont(C.Media.Font, 12, C.Media.Font_Style)
MinimapZoneText:SetPoint("TOP", 0, -2)
MinimapZoneText:SetPoint("BOTTOM")
MinimapZoneText:SetHeight(12)
MinimapZoneText:SetWidth(MinimapZone:GetWidth() -6)

local MinimapZoneAnim = CreateAnimationGroup(MinimapZone):CreateAnimation("Fade")
MinimapZoneAnim:SetDuration(0.3)
MinimapZoneAnim:SetSmoothing("InOut")
MinimapZoneAnim:SetChange(1)

Minimap:SetScript("OnEnter", function()
    MinimapZone:SetAlpha(1)
    MinimapZoneText:SetAlpha(1)
end)

Minimap:SetScript("OnLeave", function()
    MinimapZone:SetAlpha(0)
    MinimapZoneText:SetAlpha(0)
end)

local ZoneUpdate = function()
    MinimapZoneText:SetText(strsub(GetMinimapZoneText(), 1, 46))
    MinimapZoneText:SetTextColor(GetLocTextColor())
end

MinimapZone:RegisterEvent("PLAYER_ENTERING_WORLD")
MinimapZone:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MinimapZone:RegisterEvent("ZONE_CHANGED")
MinimapZone:RegisterEvent("ZONE_CHANGED_INDOORS")
MinimapZone:SetScript("OnEvent", ZoneUpdate)