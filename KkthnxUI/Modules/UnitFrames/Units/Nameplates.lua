local K, C = unpack(select(2, ...))
if C["Nameplates"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Nameplates.lua code!")
	return
end

local _G = _G
local pairs = pairs
local select = select
local string_format = string.format
local string_gsub = string.gsub

local CreateFrame = _G.CreateFrame
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetBattlefieldScore = _G.GetBattlefieldScore
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local GetNumBattlefieldScores = _G.GetNumBattlefieldScores
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local UIParent = _G.UIParent
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UNKNOWN = _G.UNKNOWN

-- Taken from Blizzard_TalentUI.lua
local healerSpecIDs = {
	105, -- Druid Restoration
	270, -- Monk Mistweaver
	65,	 -- Paladin Holy
	256, -- Priest Discipline
	257, -- Priest Holy
	264, -- Shaman Restoration
}

Module.HealerSpecs = {}
Module.Healers = {}

--Get localized healing spec names
for _, specID in pairs(healerSpecIDs) do
	local _, name = GetSpecializationInfoByID(specID)
	if name and not Module.HealerSpecs[name] then
		Module.HealerSpecs[name] = true
	end
end

function Module:CheckBGHealers()
	local name, _, talentSpec
	for i = 1, GetNumBattlefieldScores() do
		name, _, _, _, _, _, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)
		if name then
			name = string_gsub(name,"%-"..string_gsub(K.Realm,"[%s%-]",""),"")
			if name and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			elseif name and self.Healers[name] then
				self.Healers[name] = nil
			end
		end
	end
end

function Module:CheckArenaHealers()
	local numOpps = GetNumArenaOpponentSpecs()
	if not (numOpps > 1) then
		return
	end

	for i = 1, 5 do
		local name, realm = UnitName(string_format("arena%d", i))
		if name and name ~= UNKNOWN then
			realm = (realm and realm ~= "") and string_gsub(realm,"[%s%-]","")
			if realm then name = name.."-"..realm end
			local s = GetArenaOpponentSpec(i)
			local _, talentSpec = nil, UNKNOWN
			if s and s > 0 then
				_, talentSpec = GetSpecializationInfoByID(s)
			end

			if talentSpec and talentSpec ~= UNKNOWN and self.HealerSpecs[talentSpec] then
				self.Healers[name] = talentSpec
			end
		end
	end
end

function Module:NameplatesCallback(_, _, unit)
	if unit then
		if UnitIsUnit(unit, "player") then
			self.Power:Show()
			self.Name:Hide()
			self.Castbar:SetAlpha(0)
			self.RaidTargetIndicator:SetAlpha(0)
		else
			self.Name:Show()
			self.Castbar:SetAlpha(1)
			self.RaidTargetIndicator:SetAlpha(1)
		end
	end
end

function Module:CreateNameplates()
	local NameplateTexture = K.GetTexture(C["Nameplates"].Texture)
	local Font = K.GetFont(C["Nameplates"].Font)

	self:SetScale(UIParent:GetEffectiveScale())
	self:SetSize(C["Nameplates"].Width, C["Nameplates"].Height)
	self:SetPoint("CENTER", 0, 0)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameStrata(self:GetFrameStrata())
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetHeight(C["Nameplates"].Height - C["Nameplates"].CastHeight - 1)
	self.Health:SetWidth(self:GetWidth())
	self.Health:SetStatusBarTexture(NameplateTexture)
	self.Health:CreateShadow()

	self.Health.Background = self.Health:CreateTexture(nil, "BORDER")
	self.Health.Background:SetAllPoints()
	self.Health.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorReaction = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.Smooth = C["Nameplates"].Smooth
	self.Health.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10

	if C["Nameplates"].HealthValue == true then
		self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self.Health.Value:SetFontObject(Font)
		self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 12, select(3, self.Health.Value:GetFont()))
		self:Tag(self.Health.Value, C["Nameplates"].HealthFormat.Value)
	end

	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetJustifyH("RIGHT")
	self.Level:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Level:SetFontObject(Font)
	self.Level:SetFont(select(1, self.Level:GetFont()), 12, select(3, self.Level:GetFont()))
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetJustifyH("LEFT")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Level, "BOTTOMLEFT")
	self.Name:SetFontObject(Font)
	self.Name:SetFont(select(1, self.Name:GetFont()), 12, select(3, self.Name:GetFont()))
	self.Name:SetWordWrap(false) -- Why is this even a thing? Text wrapping is just fucking ugly.
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata(self:GetFrameStrata())
	self.Power:SetHeight(C["Nameplates"].CastHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	self.Power:SetStatusBarTexture(NameplateTexture)
	self.Power:CreateShadow()

	self.Power.Background = self.Power:CreateTexture(nil, "BORDER")
	self.Power.Background:SetAllPoints()
	self.Power.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4] )

	self.Power.IsHidden = false
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.Smooth = C["Nameplates"].Smooth
	self.Power.SmoothSpeed = C["Nameplates"].SmoothSpeed * 10
	self.Power.PostUpdate = Module.DisplayNameplatePowerAndCastBar

	self.Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	self.Debuffs:SetHeight(18)
	self.Debuffs:SetWidth(self:GetWidth())
	self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 18)
	self.Debuffs.size = 18
	self.Debuffs.num = 7
	self.Debuffs.numRow = 2

	self.Debuffs.spacing = 2
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs["growth-y"] = "UP"
	self.Debuffs["growth-x"] = "RIGHT"
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	self.Debuffs.onlyShowPlayer = true

	self.Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
	self.Castbar:SetFrameStrata(self:GetFrameStrata())
	self.Castbar:SetStatusBarTexture(NameplateTexture)
	self.Castbar:SetFrameLevel(6)
	self.Castbar:SetHeight(C["Nameplates"].CastHeight)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)

	self.Castbar.Background = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.Background:SetAllPoints(self.Castbar)
	self.Castbar.Background:SetTexture(NameplateTexture)
	self.Castbar.Background:SetVertexColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetSize(32, self:GetHeight())
	self.Castbar.Spark:SetTexture(C["Media"].Spark_64)
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", 0, -2)
	self.Castbar.Time:SetJustifyH("RIGHT")
	self.Castbar.Time:SetFontObject(Font)
	self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() + 2, self:GetHeight() + 3)
	self.Castbar.Button:CreateShadow()
	self.Castbar.Button:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetAllPoints()
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]])
	self.Castbar.Shield:SetSize(50, 50)
	self.Castbar.Shield:SetPoint("RIGHT", self.Castbar, "LEFT", 26, 12)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFontObject(Font)
	self.Castbar.Text:SetPoint("TOPLEFT", self.Castbar, "BOTTOMLEFT", 0, -2)
	self.Castbar.Text:SetPoint("TOPRIGHT", self.Castbar.Time, "TOPLEFT")
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)

	self.Castbar.PostCastStart = Module.CheckInterrupt
	self.Castbar.PostCastInterruptible = Module.CheckInterrupt
	self.Castbar.PostCastNotInterruptible = Module.CheckInterrupt
	self.Castbar.PostChannelStart = Module.CheckInterrupt

	self.Castbar:SetScript("OnShow", Module.DisplayNameplatePowerAndCastBar)
	self.Castbar:SetScript("OnHide", Module.DisplayNameplatePowerAndCastBar)

	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(self:GetHeight(), self:GetHeight())
	self.RaidTargetIndicator:SetPoint("BOTTOM", self.Health, "TOP", 0, 38)

	self.QuestIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.QuestIndicator:SetTexture("Interface\\MINIMAP\\ObjectIcons")
	self.QuestIndicator:SetTexCoord(0.125, 0.250, 0.125, 0.250)
	self.QuestIndicator:SetSize(18, 18)
	self.QuestIndicator:SetPoint("RIGHT", self.Health, "LEFT", 2, 0)

	-- Create Totem Icon
	--if C.nameplate.totem_icons == true then
	self.Totem = CreateFrame("Frame", nil, self)
	self.Totem.Icon = self.Totem:CreateTexture(nil, "OVERLAY")
	self.Totem.Icon:SetSize((C["Nameplates"].Height * 2 * K.NoScaleMult) + 8, (C["Nameplates"].Height * 2 * K.NoScaleMult) + 8)
	self.Totem.Icon:SetPoint("BOTTOM", self.Health, "TOP", 0, 16)
	self.Totem:CreateShadow(true)
	--end

	-- Create Healer Icon
	if C["Nameplates"].MarkHealers then
		self.HealerTexture = self:CreateTexture(nil, "OVERLAY")
		self.HealerTexture:SetPoint("RIGHT", self.Health, "LEFT", -6, 0)
		self.HealerTexture:SetSize(40, 40)
		self.HealerTexture:SetTexture([[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Healer.tga]])
		self.HealerTexture:Hide()
	end

	self:EnableMouse(false)
	self.Health:EnableMouse(false)
	self.Power:EnableMouse(false)
	self.Castbar:EnableMouse(false)
	self.Debuffs:EnableMouse(false)

	self.HealthPrediction = Module.CreateHealthPrediction(self)
	Module.CreatePvPIndicator(self, "nameplate", self, self:GetHeight(), self:GetHeight() + 3)
	Module.CreateDebuffHighlight(self)

	-- Highlight Plate Events
	self:RegisterEvent("NAME_PLATE_CREATED", Module.HighlightPlate)
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.HighlightPlate)
	self:RegisterEvent("NAME_PLATE_UNIT_REMOVED", Module.HighlightPlate)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.HighlightPlate)
	Module.HighlightPlate(self)

	-- Target Alpha Events
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.UpdateNameplateTarget)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateNameplateTarget)
	Module.UpdateNameplateTarget(self)

	-- Totem Icon Events
	self:RegisterEvent("NAME_PLATE_CREATED", Module.UpdatePlateTotems)
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.UpdatePlateTotems)

	-- Healer Icon Events
	self:RegisterEvent("NAME_PLATE_CREATED", Module.DisplayHealerTexture)
	self:RegisterEvent("NAME_PLATE_UNIT_ADDED", Module.DisplayHealerTexture)

	-- Threat Plate Events
	self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE", Module.ThreatPlate)

	-- Threat Plate PostUpdate Function
	self.Health.PostUpdate = function()
		Module.ThreatPlate(self, true)
	end
end