local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local string_format = _G.string.format

local ENCHANT_CONDITION_AND = _G.ENCHANT_CONDITION_AND
local FEATURE_BECOMES_AVAILABLE_AT_LEVEL = _G.FEATURE_BECOMES_AVAILABLE_AT_LEVEL
local GetLootSpecialization = _G.GetLootSpecialization
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local IsShiftKeyDown = _G.IsShiftKeyDown
local LOOT = _G.LOOT
local NO = _G.NO
local SELECT_LOOT_SPECIALIZATION = _G.SELECT_LOOT_SPECIALIZATION
local SHOW_SPEC_LEVEL = _G.SHOW_SPEC_LEVEL
local SPECIALIZATION = _G.SPECIALIZATION
local SetLootSpecialization = _G.SetLootSpecialization

_G.CreateFrame("Frame", "KKUI_TalentDropDownMenu", _G.UIParent, "UIDropDownMenuTemplate")

local lootSpecName, specName
local specList = {
	{text = SPECIALIZATION, isTitle = true, notCheckable = true},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true}
}

local lootList = {
	{text = SELECT_LOOT_SPECIALIZATION, isTitle = true, notCheckable = true},
	{notCheckable = true, func = function()
			SetLootSpecialization(0)
	end},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true},
	{notCheckable = true}
}

function Module:OnTalentEnter()
	Module.isHovered = true
	if K.Level >= SHOW_SPEC_LEVEL then
		GameTooltip:SetOwner(Module.TalentFrame, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(Module.TalentFrame))
		GameTooltip:ClearLines()

        GameTooltip:AddLine("|cffffffff".."Specializations & Talents".."|r".." (N)")
        GameTooltip:AddLine(" ")
		GameTooltip:AddLine(K.InfoColor..SPECIALIZATION.." "..ENCHANT_CONDITION_AND..LOOT)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(SPECIALIZATION, K.InfoColor..specName)
		GameTooltip:AddDoubleLine(LOOT, K.InfoColor..lootSpecName)

		GameTooltip:Show()
    else
        GameTooltip:SetOwner(Module.TalentFrame, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(Module.TalentFrame))
		GameTooltip:ClearLines()

        GameTooltip:AddLine("|cffffffff".."Specializations & Talents".."|r".." (N)")

        GameTooltip:Show()
    end
end

function Module:OnTalentLeave()
	GameTooltip:Hide()
	Module.isHovered = false
end

function Module:OnTalentEvent()
    if K.Level < SHOW_SPEC_LEVEL then
		return
	end

	local lootSpec = GetLootSpecialization()
	local spec = GetSpecialization()

	lootSpecName = lootSpec and select(2, GetSpecializationInfoByID(lootSpec)) or NO
	specName = spec and select(2, GetSpecializationInfo(spec)) or NO

	if lootSpec == 0 then
		lootSpecName = "|cff55ff55"..specName.."|r"
	end

	if Module.isHovered then
		Module:OnTalentEnter()
	end
end

function Module:OnTalentMouseUp(b)
	if K.Level < SHOW_SPEC_LEVEL then
		K.Print("|cffffff00"..string_format(FEATURE_BECOMES_AVAILABLE_AT_LEVEL, SHOW_SPEC_LEVEL).."|r")
		return
	end

	if b == "LeftButton" then
		if not _G.PlayerTalentFrame then
			_G.LoadAddOn("Blizzard_TalentUI")
		end
		if IsShiftKeyDown() then
			_G.PlayerTalentFrame_Toggle()
		else
			for index = 1, 4 do
				local id, name, _, texture = GetSpecializationInfo(index)
				if id then
					if GetSpecializationInfo(GetSpecialization()) == id then
						name = "|cff55ff55"..name.."|r"
					end
					specList[index + 1].text = string_format("|T%s:".."14"..":".."14"..":0:0:64:64:5:59:5:59|t %s", texture, name)
					specList[index + 1].func = function()
						_G.SetSpecialization(index)
					end
				else
					specList[index + 1] = nil
				end
			end
			_G.EasyMenu(specList, _G["KKUI_TalentDropDownMenu"], self, 0, 130, "MENU")
		end
	elseif b == "RightButton" and GetSpecialization() then
		local lootSpec = GetLootSpecialization()
		local _, specName = GetSpecializationInfo(GetSpecialization())
		local specDefault = string_format(_G.LOOT_SPECIALIZATION_DEFAULT, specName)

		if lootSpec == 0 then
			specDefault = "|cff55ff55"..string_format(_G.LOOT_SPECIALIZATION_DEFAULT, specName).."|r"
		end

		lootList[2].text = specDefault
		for index = 1, 4 do
			local id, name, _, texture = GetSpecializationInfo(index)
			if id then
				if lootSpec == id then
					name = "|cff55ff55"..name.."|r"
				end
				lootList[index + 2].text = string_format("|T%s:".."14"..":".."14"..":0:0:64:64:5:59:5:59|t %s", texture, name)
				lootList[index + 2].func = function()
					SetLootSpecialization(id)
				end
			else
				lootList[index + 2] = nil
			end
		end
		_G.EasyMenu(lootList, _G["KKUI_TalentDropDownMenu"], self, 0, 130, "MENU")
	end
end

function Module:CreateTalentDataText()
	if not C["DataText"].Talents then
		return
	end

	if not _G["TalentMicroButton"] then
		return
	end

	Module.TalentFrame = _G.CreateFrame("Button", "KKUI_TalentDataText", _G.UIParent)
	Module.TalentFrame:SetAllPoints(_G["TalentMicroButton"])
	Module.TalentFrame:SetSize(_G["TalentMicroButton"]:GetWidth(), _G["TalentMicroButton"]:GetHeight())
	Module.TalentFrame:SetFrameLevel(_G["TalentMicroButton"]:GetFrameLevel() + 2)

	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.OnTalentEvent)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", Module.OnTalentEvent)
	K:RegisterEvent("PLAYER_LOOT_SPEC_UPDATED", Module.OnTalentEvent)
	K:RegisterEvent("CHARACTER_POINTS_CHANGED", Module.OnTalentEvent)
	K:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", Module.OnTalentEvent)

	Module.TalentFrame:SetScript("OnEvent", Module.OnTalentEvent)
	Module.TalentFrame:SetScript("OnMouseUp", Module.OnTalentMouseUp)
	Module.TalentFrame:SetScript("OnEnter", Module.OnTalentEnter)
	Module.TalentFrame:SetScript("OnLeave", Module.OnTalentLeave)
end