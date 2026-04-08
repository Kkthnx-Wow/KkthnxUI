--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays durability information for equipped items on the character frame.
-- - Design: Integrates with the PaperDollFrame and uses HelpTips for low durability warnings.
-- - Events: UPDATE_INVENTORY_DURABILITY, PLAYER_ENTERING_WORLD, PLAYER_REGEN_ENABLED
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local C_TooltipInfo_GetInventoryItem = _G.C_TooltipInfo.GetInventoryItem
local CreateFrame = _G.CreateFrame
local DURABILITY = _G.DURABILITY
local GetAverageItemLevel = _G.GetAverageItemLevel
local GetInventoryItemDurability = _G.GetInventoryItemDurability
local GetInventoryItemLink = _G.GetInventoryItemLink
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local HelpTip = _G.HelpTip
local InCombatLockdown = _G.InCombatLockdown
local PaperDollFrame = _G.PaperDollFrame
local UIParent = _G.UIParent
local math_floor = math.floor
local pairs = pairs
local string_format = string.format
local string_gsub = string.gsub
local table_sort = table.sort
local unpack = unpack

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local durabilityDataText
local repairCostString = string_gsub(_G.REPAIR_COST, _G.HEADER_COLON, ":")
local LOW_DURABILITY_CAP = 0.25

local localSlots = {
	[1] = { 1, _G.INVTYPE_HEAD, 1000 },
	[2] = { 3, _G.INVTYPE_SHOULDER, 1000 },
	[3] = { 5, _G.INVTYPE_CHEST, 1000 },
	[4] = { 6, _G.INVTYPE_WAIST, 1000 },
	[5] = { 9, _G.INVTYPE_WRIST, 1000 },
	[6] = { 10, _G.INVTYPE_HAND, 1000 },
	[7] = { 7, _G.INVTYPE_LEGS, 1000 },
	[8] = { 8, _G.INVTYPE_FEET, 1000 },
	[9] = { 16, _G.INVTYPE_WEAPONMAINHAND, 1000 },
	[10] = { 17, _G.INVTYPE_WEAPONOFFHAND, 1000 },
}

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function hideAlertWhileCombat()
	-- REASON: Suppress durability alerts during combat to prevent UI clutter and potential layout issues.
	if InCombatLockdown() then
		durabilityDataText:RegisterEvent("PLAYER_REGEN_ENABLED")
		durabilityDataText:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
	end
end

local lowDurabilityInfo = {
	text = L["DurabilityHelpTip"],
	buttonStyle = HelpTip.ButtonStyle.Okay,
	targetPoint = HelpTip.Point.TopEdgeCenter,
	onAcknowledgeCallback = hideAlertWhileCombat,
	offsetY = 10,
}

local function sortSlots(a, b)
	-- REASON: Sorts slots by durability percentage (lowest first) for the primary display and tooltip.
	if a and b then
		return (a[3] == b[3] and a[1] < b[1]) or (a[3] < b[3])
	end
end

local function updateAllSlots()
	-- REASON: Scans all relevant equipment slots and updates their durability and icon data in the local cache.
	local numSlots = 0
	for i = 1, #localSlots do
		localSlots[i][3] = 1000
		local index = localSlots[i][1]
		if GetInventoryItemLink("player", index) then
			local current, max = GetInventoryItemDurability(index)
			if current then
				localSlots[i][3] = current / max
				numSlots = numSlots + 1
			end
			local iconTexture = GetInventoryItemTexture("player", index) or 134400
			localSlots[i][4] = "|T" .. iconTexture .. ":13:15:0:0:50:50:4:46:4:46|t "
		end
	end
	table_sort(localSlots, sortSlots)

	return numSlots
end

local function hasLowDurability()
	-- REASON: Checks if any equipped item's durability has fallen below the defined threshold.
	for i = 1, 10 do
		if localSlots[i][3] < LOW_DURABILITY_CAP then
			return true
		end
	end
	return false
end

local function getDurabilityColor(cur, max)
	-- REASON: Generates a color gradient (red to green) based on the current durability percentage.
	local r, g, b = K.RGBColorGradient(cur, max, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	return r, g, b
end

local function onEvent(self, event)
	-- REASON: Manages durability updates and triggers HelpTips when equipment is damaged.
	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent(event)
	end

	local numSlots = updateAllSlots()
	local isLow = hasLowDurability()

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent(event)
		self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	else
		if numSlots > 0 then
			local currentDurabilityPercent = math_floor(localSlots[1][3] * 100)
			local r, g, b = getDurabilityColor(currentDurabilityPercent, 100)
			local yellowColor = "|cFFF0C500"
			-- REASON: Formats the DataText string with the lowest durability item's status.
			self.Text:SetFormattedText("%s%%|r %s", K.RGBToHex(r, g, b) .. currentDurabilityPercent, yellowColor .. DURABILITY)
		else
			self.Text:SetText(DURABILITY .. ": " .. K.MyClassColor .. _G.NONE)
		end
	end

	if isLow then
		HelpTip:Show(self, lowDurabilityInfo)
	else
		HelpTip:Hide(self, L["DurabilityHelpTip"])
	end
end

local function onEnter(self)
	-- REASON: Populates the durability tooltip with per-slot breakdowns and total repair costs.
	local totalItemLevel, equippedItemLevel = GetAverageItemLevel()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 0, 0)
	GameTooltip:AddDoubleLine(DURABILITY, string_format("%s: %d/%d", _G.STAT_AVERAGE_ITEM_LEVEL, equippedItemLevel, totalItemLevel), 0.4, 0.6, 1, 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")

	local totalCost = 0
	for i = 1, 10 do
		if localSlots[i][3] ~= 1000 then
			local slot = localSlots[i][1]
			local curPercent = math_floor(localSlots[i][3] * 100)
			local slotIcon = localSlots[i][4]
			GameTooltip:AddDoubleLine(slotIcon .. localSlots[i][2], curPercent .. "%", 1, 1, 1, getDurabilityColor(curPercent, 100))

			local data = C_TooltipInfo_GetInventoryItem("player", slot)
			if data then
				local argVal = data.args and data.args[7]
				if argVal and argVal.field == "repairCost" then
					totalCost = totalCost + argVal.intVal
				end
			end
		end
	end

	if totalCost > 0 then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(repairCostString, K.FormatMoney(totalCost), 0.4, 0.6, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function onLeave()
	GameTooltip:Hide()
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateDurabilityDataText()
	-- REASON: Entry point for durability DataText; attaches a stylized button to the Character Frame.
	if not C["Misc"].SlotDurability then
		return
	end

	durabilityDataText = CreateFrame("Button", nil, UIParent, "PanelTabButtonTemplate")
	durabilityDataText:SetPoint("TOP", PaperDollFrame, "BOTTOM", 214, 3)
	durabilityDataText:SetFrameLevel(PaperDollFrame:GetFrameLevel() + 2)
	durabilityDataText:SetParent(PaperDollFrame)
	durabilityDataText:Disable()

	-- REASON: Clean up Blizzard's default tab textures for a custom look.
	durabilityDataText.LeftActive:Hide()
	durabilityDataText.MiddleActive:Hide()
	durabilityDataText.RightActive:Hide()

	local eventList = {
		"UPDATE_INVENTORY_DURABILITY",
		"PLAYER_ENTERING_WORLD",
	}

	for _, event in pairs(eventList) do
		durabilityDataText:RegisterEvent(event)
	end

	durabilityDataText:SetScript("OnEvent", onEvent)
	durabilityDataText:SetScript("OnEnter", onEnter)
	durabilityDataText:SetScript("OnLeave", onLeave)
end
