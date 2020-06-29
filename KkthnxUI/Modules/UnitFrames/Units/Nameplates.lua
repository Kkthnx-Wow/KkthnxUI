local K, C = unpack(select(2, ...))
local UF = K:GetModule("Unitframes")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local math_floor = _G.math.floor
local math_rad = _G.math.rad
local pairs = _G.pairs
local string_format = _G.string.format
local string_match = _G.string.match
local tonumber = _G.tonumber
local unpack = _G.unpack
local table_wipe = _G.table.wipe

local Ambiguate = _G.Ambiguate
local C_MythicPlus_GetCurrentAffixes = _G.C_MythicPlus.GetCurrentAffixes
local C_NamePlate_GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit
local C_Scenario_GetCriteriaInfo = _G.C_Scenario.GetCriteriaInfo
local C_Scenario_GetInfo = _G.C_Scenario.GetInfo
local C_Scenario_GetStepInfo = _G.C_Scenario.GetStepInfo
local CreateFrame = _G.CreateFrame
local GetInstanceInfo = _G.GetInstanceInfo
local GetPlayerInfoByGUID = _G.GetPlayerInfoByGUID
local INTERRUPTED = _G.INTERRUPTED
local InCombatLockdown = _G.InCombatLockdown
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local SetCVar = _G.SetCVar
local UnitClassification = _G.UnitClassification
local UnitExists = _G.UnitExists
local UnitGUID = _G.UnitGUID
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

local CPBarPoint = {"TOPLEFT", 12, 4}
local aksCacheData = {}
local barHeight = C["Nameplate"].PlateHeight
local barWidth = C["Nameplate"].PlateWidth
local explosivesID = 120651
local groupRoles = {}
local guidToPlate = {}
local hasExplosives
local isInGroup
local isInInstance
local isTargetClassPower

-- Unit classification
local classify = {
	elite = {1, 1, 1},
	rare = {1, 1, 1, true},
	rareelite = {1, .1, .1},
	worldboss = {0, 1, 0},
}

-- Init
function UF:PlateInsideView()
	if C["Nameplate"].InsideView then
		SetCVar("nameplateOtherTopInset", 0.05)
		SetCVar("nameplateOtherBottomInset", 0.08)
	else
		SetCVar("nameplateOtherTopInset", -1)
		SetCVar("nameplateOtherBottomInset", -1)
	end
end

function UF:UpdatePlateScale()
	SetCVar("namePlateMinScale", C["Nameplate"].MinScale)
	SetCVar("namePlateMaxScale", C["Nameplate"].MinScale)
end

function UF:UpdatePlateAlpha()
	SetCVar("nameplateMinAlpha", 1)
	SetCVar("nameplateMaxAlpha", 1)
end

function UF:UpdatePlateRange()
	SetCVar("nameplateMaxDistance", C["Nameplate"].Distance)
end

function UF:UpdatePlateSpacing()
	SetCVar("nameplateOverlapV", C["Nameplate"].VerticalSpacing)
end

function UF:UpdateClickableSize()
	if InCombatLockdown() then
		return
	end

	C_NamePlate.SetNamePlateEnemySize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight + 40)
	C_NamePlate.SetNamePlateFriendlySize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight + 40)
end

function UF:SetupCVars()
	UF:PlateInsideView()
	SetCVar("nameplateOverlapH", .8)
	UF:UpdatePlateSpacing()
	UF:UpdatePlateRange()
	UF:UpdatePlateAlpha()
	SetCVar("nameplateSelectedAlpha", 1)
	SetCVar("showQuestTrackingTooltips", 1)

	UF:UpdatePlateScale()
	SetCVar("nameplateSelectedScale", 1)
	SetCVar("nameplateLargerScale", 1)

	SetCVar("nameplateShowSelf", 0)
	SetCVar("nameplateResourceOnTarget", 0)
	K.HideInterfaceOption(InterfaceOptionsNamesPanelUnitNameplatesPersonalResource)
	K.HideInterfaceOption(InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy)

	UF:UpdateClickableSize()
	hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", UF.UpdateClickableSize)
end

function UF:BlockAddons()
	if not DBM or not DBM.Nameplate then
		return
	end

	function DBM.Nameplate:SupportedNPMod()
		return true
	end

	local function showAurasForDBM(_, _, _, spellID)
		if not tonumber(spellID) then
			return
		end

		if not K.NameplateWhiteList[spellID] then
			K.NameplateWhiteList[spellID] = true
		end
	end

	hooksecurefunc(DBM.Nameplate, "Show", showAurasForDBM)
end

function UF:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = K.NameplateShowPowerList[unitName] or K.NameplateShowPowerList[npcID]
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

function UF:UpdateGroupRoles()
	refreshGroupRoles()
	K:RegisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	K:RegisterEvent("GROUP_LEFT", resetGroupRoles)
end

function UF:CheckTankStatus(unit)
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
function UF.UpdateColor(self, _, unit)
	if not unit or self.unit ~= unit then
		return
	end

	local element = self.Health
	local name = self.unitName
	local npcID = self.npcID
	local isCustomUnit = K.NameplateCustomUnits[name] or K.NameplateCustomUnits[npcID]
	local isPlayer = UnitIsPlayer(unit)
	local status = UnitThreatSituation(self.feedbackUnit or "player", unit) or false -- just in case
	local reaction = UnitReaction(unit, "player")

	local reactionColor = K.Colors.reaction[reaction]
	local customColor = C["Nameplate"].CustomColor
	local secureColor = C["Nameplate"].SecureColor
	local transColor = C["Nameplate"].TransColor
	local insecureColor = C["Nameplate"].InsecureColor
	local revertThreat = C["Nameplate"].DPSRevertThreat
	local offTankColor = C["Nameplate"].OffTankColor

	local r, g, b
	if not UnitIsConnected(unit) then
		r, g, b = 0.7, 0.7, 0.7
	else
		if isCustomUnit then
			r, g, b = customColor[1], customColor[2], customColor[3]
		elseif isPlayer and (reaction and reaction >= 5) then
			if C["Nameplate"].FriendlyCC then
				r, g, b = K.UnitColor(unit)
			else
				r, g, b = unpack(K.Colors.power["MANA"])
			end
		elseif isPlayer and (reaction and reaction <= 4) and C["Nameplate"].HostileCC then
			r, g, b = K.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			r, g, b = .6, .6, .6
		else
			if not UnitIsTapDenied(unit) and not UnitIsPlayer(unit) then
				if reactionColor then
					r, g, b = reactionColor[1], reactionColor[2], reactionColor[3]
				else
					r, g, b = UnitSelectionColor(unit, true)
				end
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
end

function UF:UpdateThreatColor(_, unit)
	if unit ~= self.unit then
		return
	end

	UF.CheckTankStatus(self, unit)
	UF.UpdateColor(self, _, unit)
end

function UF:CreateThreatColor(self)
	local threatIndicator = CreateFrame("Frame", nil, self)
	threatIndicator:SetPoint("TOPLEFT", self, -3, 3)
	threatIndicator:SetPoint("BOTTOMRIGHT", self, 3, -3)
	threatIndicator:SetBackdrop({edgeFile = C["Media"].Glow, edgeSize = 3})
	threatIndicator:Hide()

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = UF.UpdateThreatColor
end


-- Target indicator
function UF:UpdateTargetChange()
	-- if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
	-- 	self.TargetIndicator:SetAlpha(1)
	-- 	self:SetAlpha(1)
	-- else
	-- 	if not UnitExists("target") or UnitIsUnit(self.unit, "player") then
	-- 		self.TargetIndicator:SetAlpha(0)
	-- 		self:SetAlpha(1)
	-- 	else
	-- 		self.TargetIndicator:SetAlpha(0)
	-- 		self:SetAlpha(0.35)
	-- 	end
	-- end

	if C["Nameplate"].TargetIndicator.Value == 1 then
		return
	end

	if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
		self.TargetIndicator:SetAlpha(1)
	else
		self.TargetIndicator:SetAlpha(0)
	end
end

function UF:UpdateTargetIndicator(self)
	local style = C["Nameplate"].TargetIndicator.Value

	if style == 1 then
		self.TargetIndicator:Hide()
	else
		if style == 2 then
			self.TargetIndicator.TopArrow:Show()
			self.TargetIndicator.RightArrow:Hide()
			self.TargetIndicator.Glow:Hide()
		elseif style == 3 then
			self.TargetIndicator.TopArrow:Hide()
			self.TargetIndicator.RightArrow:Show()
			self.TargetIndicator.Glow:Hide()
		elseif style == 4 then
			self.TargetIndicator.TopArrow:Hide()
			self.TargetIndicator.RightArrow:Hide()
			self.TargetIndicator.Glow:Show()
		elseif style == 5 then
			self.TargetIndicator.TopArrow:Show()
			self.TargetIndicator.RightArrow:Hide()
			self.TargetIndicator.Glow:Show()
		elseif style == 6 then
			self.TargetIndicator.TopArrow:Hide()
			self.TargetIndicator.RightArrow:Show()
			self.TargetIndicator.Glow:Show()
		end

		self.TargetIndicator:Show()
	end
end

function UF:AddTargetIndicator(self)
	self.TargetIndicator = CreateFrame("Frame", nil, self)
	self.TargetIndicator:SetAllPoints()
	self.TargetIndicator:SetFrameLevel(0)
	self.TargetIndicator:SetAlpha(0)

	self.TargetIndicator.TopArrow = self.TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	self.TargetIndicator.TopArrow:SetSize(40, 40)
	self.TargetIndicator.TopArrow:SetTexture(C["Media"].NPArrow)
	self.TargetIndicator.TopArrow:SetPoint("BOTTOM", self.TargetIndicator, "TOP", 0, 10)
	self.TargetIndicator.TopArrow:SetRotation(math_rad(-90))

	self.TargetIndicator.RightArrow = self.TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	self.TargetIndicator.RightArrow:SetSize(40, 40)
	self.TargetIndicator.RightArrow:SetTexture(C["Media"].NPArrow)
	self.TargetIndicator.RightArrow:SetPoint("LEFT", self.TargetIndicator, "RIGHT", 3, 0)
	self.TargetIndicator.RightArrow:SetRotation(math_rad(-180))

	self.TargetIndicator.Glow = CreateFrame("Frame", nil, self.TargetIndicator)
	self.TargetIndicator.Glow:SetPoint("TOPLEFT", self.TargetIndicator, -5, 5)
	self.TargetIndicator.Glow:SetPoint("BOTTOMRIGHT", self.TargetIndicator, 5, -5)
	self.TargetIndicator.Glow:SetBackdrop({edgeFile = C["Media"].Glow, edgeSize = 4})
	self.TargetIndicator.Glow:SetBackdropBorderColor(unpack(C["Nameplate"].TargetIndicatorColor))
	self.TargetIndicator.Glow:SetFrameLevel(0)

	UF:UpdateTargetIndicator(self)
	self:RegisterEvent("PLAYER_TARGET_CHANGED", UF.UpdateTargetChange, true)
end

local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function UF:QuestIconCheck()
	if not C["Nameplate"].QuestIndicator then
		return
	end

	CheckInstanceStatus()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

function UF:UpdateQuestUnit(_, unit)
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

					local questLine = _G[K.ScanTooltip:GetName().."TextLeft"..(i+1)]
					local questText = questLine:GetText()
					if questLine and questText then
						local current, goal = string_match(questText, "(%d+)/(%d+)")
						local progress = string_match(questText, "([%d%.]+)%%")
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
		self.questIcon:SetAtlas("Warfronts-BaseMapIcons-Horde-Barracks-Minimap")
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas("adventureguide-microbutton-alert")
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

function UF:AddQuestIcon(self)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	local qicon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	qicon:SetPoint("LEFT", self, "RIGHT", -1, 0)
	qicon:SetSize(18, 18)
	qicon:SetAtlas("adventureguide-microbutton-alert")
	qicon:Hide()

	local count = K.CreateFontString(self, 10, "", "", nil, "LEFT", 0, 0)
	count:SetPoint("LEFT", qicon, "RIGHT", -2, 0)

	self.questIcon = qicon
	self.questCount = count
	self:RegisterEvent("QUEST_LOG_UPDATE", UF.UpdateQuestUnit, true)
end

-- Dungeon progress, AngryKeystones required
function UF:AddDungeonProgress(self)
	if not C["Nameplate"].AKSProgress then
		return
	end

	self.progressText = K.CreateFontString(self, 12, "", "", false, "LEFT", 0, 0)
	self.progressText:SetPoint("LEFT", self, "RIGHT", 5, 0)
end

function UF:UpdateDungeonProgress(unit)
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
				self.progressText:SetText(string_format("+%.2f", value / total*100))
			end
		end
	end
end

function UF:AddCreatureIcon(self)
	local iconFrame = CreateFrame("Frame", nil, self)
	iconFrame:SetAllPoints()
	iconFrame:SetFrameLevel(self:GetFrameLevel() + 2)

	self.creatureIcon = iconFrame:CreateTexture(nil, "ARTWORK")
	self.creatureIcon:SetAtlas("VignetteKill")
	self.creatureIcon:SetPoint("BOTTOMLEFT", self, "LEFT", 0, -4)
	self.creatureIcon:SetSize(14, 14)
	self.creatureIcon:Hide()
end

function UF:UpdateUnitClassify(unit)
	local class = UnitClassification(unit)
	if self.creatureIcon then
		if class and classify[class] then
			local r, g, b, desature = unpack(classify[class])
			self.creatureIcon:SetVertexColor(r, g, b)
			self.creatureIcon:SetDesaturated(desature)
			self.creatureIcon:Show()
		else
			self.creatureIcon:Hide()
		end
	end
end

-- Scale plates for explosives
function UF:UpdateExplosives(event, unit)
	if not hasExplosives or unit ~= self.unit then
		return
	end

	local npcID = self.npcID
	if event == "NAME_PLATE_UNIT_ADDED" and npcID == explosivesID then
		self:SetScale(1.25)
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		self:SetScale(1)
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

function UF:CheckExplosives()
	if not C["Nameplate"].ExplosivesScale then
		return
	end

	K:RegisterEvent("PLAYER_ENTERING_WORLD", checkAffixes)
end

-- Mouseover indicator
function UF:IsMouseoverUnit()
	if not self or not self.unit then
		return
	end

	if self:IsVisible() and UnitExists("mouseover") then
		return UnitIsUnit("mouseover", self.unit)
	end

	return false
end

function UF:UpdateMouseoverShown()
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

function UF:MouseoverIndicator(self)
	self.HighlightIndicator = CreateFrame("Frame", nil, self.Health)
	self.HighlightIndicator:SetAllPoints(self)
	self.HighlightIndicator:Hide()

	self.HighlightIndicator.Texture = self.HighlightIndicator:CreateTexture(nil, "ARTWORK")
	self.HighlightIndicator.Texture:SetAllPoints()
	self.HighlightIndicator.Texture:SetColorTexture(1, 1, 1, .25)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", UF.UpdateMouseoverShown, true)

	self.HighlightUpdater = CreateFrame("Frame", nil, self)
	self.HighlightUpdater:SetScript("OnUpdate", function(_, elapsed)
		self.HighlightUpdater.elapsed = (self.HighlightUpdater.elapsed or 0) + elapsed
		if self.HighlightUpdater.elapsed > .1 then
			if not UF.IsMouseoverUnit(self) then
				self.HighlightUpdater:Hide()
			end

			self.HighlightUpdater.elapsed = 0
		end
	end)

	self.HighlightUpdater:HookScript("OnHide", function()
		self.HighlightIndicator:Hide()
	end)
end

-- NazjatarFollowerXP
function UF:AddFollowerXP(self)
	self.NazjatarFollowerXP = CreateFrame("StatusBar", nil, self)
	self.NazjatarFollowerXP:SetStatusBarTexture(C["Media"].Texture)
	self.NazjatarFollowerXP:SetSize(C["Nameplate"].PlateWidth * 0.75, C["Nameplate"].PlateHeight)
	self.NazjatarFollowerXP:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)

	self.NazjatarFollowerXP.progressText = K.CreateFontString(self.NazjatarFollowerXP, 9)
end

-- Interrupt info on castbars
function UF:UpdateCastbarInterrupt(...)
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

function UF:AddInterruptInfo()
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.UpdateCastbarInterrupt)
end

-- Create Nameplates
function UF:CreatePlates()
	self.mystyle = "nameplate"

	self:SetSize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight)
	self:SetPoint("CENTER")
	self:SetScale(1)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Health:CreateShadow(true)

	self.Health.frequentUpdates = true
	self.Health.UpdateColor = UF.UpdateColor

	if C["Nameplate"].Smooth then
		K:SmoothBar(self.Health)
	end

	self.levelText = K.CreateFontString(self.Health, C["Nameplate"].NameTextSize, "", "", false)
	self.levelText:SetJustifyH("RIGHT")
	self.levelText:ClearAllPoints()
	self.levelText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 3)
	self:Tag(self.levelText, "[nplevel]")

	self.nameText = K.CreateFontString(self.Health, C["Nameplate"].NameTextSize, "", "", false)
	self.nameText:SetJustifyH("LEFT")
	self.nameText:SetWidth(self:GetWidth() * 0.85)
	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 3)
	self:Tag(self.nameText, "[name]")

	self.healthValue = K.CreateFontString(self.Health, C["Nameplate"].HealthTextSize, "", "", false, "CENTER", 0, 0)
	self.healthValue:SetPoint("CENTER", self, 0, 0)
	self:Tag(self.healthValue, "[nphp]")

	self.Castbar = CreateFrame("StatusBar", "oUF_CastbarNameplate", self)
	self.Castbar:SetHeight(20)
	self.Castbar:SetWidth(self:GetWidth() - 22)
	self.Castbar:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Castbar:CreateShadow(true)
	self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Castbar:SetHeight(self:GetHeight())

	self.Castbar.Time = K.CreateFontString(self.Castbar, 10, "", "", false, "RIGHT", -2, 0)
	self.Castbar.Text = K.CreateFontString(self.Castbar, 10, "", "", false, "LEFT", 2, 0)
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
	self.Castbar.Shield:SetSize(14 * 0.84375, 14)
	self.Castbar.Shield:SetPoint("CENTER", 0, -5)
	self.Castbar.Shield:SetVertexColor(0.5, 0.5, 0.7)

	self.Castbar.timeToHold = .5
	self.Castbar.decimal = "%.1f"
	self.Castbar.OnUpdate = UF.OnCastbarUpdate
	self.Castbar.PostCastStart = UF.PostCastStart
	self.Castbar.PostChannelStart = UF.PostCastStart
	self.Castbar.PostCastStop = UF.PostCastStop
	self.Castbar.PostChannelStop = UF.PostChannelStop
	self.Castbar.PostCastFailed = UF.PostCastFailed
	self.Castbar.PostCastInterrupted = UF.PostCastFailed
	self.Castbar.PostCastInterruptible = UF.PostUpdateInterruptible
	self.Castbar.PostCastNotInterruptible = UF.PostUpdateInterruptible

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
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6 + _G.oUF_NameplateClassPowerBar:GetHeight())
	else
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
	end
	self.Auras.numTotal = C["Nameplate"].MaxAuras
	self.Auras.iconsPerRow = C["Nameplate"].MaxAurasPerRow or 6
	self.Auras.size = C["Nameplate"].AuraSize
	self.Auras.gap = false
	self.Auras.disableMouse = true

	local width = self:GetWidth()
	local maxAuras = self.Auras.numTotal or self.Auras.numBuffs + self.Auras.numDebuffs
	local maxLines = self.Auras.iconsPerRow and math_floor(maxAuras / self.Auras.iconsPerRow + 0.5) or 2
	self.Auras.size = self.Auras.iconsPerRow and UF.auraIconSize(width, self.Auras.iconsPerRow, self.Auras.spacing) or self.Auras.size
	self.Auras:SetWidth(width)
	self.Auras:SetHeight((self.Auras.size + self.Auras.spacing) * maxLines)

	self.Auras.showStealableBuffs = true
	self.Auras.CustomFilter = UF.CustomFilter
	self.Auras.PostCreateIcon = UF.PostCreateAura
	self.Auras.PostUpdateIcon = UF.PostUpdateAura
	self.Auras.PreUpdate = UF.bolsterPreUpdate
	self.Auras.PostUpdate = UF.bolsterPostUpdate

	UF:CreateThreatColor(self)

	self.PvPClassificationIndicator = self:CreateTexture(nil, "ARTWORK")
	self.PvPClassificationIndicator:SetSize(18, 18)
	self.PvPClassificationIndicator:SetPoint("LEFT", self, "RIGHT", 6, 0)

	self.powerText = K.CreateFontString(self, 15)
	self.powerText:ClearAllPoints()
	self.powerText:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -4)
	self:Tag(self.powerText, "[nppp]")

	--UF:AddFollowerXP(self)
	UF:MouseoverIndicator(self)
	UF:AddTargetIndicator(self)
	UF:AddCreatureIcon(self)
	UF:AddQuestIcon(self)
	UF:AddDungeonProgress(self)
end

-- Classpower on target nameplate
function UF:UpdateClassPowerAnchor()
	if not isTargetClassPower then
		return
	end

	local bar = _G.oUF_NameplateClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame, "TOP", 0, 14)
		bar:Show()
	else
		bar:Hide()
	end
end

function UF:UpdateTargetClassPower()
	local bar = _G.oUF_NameplateClassPowerBar
	local playerPlate = _G.oUF_PlayerPlate

	if not bar or not playerPlate then
		return
	end

	if C["Nameplate"].NameplateClassPower then
		isTargetClassPower = true
		UF:UpdateClassPowerAnchor()
	else
		isTargetClassPower = false
		bar:SetParent(playerPlate.Health)
		bar:ClearAllPoints()
		bar:SetPoint("TOPLEFT", playerPlate.Health, 0, 3)
		bar:Show()
	end
end

function UF.PostUpdateNameplateClassPower(element, cur, max, diff, powerType)
	if diff then
		for i = 1, max do
			element[i]:SetWidth((C["Nameplate"].PlateWidth - (max - 1) * 6) / max)
		end
	end

	if (K.Class == "ROGUE" or K.Class == "DRUID") and (powerType == "COMBO_POINTS") and element.__owner.unit ~= "vehicle" then
		for i = 1, 6 do
			element[i]:SetStatusBarColor(unpack(K.Colors.power.COMBO_POINTS[i]))
		end
	end

	if (powerType == "COMBO_POINTS" or powerType == "HOLY_POWER") and element.__owner.unit ~= "vehicle" and cur == max then
		for i = 1, 6 do
			if element[i]:IsShown() then
				if C["Nameplate"].ShowPlayerPlate and C["Nameplate"].MaxPowerGlow then
					K.libCustomGlow.AutoCastGlow_Start(element[i])
				end
			end
		end
	else
		for i = 1, 6 do
			if C["Nameplate"].ShowPlayerPlate and C["Nameplate"].MaxPowerGlow then
				K.libCustomGlow.AutoCastGlow_Stop(element[i])
			end
		end
	end
end

function UF:PostUpdatePlates(event, unit)
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

		local blizzPlate = self:GetParent().UnitFrame
		self.widget = blizzPlate.WidgetContainer
	elseif event == "NAME_PLATE_UNIT_REMOVED" then
		if self.unitGUID then
			guidToPlate[self.unitGUID] = nil
		end
	end

	UF.UpdateUnitPower(self)
	UF.UpdateTargetChange(self)
	UF.UpdateQuestUnit(self, event, unit)
	UF.UpdateUnitClassify(self, unit)
	UF.UpdateExplosives(self, event, unit)
	UF.UpdateDungeonProgress(self, unit)
	UF:UpdateClassPowerAnchor()
end

-- Player Nameplate
function UF:PlateVisibility(event)
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		K.UIFrameFadeIn(self.Health, 0.3, self.Health:GetAlpha(), 1)
		K.UIFrameFadeIn(self.Power, 0.3, self.Power:GetAlpha(), 1)
	else
		K.UIFrameFadeOut(self.Health, 2, self.Health:GetAlpha(), 0.1)
		K.UIFrameFadeOut(self.Power, 2, self.Power:GetAlpha(), 0.1)
	end
end

function UF:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"

	local iconSize, margin = C["Nameplate"].PPIconSize, 2

	self:SetSize(iconSize * 5 + margin * 4, C["Nameplate"].PPHeight)
	self:EnableMouse(false)
	self.iconSize = iconSize

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Health:SetStatusBarColor(.1, .1, .1)
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

	if C["Nameplate"].NameplateClassPower then
		if self.mystyle == "PlayerPlate" then
			barWidth, barHeight = C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight
			CPBarPoint = {"BOTTOMLEFT", self, "TOPLEFT", 0, 3}
		end

		local bar = CreateFrame("Frame", "oUF_NameplateClassPowerBar", self.Health)
		bar:SetSize(barWidth, barHeight)
		bar:SetPoint(unpack(CPBarPoint))

		local bars = {}
		for i = 1, 6 do
			bars[i] = CreateFrame("StatusBar", nil, bar)
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - 5 * 6) / 6)
			bars[i]:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
			bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)
			bars[i]:CreateShadow(true)

			if i == 1 then
				bars[i]:SetPoint("BOTTOMLEFT")
			else
				bars[i]:SetPoint("LEFT", bars[i - 1], "RIGHT", 6, 0)
			end

			if K.Class == "DEATHKNIGHT" then
				bars[i].timer = K.CreateFontString(bars[i], 10, "")
			end

			if C["Nameplate"].ShowPlayerPlate then
				bars[i].glow = CreateFrame("Frame", nil, bars[i])
				bars[i].glow:SetPoint("TOPLEFT", -3, 2)
				bars[i].glow:SetPoint("BOTTOMRIGHT", 3, -2)
			end
		end

		if K.Class == "DEATHKNIGHT" then
			bars.colorSpec = true
			bars.sortOrder = "asc"
			bars.PostUpdate = UF.PostUpdateRunes
			self.Runes = bars
		else
			bars.PostUpdate = UF.PostUpdateNameplateClassPower
			self.ClassPower = bars
		end
	end

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

	K:GetModule("Auras"):CreateLumos(self)

	if C["Nameplate"].PPPowerText then
		local textFrame = CreateFrame("Frame", nil, self.Power)
		textFrame:SetAllPoints()

		local power = K.CreateFontString(textFrame, 14, "")
		self:Tag(power, "[pppower]")
	end

	UF:UpdateTargetClassPower()

	if C["Nameplate"].PPHideOOC then
		self:RegisterEvent("UNIT_EXITED_VEHICLE", UF.PlateVisibility)
		self:RegisterEvent("UNIT_ENTERED_VEHICLE", UF.PlateVisibility)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", UF.PlateVisibility, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", UF.PlateVisibility, true)
		self:RegisterEvent("PLAYER_ENTERING_WORLD", UF.PlateVisibility, true)
	end
end