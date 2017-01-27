local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true then return end

local unpack = unpack

local hooksecurefunc = hooksecurefunc
local Movers = K.Movers

-- Make ExtraActionBarFrame movable (use macro /click ExtraActionButton1)
local anchor = CreateFrame("Frame", "ExtraButtonAnchor", UIParent)
if C.ActionBar.SplitBars and not C.DataText.BottomBar then
	anchor:SetPoint(C.Position.ExtraButton[1], SplitBarRight, C.Position.ExtraButton[3], C.Position.ExtraButton[4], C.Position.ExtraButton[5])
elseif C.ActionBar.SplitBars and C.DataText.BottomBar then
	anchor:SetPoint("BOTTOMLEFT", "MultiBarBottomRightButton12", "BOTTOMRIGHT", 3, -28)
elseif not C.ActionBar.SplitBars and C.DataText.BottomBar then
	anchor:SetPoint("BOTTOMLEFT", "ActionButton12", "BOTTOMRIGHT", 3, -28)
else
	anchor:SetPoint(unpack(C.Position.ExtraButton))
end
anchor:SetSize(53, 53)
anchor:SetFrameStrata("LOW")
Movers:RegisterFrame(anchor)

ExtraActionBarFrame:SetParent(ExtraButtonAnchor)
ExtraActionBarFrame:ClearAllPoints()
ExtraActionBarFrame:SetPoint("CENTER", anchor, "CENTER")
ExtraActionBarFrame:SetSize(53, 53)
ExtraActionBarFrame.ignoreFramePositionManager = true

RegisterStateDriver(anchor, "visibility", "[petbattle] hide; show")

ZoneAbilityFrame:SetParent(ExtraButtonAnchor)
ZoneAbilityFrame:ClearAllPoints()
ZoneAbilityFrame:SetPoint("CENTER", anchor, "CENTER")
ZoneAbilityFrame:SetSize(53, 53)
ZoneAbilityFrame.ignoreFramePositionManager = true

-- Skin ExtraActionBarFrame(by Zork)
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

-- Skin ZoneAbilityFrame
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