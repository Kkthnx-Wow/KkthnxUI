--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Surfaces hidden character-sheet stats and tidies readouts.
-- - Design: Post-update rows (no PAPERDOLL_STATCATEGORIES injection).
-- - Events: PaperDollFrame_UpdateStats hook; PLAYER_REGEN_ENABLED for scroll extent.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")
local NotSecret = K.NotSecret

local math_floor = _G.math.floor
local math_max = _G.math.max
local math_min = _G.math.min
local string_format = _G.string.format

local _G = _G
local BreakUpLargeNumbers = _G.BreakUpLargeNumbers
local CreateFrame = _G.CreateFrame
local GetAverageItemLevel = _G.GetAverageItemLevel
local GetMeleeHaste = _G.GetMeleeHaste
local GetSpecializationRoleEnum = _G.GetSpecializationRoleEnum
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local UnitAttackSpeed = _G.UnitAttackSpeed
local UnitSex = _G.UnitSex

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_PaperDollInfo_GetMinItemLevel = _G.C_PaperDollInfo.GetMinItemLevel
local C_PaperDollInfo_OffhandHasShield = _G.C_PaperDollInfo.OffhandHasShield
local C_SpecializationInfo_GetSpecializationInfo = _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetSpecializationInfo
local C_SpecializationInfo_GetSpecialization = _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetSpecialization
local C_Timer_After = _G.C_Timer and _G.C_Timer.After
local GetItemLevelColor = _G.GetItemLevelColor

local scrollContainer
local scrollFrame
local scrollChild
local scrollInstalled = false
local extentPending = false
local extentPendingCombat = false
local hooksInstalled = false

local INSET_PAD_LEFT, INSET_PAD_TOP = 3, -3
local INSET_PAD_RIGHT, INSET_PAD_BOTTOM = -3, 2

-- REASON: Extra rows appended after Blizzard's live update — never inject categories
-- (injection taints UnitStat comparisons in combat; armor is secret in instances).
local EXTRA_STATS = {
	{ stat = "STAGGER", hideAt = 0, roles = { _G.Enum.LFGRole.Tank } },
	{ stat = "ATTACK_DAMAGE", primary = _G.LE_UNIT_STAT_STRENGTH, roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage } },
	{ stat = "ATTACK_AP", hideAt = 0, primary = _G.LE_UNIT_STAT_STRENGTH, roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage } },
	{ stat = "ATTACK_ATTACKSPEED", primary = _G.LE_UNIT_STAT_STRENGTH, roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage } },
	{ stat = "ATTACK_DAMAGE", primary = _G.LE_UNIT_STAT_AGILITY, roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage } },
	{ stat = "ATTACK_AP", hideAt = 0, primary = _G.LE_UNIT_STAT_AGILITY, roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage } },
	{ stat = "ATTACK_ATTACKSPEED", primary = _G.LE_UNIT_STAT_AGILITY, roles = { _G.Enum.LFGRole.Tank, _G.Enum.LFGRole.Damage } },
	{ stat = "SPELLPOWER", hideAt = 0, primary = _G.LE_UNIT_STAT_INTELLECT },
	{ stat = "MANAREGEN", hideAt = 0, primary = _G.LE_UNIT_STAT_INTELLECT },
	{ stat = "ENERGY_REGEN", hideAt = 0, primary = _G.LE_UNIT_STAT_AGILITY },
	{ stat = "RUNE_REGEN", hideAt = 0, primary = _G.LE_UNIT_STAT_STRENGTH },
	{ stat = "FOCUS_REGEN", hideAt = 0, primary = _G.LE_UNIT_STAT_AGILITY },
	{ stat = "MOVESPEED" },
	{ stat = "LIFESTEAL", hideAt = 0 },
	{ stat = "AVOIDANCE", hideAt = 0 },
	{ stat = "SPEED", hideAt = 0 },
	{ stat = "DODGE", roles = { _G.Enum.LFGRole.Tank } },
	{ stat = "PARRY", hideAt = 0, roles = { _G.Enum.LFGRole.Tank } },
	{ stat = "BLOCK", hideAt = 0, roles = { _G.Enum.LFGRole.Tank }, showFunc = C_PaperDollInfo_OffhandHasShield },
}

local function hasRole(roles, role)
	if not roles then
		return true
	end
	for i = 1, #roles do
		if roles[i] == role then
			return true
		end
	end
	return false
end

local function shouldShowExtraStat(stat, spec, role)
	if stat.showFunc and not stat.showFunc() then
		return false
	end
	if stat.primary and spec and C_SpecializationInfo_GetSpecializationInfo then
		local primaryStat = select(6, C_SpecializationInfo_GetSpecializationInfo(spec, false, false, nil, UnitSex("player")))
		if primaryStat ~= stat.primary then
			return false
		end
	end
	return hasRole(stat.roles, role)
end

local function getPaneContentHeight(pane)
	local paneTop = pane:GetTop()
	if not paneTop or not NotSecret(paneTop) then
		return 1
	end

	local lowestBottom = paneTop
	local function track(frame)
		if frame and frame.IsShown and frame:IsShown() then
			local bottom = frame:GetBottom()
			if bottom and NotSecret(bottom) and bottom < lowestBottom then
				lowestBottom = bottom
			end
		end
	end

	track(pane.ItemLevelCategory)
	track(pane.ItemLevelFrame)
	track(pane.AttributesCategory)
	track(pane.EnhancementsCategory)
	for statFrame in pane.statsFramePool:EnumerateActive() do
		track(statFrame)
	end

	if not NotSecret(lowestBottom) then
		return 1
	end
	return math_max(paneTop - lowestBottom + 16, 1)
end

local function updateStatsScrollExtent()
	if not (scrollChild and scrollFrame and scrollContainer) then
		return
	end
	if InCombatLockdown() then
		extentPendingCombat = true
		return
	end

	local pane = _G.CharacterStatsPane
	local width = scrollContainer:GetWidth()
	if not width or width <= 0 or not NotSecret(width) then
		width = 200
	end

	local height = getPaneContentHeight(pane)
	if not NotSecret(height) then
		return
	end
	scrollChild:SetSize(width, height)
	if scrollFrame.UpdateScrollChildRect then
		scrollFrame:UpdateScrollChildRect()
	end

	local range = scrollFrame:GetVerticalScrollRange()
	local scroll = scrollFrame:GetVerticalScroll()
	if NotSecret(range) and NotSecret(scroll) and scroll > range then
		scrollFrame:SetVerticalScroll(range)
	end
end

local function scheduleStatsScrollExtent()
	if extentPending or not C_Timer_After then
		return
	end
	extentPending = true
	C_Timer_After(0, function()
		extentPending = false
		updateStatsScrollExtent()
	end)
end

local function onStatsScrollWheel(frame, delta)
	local cur = frame:GetVerticalScroll()
	local range = frame:GetVerticalScrollRange()
	if not NotSecret(cur) or not NotSecret(range) or not NotSecret(delta) then
		return
	end
	frame:SetVerticalScroll(math_max(0, math_min(range, cur - delta * 20)))
end

local function syncScrollContainerVisibility()
	if scrollContainer and _G.CharacterStatsPane then
		scrollContainer:SetShown(_G.CharacterStatsPane:IsShown())
	end
end

local function installStatsScrollFrame()
	if scrollInstalled then
		syncScrollContainerVisibility()
		scheduleStatsScrollExtent()
		return true
	end

	local inset = _G.CharacterFrameInsetRight
	local pane = _G.CharacterStatsPane
	if not (inset and pane) then
		return false
	end

	scrollInstalled = true

	scrollContainer = CreateFrame("Frame", nil, inset)
	scrollContainer:SetPoint("TOPLEFT", inset, "TOPLEFT", INSET_PAD_LEFT, INSET_PAD_TOP)
	scrollContainer:SetPoint("BOTTOMRIGHT", inset, "BOTTOMRIGHT", INSET_PAD_RIGHT, INSET_PAD_BOTTOM)
	scrollContainer:SetFrameLevel(inset:GetFrameLevel() + 2)
	scrollContainer:SetScript("OnSizeChanged", function(self)
		if scrollChild then
			scrollChild:SetWidth(self:GetWidth())
			scheduleStatsScrollExtent()
		end
	end)

	scrollFrame = CreateFrame("ScrollFrame", "KKUI_CharacterStatsScroll", scrollContainer)
	scrollFrame:SetAllPoints()
	scrollFrame:EnableMouseWheel(true)
	scrollFrame:SetScript("OnMouseWheel", onStatsScrollWheel)

	scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild:SetSize(scrollContainer:GetWidth() or 200, 1)
	scrollFrame:SetScrollChild(scrollChild)

	pane:ClearAllPoints()
	pane:SetParent(scrollChild)
	pane:SetAllPoints(scrollChild)

	pane:HookScript("OnShow", function()
		syncScrollContainerVisibility()
		scheduleStatsScrollExtent()
	end)
	pane:HookScript("OnHide", syncScrollContainerVisibility)

	if type(_G.PaperDollFrame_UpdateSidebarTabs) == "function" then
		hooksecurefunc("PaperDollFrame_UpdateSidebarTabs", syncScrollContainerVisibility)
	end

	local paperDoll = _G.PaperDollFrame
	if paperDoll then
		paperDoll:HookScript("OnShow", function()
			if scrollFrame then
				scrollFrame:SetVerticalScroll(0)
			end
			scheduleStatsScrollExtent()
		end)
	end

	syncScrollContainerVisibility()
	scheduleStatsScrollExtent()

	if paperDoll and paperDoll:IsShown() and type(_G.PaperDollFrame_UpdateStats) == "function" then
		_G.PaperDollFrame_UpdateStats()
	end
	return true
end

local function ensureStatsScrollFrame()
	if scrollInstalled then
		return true
	end
	if installStatsScrollFrame() then
		return true
	end
	if not Module._deferredStatsScrollInstall then
		Module._deferredStatsScrollInstall = true
		local paperDoll = _G.PaperDollFrame
		if paperDoll then
			paperDoll:HookScript("OnShow", function()
				installStatsScrollFrame()
			end)
		end
	end
	return scrollInstalled
end

local function addExtraStatRows()
	if InCombatLockdown() then
		return
	end

	local pane = _G.CharacterStatsPane
	local pool = pane and pane.statsFramePool
	local enhancements = pane and pane.EnhancementsCategory
	if not (pool and enhancements) then
		return
	end

	local _, anchor = enhancements:GetPoint()
	if not anchor then
		return
	end

	local spec = C_SpecializationInfo_GetSpecialization and C_SpecializationInfo_GetSpecialization()
	local role = spec and GetSpecializationRoleEnum and GetSpecializationRoleEnum(spec)
	local lastAnchor = anchor
	local numAdded = 0

	for i = 1, #EXTRA_STATS do
		local stat = EXTRA_STATS[i]
		local info = _G.PAPERDOLL_STATINFO and _G.PAPERDOLL_STATINFO[stat.stat]
		if info and shouldShowExtraStat(stat, spec, role) then
			local statFrame = pool:Acquire()
			statFrame:ClearAllPoints()
			statFrame.onEnterFunc = nil
			statFrame.UpdateTooltip = nil
			statFrame.numericValue = 0

			if info.updateFunc then
				info.updateFunc(statFrame, "player")
			end

			local value = statFrame.numericValue
			if statFrame:IsShown() and NotSecret(value) and (not stat.hideAt or stat.hideAt ~= value) then
				statFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, 0)
				numAdded = numAdded + 1
				if statFrame.Background then
					statFrame.Background:SetShown((numAdded % 2) == 0)
				end
				lastAnchor = statFrame
			else
				pool:Release(statFrame)
			end
		end
	end

	if numAdded > 0 then
		enhancements:ClearAllPoints()
		enhancements:SetPoint("TOP", lastAnchor, "BOTTOM", 0, 0)
	end
end

local function styleCharacterStatFrames()
	local gameFont = _G.Game11Font
	if not (_G.CharacterStatsPane and gameFont) then
		return
	end
	for statFrame in _G.CharacterStatsPane.statsFramePool:EnumerateActive() do
		if not statFrame.__kkthnx_stats_styled then
			statFrame.Label:SetFontObject(gameFont)
			statFrame.Value:SetFontObject(gameFont)
			statFrame.__kkthnx_stats_styled = true
		end
	end
end

-- REASON: Blizzard tints the item-level readout by
-- quality (blue/purple/etc); when it has no tint the text is plain white.
-- Repaint just the white case as a soft artifact-gold and leave Blizzard's
-- coloured cases alone.
local ITEMLEVEL_ARTIFACT_R, ITEMLEVEL_ARTIFACT_G, ITEMLEVEL_ARTIFACT_B = 0.90, 0.80, 0.50
local function colorItemLevel()
	local pane = _G.CharacterStatsPane
	local value = pane and pane.ItemLevelFrame and pane.ItemLevelFrame.Value
	if not (value and GetItemLevelColor) then
		return
	end

	local r, g, b = GetItemLevelColor()
	if not (r and g and b) or not NotSecret(r) or not NotSecret(g) or not NotSecret(b) then
		return
	end

	if r > 0.99 and g > 0.99 and b > 0.99 then
		value:SetTextColor(ITEMLEVEL_ARTIFACT_R, ITEMLEVEL_ARTIFACT_G, ITEMLEVEL_ARTIFACT_B)
	end
end

local function onPaperDollUpdateStats()
	if InCombatLockdown() then
		return
	end
	addExtraStatRows()
	styleCharacterStatFrames()
	colorItemLevel()
	scheduleStatsScrollExtent()
end

local function patchRegenUpdateFuncs()
	local info = _G.PAPERDOLL_STATINFO
	if not info then
		return
	end

	if info.ENERGY_REGEN and info.ENERGY_REGEN.updateFunc then
		info.ENERGY_REGEN.updateFunc = function(statFrame, unitID)
			statFrame.numericValue = 0
			_G.PaperDollFrame_SetEnergyRegen(statFrame, unitID)
		end
	end
	if info.RUNE_REGEN and info.RUNE_REGEN.updateFunc then
		info.RUNE_REGEN.updateFunc = function(statFrame, unitID)
			statFrame.numericValue = 0
			_G.PaperDollFrame_SetRuneRegen(statFrame, unitID)
		end
	end
	if info.FOCUS_REGEN and info.FOCUS_REGEN.updateFunc then
		info.FOCUS_REGEN.updateFunc = function(statFrame, unitID)
			statFrame.numericValue = 0
			_G.PaperDollFrame_SetFocusRegen(statFrame, unitID)
		end
	end
end

function Module:createImprovedStatFrames()
	if not C["Misc"].ImprovedStats or C_AddOns_IsAddOnLoaded("DejaCharacterStats") then
		return
	end

	if not (_G.PAPERDOLL_STATINFO and _G.CharacterStatsPane and type(_G.PaperDollFrame_UpdateStats) == "function") then
		return
	end

	patchRegenUpdateFuncs()
	ensureStatsScrollFrame()

	if not hooksInstalled then
		hooksInstalled = true

		local function updatePaperDollAttackSpeed(statFrame, unitID)
			local meleeHasteValue = GetMeleeHaste()
			local mainHandSpeed, offHandSpeed = UnitAttackSpeed(unitID)
			local speedText = string_format("%.2f", mainHandSpeed)
			if offHandSpeed then
				speedText = speedText .. " / " .. string_format("%.2f", offHandSpeed)
			end
			_G.PaperDollFrame_SetLabelAndText(statFrame, _G.WEAPON_SPEED, speedText, false, mainHandSpeed)
			statFrame.tooltip = _G.HIGHLIGHT_FONT_COLOR_CODE .. string_format(_G.PAPERDOLLFRAME_TOOLTIP_FORMAT, _G.ATTACK_SPEED) .. " " .. speedText .. _G.FONT_COLOR_CODE_CLOSE
			statFrame.tooltip2 = string_format(_G.STAT_ATTACK_SPEED_BASE_TOOLTIP, BreakUpLargeNumbers(meleeHasteValue))
			statFrame:Show()
		end

		hooksecurefunc("PaperDollFrame_SetAttackSpeed", updatePaperDollAttackSpeed)

		hooksecurefunc("PaperDollFrame_SetItemLevel", function(statFrame, unitID)
			if unitID ~= "player" then
				return
			end
			local averageLevel, equippedLevel = GetAverageItemLevel()
			local minimumLevel = C_PaperDollInfo_GetMinItemLevel()
			-- BUGFIX: minimumLevel was used in math_max() without a secret check,
			-- unlike averageLevel/equippedLevel above. Not secret today, but guard
			-- anyway so a future predicate change falls back to Blizzard's readout.
			if not NotSecret(averageLevel) or not NotSecret(equippedLevel) or not NotSecret(minimumLevel) then
				return
			end
			minimumLevel = minimumLevel or 0
			local itemLevelValue = math_max(minimumLevel, equippedLevel)
			itemLevelValue = math_floor(itemLevelValue * 10 + 0.5) / 10
			averageLevel = math_floor(averageLevel * 10 + 0.5) / 10

			local itemLevelText = itemLevelValue
			if itemLevelValue ~= averageLevel then
				itemLevelText = itemLevelValue .. " / " .. averageLevel
			end
			_G.PaperDollFrame_SetLabelAndText(statFrame, _G.STAT_AVERAGE_ITEM_LEVEL, itemLevelText, false, itemLevelValue)
		end)

		hooksecurefunc("PaperDollFrame_SetLabelAndText", function(statFrame, labelText, _, isStatPercentage)
			if isStatPercentage or labelText == _G.STAT_HASTE then
				local numericValue = statFrame.numericValue
				if NotSecret(numericValue) then
					statFrame.Value:SetFormattedText("%.2f%%", numericValue)
				end
			end
		end)

		hooksecurefunc("PaperDollFrame_UpdateStats", onPaperDollUpdateStats)

		if not Module._statsRegenFrame then
			local regenFrame = CreateFrame("Frame")
			regenFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
			regenFrame:SetScript("OnEvent", function()
				if extentPendingCombat then
					extentPendingCombat = false
					updateStatsScrollExtent()
				end
				if _G.PaperDollFrame and _G.PaperDollFrame:IsShown() then
					onPaperDollUpdateStats()
				end
			end)
			Module._statsRegenFrame = regenFrame
		end
	end

	if _G.PaperDollFrame and _G.PaperDollFrame:IsShown() then
		_G.PaperDollFrame_UpdateStats()
	end
end

Module:RegisterMisc("MissingStats", Module.createImprovedStatFrames)
