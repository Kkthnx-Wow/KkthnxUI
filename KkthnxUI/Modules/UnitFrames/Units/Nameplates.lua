local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF

local _G = _G
local math_floor = _G.math.floor
local math_rad = _G.math.rad
local pairs = _G.pairs
local string_format = _G.string.format
local string_match = _G.string.match
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local unpack = _G.unpack

local Ambiguate = _G.Ambiguate
local C_MythicPlus_GetCurrentAffixes = _G.C_MythicPlus.GetCurrentAffixes
local C_NamePlate_GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit
local C_NamePlate_SetNamePlateEnemySize = _G.C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlySize = _G.C_NamePlate.SetNamePlateFriendlySize
local C_Scenario_GetCriteriaInfo = _G.C_Scenario.GetCriteriaInfo
local C_Scenario_GetInfo = _G.C_Scenario.GetInfo
local C_Scenario_GetStepInfo = _G.C_Scenario.GetStepInfo
local CreateFrame = _G.CreateFrame
local GetInstanceInfo = _G.GetInstanceInfo
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetNumSubgroupMembers = _G.GetNumSubgroupMembers
local GetPlayerInfoByGUID = _G.GetPlayerInfoByGUID
local INTERRUPTED = _G.INTERRUPTED
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local SetCVar = _G.SetCVar
local UnitClassification = _G.UnitClassification
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitIsConnected = _G.UnitIsConnected
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitIsUnit = _G.UnitIsUnit
local UnitName = _G.UnitName
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitReaction = _G.UnitReaction
local UnitSelectionColor = _G.UnitSelectionColor
local UnitThreatSituation = _G.UnitThreatSituation
local hooksecurefunc = _G.hooksecurefunc

local aksCacheData = {}
local guidToPlate = {}
local hasExplosives
local explosivesID = 120651
local groupRoles, isInGroup = {}
local isInInstance
local isTargetClassPower

-- Unit classification
local classify = {
	elite = {1, 1, 1},
	rare = {1, 1, 1, true},
	rareelite = {1, 0.1, 0.1},
	worldboss = {0, 1, 0},
}

-- Init
function Module:PlateInsideView()
	if C["Nameplate"].InsideView then
		SetCVar("nameplateOtherTopInset", 0.05)
		SetCVar("nameplateOtherBottomInset", 0.08)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end
end

function Module:UpdatePlateScale()
	SetCVar("namePlateMinScale", C["Nameplate"].MinScale)
	SetCVar("namePlateMaxScale", C["Nameplate"].MinScale)
end

function Module:UpdatePlateAlpha()
	SetCVar("nameplateMinAlpha", C["Nameplate"].MinAlpha)
	SetCVar("nameplateMaxAlpha", C["Nameplate"].MinAlpha)
end

function Module:UpdatePlateRange()
	SetCVar("nameplateMaxDistance", C["Nameplate"].Distance)
end

function Module:UpdatePlateSpacing()
	SetCVar("nameplateOverlapV", C["Nameplate"].VerticalSpacing)
end

function Module:UpdateClickableSize()
	if InCombatLockdown() then
		return
	end

	C_NamePlate_SetNamePlateEnemySize(C["Nameplate"].PlateWidth * C["General"].UIScale, C["Nameplate"].PlateHeight * C["General"].UIScale + 40)
	C_NamePlate_SetNamePlateFriendlySize(C["Nameplate"].PlateWidth * C["General"].UIScale, C["Nameplate"].PlateHeight * C["General"].UIScale + 40)
end

function Module:SetupCVars()
	Module:PlateInsideView()
	SetCVar("nameplateOverlapH", 0.8)
	Module:UpdatePlateSpacing()
	Module:UpdatePlateRange()
	Module:UpdatePlateAlpha()
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("showQuestTrackingTooltips", 1)
	SetCVar("nameplateGlobalScale", 1)

	Module:UpdatePlateScale()
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)

	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateResourceOnTarget", 0)
	K.HideInterfaceOption(_G.InterfaceOptionsNamesPanelUnitNameplatesPersonalResource)
	K.HideInterfaceOption(_G.InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy)

	Module:UpdateClickableSize()
	hooksecurefunc(_G.NamePlateDriverFrame, "UpdateNamePlateOptions", Module.UpdateClickableSize)
end

function Module:BlockAddons()
	if not _G.DBM or not _G.DBM.Nameplate then
		return
	end

	function _G.DBM.Nameplate:SupportedNPMod()
		return true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then
			return
		end

		if not C.NameplateWhiteList[spellID] then
			C.NameplateWhiteList[spellID] = true
		end
	end

	hooksecurefunc(_G.DBM.Nameplate, "Show", showAurasForDBM)
end

function Module:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = C.NameplateShowPowerList[unitName] or C.NameplateShowPowerList[npcID]
	if shouldShowPower then
		self.powerText:Show()
	else
		self.powerText:Hide()
	end
end

-- Off-tank threat color
local function refreshGroupRoles()
	local isInRaid = IsInRaid()
	isInGroup = isInRaid or IsInGroup()
	table_wipe(groupRoles)

	if isInGroup then
		local numPlayers = (isInRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()
		local unit = (isInRaid and "raid") or "party"
		for i = 1, numPlayers do
			local index = unit..i
			if UnitExists(index) then
				groupRoles[UnitName(index)] = UnitGroupRolesAssigned(index)
			end
		end
	end
end

local function resetGroupRoles()
	isInGroup = IsInRaid() or IsInGroup()
	table_wipe(groupRoles)
end

function Module:UpdateGroupRoles()
	refreshGroupRoles()
	K:RegisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	K:RegisterEvent("GROUP_LEFT", resetGroupRoles)
end

function Module:CheckTankStatus(unit)
	local index = unit.."target"
	local unitRole = isInGroup and UnitExists(index) and not UnitIsUnit(index, "player") and groupRoles[UnitName(index)] or "NONE"
	if unitRole == "TANK" and K.Role == "Tank" then
		self.feedbackUnit = index
		self.isOffTank = true
	else
		self.feedbackUnit = "player"
		self.isOffTank = false
	end
end

-- Update unit color
function Module:UpdateColor(_, unit)
	if not unit or self.unit ~= unit then
		return
	end

	local element = self.Health
	local name = self.unitName
	local npcID = self.npcID
	local isCustomUnit = C.NameplateCustomUnits[name] or C.NameplateCustomUnits[npcID]
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local status = self.feedbackUnit and UnitThreatSituation(self.feedbackUnit, unit) or false -- just in case
	local reaction = UnitReaction(unit, "player")

	local customColor = C["Nameplate"].CustomColor
	local insecureColor = C["Nameplate"].InsecureColor
	local offTankColor = C["Nameplate"].OffTankColor
	local reactionColor = K.Colors.reaction[reaction]
	local revertThreat = C["Nameplate"].DPSRevertThreat
	local secureColor = C["Nameplate"].SecureColor
	local transColor = C["Nameplate"].TransColor

	local executeRatio = C["Nameplate"].ExecuteRatio
	local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit) + .0001) * 100

	local r, g, b
	if not UnitIsConnected(unit) then
		r, g, b = 0.7, 0.7, 0.7
	else
		if isCustomUnit then
			r, g, b = customColor[1], customColor[2], customColor[3]
		elseif isPlayer and isFriendly then
			if C["Nameplate"].FriendlyCC then
				r, g, b = K.UnitColor(unit)
			else
				r, g, b = unpack(K.Colors.power["MANA"])
			end
		elseif isPlayer and (not isFriendly) and C["Nameplate"].HostileCC then
			r, g, b = K.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			r, g, b = .6, .6, .6
		else
			if reaction then
				r, g, b = reactionColor[1], reactionColor[2], reactionColor[3]
			else
				r, g, b = UnitSelectionColor(unit, true)
			end

			if status and (C["Nameplate"].TankMode or K.Role == "Tank") then
				if status == 3 then
					if K.Role ~= "Tank" and revertThreat then
						r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
					else
						if self.isOffTank then
							r, g, b = offTankColor[1], offTankColor[2], offTankColor[3]
						else
							r, g, b = secureColor[1], secureColor[2], secureColor[3]
						end
					end
				elseif status == 2 or status == 1 then
					r, g, b = transColor.r, transColor.g, transColor.b
				elseif status == 0 then
					if K.Role ~= "Tank" and revertThreat then
						r, g, b = secureColor[1], secureColor[2], secureColor[3]
					else
						r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
					end
				end
			end
		end
	end

	if r or g or b then
		element:SetStatusBarColor(r, g, b)
	end

	if isCustomUnit or (not C["Nameplate"].TankMode and K.Role ~= "Tank") then
		if status and status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status and (status == 2 or status == 1) then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		else
			self.ThreatIndicator:Hide()
		end
	else
		self.ThreatIndicator:Hide()
	end

	if executeRatio > 0 and healthPerc <= executeRatio then
		self.nameText:SetTextColor(1, 0, 0)
	else
		self.nameText:SetTextColor(1, 1, 1)
	end
end

function Module:UpdateThreatColor(_, unit)
	if unit ~= self.unit then
		return
	end

	Module.CheckTankStatus(self, unit)
	Module.UpdateColor(self, _, unit)
end

-- Backdrop shadow
function Module:CreateThreatColor(self)
	local threatIndicator = self:CreateShadow()
	threatIndicator:SetPoint("TOPLEFT", self.Health.backdrop, "TOPLEFT", -1, 1)
	threatIndicator:SetPoint("BOTTOMRIGHT", self.Health.backdrop, "BOTTOMRIGHT", 1, -1)
	threatIndicator:Hide()

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = Module.UpdateThreatColor
end

-- Target indicator
function Module:UpdateTargetChange()
	local element = self.TargetIndicator
	if C["Nameplate"].TargetIndicator.Value == 1 then
		return
	end

	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		element:Show()
	else
		element:Hide()
	end
end

function Module:UpdateTargetIndicator()
	local style = C["Nameplate"].TargetIndicator.Value

	local element = self.TargetIndicator
	local isNameOnly = self.isNameOnly
	if style == 1 then
		element:Hide()
	else
		if style == 2 then
			element.TopArrow:Show()
			element.RightArrow:Hide()
			element.Glow:Hide()
			element.nameGlow:Hide()
		elseif style == 3 then
			element.TopArrow:Hide()
			element.RightArrow:Show()
			element.Glow:Hide()
			element.nameGlow:Hide()
		elseif style == 4 then
			element.TopArrow:Hide()
			element.RightArrow:Hide()
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		elseif style == 5 then
			element.TopArrow:Show()
			element.RightArrow:Hide()
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		elseif style == 6 then
			element.TopArrow:Hide()
			element.RightArrow:Show()
			if isNameOnly then
				element.Glow:Hide()
				element.nameGlow:Show()
			else
				element.Glow:Show()
				element.nameGlow:Hide()
			end
		end
		element:Show()
	end
end

function Module:AddTargetIndicator(self)
	self.TargetIndicator = CreateFrame("Frame", nil, self)
	self.TargetIndicator:SetAllPoints()
	self.TargetIndicator:SetFrameLevel(0)
	self.TargetIndicator:Hide()

	self.TargetIndicator.TopArrow = self.TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	self.TargetIndicator.TopArrow:SetSize(50, 50)
	self.TargetIndicator.TopArrow:SetTexture(C["Media"].NPArrow)
	self.TargetIndicator.TopArrow:SetPoint("BOTTOM", self.TargetIndicator, "TOP", 0, 40)
	self.TargetIndicator.TopArrow:SetRotation(math_rad(-90))

	self.TargetIndicator.RightArrow = self.TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	self.TargetIndicator.RightArrow:SetSize(50, 50)
	self.TargetIndicator.RightArrow:SetTexture(C["Media"].NPArrow)
	self.TargetIndicator.RightArrow:SetPoint("LEFT", self.TargetIndicator, "RIGHT", 3, 0)
	self.TargetIndicator.RightArrow:SetRotation(math_rad(-180))

	self.TargetIndicator.Glow = CreateFrame("Frame", nil, self.TargetIndicator, "BackdropTemplate")
	self.TargetIndicator.Glow:SetPoint("TOPLEFT", self.Health.backdrop, -2, 2)
	self.TargetIndicator.Glow:SetPoint("BOTTOMRIGHT", self.Health.backdrop, 2, -2)
	self.TargetIndicator.Glow:SetBackdrop({edgeFile = C["Media"].Glow, edgeSize = 4})
	self.TargetIndicator.Glow:SetBackdropBorderColor(unpack(C["Nameplate"].TargetIndicatorColor))
	self.TargetIndicator.Glow:SetFrameLevel(0)

	self.TargetIndicator.nameGlow = self.TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	self.TargetIndicator.nameGlow:SetSize(150, 80)
	self.TargetIndicator.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	self.TargetIndicator.nameGlow:SetVertexColor(102/255, 157/255, 255/255)
	self.TargetIndicator.nameGlow:SetBlendMode("ADD")
	self.TargetIndicator.nameGlow:SetPoint("CENTER", self, "BOTTOM")

	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateTargetChange, true)
	Module.UpdateTargetIndicator(self)
end

local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function Module:QuestIconCheck()
	if not C["Nameplate"].QuestIndicator then
		return
	end

	CheckInstanceStatus()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

function Module:UpdateQuestUnit(_, unit)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local isLootQuest, questProgress
	K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetUnit(unit)

	for i = 2, K.ScanTooltip:NumLines() do
		local textLine = _G[K.ScanTooltip:GetName().."TextLeft"..i]
		local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			if r > 0.99 and g > 0.82 and b == 0 then
				if isInGroup and text == K.Name or not isInGroup then
					isLootQuest = true

					local questLine = _G[K.ScanTooltip:GetName().."TextLeft"..(i + 1)]
					local questText = questLine:GetText()
					if questLine and questText then
						local current, goal = string_match(questText, "(%d+)/(%d+)")
						local progress = string_match(questText, "(%d+)%%")
						if current and goal then
							current = tonumber(current)
							goal = tonumber(goal)
							if current == goal then
								isLootQuest = nil
							elseif current < goal then
								questProgress = goal - current
								break
							end
						elseif progress then
							progress = tonumber(progress)
							if progress == 100 then
								isLootQuest = nil
							elseif progress < 100 then
								questProgress = progress.."%"
								--break -- lower priority on progress
							end
						end
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetTexture("Interface\\WorldMap\\Skull_64Grey")
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas("QuestNormal")
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

function Module:AddQuestIcon(self)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	self.questIcon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	self.questIcon:SetPoint("LEFT", self, "RIGHT", 1, 0)
	self.questIcon:SetSize(25, 25)
	self.questIcon:SetAtlas("QuestNormal")
	self.questIcon:Hide()

	self.questCount = K.CreateFontString(self, 13, "", "", nil, "LEFT", 0, 0)
	self.questCount:SetPoint("LEFT", self.questIcon, "RIGHT", -2, 0)

	self:RegisterEvent("QUEST_LOG_UPDATE", Module.UpdateQuestUnit, true)
end

function Module:AddClassIcon(self)
	if not C["Nameplate"].ClassIcon then
		return
	end

	self.Class = CreateFrame("Frame", nil, self)
	self.Class:SetSize(self:GetHeight() * 2 + 3, self:GetHeight() * 2 + 3)
	self.Class:SetPoint("BOTTOMLEFT", self.Castbar, "BOTTOMRIGHT", 3, 0)
	self.Class:CreateShadow(true)

	self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
	self.Class.Icon:SetAllPoints()
	self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
	self.Class.Icon:SetTexCoord(0, 0, 0, 0)
end

function Module:UpdateClassIcon(self, unit)
	if not C["Nameplate"].ClassIcon then
		return
	end

	local reaction = UnitReaction(unit, "player")
	if UnitIsPlayer(self.unit) and (reaction and reaction <= 4) then
		local _, class = UnitClass(unit)
		local texcoord = CLASS_ICON_TCOORDS[class]
		self.Class.Icon:SetTexCoord(texcoord[1] + 0.015, texcoord[2] - 0.02, texcoord[3] + 0.018, texcoord[4] - 0.02)
		self.Class:Show()
	else
		self.Class.Icon:SetTexCoord(0, 0, 0, 0)
		self.Class:Hide()
	end
end

-- Dungeon progress, AngryKeystones required
function Module:AddDungeonProgress(self)
	if not C["Nameplate"].AKSProgress then
		return
	end

	self.progressText = K.CreateFontString(self, 13, "", "", false, "LEFT", 0, 0)
	self.progressText:SetPoint("LEFT", self, "RIGHT", 5, 0)
end

function Module:UpdateDungeonProgress(unit)
	if not self.progressText or not AngryKeystones_Data then
		return
	end

	if unit ~= self.unit then
		return
	end

	self.progressText:SetText("")

	local name, _, _, _, _, _, _, _, _, scenarioType = C_Scenario_GetInfo()
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
		local npcID = self.npcID
		local info = AngryKeystones_Data.progress[npcID]
		if info then
			local numCriteria = select(3, C_Scenario_GetStepInfo())
			local total = aksCacheData[name]
			if not total then
				for criteriaIndex = 1, numCriteria do
					local _, _, _, _, totalQuantity, _, _, _, _, _, _, _, isWeightedProgress = C_Scenario_GetCriteriaInfo(criteriaIndex)
					if isWeightedProgress then
						aksCacheData[name] = totalQuantity
						total = aksCacheData[name]
						break
					end
				end
			end

			local value, valueCount
			for amount, count in pairs(info) do
				if not valueCount or count > valueCount or (count == valueCount and amount < value) then
					value = amount
					valueCount = count
				end
			end

			if value and total then
				self.progressText:SetText(string_format("+%.2f", value / total * 100))
			end
		end
	end
end

function Module:AddCreatureIcon(self)
	local iconFrame = CreateFrame("Frame", nil, self)
	iconFrame:SetAllPoints()
	iconFrame:SetFrameLevel(self:GetFrameLevel() + 2)

	self.ClassifyIndicator = iconFrame:CreateTexture(nil, "ARTWORK")
	self.ClassifyIndicator:SetAtlas("VignetteKill")
	self.ClassifyIndicator:SetPoint("BOTTOMLEFT", self, "LEFT", 0, -4)
	self.ClassifyIndicator:SetSize(19, 19)
	self.ClassifyIndicator:Hide()
end

function Module:UpdateUnitClassify(unit)
	if self.ClassifyIndicator then
		local class = UnitClassification(unit)
		if (not self.isNameOnly) and class and classify[class] then
			local r, g, b, desature = unpack(classify[class])
			self.ClassifyIndicator:SetVertexColor(r, g, b)
			self.ClassifyIndicator:SetDesaturated(desature)
			self.ClassifyIndicator:Show()
		else
			self.ClassifyIndicator:Hide()
		end
	end
end

-- Scale plates for explosives
function Module:UpdateExplosives(event, unit)
	if not hasExplosives or unit ~= self.unit then
		return
	end

	local npcID = self.npcID
	if event == "NAME_PLATE_UNIT_ADDED" and npcID == explosivesID then
		self:SetScale(C["General"].UIScale * 1.25)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self:SetScale(C["General"].UIScale)
	end
end

local function checkInstance()
	local name, _, instID = GetInstanceInfo()
	if name and instID == 8 then
		hasExplosives = true
	else
		hasExplosives = false
	end
end

local function checkAffixes(event)
	local affixes = C_MythicPlus_GetCurrentAffixes()
	if not affixes then
		return
	end

	if affixes[3] and affixes[3].id == 13 then
		checkInstance()
		K:RegisterEvent(event, checkInstance)
		K:RegisterEvent("CHALLENGE_MODE_START", checkInstance)
	end

	K:UnregisterEvent(event, checkAffixes)
end

function Module:CheckExplosives()
	if not C["Nameplate"].ExplosivesScale then
		return
	end

	K:RegisterEvent("PLAYER_ENTERING_WORLD", checkAffixes)
end

-- Mouseover indicator
function Module:IsMouseoverUnit()
	if not self or not self.unit then
		return
	end

	if self:IsVisible() and UnitExists("mouseover") then
		return UnitIsUnit("mouseover", self.unit)
	end

	return false
end

function Module:UpdateMouseoverShown()
	if not self or not self.unit then
		return
	end

	if self:IsShown() and UnitIsUnit("mouseover", self.unit) then
		self.HighlightIndicator:Show()
		self.HighlightUpdater:Show()
	else
		self.HighlightUpdater:Hide()
	end
end

function Module:MouseoverIndicator(self)
	self.HighlightIndicator = CreateFrame("Frame", nil, self.Health)
	self.HighlightIndicator:SetAllPoints(self)
	self.HighlightIndicator:Hide()

	self.HighlightIndicator.Texture = self.HighlightIndicator:CreateTexture(nil, "ARTWORK")
	self.HighlightIndicator.Texture:SetAllPoints()
	self.HighlightIndicator.Texture:SetColorTexture(1, 1, 1, .25)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Module.UpdateMouseoverShown, true)

	self.HighlightUpdater = CreateFrame("Frame", nil, self)
	self.HighlightUpdater:SetScript("OnUpdate", function(_, elapsed)
		self.HighlightUpdater.elapsed = (self.HighlightUpdater.elapsed or 0) + elapsed
		if self.HighlightUpdater.elapsed > .1 then
			if not Module.IsMouseoverUnit(self) then
				self.HighlightUpdater:Hide()
			end

			self.HighlightUpdater.elapsed = 0
		end
	end)

	self.HighlightUpdater:HookScript("OnHide", function()
		self.HighlightIndicator:Hide()
	end)
end

-- WidgetContainer
function Module:AddWidgetContainer(self)
	self.WidgetContainer = CreateFrame("Frame", nil, self, "UIWidgetContainerTemplate")
	self.WidgetContainer:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)
	self.WidgetContainer:SetScale(1 / C["General"].UIScale) -- need reviewed
	self.WidgetContainer:Hide()
end

-- Interrupt info on castbars
function Module:UpdateCastbarInterrupt(...)
	local _, eventType, _, sourceGUID, sourceName, _, _, destGUID = ...
	if eventType == "SPELL_INTERRUPT" and destGUID and sourceName and sourceName ~= "" then
		local nameplate = guidToPlate[destGUID]
		if nameplate and nameplate.Castbar then
			local _, class = GetPlayerInfoByGUID(sourceGUID)
			local r, g, b = K.ColorClass(class)
			local color = K.RGBToHex(r, g, b)
			local sourceName = Ambiguate(sourceName, "short")
			nameplate.Castbar.Text:SetText(INTERRUPTED.." > "..color..sourceName)
			nameplate.Castbar.Time:SetText("")
		end
	end
end

function Module:AddInterruptInfo()
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.UpdateCastbarInterrupt)
end

-- Create Nameplates
function Module:CreatePlates()
	self.mystyle = "nameplate"

	self:SetSize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight)
	self:SetPoint("CENTER")
	self:SetScale(C["General"].UIScale)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(4)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))

	self.Health.backdrop = self.Health:CreateShadow(true) -- don"t mess up with libs
	self.Health.backdrop:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -3, 3)
	self.Health.backdrop:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 3, -3)
	self.Health.backdrop:SetFrameLevel(self.Health:GetFrameLevel())

	self.Health.frequentUpdates = true
	self.Health.UpdateColor = Module.UpdateColor

	if C["Nameplate"].Smooth then
		K:SmoothBar(self.Health)
	end

	self.levelText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.levelText:SetJustifyH("RIGHT")
	self.levelText:ClearAllPoints()
	self.levelText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 3)
	self:Tag(self.levelText, "[nplevel]")

	self.nameText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.nameText:SetJustifyH("LEFT")
	self.nameText:SetWidth(self:GetWidth() * 0.85)
	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)
	self:Tag(self.nameText, "[name]")

	self.npcTitle = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.npcTitle:ClearAllPoints()
	self.npcTitle:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.npcTitle:Hide()
	self:Tag(self.npcTitle, "[npctitle]")

	self.healthValue = K.CreateFontString(self.Overlay, C["Nameplate"].HealthTextSize, "", "", false, "CENTER", 0, 0)
	self.healthValue:SetPoint("CENTER", self.Overlay, 0, 0)
	self:Tag(self.healthValue, "[nphp]")

	self.Castbar = CreateFrame("StatusBar", "oUF_CastbarNameplate", self)
	self.Castbar:SetHeight(20)
	self.Castbar:SetWidth(self:GetWidth() - 22)
	self.Castbar:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Castbar:CreateShadow(true)
	self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Castbar:SetHeight(self:GetHeight())

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
	self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.Time = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize, "", "", false, "RIGHT", -2, 0)
	self.Castbar.Text = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize, "", "", false, "LEFT", 2, 0)
	self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -5, 0)
	self.Castbar.Text:SetJustifyH("LEFT")

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(self:GetHeight() * 2 + 3, self:GetHeight() * 2 + 3)
	self.Castbar.Button:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -3, 0)
	self.Castbar.Button:CreateShadow(true)

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetAllPoints()
	self.Castbar.Icon:SetTexCoord(unpack(K.TexCoords))

	self.Castbar.Text:SetPoint("LEFT", self.Castbar, 0, -5)
	self.Castbar.Time:SetPoint("RIGHT", self.Castbar, 0, -5)

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CastBorderShield")
	self.Castbar.Shield:SetTexCoord(0, 0.84375, 0, 1)
	self.Castbar.Shield:SetSize(16 * 0.84375, 16)
	self.Castbar.Shield:SetPoint("CENTER", 0, -5)
	self.Castbar.Shield:SetVertexColor(0.5, 0.5, 0.7)

	self.Castbar.timeToHold = .5
	self.Castbar.decimal = "%.1f"

	self.Castbar.OnUpdate = Module.OnCastbarUpdate
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostCastFail = Module.PostCastFailed
	self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)
	self.RaidTargetIndicator:SetParent(self.Health)
	self.RaidTargetIndicator:SetSize(16, 16)

	do
		local mhpb = self:CreateTexture(nil, "BORDER", nil, 5)
		mhpb:SetWidth(1)
		mhpb:SetTexture(K.GetTexture(C["UITextures"].HealPredictionTextures))
		mhpb:SetVertexColor(0, 1, 0.5, 0.25)

		local ohpb = self:CreateTexture(nil, "BORDER", nil, 5)
		ohpb:SetWidth(1)
		ohpb:SetTexture(K.GetTexture(C["UITextures"].HealPredictionTextures))
		ohpb:SetVertexColor(0, 1, 0, 0.25)

		local abb = self:CreateTexture(nil, "BORDER", nil, 5)
		abb:SetWidth(1)
		abb:SetTexture(K.GetTexture(C["UITextures"].HealPredictionTextures))
		abb:SetVertexColor(1, 1, 0, 0.25)

		local abbo = self:CreateTexture(nil, "ARTWORK", nil, 1)
		abbo:SetAllPoints(abb)
		abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		abbo.tileSize = 32

		local oag = self:CreateTexture(nil, "ARTWORK", nil, 1)
		oag:SetWidth(15)
		oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		oag:SetBlendMode("ADD")
		oag:SetAlpha(.25)
		oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
		oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

		local hab = CreateFrame("StatusBar", nil, self)
		hab:SetPoint("TOP")
		hab:SetPoint("BOTTOM")
		hab:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
		hab:SetWidth(self.Health:GetWidth())
		hab:SetReverseFill(true)
		hab:SetStatusBarTexture(K.GetTexture(C["UITextures"].HealPredictionTextures))
		hab:SetStatusBarColor(1, 0, 0, 0.25)

		local ohg = self:CreateTexture(nil, "ARTWORK", nil, 1)
		ohg:SetWidth(15)
		ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		ohg:SetBlendMode("ADD")
		ohg:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
		ohg:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

		self.HealPredictionAndAbsorb = {
			myBar = mhpb,
			otherBar = ohpb,
			absorbBar = abb,
			absorbBarOverlay = abbo,
			overAbsorbGlow = oag,
			healAbsorbBar = hab,
			overHealAbsorbGlow = ohg,
			maxOverflow = 1,
		}
	end

	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Auras.spacing = 4
	self.Auras.initdialAnchor = "BOTTOMLEFT"
	self.Auras["growth-y"] = "UP"
	if C["Nameplate"].ShowPlayerPlate and C["Nameplate"].NameplateClassPower then
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6 + _G.oUF_ClassPowerBar:GetHeight())
	else
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
	end
	self.Auras.numTotal = C["Nameplate"].MaxAuras
	self.Auras.size = C["Nameplate"].AuraSize
	self.Auras.gap = false
	self.Auras.disableMouse = true

	local width = self:GetWidth()
	local maxLines = 2
	self.Auras:SetWidth(width)
	self.Auras:SetHeight((self.Auras.size + self.Auras.spacing) * maxLines)

	self.Auras.showStealableBuffs = true
	self.Auras.CustomFilter = Module.CustomFilter
	self.Auras.PostCreateIcon = Module.PostCreateAura
	self.Auras.PostUpdateIcon = Module.PostUpdateAura
	self.Auras.PreUpdate = Module.bolsterPreUpdate
	self.Auras.PostUpdate = Module.bolsterPostUpdate

	Module:CreateThreatColor(self)

	self.PvPClassificationIndicator = self:CreateTexture(nil, "ARTWORK")
	self.PvPClassificationIndicator:SetSize(18, 18)
	self.PvPClassificationIndicator:ClearAllPoints()
	if C["Nameplate"].ClassIcon then
		self.PvPClassificationIndicator:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 20)
	else
		self.PvPClassificationIndicator:SetPoint("LEFT", self, "RIGHT", 6, 0)
	end

	self.powerText = K.CreateFontString(self, 15)
	self.powerText:ClearAllPoints()
	self.powerText:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -4)
	self:Tag(self.powerText, "[nppp]")

	Module:AddWidgetContainer(self)
	Module:MouseoverIndicator(self)
	Module:AddTargetIndicator(self)
	Module:AddCreatureIcon(self)
	Module:AddQuestIcon(self)
	Module:AddDungeonProgress(self)
	Module:AddClassIcon(self)
end

-- Classpower on target nameplate
function Module:UpdateClassPowerAnchor()
	if not isTargetClassPower then
		return
	end

	local bar = _G.oUF_ClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame, "TOP", 0, 18)
		bar:Show()
	else
		bar:Hide()
	end
end

function Module:UpdateTargetClassPower()
	local bar = _G.oUF_ClassPowerBar
	local playerPlate = _G.oUF_PlayerPlate

	if not bar or not playerPlate then
		return
	end

	if C["Nameplate"].NameplateClassPower then
		isTargetClassPower = true
		Module:UpdateClassPowerAnchor()
	else
		isTargetClassPower = false
		bar:SetParent(playerPlate.Health)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOMLEFT", playerPlate.Health, "TOPLEFT", 0, 3)
		bar:Show()
	end
end

local DisabledElements = {
	"Health", "Castbar", "HealPredictionAndAbsorb", "PvPClassificationIndicator", "ThreatIndicator"
}
function Module:UpdatePlateByType()
	local name = self.nameText
	local level = self.levelText
	local hpval = self.healthValue
	local title = self.npcTitle
	local raidtarget = self.RaidTargetIndicator
	local classify = self.ClassifyIndicator
	local questIcon = self.questIcon

	name:SetShown(not self.widgetsOnly)
	name:ClearAllPoints()
	raidtarget:ClearAllPoints()

	if self.isNameOnly then
		for _, element in pairs(DisabledElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end

		name:SetJustifyH("CENTER")
		self:Tag(name, "[color][name] [nplevel]")
		name:UpdateTag()
		name:SetPoint("CENTER", self, "BOTTOM")

		self:Tag(level, "")
		level:UpdateTag()

		hpval:Hide()
		title:Show()

		raidtarget:SetPoint("TOP", title, "BOTTOM", 0, -5)
		raidtarget:SetParent(self)
		classify:Hide()
		if questIcon then
			questIcon:SetPoint("LEFT", name, "RIGHT", 0, 0)
		end
	else
		for _, element in pairs(DisabledElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end

		name:SetJustifyH("LEFT")
		self:Tag(name, "[name]")
		name:UpdateTag()
		name:SetWidth(self:GetWidth() * 0.85)
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)

		level:SetJustifyH("RIGHT")
		self:Tag(self.levelText, "[nplevel]")
		level:UpdateTag()
		level:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 3)

		hpval:Show()
		title:Hide()

		raidtarget:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)
		raidtarget:SetParent(self.Health)
		classify:Show()
		if questIcon then
			questIcon:SetPoint("LEFT", self, "RIGHT", 1, 0)
		end
	end

	Module.UpdateTargetIndicator(self)
end

function Module:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 5
	self.isNameOnly = C["Nameplate"].NameOnly and self.isFriendly or self.widgetsOnly or false

	if self.previousType == nil or self.previousType ~= self.isNameOnly then
		Module.UpdatePlateByType(self)
		self.previousType = self.isNameOnly
	end
end

function Module:OnUnitFactionChanged(unit)
	local nameplate = C_NamePlate_GetNamePlateForUnit(unit, issecure())
	local unitFrame = nameplate and nameplate.unitFrame
	if unitFrame and unitFrame.unitName then
		Module.RefreshPlateType(unitFrame, unit)
	end
end

function Module:RefreshPlateOnFactionChanged()
	K:RegisterEvent("UNIT_FACTION", Module.OnUnitFactionChanged)
end

function Module:PostUpdatePlates(event, unit)
	if not self then
		return
	end

	if event == "NAME_PLATE_UNIT_ADDED" then
		self.unitName = UnitName(unit)
		self.unitGUID = UnitGUID(unit)
		if self.unitGUID then
			guidToPlate[self.unitGUID] = self
		end

		self.npcID = K.GetNPCID(self.unitGUID)
		self.isPlayer = UnitIsPlayer(unit)

		self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)
		self.WidgetContainer:RegisterForWidgetSet(UnitWidgetSet(unit), oUF.Widget_DefaultLayout, nil, unit)

		Module.RefreshPlateType(self, unit)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		if self.unitGUID then
			guidToPlate[self.unitGUID] = nil
		end
		self.npcID = nil
		self.WidgetContainer:UnregisterForWidgetSet()
	end

	if event ~= "NAME_PLATE_UNIT_REMOVED" then
		Module.UpdateUnitPower(self)
		Module.UpdateTargetChange(self)
		Module.UpdateQuestUnit(self, event, unit)
		Module.UpdateUnitClassify(self, unit)
		Module.UpdateDungeonProgress(self, unit)
		Module:UpdateClassIcon(self, unit)
		Module:UpdateClassPowerAnchor()
	end
	Module.UpdateExplosives(self, event, unit)
end

-- Player Nameplate
function Module:PlateVisibility(event)
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		UIFrameFadeIn(self.Health, 0.3, self.Health:GetAlpha(), 1)
		UIFrameFadeIn(self.Power, 0.3, self.Power:GetAlpha(), 1)
		UIFrameFadeIn(self.Auras, 0.3, self.Power:GetAlpha(), 1)
	else
		UIFrameFadeOut(self.Health, 2, self.Health:GetAlpha(), 0.1)
		UIFrameFadeOut(self.Power, 2, self.Power:GetAlpha(), 0.1)
		UIFrameFadeIn(self.Auras, 2, self.Power:GetAlpha(), 0.1)
	end
end

function Module:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"

	local iconSize, margin = C["Nameplate"].PPIconSize, 2
	self:SetSize(iconSize * 5 + margin * 4, C["Nameplate"].PPHeight)
	self:EnableMouse(false)
	self.iconSize = iconSize

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Health:SetStatusBarColor(0.1, 0.1, 0.1)
	self.Health:CreateShadow(true)

	self.Health.colorHealth = true

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Power:SetHeight(C["Nameplate"].PPPHeight)
	self.Power:SetWidth(self:GetWidth())
	self.Power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Power:CreateShadow(true)

	self.Power.colorClass = true
	self.Power.colorTapping = true
	self.Power.colorDisconnected = true
	self.Power.colorReaction = true
	self.Power.frequentUpdates = true

	Module:CreateClassPower(self)

	if K.Class == "MONK" then
		self.Stagger = CreateFrame("StatusBar", self:GetName().."Stagger", self)
		self.Stagger:SetPoint("TOPLEFT", self.Health, 0, 8)
		self.Stagger:SetSize(self:GetWidth(), self:GetHeight())
		self.Stagger:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
		self.Stagger:CreateShadow(true)

		self.Stagger.Value = self.Stagger:CreateFontString(nil, "OVERLAY")
		self.Stagger.Value:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		self.Stagger.Value:SetPoint("CENTER", self.Stagger, "CENTER", 0, 0)
		self:Tag(self.Stagger.Value, "[monkstagger]")
	end

	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Auras.spacing = 4
	self.Auras.initdialAnchor = "BOTTOMLEFT"
	self.Auras["growth-y"] = "UP"
	self.Auras:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 5)
	self.Auras.numTotal = C["Nameplate"].MaxAuras
	self.Auras.iconsPerRow = C["Nameplate"].MaxAurasPerRow or 6
	self.Auras.size = C["Nameplate"].AuraSize
	self.Auras.gap = false
	self.Auras.disableMouse = true

	local width = self:GetWidth()
	local maxAuras = self.Auras.numTotal or self.Auras.numBuffs + self.Auras.numDebuffs
	local maxLines = self.Auras.iconsPerRow and math_floor(maxAuras / self.Auras.iconsPerRow + 0.5) or 2
	self.Auras.size = self.Auras.iconsPerRow and Module.auraIconSize(width, self.Auras.iconsPerRow, self.Auras.spacing) or self.Auras.size
	self.Auras:SetWidth(width)
	self.Auras:SetHeight((self.Auras.size + self.Auras.spacing) * maxLines)

	self.Auras.showStealableBuffs = true
	self.Auras.CustomFilter = Module.CustomFilter
	self.Auras.PostCreateIcon = Module.PostCreateAura
	self.Auras.PostUpdateIcon = Module.PostUpdateAura
	self.Auras.PreUpdate = Module.bolsterPreUpdate
	self.Auras.PostUpdate = Module.bolsterPostUpdate

	if C["Nameplate"].ClassAuras then
		K:GetModule("Auras"):CreateLumos(self)
	end

	local textFrame = CreateFrame("Frame", nil, self.Power)
	textFrame:SetAllPoints()
	self.powerText = K.CreateFontString(textFrame, 14, "")
	self:Tag(self.powerText, "[pppower]")
	Module:TogglePlatePower()

	Module:CreateGCDTicker(self)
	Module:UpdateTargetClassPower()
	Module:TogglePlateVisibility()
end

function Module:TogglePlatePower()
	local plate = _G.oUF_PlayerPlate
	if not plate then
		return
	end

	plate.powerText:SetShown(C["Nameplate"].PPPowerText)
end

function Module:TogglePlateVisibility()
	local plate = _G.oUF_PlayerPlate
	if not plate then
		return
	end

	if C["Nameplate"].PPHideOOC then
		plate:RegisterEvent("UNIT_EXITED_VEHICLE", Module.PlateVisibility)
		plate:RegisterEvent("UNIT_ENTERED_VEHICLE", Module.PlateVisibility)
		plate:RegisterEvent("PLAYER_REGEN_ENABLED", Module.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_REGEN_DISABLED", Module.PlateVisibility, true)
		plate:RegisterEvent("PLAYER_ENTERING_WORLD", Module.PlateVisibility, true)
		Module.PlateVisibility(plate)
	else
		plate:UnregisterEvent("UNIT_EXITED_VEHICLE", Module.PlateVisibility)
		plate:UnregisterEvent("UNIT_ENTERED_VEHICLE", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.PlateVisibility)
		plate:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.PlateVisibility)
		Module.PlateVisibility(plate, "PLAYER_REGEN_DISABLED")
	end
end

function Module:UpdateGCDTicker(elapsed)
	local start, duration = GetSpellCooldown(61304)
	if start > 0 and duration > 0 then
		if self.duration ~= duration then
			self:SetMinMaxValues(0, duration)
			self.duration = duration
		end
		self:SetValue(GetTime() - start)
		self.spark:Show()
	else
		self.spark:Hide()
	end
end

function Module:CreateGCDTicker(self)
	local ticker = CreateFrame("StatusBar", nil, self.Power)
	ticker:SetFrameLevel(self:GetFrameLevel() + 3)
	ticker:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	ticker:GetStatusBarTexture():SetAlpha(0)
	ticker:SetAllPoints()

	local spark = ticker:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Spark_16)
	spark:SetSize(8, self.Power:GetHeight())
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", ticker:GetStatusBarTexture(), "RIGHT", 0, 0)
	ticker.spark = spark

	ticker:SetScript("OnUpdate", Module.UpdateGCDTicker)
	self.GCDTicker = ticker

	Module:ToggleGCDTicker()
end

function Module:ToggleGCDTicker()
	local plate = _G.oUF_PlayerPlate
	local ticker = plate and plate.GCDTicker
	if not ticker then
		return
	end

	ticker:SetShown(C["Nameplate"].PPGCDTicker)
end