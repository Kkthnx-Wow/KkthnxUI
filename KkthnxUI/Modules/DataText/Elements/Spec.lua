--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays the player's current specialization and loot spec, providing talent info on hover.
-- - Design: Uses a dropdown menu for quick spec/loot switching and handles the modern talent trait system.
-- - Events: PLAYER_ENTERING_WORLD, ACTIVE_PLAYER_SPECIALIZATION_CHANGED, PLAYER_LOOT_SPEC_UPDATED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local BLUE_FONT_COLOR = _G.BLUE_FONT_COLOR
local C_ClassTalents_GetLastSelectedSavedConfigID = _G.C_ClassTalents.GetLastSelectedSavedConfigID
local C_ClassTalents_GetStarterBuildActive = _G.C_ClassTalents.GetStarterBuildActive
local C_ClassTalents_LoadConfig = _G.C_ClassTalents.LoadConfig
local C_ClassTalents_SetStarterBuildActive = _G.C_ClassTalents.SetStarterBuildActive
local C_ClassTalents_UpdateLastSelectedSavedConfigID = _G.C_ClassTalents.UpdateLastSelectedSavedConfigID
local C_CurrencyInfo_GetCurrencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo
local C_SpecializationInfo_CanPlayerUsePVPTalentUI = _G.C_SpecializationInfo.CanPlayerUsePVPTalentUI
local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = _G.C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local C_Spell_GetSpellName = _G.C_Spell.GetSpellName
local C_Traits_GetConfigInfo = _G.C_Traits.GetConfigInfo
local CLUB_FINDER_SPEC = _G.CLUB_FINDER_SPEC
local CreateFrame = _G.CreateFrame
local DropDownList1 = _G.DropDownList1
local GameTooltip = _G.GameTooltip
local GetLootSpecialization = _G.GetLootSpecialization
local GetPvpTalentInfoByID = _G.GetPvpTalentInfoByID
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetTalentInfo = _G.GetTalentInfo
local InCombatLockdown = _G.InCombatLockdown
local LOOT_SPECIALIZATION_DEFAULT = _G.LOOT_SPECIALIZATION_DEFAULT
local MAX_TALENT_TIERS = _G.MAX_TALENT_TIERS
local PVP_TALENTS = _G.PVP_TALENTS
local PlayerSpellsUtil = _G.PlayerSpellsUtil
local SPECIALIZATION = _G.SPECIALIZATION
local STARTER_BUILD = _G.Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID
local SetLootSpecialization = _G.SetLootSpecialization
local SetSpecialization = _G.SetSpecialization
local TALENTS_BUTTON = _G.TALENTS_BUTTON
local UIErrorsFrame = _G.UIErrorsFrame
local UIParent = _G.UIParent
local format = string.format
local math_max = math.max
local next = next
local pairs = pairs
local select = select
local tinsert = table.insert
local unpack = unpack
local wipe = table.wipe

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local specDataText
local currentSpecIndex
local currentLootIndex
local specMenu
local numSpecs
local numLocalBase

local PVP_ICON_TEXTURE = C_CurrencyInfo_GetCurrencyInfo(1792).iconFileID

local EVENT_LIST = {
	"PLAYER_ENTERING_WORLD",
	"ACTIVE_PLAYER_SPECIALIZATION_CHANGED",
	"PLAYER_LOOT_SPEC_UPDATED",
}

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function addIcon(texture)
	-- REASON: Formats a texture ID into an inline icon string for tooltip and DataText display.
	return texture and "|T" .. texture .. ":12:16:0:0:50:50:4:46:4:46|t" or ""
end

local function onEvent()
	-- REASON: Updates the DataText icon based on current specialization and selected loot specialization.
	currentSpecIndex = GetSpecialization()
	if currentSpecIndex and currentSpecIndex < 5 then
		local _, name, _, icon = GetSpecializationInfo(currentSpecIndex)
		if not name then
			return
		end
		currentLootIndex = GetLootSpecialization()
		if currentLootIndex == 0 then
			icon = addIcon(icon)
		else
			icon = addIcon(select(4, GetSpecializationInfoByID(currentLootIndex)))
		end
		specDataText.Text:SetText(CLUB_FINDER_SPEC .. ": " .. icon)
	else
		specDataText.Text:SetText(CLUB_FINDER_SPEC .. ": " .. K.MyClassColor .. _G.NONE)
	end
end

local function onEnter()
	-- REASON: Populates the tooltip with current talents, PvP talents, and active trait configurations.
	if not currentSpecIndex or currentSpecIndex == 5 then
		return
	end

	GameTooltip:SetOwner(specDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(specDataText))
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0, 0.6, 1)
	GameTooltip:AddLine(" ")

	local specID, specName, _, specIcon = GetSpecializationInfo(currentSpecIndex)
	GameTooltip:AddLine(addIcon(specIcon) .. " " .. specName, 0.6, 0.8, 1)

	for t = 1, MAX_TALENT_TIERS do
		for c = 1, 3 do
			local _, name, icon, isSelected = GetTalentInfo(t, c, 1)
			if isSelected then
				GameTooltip:AddLine(addIcon(icon) .. " " .. name, 1, 1, 1)
			end
		end
	end

	local configID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
	local info = configID and _G.C_Traits.GetConfigInfo(configID)
	if info and info.name then
		GameTooltip:AddLine("   (" .. info.name .. ")", 1, 1, 1)
	end

	if C_SpecializationInfo_CanPlayerUsePVPTalentUI() then
		local pvpTalents = C_SpecializationInfo_GetAllSelectedPvpTalentIDs()

		if #pvpTalents > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(addIcon(PVP_ICON_TEXTURE) .. " " .. PVP_TALENTS, 0.6, 0.8, 1)
			for _, talentID in next, pvpTalents do
				local _, name, icon, _, _, _, isUnlocked = GetPvpTalentInfoByID(talentID)
				if name and isUnlocked then
					GameTooltip:AddLine(addIcon(icon) .. " " .. name, 1, 1, 1)
				end
			end
		end
		wipe(pvpTalents)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(" ", K.LeftButton .. "Toggle TalentFrame" .. " ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:AddDoubleLine(" ", K.RightButton .. "Select Your Spec" .. " ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:Show()
end

-- ---------------------------------------------------------------------------
-- Dropdown Menu Callbacks
-- ---------------------------------------------------------------------------
local function selectSpec(_, specIndex)
	if currentSpecIndex == specIndex then
		return
	end
	SetSpecialization(specIndex)
	DropDownList1:Hide()
end

local function checkSpec(self)
	return currentSpecIndex == self.arg1
end

local function selectLootSpec(_, index)
	SetLootSpecialization(index)
	DropDownList1:Hide()
end

local function checkLootSpec(self)
	return currentLootIndex == self.arg1
end

local function refreshDefaultLootSpec()
	if not currentSpecIndex or currentSpecIndex == 5 then
		return
	end
	local offset = 3 + numSpecs
	specMenu[numLocalBase - offset].text = format(LOOT_SPECIALIZATION_DEFAULT, (select(2, GetSpecializationInfo(currentSpecIndex))) or _G.NONE)
end

local function selectCurrentConfig(_, configID, specID)
	-- REASON: Handles loading of talent configurations, including safety checks for combat.
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor .. _G.ERR_NOT_IN_COMBAT)
		return
	end
	if configID == STARTER_BUILD then
		_G.C_ClassTalents.SetStarterBuildActive(true)
	else
		C_ClassTalents_LoadConfig(configID, true)
		_G.C_ClassTalents.SetStarterBuildActive(false)
	end
	_G.C_ClassTalents.UpdateLastSelectedSavedConfigID(specID or GetSpecializationInfo(currentSpecIndex), configID)
end

local function checkCurrentConfig(self)
	return C_ClassTalents_GetLastSelectedSavedConfigID(self.arg2) == self.arg1
end

local function refreshAllTraits()
	-- REASON: Dynamically rebuilds the trait/talent configuration list in the spec menu.
	local configCount = numLocalBase or 0
	local specID = GetSpecializationInfo(currentSpecIndex)
	local configIDs = specID and _G.C_ClassTalents.GetConfigIDsBySpecID(specID)
	if configIDs then
		for i = 1, #configIDs do
			local configID = configIDs[i]
			if configID then
				local info = _G.C_Traits.GetConfigInfo(configID)
				configCount = configCount + 1
				specMenu[configCount] = specMenu[configCount] or {}
				local entry = specMenu[configCount]
				entry.text = info.name
				entry.arg1 = configID
				entry.arg2 = specID
				entry.func = selectCurrentConfig
				entry.checked = checkCurrentConfig
			end
		end
	end

	for i = configCount + 1, #specMenu do
		if specMenu[i] then
			specMenu[i].text = nil
		end
	end
end

-- ---------------------------------------------------------------------------
-- Menu Construction
-- ---------------------------------------------------------------------------
local separatorMenu = {
	text = "",
	isTitle = true,
	notCheckable = true,
	iconOnly = true,
	icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
	iconInfo = {
		tCoordLeft = 0,
		tCoordRight = 1,
		tCoordTop = 0,
		tCoordBottom = 1,
		tSizeX = 0,
		tSizeY = 8,
		tFitDropDownSizeX = true,
	},
}

local function buildSpecMenu()
	if specMenu then
		return
	end

	specMenu = {
		{ text = SPECIALIZATION, isTitle = true, notCheckable = true },
		separatorMenu,
		{ text = _G.SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
		{ text = "", arg1 = 0, func = selectLootSpec, checked = checkLootSpec },
	}

	for i = 1, 4 do
		local id, name = GetSpecializationInfo(i)
		if id then
			numSpecs = (numSpecs or 0) + 1
			tinsert(specMenu, i + 1, { text = name, arg1 = i, func = selectSpec, checked = checkSpec })
			tinsert(specMenu, { text = name, arg1 = id, func = selectLootSpec, checked = checkLootSpec })
		end
	end

	tinsert(specMenu, separatorMenu)
	tinsert(specMenu, { text = C_Spell_GetSpellName(384255), isTitle = true, notCheckable = true })
	tinsert(specMenu, {
		text = BLUE_FONT_COLOR:WrapTextInColorCode(_G.TALENT_FRAME_DROP_DOWN_STARTER_BUILD),
		func = selectCurrentConfig,
		arg1 = STARTER_BUILD,
		checked = function()
			return C_ClassTalents_GetStarterBuildActive()
		end,
	})

	numLocalBase = #specMenu

	refreshDefaultLootSpec()
	K:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", refreshDefaultLootSpec)

	refreshAllTraits()
	K:RegisterEvent("TRAIT_CONFIG_DELETED", refreshAllTraits)
	K:RegisterEvent("TRAIT_CONFIG_UPDATED", refreshAllTraits)
	K:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", refreshAllTraits)
end

local function onMouseUp(self, btn)
	-- REASON: Interaction: Left-click toggles talent UI, Right-click opens the custom spec/loot menu.
	if not currentSpecIndex or currentSpecIndex == 5 then
		return
	end

	if btn == "LeftButton" then
		PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
	else
		buildSpecMenu()
		_G.K.LibEasyMenu.Create(specMenu, _G.K.EasyMenu, self, -80, 100, "MENU", 1)
		GameTooltip:Hide()
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateSpecDataText()
	-- REASON: Main entry point for specialization DataText; sets up frame, fonts, and automatic resizing logic.
	if not C["DataText"].Spec then
		return
	end

	specDataText = CreateFrame("Frame", nil, UIParent)

	specDataText.Text = K.CreateFontString(specDataText, 12)
	specDataText.Text:ClearAllPoints()
	specDataText.Text:SetPoint("LEFT", specDataText, "LEFT", 24, 0)

	specDataText.Texture = specDataText:CreateTexture(nil, "ARTWORK")
	specDataText.Texture:SetPoint("LEFT", specDataText, "LEFT", 0, 2)
	specDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\TalentsIcon")
	specDataText.Texture:SetSize(24, 24)
	specDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	for _, event in pairs(EVENT_LIST) do
		specDataText:RegisterEvent(event)
	end

	specDataText:SetScript("OnEvent", onEvent)
	specDataText:SetScript("OnEnter", onEnter)
	specDataText:SetScript("OnLeave", K.HideTooltip)
	specDataText:SetScript("OnMouseUp", onMouseUp)

	specDataText:HookScript("OnEvent", function()
		-- REASON: Automatically scales the frame and mover dimensions to fit dynamic text and icon content.
		local textW = specDataText.Text:GetStringWidth() or 0
		local iconW = (specDataText.Texture and specDataText.Texture:GetWidth()) or 0
		local totalW = textW + iconW
		local textH = specDataText.Text:GetLineHeight() or 12
		local iconH = (specDataText.Texture and specDataText.Texture:GetHeight()) or 12
		local totalH = math_max(textH, iconH)
		specDataText:SetSize(math_max(totalW, 56), totalH)
		if specDataText.mover then
			specDataText.mover:SetWidth(math_max(totalW, 56))
			specDataText.mover:SetHeight(totalH)
		end
	end)

	specDataText.mover = K.Mover(specDataText, "SpecDT", "SpecDT", { "LEFT", UIParent, "LEFT", 0, -210 }, 56, 12)
end
