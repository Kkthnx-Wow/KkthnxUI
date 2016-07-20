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

-- Minimap border
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
}

for i, FrameName in pairs(HiddenFrames) do
	local Frame = _G[FrameName]
	Frame:Hide()

	if Frame.UnregisterAllEvents then
		Frame:UnregisterAllEvents()
	end

	North:SetTexture(nil)
end

-- Parent Minimap into our frame
Minimap:SetParent(MinimapAnchor)
Minimap:ClearAllPoints()
Minimap:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 0, 0)
Minimap:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", 0, 0)
Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
-- Backdrop
MinimapBackdrop:ClearAllPoints()
MinimapBackdrop:SetPoint("TOPLEFT", MinimapAnchor, "TOPLEFT", 2, -2)
MinimapBackdrop:SetPoint("BOTTOMRIGHT", MinimapAnchor, "BOTTOMRIGHT", -2, 2)
MinimapBackdrop:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())

-- Mail
Mail:ClearAllPoints()
Mail:SetPoint("TOPRIGHT", Minimap, 6, 10)
Mail:SetFrameLevel(Minimap:GetFrameLevel() + 2)
Mail:SetScale(1.2)
MailBorder:Hide()
MailIcon:SetTexture("Interface\\Addons\\KkthnxUI\\Media\\Textures\\Mail")

QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint("BOTTOMRIGHT", 0, 0)
QueueStatusMinimapButtonBorder:Kill()

MiniMapInstanceDifficulty:ClearAllPoints()
MiniMapInstanceDifficulty:SetParent(Minimap)
MiniMapInstanceDifficulty:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)

-- Invites icon
GameTimeCalendarInvitesTexture:ClearAllPoints()
GameTimeCalendarInvitesTexture:SetParent(Minimap)
GameTimeCalendarInvitesTexture:SetPoint("BOTTOM", 0, 5)

-- Enable mouse scrolling
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, delta)
	if (delta > 0) then
		MinimapZoomIn:Click()
	elseif (delta < 0) then
		MinimapZoomOut:Click()
	end
end)

-- ClockFrame
if not IsAddOnLoaded("Blizzard_TimeManager") then
	LoadAddOn("Blizzard_TimeManager")
end
local ClockFrame, ClockTime = TimeManagerClockButton:GetRegions()
ClockFrame:Hide()
ClockTime:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
ClockTime:SetShadowOffset(0, 0)
TimeManagerClockButton:ClearAllPoints()
TimeManagerClockButton:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -5)
TimeManagerClockButton:SetScript("OnShow", nil)
TimeManagerClockButton:Hide()
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

-- For others mods with a minimap button, set minimap buttons position in square mode.
function GetMinimapShape()
	return "SQUARE"
end

-- Set Boarder Texture
MinimapBackdrop:SetBackdrop(K.Backdrop)
MinimapBackdrop:SetBackdropColor(0.05, 0.05, 0.05, 0.0)
MinimapBackdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))
MinimapBackdrop:SetOutside(Minimap, 4, 4)

-- Set Square Map View
Minimap:SetMaskTexture(C.Media.Blank)
MinimapBorder:Hide()