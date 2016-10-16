local K, C, L = select(2, ...):unpack()
if IsAddOnLoaded("TidyPlates") or IsAddOnLoaded("Aloft") or IsAddOnLoaded("Kui_Nameplates") or IsAddOnLoaded("bdNameplates") then
	return
end

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
local wipe = wipe

-- constants
local CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local ICON = {
	Alliance = "\124TInterface/PVPFrame/PVP-Currency-Alliance:16\124t",
	Horde = "\124TInterface/PVPFrame/PVP-Currency-Horde:16\124t"
}

local NAME_FADE_VALUE = .6
local BAR_FADE_VALUE = .4

local NameplatePowerBarColor = NameplatePowerBarColor or unpack(K.Colors.power["MANA"])

-- helper functions
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

local function GetBorderBackdrop(size)
	return {
		bgFile = nil,
		edgeFile = C.Media.Glow,
		tile = false,
		edgeSize = size,
		insets = { left = 0, right = 0, top = 0, bottom = 0 }
	}
end

local function AbbrClassification(classification)
	return (classification == "elite") and "+" or
	(classification == "minus") and "-" or
	(classification == "rare") and "r" or
	(classification == "rareelite") and "r+"
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

		SetCVar("nameplateShowAll", 1)
		SetCVar("nameplateMaxAlpha", 0.5)
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("ShowClassColorInNameplate", 1)
		SetCVar("nameplateOtherTopInset", 0.08)
		SetCVar("nameplateOtherBottomInset", -1)
		SetCVar("nameplateMinScale", 1)
		SetCVar("namePlateMaxScale", 1)
		SetCVar("nameplateMinScaleDistance", 10)
		SetCVar("nameplateMaxDistance", 40)
		SetCVar("NamePlateHorizontalScale", 1)
		SetCVar("NamePlateVerticalScale", 1)

		-- enable class colors on friendly nameplates
		DefaultCompactNamePlateFriendlyFrameOptions.useClassColors = true

		-- set the selected border color on friendly nameplates
		DefaultCompactNamePlateFriendlyFrameOptions.selectedBorderColor = CreateColor(0, 0, 0, 1)
		DefaultCompactNamePlateFriendlyFrameOptions.tankBorderColor = CreateColor(0, 0, 0, 1)
		DefaultCompactNamePlateFriendlyFrameOptions.defaultBorderColor = CreateColor(0, 0, 0, 1)

		-- disable the classification indicator on nameplates
		DefaultCompactNamePlateEnemyFrameOptions.showClassificationIndicator = false

		-- set the selected border color on enemy nameplates
		DefaultCompactNamePlateEnemyFrameOptions.selectedBorderColor = CreateColor(0, 0, 0, 1)
		DefaultCompactNamePlateEnemyFrameOptions.tankBorderColor = CreateColor(0, 0, 0, 1)
		DefaultCompactNamePlateEnemyFrameOptions.defaultBorderColor = CreateColor(0, 0, 0, 1)

		-- override any enabled cvar
		C_Timer.After(.1, function ()
			-- disable class colors on enemy nameplates
			DefaultCompactNamePlateEnemyFrameOptions.useClassColors = false
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

		-- hooksecurefunc(ClassNameplateBar, "TurnOn", function () print("to") end)
		ClassNameplateManaBarFrame:HookScript("OnEvent", function (frame, event, ...)
			if (event == "PLAYER_ENTERING_WORLD") then
				frame:SetStatusBarTexture(C.Media.Texture, "BACKGROUND", 1)
			end
			frame:SetAlpha(1)
		end)
	end
end

function KkthnxUIPlates:SetupNamePlateInternal(frame, setupOptions, frameOptions)
	-- set bar color and textures for health bar
	frame.healthBar.background:SetTexture(C.Media.Blank)
	frame.healthBar.background:SetVertexColor(0, 0, 0, .5)
	frame.healthBar:SetStatusBarTexture(C.Media.Texture)

	-- remove default health bar border
	frame.healthBar.border:Hide()
	for _, texture in pairs(frame.healthBar.border.Textures) do
		texture:SetTexture(nil)
	end
	wipe(frame.healthBar.border.Textures)

	-- create a new border around the health bar
	if (not frame.healthBar.barBorder) then
		frame.healthBar.barBorder = self:CreateBorder(frame.healthBar)
	end

	-- and casting bar
	frame.castBar.background:SetTexture(C.Media.Blank)
	frame.castBar.background:SetVertexColor(0, 0, 0, .5)
	frame.castBar:SetStatusBarTexture(C.Media.Texture)

	-- create a border just like the one around the health bar
	if (not frame.castBar.barBorder) then
		frame.castBar.barBorder = self:CreateBorder(frame.castBar)
	end

	-- adjust cast bar icon size and position
	frame.castBar.Icon:SetSize(17, 17)
	frame.castBar.Icon:ClearAllPoints()
	frame.castBar.Icon:SetPoint("RIGHT", frame.castBar, "LEFT", -4, 3)

	frame.castBar.IconBorder = frame.castBar:CreateTexture("$parentIconBorder", "OVERLAY", nil, 2)
	--castBar.IconBorder:SetTexture(config.IconTextures.Normal)
	--castBar.IconBorder:SetVertexColor(unpack(config.Colors.Border))
	frame.castBar.IconBorder:SetPoint("TOPRIGHT", frame.castBar.Icon, 2, 2)
	frame.castBar.IconBorder:SetPoint("BOTTOMLEFT", frame.castBar.Icon, -2, -2)

	if (not frame.castBar.barBorder) then
		frame.castBar.IconBorder.barBorder = self:CreateBorder(frame.castBar.IconBorder)
	end

	-- adjust cast bar shield
	frame.castBar.BorderShield:SetSize(17, 17)
	frame.castBar.BorderShield:ClearAllPoints()
	frame.castBar.BorderShield:SetPoint("RIGHT", frame.castBar, "LEFT", -4, 3)

	-- cut the default icon border embedded in icons
	frame.castBar.Icon:SetTexCoord(.1, .9, .1, .9)

	-- when using small nameplates move the text below the casting bar
	if (not setupOptions.useLargeNameFont) then
		frame.castBar.Text:ClearAllPoints()
		frame.castBar.Text:SetPoint("CENTER", frame.castBar, "CENTER", 0, -16)
		frame.castBar.Text:SetFont(C.Media.Font, 12, "OUTLINE")
	end
end

function KkthnxUIPlates:UpdateHealthColor(frame)
	if (UnitExists(frame.displayedUnit) and IsTanking(frame.displayedUnit)) then
		-- color of name plate of unit targeting us
		local r, g, b = 1, .3, 1
		if (CompactUnitFrame_IsTapDenied(frame)) then
			r, g, b = r / 2, g / 2, b / 2
		end

		if (r ~= frame.healthBar.r or g ~= frame.healthBar.g or b ~= frame.healthBar.b) then
			frame.healthBar:SetStatusBarColor(r, g, b)
			frame.healthBar.r, frame.healthBar.g, frame.healthBar.b = r, g, b
		end
	end
end

function KkthnxUIPlates:UpdateName(frame)
	if (ShouldShowName(frame) and frame.optionTable.colorNameBySelection) then
		local level = UnitLevel(frame.unit)
		local name = GetUnitName(frame.unit, false)
		local classification = UnitClassification(frame.unit)
		local classificationAbbr = AbbrClassification(classification)

		frame.name:SetShadowOffset(1.25, -1.25)

		if (UnitIsPlayer(frame.unit)) then
			local isPVP = UnitIsPVP(frame.unit)
			local faction = UnitFactionGroup(frame.unit)

			-- set unit player name
			if (InCombat(frame.unit)) then
				-- unit player in combat
				frame.name:SetText((isPVP and faction) and ICON[faction].." "..name.." ("..level..") **" or name.." ("..level..") **")
			else
				-- unit player out of combat
				frame.name:SetText((isPVP and faction) and ICON[faction].." "..name.." ("..level..")" or name.." ("..level..")")
			end

			-- set unit player name color
			if (UnitIsEnemy("player", frame.unit)) then
				local _, class = UnitClass(frame.unit)
				local color = K.Colors.class[class]

				-- color enemy players name with class color
				frame.name:SetVertexColor(color[1], color[2], color[3])
			else
				-- color friendly players name white
				frame.name:SetVertexColor(.9, .9, .9)
			end
		elseif (level == -1) then
			-- set boss name text
			if (InCombat(frame.unit)) then
				frame.name:SetText(name.." (??) **")
			else
				frame.name:SetText(name.." (??)")
			end

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
			if (InCombat(frame.unit)) then
				frame.name:SetText(classificationAbbr and name.." ("..level..classificationAbbr..") **" or name.." ("..level..") **")
			else
				frame.name:SetText(classificationAbbr and name.." ("..level..classificationAbbr..")" or name.." ("..level..")")
			end

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

		local HideFriendly = true
		if ( UnitIsFriend(frame.displayedUnit,"player") and not UnitCanAttack(frame.displayedUnit,"player") and HideFriendly ) then
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

function KkthnxUIPlates:CreateBorder(frame)
	local textures = {}

	local layers = 3
	local size = 2

	for i = 1, layers do
		local backdrop = GetBorderBackdrop(size)

		local texture = CreateFrame("Frame", nil, frame)
		texture:SetBackdrop(backdrop)
		texture:SetBackdropColor(unpack(C.Media.Backdrop_Color)) -- Unsure about this.
		texture:SetPoint("TOPRIGHT", size, size)
		texture:SetPoint("BOTTOMLEFT", -size, -size)
		texture:SetFrameStrata("LOW")
		texture:SetBackdropBorderColor(0, 0, 0, (1 / layers))

		size = size

		textures[#textures + 1] = texture
	end

	return textures
end

-- call
KkthnxUIPlates:Load()