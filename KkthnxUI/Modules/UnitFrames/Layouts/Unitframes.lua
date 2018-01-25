local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Unitframes.lua code!")
	return
end

local _G = _G

local CLASS_ICON_TCOORDS = _G.CLASS_ICON_TCOORDS
local CreateFrame = _G.CreateFrame
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local GetThreatStatusColor = _G.GetThreatStatusColor
local InCombatLockdown = _G.InCombatLockdown
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local UnitClass = _G.UnitClass
local UnitFrame_OnEnter = UnitFrame_OnEnter
local UnitFrame_OnLeave = UnitFrame_OnLeave
local UnitIsPlayer = _G.UnitIsPlayer
local UnitThreatSituation = _G.UnitThreatSituation

local UnitframeFont = K.GetFont(C["Unitframe"].Font)
local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

local function UpdateClassPortraits(self, unit)
	local _, unitClass = UnitClass(unit)
	if (unitClass and UnitIsPlayer(unit)) and C["Unitframe"].PortraitStyle.Value == "ClassPortraits" then
		self:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
		self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
	elseif (unitClass and UnitIsPlayer(unit)) and C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
		self:SetTexture(C["Media"].NewClassPortraits)
		self:SetTexCoord(unpack(CLASS_ICON_TCOORDS[unitClass]))
	else
		self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	end
end

local function oUF_Unitframes(self, unit)
	unit = unit:match("^(.-)%d+") or unit

	self:RegisterForClicks("AnyUp")
	self:HookScript("OnEnter", UnitFrame_OnEnter)
	self:HookScript("OnLeave", UnitFrame_OnLeave)

	-- Health bar
	self.Health = CreateFrame("StatusBar", "$parent.Healthbar", self)
	self.Health:SetTemplate("Transparent")
	self.Health:SetFrameStrata("LOW")
	self.Health:SetFrameLevel(1)
	self.Health:SetStatusBarTexture(UnitframeTexture)

	self.Health.Smooth = C["Unitframe"].Smooth
	self.Health.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true
	self.Health.PreUpdate = K.PreUpdateHealth
	self.Health.PostUpdate = K.PostUpdateHealth

	if (unit == "player") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent]")
	elseif (unit == "pet") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", 15, 7)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetTextColor(1.0, 1.0, 1.0)
		self.Health.Value:SetJustifyH("LEFT")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	elseif (unit == "target") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", -26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "focus") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "targettarget") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", -15, 7)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	elseif (unit == "focustarget") then
		self.Health:SetSize(74, 12)
		self.Health:SetPoint("CENTER", self, "CENTER", 15, 7)
	elseif (unit == "party") then
		self.Health:SetSize(98, 16)
		self.Health:SetPoint("CENTER", self, "CENTER", 18, 8)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 10, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	elseif (unit == "boss" or unit == "arena") then
		self.Health:SetSize(130, 26)
		self.Health:SetPoint("CENTER", self, "CENTER", 26, 10)
		-- Health Value
		self.Health.Value = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
		self:Tag(self.Health.Value, "[KkthnxUI:HealthCurrent-Percent]")
	end

	-- Power Bar
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetTemplate("Transparent")
	self.Power:SetFrameStrata("LOW")
	self.Power:SetFrameLevel(1)
	self.Power:SetStatusBarTexture(UnitframeTexture)

	self.Power.Smooth = C["Unitframe"].Smooth
	self.Power.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10
	self.Power.colorPower = true
	self.Power.frequentUpdates = unit == "player" or unit == "target" -- Less usage this way!
	self.Power.PostUpdate = K.PostUpdatePower

	if C["Unitframe"].PowerClass then
		self.Power.colorClass = true
		self.Power.colorReaction = true
	else
		self.Power.colorPower = true
	end

	-- Power StatusBar
	if unit == "player" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power Value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif unit == "pet" then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power Value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 10, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 2, 0)
	elseif unit == "target" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", -2, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif unit == "focus" then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", -2, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	elseif (unit == "targettarget") then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "focustarget") then
		self.Power:SetSize(74, 8)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "party") then
		self.Power:SetSize(98, 10)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
	elseif (unit == "boss" or unit == "arena") then
		self.Power:SetSize(130, 14)
		self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, -6)
		-- Power value
		self.Power.Value = K.SetFontString(self, C["Media"].Font, 11, "CENTER")
		self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
		self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")
	end

	-- Name Text
	if (unit == "target") then
		self.Name = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 16)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameAbbreviateMedium]")
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 16, C["Unitframe"].Outline and "OUTLINE" or "", "LEFT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("RIGHT", self.Health, "LEFT", -4, 0)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:SmartLevel][KkthnxUI:ClassificationColor][shortclassification]")
	elseif unit == "focus" then
		self.Name = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 16)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
		-- Level Text
		self.Level = K.SetFontString(self, C["Media"].Font, 16, C["Unitframe"].Outline and "OUTLINE" or "", "RIGHT")
		self.Level:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Level:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][KkthnxUI:Level]")
	elseif (unit == "targettarget" or unit == "focustarget") then
		self.Name = K.SetFontString(self, C["Media"].Font, 12, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("BOTTOM", self.Power, "BOTTOM", 0, -16)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameShort]")
	elseif (unit == "party") then
		self.Name = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 16)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
	elseif (unit == "boss" or unit == "arena") then
		self.Name = K.SetFontString(self, C["Media"].Font, 13, C["Unitframe"].Outline and "OUTLINE" or "", "CENTER")
		self.Name:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
		self.Name:SetPoint("TOP", self.Health, "TOP", 0, 16)
		self:Tag(self.Name, "[KkthnxUI:GetNameColor][KkthnxUI:NameMedium]")
	end

	-- 3D and such models. We provide 3 choices here.
	if (C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits") then
		-- Create the portrait globally
		self.Portrait = CreateFrame("PlayerModel", self:GetName().."_3DPortrait", self)
		self.Portrait:SetTemplate("Transparent")
		self.Portrait:SetFrameStrata("BACKGROUND")
		self.Portrait:SetFrameLevel(1)
		self.Portrait.PostUpdate = K.PortraitUpdate

		if (unit == "player" or unit == "focus" or unit == "boss" or unit == "arena") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "pet") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "target") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "targettarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "focustarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "party") then
			self.Portrait:SetSize(32, 32)
			self.Portrait:SetPoint("LEFT", self, 2, 0)
		end
	elseif C["Unitframe"].PortraitStyle.Value == "DefaultPortraits" or C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
		self.Portrait = self.Health:CreateTexture("$parentPortrait", "BACKGROUND", nil, 7)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)

		-- We need to create this for non 3D Ports
		self.Portrait.Background = CreateFrame("Frame", self:GetName().."_2DPortrait", self)
		self.Portrait.Background:SetTemplate("Transparent")
		self.Portrait.Background:SetFrameStrata("LOW")
		self.Portrait.Background:SetFrameLevel(1)

		if (unit == "player" or unit == "focus" or unit == "boss" or unit == "arena") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(46, 46)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "pet") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "target") then
			self.Portrait:SetSize(46, 46)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
			self.Portrait.Background:SetSize(46, 46)
			self.Portrait.Background:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "targettarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("RIGHT", self, -4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("RIGHT", self, -4, 0)
		elseif (unit == "focustarget") then
			self.Portrait:SetSize(26, 26)
			self.Portrait:SetPoint("LEFT", self, 4, 0)
			self.Portrait.Background:SetSize(26, 26)
			self.Portrait.Background:SetPoint("LEFT", self, 4, 0)
		elseif (unit == "party") then
			self.Portrait:SetSize(32, 32)
			self.Portrait:SetPoint("LEFT", self, 2, 0)
			self.Portrait.Background:SetSize(32, 32)
			self.Portrait.Background:SetPoint("LEFT", self, 2, 0)
		end

		if C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits" then
			self.Portrait.PostUpdate = UpdateClassPortraits
		end
	end

	if (unit ~= "player") then
		K.CreateAuras(self, unit)
	end

	if (unit == "player") then
		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, unit)
		end
		if (C["Unitframe"].CombatText) then
			K.CreateCombatText(self)
		end
		if (C["Unitframe"].GlobalCooldown) then
			K.CreateGlobalCooldown(self)
		end
		if (C["Unitframe"].PortraitTimer) then
			K.CreatePortraitTimer(self)
		end
		K.CreateRaidTargetIndicator(self)
		K.CreateResurrectIndicator(self)
		K.CreatePvPText(self, unit)
		K.CreateAssistantIndicator(self)
		K.CreateCombatIndicator(self)
		K.CreateLeaderIndicator(self)
		K.CreateMasterLooterIndicator(self)
		K.CreateReadyCheckIndicator(self)
		K.CreateRestingIndicator(self)
		K.CreateThreatIndicator(self)
		self.HealthPrediction = K.CreateHealthPrediction(self)
		K.CreateAdditionalPower(self)
		K.CreateClassModules(self, 194, 12, 6)
		K.CreateClassTotems(self, 194, 12, 6)
		if (C["Unitframe"].PowerPredictionBar) then
			K.CreatePowerPrediction(self)
		end
		if K.Class == "DEATHKNIGHT" then
			K.CreateClassRunes(self, 194, 12, 6)
		elseif (K.Class == "MONK") then
			K.CreateStagger(self)
		end
	elseif (unit == "target") then
		if C["Unitframe"].Castbars then
			K.CreateCastBar(self, unit)
		end
		if (C["Unitframe"].CombatText) then
			K.CreateCombatText(self)
		end
		if (C["Unitframe"].PortraitTimer) then
			K.CreatePortraitTimer(self)
		end
		K.CreateRaidTargetIndicator(self)
		K.CreateResurrectIndicator(self)
		K.CreatePvPText(self, unit)
		K.CreateQuestIndicator(self)
		K.CreateReadyCheckIndicator(self)
		K.CreateThreatIndicator(self)
		self.HealthPrediction = K.CreateHealthPrediction(self)
	elseif (unit == "party") then
		if (C["Unitframe"].PortraitTimer) then
			K.CreatePortraitTimer(self)
		end
		K.CreateRaidTargetIndicator(self)
		K.CreateGroupRoleIndicator(self)
		K.CreateResurrectIndicator(self)
		K.CreateAssistantIndicator(self)
		K.CreateLeaderIndicator(self)
		K.CreateMasterLooterIndicator(self)
		K.CreatePhaseIndicator(self)
		K.CreateReadyCheckIndicator(self)
		K.CreateThreatIndicator(self)
		self.HealthPrediction = K.CreateHealthPrediction(self)
	end

	self:RegisterEvent("PLAYER_TARGET_CHANGED", function()
		if (UnitExists("target")) then
			if (UnitIsEnemy("target", "player")) then
				PlaySound(PlaySoundKitID and "Igcreatureaggroselect" or SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
			elseif (UnitIsFriend("target", "player")) then
				PlaySound(PlaySoundKitID and "Igcharacternpcselect" or SOUNDKIT.IG_CHARACTER_NPC_SELECT)
			else
				PlaySound(PlaySoundKitID and "Igcreatureneutralselect" or SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT)
			end
		else
			PlaySound(PlaySoundKitID and "igcreatureaggrodeselect" or SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
		end
	end)

	self.Range = K.CreateRange(self)

	return self
end

oUF:RegisterStyle("oUF_Unitframes", oUF_Unitframes)
oUF:SetActiveStyle("oUF_Unitframes")

local player = oUF:Spawn("player", "oUF_Player")
player:SetSize(190, 52)
player:SetScale(C["Unitframe"].Scale)
player:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "TOPLEFT", -10, 200)
K.Movers:RegisterFrame(player)

local pet = oUF:Spawn("pet", "oUF_Pet")
pet:SetSize(116, 36)
pet:SetScale(C["Unitframe"].Scale)
pet:SetPoint("TOPRIGHT", oUF_Player, "BOTTOMLEFT", 56, 2)
K.Movers:RegisterFrame(pet)

local target = oUF:Spawn("target", "oUF_Target")
target:SetSize(190, 52)
target:SetScale(C["Unitframe"].Scale)
target:SetPoint("BOTTOMLEFT", ActionBarAnchor, "TOPRIGHT", 10, 200)
K.Movers:RegisterFrame(target)

local targettarget = oUF:Spawn("targettarget", "oUF_TargetTarget")
targettarget:SetSize(116, 36)
targettarget:SetScale(C["Unitframe"].Scale)
targettarget:SetPoint("TOPLEFT", oUF_Target, "BOTTOMRIGHT", -56, 2)
K.Movers:RegisterFrame(targettarget)

local focus = oUF:Spawn("focus", "oUF_Focus")
focus:SetSize(190, 52)
focus:SetScale(C["Unitframe"].Scale)
focus:SetPoint("BOTTOMRIGHT", oUF_Player, "TOPLEFT", -60, 30)
K.Movers:RegisterFrame(focus)

local focustarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
focustarget:SetSize(116, 36)
focustarget:SetScale(C["Unitframe"].Scale)
focustarget:SetPoint("TOPRIGHT", oUF_Focus, "BOTTOMLEFT", 56, 2)
K.Movers:RegisterFrame(focustarget)

if (C["Unitframe"].Party) then
	local party = oUF:SpawnHeader("oUF_Party", nil, (C["Raidframe"].RaidAsParty and "custom [group:party][group:raid] hide;show") or "custom [@raid6, exists] hide; show",
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"initial-width", 140,
	"initial-height", 38,
	"showSolo", false,
	"showParty", true,
	"showRaid", false,
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupBy", "GROUP",
	"showPlayer", C["Unitframe"].ShowPlayer, -- Need to add this as an option.
	"yOffset", -44
	)
	party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -200)
	party:SetScale(C["Unitframe"].Scale)
	K.Movers:RegisterFrame(party)
end

if (C["Unitframe"].ShowBoss) then
	local Boss = {}
	for i = 1, MAX_BOSS_FRAMES do
		Boss[i] = oUF:Spawn("boss"..i, "oUF_BossFrame"..i)
		Boss[i]:SetParent(K.PetBattleHider)

		Boss[i]:SetSize(190, 52)
		Boss[i]:SetScale(C["Unitframe"].Scale)
		if (i == 1) then
			Boss[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
		else
			Boss[i]:SetPoint("TOPLEFT", Boss[i-1], "BOTTOMLEFT", 0, -45)
		end
		K.Movers:RegisterFrame(Boss[i])
	end
end

if (C["Unitframe"].ShowArena) then
	local arena = {}
	for i = 1, 5 do
		arena[i] = oUF:Spawn("arena"..i, "oUF_ArenaFrame"..i)
		arena[i]:SetSize(190, 52)
		arena[i]:SetScale(C["Unitframe"].Scale)
		if (i == 1) then
			arena[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
		else
			arena[i]:SetPoint("TOPLEFT", arena[i-1], "BOTTOMLEFT", 0, -45)
		end
		K.Movers:RegisterFrame(arena[i])
	end
end

-- Test UnitFrames(by community)
local moving = false
function K.TestUnitframes(msg)
	if InCombatLockdown() then print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r") return end
	if not moving then
		for _, frames in pairs({"oUF_Target", "oUF_TargetTarget", "oUF_Pet", "oUF_Focus"}) do
			_G[frames].oldunit = _G[frames].unit
			_G[frames]:SetAttribute("unit", "player")
		end

		if C["Unitframe"].ShowArena == true then
			for i = 1, 5 do
				_G["oUF_ArenaFrame"..i].oldunit = _G["oUF_ArenaFrame"..i].unit
				_G["oUF_ArenaFrame"..i]:SetAttribute("unit", "player")
			end
		end

		if C["Unitframe"].ShowBoss == true then
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_BossFrame"..i].oldunit = _G["oUF_BossFrame"..i].unit
				_G["oUF_BossFrame"..i]:SetAttribute("unit", "player")
			end
		end
		moving = true
	else
		for _, frames in pairs({"oUF_Target", "oUF_TargetTarget", "oUF_Pet", "oUF_Focus"}) do
			_G[frames]:SetAttribute("unit", _G[frames].oldunit)
		end

		if C["Unitframe"].ShowArena == true then
			for i = 1, 5 do
				_G["oUF_ArenaFrame"..i]:SetAttribute("unit", _G["oUF_ArenaFrame"..i].oldunit)
			end
		end

		if C["Unitframe"].ShowBoss == true then
			for i = 1, MAX_BOSS_FRAMES do
				_G["oUF_BossFrame"..i]:SetAttribute("unit", _G["oUF_BossFrame"..i].oldunit)
			end
		end
		moving = false
	end
end
K:RegisterChatCommand("testui", K.TestUnitframes)
