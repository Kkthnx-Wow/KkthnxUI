local K, C, L = select(2, ...):unpack()
if C.Minimap.Enable ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local GetMinimapShape = GetMinimapShape
local IsInInstance = IsInInstance

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GarrisonLandingPageMinimapButton, Minimap, TimeManagerClockButton, GameTimeFrame
-- GLOBALS: Minimap_ZoomIn, Minimap_ZoomOut

local Mail = MiniMapMailFrame
local MailBorder = MiniMapMailBorder
local MailIcon = MiniMapMailIcon
local Movers = K.Movers

-- Minimap border
local MinimapAnchor = CreateFrame("Frame", "MinimapAnchor", UIParent)
MinimapAnchor:CreatePanel("ClassColor", C.Minimap.Size, C.Minimap.Size, unpack(C.Position.Minimap))
Movers:RegisterFrame(MinimapAnchor)

local North = _G["MinimapNorthTag"]
local HiddenFrames = {
	"MinimapCluster",
	"MinimapBorder",
	"MinimapBorderTop",
	"MinimapZoomIn",
	"MinimapZoomOut",
	"MiniMapVoiceChatFrame",
	"MinimapNorthTag",
	"MinimapZoneTextButton",
	"MiniMapTracking",
	"MiniMapWorldMapButton",
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

-- Hide Game Time
MinimapAnchor:RegisterEvent("PLAYER_LOGIN")
MinimapAnchor:RegisterEvent("ADDON_LOADED")
MinimapAnchor:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_TimeManager" then
		TimeManagerClockButton:Kill()
	end
end)

-- Hide blob ring
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

-- Fix garrison report keybind
GarrisonLandingPageMinimapButton.IsShown = function() return true end

-- Parent minimap into our frame
Minimap:SetParent(MinimapAnchor)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 4, -4)
Minimap:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", -4, 4)
Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
-- Backdrop
MinimapBackdrop:ClearAllPoints()
MinimapBackdrop:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 2, -2)
MinimapBackdrop:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", -2, 2)
MinimapBackdrop:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())

-- Mail
Mail:ClearAllPoints()
Mail:SetPoint("BOTTOM", 0, 4)
Mail:SetFrameLevel(Minimap:GetFrameLevel() + 2)
MailBorder:Hide()
Mail:SetScale(1.2)
MailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")

-- Queuestatus icon
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", 4, -4)
QueueStatusMinimapButtonBorder:Kill()
QueueStatusFrame:StripTextures()
QueueStatusFrame:SetTemplate()

-- Garrison icon
if C.Minimap.Garrison == true then
	GarrisonLandingPageMinimapButton:ClearAllPoints()
	GarrisonLandingPageMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, 2)
	GarrisonLandingPageMinimapButton:SetScale(1)
	GarrisonLandingPageMinimapButton:SetSize(32, 32)
	GarrisonLandingPageMinimapButton:SetAlpha(1)
else
	GarrisonLandingPageMinimapButton:SetScale(0.0001)
	GarrisonLandingPageMinimapButton:SetAlpha(0)
end

local AutoHideLandingPage = CreateFrame("Frame")
AutoHideLandingPage:RegisterEvent("PLAYER_ENTERING_WORLD")
AutoHideLandingPage:SetScript("OnEvent", function(self, event)
	local InInstance, Type = IsInInstance()
	if InInstance and (Type == "party" or Type == "pvp" or Type == "arena" or Type == "raid") and C.Minimap.Garrison == true then
		GarrisonLandingPageMinimapButton:SetScale(0.0001)
		GarrisonLandingPageMinimapButton:SetAlpha(0)
	else
		GarrisonLandingPageMinimapButton:SetScale(1)
		GarrisonLandingPageMinimapButton:SetAlpha(1)
	end
end)

-- Dungeon info
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, -2)
MiniMapInstanceDifficulty:SetScale(0.8)

GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetParent(Minimap)
GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, -2)
GuildInstanceDifficulty:SetScale(0.8)

MiniMapChallengeMode:ClearAllPoints()
MiniMapChallengeMode:SetParent(Minimap)
MiniMapChallengeMode:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, -2)
MiniMapChallengeMode:SetScale(0.6)

-- Feedback icon
if FeedbackUIButton then
	FeedbackUIButton:ClearAllPoints()
	FeedbackUIButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -20)
	FeedbackUIButton:SetScale(0.8)
end

-- Streaming icon
if StreamingIcon then
	StreamingIcon:ClearAllPoints()
	StreamingIcon:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -20)
	StreamingIcon:SetScale(0.8)
	StreamingIcon:SetFrameStrata("BACKGROUND")
end

Minimap.Ticket = CreateFrame("Frame", nil, Minimap)
Minimap.Ticket:SetSize(Minimap:GetWidth() + 4, 24)
Minimap.Ticket:SetFrameLevel(Minimap:GetFrameLevel() + 4)
Minimap.Ticket:SetFrameStrata(Minimap:GetFrameStrata())
Minimap.Ticket:SetPoint("BOTTOM", 0, -47)
Minimap.Ticket:FontString("Text", C.Media.Font, 12)
Minimap.Ticket.Text:SetPoint("CENTER")
Minimap.Ticket.Text:SetText(HELP_TICKET_EDIT)
Minimap.Ticket:SetAlpha(0)

-- Ticket icon
HelpOpenTicketButton:SetParent(Minimap.Ticket)
HelpOpenTicketButton:SetFrameLevel(Minimap.Ticket:GetFrameLevel() + 1)
HelpOpenTicketButton:SetFrameStrata(Minimap.Ticket:GetFrameStrata())
HelpOpenTicketButton:ClearAllPoints()
HelpOpenTicketButton:SetAllPoints()
HelpOpenTicketButton:SetHighlightTexture(nil)
HelpOpenTicketButton:SetAlpha(0)
HelpOpenTicketButton:HookScript("OnShow", function(self) Minimap.Ticket:SetAlpha(1) end)
HelpOpenTicketButton:HookScript("OnHide", function(self) Minimap.Ticket:SetAlpha(0) end)

-- Gametime
GameTimeFrame:SetParent(Minimap)
GameTimeFrame:SetScale(0.6)
GameTimeFrame:ClearAllPoints()
GameTimeFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -2)
GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
GameTimeFrame:SetNormalTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Calendar.blp")
GameTimeFrame:SetPushedTexture(nil)
GameTimeFrame:SetHighlightTexture(nil)
GameTimeFrame:SetAlpha(0)
GameTimeFrame:HookScript("OnEnter", function()
	GameTimeFrame:FadeIn()
end)
GameTimeFrame:HookScript("OnLeave", function()
	GameTimeFrame:FadeOut()
end)

local FontString = GameTimeFrame:GetFontString()
FontString:ClearAllPoints()
FontString:SetPoint("CENTER", 0, -6)
FontString:SetFont(C.Media.Font, 16)
FontString:SetTextColor(unpack(C.Media.Backdrop_Color))

-- Enable mouse scrolling
Minimap:EnableMouseWheel()
local function Zoom(self, direction)
	if(direction > 0) then Minimap_ZoomIn()
	else Minimap_ZoomOut() end
end
Minimap:SetScript("OnMouseWheel", Zoom)

-- For others mods with a minimap button, set minimap buttons position in square mode
function GetMinimapShape() return "SQUARE" end

-- Set border texture
MinimapBackdrop:SetBackdrop(K.Backdrop)
MinimapBackdrop:SetBackdropColor(0.05, 0.05, 0.05, 0.0)
MinimapBackdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))
if C.Blizzard.ColorTextures == true then
	MinimapBackdrop:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end
MinimapBackdrop:SetOutside(Minimap, 4, 4)

-- Set square map view
Minimap:SetMaskTexture(C.Media.Blank)
Minimap:SetArchBlobRingAlpha(0)
Minimap:SetQuestBlobRingAlpha(0)
MinimapBorder:Hide()
