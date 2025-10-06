local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("DataText")

local format, wipe, select, next = string.format, K.ClearTable, select, next
local SPECIALIZATION, TALENTS_BUTTON, MAX_TALENT_TIERS = SPECIALIZATION, TALENTS_BUTTON, MAX_TALENT_TIERS
local PVP_TALENTS, LOOT_SPECIALIZATION_DEFAULT = PVP_TALENTS, LOOT_SPECIALIZATION_DEFAULT
local GetSpecialization, GetSpecializationInfo, GetLootSpecialization, GetSpecializationInfoByID = GetSpecialization, GetSpecializationInfo, GetLootSpecialization, GetSpecializationInfoByID
local GetTalentInfo, GetPvpTalentInfoByID, SetLootSpecialization, SetSpecialization = GetTalentInfo, GetPvpTalentInfoByID, SetLootSpecialization, SetSpecialization
local C_SpecializationInfo_GetAllSelectedPvpTalentIDs = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
local C_SpecializationInfo_CanPlayerUsePVPTalentUI = C_SpecializationInfo.CanPlayerUsePVPTalentUI
local STARTER_BUILD = Constants.TraitConsts.STARTER_BUILD_TRAIT_CONFIG_ID

local function addIcon(texture)
	texture = texture and "|T" .. texture .. ":12:16:0:0:50:50:4:46:4:46|t" or ""
	return texture
end

local currentSpecIndex, currentLootIndex, newMenu, numSpecs, numLocal

local eventList = {
	"PLAYER_ENTERING_WORLD",
	"ACTIVE_PLAYER_SPECIALIZATION_CHANGED",
	"PLAYER_LOOT_SPEC_UPDATED",
}

local function OnEvent()
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
		SpecDataText.Text:SetText(CLUB_FINDER_SPEC .. ": " .. icon)
	else
		SpecDataText.Text:SetText(CLUB_FINDER_SPEC .. ": " .. K.MyClassColor .. NONE)
	end
end

local pvpTalents
local pvpIconTexture = C_CurrencyInfo.GetCurrencyInfo(1792).iconFileID

local function OnEnter()
	if not currentSpecIndex or currentSpecIndex == 5 then
		return
	end

	GameTooltip:SetOwner(SpecDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(SpecDataText))
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TALENTS_BUTTON, 0, 0.6, 1)
	GameTooltip:AddLine(" ")

	local specID, specName, _, specIcon = GetSpecializationInfo(currentSpecIndex)
	GameTooltip:AddLine(addIcon(specIcon) .. " " .. specName, 0.6, 0.8, 1)

	for t = 1, MAX_TALENT_TIERS do
		for c = 1, 3 do
			local _, name, icon, selected = GetTalentInfo(t, c, 1)
			if selected then
				GameTooltip:AddLine(addIcon(icon) .. " " .. name, 1, 1, 1)
			end
		end
	end

	local configID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
	local info = configID and C_Traits.GetConfigInfo(configID)
	if info and info.name then
		GameTooltip:AddLine("   (" .. info.name .. ")", 1, 1, 1)
	end

	if C_SpecializationInfo_CanPlayerUsePVPTalentUI() then
		pvpTalents = C_SpecializationInfo_GetAllSelectedPvpTalentIDs()

		if #pvpTalents > 0 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(addIcon(pvpIconTexture) .. " " .. PVP_TALENTS, 0.6, 0.8, 1)
			for _, talentID in next, pvpTalents do
				local _, name, icon, _, _, _, unlocked = GetPvpTalentInfoByID(talentID)
				if name and unlocked then
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

local OnLeave = K.HideTooltip

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
	local mult = 3 + numSpecs
	newMenu[numLocal - mult].text = format(LOOT_SPECIALIZATION_DEFAULT, (select(2, GetSpecializationInfo(currentSpecIndex))) or NONE)
end

local function selectCurrentConfig(_, configID, specID)
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
		return
	end
	if configID == STARTER_BUILD then
		C_ClassTalents.SetStarterBuildActive(true)
	else
		C_ClassTalents.LoadConfig(configID, true)
		C_ClassTalents.SetStarterBuildActive(false)
	end
	C_ClassTalents.UpdateLastSelectedSavedConfigID(specID or GetSpecializationInfo(currentSpecIndex), configID)
end

local function checkCurrentConfig(self)
	return C_ClassTalents.GetLastSelectedSavedConfigID(self.arg2) == self.arg1
end

local function refreshAllTraits()
	local numConfig = numLocal or 0
	local specID = GetSpecializationInfo(currentSpecIndex)
	local configIDs = specID and C_ClassTalents.GetConfigIDsBySpecID(specID)
	if configIDs then
		for i = 1, #configIDs do
			local configID = configIDs[i]
			if configID then
				local info = C_Traits.GetConfigInfo(configID)
				numConfig = numConfig + 1
				if not newMenu[numConfig] then
					newMenu[numConfig] = {}
				end
				newMenu[numConfig].text = info.name
				newMenu[numConfig].arg1 = configID
				newMenu[numConfig].arg2 = specID
				newMenu[numConfig].func = selectCurrentConfig
				newMenu[numConfig].checked = checkCurrentConfig
			end
		end
	end

	for i = numConfig + 1, #newMenu do
		if newMenu[i] then
			newMenu[i].text = nil
		end
	end
end

local seperatorMenu = {
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

local function BuildSpecMenu()
	if newMenu then
		return
	end

	newMenu = {
		{ text = SPECIALIZATION, isTitle = true, notCheckable = true },
		seperatorMenu,
		{ text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true },
		{ text = "", arg1 = 0, func = selectLootSpec, checked = checkLootSpec },
	}

	for i = 1, 4 do
		local id, name = GetSpecializationInfo(i)
		if id then
			numSpecs = (numSpecs or 0) + 1
			tinsert(newMenu, i + 1, { text = name, arg1 = i, func = selectSpec, checked = checkSpec })
			tinsert(newMenu, { text = name, arg1 = id, func = selectLootSpec, checked = checkLootSpec })
		end
	end

	tinsert(newMenu, seperatorMenu)
	tinsert(newMenu, { text = C_Spell.GetSpellName(384255), isTitle = true, notCheckable = true })
	tinsert(newMenu, {
		text = BLUE_FONT_COLOR:WrapTextInColorCode(TALENT_FRAME_DROP_DOWN_STARTER_BUILD),
		func = selectCurrentConfig,
		arg1 = STARTER_BUILD,
		checked = function()
			return C_ClassTalents.GetStarterBuildActive()
		end,
	})

	numLocal = #newMenu

	refreshDefaultLootSpec()
	K:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", refreshDefaultLootSpec)

	refreshAllTraits()
	K:RegisterEvent("TRAIT_CONFIG_DELETED", refreshAllTraits)
	K:RegisterEvent("TRAIT_CONFIG_UPDATED", refreshAllTraits)
	K:RegisterEvent("ACTIVE_PLAYER_SPECIALIZATION_CHANGED", refreshAllTraits)
end

local function OnMouseUp(self, btn)
	if not currentSpecIndex or currentSpecIndex == 5 then
		return
	end

	if btn == "LeftButton" then
		PlayerSpellsUtil.ToggleClassTalentOrSpecFrame()
	else
		BuildSpecMenu()
		K.LibEasyMenu.Create(newMenu, K.EasyMenu, self, -80, 100, "MENU", 1)
		GameTooltip:Hide()
	end
end

function Module:CreateSpecDataText()
	if not C["DataText"].Spec then
		return
	end

	SpecDataText = CreateFrame("Frame", nil, UIParent)

	SpecDataText.Text = K.CreateFontString(SpecDataText, 12)
	SpecDataText.Text:ClearAllPoints()
	SpecDataText.Text:SetPoint("LEFT", SpecDataText, "LEFT", 24, 0)

	SpecDataText.Texture = SpecDataText:CreateTexture(nil, "ARTWORK")
	SpecDataText.Texture:SetPoint("LEFT", SpecDataText, "LEFT", 0, 2)
	SpecDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\talents.blp")
	SpecDataText.Texture:SetSize(24, 24)
	SpecDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	local function _OnEvent(...)
		OnEvent(...)
	end

	for _, event in pairs(eventList) do
		SpecDataText:RegisterEvent(event)
	end

	SpecDataText:SetScript("OnEvent", _OnEvent)
	SpecDataText:SetScript("OnEnter", OnEnter)
	SpecDataText:SetScript("OnLeave", OnLeave)
	SpecDataText:SetScript("OnMouseUp", OnMouseUp)

	-- Keep frame and mover size in sync with icon + text on updates
	SpecDataText:HookScript("OnEvent", function()
		local textW = SpecDataText.Text:GetStringWidth() or 0
		local iconW = (SpecDataText.Texture and SpecDataText.Texture:GetWidth()) or 0
		local totalW = textW + iconW
		local textH = SpecDataText.Text:GetLineHeight() or 12
		local iconH = (SpecDataText.Texture and SpecDataText.Texture:GetHeight()) or 12
		local totalH = math.max(textH, iconH)
		SpecDataText:SetSize(math.max(totalW, 56), totalH)
		if SpecDataText.mover then
			SpecDataText.mover:SetWidth(math.max(totalW, 56))
			SpecDataText.mover:SetHeight(totalH)
		end
	end)

	-- Make the whole block (icon + text) movable
	SpecDataText.mover = K.Mover(SpecDataText, "SpecDT", "SpecDT", { "LEFT", UIParent, "LEFT", 0, -210 }, 56, 12)
end
