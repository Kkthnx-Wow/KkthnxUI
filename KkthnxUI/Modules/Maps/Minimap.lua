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

-- MINIMAP BORDER
local MinimapAnchor = CreateFrame("Frame", "MinimapAnchor", UIParent)
MinimapAnchor:CreatePanel("ClassColor", C.Minimap.Size, C.Minimap.Size, unpack(C.Position.Minimap))

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
	"GameTimeFrame",
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
Minimap:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 0, 0)
Minimap:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", 0, 0)
Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
-- BACKDROP
MinimapBackdrop:ClearAllPoints()
MinimapBackdrop:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 2, -2)
MinimapBackdrop:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", -2, 2)
MinimapBackdrop:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())

-- MAIL
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint("TOPRIGHT", Minimap, 4, 8)
MiniMapMailFrame:SetScale(1.2)
MiniMapMailFrame:SetFrameLevel(Minimap:GetFrameLevel() + 1)
MiniMapMailFrame:SetFrameStrata(Minimap:GetFrameStrata())
MiniMapMailBorder:Hide()
MailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")

-- QUEUESTATUS ICON
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", 0, 0)
QueueStatusMinimapButtonBorder:Kill()

MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

-- GUILD INSTANCE DIFFICULTY ICON
GuildInstanceDifficulty:ClearAllPoints()
GuildInstanceDifficulty:SetParent(Minimap)
GuildInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)
GuildInstanceDifficulty:SetScale(0.75)

-- CHALLENGE MODE ICON
MiniMapChallengeMode:SetParent(Minimap)
MiniMapChallengeMode:ClearAllPoints()
MiniMapChallengeMode:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", -2, -2)
MiniMapChallengeMode:SetScale(0.75)

-- INVITES ICON
GameTimeCalendarInvitesTexture:SetParent("Minimap")

-- DEFAULT LFG ICON
LFG_EYE_TEXTURES.raid = LFG_EYE_TEXTURES.default
LFG_EYE_TEXTURES.unknown = LFG_EYE_TEXTURES.default

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
HelpOpenTicketButton:SetPoint("TOP", Minimap, "TOP", 0, -2)
HelpOpenTicketButton:SetHighlightTexture(nil)
HelpOpenTicketButton:SetPushedTexture("Interface\\Icons\\inv_misc_note_03")
HelpOpenTicketButton:SetNormalTexture("Interface\\Icons\\inv_misc_note_03")
HelpOpenTicketButton:GetNormalTexture():SetTexCoord(unpack(K.TexCoords))
HelpOpenTicketButton:GetPushedTexture():SetTexCoord(unpack(K.TexCoords))
HelpOpenTicketButton:SetSize(16, 16)

-- ENABLE MOUSE SCROLLING
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
	if (delta > 0) then
		MinimapZoomIn:Click()
	elseif (delta < 0) then
		MinimapZoomOut:Click()
	end
end)

-- CLOCKFRAME
if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end
local ClockFrame, ClockTime = TimeManagerClockButton:GetRegions()
ClockFrame:Hide()
ClockTime:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
ClockTime:SetTextColor(255/255, 255/255, 255/255)
ClockTime:SetShadowOffset(0, 0)
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -6)
TimeManagerClockButton:SetScript("OnShow", nil)
TimeManagerClockButton:SetScript("OnClick", function(self, button)
	if(button == "RightButton") then
		if(self.alarmFiring) then
			PlaySound("igMainMenuQuit")
			TimeManager_TurnOffAlarm()
		else
			ToggleTimeManager()
		end
	else
		ToggleCalendar()
	end
end)

SlashCmdList["CALENDAR"] = function()
	ToggleCalendar()
end
SLASH_CALENDAR1 = "/cl"
SLASH_CALENDAR2 = "/calendar"

local Calendar = CreateFrame("Frame", nil, Minimap)
GameTimeFrame:HookScript("OnShow", Calendar.Show)
GameTimeFrame:SetScript("OnEvent", function(self, event, addon)
end)

if CalendarGetNumPendingInvites() ~= 0 then
	ClockTime:SetTextColor(K.Color.r, K.Color.g, K.Color.b)
else
	ClockTime:SetTextColor(255/255, 255/255, 255/255)
end

-- FOR OTHERS MODS WITH A MINIMAP BUTTON, SET MINIMAP BUTTONS POSITION IN SQUARE MODE
function GetMinimapShape() return "SQUARE" end

-- SET BORDER TEXTURE
MinimapBackdrop:SetBackdrop(K.Backdrop)
MinimapBackdrop:SetBackdropColor(0.05, 0.05, 0.05, 0.0)
if C.Blizzard.DarkTextures == true then
	MinimapBackdrop:SetBackdropBorderColor(unpack(C.Blizzard.DarkTexturesColor))
end
MinimapBackdrop:SetOutside(Minimap, 4, 4)

-- SET SQUARE MAP VIEW
Minimap:SetMaskTexture(C.Media.Blank)
Minimap:SetArchBlobRingAlpha(0)
Minimap:SetQuestBlobRingAlpha(0)
MinimapBorder:Hide()