local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Nameplates.lua code!")
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

function Module:IsMouseoverUnit()
	if not self or not self.unit then return end

	if self:IsVisible() and UnitExists("mouseover") and not UnitIsUnit("target", self.unit) then
		return UnitIsUnit("mouseover", self.unit)
	end
	return false
end

function Module:UpdateMouseoverShown()
	if not self or not self.unit then return end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) and not UnitIsUnit("target", self.unit) then
		self.glow:Show()
		self.HighlightIndicator:Show()
	else
		self.HighlightIndicator:Hide()
	end
end

local function AddMouseoverIndicator(self)
	local glow = self.Health:CreateTexture(nil, "OVERLAY")
	glow:SetAllPoints()
	glow:SetTexture(C["Media"].Mouseover)
	glow:SetVertexColor(1, 1, 1, .36)
	glow:SetBlendMode("ADD")
	glow:Hide()

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Module.UpdateMouseoverShown, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateMouseoverShown, true)

	local f = CreateFrame("Frame", nil, self)
	f:SetScript("OnUpdate", function(_, elapsed)
		f.elapsed = (f.elapsed or 0) + elapsed
		if f.elapsed > .1 then
			if not Module.IsMouseoverUnit(self) then
				f:Hide()
			end
			f.elapsed = 0
		end
	end)

	f:HookScript("OnHide", function()
		glow:Hide()
	end)

	self.glow = glow
	self.HighlightIndicator = f
end

local function GetNPCID()
	return tonumber(string.match(UnitGUID('npc') or '', '%w+%-.-%-.-%-.-%-.-%-(.-)%-'))
end

local explosiveCount, hasExplosives = 0
local id = 120651
function Module:ScalePlates()
	for _, nameplate in next, C_NamePlate.GetNamePlates() do
		local unitFrame = nameplate.unitFrame
		local npcID = GetNPCID(unitFrame.unit)
		if explosiveCount > 0 and npcID == id or explosiveCount == 0 then
			unitFrame:SetWidth(C["Nameplate"]["Width"] * 1.4)
		else
			unitFrame:SetWidth(C["Nameplate"]["Width"] * .9)
		end
	end
end

function Module:UpdateExplosives(event, unit)
	if not hasExplosives or unit ~= self.unit then
		return
	end

	-- local npcID = B.GetNPCID(UnitGUID(unit))
	local npcID = GetNPCID(unit)
	if event == "NAME_PLATE_UNIT_ADDED" and npcID == id then
		explosiveCount = explosiveCount + 1
	elseif event == "NAME_PLATE_UNIT_REMOVED" and npcID == id then
		explosiveCount = explosiveCount - 1
	end
	Module:ScalePlates()
end

local function checkInstance()
	local name, _, instID = GetInstanceInfo()
	if name and instID == 8 then
		hasExplosives = true
	else
		hasExplosives = false
		explosiveCount = 0
	end
end

function Module:CheckExplosives()
	if not C["Nameplate"]["ExplosivesScale"] then return end

	local function checkAffixes(event)
		local affixes = C_MythicPlus.GetCurrentAffixes()
		if not affixes then return end
		if affixes[3] and affixes[3].id == 13 then
			checkInstance()
			K:RegisterEvent(event, checkInstance)
			K:RegisterEvent("CHALLENGE_MODE_START", checkInstance)
		end
		K:UnregisterEvent(event, checkAffixes)
	end
	K:RegisterEvent("PLAYER_ENTERING_WORLD", checkAffixes)
end

function Module:CreateNameplates()
	local NameplateTexture = K.GetTexture(C["UITextures"].NameplateTextures)
	local Font = K.GetFont(C["UIFonts"].NameplateFonts)

	self:SetScale(UIParent:GetEffectiveScale())
	self:SetSize(C["Nameplates"].Width, C["Nameplates"].Height)
	self:SetPoint("CENTER", 0, 0)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetFrameStrata(self:GetFrameStrata())
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetHeight(C["Nameplates"].Height - C["Nameplates"].CastHeight - 1)
	self.Health:SetWidth(self:GetWidth())
	self.Health:SetStatusBarTexture(NameplateTexture)
	self.Health:CreateShadow(true)

	self.Health.colorTapping = true
	self.Health.colorReaction = true
	self.Health.colorClass = true
	self.Health.colorHealth = true
	self.Health.colorThreat = C["Nameplates"].Threat
	self.Health.frequentUpdates = true
	self.Health.UpdateColor = Module.UpdateColor

	K:SetSmoothing(self.Health, C["Nameplates"].Smooth)

	if C["Nameplates"].HealthValue == true then
		self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self.Health.Value:SetFontObject(Font)
		self:Tag(self.Health.Value, C["Nameplates"].HealthFormat.Value)
	end

	self.Level = self.Health:CreateFontString(nil, "OVERLAY")
	self.Level:SetJustifyH("RIGHT")
	self.Level:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Level:SetFontObject(Font)
	self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")

	self.Name = self.Health:CreateFontString(nil, "OVERLAY")
	self.Name:SetJustifyH("LEFT")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Level, "BOTTOMLEFT")
	self.Name:SetFontObject(Font)
	self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameAbbrev]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetFrameStrata(self:GetFrameStrata())
	self.Power:SetHeight(C["Nameplates"].CastHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)
	self.Power:SetStatusBarTexture(NameplateTexture)
	self.Power:CreateShadow(true)

	self.Power.IsHidden = false
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	self.Power.PostUpdate = Module.NameplatePowerAndCastBar

	K:SetSmoothing(self.Power, C["Nameplates"].Smooth)

	if C["Nameplates"].TrackAuras == true then
		self.Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
		self.Debuffs:SetWidth(C["Nameplates"].Width)
		self.Debuffs:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, -4)
		self.Debuffs.num = 5 * 2
		self.Debuffs.spacing = 3
		self.Debuffs.size = ((((self.Debuffs:GetWidth() - (self.Debuffs.spacing * (self.Debuffs.num / 2 - 1))) / self.Debuffs.num)) * 2)
		self.Debuffs:SetHeight(self.Debuffs.size * 2)
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs.onlyShowPlayer = true
		self.Debuffs.filter = "HARMFUL|INCLUDE_NAME_PLATE_ONLY"
		self.Debuffs.disableMouse = true
		self.Debuffs.PostCreateIcon = Module.PostCreateAura
		self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	end

	self.Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
	self.Castbar:SetFrameStrata(self:GetFrameStrata())
	self.Castbar:SetStatusBarTexture(NameplateTexture)
	self.Castbar:SetFrameLevel(6)
	self.Castbar:SetHeight(C["Nameplates"].CastHeight)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -4)
	self.Castbar:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -4)

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetSize(32, self:GetHeight())
	self.Castbar.Spark:SetTexture(C["Media"].Spark_64)
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.timeToHold = 0.4
	self.Castbar.CustomDelayText = Module.CustomCastDelayText
	self.Castbar.CustomTimeText = Module.CustomTimeText
	self.Castbar.PostCastFail = Module.PostCastFail
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostCastInterruptible = Module.PostCastInterruptible

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
	self.Castbar.Time:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", 0, -2)
	self.Castbar.Time:SetJustifyH("RIGHT")
	self.Castbar.Time:SetFontObject(Font)
	self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() + 2, self:GetHeight() + 3)
	self.Castbar.Button:CreateShadow(true)
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
	self.Castbar.Text:SetWordWrap(false)

	self.Castbar:SetScript("OnShow", Module.NameplatePowerAndCastBar)
	self.Castbar:SetScript("OnHide", Module.NameplatePowerAndCastBar)

	self.RaidTargetIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetSize(32, 32)
	self.RaidTargetIndicator:SetPoint("BOTTOM", self.Debuffs or self, "TOP", 0, 10)

	if C["Nameplates"].ThreatPercent == true then
		self.ThreatPercent = self:CreateFontString(nil, "OVERLAY")
		self.ThreatPercent:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
		self.ThreatPercent:SetFontObject(Font)
		self:Tag(self.ThreatPercent, "[KkthnxUI:ThreatColor][KkthnxUI:ThreatPercent]")
	end

	if C["Nameplates"].ClassResource then
		Module.CreateNamePlateClassPower(self)
		if (K.Class == "DEATHKNIGHT") then
			Module.CreateNamePlateRuneBar(self)
		elseif (K.Class == "MONK") then
			Module.CreateNamePlateStaggerBar(self)
		end
	end

	Module.CreatePlateQuestIcons(self)
	Module.CreatePlateHealerIcons(self)
	Module.CreatePlateTotemIcons(self)
	Module.CreateDebuffHighlight(self)
	Module.CreateHealthPrediction(self, "nameplate")
	--Module.UpdateExplosives(self, event, "nameplate")

	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.HighlightPlate, true)
	self:RegisterEvent("UNIT_HEALTH", Module.HighlightPlate, true)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateNameplateTarget, true)
	if C["Nameplates"].Totems then
		self:RegisterEvent("UNIT_NAME_UPDATE", Module.UpdatePlateTotems, true)
	end

	AddMouseoverIndicator(self)
end