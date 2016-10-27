local K, C, L = select(2, ...):unpack()
--[[
local _, ns = ...
local oUF = ns.oUF

local function CreateVirtualFrame(frame, point)
	if point == nil then point = frame end

	if point.backdrop then return end
	frame.backdrop = CreateFrame("Frame", nil , frame)
	frame.backdrop:SetAllPoints()
	frame.backdrop:SetBackdrop({
		bgFile = C.Media.Blank,
		edgeFile = C.Media.Glow,
		edgeSize = 3 * K.NoScaleMult,
		insets = {top = 3 * K.NoScaleMult, left = 3 * K.NoScaleMult, bottom = 3 * K.NoScaleMult, right = 3 * K.NoScaleMult}
	})
	frame.backdrop:SetPoint("TOPLEFT", point, -3 * K.NoScaleMult, 3 * K.NoScaleMult)
	frame.backdrop:SetPoint("BOTTOMRIGHT", point, 3 * K.NoScaleMult, -3 * K.NoScaleMult)
	frame.backdrop:SetBackdropColor(.05, .05, .05, .9)
	frame.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

	if frame:GetFrameLevel() - 1 > 0 then
		frame.backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
	else
		frame.backdrop:SetFrameLevel(0)
	end
end

local whitelist = {
	["Arcane Torrent"] = true,
	["War Stomp"] = true,
}
local blacklist = {

}
local mine = {

}

SetCVar("nameplateShowAll",1)
SetCVar("nameplateMaxAlpha",0.5)
SetCVar("nameplateMaxDistance",50)
SetCVar("nameplateShowEnemies",1)
SetCVar("nameplateMinScale",1)
SetCVar("nameplateLargerScale",1)
SetCVar("nameplateOtherTopInset", -1); -- Default 0.08
SetCVar("nameplateOtherBottomInset", -1); -- Default 0.1

local function getcolor(unit)
	local reaction = UnitReaction(unit, "player") or 5

	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		local color = RAID_CLASS_COLORS[class]
		return color.r, color.g, color.b
	elseif UnitCanAttack("player", unit) then
		if UnitIsDead(unit) then
			return 136/255, 136/255, 136/255
		else
			if reaction < 4 then
				return unpack(K.Colors.reaction[1])
			elseif reaction == 4 then
				return unpack(K.Colors.reaction[4])
			end
		end
	else
		if reaction < 4 then
			return unpack(K.Colors.reaction[5])
		else
			return 255/255, 255/255, 255/255
		end
	end
end

local function threatColor(self, forced)
	if (UnitIsPlayer(self.unit)) then return end
	local healthbar = self.Health
	local combat = UnitAffectingCombat("player")
	local threat = select(2, UnitDetailedThreatSituation("player", self.unit));
	local targeted = select(1, UnitDetailedThreatSituation("player", self.unit));

	if (UnitIsTapDenied(self.unit)) then
		healthbar:SetStatusBarColor(.5,.5,.5)
	elseif(combat) then

		if(threat and threat >= 1) then
			if(threat == 3) then
				healthbar:SetStatusBarColor(unpack(K.Colors.reaction[1]))
			elseif (threat == 2 or threat == 1 or targeted) then
				healthbar:SetStatusBarColor(unpack(K.Colors.reaction[5]))
			end
		else
			healthbar:SetStatusBarColor(112/255, 51/255, 112/255)
		end
	elseif (not forced) then
		self.Health:ForceUpdate()
	end
end

local function callback(event,nameplate,unit)
	local unit = unit or "target"
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local self = nameplate.ouf

	if (UnitIsUnit(unit,"player")) then
		self.Name:Hide()
		self.Power:Show()
		self.Castbar:Hide()
	else
		self.Name:Show()
		self.Power:Hide()
		self.Castbar:Show()
	end
end

local function style(self,unit)
	local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
	local main = self
	nameplate.ouf = self
	self.unit = unit
	self:SetScript("OnEnter", function()
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetUnit(self.unit)
		GameTooltip:Show()
	end)
	self:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	self:SetPoint("CENTER", nameplate, "CENTER")
	self:SetScale(K.NoScaleMult)
	self:SetSize(C.Nameplates.Width, C.Nameplates.Height)

	self.Name = self:CreateFontString(nil)
	self.Name:SetFont(C.Media.Font, 14)
	self.Name:SetShadowOffset(1, -1)
	self.Name:SetPoint("BOTTOM", self, "TOP", 0, 6)
	self:Tag(self.Name, "[kkthnx:name]")

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetStatusBarTexture(C.Media.Texture)
	self.Health:SetAllPoints(self)
	self.Health.frequentUpdates = true
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.colorHealth = true
	CreateVirtualFrame(self.Health)

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(C.Media.Texture)
	self.Power:ClearAllPoints()
	self.Power:SetFrameLevel(5)
	self.Power:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Power:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 12)
	self.Power.frequentUpdates = true
	self.Power.colorPower = true
	CreateVirtualFrame(self.Power)

	self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

	self.Health:SetScript("OnEvent",function()
		threatColor(main)
	end)
	function self.Health:PostUpdate()
		threatColor(main,true)
	end

	-- Absorb
	--self.TotalAbsorb = CreateFrame("StatusBar", nil, self.Health)
	--self.TotalAbsorb:SetAllPoints(self.Health)
	--self.TotalAbsorb:SetStatusBarTexture(C.Media.Texture)
	--self.TotalAbsorb:SetStatusBarColor(.1, .1, .1, .6)

	-- Raid Icon
	self.RaidIcon = self:CreateTexture(nil, "OVERLAY",nil,7)
	self.RaidIcon:SetSize(14, 14)
	self.RaidIcon:SetPoint("LEFT", self, "RIGHT", 6, 0)

	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 28)
	self.Auras:SetSize(C.Nameplates.AurasSize, C.Nameplates.AurasSize)
	self.Auras:EnableMouse(false)
	self.Auras.size = C.Nameplates.AurasSize
	self.Auras.initialAnchor = "BOTTOMLEFT"
	self.Auras.spacing = 2
	self.Auras.num = 20
	self.Auras["growth-y"] = "UP"
	self.Auras["growth-x"] = "RIGHT"

	self.Auras.CustomFilter = function(icons, unit, name, rank, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID, canApplyAura, isBossDebuff, _, nameplateShowAll)
		local allow = false

		if (nameplateShowAll or (nameplateShowPersonal and caster == "player")) then
			allow = true
		end
		if (K.NameplatesWhitelist and K.NameplatesWhitelist[name]) then
			allow = true
		end
		if (K.NameplatesSelfWhitelist and K.NameplatesSelfWhitelist[name]) then
			allow = true
		end
		if (K.NameplatesBlacklist and K.NameplatesBlacklist[name]) then
			allow = false
		end

		return allow
	end

	self.Auras.PostUpdateIcon = function(Auras, unit, button)
		CreateVirtualFrame(button)
		button.cd:GetRegions():SetAlpha(0)
		button:EnableMouse(false)
		button.icon:SetTexCoord(0.08, 0.9, 0.08, 0.9)
		button:SetHeight(C.Nameplates.AurasSize * 16/25)
	end

	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetFrameLevel(3)
	self.Castbar:SetStatusBarTexture(C.Media.Texture)
	self.Castbar:SetStatusBarColor(.1, .4, .7, 1)
	self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -2)
	self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -12)
	CreateVirtualFrame(self.Castbar)

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
	self.Castbar.Text:SetFont(C.Media.Font, 11, "OUTLINE")
	self.Castbar.Text:SetJustifyH("RIGHT")
	self.Castbar.Text:SetPoint("CENTER", self.Castbar, "CENTER")

	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Castbar.Icon:SetDrawLayer("ARTWORK")
	self.Castbar.Icon:SetSize(C.Nameplates.Height + 12, C.Nameplates.Height + 12)
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT",self.Castbar, "BOTTOMLEFT", -4, 0)

	self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
	self.Castbar.bg:SetTexture(C.Media.Blank)
	self.Castbar.bg:SetVertexColor(unpack(C.Media.Nameplate_BorderColor))
	self.Castbar.bg:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -1, 1)
	self.Castbar.bg:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", 1, -1)

	self.Castbar.PostCastStart = function(self,unit, name, castid)
		local interrupt = select(9, UnitCastingInfo(unit))
		if (interrupt) then
			self.Icon:SetDesaturated(1)
			self:SetStatusBarColor(.7, .7, .7, 1)
		else
			self.Icon:SetDesaturated(false)
			self:SetStatusBarColor(.1, .4, .7, 1)
		end
	end

end

oUF:RegisterStyle("oUF_KkthnxPlates", style)
oUF:SpawnNamePlates("oUF_KkthnxPlates", "oUF_KkthnxPlates", callback)
--]]

local Skinning = CreateFrame("Frame")

local unpack = unpack
local function LoadSkin()
	--if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.objectiveTracker ~= true then return end
	ObjectiveTrackerBlocksFrame.QuestHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetFont(C.Media.Font, 14)
	ObjectiveTrackerBlocksFrame.AchievementHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetFont(C.Media.Font, 14)
	ObjectiveTrackerBlocksFrame.ScenarioHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetFont(C.Media.Font, 14)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header:StripTextures()
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetFont(C.Media.Font, 14)
	WORLD_QUEST_TRACKER_MODULE.Header:StripTextures()
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetFont(C.Media.Font, 14)

	--Skin ObjectiveTrackerFrame item buttons
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(25, 25)
			item:SetTemplate("Transparent")
			item:StyleButton()
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(unpack(K.TexCoords))
			item.icon:SetPoint("TOPLEFT", item, 2, -2)
			item.icon:SetPoint("BOTTOMRIGHT", item, -2, 2)
			item.Cooldown:SetAllPoints(item.icon)
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(C.Media.Font, 14, "OUTLINE")
			item.Count:SetShadowOffset(1, -1)
			item.skinned = true
		end
	end)

	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", function(_, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(25, 25)
			item:SetTemplate("Transparent")
			item:StyleButton()
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(unpack(E.TexCoords))
			item.icon:SetPoint("TOPLEFT", item, 2, -2)
			item.icon:SetPoint("BOTTOMRIGHT", item, -2, 2)
			item.Cooldown:SetAllPoints(item.icon)
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(C.Media.Font, 14, "OUTLINE")
			item.Count:SetShadowOffset(5, -5)
			item.skinned = true
		end
	end)
end

Skinning:RegisterEvent("PLAYER_LOGIN")
Skinning:SetScript("OnEvent", LoadSkin)