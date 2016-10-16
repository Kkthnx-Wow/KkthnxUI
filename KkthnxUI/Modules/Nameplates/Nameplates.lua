local K, C, L = select(2, ...):unpack()
if IsAddOnLoaded("TidyPlates") or IsAddOnLoaded("Aloft") or IsAddOnLoaded("Kui_Nameplates") or IsAddOnLoaded("bdNameplates") then
	return
end

-- Convert this over to KkthnxUI Config soon.
local HideFriendly = true

local KkthnxUIPlates = CreateFrame("Frame", nil, WorldFrame)

local _G = _G
local select = select
local pairs = pairs

local CompactUnitFrame_IsTapDenied = CompactUnitFrame_IsTapDenied
local CreateColor = CreateColor
local CreateFrame = CreateFrame
local C_NamePlate = C_NamePlate
local GetUnitName = GetUnitName
local InCombatLockdown = InCombatLockdown
local ShouldShowName = ShouldShowName
local UnitAffectingCombat = UnitAffectingCombat
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitGUID = UnitGUID
local UnitIsEnemy = UnitIsEnemy
local UnitIsPlayer = UnitIsPlayer
local UnitIsPVP = UnitIsPVP
local UnitLevel = UnitLevel
local SetCVar = SetCVar

-- constants
local CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local ICON = {
	Alliance = "\124TInterface/PVPFrame/PVP-Currency-Alliance:16\124t",
	Horde = "\124TInterface/PVPFrame/PVP-Currency-Horde:16\124t"
}

local NAME_FADE_VALUE = .6
local BAR_FADE_VALUE = .4

-- helper functions
local function Abbrev(name)
	local newname = (string.len(name) > 18) and string.gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
	return K.ShortenString(newname, 18, false)
end

local function IsTanking(unit)
	return select(1, UnitDetailedThreatSituation("player", unit))
end

local function InCombat(unit)
	return UnitAffectingCombat(unit) and UnitCanAttack("player", unit)
end

local function IsOnThreatList(unit)
	return select(2, UnitDetailedThreatSituation("player", unit)) ~= nil
end

-- identical to CastingBarFrame_ApplyAlpha
local function ApplyCastingBarAlpha(frame, alpha)
	frame:SetAlpha(alpha)
	if (frame.additionalFadeWidgets) then
		for widget in pairs(frame.additionalFadeWidgets) do
			widget:SetAlpha(alpha)
		end
	end
end

local function AbbrClassification(classification)
  return (classification == "elite") and "E" or
  (classification == "rare") and "R" or
  (classification == "rareelite") and "R+" or
  (classification == "worldboss") and "B"
end

-- main
function KkthnxUIPlates:Load()
	do
		local eventHandler = CreateFrame("Frame", nil)

		-- set OnEvent handler
		eventHandler:SetScript("OnEvent", function(handler, ...)
			self:OnEvent(...)
		end)

		eventHandler:RegisterEvent("PLAYER_LOGIN")
	end
end

-- frame events
function KkthnxUIPlates:OnEvent(event, ...)
	local action = self[event]

	if (action) then
		action(self, event, ...)
	end
end

function KkthnxUIPlates:PLAYER_LOGIN()
	self:ConfigNamePlates()
	self:HookActionEvents()
end

-- configuration (credits to Ketho)
function KkthnxUIPlates:ConfigNamePlates()
	if (not InCombatLockdown()) then

		SetCVar("NamePlateVerticalScale", "1")
		SetCVar("NamePlateHorizontalScale", "1")

		-- enable class colors on friendly nameplates
		-- DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = false

		-- set the selected border color on friendly nameplates
		DefaultCompactNamePlateFriendlyFrameOptions.selectedBorderColor = CreateColor(1, 1, 1, .35)
		DefaultCompactNamePlateFriendlyFrameOptions.tankBorderColor = CreateColor(1, 1, 0, .6)
		DefaultCompactNamePlateFriendlyFrameOptions.defaultBorderColor = CreateColor(0, 0, 0, 1)

		-- disable the classification indicator on nameplates
		DefaultCompactNamePlateEnemyFrameOptions.showClassificationIndicator = false

		-- set the selected border color on enemy nameplates
		DefaultCompactNamePlateEnemyFrameOptions.selectedBorderColor = CreateColor(1, 1, 1, .55)
		DefaultCompactNamePlateEnemyFrameOptions.tankBorderColor = CreateColor(1, 1, 0, .6)
		DefaultCompactNamePlateEnemyFrameOptions.defaultBorderColor = CreateColor(0, 0, 0, 1)

		-- override any enabled cvar
		C_Timer.After(.1, function ()
			-- disable class colors on enemy nameplates
			DefaultCompactNamePlateEnemyFrameOptions.useClassColors = true
		end)

		-- always show names on nameplates
		for _, i in pairs({
			"Friendly",
			"Enemy"
		}) do
			for _, j in pairs({
				"displayNameWhenSelected",
				"displayNameByPlayerNameRules"
			}) do
				_G["DefaultCompactNamePlate"..i.."FrameOptions"][j] = false
			end
		end
	end
end

-- hooks
do
	local function Frame_SetupNamePlateInternal(frame, setupOptions, frameOptions)
		KkthnxUIPlates:SetupNamePlateInternal(frame, setupOptions, frameOptions)
	end

	local function Frame_UpdateHealthColor(frame)
		KkthnxUIPlates:UpdateHealthColor(frame)
	end

	local function Frame_UpdateName(frame)
		KkthnxUIPlates:UpdateName(frame)
	end

	local function Frame_ApplyAlpha(frame, alpha)
		KkthnxUIPlates:ApplyAlpha(frame, alpha)
	end

	local function Frame_OnEvent(event, ...)

	end

	function KkthnxUIPlates:HookActionEvents()
		hooksecurefunc("DefaultCompactNamePlateFrameSetupInternal", Frame_SetupNamePlateInternal)
		hooksecurefunc("CompactUnitFrame_UpdateHealthColor", Frame_UpdateHealthColor)
		hooksecurefunc("CompactUnitFrame_UpdateName", Frame_UpdateName)
		hooksecurefunc("CastingBarFrame_ApplyAlpha", Frame_ApplyAlpha)

		NamePlateDriverFrame:HookScript("OnEvent", function (frame, event, ...)
			if event == "NAME_PLATE_UNIT_ADDED" then
				local namePlateUnitToken = ...
				if (UnitIsUnit("player", namePlateUnitToken)) then
					local namePlateFrameBase = C_NamePlate.GetNamePlateForUnit(namePlateUnitToken)
					namePlateFrameBase.UnitFrame.healthBar:SetAlpha(1)
				end
			end
		end)
	end
end

function KkthnxUIPlates:SetCastingIcon()
	local Icon = self.Icon
	local Texture = Icon:GetTexture()
	local Backdrop = self.IconBackdrop
	local IconTexture = self.IconTexture
	
	if Texture then
		Backdrop:SetAlpha(1)
		IconTexture:SetTexture(Texture)
	else
		Backdrop:SetAlpha(0)
		Icon:SetTexture(nil)		
	end
end

function KkthnxUIPlates:SetupNamePlateInternal(frame, setupOptions, frameOptions)
	-- remove default health bar border
	frame.healthBar:SetStatusBarTexture(C.Media.Texture)
	frame.healthBar.background:ClearAllPoints()
	frame.healthBar.background:SetInside(0, 0)
	frame.healthBar:CreatePixelShadow()
	frame.healthBar.border:SetAlpha(0)

	frame.castBar:SetStatusBarTexture(C.Media.Texture)
	frame.castBar.background:ClearAllPoints()
	frame.castBar.background:SetInside(0, 0)
	frame.castBar:CreatePixelShadow()

	if frame.castBar.border then
		frame.castBar.border:SetAlpha(0)
	end

	frame.castBar.SetStatusBarTexture = function() end

	frame.castBar.IconBackdrop = CreateFrame("Frame", nil, frame.castBar)
	frame.castBar.IconBackdrop:SetSize(frame.castBar.Icon:GetSize() + 4, frame.castBar.Icon:GetSize() + 4)
	frame.castBar.IconBackdrop:SetPoint("TOPRIGHT", frame.healthBar, "TOPLEFT", -4, 0)
	frame.castBar.IconBackdrop:SetBackdrop({bgFile = C.Media.Blank})
	frame.castBar.IconBackdrop:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	frame.castBar.IconBackdrop:CreatePixelShadow()
	frame.castBar.IconBackdrop:SetFrameLevel(frame.castBar:GetFrameLevel() - 1 or 0)
	
	frame.castBar.Icon:SetParent(UIFrameHider)
	
	frame.castBar.IconTexture = frame.castBar:CreateTexture(nil, "OVERLAY")
	frame.castBar.IconTexture:SetTexCoord(.08, .92, .08, .92)
	frame.castBar.IconTexture:SetParent(frame.castBar.IconBackdrop)
	frame.castBar.IconTexture:SetAllPoints(frame.castBar.IconBackdrop)

	--frame.castBar.Text:SetFont(C.Media.Font, 9, "OUTLINE")
	
	frame.castBar.startCastColor.r, frame.castBar.startCastColor.g, frame.castBar.startCastColor.b = unpack(K.Colors.power["ENERGY"])
	frame.castBar.startChannelColor.r, frame.castBar.startChannelColor.g, frame.castBar.startChannelColor.b = unpack(K.Colors.power["MANA"])
	frame.castBar.failedCastColor.r, frame.castBar.failedCastColor.g, frame.castBar.failedCastColor.b = 1.0, 0.0, 0.0
	frame.castBar.nonInterruptibleColor.r, frame.castBar.nonInterruptibleColor.g, frame.castBar.nonInterruptibleColor.b = 0.7, 0.7, 0.7
	frame.castBar.finishedCastColor.r, frame.castBar.finishedCastColor.g, frame.castBar.finishedCastColor.b = 0.0, 1.0, 0.0
	
	frame.castBar:HookScript("OnShow", KkthnxUIPlates.SetCastingIcon)

	if ClassNameplateManaBarFrame then
		ClassNameplateManaBarFrame.Border:SetAlpha(0)
		ClassNameplateManaBarFrame:SetStatusBarTexture(C.Media.Texture)
		ClassNameplateManaBarFrame.ManaCostPredictionBar:SetTexture(C.Media.Texture)
		ClassNameplateManaBarFrame:SetBackdrop({bgFile = C.Media.Blank})
		ClassNameplateManaBarFrame:SetBackdropColor(.2, .2, .2)
		ClassNameplateManaBarFrame:CreatePixelShadow()
	end

	-- when using small nameplates move the text below the casting bar
	if (not setupOptions.useLargeNameFont) then
		frame.castBar.Text:ClearAllPoints()
		frame.castBar.Text:SetPoint("CENTER", frame.castBar, "CENTER", 0, -16)
		frame.castBar.Text:SetFont(C.Media.Font, 12, "OUTLINE")
	end

	frame.IsEdited = true
end

function KkthnxUIPlates:UpdateHealthColor(frame)
	if (frame:GetName() and string.find(frame:GetName(), "NamePlate")) then
        local r, g, b

        if not UnitIsConnected(frame.unit) then
            r, g, b = unpack(K.Colors.disconnected)
        else
            if UnitIsPlayer(frame.unit) then
                local class = select(2, UnitClass(frame.unit))

                r, g, b = unpack(K.Colors.class[class])
            else
                if (UnitIsFriend("player", frame.unit)) then
                    r, g, b = unpack(K.Colors.reaction[5])
                else
                    r, g, b = unpack(K.Colors.reaction[1])
                end
            end
        end

        frame.healthBar:SetStatusBarColor(r, g, b)
    end
end

function KkthnxUIPlates:UpdateName(frame)
	if (ShouldShowName(frame) and frame.optionTable.colorNameBySelection) then
		local unit = frame.displayedUnit
		local level = UnitLevel(frame.unit)
		local levelcolor = GetQuestDifficultyColor(level)
		local levelhexcolor = K.RGBToHex(levelcolor.r, levelcolor.g, levelcolor.b)
		local isfriend = UnitIsFriend("player", unit)
		local namecolor = isfriend and K.Colors.reaction[5] or K.Colors.reaction[1]
		local namehexcolor = K.RGBToHex(namecolor[1], namecolor[2], namecolor[3])

		local name = GetUnitName(frame.unit, false)
		local classification = UnitClassification(frame.unit)
		local classificationAbbr = AbbrClassification(classification)

		frame.name:SetShadowOffset(1.25, -1.25)

		if (UnitIsPlayer(frame.unit)) then
			local isPVP = UnitIsPVP(frame.unit)
			local faction = UnitFactionGroup(frame.unit)

			-- set unit player name
			frame.name:SetText((isPVP and faction) and ICON[faction].." "..namehexcolor ..Abbrev(name).." "..levelhexcolor..level.."" or namehexcolor.. Abbrev(name).." "..levelhexcolor..level.."")

			elseif (level == -1) then
			-- set boss name text
			frame.name:SetText(Abbrev(name).." ??")

			-- set boss name color
			if (frame.optionTable.considerSelectionInCombatAsHostile and IsOnThreatList(frame.displayedUnit)) then
				frame.name:SetVertexColor(1, 0, 0)
			elseif (UnitCanAttack("player", frame.unit)) then
				frame.name:SetVertexColor(1, .8, .8)
			else
				frame.name:SetVertexColor(.8, 1, .8)
			end
		else
			-- set name text
			frame.name:SetText(classificationAbbr and namehexcolor.. Abbrev(name).." "..levelhexcolor..level..classificationAbbr.."" or namehexcolor.. Abbrev(name).." "..levelhexcolor..level.."")

			-- set name color
			if (frame.optionTable.considerSelectionInCombatAsHostile and IsOnThreatList(frame.displayedUnit)) then
				frame.name:SetVertexColor(1, 0, 0)
			elseif (UnitCanAttack("player", frame.unit)) then
				frame.name:SetVertexColor(1, .8, .8)
			else
				frame.name:SetVertexColor(.8, 1, .8)
			end
		end

		if (UnitGUID("target") == nil) then
			frame.name:SetAlpha(1)
			frame.healthBar:SetAlpha(1)
			ApplyCastingBarAlpha(frame.castBar, 1)
		else
			local nameplate = C_NamePlate.GetNamePlateForUnit("target")
			if (nameplate) then
				frame.name:SetAlpha(NAME_FADE_VALUE)
				frame.healthBar:SetAlpha(BAR_FADE_VALUE)
				if (not UnitCanAttack("player", frame.unit)) then
					ApplyCastingBarAlpha(frame.castBar, BAR_FADE_VALUE)
				end

				nameplate.UnitFrame.name:SetAlpha(1)
				nameplate.UnitFrame.healthBar:SetAlpha(1)
				ApplyCastingBarAlpha(nameplate.UnitFrame.castBar, 1)
			else
				-- we have a target but unit has no nameplate
				-- keep casting bars faded to indicate we have a target
				frame.name:SetAlpha(NAME_FADE_VALUE)
				frame.healthBar:SetAlpha(BAR_FADE_VALUE)
				if (not UnitCanAttack("player", frame.unit)) then
					ApplyCastingBarAlpha(frame.castBar, BAR_FADE_VALUE)
				end
			end
		end

		if ( UnitIsFriend(frame.displayedUnit,"player") and not UnitCanAttack(frame.displayedUnit, "player") and HideFriendly) then
			frame.healthBar:Hide()
		else
			frame.healthBar:Show()
		end
	end
end

function KkthnxUIPlates:ApplyAlpha(frame, alpha)
	if (not UnitCanAttack("player", frame.unit)) then
		local parent = frame:GetParent()

		if (parent.healthBar) then
			local healthBarAlpha = parent.healthBar:GetAlpha()

			-- frame is faded
			if (healthBarAlpha == BAR_FADE_VALUE) then
				local value = (alpha * BAR_FADE_VALUE)
				ApplyCastingBarAlpha(frame, value)
			end
		end
	end
end

-- call
KkthnxUIPlates:Load()