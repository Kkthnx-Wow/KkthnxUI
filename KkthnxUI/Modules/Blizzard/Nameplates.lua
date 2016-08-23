local K, C, L, _ = select(2, ...):unpack()

local enable = {}

if (K.Name == "Pervie" or K.Name == "Aceer" or K.Name == "Kkthnxx" or K.Name == "Tatterdots") and (K.Realm == "Stormreaver") then
	enable = true
else
	enable = false
end

if enable ~= true then return end

-- LUA API
local _G = _G
local ceil = math.ceil
local floor = math.floor
local format = string.format
local gsub = string.gsub
local len = string.len
local match = string.match
local next = next
local pairs = pairs
local select = select
local tonumber = tonumber

-- WOW API
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetCVarDefault = GetCVarDefault
local UnitCastingInfo = UnitCastingInfo
local UnitIsUnit = UnitIsUnit
local UnitPlayerOrPetInParty = UnitPlayerOrPetInParty
local UnitPlayerOrPetInRaid = UnitPlayerOrPetInRaid
local hooksecurefunc = hooksecurefunc

local BACKDROP = {
	bgFile = [[Interface/Buttons/WHITE8X8]],
	tiled = false,
	insets = {left = -1, right = -1, top = -1, bottom = -1}
}

-- FUNCTIONS. (MERGE THIS WITH KKTHNXUI FUNCTIONS LATER)
K.NameSize = function(frame)
	local font = select(1,frame.name:GetFont())
	local size = C.Media.Font_Size * K.NoScaleMult
	frame.name:SetFont(font, size)
	frame.name:SetShadowOffset(K.Mult, -K.Mult)
end

K.FrameIsNameplate = function(frame)
	if (match(frame.displayedUnit, "nameplate") ~= "nameplate") then
		return false
	else
		return true
	end
end

K.PlayerIsTank = function(target)
	local assignedRole = UnitGroupRolesAssigned(target)

	return assignedRole == "TANK"
end

K.UseOffTankColor = function(target)
	if (C.Nameplate.UseOffTankColor and (UnitPlayerOrPetInRaid(target) or UnitPlayerOrPetInParty(target))) then
		if (not UnitIsUnit("player", target) and K.PlayerIsTank(target) and K.PlayerIsTank("player")) then
			return true
		end
	end
	return false
end

K.IsUsingLargerNamePlateStyle = function()
	local namePlateVerticalScale = tonumber(GetCVar("NamePlateVerticalScale"))
	return namePlateVerticalScale > 1.0
end

K.SetManabarColors = function(frame, color)
	if (frame.healthBar.border) then
		frame.castBar.border:SetVertexColor(unpack(color))
	end
end

K.FormatTime = function(s)
	if s > 86400 then
		-- DAYS
		return ceil(s/86400) .. "d", s%86400
	elseif s >= 3600 then
		-- HOURS
		return ceil(s/3600) .. "h", s%3600
	elseif s >= 60 then
		-- MINUTES
		return ceil(s/60) .. "m", s%60
	elseif s <= 10 then
		-- SECONDS
		return format("%.1f", s)
	end

	return floor(s), s - floor(s)
end

-- START NAMEPLATE CODE
C_Timer.After(1, function()

	-- SET DEFAULTCOMPACTNAMEPLATE OPTIONS
	local groups = {
		"Friendly",
		"Enemy",
	}

	local options = {
		displaySelectionHighlight = true,
		useClassColors = C.Nameplate.ShowClassColors,

		tankBorderColor = CreateColor(unpack(C.Media.Backdrop_Color)),
		selectedBorderColor = CreateColor(unpack(C.Media.Backdrop_Color)),
		defaultBorderColor = CreateColor(unpack(C.Media.Backdrop_Color)),
	}

	for i, group in next, groups do
		for key, value in next, options do
			_G["DefaultCompactNamePlate"..group.."FrameOptions"][key] = value
		end
	end

	-- SET CVARS
	if not InCombatLockdown() then
		-- SET MIN AND MAX SCALE.
		SetCVar("namePlateMinScale", 1)
		SetCVar("namePlateMaxScale", 1)

		-- SET STICKY NAMEPLATES.
		if (not C.Nameplate.DontClamp) then
			SetCVar("nameplateOtherTopInset", -1, true)
			SetCVar("nameplateOtherBottomInset", -1, true)
		else
			for _, v in pairs({"nameplateOtherTopInset", "nameplateOtherBottomInset"}) do SetCVar(v, GetCVarDefault(v), true) end
		end
	end
end)

hooksecurefunc("CompactUnitFrame_UpdateStatusText", function(frame)
	if (not K.FrameIsNameplate(frame)) then return end

	local font = select(1, frame.name:GetFont())

	if (C.Nameplate.ShowHP) then
		if (not frame.healthBar.healthString) then
			frame.healthBar.healthString = frame.healthBar:CreateFontString("$parentHeathValue", "OVERLAY")
			frame.healthBar.healthString:Hide()
			frame.healthBar.healthString:SetPoint("CENTER", frame.healthBar, 0, 0)
			frame.healthBar.healthString:SetFont(C.Media.Font, C.Media.Font_Size * K.NoScaleMult)
			frame.healthBar.healthString:SetShadowOffset(K.Mult, -K.Mult)
		end
	else
		if (frame.healthBar.healthString) then frame.healthBar.healthString:Hide() end
		return
	end

	local health = UnitHealth(frame.displayedUnit)
	local maxHealth = UnitHealthMax(frame.displayedUnit)
	local perc = (health / maxHealth) * 100

	if (perc >= 100 and health > 5 and C.Nameplate.ShowFullHP) then
		if (C.Nameplate.ShowCurHP and perc >= 100) then
			frame.healthBar.healthString:SetFormattedText("%s", K.ShortValue(health))
		elseif (C.Nameplate.ShowCurHP and C.Nameplate.ShowPercHP) then
			frame.healthBar.healthString:SetFormattedText("%s - %.0f%%", K.ShortValue(health), perc - 0.5)
		elseif (C.Nameplate.ShowCurHP) then
			frame.healthBar.healthString:SetFormattedText("%s", K.ShortValue(health))
		elseif (C.Nameplate.ShowPercHP) then
			frame.healthBar.healthString:SetFormattedText("%.0f%%", perc - 0.5)
		else
			frame.healthBar.healthString:SetText("")
		end
	elseif (perc < 100 and health > 5) then
		if (C.Nameplate.ShowCurHP and C.Nameplate.ShowPercHP) then
			frame.healthBar.healthString:SetFormattedText("%s - %.0f%%", K.ShortValue(health), perc - 0.5)
		elseif (C.Nameplate.ShowCurHP) then
			frame.healthBar.healthString:SetFormattedText("%s", K.ShortValue(health))
		elseif (C.Nameplate.ShowPercHP) then
			frame.healthBar.healthString:SetFormattedText("%.0f%%", perc - 0.5)
		else
			frame.healthBar.healthString:SetText("")
		end
	else
		frame.healthBar.healthString:SetText("")
	end
	frame.healthBar.healthString:Show()
end)

-- UPDATE HEALTH COLOR
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
	if (not K.FrameIsNameplate(frame)) then return end

	if (not UnitIsConnected(frame.unit)) then
		local r, g, b = 0.5, 0.5, 0.5
	else
		if (frame.optionTable.healthBarColorOverride) then
			local healthBarColorOverride = frame.optionTable.healthBarColorOverride
			r, g, b = healthBarColorOverride.r, healthBarColorOverride.g, healthBarColorOverride.b
		else
			local localizedClass, englishClass = UnitClass(frame.unit)
			local classColor = RAID_CLASS_COLORS[englishClass]
			if (UnitIsPlayer(frame.unit) and classColor and C.Nameplate.ShowClassColors) then
				r, g, b = classColor.r, classColor.g, classColor.b
			elseif (CompactUnitFrame_IsTapDenied(frame)) then
				r, g, b = 0.1, 0.1, 0.1
			elseif (frame.optionTable.colorHealthBySelection) then
				if (frame.optionTable.considerSelectionInCombatAsHostile and CompactUnitFrame_IsOnThreatListWithPlayer(frame.displayedUnit)) then
					if (C.Nameplate.TankMode) then
						local target = frame.displayedUnit.."target"
						local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
						if (isTanking and threatStatus) then
							if (threatStatus >= 3) then
								r, g, b = 0.0, 1.0, 0.0
							elseif (threatStatus == 2) then
								r, g, b = 1.0, 0.6, 0.2
							end
						elseif (K.UseOffTankColor(target)) then
							r, g, b = (unpack(C.Nameplate.OffTankColor))
						else
							r, g, b = 1.0, 0.0, 0.0
						end
					else
						r, g, b = 1.0, 0.0, 0.0
					end
				else
					r, g, b = UnitSelectionColor(frame.unit, frame.optionTable.colorHealthWithExtendedColors)
				end
			elseif (UnitIsFriend("player", frame.unit)) then
				r, g, b = 0.0, 1.0, 0.0
			else
				r, g, b = 1.0, 0.0, 0.0
			end
		end
	end

	-- EXECUTE RANGE COLORING
	if (C.Nameplate.ShowExecuteRange and K.IsInExecuteRange(frame)) then
		r, g, b = unpack(C.Nameplate.ExecuteColor)
	end

	if (r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b) then
		frame.healthBar:SetStatusBarColor(r, g, b)

		if (frame.optionTable.colorHealthWithExtendedColors) then
			frame.selectionHighlight:SetVertexColor(r, g, b)
		else
			frame.selectionHighlight:SetVertexColor(1, 1, 1)
		end

		frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b
	end
end)

-- CHANGE BORDER COLOR ON TARGET
hooksecurefunc("CompactUnitFrame_UpdateSelectionHighlight", function(frame)
	local r, g, b = frame.healthBar.r, frame.healthBar.g, frame.healthBar.b

	if (frame.healthBar.Border) then
		if (UnitIsUnit(frame.displayedUnit, "target")) then
			frame.healthBar.Border:SetVertexColor(r, g, b, 1)
		else
			frame.healthBar.Border:SetVertexColor(unpack(C.Media.Backdrop_Color))
		end
	end
end)

-- UPDATE CASTBAR TIME
local function UpdateCastbarTimer(frame)

	if (frame.unit) then
		if (frame.castBar.casting) then
			local current = frame.castBar.maxValue - frame.castBar.value
			if (current > 0.0) then
				frame.castBar.CastTime:SetText(K.FormatTime(current))
			end
		else
			if (frame.castBar.value > 0) then
				frame.castBar.CastTime:SetText(K.FormatTime(frame.castBar.value))
			end
		end
	end
end

local function UpdateCastbar(frame)

	-- CASTBAR OVERLAY COLORING
	local notInterruptible
	local red = {.75, 0, 0, 1}
	local green = {0, .75, 0, 1}

	if (frame.unit) then
		if (frame.castBar.casting) then
			notInterruptible = select(9, UnitCastingInfo(frame.displayedUnit))
		else
			notInterruptible = select(8, UnitChannelInfo(frame.displayedUnit))
		end

		if (UnitCanAttack("player", frame.displayedUnit)) then
			if (notInterruptible) then
				K.SetManabarColors(frame, red)
			else
				K.SetManabarColors(frame, green)
			end
		else
			K.SetManabarColors(frame, unpack(C.Media.Backdrop_Color))
		end
	end

	-- BACKUP ICON BACKGROUND
	if (frame.castBar.Icon.Background) then
		local _,class = UnitClass(frame.displayedUnit)
		if (not class) then
			frame.castBar.Icon.Background:SetTexture("Interface\\Icons\\Ability_DualWield")
		else
			frame.castBar.Icon.Background:SetTexture("Interface\\Icons\\ClassIcon_"..class)
		end
	end

	-- ABBREVIATE LONG SPELL NAMES
	if (not K.IsUsingLargerNamePlateStyle()) then
		local spellName = frame.castBar.Text:GetText()
		if (spellName ~= nil) then
			spellName = (len(spellName) > 20) and gsub(spellName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or spellName
			frame.castBar.Text:SetText(spellName)
		end
	end
end

local function UpdateCastbar(frame)
	-- Abbreviate Long Spell Names
	if (not K.IsUsingLargerNamePlateStyle()) then
		local spellName = frame.castBar.Text:GetText()
		if (spellName ~= nil) then
			spellName = (len(spellName) > 20) and gsub(spellName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or spellName
			frame.castBar.Text:SetText(spellName)
		end
	end
end

-- SETUP FRAMES
hooksecurefunc("DefaultCompactNamePlateFrameSetup", function(frame, options)

	-- NAME
	K.NameSize(frame)

	-- HEALTHBAR
	frame.healthBar:SetHeight(8)
	frame.healthBar:Hide()
	frame.healthBar:ClearAllPoints()
	frame.healthBar:SetPoint("BOTTOMLEFT", frame.castBar, "TOPLEFT", 0, 4.2)
	frame.healthBar:SetPoint("BOTTOMRIGHT", frame.castBar, "TOPRIGHT", 0, 4.2)
	frame.healthBar:SetStatusBarTexture(C.Media.Texture)
	frame.healthBar:Show()

	-- CASTBAR
	local castbarFont = select(1, frame.castBar.Text:GetFont())

	-- ADD A BORDER TO THE CASTBAR LIKE THE HEALTHBAR HAS
	if (not frame.castBar.border) then
		frame.castBar.border = CreateFrame("Frame", nil, frame.castBar, "NamePlateFullBorderTemplate")
		frame.castBar.border:SetVertexColor(0.2, 0.2, 0.2, 0.85) -- THIS IS THE DEFAULT COLOR BLIZZARD USES IN THEIR .XML
	end

	frame.castBar:SetHeight(8)
	frame.castBar:SetStatusBarTexture(C.Media.Texture)

	-- SPELL NAME
	frame.castBar.Text:Hide()
	frame.castBar.Text:ClearAllPoints()
	frame.castBar.Text:SetFont(castbarFont, C.Media.Font_Size * K.NoScaleMult)
	frame.castBar.Text:SetShadowOffset(K.Mult, -K.Mult)
	frame.castBar.Text:SetPoint("LEFT", frame.castBar, "LEFT", 2, 0)
	frame.castBar.Text:Show()

	-- SET CASTBAR TIMER
	if (not frame.castBar.CastTime) then
		frame.castBar.CastTime = frame.castBar:CreateFontString(nil, "OVERLAY")
		frame.castBar.CastTime:Hide()
		frame.castBar.CastTime:SetPoint("BOTTOMRIGHT", frame.castBar.Icon, "BOTTOMRIGHT", 0, 0)
		frame.castBar.CastTime:SetFont(castbarFont, C.Media.Font_Size * K.NoScaleMult, C.Media.Font_Style)
		frame.castBar.CastTime:Show()
	end

	-- CASTBAR ICON
	frame.castBar.Icon:SetSize(20, 20)
	frame.castBar.Icon:Hide()
	frame.castBar.Icon:ClearAllPoints()
	frame.castBar.Icon:SetPoint("BOTTOMLEFT", frame.castBar, "BOTTOMRIGHT", 4.9, 0)
	frame.castBar.Icon:SetTexCoord(unpack(K.TexCoords))
	frame.castBar.Icon:Show()

	-- CASTBAR ICON BACKGROUND
    if (not frame.castBar.Icon.Background) then
        frame.castBar.Icon.Background = CreateFrame('Frame', nil, frame.castBar)
		frame.castBar.Icon.Background:SetAllPoints(frame.castBar.Icon)
		frame.castBar.Icon.Background:SetFrameLevel(0)
    end

	-- CASTBAR ICON BORDER
    if (not frame.castBar.Icon.border) then
		 frame.castBar.Icon.Background:SetBackdrop(BACKDROP)
		 frame.castBar.Icon.Background:SetBackdropColor(0.2, 0.2, 0.2, 0.85)
    end

	frame.castBar.BorderShield:SetSize(16, 16)
	frame.castBar.BorderShield:ClearAllPoints()
	frame.castBar.BorderShield:SetPoint("CENTER", frame.castBar.Icon)

	-- UPDATE CASTBAR
	frame.castBar:SetScript("OnValueChanged", function(self, value)
		UpdateCastbarTimer(frame)
	end)

	frame.castBar:SetScript("OnShow", function(self)
		UpdateCastbar(frame)
	end)
end)

hooksecurefunc("DefaultCompactNamePlatePlayerFrameSetup", function(frame, setupOptions, frameOptions)
	frame.healthBar:SetHeight(8)
end)

hooksecurefunc("CompactUnitFrame_UpdateName", function(frame)
	if (not K.FrameIsNameplate(frame)) then return end

	-- HIDE FRIENDLY NAMEPLATES
	if (UnitIsFriend(frame.displayedUnit, "player") and not UnitCanAttack(frame.displayedUnit, "player") and C.Nameplate.HideFriendly) then
		frame.healthBar:Hide()
	else
		frame.healthBar:Show()
	end

	if (not ShouldShowName(frame)) then
		frame.name:Hide()
	else

		-- FRIENDLY NAMEPLATE CLASS COLOR
		if (C.Nameplate.ShowClassColors and UnitIsPlayer(frame.displayedUnit)) then
			frame.name:SetTextColor(frame.healthBar:GetStatusBarColor())
		end

		-- SHORTEN LONG NAMES
		local newName = GetUnitName(frame.displayedUnit, C.Nameplate.ShowServerName) or UNKNOWN
		if (C.Nameplate.AbrrevLongNames) then
			newName = (len(newName) > 20) and gsub(newName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or newName
		end

		-- LEVEL
		if (C.Nameplate.ShowLevel) then
			local playerLevel = UnitLevel("player")
			local targetLevel = UnitLevel(frame.displayedUnit)
			local difficultyColor = GetRelativeDifficultyColor(playerLevel, targetLevel)
			local levelColor = K.RGBToHex(difficultyColor.r, difficultyColor.g, difficultyColor.b)

			if (targetLevel == -1) then
				frame.name:SetText(newName)
			else
				frame.name:SetText("|cffffff00|r"..levelColor..targetLevel.."|r "..newName)
			end
		else
			frame.name:SetText(newName)
		end

		-- COLOR NAME TO THREAT STATUS
		if (C.Nameplate.ColorNameByThreat) then
			local isTanking, threatStatus = UnitDetailedThreatSituation("player", frame.displayedUnit)
			if (isTanking and threatStatus) then
				if (threatStatus >= 3) then
					frame.name:SetTextColor(0, 1, 0)
				elseif (threatStatus == 2) then
					frame.name:SetTextColor(1, 0.6, 0.2)
				end
			else
				local target = frame.displayedUnit.."target"
				if (K.UseOffTankColor(target)) then
					frame.name:SetTextColor((unpack(C.Nameplate.OffTankColor)))
				end
			end
		end
	end
end)

-- BUFF FRAME OFFSETS
hooksecurefunc(NamePlateBaseMixin,"ApplyOffsets", function(self)
	local targetMode = GetCVarBool("nameplateShowSelf") and GetCVarBool("nameplateResourceOnTarget")

	self.UnitFrame.BuffFrame:SetBaseYOffset(0)

	if (targetMode) then
		self.UnitFrame.BuffFrame:SetTargetYOffset(25)
	else
		self.UnitFrame.BuffFrame:SetTargetYOffset(0)
	end
end)

-- UPDATE BUFF FRAME ANCHOR
hooksecurefunc(NameplateBuffContainerMixin,"UpdateAnchor", function(self)
	local targetMode = GetCVarBool("nameplateShowSelf") and GetCVarBool("nameplateResourceOnTarget")
	local isTarget = self:GetParent().unit and UnitIsUnit(self:GetParent().unit, "target")
	local targetYOffset = isTarget and self:GetTargetYOffset() or 0.0
	local nameHeight = self:GetParent().name:GetHeight()

	if (self:GetParent().unit and ShouldShowName(self:GetParent())) then
		if (targetMode) then
			if (K.IsUsingLargerNamePlateStyle()) then
				self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, targetYOffset + 5)
			else
				self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, nameHeight+targetYOffset + 5)
			end
		else
			if (K.IsUsingLargerNamePlateStyle()) then
				self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, 0)
			else
				self:SetPoint("BOTTOM", self:GetParent(), "TOP", 0, nameHeight + 5)
			end
		end
	else
		self:SetPoint("BOTTOM", self:GetParent().healthBar, "TOP", 0, 5)
	end
end)