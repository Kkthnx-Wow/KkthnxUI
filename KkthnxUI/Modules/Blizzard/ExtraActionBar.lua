local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

local unpack = unpack

local hooksecurefunc = hooksecurefunc
local Movers = K.Movers

-- MAKE EXTRAACTIONBARFRAME MOVABLE (USE MACRO /click extraactionbutton1)
local anchor = CreateFrame("Frame", "ExtraButtonAnchor", UIParent)
if C.ActionBar.SplitBars then
	anchor:SetPoint(C.Position.ExtraButton[1], SplitBarLeft, C.Position.ExtraButton[3], C.Position.ExtraButton[4], C.Position.ExtraButton[5])
else
	anchor:SetPoint(unpack(C.Position.ExtraButton))
end
anchor:SetSize(53, 53)
Movers:RegisterFrame(anchor)

ExtraActionBarFrame:SetParent(UIParent)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetPoint("CENTER", anchor, "CENTER")
ExtraActionBarFrame:SetSize(53, 53)
ExtraActionBarFrame.ignoreFramePositionManager = true

RegisterStateDriver(anchor, "visibility", "[petbattle] hide; show")

ZoneAbilityFrame:SetParent(UIParent)
ZoneAbilityFrame:ClearAllPoints()
ZoneAbilityFrame:SetPoint("CENTER", anchor, "CENTER")
ZoneAbilityFrame:SetSize(53, 53)
ZoneAbilityFrame.ignoreFramePositionManager = true

-- SKIN EXTRAACTIONBARFRAME(BY ZORK)
local button = ExtraActionButton1
local texture = button.style
local disableTexture = function(style, texture)
	if texture then
		style:SetTexture(nil)
	end
end
button.style:SetTexture(nil)
hooksecurefunc(texture, "SetTexture", disableTexture)

button:StyleButton()
button:SetSize(53, 53)

-- SKIN ZONEABILITYFRAME
local button = ZoneAbilityFrame.SpellButton
local texture = button.Style
local disableTexture = function(style, texture)
	if texture then
		style:SetTexture(nil)
	end
end
button.Style:SetTexture(nil)
hooksecurefunc(texture, "SetTexture", disableTexture)

button:StripTextures()
button:StyleButton()
button:SetSize(53, 53)
button:CreateBackdrop("Transparent")
button.backdrop:SetOutside()
if C.ActionBar.ClassColorBorder == true then
	button.backdrop:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
end

button.Icon:SetTexCoord(unpack(K.TexCoords))
button.Icon:SetPoint("TOPLEFT", button, 2, -2)
button.Icon:SetPoint("BOTTOMRIGHT", button, -2, 2)

button.Count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
button.Count:SetShadowOffset(0, 0)
button.Count:SetPoint("BOTTOMRIGHT", 1, -2)
button.Count:SetJustifyH("RIGHT")

button.Cooldown:SetAllPoints(button.Icon)