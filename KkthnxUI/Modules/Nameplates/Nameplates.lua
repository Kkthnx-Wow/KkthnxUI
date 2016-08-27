local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local unpack = unpack
local gsub = string.gsub

local Plates = CreateFrame("Frame", nil, WorldFrame)
local Noop = function() end

function Plates:RegisterOptions()
	Plates.Options = {}

	Plates.Options.Friendly = {
		displaySelectionHighlight = true,
		displayAggroHighlight = false,
		displayName = true,
		fadeOutOfRange = false,
		--displayStatusText = true,
		displayHealPrediction = false,
		--displayDispelDebuffs = true,
		colorNameBySelection = true,
		colorNameWithExtendedColors = true,
		colorHealthWithExtendedColors = true,
		colorHealthBySelection = true,
		considerSelectionInCombatAsHostile = true,
		smoothHealthUpdates = false,
		displayNameWhenSelected = false,
		displayNameByPlayerNameRules = false,

		selectedBorderColor = CreateColor(1, 1, 1, .35),
		tankBorderColor = CreateColor(1, 1, 0, .6),
		defaultBorderColor = CreateColor(0, 0, 0, 1),
	}

	Plates.Options.Enemy = {
		displaySelectionHighlight = true,
		displayAggroHighlight = false,
		playLoseAggroHighlight = true,
		displayName = true,
		fadeOutOfRange = false,
		displayHealPrediction = false,
		colorNameBySelection = true,
		colorHealthBySelection = true,
		considerSelectionInCombatAsHostile = true,
		smoothHealthUpdates = false,
		displayNameWhenSelected = false,
		displayNameByPlayerNameRules = false,
		greyOutWhenTapDenied = true,

		selectedBorderColor = CreateColor(1, 1, 1, .55),
		tankBorderColor = CreateColor(1, 1, 0, .6),
		defaultBorderColor = CreateColor(0, 0, 0, 1),
	}

	Plates.Options.Player = {
		displaySelectionHighlight = false,
		displayAggroHighlight = false,
		displayName = false,
		fadeOutOfRange = false,
		displayHealPrediction = false,
		colorNameBySelection = true,
		smoothHealthUpdates = false,
		displayNameWhenSelected = false,
		hideCastbar = true,
		healthBarColorOverride = CreateColor(0, 1, 0),

		defaultBorderColor = CreateColor(0, 0, 0, 1),
	}

	Plates.Options.Size = {
		healthBarHeight = C.Nameplate.Height,
		healthBarAlpha = 1,
		castBarHeight = C.Nameplate.CastHeight,
		castBarFontHeight = 9,
		useLargeNameFont = false,

		castBarShieldWidth = 10,
		castBarShieldHeight = 12,

		castIconWidth = C.Nameplate.Height + C.Nameplate.CastHeight + 2,
		castIconHeight = C.Nameplate.Height + C.Nameplate.CastHeight + 2,
	}

	Plates.Options.PlayerSize = {
		healthBarHeight = C.Nameplate.Height,
		healthBarAlpha = 1,
		castBarHeight = C.Nameplate.CastHeight,
		castBarFontHeight = 10,
		useLargeNameFont = false,

		castBarShieldWidth = 10,
		castBarShieldHeight = 12,

		castIconWidth = 10,
		castIconHeight = 10,
	}

	Plates.Options.CastBarColors = {
		StartNormal = BETTER_POWERBAR_COLORS["ENERGY"],
		StartChannel = BETTER_POWERBAR_COLORS["MANA"],
		Success = {0.0, 1.0, 0.0},
		NonInterrupt = {0.7, 0.7, 0.7},
		Failed = {1.0, 0.0, 0.0},
	}
end

function Plates:GetClassification(unit)
	local CreatureClassification = UnitClassification(unit)
	local String = ""

	if CreatureClassification == "elite" then
		String = "[E]"
	elseif CreatureClassification == "rare" then
		String = "[R]"
	elseif CreatureClassification == "rareelite" then
		String = "[R+]"
	elseif CreatureClassification == "worldboss" then
		String = "[B]"
	end

	return String
end

function Plates:SetName()
	Text = self:GetText()

	if Text then
		local Unit = self:GetParent().unit
		local Class = select(2, UnitClass(Unit))
		local Level = UnitLevel(Unit)
		local LevelColor = GetQuestDifficultyColor(Level)
		local LevelHexColor = K.RGBToHex(LevelColor.r, LevelColor.g, LevelColor.b)
		local IsFriend = UnitIsFriend("player", Unit)
		local NameColor = IsFriend and BETTER_REACTION_COLORS[5] or BETTER_REACTION_COLORS[1]
		local NameHexColor = K.RGBToHex(NameColor[1], NameColor[2], NameColor[3])
		local Elite = Plates:GetClassification(Unit)

		if Level < 0 then
			Level = ""
		else
			Level = "[".. Level.. "]"
		end

		self:SetText("|cffff0000".. Elite .."|r" .. LevelHexColor .. Level .."|r "..NameHexColor.. Text .."|r")
	end
end

function Plates:ColorHealth()
	if (self:GetName() and string.find(self:GetName(), "NamePlate")) then
		local r, g, b

		if not UnitIsConnected(self.unit) then
			r, g, b = unpack(BETTER_DISCONNECTED_COLORS)
		else
			if UnitIsPlayer(self.unit) then
				local Class = select(2, UnitClass(self.unit))

				r, g, b = unpack(BETTER_RAID_CLASS_COLORS[Class])
			else
				if (UnitIsFriend("player", self.unit)) then
					r, g, b = unpack(BETTER_REACTION_COLORS[5])
				else
					local Reaction = UnitReaction("player", self.unit)

					r, g, b = unpack(BETTER_REACTION_COLORS[Reaction])
				end
			end
		end

		self.healthBar:SetStatusBarColor(r, g, b)
	end
end

function Plates:SetCastingIcon()
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

function Plates:SetupPlate(options)
	if self.IsEdited then
		return
	end

	local HealthBar = self.healthBar
	local Highlight = self.selectionHighlight
	local Aggro = self.aggroHighlight
	local CastBar = self.castBar
	local CastBarIcon = self.castBar.Icon
	local Shield = self.castBar.BorderShield
	local Flash = self.castBar.Flash
	local Spark = self.castBar.Spark
	local Name = self.name
	local Texture = C.Media.Texture
	local Font = C.Media.Font
	local FontName, FontSize, FontFlags = C.Media.Font, C.Media.Font_Size, C.Media.Font_Style

	-- HEALTHBAR
	HealthBar:SetStatusBarTexture(Texture)
	HealthBar.background:ClearAllPoints()
	HealthBar.background:SetInside(0, 0)
	HealthBar:CreatePixelShadow()
	HealthBar.border:SetAlpha(0)

	-- CASTBAR
	CastBar:SetStatusBarTexture(Texture)
	CastBar.background:ClearAllPoints()
	CastBar.background:SetInside(0, 0)
	CastBar:CreatePixelShadow()

	if CastBar.border then
		CastBar.border:SetAlpha(0)
	end

	CastBar.SetStatusBarTexture = function() end

	CastBar.IconBackdrop = CreateFrame("Frame", nil, CastBar)
	CastBar.IconBackdrop:SetSize(CastBar.Icon:GetSize())
	CastBar.IconBackdrop:SetPoint("TOPRIGHT", HealthBar, "TOPLEFT", -4, 0)
	CastBar.IconBackdrop:SetBackdrop({bgFile = C.Media.Blank})
	CastBar.IconBackdrop:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	CastBar.IconBackdrop:CreatePixelShadow()
	CastBar.IconBackdrop:SetFrameLevel(CastBar:GetFrameLevel() - 1 or 0)

	CastBar.Icon:SetParent(KkthnxUIUIHider)

	CastBar.IconTexture = CastBar:CreateTexture(nil, "OVERLAY")
	CastBar.IconTexture:SetTexCoord(.08, .92, .08, .92)
	CastBar.IconTexture:SetParent(CastBar.IconBackdrop)
	CastBar.IconTexture:SetAllPoints(CastBar.IconBackdrop)

	CastBar.Text:SetFont(FontName, 9, "")

	CastBar.startCastColor.r, CastBar.startCastColor.g, CastBar.startCastColor.b = unpack(Plates.Options.CastBarColors.StartNormal)
	CastBar.startChannelColor.r, CastBar.startChannelColor.g, CastBar.startChannelColor.b = unpack(Plates.Options.CastBarColors.StartChannel)
	CastBar.failedCastColor.r, CastBar.failedCastColor.g, CastBar.failedCastColor.b = unpack(Plates.Options.CastBarColors.Failed)
	CastBar.nonInterruptibleColor.r, CastBar.nonInterruptibleColor.g, CastBar.nonInterruptibleColor.b = unpack(Plates.Options.CastBarColors.NonInterrupt)
	CastBar.finishedCastColor.r, CastBar.finishedCastColor.g, CastBar.finishedCastColor.b = unpack(Plates.Options.CastBarColors.Success)

	CastBar:HookScript("OnShow", Plates.SetCastingIcon)

	-- UNIT NAME
	Name:SetFont(FontName, 9, "")
	hooksecurefunc(Name, "Show", Plates.SetName)

	-- WILL DO A BETTER VISUAL FOR THIS LATER
	Highlight:Kill()
	Shield:Kill()
	Aggro:Kill()
	Flash:Kill()
	Spark:Kill()

	self.IsEdited = true
end

function Plates:Enable()
	local Enabled = C.Nameplate.Enable

	if not Enabled then
		return
	end

	self:RegisterOptions()

	DefaultCompactNamePlateFriendlyFrameOptions = Plates.Options.Friendly
	DefaultCompactNamePlateEnemyFrameOptions = Plates.Options.Enemy
	DefaultCompactNamePlatePlayerFrameOptions = Plates.Options.Player
	DefaultCompactNamePlateFrameSetUpOptions = Plates.Options.Size
	DefaultCompactNamePlatePlayerFrameSetUpOptions = Plates.Options.PlayerSize

	if ClassNameplateManaBarFrame then
		ClassNameplateManaBarFrame.Border:SetAlpha(0)
		ClassNameplateManaBarFrame:SetStatusBarTexture(C.Media.Texture)
		ClassNameplateManaBarFrame.ManaCostPredictionBar:SetTexture(C.Media.Texture)
		ClassNameplateManaBarFrame:SetBackdrop({bgFile = C.Media.Blank})
		ClassNameplateManaBarFrame:SetBackdropColor(unpack(C.Media.Backdrop_Color))
		ClassNameplateManaBarFrame:CreatePixelShadow()
	end

	hooksecurefunc("DefaultCompactNamePlateFrameSetupInternal", self.SetupPlate)
	hooksecurefunc("CompactUnitFrame_UpdateHealthColor", self.ColorHealth)

	-- DISABLE BLIZZARD RESCALE
	NamePlateDriverFrame.UpdateNamePlateOptions = Noop

	-- MAKE SURE NAMEPLATES ARE ALWAYS SCALED AT 1
	SetCVar("NamePlateVerticalScale", "1")
	SetCVar("NamePlateHorizontalScale", "1")

	-- HIDE THE OPTION TO RESCALE, BECAUSE WE WILL DO IT FROM SETTINGS.
	InterfaceOptionsNamesPanelUnitNameplatesMakeLarger:Hide()

	-- SET THE WIDTH OF NAMEPLATE
	C_NamePlate.SetNamePlateOtherSize(C.Nameplate.Width, 45)
end

Plates:Enable()