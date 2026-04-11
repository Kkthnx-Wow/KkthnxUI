--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main nameplate logic for KkthnxUI, handling CVars, styling, and elements.
-- - Design: Uses oUF for unit frame management and Blizzard CVars for nameplate behavior.
-----------------------------------------------------------------------------]]

local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

-- Lua functions
local math_rad = math.rad
local math_floor = math.floor
local pairs = pairs
local ipairs = ipairs
local select = select
local string_format = string.format
local strmatch = string.match
local table_wipe = table.wipe
local tonumber = tonumber
local tostring = tostring
local unpack = unpack

local function trim(str)
	if not str then
		return ""
	end
	return str:match("^%s*(.-)%s*$") or ""
end

-- WoW API
local Ambiguate = Ambiguate
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local C_NamePlate_GetNamePlates = C_NamePlate.GetNamePlates
local C_NamePlate_SetNamePlateEnemyClickThrough = C_NamePlate.SetNamePlateEnemyClickThrough
local C_NamePlate_SetNamePlateEnemySize = C_NamePlate.SetNamePlateEnemySize
local C_NamePlate_SetNamePlateFriendlyClickThrough = C_NamePlate.SetNamePlateFriendlyClickThrough
local C_NamePlate_SetNamePlateFriendlySize = C_NamePlate.SetNamePlateFriendlySize
local C_Scenario_GetInfo = C_Scenario.GetInfo
local C_Scenario_GetStepInfo = C_Scenario.GetStepInfo
local C_ScenarioInfo_GetCriteriaInfo = C_ScenarioInfo.GetCriteriaInfo
local C_Timer_After = C_Timer.After
local C_TooltipInfo_GetUnit = C_TooltipInfo.GetUnit
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local GetNumGroupMembers = GetNumGroupMembers
local GetNumSubgroupMembers = GetNumSubgroupMembers
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local INTERRUPTED = INTERRUPTED
local InCombatLockdown = InCombatLockdown
local IsInGroup = IsInGroup
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local LE_SCENARIO_TYPE_CHALLENGE_MODE = LE_SCENARIO_TYPE_CHALLENGE_MODE
local SetCVar = SetCVar
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitExists = UnitExists
local UnitGUID = UnitGUID
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitIsUnit = UnitIsUnit
local UnitName = UnitName
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitPlayerControlled = UnitPlayerControlled
local UnitReaction = UnitReaction
local UnitThreatSituation = UnitThreatSituation
local hooksecurefunc = hooksecurefunc
local issecure = issecure

-- Custom data
local mdtCacheData = {} -- Cache for data of abilities used by players
local customUnits = {} -- Custom unit data
local groupRoles = {} -- Group roles for players
local showPowerList = {} -- List of players who have their power displayed
local isInGroup = false -- Boolean to track if the player is in a group
local isInInstance = false -- Boolean to track if the player is in an instance

-- Unit classification
local NPClassifies = {
	elite = { atlas = "VignetteKillElite", color = { 1, 1, 1 } },
	rare = { atlas = "VignetteKill", color = { 1, 1, 1 }, desaturate = true },
	rareelite = { atlas = "VignetteKillElite", color = { 1, 0.1, 0.1 } },
	worldboss = { atlas = "VignetteKillElite", color = { 0, 1, 0 } },
}

-- Specific NPCs to show
local ShowTargetNPCs = C.NameplateTargetNPCs

-- ---------------------------------------------------------------------------
-- CVars & Settings
-- ---------------------------------------------------------------------------
function Module:UpdatePlateCVars()
	Module:CreateUnitTable()
	Module:CreatePowerUnitTable()

	if InCombatLockdown() then
		return
	end

	-- REASON: Manage distance and overlap CVars to ensure clean nameplate behavior.
	local curTop, curBottom = GetCVar("nameplateOtherTopInset"), GetCVar("nameplateOtherBottomInset")
	if C["Nameplate"].InsideView then
		if curTop ~= "0.05" then
			SetCVar("nameplateOtherTopInset", 0.05)
		end
		if curBottom ~= "0.08" then
			SetCVar("nameplateOtherBottomInset", 0.08)
		end
	else
		if curTop == "0.05" then
			SetCVar("nameplateOtherTopInset", -1)
		end
		if curBottom == "0.08" then
			SetCVar("nameplateOtherBottomInset", -1)
		end
	end

	local settings = {
		namePlateMinScale = C["Nameplate"].MinScale,
		namePlateMaxScale = C["Nameplate"].MinScale,
		nameplateMinAlpha = C["Nameplate"].MinAlpha,
		nameplateMaxAlpha = C["Nameplate"].MinAlpha,
		nameplateOverlapV = C["Nameplate"].VerticalSpacing,
		nameplateShowOnlyNames = C["Nameplate"].CVarOnlyNames and 1 or 0,
		nameplateShowFriendlyNPCs = C["Nameplate"].CVarShowNPCs and 1 or 0,
	}

	for cvar, value in pairs(settings) do
		local cur = GetCVar(cvar)
		local want = tostring(value)
		if cur ~= want then
			SetCVar(cvar, value)
		end
	end
end

function Module:UpdateClickableSize()
	if InCombatLockdown() then
		return
	end

	-- REASON: Adjust the interactive area of the nameplates based on UI scale and settings.
	local uiScale = C["General"].UIScale
	local harmWidth, harmHeight = C["Nameplate"].HarmWidth, C["Nameplate"].HarmHeight
	local helpWidth, helpHeight = C["Nameplate"].HelpWidth, C["Nameplate"].HelpHeight

	C_NamePlate_SetNamePlateEnemySize(harmWidth * uiScale, harmHeight * uiScale)
	C_NamePlate_SetNamePlateFriendlySize(helpWidth * uiScale, helpHeight * uiScale)
end

function Module:UpdatePlateClickThru()
	if InCombatLockdown() then
		return
	end

	-- REASON: Control whether nameplates can be clicked through in combat.
	C_NamePlate_SetNamePlateEnemyClickThrough(C["Nameplate"].EnemyThru)
	C_NamePlate_SetNamePlateFriendlyClickThrough(C["Nameplate"].FriendlyThru)
end

function Module:SetupCVars()
	Module:UpdatePlateCVars()

	-- REASON: Enforce various Blizzard CVars for consistent nameplate scaling and visibility.
	local settings = {
		nameplateOverlapH = 0.8,
		nameplateSelectedAlpha = 1,
		showQuestTrackingTooltips = 1,
		nameplateSelectedScale = C["Nameplate"].SelectedScale,
		nameplateLargerScale = 1.1,
		nameplateGlobalScale = 1,
		NamePlateHorizontalScale = 1,
		NamePlateVerticalScale = 1,
		NamePlateClassificationScale = 1,
		nameplateShowSelf = 0,
		nameplateResourceOnTarget = 0,
		nameplatePlayerMaxDistance = 60,
	}

	for cvar, value in pairs(settings) do
		local cur = GetCVar(cvar)
		local want = tostring(value)
		if cur ~= want then
			SetCVar(cvar, value)
		end
	end

	Module:UpdateClickableSize()
	-- WARNING: DBM and other addons might fight for these CVars; hook ensures our settings persist.
	hooksecurefunc(NamePlateDriverFrame, "UpdateNamePlateOptions", Module.UpdateClickableSize)
	Module:UpdatePlateClickThru()
end

function Module:BlockAddons()
	-- REASON: Disable DBM's built-in nameplate icons to prevent overlapping with KkthnxUI elements.
	if not _G.DBM or not _G.DBM.Nameplate then
		return
	end

	if DBM.Options then
		DBM.Options.DontShowNameplateIcons = true
		DBM.Options.DontShowNameplateIconsCD = true
		DBM.Options.DontShowNameplateIconsCast = true
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

-- ---------------------------------------------------------------------------
-- Tables & Data Management
-- ---------------------------------------------------------------------------
function Module:CreateUnitTable()
	table_wipe(customUnits)
	if not C["Nameplate"].CustomUnitColor then
		return
	end

	-- REASON: Merge built-in custom units with user-configured units for unique coloring.
	K.CopyTable(C.NameplateCustomUnits, customUnits)
	K.SplitList(customUnits, C["Nameplate"].CustomUnitList)
end

function Module:CreatePowerUnitTable()
	table_wipe(showPowerList)
	-- REASON: Define which NPCs or players should have their power bars displayed on nameplates.
	K.CopyTable(C.NameplateShowPowerList, showPowerList)
	K.SplitList(showPowerList, C["Nameplate"].PowerUnitList)
end

function Module:UpdateUnitPower()
	local unitName = self.unitName
	local npcID = self.npcID
	-- REASON: Efficiently check if the current unit is on the power-display whitelist.
	local shouldShowPower = showPowerList[unitName] or showPowerList[npcID]
	if shouldShowPower then
		self.powerText:Show()
	else
		self.powerText:Hide()
	end
end

local function refreshGroupRoles()
	local isRaid = IsInRaid()
	isInGroup = isRaid or IsInGroup()

	table_wipe(groupRoles)

	-- REASON: Track roles (TANK/HEALER/DPS) of group members for threat-based coloring.
	if isInGroup then
		local numPlayers = (isRaid and GetNumGroupMembers()) or GetNumSubgroupMembers()
		local unitPrefix = (isRaid and "raid") or "party"

		for i = 1, numPlayers do
			local unit = unitPrefix .. i
			if UnitExists(unit) then
				groupRoles[UnitName(unit)] = UnitGroupRolesAssigned(unit)
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

	K:UnregisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	K:UnregisterEvent("GROUP_LEFT", resetGroupRoles)

	K:RegisterEvent("GROUP_ROSTER_UPDATE", refreshGroupRoles)
	K:RegisterEvent("GROUP_LEFT", resetGroupRoles)
end

function Module:CheckThreatStatus(unit)
	if not UnitExists(unit) then
		return
	end

	-- REASON: Determine if the unit is targeting a tank or the player to decide nameplate color.
	local unitTarget = unit .. "target"
	local unitRole = isInGroup and UnitExists(unitTarget) and not UnitIsUnit(unitTarget, "player") and groupRoles[UnitName(unitTarget)] or "NONE"

	if K.Role == "Tank" and unitRole == "TANK" then
		return true, UnitThreatSituation(unitTarget, unit)
	else
		return false, UnitThreatSituation("player", unit)
	end
end

-- ---------------------------------------------------------------------------
-- Style Filter Logic
-- ---------------------------------------------------------------------------
local StyleFilters = {
	-- Priority NPCs (e.g. explosive orbs, spiteful shades)
	[120651] = { scale = 1.35, color = { 1, 1, 1 } }, -- Explosive Orb
	[174773] = { scale = 1.25, color = { 0.8, 0.2, 0.8 }, desaturate = true }, -- Spiteful Shade
	[164702] = { scale = 1.20 }, -- Rotting Maggot (High priority in some dungeons)
	[165251] = { scale = 1.20 }, -- Mistcaller (Specific NPC)
	[190120] = { scale = 1.30, color = { 0, 1, 0.5 } }, -- Incorporeal Being
	[196115] = { scale = 1.30, color = { 1, 1, 0 } }, -- Afflicted Soul
	-- TWW Season 1
	[212450] = { scale = 1.25, color = { 1, 0.5, 0 } }, -- Nightfall Ritualist (CoT)
	[212451] = { scale = 1.25, color = { 1, 0.5, 0 } }, -- Nightfall Shadowwalker (CoT)
	[216364] = { scale = 1.25 }, -- Blood-Bound Horror
	[216365] = { scale = 1.25 }, -- Blood-Bound Horror
}

function Module:ApplyStyleFilter(unit)
	local npcID = self.npcID
	local name = self.unitName
	local isTarget = UnitIsUnit(unit, "target")

	-- REASON: Reset style filter changes before applying new ones to prevent state leaking between units.
	if self._styleFiltered then
		self:SetScale(C["General"].UIScale)
		local element = self.Health:GetStatusBarTexture()
		if element and element.SetDesaturated then
			element:SetDesaturated(false)
		end
		self._styleFiltered = false
	end

	-- REASON: Stop any existing priority pulse animation.
	if self._priorityPulse then
		self._priorityPulse:Stop()
	end

	-- REASON: Apply custom color if the unit is on the user-defined custom list.
	local isCustom = customUnits[name] or customUnits[npcID]
	if isCustom then
		local customColor = C["Nameplate"].CustomColor
		self.Health:SetStatusBarColor(unpack(customColor))
		self._styleFiltered = true
	end

	-- REASON: Apply hardcoded style filters for specific high-priority NPCs.
	if npcID then
		local filter = StyleFilters[npcID] or (C.NameplateTrashUnits[npcID] and { color = { 0.6, 0.6, 0.6 }, desaturate = true }) or (ShowTargetNPCs[npcID] and { scale = 1.2, color = C["Nameplate"].TargetColor })

		if filter then
			if filter.scale then
				-- PERF: Cache scale calculations.
				self:SetScale(filter.scale * C["General"].UIScale)
			end

			if filter.color then
				self.Health:SetStatusBarColor(unpack(filter.color))
			end

			if filter.desaturate then
				local element = self.Health:GetStatusBarTexture()
				if element and element.SetDesaturated then
					element:SetDesaturated(true)
				end
			end

			-- PERF: Use animation group for pulse highlight to keep OnUpdate clean.
			if filter.scale and filter.scale > 1.2 then
				if not self._priorityPulse then
					local anim = self.Health:CreateAnimationGroup()
					local fadeOut = anim:CreateAnimation("Alpha")
					fadeOut:SetFromAlpha(1)
					fadeOut:SetToAlpha(0.6)
					fadeOut:SetDuration(0.6)
					fadeOut:SetOrder(1)
					fadeOut:SetSmoothing("IN_OUT")

					local fadeIn = anim:CreateAnimation("Alpha")
					fadeIn:SetFromAlpha(0.6)
					fadeIn:SetToAlpha(1)
					fadeIn:SetDuration(0.6)
					fadeIn:SetOrder(2)
					fadeIn:SetSmoothing("IN_OUT")

					anim:SetLooping("REPEAT")
					self._priorityPulse = anim
				end
				self._priorityPulse:Play()
			end

			self._styleFiltered = true
		end
	end

	-- REASON: Targeted units can have a specific color override if enabled.
	if C["Nameplate"].ColoredTarget and isTarget and not UnitIsUnit(unit, "player") then
		self.Health:SetStatusBarColor(unpack(C["Nameplate"].TargetColor))
		self._styleFiltered = true
	end

	return self._styleFiltered
end

-- ---------------------------------------------------------------------------
-- Unit Coloring
-- ---------------------------------------------------------------------------
function Module:UpdateColor(_, unit)
	-- REASON: Early exit for invalid units or mismatching frame ownership.
	if not unit or self.unit ~= unit then
		return
	end

	local element = self.Health
	local isCustomUnit = self.isCustomUnit
	local isPlayer = self.isPlayer
	local isFriendly = self.isFriendly
	local isOffTank, status = Module:CheckThreatStatus(unit)

	local health = UnitHealth(unit)
	local healthMax = UnitHealthMax(unit)
	if not health or not healthMax then
		return
	end

	local executeRatio = C["Nameplate"].ExecuteRatio
	local healthPerc = healthMax > 0 and (health / healthMax) * 100 or 100
	local r, g, b

	-- REASON: Style filters (custom units, priority NPCs, target coloring) have high priority.
	-- If a filter applies, we skip standard coloring to avoid overrides.
	if Module.ApplyStyleFilter(self, unit) then
		Module.UpdateThreatIndicator(self, status, isCustomUnit)
	else
		-- REASON: Priority chain for standard unit coloring, similar to ElvUI's cleaner logic.
		if not UnitIsConnected(unit) then
			-- 1. Disconnected status
			r, g, b = 0.7, 0.7, 0.7
		elseif UnitIsTapDenied(unit) and not UnitPlayerControlled(unit) then
			-- 2. Tapping status (greyed out)
			r, g, b = 0.6, 0.6, 0.6
		elseif not isFriendly and executeRatio > 0 and healthPerc <= executeRatio then
			-- 3. Execute phase coloring
			local executeColor = C["Nameplate"].ExecuteColor
			r, g, b = executeColor[1], executeColor[2], executeColor[3]
		elseif self.Auras.hasTheDot then
			-- 4. Active DoT coloring (if enabled)
			local dotColor = C["Nameplate"].DotColor
			r, g, b = dotColor[1], dotColor[2], dotColor[3]
		elseif isPlayer then
			-- 5. Player coloring (Friendly vs Hostile settings)
			if isFriendly then
				if C["Nameplate"].FriendlyCC then
					r, g, b = K.UnitColor(unit)
				else
					-- REASON: Use default mana color for friendly players if class color is disabled.
					local manaColor = K.Colors.power["MANA"]
					r, g, b = manaColor[1], manaColor[2], manaColor[3]
				end
			else
				-- REASON: Hostiles use reaction coloring by default if HostileCC is disabled.
				r, g, b = K.UnitColor(unit)
			end
		else
			-- 6. Selection Type coloring (Retail primary, provides more granular NPC/Guard colors)
			local selection = _G.UnitSelectionType and _G.UnitSelectionType(unit, true)
			if selection then
				-- REASON: Special handling for friendly NPCs/Guards to match specific selection colors.
				if selection == 3 then
					selection = UnitPlayerControlled(unit) and 5 or 3
				end

				local color = K.Colors.selection[selection]
				if color then
					r, g, b = color[1], color[2], color[3]
				end
			end

			-- 7. Default NPC reaction coloring fallback
			if not r then
				r, g, b = K.UnitColor(unit)
			end
		end

		-- REASON: Threat coloring overrides base health color for tanks for better visibility.
		-- We check for either Tank Mode or the player's active Role.
		if status and (C["Nameplate"].TankMode or K.Role == "Tank") then
			local insecureColor = C["Nameplate"].InsecureColor
			local offTankColor = C["Nameplate"].OffTankColor
			local revertThreat = C["Nameplate"].DPSRevertThreat
			local secureColor = C["Nameplate"].SecureColor
			local transColor = C["Nameplate"].TransColor

			if status == 3 then
				-- Aggro Secure
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
				-- Threat transition
				r, g, b = transColor[1], transColor[2], transColor[3]
			elseif status == 0 then
				-- No threat / Losing aggro
				if K.Role ~= "Tank" and revertThreat then
					r, g, b = secureColor[1], secureColor[2], secureColor[3]
				else
					r, g, b = insecureColor[1], insecureColor[2], insecureColor[3]
				end
			end
		end

		if r or g or b then
			element:SetStatusBarColor(r, g, b)
		end

		Module.UpdateThreatIndicator(self, status, isCustomUnit)
	end

	-- REASON: Update name text color for units in execute range for immediate feedback.
	local useExecuteColor = not isFriendly and executeRatio > 0 and healthPerc <= executeRatio
	if useExecuteColor ~= self._lastExecuteColor then
		self._lastExecuteColor = useExecuteColor
		self.nameText:SetTextColor(useExecuteColor and 1 or 1, useExecuteColor and 0 or 1, useExecuteColor and 0 or 1)
	end
end

function Module:UpdateThreatIndicator(status, isCustomUnit)
	-- REASON: Threat indicator border for non-tank roles or specific custom units.
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
end

function Module:UpdateThreatColor(_, unit)
	if unit ~= self.unit then
		return
	end

	Module.UpdateColor(self, _, unit)
end

function Module:CreateThreatColor(self)
	-- REASON: Use a shadow/glow frame as a threat indicator border.
	local threatIndicator = self:CreateShadow()
	threatIndicator:SetPoint("TOPLEFT", self.Health.backdrop, "TOPLEFT", -1, 1)
	threatIndicator:SetPoint("BOTTOMRIGHT", self.Health.backdrop, "BOTTOMRIGHT", 1, -1)
	threatIndicator:Hide()

	self.ThreatIndicator = threatIndicator
	self.ThreatIndicator.Override = Module.UpdateThreatColor
end

-- ---------------------------------------------------------------------------
-- Target Indicator
-- ---------------------------------------------------------------------------
function Module:UpdateTargetChange()
	local element = self.TargetIndicator
	local unit = self.unit

	-- REASON: Toggle target indicators based on currently selected unit and player options.
	if C["Nameplate"].TargetIndicator ~= 1 then
		local isTarget = UnitIsUnit(unit, "target") and not UnitIsUnit(unit, "player")
		element:SetShown(isTarget)

		-- PERF: Only play/stop animations if the state actually changes.
		local shouldPlayAnim = isTarget and not element.TopArrowAnim:IsPlaying()
		local shouldStopAnim = not isTarget and element.TopArrowAnim:IsPlaying()

		if shouldPlayAnim then
			element.TopArrowAnim:Play()
		elseif shouldStopAnim then
			element.TopArrowAnim:Stop()
		end
	end

	-- REASON: Immediately update threat color for the new target for responsive visual feedback.
	-- This ensures that the target color or style filter applied to the target is updated instantly.
	Module.UpdateThreatColor(self, _, unit)
end

function Module:UpdateTargetIndicator()
	local style = C["Nameplate"].TargetIndicator
	local element = self.TargetIndicator
	local isNameOnly = self.plateType == "NameOnly"

	-- REASON: Hide all indicators if the "None" style is selected.
	if style == 1 then
		element:Hide()
		return
	end

	-- REASON: Map user choice (style ID) to visibility of specific indicator elements (arrows, glows).
	local showTopArrow = style == 2 or style == 5
	local showRightArrow = style == 3 or style == 6
	local showGlow = (style == 4 or style == 5 or style == 6) and not isNameOnly
	local showNameGlow = (style == 4 or style == 5 or style == 6) and isNameOnly

	element.TopArrow:SetShown(showTopArrow)
	element.RightArrow:SetShown(showRightArrow)
	element.Glow:SetShown(showGlow)
	element.nameGlow:SetShown(showNameGlow)
	element:Show()
end

function Module:AddTargetIndicator(self)
	-- REASON: Create a parent frame to hold various target visual cues (arrows, glows).
	local targetIndicator = CreateFrame("Frame", nil, self)
	targetIndicator:SetAllPoints()
	targetIndicator:SetFrameLevel(0)
	targetIndicator:Hide()

	local function createArrow(parent, point, x, y, rotation)
		local arrow = parent:CreateTexture(nil, "BACKGROUND", nil, -5)
		arrow:SetSize(64, 64)
		arrow:SetTexture(C["Nameplate"].TargetIndicatorTexture)
		arrow:SetPoint(point, parent, point, x, y)
		if rotation then
			arrow:SetRotation(rotation)
		end
		return arrow
	end

	-- Top arrow
	targetIndicator.TopArrow = createArrow(targetIndicator, "BOTTOM", 0, 40)
	local animGroup = targetIndicator.TopArrow:CreateAnimationGroup()
	animGroup:SetLooping("REPEAT")

	-- REASON: Create a bouncing effect using Translation to ensure modern client compatibility.
	local anim1 = animGroup:CreateAnimation("Translation")
	anim1:SetOffset(0, -15)
	anim1:SetDuration(0.5)
	anim1:SetOrder(1)
	anim1:SetSmoothing("IN_OUT")

	local anim2 = animGroup:CreateAnimation("Translation")
	anim2:SetOffset(0, 15)
	anim2:SetDuration(0.5)
	anim2:SetOrder(2)
	anim2:SetSmoothing("IN_OUT")

	targetIndicator.TopArrowAnim = animGroup

	-- Right arrow
	targetIndicator.RightArrow = createArrow(targetIndicator, "LEFT", 3, 0, math_rad(-90))

	-- Glow
	targetIndicator.Glow = CreateFrame("Frame", nil, targetIndicator, "BackdropTemplate")
	targetIndicator.Glow:SetPoint("TOPLEFT", self.Health.backdrop, -2, 2)
	targetIndicator.Glow:SetPoint("BOTTOMRIGHT", self.Health.backdrop, 2, -2)
	targetIndicator.Glow:SetBackdrop({ edgeFile = C["Media"].Textures.GlowTexture, edgeSize = 4 })
	targetIndicator.Glow:SetBackdropBorderColor(unpack(C["Nameplate"].TargetIndicatorColor))
	targetIndicator.Glow:SetFrameLevel(0)

	-- Name glow
	targetIndicator.nameGlow = targetIndicator:CreateTexture(nil, "BACKGROUND", nil, -5)
	targetIndicator.nameGlow:SetSize(150, 80)
	targetIndicator.nameGlow:SetTexture("Interface\\GLUES\\Models\\UI_Draenei\\GenericGlow64")
	targetIndicator.nameGlow:SetVertexColor(102 / 255, 157 / 255, 255 / 255)
	targetIndicator.nameGlow:SetBlendMode("ADD")
	targetIndicator.nameGlow:SetPoint("CENTER", self, "BOTTOM")

	self.TargetIndicator = targetIndicator
	self:RegisterEvent("PLAYER_TARGET_CHANGED", Module.UpdateTargetChange, true)
	Module.UpdateTargetIndicator(self)
end

-- ---------------------------------------------------------------------------
-- Quest & Progression
-- ---------------------------------------------------------------------------
local function checkInstanceStatus()
	isInInstance = IsInInstance()
end

function Module:QuestIconCheck()
	if not C["Nameplate"].QuestIndicator then
		return
	end

	checkInstanceStatus()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", checkInstanceStatus)
end

-- REASON: Localize quest objective keywords for different languages to improve detection accuracy.
local questKeywords = {
	KILL = { "slain", "destroy", "eliminate", "repel", "kill", "defeat", "消灭", "摧毁", "击败", "毁灭", "击退" },
	CHAT = { "speak", "talk", "交谈", "谈一谈" },
	LOOT = { "collect", "gather", "retrieve", "收集", "寻找", "获取" },
}

local function getQuestType(text)
	local lowerText = text:lower()
	for _, keyword in ipairs(questKeywords.KILL) do
		if lowerText:find(keyword:lower()) then
			return "KILL"
		end
	end
	for _, keyword in ipairs(questKeywords.CHAT) do
		if lowerText:find(keyword:lower()) then
			return "CHAT"
		end
	end
	for _, keyword in ipairs(questKeywords.LOOT) do
		if lowerText:find(keyword:lower()) then
			return "LOOT"
		end
	end
	return "DEFAULT"
end

function Module:UpdateQuestUnit(_, unit)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	-- REASON: Disable quest indicators inside instances as tooltips often don't provide accurate progress there.
	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit
	local questProgress, questType
	local iconStyle = C["Nameplate"].QuestIconStyle

	-- REASON: Parse the unit tooltip to find quest objectives and progress.
	local data = C_TooltipInfo_GetUnit(unit)
	if data then
		for i = 1, #data.lines do
			local lineData = data.lines[i]
			-- REASON: Type 8 lines in C_TooltipInfo typically represent quest objectives.
			if lineData.type == 8 then
				local text = lineData.leftText
				if text then
					local current, goal = text:match("(%d+)%s*/%s*(%d+)")
					local progress = text:match("(%d+)%%")
					if current and goal then
						local diff = tonumber(goal) - tonumber(current)
						if diff > 0 then
							questProgress = diff
							questType = getQuestType(text)
						end
					elseif progress then
						if tonumber(progress) < 100 then
							questProgress = (100 - tonumber(progress)) .. "%"
							questType = getQuestType(text)
						end
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		if iconStyle == 2 then
			if questType == "CHAT" then
				self.questIcon:SetTexture(C["Media"].Textures.ChatBubbleIcon)
				self.questIcon:SetVertexColor(unpack(C["Nameplate"].QuestChatColor))
			elseif questType == "LOOT" then
				self.questIcon:SetTexture(C["Media"].Textures.QuestIcon)
				self.questIcon:SetVertexColor(unpack(C["Nameplate"].QuestItemColor))
			elseif questType == "KILL" then
				self.questIcon:SetTexture(C["Media"].Textures.SkullIcon)
				self.questIcon:SetVertexColor(unpack(C["Nameplate"].QuestSkullColor))
			else
				self.questIcon:SetTexture(C["Media"].Textures.QuestIcon)
				self.questIcon:SetVertexColor(1, 1, 1)
			end
		else
			self.questIcon:SetTexture(C["Media"].Textures.QuestIcon)
			self.questIcon:SetVertexColor(1, 1, 1)
		end
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		self.questIcon:Hide()
	end
end

function Module:AddQuestIcon(self)
	if not C["Nameplate"].QuestIndicator then
		return
	end

	-- REASON: Create textures and font strings for displaying quest status next to nameplates.
	self.questIcon = self:CreateTexture(nil, "OVERLAY", nil, 2)
	self.questIcon:SetPoint("LEFT", self.Health, "RIGHT", 4, 0)
	self.questIcon:SetSize(18, 18)
	self.questIcon:Hide()

	self.questCount = K.CreateFontString(self, 12, "", nil, "LEFT", 0, 0)
	self.questCount:SetPoint("LEFT", self.questIcon, "RIGHT", 2, 0)

	self:RegisterEvent("QUEST_LOG_UPDATE", Module.UpdateQuestUnit, true)
	self:RegisterEvent("UNIT_NAME_UPDATE", Module.UpdateQuestUnit, true)
end

function Module:AddDungeonProgress(self)
	if not C["Nameplate"].AKSProgress then
		return
	end

	-- REASON: Display MDT-based enemy forces progress on mob nameplates in Mythic+ dungeons.
	self.progressText = K.CreateFontString(self, 13, "", "", false, "LEFT", 0, 0)
	self.progressText:ClearAllPoints()
	self.progressText:SetPoint("LEFT", self, "RIGHT", 5, 0)
end

function Module:UpdateDungeonProgress(unit)
	-- REASON: Calculate and display the percentage of enemy forces this mob provides.
	if not self.progressText or not MDT then
		return
	end

	if unit ~= self.unit then
		return
	end
	self.progressText:SetText("")

	local name, _, _, _, _, _, _, _, _, scenarioType = C_Scenario_GetInfo()
	if scenarioType == LE_SCENARIO_TYPE_CHALLENGE_MODE then
		local value = MDT:GetEnemyForces(self.npcID)
		if value and value > 0 then
			local total = mdtCacheData[name]
			if not total then
				local numCriteria = select(3, C_Scenario_GetStepInfo())
				for criteriaIndex = 1, numCriteria do
					local criteriaInfo = C_ScenarioInfo_GetCriteriaInfo(criteriaIndex)
					if criteriaInfo and criteriaInfo.isWeightedProgress then
						mdtCacheData[name] = criteriaInfo.totalQuantity
						total = mdtCacheData[name]
						break
					end
				end
			end

			if total then
				self.progressText:SetText(string_format("+%.2f", value / total * 100))
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Classification & Icons
-- ---------------------------------------------------------------------------
function Module:AddCreatureIcon(self)
	-- REASON: Create an indicator for unit classification (Rare, Elite, World Boss).
	local classifyIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	classifyIndicator:SetPoint("RIGHT", self.nameText, "LEFT", 10, 0)
	classifyIndicator:SetSize(16, 16)
	classifyIndicator:Hide()

	self.ClassifyIndicator = classifyIndicator
end

function Module:UpdateUnitClassify(unit)
	if not self.ClassifyIndicator then
		return
	end

	unit = unit or self.unit
	self.ClassifyIndicator:Hide()

	-- REASON: Use specific textures/atlases and colors to visually distinguish unit types.
	local class = UnitClassification(unit)
	local data = class and NPClassifies[class]
	if data then
		--if data.atlas then
		--self.ClassifyIndicator:SetAtlas(data.atlas)
		--else
		self.ClassifyIndicator:SetTexture(C["Media"].Textures.StarIcon)
		--end
		self.ClassifyIndicator:SetVertexColor(unpack(data.color))
		self.ClassifyIndicator:SetDesaturated(data.desaturate)
		self.ClassifyIndicator:Show()
	end
end

function Module:AddClassIcon(self)
	if not C["Nameplate"].ClassIcon then
		return
	end

	-- REASON: Create a class icon frame for PvP nameplates to identify enemy roles quickly.
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

	-- REASON: Only show class icons for enemy players in PvP situations.
	local reaction = UnitReaction(unit, "player")
	if UnitIsPlayer(unit) and (reaction and reaction <= 4) then
		local _, class = UnitClass(unit)

		if class and CLASS_ICON_TCOORDS[class] then
			local texcoord = CLASS_ICON_TCOORDS[class]
			-- REASON: Apply specific texcoords to crop the Blizzard class icon texture correctly.
			self.Class.Icon:SetTexCoord(texcoord[1] + 0.015, texcoord[2] - 0.02, texcoord[3] + 0.018, texcoord[4] - 0.02)
			self.Class:Show()
		else
			self.Class.Icon:SetTexCoord(0, 0, 0, 0)
			self.Class:Hide()
		end
	else
		self.Class.Icon:SetTexCoord(0, 0, 0, 0)
		self.Class:Hide()
	end
end

-- ---------------------------------------------------------------------------
-- Mouseover Highlight
-- ---------------------------------------------------------------------------
function Module:IsMouseoverUnit()
	if not self or not self.unit then
		return false
	end

	-- REASON: Use UnitIsUnit to check if the mouse is currently over this nameplate's unit.
	if self:IsVisible() and UnitExists("mouseover") then
		return UnitIsUnit("mouseover", self.unit)
	end

	return false
end

function Module:UpdateMouseoverShown()
	if not self or not self.unit then
		return
	end

	-- REASON: Show the highlight indicator and start the OnUpdate tracker if the unit is moused over.
	if self:IsShown() and UnitIsUnit("mouseover", self.unit) then
		self.HighlightIndicator:Show()
		self.HighlightUpdater:Show()
	else
		-- REASON: Hide the updater; the indicator will be hidden by the OnUpdate script once mouse leaves.
		self.HighlightUpdater:Hide()
	end
end

function Module:HighlightOnUpdate(elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	-- PERF: Use a throttle (0.1s) to reduce the frequency of visibility checks.
	if self.elapsed > 0.1 then
		if not Module.IsMouseoverUnit(self.__owner) then
			self:Hide()
		end
		self.elapsed = 0
	end
end

function Module:HighlightOnHide()
	-- REASON: Ensure the visual highlight indicator is hidden when the parent frame or updater is hidden.
	self.__owner.HighlightIndicator:Hide()
end

function Module:MouseoverIndicator(self)
	-- REASON: Create a frame for the mouseover highlight to allow for independent alpha blending/scripts.
	local highlight = CreateFrame("Frame", nil, self.Health)
	highlight:SetAllPoints(self)
	highlight:Hide()

	local texture = highlight:CreateTexture(nil, "ARTWORK")
	texture:SetAllPoints()
	texture:SetTexture(C["Media"].Textures.White8x8Texture)
	texture:SetVertexColor(1, 1, 1, 0.15)
	texture:SetBlendMode("ADD")

	-- REASON: Use an event-based approach with an OnUpdate fallback for responsive mouseover updates.
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", Module.UpdateMouseoverShown, true)

	local updater = CreateFrame("Frame", nil, self)
	updater.__owner = self
	updater:SetScript("OnUpdate", Module.HighlightOnUpdate)
	updater:HookScript("OnHide", Module.HighlightOnHide)

	self.HighlightIndicator = highlight
	self.HighlightUpdater = updater
end

-- ---------------------------------------------------------------------------
-- Castbar Utilities
-- ---------------------------------------------------------------------------
function Module:UpdateSpellInterruptor(...)
	local _, _, sourceGUID, sourceName, _, _, destGUID = ...

	-- REASON: Display who interrupted the cast directly on the nameplate for improved feedback.
	if destGUID == self.unitGUID and sourceGUID and sourceName and sourceName ~= "" then
		local _, class = GetPlayerInfoByGUID(sourceGUID)
		local r, g, b = K.ColorClass(class)
		local color = K.RGBToHex(r, g, b)
		local interrupterName = Ambiguate(sourceName, "short")

		self.Castbar.Text:SetFormattedText("%s [ %s%s|r ]", INTERRUPTED, color, interrupterName)
		self.Castbar.Time:SetText("")
	end
end

function Module:SpellInterruptor(self)
	if not self.Castbar then
		return
	end

	-- REASON: Monitor combat events to detect spell interrupts on nameplate units.
	self:RegisterCombatEvent("SPELL_INTERRUPT", Module.UpdateSpellInterruptor)
end

-- Create Nameplates
-- ---------------------------------------------------------------------------
-- Core Nameplate Creation
-- ---------------------------------------------------------------------------
local platesList = {}

local function updateSpellTarget(self, _, unit)
	Module.PostCastUpdate(self.Castbar, unit)
end

function Module:CreatePlates()
	self.mystyle = "nameplate"

	-- REASON: Initialize base nameplate dimensions and scale.
	self:SetSize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight)
	self:SetPoint("CENTER")
	self:SetScale(C["General"].UIScale)

	-- Health Bar
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(4)

	self.Health.backdrop = self.Health:CreateShadow(true)
	self.Health.backdrop:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -3, 3)
	self.Health.backdrop:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 3, -3)
	self.Health.backdrop:SetFrameLevel(self.Health:GetFrameLevel())

	self.Health.frequentUpdates = true
	self.Health.UpdateColor = Module.UpdateColor

	if C["Nameplate"].Smooth then
		-- K:SmoothBar(self.Health)
	end

	-- Text Elements
	-- REASON: Use oUF tags for dynamic text updating (name, level, health, etc.).
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
	self.nameText:SetPoint("BOTTOMRIGHT", self.levelText, "TOPRIGHT", -21, 4)
	self:Tag(self.nameText, "[name]")

	self.npcTitle = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.npcTitle:ClearAllPoints()
	self.npcTitle:SetPoint("TOP", self.nameText, "BOTTOM", 0, -4)
	self.npcTitle:Hide()
	self:Tag(self.npcTitle, "[npctitle]")

	self.guildName = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.guildName:SetTextColor(211 / 255, 211 / 255, 211 / 255)
	self.guildName:ClearAllPoints()
	self.guildName:SetPoint("TOP", self.nameText, "BOTTOM", 0, -4)
	self.guildName:Hide()
	self:Tag(self.guildName, "[guildname]")

	self.tarName = K.CreateFontString(self, C["Nameplate"].NameTextSize + 2)
	self.tarName:ClearAllPoints()
	self.tarName:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.tarName:Hide()
	self:Tag(self.tarName, "[tarname]")

	self.healthValue = K.CreateFontString(self.Overlay, C["Nameplate"].HealthTextSize, "", "", false, "CENTER", 0, 0)
	self.healthValue:SetPoint("CENTER", self.Overlay, 0, 0)
	self:Tag(self.healthValue, "[nphp]")

	-- Castbar
	-- REASON: Customize the castbar appearance with textures, sparks, and interrupt shields.
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Castbar:SetHeight(self:GetHeight() + 6)
	self.Castbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Castbar:SetFrameLevel(10)
	self.Castbar:CreateShadow(true)
	self.Castbar.castTicks = {}

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY", nil, 2)
	self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight() - 2)
	self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	self.Castbar.Spark:SetBlendMode("ADD")
	self.Castbar.Spark:SetAlpha(0.8)

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY", nil, 4)
	self.Castbar.Shield:SetAtlas("Soulbinds_Portrait_Lock")
	self.Castbar.Shield:SetSize(self:GetHeight() + 14, self:GetHeight() + 14)
	self.Castbar.Shield:SetPoint("TOP", self.Castbar, "CENTER", 0, 6)

	self.Castbar.Time = K.CreateFontString(self.Castbar, 12, "", "", false, "RIGHT", 0, -1)
	self.Castbar.Text = K.CreateFontString(self.Castbar, 12, "", "", false, "LEFT", 0, -1)
	self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -5, 0)
	self.Castbar.Text:SetJustifyH("LEFT")

	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetSize(self:GetHeight() * 2 + 10, self:GetHeight() * 2 + 10)
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -3, 0)
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:CreateShadow(true)
	self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
	self.Castbar.Button:SetFrameLevel(self.Castbar:GetFrameLevel())

	self.Castbar.glowFrame = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.glowFrame:SetPoint("CENTER", self.Castbar.Icon)
	self.Castbar.glowFrame:SetSize(self:GetHeight() * 2 + 5, self:GetHeight() * 2 + 5)

	self.Castbar.spellTarget = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize + 2)
	self.Castbar.spellTarget:ClearAllPoints()
	self.Castbar.spellTarget:SetJustifyH("LEFT")
	self.Castbar.spellTarget:SetPoint("TOPLEFT", self.Castbar.Text, "BOTTOMLEFT", 0, -6)
	self:RegisterEvent("UNIT_TARGET", updateSpellTarget)

	self.Castbar.stageString = K.CreateFontString(self.Castbar, 22)
	self.Castbar.stageString:ClearAllPoints()
	self.Castbar.stageString:SetPoint("TOPLEFT", self.Castbar.Icon, -2, 2)

	self.Castbar.decimal = "%.1f"
	self.Castbar.timeToHold = 0.5
	self.Castbar.PostCastStart = Module.UpdateCastBarColor
	self.Castbar.PostCastInterruptible = Module.UpdateCastBarColor
	self.Castbar.PostCastStop = Module.Castbar_FailedColor
	self.Castbar.PostCastFail = Module.Castbar_FailedColor
	self.Castbar.PostCastInterrupted = Module.Castbar_UpdateInterrupted
	self.Castbar.CreatePip = Module.CreatePip
	self.Castbar.PostUpdatePips = Module.PostUpdatePips
	self.Castbar.CustomTimeText = Module.CustomTimeText
	self.Castbar.CustomDelayText = Module.CustomTimeText

	-- Raid Target Indicator
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)
	self.RaidTargetIndicator:SetSize(18, 18)

	-- Health Prediction
	-- REASON: Implement health prediction (incoming heals and absorbs) for better health awareness.
	do
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(self.Health)
		local frameLevel = frame:GetFrameLevel()
		local normalTexture = K.GetTexture(C["General"].Texture)

		local myBar = CreateFrame("StatusBar", nil, frame)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(normalTexture)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.5)
		myBar:SetFrameLevel(frameLevel)
		myBar:Hide()

		local otherBar = CreateFrame("StatusBar", nil, frame)
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarTexture(normalTexture)
		otherBar:SetStatusBarColor(0, 1, 0, 0.5)
		otherBar:SetFrameLevel(frameLevel)
		otherBar:Hide()

		local absorbBar = CreateFrame("StatusBar", nil, frame)
		absorbBar:SetPoint("TOP")
		absorbBar:SetPoint("BOTTOM")
		absorbBar:SetPoint("LEFT", otherBar:GetStatusBarTexture(), "RIGHT")
		absorbBar:SetStatusBarTexture(normalTexture)
		absorbBar:SetStatusBarColor(0.66, 1, 1)
		absorbBar:SetFrameLevel(frameLevel)
		absorbBar:SetAlpha(0.5)
		absorbBar:Hide()
		local tex = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(absorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local overAbsorbBar = CreateFrame("StatusBar", nil, frame)
		overAbsorbBar:SetAllPoints()
		overAbsorbBar:SetStatusBarTexture(normalTexture)
		overAbsorbBar:SetStatusBarColor(0.66, 1, 1)
		overAbsorbBar:SetFrameLevel(frameLevel)
		overAbsorbBar:SetAlpha(0.35)
		overAbsorbBar:Hide()
		local tex = overAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(overAbsorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetStatusBarTexture(normalTexture)
		healAbsorbBar:SetStatusBarColor(1, 0, 0.5)
		healAbsorbBar:SetFrameLevel(frameLevel)
		healAbsorbBar:SetAlpha(0.35)
		healAbsorbBar:Hide()
		local tex = healAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local overAbsorb = self.Health:CreateTexture(nil, "OVERLAY", nil, 2)
		overAbsorb:SetWidth(8)
		overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		overAbsorb:SetBlendMode("ADD")
		overAbsorb:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 0)
		overAbsorb:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -0)
		overAbsorb:Hide()

		local overHealAbsorb = frame:CreateTexture(nil, "OVERLAY")
		overHealAbsorb:SetWidth(15)
		overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		overHealAbsorb:SetBlendMode("ADD")
		overHealAbsorb:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
		overHealAbsorb:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)
		overHealAbsorb:Hide()

		self.HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
			overAbsorbBar = overAbsorbBar,
			overAbsorb = overAbsorb,
			overHealAbsorb = overHealAbsorb,
			maxOverflow = 1,
			PostUpdate = Module.PostUpdatePrediction,
		}
		self.predicFrame = frame
	end

	-- Aura Container
	-- REASON: Manage buffs and debuffs display above the nameplate.
	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Auras.spacing = 4
	self.Auras.initdialAnchor = "BOTTOMLEFT"
	self.Auras["growth-y"] = "UP"

	-- REASON: Adjust aura position if class resource bars are enabled on nameplates.
	if C["Nameplate"].NameplateClassPower then
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 8 + C["Nameplate"].PlateHeight)
		self.Auras:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 8 + C["Nameplate"].PlateHeight)
	else
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6)
		self.Auras:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 6)
	end

	self.Auras.numTotal = C["Nameplate"].MaxAuras
	self.Auras.size = C["Nameplate"].AuraSize
	self.Auras.gap = false
	self.Auras.disableMouse = true
	self.Auras.FilterAura = Module.CustomFilter

	Module:UpdateAuraContainer(self:GetWidth(), self.Auras, self.Auras.numTotal)

	self.Auras.showStealableBuffs = true
	self.Auras.PostCreateButton = Module.PostCreateButton
	self.Auras.PostUpdateButton = Module.PostUpdateButton
	self.Auras.PostUpdateInfo = Module.AurasPostUpdateInfo

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

	-- REASON: Register various custom nameplate extensions.
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
	-- REASON: Enable or disable the oUF Auras element based on player settings.
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
	-- REASON: Dynamically adjust aura position and sizing when nameplate width or options change.
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
	-- REASON: Update nameplate dimensions and oUF tags based on the current plate type (NameOnly vs Bar).
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
end

function Module:RefreshNameplats()
	-- REASON: Iterate through all active nameplates to apply global setting changes.
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
	Module:RefreshNameplats()
	Module:ResizeTargetPower()
end

-- ---------------------------------------------------------------------------
-- Refresher & Visibility Logic
-- ---------------------------------------------------------------------------
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

function Module:UpdatePlateByType()
	local name = self.nameText
	local level = self.levelText
	local hpval = self.healthValue
	local title = self.npcTitle
	local guild = self.guildName
	local raidtarget = self.RaidTargetIndicator
	local questIcon = self.questIcon

	local shouldHideName = self.widgetsOnly
	if shouldHideName then
		name:Hide()
	else
		name:Show()
		name:UpdateTag()
		name:ClearAllPoints()
	end
	raidtarget:ClearAllPoints()

	-- REASON: Disable interactive elements for soft targets (e.g. herbs, objects) to keep the UI clean.
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

	-- REASON: Handle transitioning between full nameplate bars and "NameOnly" mode.
	if self.plateType == "NameOnly" then
		for _, element in ipairs(DisabledElements) do
			if self:IsElementEnabled(element) then
				self:DisableElement(element)
			end
		end

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
			questIcon:SetPoint("LEFT", name, "RIGHT", -6, 0)
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

		name:SetJustifyH("LEFT")

		level:Show()
		hpval:Show()
		title:Hide()
		guild:Hide()

		raidtarget:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)

		if questIcon then
			questIcon:SetPoint("LEFT", self, "RIGHT", 4, 0)
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
	-- REASON: Determine if the nameplate should be in "NameOnly" mode or show health bars.
	self.reaction = UnitReaction(unit, "player")
	self.isFriendly = self.reaction and self.reaction >= 4 and not UnitCanAttack("player", unit)
	self.isSoftTarget = UnitIsUnit(unit, "softinteract")

	local forceShow = C.NameplateForceShow and ((self.npcID and C.NameplateForceShow[self.npcID]) or (self.unitName and C.NameplateForceShow[self.unitName]))

	if forceShow then
		self.plateType = "None"
	elseif (C["Nameplate"].NameOnly and self.isFriendly) or self.widgetsOnly or self.isSoftTarget then
		self.plateType = "NameOnly"
	elseif C["Nameplate"].FriendPlate and self.isFriendly then
		self.plateType = "FriendPlate"
	else
		self.plateType = "None"
	end

	-- REASON: Only trigger element toggling if the plate type actually changes for performance.
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

function Module:OnUnitSoftTargetChanged(previousTarget, currentTarget)
	if not GetCVarBool("SoftTargetIconGameObject") then
		return
	end

	-- REASON: Update all nameplates when the player's soft target changes to refresh visibility of interact cues.
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

function Module:RefreshPlateOnFactionChanged()
	K:UnregisterEvent("UNIT_FACTION", Module.OnUnitFactionChanged)
	K:UnregisterEvent("PLAYER_SOFT_INTERACT_CHANGED", Module.OnUnitSoftTargetChanged)

	K:RegisterEvent("UNIT_FACTION", Module.OnUnitFactionChanged)
	K:RegisterEvent("PLAYER_SOFT_INTERACT_CHANGED", Module.OnUnitSoftTargetChanged)
end

function Module:PostUpdatePlates(event, unit)
	if not self then
		return
	end

	-- REASON: Handle logic for units being added or removed from the screen (recycling).
	if event == "NAME_PLATE_UNIT_ADDED" then
		self.unitName = UnitName(unit)
		self.unitGUID = UnitGUID(unit)
		self.isPlayer = UnitIsPlayer(unit)
		self.isFriendly = not UnitCanAttack("player", unit)
		self.npcID = K.GetNPCID(self.unitGUID)
		self.isCustomUnit = customUnits[self.unitName] or customUnits[self.npcID]
		self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

		-- REASON: Handle Blizzard widget containers (e.g. for dungeon mechanics or NPC dialogues).
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

		self:SetScale(C["General"].UIScale)
		Module.RefreshPlateType(self, unit)

		-- WARNING: Mitigate Blizzard bug where unit name might be delayed upon unit being added.
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

	-- REASON: Force an update of all registered nameplate elements when a new unit appears.
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

-- ---------------------------------------------------------------------------
-- Player Nameplate
-- ---------------------------------------------------------------------------
function Module:PlateVisibility(event)
	-- REASON: Manage the visibility of the personal resource display, often fading it out out-of-combat.
	if (event == "PLAYER_REGEN_DISABLED" or InCombatLockdown()) and UnitIsUnit("player", self.unit) then
		K.UIFrameFadeIn(self.Health, 0.2, self.Health:GetAlpha(), 1)
		K.UIFrameFadeIn(self.Power, 0.2, self.Power:GetAlpha(), 1)
		K.UIFrameFadeIn(self.Auras, 0.2, self.Power:GetAlpha(), 1)
	else
		K.UIFrameFadeOut(self.Health, 0.2, self.Health:GetAlpha(), 0)
		K.UIFrameFadeOut(self.Power, 0.2, self.Power:GetAlpha(), 0)
		K.UIFrameFadeOut(self.Auras, 0.2, self.Power:GetAlpha(), 0)
	end
end

function Module:CreatePlayerPlate()
	self.mystyle = "PlayerPlate"

	local iconSize, margin = C["Nameplate"].PPIconSize, 2
	self:SetSize(iconSize * 5 + margin * 4, C["Nameplate"].PPHeight)
	self:EnableMouse(false)
	self.iconSize = iconSize

	-- Health & Power
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Health:SetStatusBarColor(0.1, 0.1, 0.1)
	self.Health:CreateShadow(true)
	self.Health.colorClass = true

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Power:SetHeight(C["Nameplate"].PPPHeight)
	self.Power:SetWidth(self:GetWidth())
	self.Power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Power:CreateShadow(true)
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	-- REASON: Create class-specific resource bars (e.g. combo points, runes) for the player plate.
	Module:CreateClassPower(self)

	if K.Class == "MONK" then
		-- REASON: Special handling for Monk's stagger bar on the personal resource display.
		self.Stagger = CreateFrame("StatusBar", self:GetName() .. "Stagger", self)
		self.Stagger:SetPoint("TOPLEFT", self.Health, 0, 8)
		self.Stagger:SetSize(self:GetWidth(), self:GetHeight())
		self.Stagger:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		self.Stagger:CreateShadow(true)

		self.Stagger.Value = self.Stagger:CreateFontString(nil, "OVERLAY")
		self.Stagger.Value:SetFontObject(K.UIFont)
		self.Stagger.Value:SetPoint("CENTER", self.Stagger, "CENTER", 0, 0)
		self:Tag(self.Stagger.Value, "[monkstagger]")
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
	-- REASON: Enable or disable the personal resource display based on player preference.
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

	-- REASON: Register events to control the fading/visibility of the player plate based on combat and location.
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

-- ---------------------------------------------------------------------------
-- Target Nameplate Elements
-- ---------------------------------------------------------------------------
function Module:CreateTargetPlate()
	self.mystyle = "targetplate"
	self:EnableMouse(false)
	self:SetSize(10, 10)

	-- REASON: Create class resource bars that can be anchored to the current target's nameplate.
	Module:CreateClassPower(self)
end

function Module:UpdateTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	local bar = plate.ClassPowerBar
	local nameplate = C_NamePlate_GetNamePlateForUnit("target")

	-- REASON: Reparent and anchor the class resource bar to the current target's nameplate for better focus.
	if nameplate and nameplate.unitFrame then
		bar:SetParent(nameplate.unitFrame)
		bar:ClearAllPoints()
		bar:SetPoint("BOTTOM", nameplate.unitFrame, "TOP", 0, 24)
		bar:Show()
	else
		bar:Hide()
		-- REASON: Return the bar to its original holder to avoid memory issues with recycled Blizzard frames.
		bar:SetParent(plate)
		bar:ClearAllPoints()
	end
end

function Module:ToggleTargetClassPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	local playerPlate = _G.oUF_PlayerPlate
	local isEnabled = C["Nameplate"].NameplateClassPower

	-- REASON: Switch between showing class resources on the personal plate or the target plate.
	if isEnabled then
		plate:Enable()
		if plate.ClassPower then
			if not plate:IsElementEnabled("ClassPower") then
				plate:EnableElement("ClassPower")
				plate.ClassPower:ForceUpdate()
			end
			if playerPlate and playerPlate:IsElementEnabled("ClassPower") then
				playerPlate:DisableElement("ClassPower")
			end
		end

		if plate.Runes then
			if not plate:IsElementEnabled("Runes") then
				plate:EnableElement("Runes")
				plate.Runes:ForceUpdate()
			end
			if playerPlate and playerPlate:IsElementEnabled("Runes") then
				playerPlate:DisableElement("Runes")
			end
		end
	else
		plate:Disable()
		if plate.ClassPower then
			if plate:IsElementEnabled("ClassPower") then
				plate:DisableElement("ClassPower")
			end
			if playerPlate and not playerPlate:IsElementEnabled("ClassPower") then
				playerPlate:EnableElement("ClassPower")
				playerPlate.ClassPower:ForceUpdate()
			end
		end

		if plate.Runes then
			if plate:IsElementEnabled("Runes") then
				plate:DisableElement("Runes")
			end
			if playerPlate and not playerPlate:IsElementEnabled("Runes") then
				playerPlate:EnableElement("Runes")
				playerPlate.Runes:ForceUpdate()
			end
		end
	end
end

function Module:ResizeTargetPower()
	local plate = _G.oUF_TargetPlate
	if not plate then
		return
	end

	-- REASON: Adjust the scale of target-anchored resource bars to match the nameplate width.
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

function Module:CreateGCDTicker(self)
	if not C["Nameplate"].PPGCDTicker then
		return
	end

	-- REASON: Add a small spark/ticker on the personal resource bar to track Global Cooldown.
	local GCD = CreateFrame("Frame", nil, self.Power)
	GCD:SetWidth(self:GetWidth())
	GCD:SetHeight(C["Nameplate"].PPPHeight)
	GCD:SetPoint("LEFT", self.Power, "LEFT", 0, 0)

	GCD.Color = { 1, 1, 1, 0.6 }
	GCD.Texture = C["Media"].Textures.Spark128Texture
	GCD.Height = C["Nameplate"].PPPHeight
	GCD.Width = 64

	self.GCD = GCD
end
