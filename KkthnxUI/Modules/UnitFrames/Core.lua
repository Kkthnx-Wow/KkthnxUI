local K, C = unpack(select(2, ...))
local Module = K:NewModule("Unitframes", "AceEvent-3.0")

local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Core.lua code!")
	return
end

local _G = _G
local string_format = string.format
local table_insert = table.insert
local unpack = unpack
local pairs = pairs
local select = _G.select

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES or 5
local PlaySound = _G.PlaySound
local PlaySoundKitID = _G.PlaySoundKitID
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local SOUNDKIT = _G.SOUNDKIT
local UIParent = _G.UIParent
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitDetailedThreatSituation = _G.UnitDetailedThreatSituation
local UnitExists = _G.UnitExists
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsUnit = _G.UnitIsUnit
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitReaction = _G.UnitReaction

local Movers = K["Movers"]

Module.RaidBuffsTrackingPosition = {
	TOPLEFT = {6, 1},
	TOPRIGHT = {-6, 1},
	BOTTOMLEFT = {6, 1},
	BOTTOMRIGHT = {-6, 1},
	LEFT = {6, 1},
	RIGHT = {-6, 1},
	TOP = {0, 0},
	BOTTOM = {0, 0}
}

function Module:UpdateClassPortraits(unit)
    local _, unitClass = UnitClass(unit)
	local isPlayer = unitClass and UnitIsPlayer(unit)

	local PValue = C["Party"].PortraitStyle.Value
	local BValue = C["Boss"].PortraitStyle.Value
	local UFValue = C["Unitframe"].PortraitStyle.Value

    if isPlayer and PValue == "ClassPortraits" or BValue == "ClassPortraits" or UFValue == "ClassPortraits" then
        self:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
        self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
    elseif isPlayer and PValue == "NewClassPortraits" or BValue == "NewClassPortraits" or UFValue == "NewClassPortraits" then
        self:SetTexture(C["Media"].NewClassPortraits)
        self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
    else
        self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
    end
end

function Module:ThreatPlate(forced)
	if C["Nameplates"].Threat ~= true then
		return
	end

	if UnitIsPlayer(self.unit) then
		return
	end

	local combat = UnitAffectingCombat("player")
	if (not UnitPlayerControlled(self.unit) and UnitIsTapDenied(self.unit)) then
		self.Health:SetStatusBarColor(0.6, 0.6, 0.6)
	elseif combat then
		local _, threatStatus = UnitDetailedThreatSituation("player", self.unit)
		if (threatStatus and threatStatus > 0) and (IsInGroup() or UnitExists("pet")) then
			if (threatStatus == 3) then
				if (K.GetPlayerRole() == "TANK") then
					self.Health:SetStatusBarColor(C["Nameplates"].GoodColor[1], C["Nameplates"].GoodColor[2], C["Nameplates"].GoodColor[3])
				else
					self.Health:SetStatusBarColor(C["Nameplates"].BadColor[1], C["Nameplates"].BadColor[2], C["Nameplates"].BadColor[3])
				end
			elseif (threatStatus == 2) then
				self.Health:SetStatusBarColor(C["Nameplates"].NearColor[1], C["Nameplates"].NearColor[2], C["Nameplates"].NearColor[3])
			elseif (threatStatus == 1) then
				self.Health:SetStatusBarColor(C["Nameplates"].NearColor[1], C["Nameplates"].NearColor[2], C["Nameplates"].NearColor[3])
			elseif (threatStatus == 0) then
				if (K.GetPlayerRole() == "TANK") then
					self.Health:SetStatusBarColor(C["Nameplates"].BadColor[1], C["Nameplates"].BadColor[2], C["Nameplates"].BadColor[3])
					if IsInGroup() or IsInRaid() then
						for i = 1, GetNumGroupMembers() do
							if UnitExists("raid" .. i) and not UnitIsUnit("raid" .. i, "player") then
								local isTanking = UnitDetailedThreatSituation("raid" .. i, self.unit)
								if isTanking and UnitGroupRolesAssigned("raid" .. i) == "TANK" then
									self.Health:SetStatusBarColor(C["Nameplates"].OffTankColor[1], C["Nameplates"].OffTankColor[2], C["Nameplates"].OffTankColor[3])
								end
							end
						end
					end
				else
					self.Health:SetStatusBarColor(C["Nameplates"].GoodColor[1], C["Nameplates"].GoodColor[2], C["Nameplates"].GoodColor[3])
				end
			end
		end
	end

	if (not forced and self.Health.ForceUpdate) then
		self.Health:ForceUpdate()
	end
end

function Module:HighlightPlate()
	local Shadow = self.Health.Shadow

	if UnitIsPlayer(self.unit) then
		return
	end

	local unit = self.unit
	if (UnitIsUnit("target", self.unit)) then
		local reaction = UnitReaction(unit, "player")
		if UnitIsPlayer(unit) then
			local _, class = UnitClass(unit)
			if class then
				local color = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
				Shadow:SetBackdropBorderColor(color.r, color.g, color.b)
			else
				Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
			end
		elseif reaction then
			local color = FACTION_BAR_COLORS[reaction]
			Shadow:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
		end
	else
		Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
	end
end

function Module:CustomCastTimeText(duration)
	local Value = string_format("%.1f / %.1f", self.channeling and duration or self.max - duration, self.max)

	self.Time:SetText(Value)
end

function Module:CustomCastDelayText(duration)
	local Value = string_format("%.1f |cffaf5050%s %.1f|r", self.channeling and duration or self.max - duration, self.channeling and "- " or "+", self.delay)
	self.Time:SetText(Value)
end

function Module:CheckInterrupt(unit)
	if (unit == "vehicle") then
		unit = "player"
	end

	local colors = K.Colors
	local r, g, b = colors.status.castColor[1], colors.status.castColor[2], colors.status.castColor[3]

	local t
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if (t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.notInterruptible and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
end

function Module:CheckCast(unit)
	Module.CheckInterrupt(self, unit)
end

function Module:CheckChannel(unit)
	Module.CheckInterrupt(self, unit)
end

function Module:CreateAuraTimer(elapsed)
	if (self.TimeLeft) then
		self.Elapsed = (self.Elapsed or 0) + elapsed

		if self.Elapsed >= 0.1 then
			if not self.First then
				self.TimeLeft = self.TimeLeft - self.Elapsed
			else
				self.TimeLeft = self.TimeLeft - GetTime()
				self.First = false
			end

			if self.TimeLeft > 0 then
				local Time = K.FormatTime(self.TimeLeft)
				self.Remaining:SetText(Time)

				if self.TimeLeft <= 5 then
					self.Remaining:SetTextColor(1, 0, 0)
				else
					self.Remaining:SetTextColor(1, 1, 1)
				end
			else
				self.Remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.Elapsed = 0
		end
	end
end

function Module:PostCreateAura(button)

	if button:GetName():match("NamePlate") and C["Nameplates"].Enable then
		button:CreateShadow()
	else
		button.Backgrounds = button:CreateTexture(nil, "BACKGROUND", -1)
		button.Backgrounds:SetAllPoints()
		button.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		K.CreateBorder(button)
	end

	button.Remaining = button.cd:CreateFontString(nil, "OVERLAY")
	button.Remaining:SetFont(C["Media"].Font, self.size * 0.46, "THINOUTLINE")
	button.Remaining:SetPoint("CENTER", 1, 0)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", 1, -1)
	button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
	button.cd:SetHideCountdownNumbers(true)

	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	button.icon:SetDrawLayer("ARTWORK")

	button.count:SetPoint("BOTTOMRIGHT", 1, 1)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(C["Media"].Font, self.size * 0.46, "THINOUTLINE")
	button.count:SetTextColor(0.84, 0.75, 0.65)

	button.OverlayFrame = CreateFrame("Frame", nil, button, nil)
	button.OverlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
	button.overlay:SetParent(button.OverlayFrame)
	button.count:SetParent(button.OverlayFrame)
	button.Remaining:SetParent(button.OverlayFrame)

	if not button:GetName():match("NamePlate") then
		button.Animation = button:CreateAnimationGroup()
		button.Animation:SetLooping("BOUNCE")

		button.Animation.FadeOut = button.Animation:CreateAnimation("Alpha")
		button.Animation.FadeOut:SetFromAlpha(1)
		button.Animation.FadeOut:SetToAlpha(0)
		button.Animation.FadeOut:SetDuration(.6)
		button.Animation.FadeOut:SetSmoothing("IN_OUT")
	end
end

function Module:PostUpdateAura(unit, button, index)
	local _, _, _, _, DType, Duration, ExpirationTime, _, IsStealable = UnitAura(unit, index, button.filter)

	if button then
		if (button.filter == "HARMFUL") then
			if (not UnitIsFriend("player", unit) and not button.isPlayer) then
				button.icon:SetDesaturated(true)
				button:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
			else
				local color = _G.DebuffTypeColor[DType] or _G.DebuffTypeColor.none
				button.icon:SetDesaturated(false)
				button:SetBackdropBorderColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)
			end
		else
			if button.Animation then
				if (IsStealable or DType == "Magic") and not UnitIsFriend("player", unit) and not button.Animation.Playing then
					button.Animation:Play()
					button.Animation.Playing = true
				else
					button.Animation:Stop()
					button.Animation.Playing = false
				end
			end
		end

		if button.Remaining then
			if Duration and Duration > 0 then
				button.Remaining:Show()
			else
				button.Remaining:Hide()
			end

			button:SetScript("OnUpdate", Module.CreateAuraTimer)
		end

		button.Duration = Duration
		button.TimeLeft = ExpirationTime
		button.First = true
	end
end

function Module:CreateAuraWatchIcon(icon)
	icon:CreateShadow()
	icon.icon:SetPoint("TOPLEFT", 1, -1)
	icon.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon.icon:SetDrawLayer("ARTWORK")

	if (icon.cd) then
		icon.cd:SetHideCountdownNumbers(true)
		icon.cd:SetReverse(true)
	end

	icon.overlay:SetTexture()
end

function Module:CreateAuraWatch(frame)
	local buffs = {}
	local Class = select(2, UnitClass("player"))

	local Auras = CreateFrame("Frame", nil, frame)
	Auras:SetPoint("TOPLEFT", frame.Health, 2, -2)
	Auras:SetPoint("BOTTOMRIGHT", frame.Health, -2, 2)
	Auras.presentAlpha = 1
	Auras.missingAlpha = 0
	Auras.icons = {}
	Auras.PostCreateIcon = Module.CreateAuraWatchIcon
	Auras.strictMatching = true

	if (Module.RaidBuffsTracking["ALL"]) then
		for _, value in pairs(Module.RaidBuffsTracking["ALL"]) do
			table_insert(buffs, value)
		end
	end

	if (Module.RaidBuffsTracking[Class]) then
		for _, value in pairs(Module.RaidBuffsTracking[Class]) do
			table_insert(buffs, value)
		end
	end

	if (buffs) then
		for _, spell in pairs(buffs) do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon:SetWidth(6)
			Icon:SetHeight(6)
			Icon:SetPoint(spell[2], 0, 0)

			local Texture = Icon:CreateTexture(nil, "OVERLAY")
			Texture:SetAllPoints(Icon)
			Texture:SetTexture(C["Media"].Blank)

			if (spell[3]) then
				Texture:SetVertexColor(unpack(spell[3]))
			else
				Texture:SetVertexColor(0.8, 0.8, 0.8)
			end

			local Count = Icon:CreateFontString(nil, "OVERLAY")
			Count:SetFont(C["Media"].Font, 8, "THINOUTLINE")
			Count:SetPoint("CENTER", unpack(Module.RaidBuffsTrackingPosition[spell[2]]))
			Icon.count = Count

			Auras.icons[spell[1]] = Icon
		end
	end

	frame.AuraWatch = Auras
end

function Module:GetPartyFramesAttributes()
	local PartyProperties = C["Party"].PartyAsRaid and "custom [group:party] hide" or "custom [group:party, nogroup:raid] show; hide"

	return "oUF_Party", nil, PartyProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", 140,
	"initial-height", 38,
	"showSolo", false,
	"showParty", true,
	"showPlayer", C["Party"].ShowPlayer,
	"showRaid", false,
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "TANK, HEALER, DAMAGER, NONE",
	"groupBy", "ASSIGNEDROLE",
	"yOffset", -44
end

function Module:GetDamageRaidFramesAttributes()
	local DamageRaidProperties = C["Party"].PartyAsRaid and "custom [group:party] show" or "custom [group:raid] show; hide"

	return "DamageRaid", nil, DamageRaidProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", C["Raid"].Width,
	"initial-height", C["Raid"].Height,
	"showParty", true,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", 6,
	"yOffset", -6,
	"point", "TOP",
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", C["Raid"].GroupBy.Value,
	"maxColumns", math.ceil(40 / 5),
	"unitsPerColumn", C["Raid"].MaxUnitPerColumn,
	"columnSpacing", 6,
	"columnAnchorPoint", "LEFT"
end

function Module:GetHealerRaidFramesAttributes()
	local HealerRaidProperties = C["Party"].PartyAsRaid and "custom [group:party] show" or "custom [group:raid] show; hide"

	return "HealerRaid", nil, HealerRaidProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],

	"initial-width", C["Raid"].Width,
	"initial-height", C["Raid"].Height,
	"showParty", true,
	"showRaid", true,
	"showPlayer", true,
	"showSolo", false,
	"xoffset", 6,
	"yOffset", -6,
	"point", "TOP",
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", C["Raid"].GroupBy.Value,
	"maxColumns", math.ceil(40 / 5),
	"unitsPerColumn", C["Raid"].MaxUnitPerColumn,
	"columnSpacing", 6,
	"columnAnchorPoint", "LEFT"
end

function Module:GetMainTankAttributes()
	return "oUF_MainTank", nil, "raid",
	"oUF-initialConfigFunction", [[
	self:SetWidth(70)
	self:SetHeight(32)
	]],

	"showRaid", true,
	"yOffset", -8,
	"groupFilter",
	"MAINTANK, MAINASSIST",
	"groupBy", "ROLE",
	"groupingOrder", "MAINTANK, MAINASSIST",
	"template", "oUF_MainTank"
end

function Module:CreateStyle(unit)
	if (not unit) then
		return
	end

	local Parent = self:GetParent():GetName()

	if (unit == "player") then
		Module.CreatePlayer(self)
	elseif (unit == "target") then
		Module.CreateTarget(self)
	elseif (unit == "targettarget") then
		Module.CreateTargetOfTarget(self)
	elseif (unit == "pet") then
		Module.CreatePet(self)
	elseif (unit == "focus") then
		Module.CreateFocus(self)
	elseif (unit == "focustarget") then
		Module.CreateFocusTarget(self)
	elseif unit:find("arena%d") then
		Module.CreateArena(self)
	elseif unit:find("boss%d") then
		Module.CreateBoss(self)
	elseif (unit:find("party") or unit:find("raid")) then
		if Parent:match("Party") then
			Module.CreateParty(self)
		else
			Module.CreateRaid(self)
		end
	elseif unit:match("nameplate") then
		Module.CreateNameplates(self)
	end

	return self
end

function Module:CreateUnits()
	if (C["Unitframe"].Enable) then
		local Player = oUF:Spawn("player")
		Player:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "TOPLEFT", -10, 200)
		Player:SetSize(190, 52)

		local Target = oUF:Spawn("target")
		Target:SetPoint("BOTTOMLEFT", ActionBarAnchor, "TOPRIGHT", 10, 200)
		Target:SetSize(190, 52)

		local TargetOfTarget = oUF:Spawn("targettarget")
		TargetOfTarget:SetPoint("TOPLEFT", Target, "BOTTOMRIGHT", -56, 2)
		TargetOfTarget:SetSize(116, 36)

		local Pet = oUF:Spawn("pet")
		if C["Unitframe"].CombatFade and Player and not InCombatLockdown() then
			Pet:SetParent(Player)
		end
		if (K.Class == "WARLOCK" or K.Class == "DEATHKNIGHT") then
			Pet:SetPoint("TOPRIGHT", Player, "BOTTOMLEFT", 56, -16)
		else
			Pet:SetPoint("TOPRIGHT", Player, "BOTTOMLEFT", 56, 2)
		end
		Pet:SetSize(116, 36)

		local Focus = oUF:Spawn("focus")
		Focus:SetPoint("BOTTOMRIGHT", Player, "TOPLEFT", -60, 30)
		Focus:SetSize(190, 52)

		local FocusTarget = oUF:Spawn("focustarget")
		FocusTarget:SetPoint("TOPRIGHT", Focus, "BOTTOMLEFT", 56, 2)
		FocusTarget:SetSize(116, 36)

		if (C["Arena"].Enable) then
			local Arena = {}
			for i = 1, 5 do
				Arena[i] = oUF:Spawn("arena" .. i)
				Arena[i]:SetSize(190, 52)
				if (i == 1) then
					Arena[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
				else
					Arena[i]:SetPoint("TOPLEFT", Arena[i - 1], "BOTTOMLEFT", 0, -48)
				end
				Movers:RegisterFrame(Arena[i])
			end
			Module.Arena = Arena
			Module.CreateArenaPreparationFrames()
		end

		if (C["Boss"].Enable) then
			local Boss = {}
			for i = 1, MAX_BOSS_FRAMES do
				Boss[i] = oUF:Spawn("boss" .. i)
				if (i == 1) then
					Boss[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
				else
					Boss[i]:SetPoint("TOPLEFT", Boss[i - 1], "BOTTOMLEFT", 0, -48)
				end
				Boss[i]:SetSize(190, 52)
				Movers:RegisterFrame(Boss[i])
			end
		end

		if (C["Party"].Enable) then
			local Party = oUF:SpawnHeader(Module:GetPartyFramesAttributes())
			Party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -200)
			Movers:RegisterFrame(Party)
		end

		if (C["Raid"].Enable) then
			local DamageRaid = oUF:SpawnHeader(Module:GetDamageRaidFramesAttributes())
			local HealerRaid = oUF:SpawnHeader(Module:GetHealerRaidFramesAttributes())

			if C["Raid"].RaidLayout.Value == "Healer" then
				HealerRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -30)
			elseif C["Raid"].RaidLayout.Value == "Damage" then
				DamageRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -30)
			else
				DamageRaid:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -30)
			end

			if C["Raid"].MainTankFrames then
				local MainTank = oUF:SpawnHeader(Module:GetMainTankAttributes())
				if C["Raid"].RaidLayout.Value == "Healer" then
					MainTank:SetPoint("BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", 6, 2)
				elseif C["Raid"].RaidLayout.Value == "Damage" then
					MainTank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
				else
					MainTank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
				end
				Movers:RegisterFrame(MainTank)
			end

			Movers:RegisterFrame(DamageRaid)
			Movers:RegisterFrame(HealerRaid)
		end

		Movers:RegisterFrame(Player)
		Movers:RegisterFrame(Target)
		Movers:RegisterFrame(TargetOfTarget)
		Movers:RegisterFrame(Pet)
		Movers:RegisterFrame(Focus)
		Movers:RegisterFrame(FocusTarget)
	end

	if C["Nameplates"].Enable then
		local GetCVarDefault = _G.GetCVarDefault
		local SetCVar = _G.SetCVar

		SetCVar("nameplateMotionSpeed", .1)
		SetCVar("nameplateOverlapV", GetCVarDefault("nameplateOverlapV"))
		SetCVar("nameplateOverlapH", GetCVarDefault("nameplateOverlapH"))
		SetCVar("nameplateOtherTopInset", GetCVarDefault("nameplateOtherTopInset"))
		SetCVar("nameplateOtherBottomInset", GetCVarDefault("nameplateOtherBottomInset"))
		SetCVar("nameplateLargeTopInset", GetCVarDefault("nameplateLargeTopInset"))
		SetCVar("nameplateLargeBottomInset", GetCVarDefault("nameplateLargeBottomInset"))

		Module.NameplatesVars = {
			NamePlateHorizontalScale = 1,
			nameplateGlobalScale = 1,
			nameplateLargerScale = 1.2,
			nameplateMaxAlpha = 1,
			nameplateMaxAlphaDistance = 0,
			nameplateMaxDistance = C["Nameplates"].Distance + 6 or 46, -- for some reason there is a 6yd diff
			nameplateMaxScale = 1,
			nameplateMaxScaleDistance = 0,
			nameplateMinAlpha = 1,
			nameplateMinAlphaDistance = 0,
			nameplateMinScale = 1,
			nameplateMinScaleDistance = 0,
			nameplateOtherBottomInset = C["Nameplates"].Clamp and 0.1 or -1,
			nameplateOtherTopInset = C["Nameplates"].Clamp and 0.08 or -1,
			nameplateSelectedAlpha = 1,
			nameplateSelectedScale = 1,
			nameplateSelfAlpha = 1,
			nameplateSelfScale = 1,
			nameplateShowAll = 1,
			nameplateShowFriendlyNPCs = 0,
			nameplateVerticalScale = 1,
		}

		oUF:SpawnNamePlates(nil, Module.NameplatesCallback, Module.NameplatesVars)
	end
end

function Module:ShowArenaPreparation()
	local NumOpps = GetNumArenaOpponentSpecs()

	for i = 1, 5 do
		local Frame = self.ArenaPreparation[i]

		if (i <= NumOpps) then
			local SpecID = GetArenaOpponentSpec(i)

			if (SpecID and SpecID > 0) then
				local _, Spec, _, _, _, Class = GetSpecializationInfoByID(SpecID)

				if (Class) then
					Frame.SpecClass:SetText(Spec .. " - " .. LOCALIZED_CLASS_NAMES_MALE[Class])

					local Color = self.Arena[i].colors.class[Class]
					Frame.Health:SetStatusBarColor(unpack(Color))
				end

				Frame:Show()
			else
				Frame:Hide()
			end
		else
			Frame:Hide()
		end
	end
end

function Module:HideArenaPreparation()
	for i = 1, 5 do
		local Frame = self.ArenaPreparation[i]
		Frame:Hide()
	end
end

function Module:OnEvent(event)
	if (event == "ARENA_OPPONENT_UPDATE") then
		self:HideArenaPreparation()
	else
		self:ShowArenaPreparation()
	end
end

function Module:UpdateRaidDebuffIndicator()
	local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs

	if (ORD) then
		ORD:ResetDebuffData()
		local _, InstanceType = IsInInstance()
		if (InstanceType == "party" or InstanceType == "raid") then
			ORD:RegisterDebuffs(Module.DebuffsTracking.RaidDebuffs.spells)
		else
			ORD:RegisterDebuffs(Module.DebuffsTracking.CCDebuffs.spells)
		end
	end
end

local function CreateTargetSound(unit)
	if UnitExists(unit) then
		if UnitIsEnemy(unit, "player") then
			PlaySound(PlaySoundKitID and "Igcreatureaggroselect" or SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend("player", unit) then
			PlaySound(PlaySoundKitID and "Igcharacternpcselect" or SOUNDKIT.IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(PlaySoundKitID and "Igcreatureneutralselect" or SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
		end
	else
		PlaySound(PlaySoundKitID and "igcreatureaggrodeselect" or SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

function Module:PLAYER_FOCUS_CHANGED()
	CreateTargetSound("focus")
end

function Module:PLAYER_TARGET_CHANGED()
	CreateTargetSound("target")
end

local announcedPVP
function Module:UNIT_FACTION(_, unit)
	if (unit ~= "player") then
		return
	end

	if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
		if not announcedPVP then
			announcedPVP = true
			PlaySound(PlaySoundKitID and "IgPVPUpdate" or SOUNDKIT.IG_PVP_UPDATE)
		end
	else
		announcedPVP = nil
	end
end

function Module:OnEnable()
	if C["Unitframe"].Enable ~= true and C["Party"].Enable ~= true and C["Raid"].Enable ~= true then
		return
	end

	self.Backdrop = {
		bgFile = C["Media"].Blank,
		insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult}
	}

	oUF:RegisterStyle(" ", Module.CreateStyle)
	oUF:SetActiveStyle(" ")

	self:CreateUnits()

	if (C["Arena"].Enable) then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "OnEvent")
		self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS", "OnEvent")
		self:RegisterEvent("ARENA_OPPONENT_UPDATE", "OnEvent")
	end

	if (C["Raid"].RaidDebuffs) then
		local RaidDebuffs = CreateFrame("Frame")
		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", Module.UpdateRaidDebuffIndicator)

		local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs
		if (ORD) then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end
	end

	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("UNIT_FACTION")
end