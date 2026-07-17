--[[-----------------------------------------------------------------------------
-- Nameplate refresh, plate-type switching, oUF driver callbacks, aura layout.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")
local oUF = K.oUF
local NP = Module.NP

local ipairs = ipairs
local pairs = pairs
local string_find = string.find
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates
local C_Timer_After = C_Timer.After
local GetCVarBool = GetCVarBool
local UnitCanAttack = UnitCanAttack
local UnitGUID = UnitGUID
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitReaction = UnitReaction
local issecure = issecure

local IsSecret = K.IsSecret
local NotSecret = K.NotSecret
local platesList = NP.platesList
local ShowTargetNPCs = NP.ShowTargetNPCs

function Module:RegisterNameplate(plate)
	platesList[plate] = plate:GetName()
end

local SoftTargetBlockElements = {
	"Auras",
	"RaidTargetIndicator",
}

local DisabledElements = {
	"Castbar",
	"HealthPrediction",
	"Health",
	"PvPClassificationIndicator",
	"ThreatIndicator",
}

function Module:ToggleNameplateAuras()
	local isEnabled = C["Nameplate"].PlateAuras
	if isEnabled then
		if not self:IsElementEnabled("Auras") then
			self:EnableElement("Auras")
		end
	else
		if self:IsElementEnabled("Auras") then
			self:DisableElement("Auras")
		end
	end
end

function Module:UpdateNameplateAuras()
	Module.ToggleNameplateAuras(self)

	if not C["Nameplate"].PlateAuras then
		return
	end

	local element = self.Auras
	element:ClearAllPoints()
	if C["Nameplate"].NameplateClassPower then
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6 + C["Nameplate"].PlateHeight)
		element:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 6 + C["Nameplate"].PlateHeight)
	else
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
		element:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 5)
	end

	element.numTotal = C["Nameplate"].MaxAuras
	element.size = C["Nameplate"].AuraSize
	element.showDebuffType = true
	Module:UpdateAuraContainer(self:GetWidth(), element, element.numTotal)

	element:ForceUpdate()
end

function Module:UpdateNameplateSize()
	if self.plateType == "NameOnly" then
		self:Tag(self.nameText, "[nprare][color][name] [nplevel]")
		self.npcTitle:UpdateTag()
	else
		self.nameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
		self.nameText:SetPoint("BOTTOMRIGHT", self.levelText, "TOPRIGHT", -21, 4)
		self:Tag(self.nameText, "[nprare][name]")
		self.healthValue:UpdateTag()

		self:SetSize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight)
	end

	self.nameText:UpdateTag()
	Module:RefreshCastOverlay(self)
end

function Module:RefreshNameplates()
	Module:UpdateExecuteCurve()
	for nameplate in pairs(platesList) do
		Module.UpdateNameplateSize(nameplate)
		Module.UpdateUnitClassify(nameplate)
		Module.UpdateNameplateAuras(nameplate)
		Module.UpdateTargetIndicator(nameplate)
		Module.UpdateTargetChange(nameplate)
		Module:RefreshCastOverlay(nameplate)
	end
	Module:UpdateClickableSize()
end

function Module:UpdateNameplateSmooth()
	local enabled = C["Nameplate"].Smooth
	for nameplate in pairs(platesList) do
		if enabled then
			K:SmoothBar(nameplate.Health)
		else
			K:DesmoothBar(nameplate.Health)
		end
	end
end

function Module:RefreshAllPlates()
	Module:RefreshNameplates()
	Module:ResizeTargetPower()
end

function Module:InitNameplates()
	if not C["Nameplate"].Enable or Module.NameplateDriver or not oUF then
		return
	end

	Module:BlockAddons()
	Module:CreateUnitTable()
	Module:CreatePowerUnitTable()
	Module:UpdateGroupRoles()
	Module:QuestIconCheck()
	Module:RefreshPlateOnFactionChanged()

	oUF:RegisterStyle("Nameplates", Module.CreatePlates)
	oUF:SetActiveStyle("Nameplates")

	Module.NameplateDriver = oUF:SpawnNamePlates("oUF_NPs")
	Module.NameplateDriver:SetAddedCallback(Module.PostUpdatePlates)
	Module.NameplateDriver:SetRemovedCallback(Module.PostUpdatePlates)
	-- Target swaps between visible plates never hit ADD — reparent class power here.
	Module.NameplateDriver:SetTargetCallback(function()
		if Module.ScheduleUpdateTargetClassPower then
			Module:ScheduleUpdateTargetClassPower()
		end
	end)
	Module:SetupCVars()
end

local function registerNameplateDriverEvents()
	local driver = Module.NameplateDriver
	if not driver then
		return
	end

	driver:RegisterEvent("NAME_PLATE_UNIT_ADDED")
	driver:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
	driver:RegisterEvent("PLAYER_TARGET_CHANGED")
end

local function setBlizzardNameplatesVisible(showBlizzard)
	local blizzDriver = _G.NamePlateDriverFrame
	if not blizzDriver or not blizzDriver.ForEachNamePlate then
		return
	end

	blizzDriver:ForEachNamePlate(function(frame)
		local oUFPlate = frame.unitFrame
		if oUFPlate then
			oUFPlate:SetShown(not showBlizzard)
		end

		local blizz = frame.UnitFrame
		if blizz then
			blizz:SetParent(frame)
			blizz:SetShown(showBlizzard)
		end
	end)

	if showBlizzard and blizzDriver.UpdateNamePlateOptions then
		blizzDriver:UpdateNamePlateOptions()
	end
end

local function refreshActiveKkNameplates()
	for plate in pairs(platesList) do
		if plate:IsShown() then
			local unit = plate.unit
			if unit then
				Module.PostUpdatePlates(plate, "NAME_PLATE_UNIT_ADDED", unit)
				plate:UpdateAllElements("NAME_PLATE_UNIT_ADDED")
			end
		end
	end
	Module:RefreshNameplates()
end

function Module:SetNameplatesEnabled(enabled)
	if enabled then
		Module._nameplatesSuspended = false
		Module:InitNameplates()
		registerNameplateDriverEvents()
		if Module.NameplateDriver then
			Module:SetupCVars()
			setBlizzardNameplatesVisible(false)
			for plate in pairs(platesList) do
				plate:Show()
			end
			refreshActiveKkNameplates()
			Module:RefreshPlateOnFactionChanged()
		end
	else
		Module._nameplatesSuspended = true

		local driver = Module.NameplateDriver
		if driver then
			driver:UnregisterAllEvents()
		end

		Module:ClearAllCastOverlays()

		for plate in pairs(platesList) do
			plate:Hide()
			if plate.Castbar then
				plate.Castbar:Hide()
			end
		end

		setBlizzardNameplatesVisible(true)
		Module:RestorePlateCVars()

		K:UnregisterEvent("UNIT_FACTION", Module.OnUnitFactionChanged)
		K:UnregisterEvent("PLAYER_SOFT_INTERACT_CHANGED", Module.OnUnitSoftTargetChanged)
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.OnNameplateRegenEnabled)
	end
end

function Module:UpdatePlateByType()
	local name = self.nameText
	local level = self.levelText
	local hpval = self.healthValue
	local title = self.npcTitle
	local guild = self.guildName
	local raidtarget = self.RaidTargetIndicator
	local questIcon = self.questIcon
	local questCount = self.questCount

	local shouldHideName = self.widgetsOnly
	if shouldHideName then
		name:Hide()
	else
		name:Show()
		name:UpdateTag()
		name:ClearAllPoints()
	end
	raidtarget:ClearAllPoints()

	if self.isSoftTarget then
		for _, element in ipairs(SoftTargetBlockElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end
	else
		for _, element in ipairs(SoftTargetBlockElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end
	end

	if self.plateType == "NameOnly" then
		for _, element in ipairs(DisabledElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end

		-- REASON: Centered to match the centered health-value text on the bar below.
		name:SetJustifyH("CENTER")
		name:SetPoint("CENTER", self, "BOTTOM")
		name:Show()
		name:UpdateTag()

		level:Hide()
		hpval:Hide()
		title:Show()
		guild:Show()

		raidtarget:SetPoint("BOTTOM", name, "TOP", 0, 6)

		if questIcon then
			questIcon:SetPoint("LEFT", name, "RIGHT", -4, 0)
			if questCount then
				questCount:SetPoint("LEFT", name, "RIGHT", -0, 0)
			end
		end

		if self.widgetContainer then
			self.widgetContainer:ClearAllPoints()
			self.widgetContainer:SetPoint("TOP", title, "BOTTOM", 0, -10)
		end
	else
		for _, element in ipairs(DisabledElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end

		-- REASON: Left-aligned (see Style.lua for why) so the classify icon anchored to
		-- this frame's edge in Widgets.lua stays adjacent to the visible text.
		name:SetJustifyH("LEFT")

		level:Show()
		hpval:Show()
		title:Hide()
		guild:Hide()

		raidtarget:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)

		if questIcon then
			questIcon:SetPoint("LEFT", self, "RIGHT", 4, 0)
			if questCount then
				questCount:SetPoint("LEFT", self, "RIGHT", 4, 0)
			end
		end

		if self.widgetContainer then
			self.widgetContainer:ClearAllPoints()
			self.widgetContainer:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -6)
		end

		name:Show()
		name:UpdateTag()
	end

	Module.UpdateNameplateSize(self)
	Module.UpdateTargetIndicator(self)
	Module.ToggleNameplateAuras(self)
end

function Module:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack("player", unit)
	self.isSoftTarget = UnitIsUnit(unit, "softinteract")

	local forceShow = C.NameplateForceShow and ((self.npcID and C.NameplateForceShow[self.npcID]) or (self.unitName and C.NameplateForceShow[self.unitName]))

	if forceShow then
		self.plateType = "None"
	elseif (C["Nameplate"].NameOnly and self.isFriendly) or self.widgetsOnly or self.isSoftTarget then
		self.plateType = "NameOnly"
	else
		self.plateType = "None"
	end

	if self.previousType == nil or self.previousType ~= self.plateType then
		Module.UpdatePlateByType(self)
		self.previousType = self.plateType
	end
end

function Module.OnUnitFactionChanged(event, unit)
	if not unit or not string_find(unit, "nameplate") then
		return
	end

	local nameplate = C_NamePlate_GetNamePlateForUnit(unit, issecure())
	local unitFrame = nameplate and nameplate.unitFrame
	if unitFrame and unitFrame.unitName then
		Module.RefreshPlateType(unitFrame, unit)
	end
end

function Module.OnUnitSoftTargetChanged(event, previousTarget, currentTarget)
	if not GetCVarBool("SoftTargetIconGameObject") then
		return
	end

	for _, nameplate in ipairs(C_NamePlate_GetNamePlates()) do
		local unitFrame = nameplate and nameplate.unitFrame
		local guid = unitFrame and unitFrame.unitGUID
		if guid and (guid == previousTarget or guid == currentTarget) then
			unitFrame.previousType = nil
			Module.RefreshPlateType(unitFrame, unitFrame.unit)
			Module.UpdateTargetChange(unitFrame)
		end
	end
end

function Module.OnNameplateRegenEnabled()
	if Module._nameplatesSuspended then
		return
	end

	C_Timer_After(0, function()
		for plate in pairs(platesList) do
			if plate.unit and plate.Health then
				if plate.Health.ForceUpdate then
					plate.Health:ForceUpdate()
				else
					Module.UpdateColor(plate, nil, plate.unit)
				end
			end
		end
	end)
end

function Module:RefreshPlateOnFactionChanged()
	K:UnregisterEvent("UNIT_FACTION", Module.OnUnitFactionChanged)
	K:UnregisterEvent("PLAYER_SOFT_INTERACT_CHANGED", Module.OnUnitSoftTargetChanged)
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.OnNameplateRegenEnabled)

	K:RegisterEvent("UNIT_FACTION", Module.OnUnitFactionChanged)
	K:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED", Module.OnUnitSoftTargetChanged)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.OnNameplateRegenEnabled)
end

function Module:PostUpdatePlates(event, unit)
	if Module._nameplatesSuspended then
		return
	end

	if not self then
		return
	end

	if event == "NAME_PLATE_UNIT_ADDED" then
		local name = UnitName(unit)
		self.unitName = not IsSecret(name) and name or nil
		local guid = UnitGUID(unit)
		self.unitGUID = not IsSecret(guid) and guid or nil
		local isPlayer = UnitIsPlayer(unit)
		self.isPlayer = NotSecret(isPlayer) and isPlayer or false
		local canAttack = UnitCanAttack("player", unit)
		self.isFriendly = NotSecret(canAttack) and not canAttack or false
		self.npcID = K.GetNPCID(self.unitGUID)
		self.isCustomUnit = (self.unitName and NP.customUnits[self.unitName]) or NP.customUnits[self.npcID]
		self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

		local blizzPlate = self:GetParent().UnitFrame
		if blizzPlate then
			self.widgetContainer = blizzPlate.WidgetContainer
			if self.widgetContainer then
				self.widgetContainer:SetScale(1 / C["General"].UIScale)
			end

			self.softTargetFrame = blizzPlate.SoftTargetFrame
			if self.softTargetFrame then
				self.softTargetFrame:SetScale(1 / C["General"].UIScale)
			end
		end

		Module.RefreshPlateType(self, unit)

		if self.nameText and self.plateType == "NameOnly" then
			C_Timer_After(0.25, function()
				if self.nameText and self:IsShown() then
					self.nameText:UpdateTag()
				end
			end)
		end
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self.npcID = nil
	end

	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		Module.UpdateUnitPower(self)
		Module.UpdateTargetChange(self)
		Module.UpdateQuestUnit(self, event, unit)
		Module.UpdateUnitClassify(self, unit)
		Module.UpdateDungeonProgress(self, unit)
		Module:UpdateClassIcon(self, unit)
		Module:UpdateTargetClassPower()

		self.tarName:SetShown(ShowTargetNPCs[self.npcID])
	end
end
