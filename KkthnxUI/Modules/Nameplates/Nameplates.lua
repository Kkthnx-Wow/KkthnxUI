local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local unpack = unpack
local Plates = CreateFrame("Frame", nil, WorldFrame)
local Noop = function() end

function Plates:GetClassification(unit)
	local CreatureClassification = UnitClassification(unit)
	local String = ""

	if CreatureClassification == "elite" then
		String = "E"
	elseif CreatureClassification == "rare" then
		String = "R"
	elseif CreatureClassification == "rareelite" then
		String = "R+"
	elseif CreatureClassification == "worldboss" then
		String = "B"
	end

	return String
end

function Plates:SetName()
	local Text = self:GetText()
	local NewName = GetUnitName(self:GetParent().unit, C.Nameplate.Realm) or UNKNOWN

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

		if Level < 0 then Level = " |cffff0000??|r" else Level = Level end

		if (C.Nameplate.Realm) then
			self:SetText("|cffff0000".. Elite .."|r" .. LevelHexColor .. Level .."|r "..NameHexColor.. Text .."|r")
		else
			self:SetText("|cffff0000".. Elite .."|r" .. LevelHexColor .. Level .."|r "..NameHexColor.. NewName .."|r")
		end
	end
end

--[[
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
--]]

function Plates:ColorHealth()
	if (self:GetName() and string.find(self:GetName(), "NamePlate")) then
        local r, g, b = self.healthBar:GetStatusBarColor()

		self.isTapped = false

		if r + b + b == 1.59 then -- tapped
			r, g, b = .6, .6, .6
			self.isFriendly = false
			self.isTapped = true
		elseif g + b == 0 then
			r, g, b = .87, .37, .37 -- hostile
			self.isFriendly = false
		elseif r + b == 0 then
			r, g, b = .31, .45, .63 -- player
			self.isFriendly = true
		elseif r + g > 1.95 then
			r, g, b = .85, .77, .36 -- neutral
			self.isFriendly = false
		elseif r + g == 0 then
			r, g, b = .29, .67, .30 -- good
			self.isFriendly = true
		else
			self.isFriendly = false
		end

		if C.Nameplate.ClassColor then
			if UnitIsPlayer(self.unit) then
				local Class = select(2, UnitClass(self.unit))
				r, g, b = unpack(BETTER_RAID_CLASS_COLORS[Class])
			end
		end
		self.healthBar:SetStatusBarColor(r, g, b)
    end

	-- (3 = securely tanking, 2 = insecurely tanking, 1 = not tanking but higher threat than tank, 0 = not tanking and lower threat than tank)
	local isTanking, threatStatus = UnitDetailedThreatSituation("player", self.displayedUnit)
	if C.Nameplate.EnhanceThreat then
		if K.Role == "Tank" then
			if isTanking and threatStatus then
				if (threatStatus and threatStatus == 3) then
					self.healthBar.barTexture:SetVertexColor(.29,  .69, .3) -- good
				elseif (threatStatus and threatStatus == 2) then
					self.healthBar.barTexture:SetVertexColor(.86, .77, .36) -- transition
				elseif (threatStatus and threatStatus == 1) then
					self.healthBar.barTexture:SetVertexColor(.5, 0, .5) -- offtank
				elseif (threatStatus and threatStatus == 0) then
					self.healthBar.barTexture:SetVertexColor(.78, .25, .25) -- bad
				end
			end
		else
			if isTanking and threatStatus then
				self.healthBar.barTexture:SetVertexColor(.78, .25, .25) -- bad
				self:GetParent().playerHasAggro = true
			else
				if (threatStatus and threatStatus == 3) then
					self.healthBar.barTexture:SetVertexColor(.78, .25, .25) -- bad
					self:GetParent().playerHasAggro = true
				elseif (threatStatus and threatStatus == 2) then
					self.healthBar.barTexture:SetVertexColor(.86, .77, .36) -- transition
					self:GetParent().playerHasAggro = true
				elseif (threatStatus and threatStatus == 1) then
					self.healthBar.barTexture:SetVertexColor(.5, 0, .5) -- transition
					self:GetParent().playerHasAggro = false
				elseif (threatStatus and threatStatus == 0) then
					self.healthBar.barTexture:SetVertexColor(.29,  .69, .3) -- good
					self:GetParent().playerHasAggro = false
				end
			end
		end
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

	CastBar.Icon:SetParent(UIFrameHider)

	CastBar.IconTexture = CastBar:CreateTexture(nil, "OVERLAY")
	CastBar.IconTexture:SetTexCoord(.08, .92, .08, .92)
	CastBar.IconTexture:SetParent(CastBar.IconBackdrop)
	CastBar.IconTexture:SetAllPoints(CastBar.IconBackdrop)

	CastBar.Text:SetFont(FontName, FontSize * K.NoScaleMult, "OUTLINE")

	CastBar.startCastColor.r, CastBar.startCastColor.g, CastBar.startCastColor.b = unpack(Plates.Options.CastBarColors.StartNormal)
	CastBar.startChannelColor.r, CastBar.startChannelColor.g, CastBar.startChannelColor.b = unpack(Plates.Options.CastBarColors.StartChannel)
	CastBar.failedCastColor.r, CastBar.failedCastColor.g, CastBar.failedCastColor.b = unpack(Plates.Options.CastBarColors.Failed)
	CastBar.nonInterruptibleColor.r, CastBar.nonInterruptibleColor.g, CastBar.nonInterruptibleColor.b = unpack(Plates.Options.CastBarColors.NonInterrupt)
	CastBar.finishedCastColor.r, CastBar.finishedCastColor.g, CastBar.finishedCastColor.b = unpack(Plates.Options.CastBarColors.Success)

	CastBar:HookScript("OnShow", Plates.SetCastingIcon)

	-- UNIT NAME
	Name:SetFont(FontName, FontSize * K.NoScaleMult, "")
	Name:SetShadowColor(0, 0, 0)
	Name:SetShadowOffset(1.25, -1.25)
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

K.NamePlates = Plates

function Plates:OnEvent(event)
	if (event == "PLAYER_LOGIN") then
		K.NamePlates:Enable()
	end
end

Plates:RegisterEvent("PLAYER_LOGIN")
Plates:SetScript("OnEvent", Plates.OnEvent)