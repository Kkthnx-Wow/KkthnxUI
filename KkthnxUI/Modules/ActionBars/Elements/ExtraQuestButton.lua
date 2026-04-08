--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatic quest item button that mimics the extra action button.
-- - Design: Scans the quest log for distance-relevant items and provides a secure clickable interface.
-----------------------------------------------------------------------------]]

-- NOTE: ExtraQuestButton Modification by p3lim for KkthnxUI
local K, C = KkthnxUI[1], KkthnxUI[2]

-- ---------------------------------------------------------------------------
-- LOCALS & CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache globals and quest APIs to minimize overhead during the distance scan loop.
local next, type, sqrt, GetTime, format = next, type, sqrt, GetTime, format
local RegisterStateDriver, InCombatLockdown = RegisterStateDriver, InCombatLockdown
local C_Item_IsItemInRange, C_Item_ItemHasRange, HasExtraActionBar = C_Item.IsItemInRange, C_Item.ItemHasRange, HasExtraActionBar
local C_Item_GetItemCooldown, C_Item_GetItemCount, C_Item_GetItemIconByID, GetItemInfoFromHyperlink = C_Item.GetItemCooldown, C_Item.GetItemCount, C_Item.GetItemIconByID, GetItemInfoFromHyperlink
local GetBindingKey, GetBindingText = GetBindingKey, GetBindingText
local GetQuestLogSpecialItemInfo, QuestHasPOIInfo = GetQuestLogSpecialItemInfo, QuestHasPOIInfo
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_QuestLog_GetInfo = C_QuestLog.GetInfo
local C_QuestLog_IsOnMap = C_QuestLog.IsOnMap
local C_QuestLog_IsComplete = C_QuestLog.IsComplete
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local C_QuestLog_GetNumQuestWatches = C_QuestLog.GetNumQuestWatches
local C_QuestLog_GetDistanceSqToQuest = C_QuestLog.GetDistanceSqToQuest
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetNumWorldQuestWatches = C_QuestLog.GetNumWorldQuestWatches
local C_QuestLog_GetQuestIDForQuestWatchIndex = C_QuestLog.GetQuestIDForQuestWatchIndex
local C_QuestLog_GetQuestIDForWorldQuestWatchIndex = C_QuestLog.GetQuestIDForWorldQuestWatchIndex

-- NOTE: Tuning constants for quest item detection.
local MAX_DISTANCE_YARDS = 1e4
local onlyCurrentZone = true

-- ---------------------------------------------------------------------------
-- ATTRIBUTES & VISIBILITY
-- ---------------------------------------------------------------------------

-- REASON: Use SecureActionButtonTemplate to allow item usage during combat without taint.
local ExtraQuestButton = CreateFrame("Button", "KKUI_ExtraQuestButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate")
ExtraQuestButton:SetMovable(true)
ExtraQuestButton:RegisterEvent("PLAYER_LOGIN")
ExtraQuestButton:RegisterForClicks("AnyUp", "AnyDown")
ExtraQuestButton:Hide()

-- REASON: Visibility logic ensures the button is hidden during pet battles or when the
-- Blizzard Extra Action Bar is already active to prevent overlapping UI elements.
local visibilityState = "[extrabar][petbattle] hide; show"
local onAttributeChanged = [[
	if name == "item" then
		if value and not self:IsShown() and not HasExtraActionBar() then
			self:Show()
		elseif not value then
			self:Hide()
			self:ClearBindings()
		end
	elseif name == "state-visible" then
		if value == "show" then
			self:Show()
			self:CallMethod("Update")
		else
			self:Hide()
			self:ClearBindings()
		end
	end
	
	-- NOTE: Dynamically map the Extra Action Button bind to this button for seamless input.
	if self:IsShown() then
		self:ClearBindings()
		local key1, key2 = GetBindingKey("EXTRAACTIONBUTTON1")
		if key1 then
			self:SetBindingClick(1, key1, self, "LeftButton")
		end
		if key2 then
			self:SetBindingClick(2, key2, self, "LeftButton")
		end
	end
]]

-- ---------------------------------------------------------------------------
-- EVENT HANDLERS
-- ---------------------------------------------------------------------------

ExtraQuestButton:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, event, ...)
	else
		self:Update()
	end
end)

function ExtraQuestButton:BAG_UPDATE_COOLDOWN()
	if self:IsShown() and self.itemID then
		local start, duration = C_Item_GetItemCooldown(self.itemID)
		if duration > 0 then
			self.Cooldown:SetCooldown(start, duration)
			self.Cooldown:Show()
		else
			self.Cooldown:Hide()
		end
	end
end

function ExtraQuestButton:UpdateCount()
	if self:IsShown() and self.itemLink then
		local count = C_Item_GetItemCount(self.itemLink)
		self.Count:SetText(count and count > 1 and count or "")
	end
end

function ExtraQuestButton:BAG_UPDATE_DELAYED()
	self:Update()
	self:UpdateCount()
end

-- REASON: Securely updates the 'item' attribute for the button.
function ExtraQuestButton:UpdateAttributes()
	-- WARNING: Attributes cannot be changed in combat. We defer the update until combat ends.
	if InCombatLockdown() then
		if not self.itemID and self:IsShown() then
			self:SetAlpha(0)
		end
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	else
		self:SetAlpha(1)
	end

	if self.itemID then
		self:SetAttribute("item", "item:" .. self.itemID)
		self:BAG_UPDATE_COOLDOWN()
	else
		self:SetAttribute("item", nil)
	end
end

function ExtraQuestButton:PLAYER_REGEN_ENABLED(event)
	self:UpdateAttributes()
	self:UnregisterEvent(event)
end

function ExtraQuestButton:UPDATE_BINDINGS()
	if self:IsShown() then
		self:SetItem()
		self:SetAttribute("binding", GetTime())
	end
end

-- ---------------------------------------------------------------------------
-- BUTTON INITIALIZATION
-- ---------------------------------------------------------------------------

function ExtraQuestButton:PLAYER_LOGIN()
	RegisterStateDriver(self, "visible", visibilityState)
	self:SetAttribute("_onattributechanged", onAttributeChanged)
	self:SetAttribute("type", "item")

	self:SetSize(ExtraActionButton1:GetSize())
	self:SetScale(ExtraActionButton1:GetScale())
	self:SetScript("OnLeave", K.HideTooltip)
	self:SetClampedToScreen(true)
	self:SetToplevel(true)

	-- NOTE: Position the button on the Extra Bar mover or use a default if missing.
	if not self:GetPoint() then
		if _G.KKUI_ActionBarExtra then
			self:SetPoint("CENTER", _G.KKUI_ActionBarExtra)
		else
			K.Mover(self, "ExtraQuestButton", "Extrabar", { "BOTTOM", UIParent, "BOTTOM", 250, 100 })
		end
	end

	self.updateTimer = 0
	self.rangeTimer = 0

	local pushed = self:CreateTexture()
	pushed:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	pushed:SetDesaturated(true)
	pushed:SetVertexColor(246 / 255, 196 / 255, 66 / 255)
	pushed:SetPoint("TOPLEFT", self, "TOPLEFT", 0, -0)
	pushed:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -0, 0)
	pushed:SetBlendMode("ADD")
	self:SetPushedTexture(pushed)

	local Icon = self:CreateTexture("$parentIcon", "ARTWORK")
	Icon:SetAllPoints()
	Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	local bg = CreateFrame("Frame", nil, self, "BackdropTemplate")
	bg:SetAllPoints(Icon)
	bg:SetFrameLevel(self:GetFrameLevel())
	bg:CreateBorder()
	bg.KKUI_Border:SetVertexColor(1, 0.82, 0.2)

	self.HL = self:CreateTexture(nil, "HIGHLIGHT")
	self.HL:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
	self.HL:SetPoint("TOPLEFT", Icon, "TOPLEFT", 0, -0)
	self.HL:SetPoint("BOTTOMRIGHT", Icon, "BOTTOMRIGHT", -0, 0)
	self.HL:SetBlendMode("ADD")
	self.Icon = Icon

	local HotKey = self:CreateFontString("$parentHotKey", nil, "NumberFontNormal")
	HotKey:SetPoint("TOP", 0, -5)
	self.HotKey = HotKey

	local Count = self:CreateFontString("$parentCount", nil, "NumberFont_Shadow_Med")
	Count:SetPoint("BOTTOMRIGHT", -3, 3)
	self.Count = Count

	local Cooldown = CreateFrame("Cooldown", "$parentCooldown", self, "CooldownFrameTemplate")
	Cooldown:SetPoint("TOPLEFT", 1, -1)
	Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
	Cooldown:SetReverse(false)
	Cooldown:Hide()
	self.Cooldown = Cooldown

	local Artwork = self:CreateTexture("$parentArtwork", "OVERLAY")
	Artwork:SetPoint("BOTTOMLEFT", 2, 2)
	Artwork:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Inventory\\QuestIcon.tga")
	self.Artwork = Artwork

	self:RegisterEvent("UPDATE_BINDINGS")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN")
	self:RegisterEvent("BAG_UPDATE_DELAYED")
	self:RegisterEvent("QUEST_LOG_UPDATE")
	self:RegisterEvent("QUEST_POI_UPDATE")
	self:RegisterEvent("QUEST_WATCH_LIST_CHANGED")
	self:RegisterEvent("QUEST_ACCEPTED")
	self:RegisterEvent("ZONE_CHANGED")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
end

ExtraQuestButton:SetScript("OnEnter", function(self)
	if not self.itemLink then
		return
	end
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink(self.itemLink)
end)

-- ---------------------------------------------------------------------------
-- UPDATE CYCLE
-- ---------------------------------------------------------------------------

ExtraQuestButton:SetScript("OnUpdate", function(self, elapsed)
	-- REASON: Handles range indicator coloring (red if out of range).
	if self.updateRange then
		if not InCombatLockdown() and ((self.rangeTimer or 0) > TOOLTIP_UPDATE_TIME) then
			local HotKey = self.HotKey
			local Icon = self.Icon

			-- NOTE: C_Item.IsItemInRange() is reliably handled here with fallback coloring.
			local inRange = C_Item_IsItemInRange(self.itemLink, "target")
			if HotKey:GetText() == RANGE_INDICATOR then
				if inRange == false then
					HotKey:SetTextColor(1, 0.1, 0.1)
					HotKey:Show()
					Icon:SetVertexColor(1, 0.1, 0.1)
				elseif inRange then
					HotKey:SetTextColor(0.6, 0.6, 0.6)
					HotKey:Show()
					Icon:SetVertexColor(1, 1, 1)
				else
					HotKey:Hide()
				end
			else
				if inRange == false then
					HotKey:SetTextColor(1, 0.1, 0.1)
					Icon:SetVertexColor(1, 0.1, 0.1)
				else
					HotKey:SetTextColor(0.6, 0.6, 0.6)
					Icon:SetVertexColor(1, 1, 1)
				end
			end

			self.rangeTimer = 0
		else
			self.rangeTimer = (self.rangeTimer or 0) + elapsed
		end
	end

	-- REASON: Periodic check for quest item relevance even if no events were fired.
	if (self.updateTimer or 0) > 5 then
		self:Update()
		self.updateTimer = 0
	else
		self.updateTimer = (self.updateTimer or 0) + elapsed
	end
end)

ExtraQuestButton:SetScript("OnEnable", function(self)
	RegisterStateDriver(self, "visible", visibilityState)
	self:SetAttribute("_onattributechanged", onAttributeChanged)
	self:Update()
	self:SetItem()
end)

ExtraQuestButton:SetScript("OnDisable", function(self)
	if not self:IsMovable() then
		self:SetMovable(true)
	end

	RegisterStateDriver(self, "visible", "show")
	self:SetAttribute("_onattributechanged", nil)
	self.Icon:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
	self.HotKey:Hide()
end)

-- ---------------------------------------------------------------------------
-- ITEM MANAGEMENT
-- ---------------------------------------------------------------------------

-- REASON: Sets the specific item to be used by the secure button.
function ExtraQuestButton:SetItem(itemLink)
	-- WARNING: Suppress the button if the actual Blizzard Extra Action Bar is active.
	if HasExtraActionBar() then
		return
	end

	if itemLink then
		self.Icon:SetTexture(C_Item_GetItemIconByID(itemLink))
		local itemID = GetItemInfoFromHyperlink(itemLink)
		self.itemID = itemID
		self.itemLink = itemLink

		if C["ExtraQuestButtonData"].Blacklist[itemID] then
			return
		end
	end

	if self.itemID then
		local HotKey = self.HotKey
		local key = GetBindingKey("EXTRAACTIONBUTTON1")
		local hasRange = C_Item_ItemHasRange(self.itemID)
		if key then
			HotKey:SetText(GetBindingText(key, 1))
			HotKey:Show()
		elseif hasRange then
			HotKey:SetText(RANGE_INDICATOR)
			HotKey:Show()
		else
			HotKey:Hide()
		end
		K:GetModule("ActionBar").UpdateHotKey(HotKey)

		self:UpdateAttributes()
		self:UpdateCount()
		self.updateRange = hasRange
	end
end

function ExtraQuestButton:RemoveItem()
	self.itemID = nil
	self.itemLink = nil
	self:UpdateAttributes()
end

-- ---------------------------------------------------------------------------
-- QUEST SCANNING LOGIC
-- ---------------------------------------------------------------------------

local function IsQuestOnMap(questID)
	return not onlyCurrentZone or C_QuestLog_IsOnMap(questID)
end

-- REASON: Retrieves the special item associated with a quest and calculates proximity.
local function GetQuestDistanceWithItem(questID)
	local questLogIndex = C_QuestLog_GetLogIndexForQuestID(questID)
	if not questLogIndex then
		return
	end

	local itemLink, _, _, showWhenComplete = GetQuestLogSpecialItemInfo(questLogIndex)
	-- NOTE: Handle fallbacks for quests with items not explicitly marked by Blizzard.
	if not itemLink then
		local fallbackItemID = C["ExtraQuestButtonData"].QuestItems[questID]
		if fallbackItemID then
			itemLink = format("|Hitem:%d|h", fallbackItemID)
		end
	end

	if not itemLink or C_Item_GetItemCount(itemLink) == 0 then
		return
	end

	local itemID = GetItemInfoFromHyperlink(itemLink)
	if C["ExtraQuestButtonData"].Blacklist[itemID] then
		return
	end

	-- NOTE: Respect completion-state filtering to avoid showing irrelevant items.
	if C_QuestLog_IsComplete(questID) then
		if showWhenComplete and C["ExtraQuestButtonData"].CompleteHiddenItems[itemID] then
			return
		end
		if not showWhenComplete and not C["ExtraQuestButtonData"].CompleteShownItems[itemID] then
			return
		end
	end

	-- REASON: Prioritize items based on square distance to the quest objective.
	local distanceSq = C_QuestLog_GetDistanceSqToQuest(questID)
	local distanceYd = distanceSq and sqrt(distanceSq)
	if IsQuestOnMap(questID) and distanceYd and distanceYd <= MAX_DISTANCE_YARDS then
		return distanceYd, itemLink
	end

	-- NOTE: Special case for quests with inaccurate area data (e.g. zone-wide objectives).
	local questMapID = C["ExtraQuestButtonData"].InaccurateQuestAreas[questID]
	if questMapID then
		local currentMapID = C_Map_GetBestMapForUnit("player")
		if type(questMapID) == "boolean" then
			return MAX_DISTANCE_YARDS - 1, itemLink
		elseif type(questMapID) == "number" then
			if questMapID == currentMapID then
				return MAX_DISTANCE_YARDS - 2, itemLink
			end
		elseif type(questMapID) == "table" then
			for _, mapID in next, questMapID do
				if mapID == currentMapID then
					return MAX_DISTANCE_YARDS - 2, itemLink
				end
			end
		end
	end
end

-- REASON: Scans watched quests, world quests, and the general log to find the "closest" item.
local function GetClosestQuestItem()
	local closestQuestItemLink
	local closestDistance = MAX_DISTANCE_YARDS

	-- 1. Scan World Quests
	for index = 1, C_QuestLog_GetNumWorldQuestWatches() do
		local questID = C_QuestLog_GetQuestIDForWorldQuestWatchIndex(index)
		if questID then
			local distance, itemLink = GetQuestDistanceWithItem(questID)
			if distance and distance <= closestDistance then
				closestDistance = distance
				closestQuestItemLink = itemLink
			end
		end
	end

	-- 2. Scan Watched Quests
	if not closestQuestItemLink then
		for index = 1, C_QuestLog_GetNumQuestWatches() do
			local questID = C_QuestLog_GetQuestIDForQuestWatchIndex(index)
			if questID and QuestHasPOIInfo(questID) then
				local distance, itemLink = GetQuestDistanceWithItem(questID)
				if distance and distance <= closestDistance then
					closestDistance = distance
					closestQuestItemLink = itemLink
				end
			end
		end
	end

	-- 3. Scan General Quest Log
	if not closestQuestItemLink then
		for index = 1, C_QuestLog_GetNumQuestLogEntries() do
			local info = C_QuestLog_GetInfo(index)
			local questID = info and info.questID
			if questID and not info.isHeader and (not info.isHidden or C_QuestLog_IsWorldQuest(questID)) and QuestHasPOIInfo(questID) then
				local distance, itemLink = GetQuestDistanceWithItem(questID)
				if distance and distance <= closestDistance then
					closestDistance = distance
					closestQuestItemLink = itemLink
				end
			end
		end
	end

	-- 4. Scan Bonus Objectives (Tasks)
	local tasksTable = GetTasksTable()
	for i = 1, #tasksTable do
		local questID = tasksTable[i]
		if questID and not C_QuestLog_IsWorldQuest(questID) and not QuestUtils_IsQuestWatched(questID) and GetTaskInfo(questID) then
			local distance, itemLink = GetQuestDistanceWithItem(questID)
			if distance and distance <= closestDistance then
				closestDistance = distance
				closestQuestItemLink = itemLink
			end
		end
	end

	return closestQuestItemLink
end

function ExtraQuestButton:Update()
	if HasExtraActionBar() or self.locked then
		return
	end

	local itemLink = GetClosestQuestItem()
	if itemLink then
		if itemLink ~= self.itemLink then
			self:SetItem(itemLink)
		end
	elseif self:IsShown() then
		self:RemoveItem()
	end
end
