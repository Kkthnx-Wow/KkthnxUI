local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local math_rad = _G.math.rad
local pairs = _G.pairs
local string_format = _G.string.format
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local unpack = _G.unpack

local Ambiguate = _G.Ambiguate
local C_NamePlate_GetNamePlateForUnit = _G.C_NamePlate.GetNamePlateForUnit
local C_NamePlate_SetNamePlateEnemySize = _G.C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlySize = _G.C_NamePlate.SetNamePlateFriendlySize
local C_Scenario_GetCriteriaInfo = _G.C_Scenario.GetCriteriaInfo
local C_Scenario_GetInfo = _G.C_Scenario.GetInfo
local C_Scenario_GetStepInfo = _G.C_Scenario.GetStepInfo
local CreateFrame = _G.CreateFrame
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
local UnitNameplateShowsWidgetsOnly = _G.UnitNameplateShowsWidgetsOnly
local UnitPlayerControlled = _G.UnitPlayerControlled
local UnitReaction = _G.UnitReaction
local UnitThreatSituation = _G.UnitThreatSituation
local hooksecurefunc = _G.hooksecurefunc

local aksCacheData = {}
local customUnits = {}
local groupRoles = {}
local showPowerList = {}

local hasExplosives
local isInGroup
local isInInstance
local explosivesID = 120651

-- Unit classification
local NPClassifies = {
	elite = { 1, 1, 1 },
	rare = { 1, 1, 1, true },
	rareelite = { 1, 0.1, 0.1 },
	worldboss = { 0, 1, 0 },
}

local ShowTargetNPCs = {
	[165251] = true, -- 仙林狐狸
	[174773] = true, -- 怨毒怪
}

function Module:PlateSetCVar(cvar, value)
	if GetCVar(cvar) ~= tostring(value) then
		SetCVar(cvar, value)
	end
end

function Module:PlateCVarReset()
	Module:PlateSetCVar("nameplateMinAlpha", 1)
	Module:PlateSetCVar("nameplateMaxAlpha", 1)
	Module:PlateSetCVar("nameplateClassResourceTopInset", GetCVarDefault("nameplateClassResourceTopInset"))
	Module:PlateSetCVar("nameplateGlobalScale", 1)
	Module:PlateSetCVar("NamePlateHorizontalScale", 1)
	Module:PlateSetCVar("nameplateLargeBottomInset", GetCVarDefault("nameplateLargeBottomInset"))
	Module:PlateSetCVar("nameplateLargerScale", 1)
	Module:PlateSetCVar("nameplateLargeTopInset", GetCVarDefault("nameplateLargeTopInset"))
	Module:PlateSetCVar("nameplateMaxAlphaDistance", GetCVarDefault("nameplateMaxAlphaDistance"))
	Module:PlateSetCVar("nameplateMaxScale", 1)
	Module:PlateSetCVar("nameplateMaxScaleDistance", 40)
	Module:PlateSetCVar("nameplateMinAlphaDistance", GetCVarDefault("nameplateMinAlphaDistance"))
	Module:PlateSetCVar("nameplateMinScale", 1)
	Module:PlateSetCVar("nameplateMinScaleDistance", 0)
	Module:PlateSetCVar("nameplateMotionSpeed", GetCVarDefault("nameplateMotionSpeed"))
	Module:PlateSetCVar("nameplateOccludedAlphaMult", GetCVarDefault("nameplateOccludedAlphaMult"))
	Module:PlateSetCVar("nameplateOtherAtBase", GetCVarDefault("nameplateOtherAtBase"))
	Module:PlateSetCVar("nameplateOverlapH", GetCVarDefault("nameplateOverlapH"))
	Module:PlateSetCVar("nameplateOverlapV", GetCVarDefault("nameplateOverlapV"))
	Module:PlateSetCVar("nameplateResourceOnTarget", GetCVarDefault("nameplateResourceOnTarget"))
	Module:PlateSetCVar("nameplateSelectedAlpha", 1)
	Module:PlateSetCVar("nameplateSelectedScale", 1)
	Module:PlateSetCVar("nameplateSelfAlpha", 1)
	Module:PlateSetCVar("nameplateSelfBottomInset", GetCVarDefault("nameplateSelfBottomInset"))
	Module:PlateSetCVar("nameplateSelfScale", 1)
	Module:PlateSetCVar("nameplateSelfTopInset", GetCVarDefault("nameplateSelfTopInset"))
	Module:PlateSetCVar("nameplateTargetBehindMaxDistance", 40)
end

-- Init
function Module:PlateInsideView()
	if C["Nameplate"].InsideView then
		Module:PlateSetCVar("nameplateOtherTopInset", 0.05)
		Module:PlateSetCVar("nameplateOtherBottomInset", 0.08)
	elseif GetCVar("nameplateOtherTopInset") == "0.05" and GetCVar("nameplateOtherBottomInset") == "0.08" then
		Module:PlateSetCVar("nameplateOtherTopInset", -1)
		Module:PlateSetCVar("nameplateOtherBottomInset", -1)
	end
end

function Module:UpdatePlateScale()
	Module:PlateSetCVar("namePlateMinScale", C["Nameplate"].MinScale)
	Module:PlateSetCVar("namePlateMaxScale", C["Nameplate"].MinScale)
end

function Module:UpdatePlateAlpha()
	Module:PlateSetCVar("nameplateMinAlpha", C["Nameplate"].MinAlpha)
	Module:PlateSetCVar("nameplateMaxAlpha", C["Nameplate"].MinAlpha)
end

function Module:UpdatePlateSpacing()
	Module:PlateSetCVar("nameplateOverlapV", C["Nameplate"].VerticalSpacing)
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
	Module:PlateSetCVar("nameplateOverlapH", 0.8)
	Module:UpdatePlateSpacing()
	Module:UpdatePlateAlpha()
	Module:PlateSetCVar("nameplateSelectedAlpha", 1)
	Module:PlateSetCVar("showQuestTrackingTooltips", 1)
	Module:PlateSetCVar("predictedHealth", 1)

	Module:UpdatePlateScale()
	Module:PlateSetCVar("nameplateSelectedScale", 1)
	Module:PlateSetCVar("nameplateLargerScale", 1)
	Module:PlateSetCVar("nameplateGlobalScale", 1)

	Module:PlateSetCVar("nameplateShowSelf", 0)
	Module:PlateSetCVar("nameplateResourceOnTarget", 0)
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

function Module:CreateUnitTable()
	table_wipe(customUnits)
	if not C["Nameplate"].CustomUnitColor then
		return
	end

	K.CopyTable(C.NameplateCustomUnits, customUnits)
	K.SplitList(customUnits, C["Nameplate"].CustomUnitList)
end

function Module:CreatePowerUnitTable()
	table_wipe(showPowerList)
	K.CopyTable(C.NameplateShowPowerList, showPowerList)
	K.SplitList(showPowerList, C["Nameplate"].PowerUnitList)
end

function Module:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
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
			local index = unit .. i
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

function Module:CheckThreatStatus(unit)
	if not UnitExists(unit) then
		return
	end

	local unitTarget = unit .. "target"
	local unitRole = isInGroup and UnitExists(unitTarget) and not UnitIsUnit(unitTarget, "player") and groupRoles[UnitName(unitTarget)] or "NONE"

	if K.Role == "Tank" and unitRole == "TANK" then
		return true, UnitThreatSituation(unitTarget, unit)
	else
		return false, UnitThreatSituation("player", unit)
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
	local isCustomUnit = customUnits[name] or customUnits[npcID]
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local isOffTank, status = Module:CheckThreatStatus(unit)

	local customColor = C["Nameplate"].CustomColor
	local targetColor = C["Nameplate"].TargetColor
	local insecureColor = C["Nameplate"].InsecureColor
	local offTankColor = C["Nameplate"].OffTankColor
	local revertThreat = C["Nameplate"].DPSRevertThreat
	local secureColor = C["Nameplate"].SecureColor
	local transColor = C["Nameplate"].TransColor

	local executeRatio = C["Nameplate"].ExecuteRatio
	local healthPerc = UnitHealth(unit) / (UnitHealthMax(unit) + 0.0001) * 100

	local r, g, b
	if not UnitIsConnected(unit) then
		r, g, b = 0.7, 0.7, 0.7
	else
		if C["Nameplate"].ColoredTarget and UnitIsUnit(unit, "target") then
			r, g, b = targetColor[1], targetColor[2], targetColor[3]
		elseif isCustomUnit then
			r, g, b = customColor[1], customColor[2], customColor[3]
		elseif isPlayer and isFriendly then
			if C["Nameplate"].FriendlyCC then
				r, g, b = K.UnitColor(unit)
			else
				r, g, b = unpack(K.Colors.power["MANA"])
			end
		elseif isPlayer and not isFriendly and C["Nameplate"].HostileCC then
			r, g, b = K.UnitColor(unit)
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) or C.NameplateTrashUnits[npcID] then
			r, g, b = 0.6, 0.6, 0.6
		else
			r, g, b = K.UnitColor(unit)
			if status and (C["Nameplate"].TankMode or K.Role == "Tank") then
				if status == 3 then
					if K.Role ~= "Tank" and revertThreat then
						r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
					else
						if isOffTank then
							r, g, b = offTankColor[1], offTankColor[2], offTankColor[3]
						else
							r, g, b = secureColor[1], secureColor[2], secureColor[3]
						end
					end
				elseif status == 2 or status == 1 then
					r, g, b = transColor[1], transColor[2], transColor[3]
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

	self.ThreatIndicator:Hide()
	if status and (isCustomUnit or (not C["Nameplate"].TankMode and K.Role ~= "Tank")) then
		if status == 3 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 0, 0)
			self.ThreatIndicator:Show()
		elseif status == 2 or status == 1 then
			self.ThreatIndicator:SetBackdropBorderColor(1, 1, 0)
			self.ThreatIndicator:Show()
		end
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
	local unit = self.unit

	if C["Nameplate"].TargetIndicator.Value ~= 1 then
		if UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player") then
			element:Show()
			if element.TopArrow:IsShown() and not element.TopArrowAnim:IsPlaying() then
				element.TopArrowAnim:Play()
			end
		else
			element:Hide()
			if element.TopArrowAnim:IsPlaying() then
				element.TopArrowAnim:Stop()
			end
		end
	end

	if C["Nameplate"].ColoredTarget then
		Module.UpdateThreatColor(self, _, unit)
	end
end

function Module:UpdateTargetIndicator()
	local style = C["Nameplate"].TargetIndicator.Value
	local element = self.TargetIndicator
	local isNameOnly = self.plateType == "NameOnly"

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

local points = { -15, -5, 0, 5, 0 }
function Module:AddTargetIndicator(self)
	TargetIndicator = CreateFrame("Frame", nil, self)
	TargetIndicator:SetAllPoints()
	TargetIndicator:SetFrameLevel(0)
	TargetIndicator:Hide()

	TargetIndicator.TopArrow = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.TopArrow:SetSize(128 / 2, 128 / 2)
	TargetIndicator.TopArrow:SetTexture(C["Nameplate"].TargetIndicatorTexture.Value)
	TargetIndicator.TopArrow:SetPoint("BOTTOM", TargetIndicator, "TOP", 0, 40)

	local animGroup = TargetIndicator.TopArrow:CreateAnimationGroup()
	animGroup:SetLooping("REPEAT")
	local anim = animGroup:CreateAnimation("Path")
	anim:SetDuration(1)
	for i = 1, #points do
		local point = anim:CreateControlPoint()
		point:SetOrder(i)
		point:SetOffset(0, points[i])
	end
	TargetIndicator.TopArrowAnim = animGroup

	TargetIndicator.RightArrow = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.RightArrow:SetSize(128 / 2, 128 / 2)
	TargetIndicator.RightArrow:SetTexture(C["Nameplate"].TargetIndicatorTexture.Value)
	TargetIndicator.RightArrow:SetPoint("LEFT", TargetIndicator, "RIGHT", 3, 0)
	TargetIndicator.RightArrow:SetRotation(math_rad(-90))

	TargetIndicator.Glow = CreateFrame("Frame", nil, TargetIndicator, "BackdropTemplate")
	TargetIndicator.Glow:SetPoint("TOPLEFT", self.Health.backdrop, -2, 2)
	TargetIndicator.Glow:SetPoint("BOTTOMRIGHT", self.Health.backdrop, 2, -2)
	TargetIndicator.Glow:SetBackdrop({ edgeFile = C["Media"].Textures.GlowTexture, edgeSize = 4 })
	TargetIndicator.Glow:SetBackdropBorderColor(unpack(C["Nameplate"].TargetIndicatorColor))
	TargetIndicator.Glow:SetFrameLevel(0)

	TargetIndicator.nameGlow = TargetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	TargetIndicator.nameGlow:SetSize(150, 80)
	TargetIndicator.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	TargetIndicator.nameGlow:SetVertexColor(102 / 255, 157 / 255, 255 / 255)
	TargetIndicator.nameGlow:SetBlendMode("ADD")
	TargetIndicator.nameGlow:SetPoint("CENTER", self, "BOTTOM")

	self.TargetIndicator = TargetIndicator
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

local function isQuestTitle(textLine)
	local r, g, b = textLine:GetTextColor()
	if r > 0.99 and g > 0.82 and b == 0 then
		return true
	end
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

	local startLooking, isLootQuest, questProgress
	K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
	K.ScanTooltip:SetUnit(unit)

	for i = 2, K.ScanTooltip:NumLines() do
		local textLine = _G["KKUI_ScanTooltipTextLeft" .. i]
		local text = textLine and textLine:GetText()
		if not text then
			break
		end

		if text ~= " " then
			if isInGroup and text == K.Name or (not isInGroup and isQuestTitle(textLine)) then
				startLooking = true
			elseif startLooking then
				local current, goal = strmatch(text, "(%d+)/(%d+)")
				local progress = strmatch(text, "(%d+)%%")
				if current and goal then
					local diff = floor(goal - current)
					if diff > 0 then
						questProgress = diff
						break
					end
				elseif progress and not strmatch(text, THREAT_TOOLTIP) then
					if floor(100 - progress) > 0 then
						questProgress = progress .. "%" -- lower priority on progress, keep looking
					end
				else
					break
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetAtlas("tormentors-event")
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
	self.questIcon:SetSize(26, 26)
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
	if UnitIsPlayer(unit) and (reaction and reaction <= 4) then
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
	-- local ClassifyOverlay = CreateFrame("Frame", nil, self)
	-- ClassifyOverlay:SetAllPoints(self)
	-- ClassifyOverlay:SetFrameLevel(5)

	local ClassifyIndicator = self:CreateTexture(nil, "ARTWORK")
	ClassifyIndicator:SetAtlas("auctionhouse-icon-favorite")
	ClassifyIndicator:SetPoint("RIGHT", self.nameText, "LEFT", -1, 0)
	ClassifyIndicator:SetSize(16, 16)
	ClassifyIndicator:Hide()

	self.ClassifyIndicator = ClassifyIndicator
end

local testHide = 4
function Module:UpdateUnitClassify(unit)
	if not self.ClassifyIndicator then
		return
	end

	if not unit then
		unit = self.unit
	end

	self.ClassifyIndicator:Hide()

	if testHide and testHide > 3 then
		local class = UnitClassification(unit)
		local classify = class and NPClassifies[class]
		if classify then
			local r, g, b, desature = unpack(classify)
			self.ClassifyIndicator:SetVertexColor(r, g, b)
			self.ClassifyIndicator:SetDesaturated(desature)
			self.ClassifyIndicator:Show()
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

local function checkAffixes()
	local _, affixes = C_ChallengeMode.GetActiveKeystoneInfo()
	if affixes[3] and affixes[3] == 13 then
		hasExplosives = true
	else
		hasExplosives = false
	end
end

function Module:CheckExplosives()
	if not C["Nameplate"].ExplosivesScale then
		return
	end

	checkAffixes()
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", checkAffixes)
	K:RegisterEvent("CHALLENGE_MODE_START", checkAffixes)
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

function Module:HighlightOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed > 0.1 then
		if not Module.IsMouseoverUnit(self.__owner) then
			self:Hide()
		end
		self.elapsed = 0
	end
end

function Module:HighlightOnHide()
	self.__owner.HighlightIndicator:Hide()
end

function Module:MouseoverIndicator(self)
	local highlight = CreateFrame("Frame", nil, self.Health)
	highlight:SetAllPoints(self)
	highlight:Hide()

	local texture = highlight:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetColorTexture(1, 1, 1, 0.25)

	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Module.UpdateMouseoverShown, true)

	local updater = CreateFrame("Frame", nil, self)
	updater.__owner = self
	updater:SetScript("OnUpdate", Module.HighlightOnUpdate)
	updater:HookScript("OnHide", Module.HighlightOnHide)

	self.HighlightIndicator = highlight
	self.HighlightUpdater = updater
end

-- Interrupt info on castbars
function Module:UpdateSpellInterruptor(...)
	local _, _, sourceGUID, sourceName, _, _, destGUID = ...
	if destGUID == self.unitGUID and sourceGUID and sourceName and sourceName ~= "" then
		local _, class = GetPlayerInfoByGUID(sourceGUID)
		local r, g, b = K.ColorClass(class)
		local color = K.RGBToHex(r, g, b)
		local sourceName = Ambiguate(sourceName, "short")
		self.Castbar.Text:SetText(INTERRUPTED .. " > " .. color .. sourceName)
		self.Castbar.Time:SetText("")
	end
end

function Module:SpellInterruptor(self)
	if not self.Castbar then
		return
	end

	self:RegisterCombatEvent("SPELL_INTERRUPT", Module.UpdateSpellInterruptor)
end

-- Create Nameplates
local platesList = {}
function Module:CreatePlates()
	self.mystyle = "nameplate"

	self:SetSize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight)
	self:SetPoint("CENTER")
	self:SetScale(C["General"].UIScale)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(4)

	self.Health.backdrop = self.Health:CreateShadow(true) -- don't mess up with libs
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
	self.levelText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 6, 4)
	self.levelText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 6, 4)
	self:Tag(self.levelText, "[nplevel]")

	self.nameText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.nameText:SetJustifyH("LEFT")
	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
	self.nameText:SetPoint("BOTTOMRIGHT", self.levelText, "TOPRIGHT", -12, 4)
	self:Tag(self.nameText, "[name]")

	self.npcTitle = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.npcTitle:ClearAllPoints()
	self.npcTitle:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.npcTitle:Hide()
	self:Tag(self.npcTitle, "[npctitle]")

	self.guildName = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.guildName:SetTextColor(211 / 255, 211 / 255, 211 / 255)
	self.guildName:ClearAllPoints()
	self.guildName:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.guildName:Hide()
	self:Tag(self.guildName, "[guildname]")

	local tarName = K.CreateFontString(self, C["Nameplate"].NameTextSize + 2)
	tarName:ClearAllPoints()
	tarName:SetPoint("TOP", self, "BOTTOM", 0, -10)
	tarName:Hide()
	self:Tag(tarName, "[tarname]")
	self.tarName = tarName

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
	self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
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

	self.Castbar.glowFrame = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.glowFrame:SetPoint("CENTER", self.Castbar.Button)
	self.Castbar.glowFrame:SetSize(self:GetHeight() * 2 + 3, self:GetHeight() * 2 + 3)

	self.Castbar.Text:SetPoint("LEFT", self.Castbar, 0, -5)
	self.Castbar.Time:SetPoint("RIGHT", self.Castbar, 0, -5)

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Shield:SetAtlas("Soulbinds_Portrait_Lock")
	self.Castbar.Shield:SetSize(self:GetHeight() + 14, self:GetHeight() + 14)
	self.Castbar.Shield:SetPoint("CENTER", 0, -5)

	self.Castbar.timeToHold = 0.5
	self.Castbar.decimal = "%.1f"

	self.Castbar.spellTarget = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize + 3)
	self.Castbar.spellTarget:ClearAllPoints()
	self.Castbar.spellTarget:SetJustifyH("LEFT")
	self.Castbar.spellTarget:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -6)

	self.Castbar.OnUpdate = Module.OnCastbarUpdate
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostCastUpdate = Module.PostCastUpdate
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
		oag:SetAlpha(0.25)
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
	if C["Nameplate"].NameplateClassPower then
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 12 + C["Nameplate"].PlateHeight)
		self.Auras:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 12 + C["Nameplate"].PlateHeight)
	else
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6)
		self.Auras:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 6)
	end
	self.Auras.numTotal = C["Nameplate"].MaxAuras
	self.Auras.size = C["Nameplate"].AuraSize
	self.Auras.gap = false
	self.Auras.disableMouse = true

	Module:UpdateAuraContainer(self:GetWidth(), self.Auras, self.Auras.numTotal)

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

	Module:MouseoverIndicator(self)
	Module:AddTargetIndicator(self)
	Module:AddCreatureIcon(self)
	Module:AddQuestIcon(self)
	Module:AddDungeonProgress(self)
	Module:SpellInterruptor(self)
	Module:AddClassIcon(self)

	platesList[self] = self:GetName()
end

function Module:ToggleNameplateAuras()
	if C["Nameplate"].PlateAuras then
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
	if C["Nameplate"].NameplateClassPower then
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6 + C["Nameplate"].PlateHeight)
	else
		element:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 5)
	end

	element.numTotal = C["Nameplate"].MaxAuras
	element.size = C["Nameplate"].AuraSize
	element.showDebuffType = true
	element:SetWidth(self:GetWidth())
	element:SetHeight((element.size + element.spacing) * 2)

	element:ForceUpdate()
end

function Module:UpdateNameplateSize()
	local plateHeight = C["Nameplate"].PlateHeight
	local nameTextSize = C["Nameplate"].NameTextSize
	local iconSize = plateHeight * 2 + 3

	self:SetSize(C["Nameplate"].PlateWidth, plateHeight)

	self.nameText:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize, "")
	if self.plateType ~= "NameOnly" then
		self:Tag(self.nameText, "[name]")
		self.nameText:UpdateTag()
	end

	self.npcTitle:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize - 1, "")
	self.tarName:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize + 4, "")

	self.Castbar.Icon:SetSize(iconSize, iconSize)
	self.Castbar:SetHeight(plateHeight)
	self.Castbar.Time:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize, "")
	self.Castbar.Text:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize, "")
	self.Castbar.spellTarget:SetFont(C["Media"].Fonts.KkthnxUIFont, nameTextSize + 3, "")

	self.healthValue:SetFont(C["Media"].Fonts.KkthnxUIFont, C["Nameplate"].HealthTextSize, "")
	self.healthValue:UpdateTag()
end

function Module:RefreshNameplats()
	for nameplate in pairs(platesList) do
		Module.UpdateNameplateSize(nameplate)
		Module.UpdateUnitClassify(nameplate)
		Module.UpdateNameplateAuras(nameplate)
		Module.UpdateTargetIndicator(nameplate)
		Module.UpdateTargetChange(nameplate)
	end
	Module:UpdateClickableSize()
end

function Module:RefreshAllPlates()
	-- Module:ResizePlayerPlate()
	Module:RefreshNameplats()
	Module:ResizeTargetPower()
end

local DisabledElements = {
	"Health",
	"Castbar",
	"HealPredictionAndAbsorb",
	"PvPClassificationIndicator",
	"ThreatIndicator",
}
function Module:UpdatePlateByType()
	local name = self.nameText
	local level = self.levelText
	local hpval = self.healthValue
	local title = self.npcTitle
	local guild = self.guildName
	local raidtarget = self.RaidTargetIndicator
	local questIcon = self.questIcon

	name:SetShown(not self.widgetsOnly)
	name:ClearAllPoints()
	raidtarget:ClearAllPoints()

	if self.plateType == "NameOnly" then
		for _, element in pairs(DisabledElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end

		name:SetJustifyH("CENTER")
		self:Tag(name, "[nprare] [color][name] [nplevel]")
		testHide = 6
		name:UpdateTag()
		name:SetPoint("CENTER", self, "BOTTOM")

		level:Hide()
		hpval:Hide()
		title:Show()
		guild:Show()

		raidtarget:SetPoint("TOP", title, "BOTTOM", 0, -5)

		if questIcon then
			questIcon:SetPoint("LEFT", name, "RIGHT", 0, 0)
		end

		if self.widgetContainer then
			self.widgetContainer:ClearAllPoints()
			self.widgetContainer:SetPoint("TOP", title, "BOTTOM", 0, -5)
		end
	else
		for _, element in pairs(DisabledElements) do
			if not self:IsElementEnabled(element) then
				self:EnableElement(element)
			end
		end

		name:SetJustifyH("LEFT")
		name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
		name:SetPoint("BOTTOMRIGHT", level, "TOPRIGHT", -12, 4)

		level:Show()
		hpval:Show()
		title:Hide()
		guild:Hide()

		raidtarget:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)

		if questIcon then
			questIcon:SetPoint("LEFT", self, "RIGHT", 1, 0)
		end

		if self.widgetContainer then
			self.widgetContainer:ClearAllPoints()
			self.widgetContainer:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)
		end

		Module.UpdateNameplateSize(self)
	end

	Module.UpdateTargetIndicator(self)
	Module.ToggleNameplateAuras(self)
end

function Module:RefreshPlateType(unit)
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack("player", unit)
	if C["Nameplate"].NameOnly and self.isFriendly or self.widgetsOnly then
		self.plateType = "NameOnly"
	elseif C["Nameplate"].FriendPlate and self.isFriendly then
		self.plateType = "FriendPlate"
	else
		self.plateType = "None"
	end

	if self.previousType == nil or self.previousType ~= self.plateType then
		Module.UpdatePlateByType(self)
		self.previousType = self.plateType
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
		self.isPlayer = UnitIsPlayer(unit)
		self.npcID = K.GetNPCID(self.unitGUID)
		self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

		local blizzPlate = self:GetParent().UnitFrame
		self.widgetContainer = blizzPlate and blizzPlate.WidgetContainer
		if self.widgetContainer then
			self.widgetContainer:SetParent(self)
			self.widgetContainer:SetScale(1 / C["General"].UIScale)
		end

		Module.RefreshPlateType(self, unit)
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
	Module.UpdateExplosives(self, event, unit)
end

-- Player Nameplate
function Module:PlateVisibility(event)
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		UIFrameFadeIn(self.Health, 0.2, self.Health:GetAlpha(), 1)
		UIFrameFadeIn(self.Power, 0.2, self.Power:GetAlpha(), 1)
		UIFrameFadeIn(self.Auras, 0.2, self.Power:GetAlpha(), 1)
	else
		UIFrameFadeOut(self.Health, 0.2, self.Health:GetAlpha(), 0)
		UIFrameFadeOut(self.Power, 0.2, self.Power:GetAlpha(), 0)
		UIFrameFadeOut(self.Auras, 0.2, self.Power:GetAlpha(), 0)
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

	self.Health.colorClass = true

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
	self.Power:SetHeight(C["Nameplate"].PPPHeight)
	self.Power:SetWidth(self:GetWidth())
	self.Power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Power:CreateShadow(true)

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	Module:CreateClassPower(self)

	if K.Class == "MONK" then
		self.Stagger = CreateFrame("StatusBar", self:GetName() .. "Stagger", self)
		self.Stagger:SetPoint("TOPLEFT", self.Health, 0, 8)
		self.Stagger:SetSize(self:GetWidth(), self:GetHeight())
		self.Stagger:SetStatusBarTexture(K.GetTexture(C["UITextures"].NameplateTextures))
		self.Stagger:CreateShadow(true)

		self.Stagger.Value = self.Stagger:CreateFontString(nil, "OVERLAY")
		self.Stagger.Value:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		self.Stagger.Value:SetPoint("CENTER", self.Stagger, "CENTER", 0, 0)
		self:Tag(self.Stagger.Value, "[monkstagger]")
	end

	if C["Nameplate"].ClassAuras then
		K:GetModule("Auras"):CreateLumos(self)
	end

	local textFrame = CreateFrame("Frame", nil, self.Power)
	textFrame:SetAllPoints()
	self.powerText = K.CreateFontString(textFrame, 12, "")
	self:Tag(self.powerText, "[pppower]")
	Module:TogglePlatePower()

	Module:CreateGCDTicker(self)
	Module:UpdateTargetClassPower()
	Module:TogglePlateVisibility()
end

function Module:TogglePlayerPlate()
	local plate = _G.oUF_PlayerPlate
	if not plate then
		return
	end

	if C["Nameplate"].ShowPlayerPlate then
		plate:Enable()
	else
		plate:Disable()
	end
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

-- Target nameplate
function Module:CreateTargetPlate()
	self.mystyle = "targetplate"
	self:EnableMouse(false)
	self:SetSize(10, 10)

	Module:CreateClassPower(self)
end

function Module:UpdateTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	local bar = plate.ClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")
	if nameplate then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame, "TOP", 0, 20)
		bar:Show()
	else
		bar:Hide()
	end
end

function Module:ToggleTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	local playerPlate = _G.oUF_PlayerPlate
	if C["Nameplate"].NameplateClassPower then
		plate:Enable()
		if plate.ClassPower then
			if not plate:IsElementEnabled("ClassPower") then
				plate:EnableElement("ClassPower")
				plate.ClassPower:ForceUpdate()
			end
			if playerPlate then
				if playerPlate:IsElementEnabled("ClassPower") then
					playerPlate:DisableElement("ClassPower")
				end
			end
		end

		if plate.Runes then
			if not plate:IsElementEnabled("Runes") then
				plate:EnableElement("Runes")
				plate.Runes:ForceUpdate()
			end
			if playerPlate then
				if playerPlate:IsElementEnabled("Runes") then
					playerPlate:DisableElement("Runes")
				end
			end
		end
	else
		plate:Disable()
		if plate.ClassPower then
			if plate:IsElementEnabled("ClassPower") then
				plate:DisableElement("ClassPower")
			end
			if playerPlate then
				if not playerPlate:IsElementEnabled("ClassPower") then
					playerPlate:EnableElement("ClassPower")
					playerPlate.ClassPower:ForceUpdate()
				end
			end
		end
		if plate.Runes then
			if plate:IsElementEnabled("Runes") then
				plate:DisableElement("Runes")
			end
			if playerPlate then
				if not playerPlate:IsElementEnabled("Runes") then
					playerPlate:EnableElement("Runes")
					playerPlate.Runes:ForceUpdate()
				end
			end
		end
	end
end

function Module:ResizeTargetPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	local barWidth = C["Nameplate"].PlateWidth
	local barHeight = C["Nameplate"].PlateHeight
	local bars = plate.ClassPower or plate.Runes
	if bars then
		plate.ClassPowerBar:SetSize(barWidth, barHeight)
		local max = bars.__max
		for i = 1, max do
			bars[i]:SetHeight(barHeight)
			bars[i]:SetWidth((barWidth - (max - 1) * 6) / max)
		end
	end
end

function Module:UpdateGCDTicker()
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
	spark:SetTexture(C["Media"].Textures.Spark128Texture)
	spark:SetBlendMode("ADD")
	spark:SetAlpha(0.6)
	spark:SetPoint("TOPLEFT", ticker:GetStatusBarTexture(), "TOPRIGHT", -64, -1)
	spark:SetPoint("BOTTOMRIGHT", ticker:GetStatusBarTexture(), "BOTTOMRIGHT", 64, 1)
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

Module.MajorSpells = {}
function Module:RefreshMajorSpells()
	wipe(Module.MajorSpells)

	for spellID in pairs(C.MajorSpells) do
		local name = GetSpellInfo(spellID)
		if name then
			local modValue = KkthnxUIDB.MajorSpells[spellID]
			if modValue == nil then
				Module.MajorSpells[spellID] = true
			end
		end
	end

	for spellID, value in pairs(KkthnxUIDB.MajorSpells) do
		if value then
			Module.MajorSpells[spellID] = true
		end
	end
end
