local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _G = _G
local pairs = pairs
local unpack = unpack
local select = select

local CreateFrame = CreateFrame
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local InCombatLockdown = InCombatLockdown
local UnitClassification = UnitClassification
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer

local _, ns = ...
local config = ns.config
local oUF = ns.oUF or oUF
local textPath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\"
local pathFat = textPath.."Fat\\"
local pathNormal = textPath.."Normal\\"
local Movers = K.Movers

-- Frame data
local DataNormal = {
	targetTexture = {
		elite = pathNormal .. "Target-Elite",
		rareelite = pathNormal .. "Target-Rare-Elite",
		rare = pathNormal .. "Target-Rare",
		worldboss = pathNormal .. "Target-Elite",
		normal = pathNormal .. "Target",
	},
	vehicle = {-- w = width, h = height, x offset, y offset, t=texture, j = justify, s = size, c=Texture Coordinates, p = point
		siz = {w = 175, h = 42}, -- size
		tex = {w = 240, h = 121, x = 0, y = -8, t = "Interface\\Vehicles\\UI-Vehicle-Frame", c = {0, 1, 0, 1}}, --texture
		hpb = {w = 108, h = 9, x = 30, y = 1,}, --Healthbar
		hpt = {x = 0, y = 1, j = "CENTER", s = 13}, -- Healthtext
		mpb = {w = 108, h = 9, x = 0, y = 0,}, -- Mana bar
		mpt = {x = 0, y = 0, j = "CENTER", s = 13}, -- Mana bar text
		nam = {w = 110, h = 10, x = 0, y = 22, j = "CENTER", s = 12}, -- Name text
		por = {w = 56, h = 56, x = -64, y = 10,}, -- Portrait
		glo = {w = 242, h = 92, x = 13, y = 0, t = "Interface\\Vehicles\\UI-VEHICLE-FRAME-FLASH", c = {0, 1, 0, 1}}, -- Glow texture
	},
	vehicleorganic = {
		siz = {w = 175, h = 42},
		tex = {w = 240, h = 121, x = 0, y = -8, t = "Interface\\Vehicles\\UI-Vehicle-Frame-Organic", c = {0, 1, 0, 1}},
		hpb = {w = 108, h = 9, x = 30, y = 1,},
		hpt = {x = 0, y = 1, j = "CENTER", s = 13},
		mpb = {w = 108, h = 9, x = 0, y = 0,},
		mpt = {x = 0, y = 0, j = "CENTER", s = 13},
		nam = {w = 110, h = 10, x = 0, y = 22, j = "CENTER", s = 12},
		por = {w = 56, h = 56, x = -64, y = 10,},
		glo = {w = 242, h = 92, x = 13, y = 0, t = "Interface\\Vehicles\\UI-VEHICLE-FRAME-ORGANIC-FLASH", c = {0, 1, 0, 1}},
	},
	player = {
		siz = {w = 175, h = 42},
		tex = {w = 232, h = 100, x = -20, y = -7, t = pathNormal.."Target", c = {1, 0.09375, 0, 0.78125}},
		hpb = {w = 118, h = 19, x = 50, y = 16,},
		hpt = {x = 0, y = 1, j = "CENTER", s = 13},
		mpb = {w = 118, h = 20, x = 0, y = 0,},
		mpt = {x = 0, y = 0, j = "CENTER", s = 13},
		nam = {w = 110, h = 10, x = 0, y = 17, j = "CENTER", s = 12},
		por = {w = 64, h = 64, x = -41, y = 6,},
		glo = {w = 242, h = 92, x = 13, y = 0, t = pathNormal.."Target-Flash", c = {0.945, 0, 0, 0.182}},
	},
	target = {-- and focus
		siz = {w = 175, h = 42},
		tex = {w = 230, h = 100, x = 20, y = -7, t = pathNormal.."Target", c = {0.09375, 1, 0, 0.78125}},
		hpb = {w = 118, h = 19, x = -50, y = 16,},
		hpt = {x = 0, y = 1, j = "CENTER", s = 13},
		mpb = {w = 118, h = 20, x = 0, y = 0,},
		mpt = {x = 0, y = 0, j = "CENTER", s = 13},
		nam = {w = 110, h = 10, x = 0, y = 17, j = "CENTER", s = 12},
		por = {w = 64, h = 64, x = 41, y = 6,},
		glo = {w = 239, h = 94, x = -24, y = 1, t = pathNormal.."Target-Flash", c = {0, 0.945, 0, 0.182}},
	},
	targettarget = {-- and focus target
		siz = {w = 85, h = 20},
		tex = {w = 128, h = 64, x = 16, y = -10, t = pathNormal.."TargetOfTarget", c = {0, 1, 0, 1}},
		hpb = {w = 43, h = 6, x = 2, y = 14,},
		hpt = {x = -2, y = 0, j = "CENTER", s = 10},
		mpb = {w = 37, h = 7, x = -1, y = 0,},
		nam = {w = 65, h = 10, x = 11, y = -18, j = "LEFT", s = 12},
		por = {w = 40, h = 40, x = -40, y = 10,},
	},
	pet = {
		siz = {w = 110, h = 37},
		tex = {w = 128, h = 64, x = 4, y = -10, t = pathNormal.."Pet", c = {0, 1, 0, 1}},
		hpb = {w = 69, h = 8, x = 16, y = 7,},
		hpt = {x = 1, y = 1, j = "CENTER", s = 10},
		mpb = {w = 69, h = 8, x = 0, y = 0,},
		mpt = {x = 0, y = 0, j = "CENTER", s = 13},
		--nam = {w = 110, h = 10, x = 20, y = 15, j = "LEFT", s = 14},
		por = {w = 37, h = 37, x = -41, y = 10,},
		glo = {w = 128, h = 64, x = -4, y = 12, t = pathNormal.."Party-Flash", c = {0, 1, 1, 0}},
	},
	party = {
		siz = {w = 115, h = 35},
		tex = {w = 128, h = 64, x = 2, y = -16, t = pathNormal.."Party", c = {0, 1, 0, 1}},
		hpb = {w = 69, h = 7, x = 17, y = 17,},
		hpt = {x = 1, y = 1, j = "CENTER", s = 10},
		mpb = {w = 70, h = 7, x = 0, y = 0,},
		mpt = {x = 0, y = -2, j = "CENTER", s = 12},
		nam = {w = 110, h = 10, x = 0, y = 15, j = "CENTER", s = 12},
		por = {w = 37, h = 37, x = -39, y = 7,},
		glo = {w = 128, h = 63, x = -3, y = 4, t = pathNormal.."Party-Flash", c = {0, 1, 0, 1}},
	},
	boss = {
		siz = {w = 132, h = 46},
		tex = {w = 250, h = 129, x = 31, y = -24, t = pathNormal.."Boss", c = {0, 1, 0, 1}},
		hpb = {w = 115, h = 9, x = -38, y = 17,},
		hpt = {x = 0, y = 0, j = "CENTER", s = 13},
		mpb = {w = 115, h = 8, x = 0, y = -3,},
		mpt = {x = 0, y = 0, j = "CENTER", s = 13},
		nam = {w = 110, h = 10, x = 0, y = 16, j = "CENTER", s = 12},
		glo = {w = 241, h = 100, x = -2, y = 3, t = pathNormal.."Boss-Flash", c = {0.0, 0.945, 0.0, 0.73125}},
	},
}

local DataFat = {
	targetTexture = {
		elite = pathFat .. "Target-Elite",
		rareelite = pathFat .. "Target-Rare-Elite",
		rare = pathFat .. "Target-Rare",
		worldboss = pathFat .. "Target-Elite",
		normal = pathFat .. "Target",
	},
	vehicle = DataNormal.vehicle,
	vehicleorganic = DataNormal.vehicleorganic,
	player = {
		siz = {w = 176, h = 42},
		tex = {w = 232, h = 100, x = -20, y = -7, t = pathFat.."Target", c = {1, 0.09375, 0, 0.78125}},
		hpb = {w = 118, h = 26, x = 50, y = 13,},
		hpt = {x = 0, y = 1, j = "CENTER", s = 13},
		mpb = {w = 118, h = 14, x = 0, y = 0,},
		mpt = {x = 0, y = 0, j = "CENTER", s = 13},
		nam = {w = 110, h = 10, x = 50, y = 19, j = "CENTER", s = 12},
		por = {w = 64, h = 64, x = -42, y = 7,},
		glo = {w = 242, h = 92, x = 13, y = -1, t = pathFat.."Target-Flash", c = {0.945, 0, 0, 0.182}},
	},
	target = {
		siz = {w = 176, h = 42},
		tex = {w = 230, h = 100, x = 20, y = -7, t = pathFat.."Target", c = {0.09375, 1, 0, 0.78125}},
		hpb = {w = 118, h = 26, x = -50, y = 13,},
		hpt = {x = 0, y = 1, j = "CENTER", s = 13},
		mpb = {w = 118, h = 14, x = 0, y = 0,},
		mpt = {x = 0, y = 0, j = "CENTER", s = 13},
		nam = {w = 110, h = 10, x = 0, y = 18, j = "CENTER", s = 12},
		por = {w = 64, h = 64, x = 41, y = 6,},
		glo = {w = 239, h = 94, x = -24, y = 1, t = pathNormal.."Target-Flash", c = {0, 0.945, 0, 0.182}},
	},
	targettarget = DataNormal.targettarget, --same for now
	pet = {
		siz = {w = 110, h = 37},
		tex = {w = 128, h = 64, x = 4, y = -10, t = pathFat.."Pet", c = {0, 1, 0, 1}},
		hpb = {w = 69, h = 12, x = 16, y = 9,},
		hpt = {x = 1, y = 1, j = "CENTER", s = 13},
		mpb = {w = 69, h = 8, x = 0, y = 0,},
		mpt = {x = 0, y = 0, j = "CENTER", s = 13},
		--nam = {w = 110, h = 10, x = 20, y = 15, j = "LEFT", s = 12},
		por = {w = 37, h = 37, x = -41, y = 10,},
		glo = {w = 128, h = 64, x = -4, y = 12, t = pathFat.."Party-Flash", c = {0, 1, 1, 0}},
	},
	party = {
		siz = {w = 116, h = 35},
		tex = {w = 128, h = 64, x = 2, y = -16, t = pathFat.."Party", c = {0, 1, 0, 1}},
		hpb = {w = 69, h = 12, x = 17, y = 15,},
		hpt = {x = 0, y = 1, j = "CENTER", s = 10},
		mpb = {w = 70, h = 7, x = 0, y = 0,},
		mpt = {x = 0, y = -1, j = "CENTER", s = 12},
		nam = {w = 110, h = 10, x = 0, y = 15, j = "CENTER", s = 12},
		por = {w = 37, h = 37, x = -39, y = 7,},
		glo = {w = 128, h = 63, x = -3, y = 4, t = pathFat.."Party-Flash", c = {0, 1, 0, 1}},
	},
	boss = DataNormal.boss,
}

local function UpdateThreat(self)
	local _, status, scaledPercent, _, _ = UnitDetailedThreatSituation("player", "target")

	if (scaledPercent) then
		local red, green, blue = GetThreatStatusColor(status)
		self.NumericalThreat.bg:SetStatusBarColor(red, green, blue)
		self.NumericalThreat.value:SetText(math.ceil(scaledPercent).."%")
		if (not self.NumericalThreat:IsVisible()) then
			self.NumericalThreat:Show()
		end
	else
		if (self.NumericalThreat:IsVisible()) then
			self.NumericalThreat:Hide()
		end
	end
end

local function GetDBUnit(cUnit)
	if cUnit == "focus" then
		return "target"
	elseif cUnit == "focustarget" then
		return "targettarget"
	elseif cUnit == "player" then -- can player be vehicle? no it cant
		if UnitHasVehicleUI("player") then
			if (UnitVehicleSkin("player") == "Natural") then
				return "vehicleorganic"
			else
				return "vehicle"
			end
		else
			return "player"
		end
	end
	return cUnit
end

local function GetData(cUnit)
	local dbUnit = GetDBUnit(cUnit)
	if (C.Unitframe.Style == "fat") then
		return DataFat[dbUnit]
	end
	return DataNormal[dbUnit]
end

local function GetTargetTexture(cUnit, type)
	local dbUnit = GetDBUnit(cUnit)
	if dbUnit == "vehicle" or dbUnit == "vehicleorganic" then
		return GetData(cUnit).tex.t
	end
	if dbUnit == "player" then
		if ns.config.playerStyle == "custom" then
			return ns.config.customPlayerTexture
		end
		type = ns.config.playerStyle
	end

	-- only "target", "focus" & "player" gets this far
	local data = C.Unitframe.Style == "normal" and DataNormal.targetTexture or DataFat.targetTexture
	if data[type] then
		return data[type]
	else
		return data["normal"]
	end
end

local function UpdatePlayerFrame(self, ...)
	local data = GetData(self.cUnit)
	local uconfig = ns.config[self.cUnit]

	self.Texture:SetSize(data.tex.w, data.tex.h)
	self.Texture:SetPoint("CENTER", self, data.tex.x, data.tex.y)
	self.Texture:SetTexture(GetTargetTexture("player")) -- 1
	self.Texture:SetTexCoord(unpack(data.tex.c))

	self.Health:SetSize(data.hpb.w, data.hpb.h)
	self.Health:SetPoint("CENTER", self.Texture, data.hpb.x, data.hpb.y)
	self.Power:SetSize(data.mpb.w, data.mpb.h)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", data.mpb.x, data.mpb.y)

	self.Health.Value:SetPoint("CENTER", self.Health, data.hpt.x, data.hpt.y)
	self.Power.Value:SetPoint("CENTER", self.Power, data.mpt.x, data.mpt.y)

	self.Name:SetPoint("TOP", self.Health, data.nam.x, data.nam.y)
	self.Name:SetSize(data.nam.w, data.nam.h)
	self.Portrait:SetPoint("CENTER", self.Texture, data.por.x, data.por.y)
	self.Portrait:SetSize(data.por.w, data.por.h)

	if self.ThreatGlow then
		self.ThreatGlow:SetSize(data.glo.w, data.glo.h)
		self.ThreatGlow:SetPoint("TOPLEFT", self.Texture, data.glo.x, data.glo.y)
		self.ThreatGlow:SetTexture(data.glo.t)
		self.ThreatGlow:SetTexCoord(unpack(data.glo.c))
	end

	if (self.PvP) then
		self.PvP:ClearAllPoints()
	end

	local inVehicle = UnitHasVehicleUI("player")

	ComboFrame_Update(ComboPointPlayerFrame)

	if inVehicle then
		self.Name:Show()
		self.Level:Hide()

		self.LFDRole:SetAlpha(0)
		self.PvP:SetPoint("TOPLEFT", self.Texture, 4, -28)
		self.Leader:SetPoint("TOPLEFT", self.Texture, 23, -14)
		self.MasterLooter:SetPoint("TOPLEFT", self.Texture, 74, -14)
		self.RaidIcon:SetPoint("CENTER", self.Portrait, "TOP", 0, -5)
		securecall("PlayerFrame_ShowVehicleTexture")

		-- ComboPointPlayerFrame:Hide()
		if (self.classPowerBar) then
			self.classPowerBar:Hide()
		end

		TotemFrame:Hide()

		if (K.Class == "SHAMAN") then
		elseif (K.Class == "DRUID") then
			EclipseBarFrame:Hide()
		elseif (K.Class == "DEATHKNIGHT") then
			RuneFrame:Hide()
		elseif (K.Class == "PRIEST") then
			PriestBarFrame:Hide()
		end
	else
		self.Name:Hide()
		self.Level:Show()

		self.LFDRole:SetAlpha(1)
		self.PvP:SetPoint("TOPLEFT", self.Texture, 23, -23)
		self.Leader:SetPoint("TOPLEFT", self.Portrait, 3, 2)
		self.MasterLooter:SetPoint("TOPRIGHT", self.Portrait, -3, 3)
		self.RaidIcon:SetPoint("CENTER", self.Portrait, "TOP", 0, -1)
		securecall("PlayerFrame_HideVehicleTexture")

		-- ComboPointPlayerFrame:Show()
		if (self.classPowerBar) then
			self.classPowerBar:Setup()
		end

		TotemFrame_Update()

		if (K.Class == "SHAMAN") then
		elseif (K.Class == "DRUID") then
			EclipseBar_UpdateShown(EclipseBarFrame)
		elseif (K.Class == "DEATHKNIGHT") then
			RuneFrame:Show()
		elseif (K.Class == "PRIEST") then
			PriestBarFrame_CheckAndShow()
		end
	end
end

local function UpdateUnitFrameLayout(frame)
	local cUnit = frame.cUnit
	local data = GetData(cUnit)
	local uconfig = ns.config[cUnit]

	-- Player frame, its special
	if cUnit == "player" then
		return UpdatePlayerFrame(frame)
	elseif (not data) then
		return
	end

	-- Frame Size
	if not InCombatLockdown() then
		frame:SetSize(data.siz.w, data.siz.h)
		frame:SetScale(C.Unitframe.Scale or 1)
	end
	-- Texture
	frame.Texture:SetTexture(data.tex.t)
	frame.Texture:SetSize(data.tex.w, data.tex.h)
	frame.Texture:SetPoint("CENTER", frame, data.tex.x, data.tex.y)
	frame.Texture:SetTexCoord(unpack(data.tex.c))
	-- HealthBar
	frame.Health:SetSize(data.hpb.w, data.hpb.h)
	frame.Health:SetPoint("CENTER", frame.Texture, data.hpb.x, data.hpb.y)
	-- ManaBar
	frame.Power:SetSize(data.mpb.w, data.mpb.h)
	frame.Power:SetPoint("TOPLEFT", frame.Health, "BOTTOMLEFT", data.mpb.x, data.mpb.y)
	-- HealthText
	frame.Health.Value:SetPoint("CENTER", frame.Health, data.hpt.x, data.hpt.y)
	-- ManaText - not for tots
	if frame.Power.Value then
		frame.Power.Value:SetPoint("CENTER", frame.Power, data.mpt.x, data.mpt.y)
	end
	-- NameText
	if frame.Name then
		frame.Name:SetSize(data.nam.w, data.nam.h)
		frame.Name:SetPoint("TOP", frame.Health, data.nam.x, data.nam.y)
	end
	-- Portrait
	if frame.Portrait then
		frame.Portrait:SetSize(data.por.w, data.por.h)
		frame.Portrait:SetPoint("CENTER", frame.Texture, data.por.x, data.por.y)
	end
	-- Threat Glow -- if enabled
	if frame.ThreatGlow then
		frame.ThreatGlow:SetSize(data.glo.w, data.glo.h)
		frame.ThreatGlow:SetPoint("TOPLEFT", frame.Texture, data.glo.x, data.glo.y)
		frame.ThreatGlow:SetTexture(data.glo.t)
		frame.ThreatGlow:SetTexCoord(unpack(data.glo.c))
	end
end

function oUFKkthnx:UpdateBaseFrames(optUnit)
	if InCombatLockdown() then return end
	config = ns.config
	if optUnit and optUnit:find("%d") then
		optUnit = optUnit:match("^.%a+")
	end

	for _, obj in pairs(oUF.objects) do
		local unit = obj.cUnit
		if obj.style == "oUF_Kkthnx" and unit and (not optUnit or optUnit == unit:match("^.%a+")) then
			UpdateUnitFrameLayout(obj)
		end
	end
end

local function CreateUnitLayout(self, unit)
	self.cUnit = K.cUnit(unit)
	self.IsMainFrame = K.MultiCheck(self.cUnit, "player", "target", "focus")
	self.IsTargetFrame = K.MultiCheck(self.cUnit, "targettarget", "focustarget")
	self.IsPartyFrame = self.cUnit:match("party")

	if (self.IsTargetFrame) then
		self:SetFrameLevel(4)
	end

	-- Mouse Interraction
	self:RegisterForClicks("AnyUp")

	self:HookScript("OnEnter", K.UnitFrame_OnEnter)
	self:HookScript("OnLeave", K.UnitFrame_OnLeave)
	self.mouseovers = {}

	if self.cUnit == "arena" then
		return ns.createArenaLayout(self, unit)
	end

	local uconfig = ns.config[self.cUnit]
	local data = GetData(self.cUnit)

	-- Load Castbars
	if C.Unitframe.Castbars and uconfig and uconfig.cbshow then
		ns.CreateCastbars(self, self.cUnit)
	end

	--Textures
	self.Texture = self:CreateTexture(nil, "BORDER")
	if C.Blizzard.ColorTextures == true then
		self.Texture:SetVertexColor(unpack(C.Blizzard.TexturesColor))
	end
	self.Texture:SetDrawLayer("BORDER", 3)

	-- Healthbar
	self.Health = K.CreateStatusBar(self, nil, nil, true)
	self.Health:SetFrameLevel(self:GetFrameLevel()-1)
	table.insert(self.mouseovers, self.Health)
	self.Health.PostUpdate = K.PostUpdateHealth
	self.Health.Smooth = true
	self.Health.frequentUpdates = true

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	if C.Unitframe.ClassColor then
		self.Health.colorClass = true
	end
	self.Health.colorReaction = true

	-- Health text
	self.Health.Value = K.SetFontString(self, C.Media.Font, 13, nil, "CENTER")

	-- Power bar
	self.Power = K.CreateStatusBar(self, nil, nil, true)
	self.Power:SetFrameLevel(self:GetFrameLevel()-1)
	table.insert(self.mouseovers, self.Power)
	self.Power.frequentUpdates = self.cUnit == "player" or self.cUnit == "boss"
	self.Power.PostUpdate = K.PostUpdatePower
	self.Power.Smooth = true
	self.Power.colorPower = true

	-- Power Text
	if (data.mpt) then
		self.Power.Value = K.SetFontString(self, C.Media.Font, 13, nil, "CENTER")
	end

	-- Name Text
	if data.nam then
		self.Name = K.SetFontString(self, C.Media.Font, 13, nil, "CENTER")
		self.Name:SetShadowOffset(K.Mult,-K.Mult)
		self:Tag(self.Name, "[KkthnxUI:Name]")
	end

	-- Portrait
	if data.por then
		self.Portrait = self.Health:CreateTexture(nil, "BACKGROUND")
		self.Portrait.Override = function(self, event, unit)
			if (not unit or not UnitIsUnit(self.unit, unit)) then return end
			local portrait = self.Portrait
			local _, class = UnitClass(self.unit)
			if C.Unitframe.ClassPortraits and UnitIsPlayer(unit) and class then
				portrait:SetTexture[[Interface\TargetingFrame\UI-Classes-Circles]]
				portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			elseif C.Unitframe.FlatClassPortraits and UnitIsPlayer(unit) and class and C.Unitframe.ClassPortraits == false then
				portrait:SetTexture[[Interface\AddOns\KkthnxUI\Media\Unitframes\DarkClassIcons]]
				portrait:SetTexCoord(unpack(CLASS_ICON_TCOORDS[class]))
			else
				portrait:SetTexCoord(0, 1, 0, 1)
				SetPortraitTexture(portrait, unit)
			end
		end
	end

	-- Threat glow
	if (C.Unitframe.ThreatGlow) and (data.glo) then
		self.ThreatGlow = self:CreateTexture(nil, "BACKGROUND", -1)
	end

	if (self.IsMainFrame) then
		-- Level text
		self.Level = self:CreateFontString(nil, "ARTWORK")
		self.Level:SetFont(C.Media.Font, C.Media.Font_Size)
		self.Level:SetShadowOffset(K.Mult,-K.Mult)
		self.Level:SetPoint("CENTER", self.Texture, (self.cUnit == "player" and -63) or 63, -15.5)
		self:Tag(self.Level, "[KkthnxUI:Level]")

		-- PvP Icon
		self.PvP = self:CreateTexture(nil, "OVERLAY")
		self.PvP:SetSize(30, 30)
		self.PvP:SetPoint("TOPRIGHT", self.Texture, -23, -23)
		self.PvP.Prestige = self:CreateTexture(nil, "ARTWORK")
		self.PvP.Prestige:SetSize(50, 52)
		self.PvP.Prestige:SetPoint("CENTER", self.PvP, "CENTER")

		local mhpb = self.Health:CreateTexture(nil, "ARTWORK")
		mhpb:SetTexture(C.Media.Texture)
		mhpb:SetVertexColor(0, 0.827, 0.765, 1)
		mhpb:SetWidth(self.Health:GetWidth())

		local ohpb = self.Health:CreateTexture(nil, "ARTWORK")
		ohpb:SetTexture(C.Media.Texture)
		ohpb:SetVertexColor(0.0, 0.631, 0.557, 1)
		ohpb:SetWidth(self.Health:GetWidth())

		local ahpb = self.Health:CreateTexture(nil, "ARTWORK")
		ahpb:SetTexture("Interface\\RaidFrame\\Shield-Fill")
		ahpb:SetWidth(self.Health:GetWidth())

		self.HealPrediction = {
			myBar = mhpb,
			otherBar = ohpb,
			absorbBar = ahpb,
			maxOverflow = 1,
			frequentUpdates = true
		}

		-- Combat CombatFeedbackText
		if C.Unitframe.CombatText == true then
			local CombatFeedbackText = self:CreateFontString(nil, "OVERLAY", 7)
			CombatFeedbackText:SetFont(C.Media.Font, 16, "THINOUTLINE")
			CombatFeedbackText:SetPoint("CENTER", self.Portrait)
			CombatFeedbackText.colors = {
				DAMAGE = {0.69, 0.31, 0.31},
				CRUSHING = {0.69, 0.31, 0.31},
				CRITICAL = {0.69, 0.31, 0.31},
				GLANCING = {0.69, 0.31, 0.31},
				STANDARD = {0.84, 0.75, 0.65},
				IMMUNE = {0.84, 0.75, 0.65},
				ABSORB = {0.84, 0.75, 0.65},
				BLOCK = {0.84, 0.75, 0.65},
				RESIST = {0.84, 0.75, 0.65},
				MISS = {0.84, 0.75, 0.65},
				HEAL = {0.33, 0.59, 0.33},
				CRITHEAL = {0.33, 0.59, 0.33},
				ENERGIZE = {0.31, 0.45, 0.63},
				CRITENERGIZE = {0.31, 0.45, 0.63},
			}

			self.CombatFeedbackText = CombatFeedbackText
		end
	end

	-- Portrait Timer
	if (C.Unitframe.PortraitTimer and self.Portrait) then
		self.PortraitTimer = CreateFrame("Frame", nil, self.Health)

		self.PortraitTimer.Icon = self.PortraitTimer:CreateTexture(nil, "BACKGROUND")
		self.PortraitTimer.Icon:SetAllPoints(self.Portrait)

		self.PortraitTimer.Remaining = K.SetFontString(self.PortraitTimer, C.Media.Font, data.por.w / 3, C.Media.Font_Style, "CENTER")
		self.PortraitTimer.Remaining:SetPoint("CENTER", self.PortraitTimer.Icon)
		self.PortraitTimer.Remaining:SetTextColor(1, 1, 1)
	end

	self.RaidIcon = self:CreateTexture(nil, "OVERLAY", self)
	self.RaidIcon:SetTexture("Interface\\TargetingFrame\\UI-RaidTargetingIcons")

	if self.cUnit == "boss" then
		self.RaidIcon:SetPoint("CENTER", self, "TOPRIGHT", -9, -10)
		self.RaidIcon:SetSize(26, 26)

		self.Name.Bg = self.Health:CreateTexture(nil, "BACKGROUND")
		self.Name.Bg:SetHeight(18)
		self.Name.Bg:SetTexCoord(0.2, 0.8, 0.3, 0.85)
		self.Name.Bg:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT")
		self.Name.Bg:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT")
		self.Name.Bg:SetTexture(C.Media.Texture)

		-- Alt power bar
		local altbar = _G["Boss"..unit:match("%d").."TargetFramePowerBarAlt"]
		UnitPowerBarAlt_Initialize(altbar, unit, (1) * 0.5, "INSTANCE_ENCOUNTER_ENGAGE_UNIT")
		altbar:SetParent(self)
		altbar:ClearAllPoints()
		altbar:SetPoint("TOPRIGHT", self, "TOPLEFT", 0, 5)
	else
		-- Icons
		self.RaidIcon:SetPoint("CENTER", self.Portrait, "TOP", 0, -1)
		self.RaidIcon:SetSize(data.por.w / 2.5, data.por.w / 2.5)

		self.MasterLooter = self:CreateTexture(nil, "OVERLAY", self)
		self.MasterLooter:SetSize(16, 16)
		if (self.cUnit == "target" or self.cUnit == "focus") then
			self.MasterLooter:SetPoint("TOPLEFT", self.Portrait, 3, 3)
		elseif (self.IsTargetFrame) then
			self.MasterLooter:SetPoint("CENTER", self.Portrait, "TOPLEFT", 3, -3)
		elseif (self.IsPartyFrame) then
			self.MasterLooter:SetSize(14, 14)
			self.MasterLooter:SetPoint("TOPLEFT", self.Texture, 29, 0)
		end

		self.Leader = self:CreateTexture(nil, "OVERLAY", self)
		self.Leader:SetSize(16, 16)
		if (self.cUnit == "target" or self.cUnit == "focus") then
			self.Leader:SetPoint("TOPRIGHT", self.Portrait, -3, 2)
		elseif self.IsTargetFrame then
			self.Leader:SetPoint("TOPLEFT", self.Portrait, -3, 4)
		elseif self.IsPartyFrame then
			self.Leader:SetSize(14, 14)
			self.Leader:SetPoint("CENTER", self.Portrait, "TOPLEFT", 1, -1)
		end

		if not self.IsTargetFrame then
			self.PhaseIcon = self:CreateTexture(nil, "OVERLAY")
			self.PhaseIcon:SetPoint("CENTER", self.Portrait, "BOTTOM")
			if self.IsMainFrame then
				self.PhaseIcon:SetSize(26, 26)
			else
				self.PhaseIcon:SetSize(18, 18)
			end
		end

		self.OfflineIcon = self:CreateTexture(nil, "OVERLAY")
		self.OfflineIcon:SetPoint("TOPRIGHT", self.Portrait, 7, 7)
		self.OfflineIcon:SetPoint("BOTTOMLEFT", self.Portrait, -7, -7)

		if (self.cUnit == "player" or self.IsPartyFrame) then
			self.ReadyCheck = self:CreateTexture(nil, "OVERLAY")
			self.ReadyCheck:SetPoint("TOPRIGHT", self.Portrait, -7, -7)
			self.ReadyCheck:SetPoint("TOPRIGHT", self.Portrait, -7, -7)
			self.ReadyCheck:SetPoint("BOTTOMLEFT", self.Portrait, 7, 7)
			self.ReadyCheck.delayTime = 2
			self.ReadyCheck.fadeTime = 0.7
		end

		if (self.IsPartyFrame or self.cUnit == "player" or self.cUnit == "target") then
			self.LFDRole = self:CreateTexture(nil, "OVERLAY")
			self.LFDRole:SetSize(20, 20)

			if self.cUnit == "player" then
				self.LFDRole:SetPoint("BOTTOMRIGHT", self.Portrait, -2, -3)
			elseif unit == "target" then
				self.LFDRole:SetPoint("TOPLEFT", self.Portrait, -10, -2)
			else
				self.LFDRole:SetPoint("BOTTOMLEFT", self.Portrait, -5, -5)
			end
		end
	end

	-- Update layout
	UpdateUnitFrameLayout(self)

	-- Player Frame
	if self.cUnit == "player" then
		self:SetSize(data.siz.w, data.siz.h)
		self:SetScale(C.Unitframe.Scale or 1)

		-- Combo Points
		ComboPointPlayerFrame:ClearAllPoints()
		ComboPointPlayerFrame:SetParent(self)
		ComboPointPlayerFrame:SetPoint("TOP", self, "BOTTOM", 30, 2)
		ComboPointPlayerFrame.SetPoint = K.Noop

		if C.Blizzard.ColorTextures == true then
			ComboPointPlayerFrame.Background:SetVertexColor(unpack(C.Blizzard.TexturesColor, 0.1))
		end

		-- Totems
		if config[K.Class].showTotems then
			ns.classModule.Totems(self, config, uconfig)
		end

		-- Alternate Mana Bar
		if config[K.Class].showAdditionalPower then
			ns.classModule.alternatePowerBar(self, config, uconfig)
		end

		-- Load Class Modules
		if ns.classModule[K.Class] then
			self.classPowerBar = ns.classModule[K.Class](self, config, uconfig)
		end

		-- Power Prediction Bar (Display estimated cost of spells when casting)
		if C.Unitframe.PowerPredictionBar then
			local mainBar, altBar
			mainBar = CreateFrame("StatusBar", nil, self.Power)
			mainBar:SetFrameLevel(self.Power:GetFrameLevel())
			mainBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar-Glow]], "BORDER")
			mainBar:GetStatusBarTexture():SetBlendMode("ADD")
			mainBar:SetReverseFill(true)
			mainBar:SetPoint"TOP"
			mainBar:SetPoint"BOTTOM"
			mainBar:SetPoint("RIGHT", self.Power:GetStatusBarTexture(), "RIGHT")
			mainBar:SetWidth(self.Power:GetWidth())
			mainBar:SetStatusBarColor(1, 1, 1, .3)

			if self.AdditionalPower then
				altBar = CreateFrame("StatusBar", nil, self.AdditionalPower)
				altBar:SetFrameLevel(self.AdditionalPower:GetFrameLevel())
				altBar:SetStatusBarTexture([[Interface\TargetingFrame\UI-StatusBar-Glow]], "BORDER")
				altBar:GetStatusBarTexture():SetBlendMode("ADD")
				altBar:SetReverseFill(true)
				altBar:SetPoint"TOP"
				altBar:SetPoint"BOTTOM"
				altBar:SetPoint("RIGHT", self.AdditionalPower:GetStatusBarTexture(), "RIGHT")
				altBar:SetWidth(self.AdditionalPower:GetWidth())
				altBar:SetStatusBarColor(1, 1, 1, .3)
			end

			self.PowerPrediction = {
				mainBar = mainBar,
				altBar = altBar
			}
		end

		-- PvP Timer
		if (self.PvP) then
			self.PvPTimer = K.SetFontString(self, C.Media.Font, 13, nil, "CENTER")
			self.PvPTimer:SetShadowOffset(K.Mult,-K.Mult)
			self.PvPTimer:SetPoint("BOTTOM", self.PvP, "TOP", 0, -3)
			self.PvPTimer.frequentUpdates = 0.5
			self:Tag(self.PvPTimer, "[KkthnxUI:PvPTimer]")
		end

		-- GCD spark
		if C.Unitframe.GCDBar == true then
			self.GCD = CreateFrame("StatusBar", self:GetName().."_GCD", self)
			self.GCD:SetHeight(K.Scale(6))
			self.GCD:SetWidth(K.Scale(150))
			self.GCD:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -K.Scale(4))
			self.GCD:SetStatusBarTexture(C.Media.Texture)
			self.GCD:SetStatusBarColor(0.9, 0.9, 0.9)

			Movers:RegisterFrame(self.GCD)
		end

		-- Combat icon
		self.Combat = self:CreateTexture(nil, "OVERLAY")
		self.Combat:SetPoint("CENTER", self.Level, 1, 0)
		self.Combat:SetSize(31, 33)

		-- Resting icon
		self.Resting = self:CreateTexture(nil, "OVERLAY")
		self.Resting:SetPoint("CENTER", self.Level, -0.5, 0)
		self.Resting:SetSize(31, 34)

		-- player frame vehicle/normal update
		self:RegisterEvent("UNIT_ENTERED_VEHICLE", UpdatePlayerFrame)
		self:RegisterEvent("UNIT_ENTERING_VEHICLE", UpdatePlayerFrame)
		self:RegisterEvent("UNIT_EXITING_VEHICLE", UpdatePlayerFrame)
		self:RegisterEvent("UNIT_EXITED_VEHICLE", UpdatePlayerFrame)
	end

	-- Focus & Target Frame
	if (self.cUnit == "target" or self.cUnit == "focus") then
		-- Questmob Icon
		self.QuestIcon = self:CreateTexture(nil, "OVERLAY")
		self.QuestIcon:SetSize(32, 32)
		self.QuestIcon:SetPoint("CENTER", self.Health, "TOPRIGHT", 1, 10)

		table.insert(self.__elements, function(self, _, unit)
			self.Texture:SetTexture(GetTargetTexture(self.cUnit, UnitClassification(unit)))
		end)
	end

	if (self.cUnit == "player") then
		if C.Unitframe.ThreatValue then
			self.NumericalThreat = CreateFrame("Frame", nil, self)
			self.NumericalThreat:SetSize(49, 18)
			self.NumericalThreat:SetPoint("BOTTOM", self, "TOP", 0, 0)
			self.NumericalThreat:Hide()

			self.NumericalThreat.value = self.NumericalThreat:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			self.NumericalThreat.value:SetPoint("TOP", 0, -4)

			self.NumericalThreat.bg = CreateFrame("StatusBar", nil, self.NumericalThreat)
			self.NumericalThreat.bg:SetStatusBarTexture(C.Media.Texture)
			self.NumericalThreat.bg:SetFrameStrata("LOW")
			self.NumericalThreat.bg:SetFrameLevel(2)
			self.NumericalThreat.bg:SetPoint("TOP", 0, -3)
			self.NumericalThreat.bg:SetSize(37, 14)

			self.NumericalThreat.texture = self.NumericalThreat:CreateTexture(nil, "ARTWORK")
			self.NumericalThreat.texture:SetPoint("TOP", 0, 0)
			self.NumericalThreat.texture:SetTexture("Interface\\TargetingFrame\\NumericThreatBorder")
			self.NumericalThreat.texture:SetTexCoord(0, 0.765625, 0, 0.5625)
			self.NumericalThreat.texture:SetSize(49, 18)

			self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", UpdateThreat)
			self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", UpdateThreat)
			self:RegisterEvent("PLAYER_REGEN_DISABLED", UpdateThreat)
			self:RegisterEvent("PLAYER_REGEN_ENABLED", UpdateThreat)
			self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateThreat)
		end
	end

	-- Auras
	if (self.cUnit == "focus") or (self.cUnit == "target") then
		local isFocus = self.cUnit == "focus"

		local function GetAuraData(mode)
			local size, gap, columns, rows, initialAnchor, relAnchor, offX, offY
			if (mode == "TOP") then
				if isFocus then
					columns, rows = 3, 3
				else
					columns, rows = 6, 3
				end
				initialAnchor, relAnchor, offX, offY = "BOTTOMLEFT", "TOPLEFT", -2, 20
			elseif (mode == "BOTTOM") then
				if isFocus then
					columns, rows = 3, 3
				else
					columns, rows = 4, 3
				end
				initialAnchor, relAnchor, offX, offY = "TOPLEFT", "BOTTOMLEFT", -2, -8
			elseif (mode == "LEFT") then
				if isFocus then
					columns, rows = 5, 3
				else
					columns, rows = 8, 3
				end
				initialAnchor, relAnchor, offX, offY = "TOPRIGHT", "TOPLEFT", -8, -1.5
			end
			size = isFocus and 26 or 20
			gap = 4.5
			return size, gap, columns, rows, initialAnchor, relAnchor, offX, offY
		end

		if (uconfig.buffPos == uconfig.debuffPos) and (uconfig.debuffPos ~= "NONE") then
			local size, gap, columns, rows, initialAnchor, relAnchor, offX, offY = GetAuraData(uconfig.debuffPos)
			self.Auras = K.AddAuras(self, initialAnchor, size, gap, columns, rows)
			self.Auras:SetPoint(initialAnchor, self, relAnchor, offX, offY)
			self.Auras.CustomFilter = ns.CustomAuraFilters.target
		else
			if (uconfig.buffPos ~= "NONE") then
				local size, gap, columns, rows, initialAnchor, relAnchor, offX, offY = GetAuraData(uconfig.buffPos)
				self.Buffs = K.AddBuffs(self, initialAnchor, size, gap, columns, rows)
				self.Buffs:SetPoint(initialAnchor, self, relAnchor, offX, offY)
				self.Buffs.CustomFilter = ns.CustomAuraFilters.target
			end
			if (uconfig.debuffPos ~= "NONE") then
				local size, gap, columns, rows, initialAnchor, relAnchor, offX, offY = GetAuraData(uconfig.debuffPos)
				self.Debuffs = K.AddDebuffs(self, initialAnchor, size, gap, columns, rows)
				self.Debuffs:SetPoint(initialAnchor, self, relAnchor, offX, offY)
				self.Debuffs.CustomFilter = ns.CustomAuraFilters.target
			end
		end

	elseif (self.IsTargetFrame and uconfig.enableAura) then
		self.Debuffs = K.AddDebuffs(self, "TOPLEFT", 20, 4, 3, 2)
		self.Debuffs:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 7, 10)
		self.Debuffs.CustomFilter = ns.CustomAuraFilters.target

	elseif (self.cUnit == "pet") then
		self.Debuffs = K.AddDebuffs(self, "TOPLEFT", 20, 4, 6, 1)
		self.Debuffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 1, -3)
		self.Debuffs.CustomFilter = ns.CustomAuraFilters.pet

	elseif (self.IsPartyFrame) then
		self.Debuffs = K.AddDebuffs(self, "TOPLEFT", 20, 4, 4, 1)
		self.Debuffs:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 5, 1)
		self.Debuffs.CustomFilter = ns.CustomAuraFilters.party

		self.Buffs = K.AddBuffs(self, "TOPLEFT", 20, 4, 4, 1)
		self.Buffs:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 2, -11)
		self.Buffs.CustomFilter = ns.CustomAuraFilters.party

	elseif (self.cUnit == "boss") then
		self.Buffs = K.AddBuffs(self, "TOPLEFT", 30, 4.5, 5, 1)
		self.Buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 3, -6)

		self.Debuffs = K.AddDebuffs(self, "TOPRIGHT", 30, 4.5, 7, 1)
		self.Debuffs:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", -34, 18)
		self.Debuffs.CustomFilter = ns.CustomAuraFilters.boss
	end

	-- Range Fader
	if (self.cUnit == "pet" or self.IsPartyFrame) then
		self.Range = {
			insideAlpha = 1,
			outsideAlpha = 0.8,
		}
	end

	self.CFade = {
		FadeInMin = .2,
		FadeInMax = 1,
		FadeTime = 0.5,
	}
	return self
end

local function FixPetUpdate(self, event, ...) -- Petframe doesnt always update correctly
	oUF_KkthnxPet:GetScript("OnAttributeChanged")(oUF_KkthnxPet, "unit", "pet")
end

-- Spawn our frames.
oUF:RegisterStyle("oUF_Kkthnx", CreateUnitLayout)
oUF:SetActiveStyle("oUF_Kkthnx")

local player = oUF:Spawn("player", "oUF_KkthnxPlayer")
player:SetPoint(unpack(C.Position.UnitFrames.Player))
Movers:RegisterFrame(player)

local pet = oUF:Spawn("pet", "oUF_KkthnxPet")
pet:SetPoint(unpack(C.Position.UnitFrames.Pet))
Movers:RegisterFrame(pet)
player:RegisterEvent("UNIT_PET", FixPetUpdate)

local target = oUF:Spawn("target", "oUF_KkthnxTarget")
target:SetPoint(unpack(C.Position.UnitFrames.Target))
Movers:RegisterFrame(target)

if (config.targettarget.enable) then
	local targettarget = oUF:Spawn("targettarget", "oUF_KkthnxTargetTarget")
	targettarget:SetPoint(unpack(C.Position.UnitFrames.TargetTarget))
	Movers:RegisterFrame(targettarget)
end

local focus = oUF:Spawn("focus", "oUF_KkthnxFocus")
focus:SetPoint(unpack(C.Position.UnitFrames.Focus))
Movers:RegisterFrame(focus)

if (config.focustarget.enable) then
	local focustarget = oUF:Spawn("focustarget", "oUF_KkthnxFocusTarget")
	focustarget:SetPoint(unpack(C.Position.UnitFrames.FocusTarget))
	Movers:RegisterFrame(focustarget)
end

if (C.Unitframe.Party) then
	local party = oUF:SpawnHeader("oUF_KkthnxParty", nil, (C.Raidframe.RaidAsParty and "custom [group:party][group:raid] hide;show") or "custom [@raid6, exists] hide; show",
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"initial-width", K.Scale(105),
	"initial-height", K.Scale(30),
	"showSolo", false,
	"showParty", true,
	"showRaid", false,
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", "GROUP",
	"showPlayer", C.Unitframe.ShowPlayer, -- Need to add this as an option.
	"yOffset", K.Scale(-32)
	)

	party:SetPoint(unpack(C.Position.UnitFrames.Party))
	party:SetScale(1)
	Movers:RegisterFrame(party)
end

if C.Unitframe.ShowBoss then
	local boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		boss[i] = oUF:Spawn("boss"..i, "oUF_KkthnxBossFrame"..i)
		if (i == 1) then
			boss[i]:SetPoint(unpack(C.Position.UnitFrames.Boss))
		else
			boss[i]:SetPoint("TOPLEFT", boss[(i - 1)], "BOTTOMLEFT", 0, -45)
		end

		Movers:RegisterFrame(boss[i])
	end
end

if C.Unitframe.ShowArena then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "oUF_KkthnxArenaFrame"..i)
		if (i == 1) then
			arena[i]:SetPoint(unpack(C.Position.UnitFrames.Arena))
		else
			arena[i]:SetPoint("TOPLEFT", arena[i-1], "BOTTOMLEFT", 0, -40)
		end

		Movers:RegisterFrame(arena[i])
	end
end

-- MirrorTimers
for i = 1, MIRRORTIMER_NUMTIMERS do
	local bar = _G["MirrorTimer" .. i]
	bar:SetParent(UIParent)
	bar:SetSize(220, 18)

	K.CreateBorder(bar, 11, 3)

	if (i > 1) then
		local p1, p2, p3, p4, p5 = bar:GetPoint()
		bar:SetPoint(p1, p2, p3, p4, p5 - 10)
	end

	local statusbar = _G["MirrorTimer" .. i .. "StatusBar"]
	statusbar:SetStatusBarTexture(C.Media.Texture)
	statusbar:SetAllPoints(bar)

	local backdrop = select(1, bar:GetRegions())
	backdrop:SetTexture(C.Media.Blank)
	backdrop:SetVertexColor(unpack(C.Media.Backdrop_Color))
	backdrop:SetAllPoints(bar)

	local border = _G["MirrorTimer" .. i .. "Border"]
	border:Hide()

	local text = _G["MirrorTimer" .. i .. "Text"]
	text:SetFont(C.Media.Font, 13, C.Media.Font_Style)
	text:ClearAllPoints()
	text:SetPoint("CENTER", bar)
	bar.text = text
end

-- Test the unitframes :D
local moving = false
SlashCmdList.TEST_UF = function(msg)
	if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
	if not moving then
		for _, frames in pairs({"oUF_KkthnxTarget", "oUF_KkthnxTargetTarget", "oUF_KkthnxPet", "oUF_KkthnxFocus", "oUF_KkthnxFocusTarget"}) do
			_G[frames].oldunit = _G[frames].unit
			_G[frames]:SetAttribute("unit", "player")
		end

		if C.Unitframe.ShowArena == true then
			for i = 1, 5 do
				_G["oUF_KkthnxArenaFrame"..i].oldunit = _G["oUF_KkthnxArenaFrame"..i].unit
				_G["oUF_KkthnxArenaFrame"..i]:SetAttribute("unit", "player")
			end
		end

		if C.Unitframe.ShowBoss == true then
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_KkthnxBossFrame"..i].oldunit = _G["oUF_KkthnxBossFrame"..i].unit
				_G["oUF_KkthnxBossFrame"..i]:SetAttribute("unit", "player")
			end
		end
		moving = true
	else
		for _, frames in pairs({"oUF_KkthnxTarget", "oUF_KkthnxTargetTarget", "oUF_KkthnxPet", "oUF_KkthnxFocus", "oUF_KkthnxFocusTarget"}) do
			_G[frames]:SetAttribute("unit", _G[frames].oldunit)
		end

		if C.Unitframe.ShowArena == true then
			for i = 1, 5 do
				_G["oUF_KkthnxArenaFrame"..i]:SetAttribute("unit", _G["oUF_KkthnxArenaFrame"..i].oldunit)
			end
		end

		if C.Unitframe.ShowBoss == true then
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_KkthnxBossFrame"..i]:SetAttribute("unit", _G["oUF_KkthnxBossFrame"..i].oldunit)
			end
		end
		moving = false
	end
end
SLASH_TEST_UF1 = "/testuf"