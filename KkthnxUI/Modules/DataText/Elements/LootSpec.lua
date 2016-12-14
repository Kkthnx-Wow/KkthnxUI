local K, C, L = unpack(select(2, ...))

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

--Lua functions
local select = select
local format, join = string.format, string.join

--WoW API / Variables
local EasyMenu = EasyMenu
local GetActiveSpecGroup = GetActiveSpecGroup
local GetLootSpecialization = GetLootSpecialization
local GetNumSpecGroups = GetNumSpecGroups
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetSpecializationInfoByID = GetSpecializationInfoByID
local HideUIPanel = HideUIPanel
local IsShiftKeyDown = IsShiftKeyDown
local SetLootSpecialization = SetLootSpecialization
local SetSpecialization = SetSpecialization
local ShowUIPanel = ShowUIPanel
local LOOT = LOOT
local SELECT_LOOT_SPECIALIZATION = SELECT_LOOT_SPECIALIZATION
local LOOT_SPECIALIZATION_DEFAULT = LOOT_SPECIALIZATION_DEFAULT

local displayString = ""
local activeString = join("", "|cff00FF00" , ACTIVE_PETS, "|r")
local inactiveString = join("", "|cffFF0000", FACTION_INACTIVE, "|r")
local menuFrame = CreateFrame("Frame", "KkthnxUILootSpecializationDatatextClickMenu", UIParent, "Lib_UIDropDownMenuTemplate")

local menuList = {
	{text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true},
	{notCheckable = true, func = function() SetLootSpecialization(0) end},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true}
}
local specList = {
	{text = SPECIALIZATION, isTitle = true, notCheckable = true},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true}
}

local function Update(self)
	local specIndex = GetSpecialization()
	if not specIndex then
		self.Text:SetText("N/A")
		return
	end

	active = GetActiveSpecGroup()

	local talent, loot = "", ""
	local i = GetSpecialization(false, false, active)
	if i then
		i = select(4, GetSpecializationInfo(i))
		if(i) then
			talent = format("|T%s:14:14:0:0:64:64:4:60:4:60|t", i)
		end
	end

	local specialization = GetLootSpecialization()
	if specialization == 0 then
		local specIndex = GetSpecialization()

		if specIndex then
			local _, _, _, texture = GetSpecializationInfo(specIndex)
			if texture then
				loot = format("|T%s:14:14:0:0:64:64:4:60:4:60|t", texture)
			else
				loot = "N/A"
			end
		else
			loot = "N/A"
		end
	else
		local _, _, _, texture = GetSpecializationInfoByID(specialization)
		if texture then
			loot = format("|T%s:14:14:0:0:64:64:4:60:4:60|t", texture)
		else
			loot = "N/A"
		end
	end

	self.Text:SetFormattedText("%s: %s %s: %s", L.DataText.LootSpecSpec, talent, LOOT, loot) --Needs local
end

local OnEnter = function(self)
	if (InCombatLockdown()) then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()

	for i = 1, GetNumSpecGroups() do
		if GetSpecialization(false, false, i) then
			GameTooltip:AddLine(join(" ", format(displayString, select(2, GetSpecializationInfo(GetSpecialization(false, false, i)))), (i == active and activeString or inactiveString)),1,1,1)
		end
	end

	GameTooltip:AddLine(" ")
	local specialization = GetLootSpecialization()
	if specialization == 0 then
		local specIndex = GetSpecialization()

		if specIndex then
			local _, name = GetSpecializationInfo(specIndex)
			GameTooltip:AddLine(format("|cffFFFFFF%s:|r %s", SELECT_LOOT_SPECIALIZATION, format(LOOT_SPECIALIZATION_DEFAULT, name)))
		end
	else
		local specID, name = GetSpecializationInfoByID(specialization)
		if specID then
			GameTooltip:AddLine(format("|cffFFFFFF%s:|r %s", SELECT_LOOT_SPECIALIZATION, name))
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.DataText.LootSpecTalent)
	GameTooltip:AddLine(L.DataText.LootSpecShow)
	GameTooltip:AddLine(L.DataText.LootSpecChange)

	GameTooltip:Show()
end

local OnMouseDown = function(self, button)
	local specIndex = GetSpecialization()
	if not specIndex then return end

	if button == "LeftButton" then
		GameTooltip:Hide()
		if not PlayerTalentFrame then
			LoadAddOn("Blizzard_TalentUI")
		end
		if IsShiftKeyDown() then
			if not PlayerTalentFrame:IsShown() then
				ShowUIPanel(PlayerTalentFrame)
			else
				HideUIPanel(PlayerTalentFrame)
			end
		else
			for index = 1, 4 do
				local id, name, _, texture = GetSpecializationInfo(index)
				if (id) then
					specList[index + 1].text = format("|T%s:14:14:0:0:64:64:4:60:4:60|t  %s", texture, name)
					specList[index + 1].func = function()
					if index and index == specIndex then
					UIErrorsFrame:AddMessage(L.ConfigButton.SpecError, 1.0, 0.0, 0.0, 53, 5)
					return
					end
					SetSpecialization(index) end
				else
					specList[index + 1] = nil
				end
			end
			Lib_EasyMenu(specList, menuFrame, "cursor", -15, -7, "MENU", 2)
		end
	else
		GameTooltip:Hide()
		local _, specName = GetSpecializationInfo(specIndex)
		menuList[2].text = format(LOOT_SPECIALIZATION_DEFAULT, specName)

		for index = 1, 4 do
			local id, name = GetSpecializationInfo(index)
			if (id) then
				menuList[index + 2].text = name
				menuList[index + 2].func = function() SetLootSpecialization(id) end
			else
				menuList[index + 2] = nil
			end
		end

		Lib_EasyMenu(menuList, menuFrame, "cursor", -15, -7, "MENU", 2)
	end
end

local Enable = function(self)
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CHARACTER_POINTS_CHANGED")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")

	self:SetScript("OnEvent", Update)
	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:Update()
end

local Disable = function(self)
	self:UnregisterAllEvents()

	self:SetScript("OnEvent", nil)
	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)

	self.Text:SetText("")
end

DataText:Register("LootSpec", Enable, Disable, Update)