local K, C, L, _ = select(2, ...):unpack()

local EliteTag = "+"
local RareTag = "^"
local BossTag = "*"

SetCVar("namePlateMinScale", 1)
SetCVar("namePlateMaxScale", 1)

local groups = {
	"Friendly",
	"Enemy",
}

local options = {
	useClassColors = true,
	displayNameWhenSelected = true,
	displayNameByPlayerNameRules = true,
	playLoseAggroHighlight = false,
	displayAggroHighlight = true,
	displaySelectionHighlight = true,
	considerSelectionInCombatAsHostile = true,
	colorNameWithExtendedColors = true,
	colorHealthWithExtendedColors = true,
	selectedBorderColor = CreateColor(5/255, 5/255, 5/255, 1),
	tankBorderColor = false,
	defaultBorderColor = CreateColor(5/255, 5/255, 5/255, 0.5),
	showClassificationIndicator = true,
}

for i, group in next, groups do
	for key, value in next, options do
		_G["DefaultCompactNamePlate"..group.."FrameOptions"][key] = value
	end
end

local function GetHexColorFromRGB(r, g, b)
	return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- SETUPNAMEPLATE
local h = CreateFrame("Frame")
h:RegisterEvent("NAME_PLATE_CREATED")
h:SetScript("OnEvent", function(h, event, ...)
	if event == "NAME_PLATE_CREATED" then
		hooksecurefunc("DefaultCompactNamePlateFrameSetupInternal", function(frame, setupOptions, frameOptions, ...)
			-- HEALTH BAR
			frame.healthBar:SetStatusBarTexture(C.Media.Texture)
			frame.name:SetFont(C.Media.Font, 9, C.Media.Font_Style)
			frame.name:SetShadowOffset(0, -0)

			-- HEALTHBAR BACKGROUND
			if (not frame.healthBar.bg) then
				frame.healthBar.bg = frame.healthBar:CreateTexture(nil, "BACKGROUND", nil, -8)
				frame.healthBar.bg:SetTexture(C.Media.Blank)
				frame.healthBar.bg:SetAllPoints()
			end

			-- CAST BAR
			frame.castBar:SetStatusBarTexture(C.Media.Texture)
			if GetCVar("NamePlateVerticalScale") == "1" then
				frame.castBar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
				frame.castBar.Icon:SetSize(17, 17)
				frame.castBar.Icon:ClearAllPoints()
				frame.castBar.Icon:SetPoint("BOTTOMRIGHT", frame.castBar, "BOTTOMLEFT", -2, 0)
			end
		end)
	end
end)

-- NAME
hooksecurefunc("CompactUnitFrame_UpdateName", function (frame)
	-- SET THE TAG BASED ON UNITCLASSIFICATION, CAN RETURN "WORLDBOSS", "RARE", "RAREELITE", "ELITE", "NORMAL", "MINUS"
	local tag
	local level = UnitLevel(frame.unit)
	local name = UnitName(frame.unit)
	local hexColor

	if level >= UnitLevel("player") +5 then
		hexColor = GetHexColorFromRGB(1, 0, 0)
	elseif level >= UnitLevel("player") +3 then
		hexColor = "ff6600"
	elseif level <= UnitLevel("player") -3 then
		hexColor = GetHexColorFromRGB(0, 1, 0)
	elseif level <= UnitLevel("player") -5 then
		hexColor = GetHexColorFromRGB(0.5, 0.5, 0.5)
	else
		hexColor = GetHexColorFromRGB(1, 1, 0)
	end

	if UnitClassification(frame.unit) == "worldboss" or UnitLevel(frame.unit) == -1 then
		level = "??"
		hexColor = "ff6600"
	elseif UnitClassification(frame.unit) == "rare" then
		name = "*"..name.."*"
	elseif UnitClassification(frame.unit) == "rareelite" then
		name = "*"..name.."*"
		level = "+"..level
	elseif UnitClassification(frame.unit) == "elite" then
		level = "+"..level
	end
	--SET THE NAMEPLATE NAME TO INCLUDE TAG(IF ANY), NAME AND LEVEL
	frame.name:SetText("|cff"..hexColor.."("..level..")|r "..name)
end)

local function IsTank()
	local assignedRole = UnitGroupRolesAssigned("player")
	if assignedRole == "TANK" then return true end
	if K.Role == "TANK" then return true end
	return false
end

-- UPDATEHEALTHBORDER
local function UpdateHealthBorder(frame)
	if frame.displayedUnit:match("(nameplate)%d?$") ~= "nameplate" then return end
	if not IsTank() then return end
	local status = UnitThreatSituation("player", frame.displayedUnit)
	if status and status >= 3 then
		frame.healthBar.border:SetVertexColor(0, 1, 0, 0.8)
	end
end
hooksecurefunc("CompactUnitFrame_UpdateHealthBorder", UpdateHealthBorder)