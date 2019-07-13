local K, C = unpack(select(2, ...))
local Module = K:NewModule("SlotItemLevel", "AceEvent-3.0")

local _G = _G
local pairs = pairs
local unpack = unpack

local UnitGUID = _G.UnitGUID
local IsAddOnLoaded = _G.IsAddOnLoaded

local InspectItems = {
	"HeadSlot",
	"NeckSlot",
	"ShoulderSlot",
	"",
	"ChestSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"WristSlot",
	"HandsSlot",
	"Finger0Slot",
	"Finger1Slot",
	"Trinket0Slot",
	"Trinket1Slot",
	"BackSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
}

function Module:CreateInspectTexture(slot, x, y)
	local texture = slot:CreateTexture()
	texture:SetPoint("BOTTOM", slot, x, y)
	texture:SetTexCoord(unpack(K.TexCoords))
	texture:SetSize(14, 14)

	local backdrop = CreateFrame('Frame', nil, slot)
	backdrop:CreateBorder()
	backdrop:SetOutside(texture)
	backdrop:Hide()

	return texture, backdrop
end

function Module:GetInspectPoints(id)
    if not id then
        return
    end

	if id <= 5 or (id == 9 or id == 15) then
		return 34, 3, 18, "BOTTOMLEFT" -- Left side
	elseif (id >= 6 and id <= 8) or (id >= 10 and id <= 14) then
		return -34, 3, 18, "BOTTOMRIGHT" -- Right side
	else
		return 0, 40, 60, "BOTTOM"
	end
end

function Module:UpdateInspectInfo(_, arg1)
	Module:UpdatePageInfo(_G.InspectFrame, "Inspect", arg1)
end

function Module:UpdateCharacterInfo(event)
	if not C["Misc"].CharacterInfo then
		return
	end

	Module:UpdatePageInfo(_G.CharacterFrame, "Character", nil, event)
end

function Module:UpdateCharacterItemLevel()
	Module:UpdateAverageString(_G.CharacterFrame, "Character")
end

function Module:ClearPageInfo(frame, which)
    if not (frame and frame.ItemLevelText) then
        return
    end
    frame.ItemLevelText:SetText("")

	for i = 1, 17 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText("")
            inspectItem.iLvlText:SetText("")

			for y = 1, 10 do
				inspectItem["textureSlot"..y]:SetTexture()
			end
		end
	end
end

function Module:ToggleItemLevelInfo(setupCharacterPage)
	if setupCharacterPage then
		Module:CreateSlotStrings(_G.CharacterFrame, "Character")
	end

	if C["Misc"].CharacterInfo then
		Module:RegisterEvent("PLAYER_EQUIPMENT_CHANGED", "UpdateCharacterInfo")
		Module:RegisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE", "UpdateCharacterItemLevel")
		_G.CharacterStatsPane.ItemLevelFrame.Value:Hide()

		if not _G.CharacterFrame.CharacterInfoHooked then
			_G.CharacterFrame:HookScript("OnShow", Module.UpdateCharacterInfo)
			_G.CharacterFrame.CharacterInfoHooked = true
		end

		if not setupCharacterPage then
			Module:UpdateCharacterInfo()
		end
	else
		Module:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
		Module:UnregisterEvent("PLAYER_AVG_ITEM_LEVEL_UPDATE")
		_G.CharacterStatsPane.ItemLevelFrame.Value:Show()
		Module:ClearPageInfo(_G.CharacterFrame, "Character")
	end

	if C["Misc"].InspectInfo then
		Module:RegisterEvent("INSPECT_READY", "UpdateInspectInfo")
	else
		Module:UnregisterEvent("INSPECT_READY")
		Module:ClearPageInfo(_G.InspectFrame, "Inspect")
	end
end

function Module:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, gems, essences, enchantColors, itemLevelColors)
	iLevelDB[i] = iLvl

	inspectItem.enchantText:SetText(enchant)
	if enchantColors then
		inspectItem.enchantText:SetTextColor(unpack(enchantColors))
	end

	inspectItem.iLvlText:SetText(iLvl)
	if itemLevelColors then
		inspectItem.iLvlText:SetTextColor(unpack(itemLevelColors))
	end

	for x = 1, 10 do
		local texture = inspectItem["textureSlot"..x]
		local backdrop = inspectItem["textureSlotBackdrop"..x]

		if gems and next(gems) then
			local index, gem = next(gems)
			texture:SetTexture(gem)
			backdrop:SetBackdropBorderColor()
			backdrop:Show()
			gems[index] = nil
		elseif essences and next(essences) then
			local index, essence = next(essences)

			local r, g, b
			if essence[2] == "tooltip-heartofazerothessence-major" then
				r, g, b = 0.8, 0.7, 0
			else -- "tooltip-heartofazerothessence-minor"
				r, g, b = 0.4, 0.4, 0.4
			end

			local selected = essence[1]
			texture:SetTexture(selected)
			backdrop:SetBackdropBorderColor(r, g, b)
			backdrop:Show()

			if selected then
				backdrop:SetBackdropColor(0, 0, 0, 0)
			else
				backdrop:SetBackdropColor(unpack(C["Media"].BackdropColor))
			end

			essences[index] = nil
		else
			texture:SetTexture()
			backdrop:Hide()
		end
	end
end

function Module:UpdateAverageString(frame, which, iLevelDB)
	local isCharPage = which == "Character"
	local AvgItemLevel = (isCharPage and K.GetPlayerItemLevel()) or K.CalculateAverageItemLevel(iLevelDB, frame.unit)
	if AvgItemLevel then
		if isCharPage then
			frame.ItemLevelText:SetText(AvgItemLevel)
			frame.ItemLevelText:SetTextColor(_G.CharacterStatsPane.ItemLevelFrame.Value:GetTextColor())
		else
			frame.ItemLevelText:SetFormattedText(_G.STAT_AVERAGE_ITEM_LEVEL..": %.2f", AvgItemLevel)
		end
	else
        frame.ItemLevelText:SetText("")
	end
end

function Module:TryGearAgain(frame, which, i, deepScan, iLevelDB, inspectItem)
	K.Delay(0.05, function()
        if which == "Inspect" and (not frame or not frame.unit) then
            return
        end

		local unit = (which == "Character" and "player") or frame.unit
		local iLvl, enchant, gems, essences, enchantColors, itemLevelColors = K.GetGearSlotInfo(unit, i, deepScan)
        if iLvl == "tooSoon" then
            return
        end

		Module:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, gems, essences, enchantColors, itemLevelColors)
	end)
end

function Module:UpdatePageInfo(frame, which, guid, event)
    if not (which and frame and frame.ItemLevelText) then
        return
    end

	if which == "Inspect" and (not frame or not frame.unit or (guid and frame:IsShown() and UnitGUID(frame.unit) ~= guid)) then
        return
    end

	local iLevelDB = {}
	local waitForItems
	for i = 1, 17 do
		if i ~= 4 then
			local inspectItem = _G[which..InspectItems[i]]
			inspectItem.enchantText:SetText("")
			inspectItem.iLvlText:SetText("")

			local unit = (which == "Character" and "player") or frame.unit
			local iLvl, enchant, gems, essences, enchantColors, itemLevelColors = K.GetGearSlotInfo(unit, i, true)
			if iLvl == "tooSoon" then
				if not waitForItems then waitForItems = true end
				Module:TryGearAgain(frame, which, i, true, iLevelDB, inspectItem)
			else
				Module:UpdatePageStrings(i, iLevelDB, inspectItem, iLvl, enchant, gems, essences, enchantColors, itemLevelColors)
			end
		end
	end

	if event and event == "PLAYER_EQUIPMENT_CHANGED" then
		return
	end

	if waitForItems then
		K.Delay(0.10, Module.UpdateAverageString, Module, frame, which, iLevelDB)
	else
		Module:UpdateAverageString(frame, which, iLevelDB)
	end
end

function Module:CreateSlotStrings(frame, which)
    if not (frame and which) then
        return
    end

	if which == "Inspect" then
		frame.ItemLevelText = _G.InspectPaperDollItemsFrame:CreateFontString(nil, "ARTWORK")
		frame.ItemLevelText:SetPoint("BOTTOMRIGHT", -11, 8)
	else
		frame.ItemLevelText = _G.CharacterStatsPane.ItemLevelFrame:CreateFontString(nil, "ARTWORK")
		frame.ItemLevelText:SetPoint("BOTTOM", _G.CharacterStatsPane.ItemLevelFrame.Value, "BOTTOM", 0, -1)
	end
	frame.ItemLevelText:FontTemplate(nil, which == "Inspect" and 12 or 20)

	for i, s in pairs(InspectItems) do
		if i ~= 4 then
			local slot = _G[which..s]
			local x, y, z, justify = Module:GetInspectPoints(i)
			slot.iLvlText = slot:CreateFontString(nil, "OVERLAY")
			slot.iLvlText:FontTemplate(nil, 12)
			slot.iLvlText:SetPoint("BOTTOM", slot, x, y)

			slot.enchantText = slot:CreateFontString(nil, "OVERLAY")
			slot.enchantText:FontTemplate(nil, 11)

			if i == 16 or i == 17 then
				slot.enchantText:SetPoint(i == 16 and "BOTTOMRIGHT" or "BOTTOMLEFT", slot, i==16 and -40 or 40, 3)
			else
				slot.enchantText:SetPoint(justify, slot, x + (justify == "BOTTOMLEFT" and 5 or -5), z)
			end

			for u = 1, 10 do
				local offset = 8 + (u * 16)
				local newX = ((justify == "BOTTOMLEFT" or i == 17) and x + offset) or x - offset
				slot["textureSlot"..u], slot["textureSlotBackdrop"..u] = Module:CreateInspectTexture(slot, newX, --[[newY or]] y)
			end
		end
	end
end

function Module:SetupInspectPageInfo()
	Module:CreateSlotStrings(_G.InspectFrame, "Inspect")
end

function Module:HideInspectControls()
	_G.InspectModelFrameControlFrame:HookScript("OnShow", _G.InspectModelFrameControlFrame.Hide)
end

function Module:ADDON_LOADED(_, addon)
	if addon == "Blizzard_InspectUI" then
		Module:SetupInspectPageInfo()
		Module:HideInspectControls()
		self:UnregisterEvent("ADDON_LOADED")
	end
end

function Module:OnInitialize()
	self:ToggleItemLevelInfo(true)

	if IsAddOnLoaded("Blizzard_InspectUI") then
		Module:SetupInspectPageInfo()
		Module:HideInspectControls()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end