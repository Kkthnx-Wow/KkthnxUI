local K, C, L, _ = select(2, ...):unpack()
if C.Minimap.Enable ~= true then return end

local _G = _G
local unpack = unpack
local pairs = pairs
local IsAddOnLoaded = IsAddOnLoaded
local Mail = MiniMapMailFrame
local MailBorder = MiniMapMailBorder
local MailIcon = MiniMapMailIcon
local MiniMapInstanceDifficulty = MiniMapInstanceDifficulty
local North = _G["MinimapNorthTag"]
local PlaySound, CreateFrame, UIParent = PlaySound, CreateFrame, UIParent
local Movers = K["Movers"]

-- MINIMAP BORDER
local MinimapAnchor = CreateFrame("Frame", "MinimapAnchor", UIParent)
MinimapAnchor:CreatePanel("ClassColor", C.Minimap.Size, C.Minimap.Size, unpack(C.Position.Minimap))
Movers:RegisterFrame(MinimapAnchor)

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
	--"GameTimeFrame",
	"MiniMapWorldMapButton",
	"GarrisonLandingPageMinimapButton",
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

-- HIDE BLOB RING
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)

-- FIX GARRISON REPORT KEYBIND
GarrisonLandingPageMinimapButton.IsShown = function() return true end

-- PARENT MINIMAP INTO OUR FRAME
Minimap:SetParent(MinimapAnchor)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 4, -4)
Minimap:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", -4, 4)
Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
-- BACKDROP
MinimapBackdrop:ClearAllPoints()
MinimapBackdrop:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 2, -2)
MinimapBackdrop:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", -2, 2)
MinimapBackdrop:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())

-- MAIL
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("BOTTOMRIGHT", Minimap, 4, -4)
MiniMapMailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")
MiniMapMailBorder:SetTexture("Interface\\Calendar\\EventNotificationGlow")
MiniMapMailBorder:SetBlendMode("ADD")
MiniMapMailBorder:ClearAllPoints()
MiniMapMailBorder:SetPoint("CENTER", MiniMapMailFrame, 0, -1)
MiniMapMailBorder:SetSize(27, 27)
MiniMapMailBorder:SetAlpha(0.5)

-- QUEUESTATUS ICON
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:SetScale(1)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", Minimap, -4, -4)
QueueStatusMinimapButtonBorder:Hide()
QueueStatusMinimapButton:SetHighlightTexture (nil)
QueueStatusMinimapButton:SetPushedTexture(nil)

-- DUNGEON INFO
MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetPoint("TOP", Minimap, "TOP", 0, -4)
MiniMapInstanceDifficulty:SetScale(0.8)
GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetPoint("TOP", Minimap, "TOP", 0, -4)
GuildInstanceDifficulty:SetScale(0.7)
MiniMapChallengeMode:ClearAllPoints()
MiniMapChallengeMode:SetPoint("TOP", Minimap, "TOP", 0, -10)
MiniMapChallengeMode:SetScale(0.6)

-- FEEDBACK ICON
if FeedbackUIButton then
	FeedbackUIButton:ClearAllPoints()
	FeedbackUIButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -20)
	FeedbackUIButton:SetScale(0.8)
end

-- STREAMING ICON
if StreamingIcon then
	StreamingIcon:ClearAllPoints()
	StreamingIcon:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -20)
	StreamingIcon:SetScale(0.8)
	StreamingIcon:SetFrameStrata("BACKGROUND")
end

-- TICKET ICON
HelpOpenTicketButton:SetParent(Minimap)
HelpOpenTicketButton:SetFrameLevel(4)
HelpOpenTicketButton:ClearAllPoints()
HelpOpenTicketButton:SetPoint("LEFT", StatFrame, "LEFT", 3, 0)
HelpOpenTicketButton:SetHighlightTexture(nil)
HelpOpenTicketButton:SetPushedTexture("Interface\\Icons\\inv_misc_note_03")
HelpOpenTicketButton:SetNormalTexture("Interface\\Icons\\inv_misc_note_03")
HelpOpenTicketButton:GetNormalTexture():SetTexCoord(unpack(K.TexCoords))
HelpOpenTicketButton:GetPushedTexture():SetTexCoord(unpack(K.TexCoords))
HelpOpenTicketButton:SetSize(16, 16)

-- BLIZZARD_TIMEMANAGER
LoadAddOn("Blizzard_TimeManager")
TimeManagerClockButton:GetRegions():Hide()
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("BOTTOM", 0, -6)
TimeManagerClockTicker:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
TimeManagerClockTicker:SetShadowOffset(0, -0)

-- GAMETIMEFRAME
GameTimeFrame:SetParent(Minimap)
GameTimeFrame:ClearAllPoints()
GameTimeFrame:SetPoint("TOPRIGHT", Minimap, -4, -4)
GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
GameTimeFrame:GetNormalTexture():SetTexCoord(0, 1, 0, 1)
GameTimeFrame:SetNormalTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Calendar.blp")
GameTimeFrame:SetPushedTexture(nil)
GameTimeFrame:SetHighlightTexture (nil)
GameTimeFrame:SetAlpha(0)
-- HOVEROVER.
GameTimeFrame:SetScript("OnEnter", function() GameTimeFrame:FadeIn() end)
GameTimeFrame:SetScript("OnLeave", function() GameTimeFrame:FadeOut() end)
local FontString = GameTimeFrame:GetFontString()
FontString:ClearAllPoints()
FontString:SetPoint("CENTER", 0, -2)
FontString:SetFont(C.Media.Font, 14)
FontString:SetTextColor(0.2, 0.2, 0.1, 0.9)

-- ENABLE MOUSE SCROLLING
Minimap:EnableMouseWheel()
local function Zoom(self, direction)
  if(direction > 0) then Minimap_ZoomIn()
  else Minimap_ZoomOut() end
end
Minimap:SetScript("OnMouseWheel", Zoom)

-- FOR OTHERS MODS WITH A MINIMAP BUTTON, SET MINIMAP BUTTONS POSITION IN SQUARE MODE
function GetMinimapShape() return "SQUARE" end

-- SET BORDER TEXTURE
MinimapBackdrop:SetBackdrop(K.Backdrop)
MinimapBackdrop:SetBackdropColor(0.05, 0.05, 0.05, 0.0)
MinimapBackdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))
if C.Blizzard.ColorTextures == true then
	MinimapBackdrop:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end
MinimapBackdrop:SetOutside(Minimap, 4, 4)

-- SET SQUARE MAP VIEW
Minimap:SetMaskTexture(C.Media.Blank)
Minimap:SetArchBlobRingAlpha(0)
Minimap:SetQuestBlobRingAlpha(0)
MinimapBorder:Hide()