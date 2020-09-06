local K, C = unpack(select(2, ...))

-- Sourced: ExtraQuestButton, by p3lim

local _G = _G
local next = _G.next
local strmatch = _G.strmatch
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

local C_Map_GetBestMapForUnit =_G.C_Map.GetBestMapForUnit
local C_Timer_NewTicker =_G.C_Timer.NewTicker
local CreateFrame = _G.CreateFrame
local GetBindingKey = _G.GetBindingKey
local GetBindingText = _G.GetBindingText
local GetDistanceSqToQuest = _G.GetDistanceSqToQuest
local GetItemCooldown = _G.GetItemCooldown
local GetItemCount = _G.GetItemCount
local GetNumQuestLogEntries =_G.GetNumQuestLogEntries
local GetNumQuestWatches =_G.GetNumQuestWatches
local GetQuestLogSpecialItemInfo = _G.GetQuestLogSpecialItemInfo
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestTagInfo = _G.GetQuestTagInfo
local GetQuestWatchInfo =_G.GetQuestWatchInfo
local GetTime = _G.GetTime
local HasExtraActionBar = _G.HasExtraActionBar
local InCombatLockdown = _G.InCombatLockdown
local IsItemInRange = _G.IsItemInRange
local IsQuestBounty = _G.IsQuestBounty
local IsQuestTask = _G.IsQuestTask
local ItemHasRange = _G.ItemHasRange
local QuestHasPOIInfo =_G.QuestHasPOIInfo
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local activeWorldQuests = {}
local ticker

local ExtraQuestButton = CreateFrame("Button", "ExtraQuestButton", UIParent, "SecureActionButtonTemplate, SecureHandlerStateTemplate, SecureHandlerAttributeTemplate")
ExtraQuestButton:SetMovable(true)
ExtraQuestButton:RegisterEvent("PLAYER_LOGIN")
ExtraQuestButton:SetScript("OnEvent", function(self, event, ...)
	if (self[event]) then
		self[event](self, event, ...)
	else
		self:Update()
	end
end)

local visibilityState = "[extrabar][petbattle] hide; show"
local onAttributeChanged = [[
if (name == "item") then
	if (value and not self:IsShown() and not HasExtraActionBar()) then
		self:Show()
	elseif (not value) then
		self:Hide()
		self:ClearBindings()
	end
elseif (name == "state-visible") then
	if (value == "show") then
		self:CallMethod("Update")
	else
		self:Hide()
		self:ClearBindings()
	end
end

if (self:IsShown() and (name == "item" or name == "binding")) then
	self:ClearBindings()
	local key = GetBindingKey("EXTRAACTIONBUTTON1")
	if (key) then
		self:SetBindingClick(1, key, self, "LeftButton")
	end
end
]]

function ExtraQuestButton:BAG_UPDATE_COOLDOWN()
	if (self:IsShown() and self.itemID) then
		local start, duration = GetItemCooldown(self.itemID)
		if (duration > 0) then
			self.Cooldown:SetCooldown(start, duration)
			self.Cooldown:Show()
		else
			self.Cooldown:Hide()
		end
	end
end

function ExtraQuestButton:BAG_UPDATE_DELAYED()
	self:Update()

	if (self:IsShown()) then
		local count = GetItemCount(self.itemLink)
		self.Count:SetText(count and count > 1 and count or "")
	end
end

function ExtraQuestButton:PLAYER_REGEN_ENABLED(event)
	if (self.itemID) then
		self:SetAttribute("item", "item:"..self.itemID)
		self:UnregisterEvent(event)
		self:BAG_UPDATE_COOLDOWN()
	end
end

function ExtraQuestButton:UPDATE_BINDINGS()
	if (self:IsShown()) then
		self:SetItem()
		self:SetAttribute("binding", GetTime())
	end
end

function ExtraQuestButton:PLAYER_LOGIN()
	RegisterStateDriver(self, "visible", visibilityState)
	self:SetAttribute("_onattributechanged", onAttributeChanged)
	self:SetAttribute("type", "item")

	if (not self:GetPoint()) then
		self:SetPoint("CENTER", ExtraActionButton1)
	end

	self:SetSize(ExtraActionButton1:GetSize())
	self:SetScale(ExtraActionButton1:GetScale())
	self:SetScript("OnLeave", K.HideTooltip)
	self:SetClampedToScreen(true)
	self:SetToplevel(true)

	self.updateTimer = 0
	self.rangeTimer = 0
	self:Hide()

	local Icon = self:CreateTexture("$parentIcon", "ARTWORK")
	Icon:SetAllPoints()
	Icon:SetTexCoord(unpack(K.TexCoords))
	self.Icon = Icon

	self:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	self:StyleButton()

	local HotKey = self:CreateFontString("$parentHotKey", nil, "NumberFontNormal")
	HotKey:SetPoint("TOP", 0, -5)
	self.HotKey = HotKey

	local Count = self:CreateFontString("$parentCount", nil, "SystemFont_OutlineThick_Huge2")
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
	Artwork:SetSize(28, 26)
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

function ExtraQuestButton:QUEST_REMOVED(_, questID)
	if (activeWorldQuests[questID]) then
		activeWorldQuests[questID] = nil

		self:Update()
	end
end

function ExtraQuestButton:QUEST_ACCEPTED(_, questLogIndex, questID)
	if (questID and not IsQuestBounty(questID) and IsQuestTask(questID)) then
		local _, _, worldQuestType = GetQuestTagInfo(questID)
		if(worldQuestType and not activeWorldQuests[questID]) then
			activeWorldQuests[questID] = questLogIndex

			self:Update()
		end
	end
end

ExtraQuestButton:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetHyperlink(self.itemLink)
end)

ExtraQuestButton:SetScript("OnUpdate", function(self, elapsed)
	if self.updateRange then
		if ((self.rangeTimer or 0) > TOOLTIP_UPDATE_TIME) then
			local HotKey = self.HotKey
			local Icon = self.Icon

			-- BUG: IsItemInRange() is broken versus friendly npcs (and possibly others)
			local inRange = IsItemInRange(self.itemLink, "target")
			if (HotKey:GetText() == RANGE_INDICATOR) then
				if (inRange == false) then
					HotKey:SetTextColor(1, .1, .1)
					HotKey:Show()
					Icon:SetVertexColor(1, .1, .1)
				elseif (inRange) then
					HotKey:SetTextColor(.6, .6, .6)
					HotKey:Show()
					Icon:SetVertexColor(1, 1, 1)
				else
					HotKey:Hide()
				end
			else
				if (inRange == false) then
					HotKey:SetTextColor(1, .1, .1)
					Icon:SetVertexColor(1, .1, .1)
				else
					HotKey:SetTextColor(.6, .6, .6)
					Icon:SetVertexColor(1, 1, 1)
				end
			end

			self.rangeTimer = 0
		else
			self.rangeTimer = (self.rangeTimer or 0) + elapsed
		end
	end

	if ((self.updateTimer or 0) > 5) then
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
	if (not self:IsMovable()) then
		self:SetMovable(true)
	end

	RegisterStateDriver(self, "visible", "show")
	self:SetAttribute("_onattributechanged", nil)
	self.Icon:SetTexture([[Interface\Icons\INV_Misc_Wrench_01]])
	self.HotKey:Hide()
end)

function ExtraQuestButton:SetItem(itemLink, texture)
	if (HasExtraActionBar()) then
		return
	end

	if (itemLink) then
		self.Icon:SetTexture(texture)

		if (itemLink == self.itemLink and self:IsShown()) then
			return
		end

		local itemID = strmatch(itemLink, "|Hitem:(.-):.-|h%[(.+)%]|h")
		self.itemID = tonumber(itemID)
		self.itemLink = itemLink

		if (K.ExtraQuestButton_BlackList[itemID]) then
			return
		end
	end

	if (self.itemID) then
		local HotKey = self.HotKey
		local key = GetBindingKey("EXTRAACTIONBUTTON1")
		local hasRange = ItemHasRange(itemLink)
		if (key) then
			HotKey:SetText(GetBindingText(key, 1))
			HotKey:Show()
		elseif (hasRange) then
			HotKey:SetText(RANGE_INDICATOR)
			HotKey:Show()
		else
			HotKey:Hide()
		end

		if C["ActionBar"].Enable then
			K:GetModule("ActionBar").UpdateHotKey(self)
		end

		if (InCombatLockdown()) then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		else
			self:SetAttribute("item", "item:"..self.itemID)
			self:BAG_UPDATE_COOLDOWN()
		end

		self.updateRange = hasRange
	end
end

function ExtraQuestButton:RemoveItem()
	if (InCombatLockdown()) then
		self.itemID = nil
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:SetAttribute("item", nil)
	end
end

local function GetClosestQuestItem()
	-- Basically a copy of QuestSuperTracking_ChooseClosestQuest from Blizzard_ObjectiveTracker
	local closestQuestLink, closestQuestTexture
	local shortestDistanceSq = 62500 -- 250 yards²
	local numItems = 0

	-- XXX: temporary solution for the above
	for questID, questLogIndex in next, activeWorldQuests do
		local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
		if (itemLink) then
			local areaID = K.ExtraQuestButton_QuestAreas[questID]
			if (not areaID) then
				areaID = K.ExtraQuestButton_ItemAreas[tonumber(strmatch(itemLink, "item:(%d+)"))]
			end

			local _, _, _, _, _, isComplete = GetQuestLogTitle(questLogIndex)
			if (areaID and (type(areaID) == "boolean" or areaID == C_Map_GetBestMapForUnit("player"))) then
				closestQuestLink = itemLink
				closestQuestTexture = texture
			elseif (not isComplete or (isComplete and showCompleted)) then
				local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
				if (onContinent and distanceSq <= shortestDistanceSq) then
					shortestDistanceSq = distanceSq
					closestQuestLink = itemLink
					closestQuestTexture = texture
				end
			end

			numItems = numItems + 1
		end
	end

	if (not closestQuestLink) then
		for index = 1, GetNumQuestWatches() do
			local questID, _, questLogIndex, _, _, isComplete = GetQuestWatchInfo(index)
			if(questID and QuestHasPOIInfo(questID)) then
				local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
				if(itemLink) then
					local areaID = K.ExtraQuestButton_QuestAreas[questID]
					if(not areaID) then
						areaID = K.ExtraQuestButton_ItemAreas[tonumber(strmatch(itemLink, "item:(%d+)"))]
					end

					if (areaID and (type(areaID) == "boolean" or areaID == C_Map_GetBestMapForUnit("player"))) then
						closestQuestLink = itemLink
						closestQuestTexture = texture
					elseif(not isComplete or (isComplete and showCompleted)) then
						local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
						if(onContinent and distanceSq <= shortestDistanceSq) then
							shortestDistanceSq = distanceSq
							closestQuestLink = itemLink
							closestQuestTexture = texture
						end
					end

					numItems = numItems + 1
				end
			end
		end
	end

	if (not closestQuestLink) then
		for questLogIndex = 1, GetNumQuestLogEntries() do
			local _, _, _, isHeader, _, isComplete, _, questID = GetQuestLogTitle(questLogIndex)
			if(not isHeader and QuestHasPOIInfo(questID)) then
				local itemLink, texture, _, showCompleted = GetQuestLogSpecialItemInfo(questLogIndex)
				if(itemLink) then
					local areaID = K.ExtraQuestButton_QuestAreas[questID]
					if(not areaID) then
						areaID = K.ExtraQuestButton_ItemAreas[tonumber(strmatch(itemLink, "item:(%d+)"))]
					end

					if(areaID and (type(areaID) == "boolean" or areaID == C_Map_GetBestMapForUnit("player"))) then
						closestQuestLink = itemLink
						closestQuestTexture = texture
					elseif(not isComplete or (isComplete and showCompleted)) then
						local distanceSq, onContinent = GetDistanceSqToQuest(questLogIndex)
						if(onContinent and distanceSq <= shortestDistanceSq) then
							shortestDistanceSq = distanceSq
							closestQuestLink = itemLink
							closestQuestTexture = texture
						end
					end

					numItems = numItems + 1
				end
			end
		end
	end

	return closestQuestLink, closestQuestTexture, numItems
end

function ExtraQuestButton:Update()
	if (HasExtraActionBar() or self.locked) then
		return
	end

	local itemLink, texture, numItems = GetClosestQuestItem()
	if (itemLink) then
		self:SetItem(itemLink, texture)
	elseif(self:IsShown()) then
		self:RemoveItem()
	end

	if(numItems > 0 and not ticker) then
		ticker = C_Timer_NewTicker(30, function() -- Might Want To Lower This
			ExtraQuestButton:Update()
		end)
	elseif(numItems == 0 and ticker) then
		ticker:Cancel()
		ticker = nil
	end
end