--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays important raid debuffs on unit frames (e.g. for healers).
-- - Design: Priority-based debuff filtering with class-specific dispel capabilities.
-- - Events: SPELLS_CHANGED, UNIT_AURA.
-----------------------------------------------------------------------------]]

local _, ns = ...
local oUF = ns.oUF or oUF
local K = KkthnxUI[1]
local NotSecret = K.NotSecret

-- REASON: Localize globals for performance
local _G = _G
local IsPlayerSpell = _G.IsPlayerSpell
local UnitCanAssist = _G.UnitCanAssist
local GetTime = _G.GetTime
local playerClass = _G.UnitClassBase("player")
local GetAuraDataByAuraInstanceID = _G.C_UnitAuras.GetAuraDataByAuraInstanceID
local GetAuraDataByIndex = _G.C_UnitAuras.GetAuraDataByIndex
local GetAuraDuration = _G.C_UnitAuras.GetAuraDuration
local ForEachAura = _G.AuraUtil.ForEachAura
local debuffColor = _G.DebuffTypeColor
local pairs = pairs

-- Raid debuff swipe sits at 0.7 so the icon stays readable under the pie.
local RAID_DEBUFF_CD_ALPHA = 0.7

-- Timer throttle for text updates (seconds)
local TIMER_THROTTLE = 0.1

-- Small table pool for cache entries
local cacheWrite
local cachePool = {}
local function acquireCacheEntry()
	local t = cachePool[#cachePool]
	if t then
		cachePool[#cachePool] = nil
		return t
	end
	return {}
end
local function releaseCacheEntry(t)
	t.priority = nil
	t.AuraData = nil
	cachePool[#cachePool + 1] = t
end

local function clearDebuffCache(cache)
	for auraInstanceID, entry in pairs(cache) do
		cache[auraInstanceID] = nil
		releaseCacheEntry(entry)
	end
end

-- Holds the dispel priority list.
local priorityList = {
	Magic = 4,
	Curse = 3,
	Poison = 2,
	Disease = 1,
}

-- Holds which dispel types can currently be handled. Initialized to false for all.
local dispelList = {
	Magic = false,
	Poison = false,
	Disease = false,
	Curse = false,
}

-- Class functions to update the dispel types which can be handled.
local updateDispelCapabilitiesByClass = {
	DRUID = function()
		dispelList["Magic"] = IsPlayerSpell(88423) -- Nature's Cure
		dispelList["Poison"] = IsPlayerSpell(392378) or IsPlayerSpell(2782) -- Improved Nature's Cure or Remove Corruption
		dispelList["Disease"] = false
		dispelList["Curse"] = IsPlayerSpell(392378) or IsPlayerSpell(2782) -- Improved Nature's Cure or Remove Corruption
	end,
	MAGE = function()
		dispelList["Magic"] = false
		dispelList["Poison"] = false
		dispelList["Disease"] = false
		dispelList["Curse"] = IsPlayerSpell(475) -- Remove Curse
	end,
	MONK = function()
		dispelList["Magic"] = IsPlayerSpell(115450) -- Detox
		dispelList["Poison"] = IsPlayerSpell(388874) or IsPlayerSpell(218164) -- Improved Detox or Detox
		dispelList["Disease"] = IsPlayerSpell(388874) or IsPlayerSpell(218164) -- Improved Detox or Detox
		dispelList["Curse"] = false
	end,
	PALADIN = function()
		dispelList["Magic"] = IsPlayerSpell(4987) -- Cleanse
		dispelList["Poison"] = IsPlayerSpell(393024) or IsPlayerSpell(213644) -- Improved Cleanse or Cleanse Toxins
		dispelList["Disease"] = IsPlayerSpell(393024) or IsPlayerSpell(213644) -- Improved Cleanse or Cleanse Toxins
		dispelList["Curse"] = false
	end,
	PRIEST = function()
		dispelList["Magic"] = IsPlayerSpell(527) or IsPlayerSpell(32375) -- Purify or Mass Dispel
		dispelList["Poison"] = false
		dispelList["Disease"] = IsPlayerSpell(390632) or IsPlayerSpell(213634) -- Improved Purify or Purify Disease
		dispelList["Curse"] = false
	end,
	SHAMAN = function()
		dispelList["Magic"] = IsPlayerSpell(77130) -- Purify Spirit
		dispelList["Poison"] = IsPlayerSpell(383013) -- Poison Cleansing Totem
		dispelList["Disease"] = false
		dispelList["Curse"] = IsPlayerSpell(383016) or IsPlayerSpell(51886) -- Improved Purify Spirit or Cleanse Spirit
	end,
	EVOKER = function()
		dispelList["Magic"] = IsPlayerSpell(360823) -- Naturalize
		dispelList["Poison"] = IsPlayerSpell(360823) or IsPlayerSpell(365585) or IsPlayerSpell(374251) -- Naturalize or Expunge or Cauterizing Flame
		dispelList["Disease"] = IsPlayerSpell(374251) -- Cauterizing Flame
		dispelList["Curse"] = IsPlayerSpell(374251) -- Cauterizing Flame
	end,
}

-- Event handler for SPELLS_CHANGED.
-- Only fires for a player frame.
local function UpdateDispelList(self, event)
	if event == "SPELLS_CHANGED" then
		local updater = updateDispelCapabilitiesByClass[playerClass]
		if updater then
			updater()
		end
	end
end

-- Returns a format string for timers.
local function timeFormat(time)
	if time < 3 then
		return "%.1f"
	elseif time < 60 then
		return "%d"
	else
		return ""
	end
end

-- Throttled OnUpdate for remaining time text
local function ElementOnUpdate(self, elapsed)
	local accum = (self._accum or 0) + elapsed
	if accum < TIMER_THROTTLE then
		self._accum = accum
		return
	end
	self._accum = 0

	local expirationTime = self._expiresAt
	local duration = self._duration
	if not expirationTime or not duration or duration <= 0 then
		self:SetScript("OnUpdate", nil)
		if self.timer then
			self.timer:SetText("")
		end
		return
	end

	local remaining = expirationTime - GetTime()
	if remaining > 0 then
		self.timer:SetFormattedText(timeFormat(remaining), remaining)
	else
		-- Aura expired; ensure cache is updated in absence of an event
		self:SetScript("OnUpdate", nil)
		self.timer:SetText("")
		if cacheWrite and self.__owner and self.__unit and self._auraInstanceID then
			cacheWrite(self.__owner, self.__unit, self._auraInstanceID, nil, nil)
		end
	end
end

-- Show the debuff element for auraInstanceID.
local function ShowElement(self, unit, auraInstanceID)
	local element = self.RaidDebuffs
	local debuffCache = element.debuffCache
	local AuraData = debuffCache[auraInstanceID].AuraData
	local count = AuraData.applications
	local duration = AuraData.duration
	local expirationTime = AuraData.expirationTime
	-- SECRET (12.0): dispelName/duration/expirationTime/applications can all be
	-- secret in instances. Gate every read used as a table key, in arithmetic, or
	-- in a comparison; fall back to safe defaults so the icon still shows.
	local dispelName = AuraData.dispelName
	local color
	if NotSecret(dispelName) and debuffColor[dispelName] then
		color = debuffColor[dispelName]
	else
		local r, g, b = K.GetAuraDispelBorderRGB(unit, auraInstanceID, oUF)
		if r then
			color = { r = r, g = g, b = b }
		else
			color = debuffColor.none
		end
	end

	element.icon:SetTexture(AuraData.icon)
	element.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
	element:Show()

	-- Prefer DurationObject + engine countdown (secret-safe in instances).
	-- Lua OnUpdate only when duration fields are plain and GetAuraDuration fails.
	element:SetScript("OnUpdate", nil)
	element._accum = 0
	element._expiresAt = nil
	element._duration = nil
	element._auraInstanceID = auraInstanceID

	local durObj = GetAuraDuration and GetAuraDuration(unit, auraInstanceID)
	if durObj and element.cd and element.cd.SetCooldownFromDurationObject then
		element.cd:SetCooldownFromDurationObject(durObj)
		-- IsZero may be secret — only feed SetAlphaFromBoolean (Ellesmere permanent-aura mask).
		if durObj.IsZero and element.cd.SetAlphaFromBoolean then
			element.cd:SetAlphaFromBoolean(durObj:IsZero(), 0, RAID_DEBUFF_CD_ALPHA)
		else
			element.cd:SetAlpha(RAID_DEBUFF_CD_ALPHA)
		end
		element.cd:SetHideCountdownNumbers(false)
		element.cd:Show()
		K.StyleAuraCooldownCountdown(element.cd, 12, element, "CENTER", 1, 0)
		element.timer:Hide()
		element.timer:SetText("")
	elseif NotSecret(duration) and NotSecret(expirationTime) and duration and duration > 0 and expirationTime then
		local start = expirationTime - duration
		element.cd:SetAlpha(RAID_DEBUFF_CD_ALPHA)
		element.cd:SetHideCountdownNumbers(true)
		element.cd:SetCooldown(start, duration)
		element.cd:Show()
		element._expiresAt = expirationTime
		element._duration = duration
		element.timer:Show()
		element:SetScript("OnUpdate", ElementOnUpdate)
	else
		element.cd:SetHideCountdownNumbers(true)
		element.cd:SetCooldown(0, 0)
		element.cd:SetAlpha(RAID_DEBUFF_CD_ALPHA)
		element.timer:Hide()
		element.timer:SetText("")
	end

	if NotSecret(count) and count and count > 1 then
		element.count:SetText(count)
	else
		element.count:SetText("")
	end
end

-- Hide the debuff element.
local function HideElement(self, unit)
	local element = self.RaidDebuffs
	local color = debuffColor["none"]

	-- Stop OnUpdate timer and clear state
	element:SetScript("OnUpdate", nil)
	element._accum = 0
	element._expiresAt = nil
	element._duration = nil
	element._auraInstanceID = nil

	element.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
	element.cd:SetHideCountdownNumbers(true)
	element.cd:SetCooldown(0, 0)
	element.cd:SetAlpha(RAID_DEBUFF_CD_ALPHA)
	element.timer:Hide()
	element.timer:SetText("")
	element.count:SetText("")

	element:Hide()
end

-- Select the Debuff with highest priority to display, hide element when none left.
local function SelectPrioDebuff(self, unit)
	local debuffCache = self.RaidDebuffs.debuffCache
	local auraInstanceID = nil
	local priority = 0

	-- find debuff with highest priority
	for id, debuff in pairs(debuffCache) do
		if priority < debuff.priority then
			auraInstanceID = id
			priority = debuff.priority
		end
	end

	if auraInstanceID then
		ShowElement(self, unit, auraInstanceID)
	else
		HideElement(self, unit)
	end
end

-- After each write to the cache the display also needs to be updated.
-- Struncture of the cache is: table<auraInstanceID, aura<priority, AuraData>>
cacheWrite = function(self, unit, auraInstanceID, priority, AuraData)
	local debuffCache = self.RaidDebuffs.debuffCache

	if not priority or not AuraData then
		local old = debuffCache[auraInstanceID]
		if old then
			debuffCache[auraInstanceID] = nil
			releaseCacheEntry(old)
		end
	else
		local entry = debuffCache[auraInstanceID]
		if not entry then
			entry = acquireCacheEntry()
			debuffCache[auraInstanceID] = entry
		end
		entry.priority = priority
		entry.AuraData = AuraData
	end

	SelectPrioDebuff(self, unit)
end

-- Filter for dispellable debuffs and update the cache.
local function FilterAura(self, unit, auraInstanceID, AuraData)
	local debuffCache = self.RaidDebuffs.debuffCache

	if AuraData then -- added aura or valid update
		-- SECRET (12.0): AuraData.isHarmful is secret. dispelList only contains
		-- dispellable debuff types, so a non-secret dispelName found there is a
		-- harmful aura we care about; this both replaces the isHarmful gate and
		-- guards the dispelList/priorityList table-key lookups.
		local dispelName = AuraData.dispelName
		if NotSecret(dispelName) and dispelName and dispelList[dispelName] then
			cacheWrite(self, unit, auraInstanceID, priorityList[dispelName], AuraData)
		elseif AuraData.auraInstanceID then
			local resolved = K.GetAuraDispelTypeName(unit, AuraData.auraInstanceID, oUF)
			if resolved and dispelList[resolved] then
				cacheWrite(self, unit, auraInstanceID, priorityList[resolved], AuraData)
			end
		end
	elseif debuffCache[auraInstanceID] then -- removed aura or invalid update
		cacheWrite(self, unit, auraInstanceID, nil, nil)
	end -- aura we dont care about
end

-- Reset cache and full scan when isFullUpdate.
local function FullUpdate(self, unit)
	clearDebuffCache(self.RaidDebuffs.debuffCache)
	HideElement(self, unit)

	if ForEachAura then
		-- Mainline iteration-style.
		ForEachAura(unit, "HARMFUL", nil, function(AuraData)
			FilterAura(self, unit, AuraData.auraInstanceID, AuraData)
		end, true)
	else
		-- Classic iteration-style.
		local AuraData
		local i = 1
		repeat
			AuraData = GetAuraDataByIndex(unit, i, "HARMFUL")
			if AuraData then
				FilterAura(self, unit, AuraData.auraInstanceID, AuraData)
			end
			i = i + 1
		until not AuraData
	end
end

-- Event handler for UNIT_AURA.
local function Update(self, event, unit, updateInfo)
	-- Exit when unit doesn't match or target can't be assisted
	if event ~= "UNIT_AURA" or self.unit ~= unit or not UnitCanAssist("player", unit) then
		return
	end

	if not updateInfo or updateInfo.isFullUpdate then
		FullUpdate(self, unit)
		return
	end

	if updateInfo.removedAuraInstanceIDs then
		local list = updateInfo.removedAuraInstanceIDs
		for i = 1, #list do
			FilterAura(self, unit, list[i], nil)
		end
	end

	if updateInfo.updatedAuraInstanceIDs then
		local list = updateInfo.updatedAuraInstanceIDs
		for i = 1, #list do
			local auraInstanceID = list[i]
			FilterAura(self, unit, auraInstanceID, GetAuraDataByAuraInstanceID(unit, auraInstanceID))
		end
	end

	if updateInfo.addedAuras then
		local list = updateInfo.addedAuras
		for i = 1, #list do
			local AuraData = list[i]
			FilterAura(self, unit, AuraData.auraInstanceID, AuraData)
		end
	end
end

local function Enable(self)
	local element = self.RaidDebuffs

	if element and updateDispelCapabilitiesByClass[playerClass] then
		element.debuffCache = {}
		element.__owner = self
		element.__unit = self.unit

		element.font = element.font or NumberFontNormal
		element.fontHeight = element.fontHeight or 12
		element.fontFlags = element.fontFlags or ""

		-- Create missing Sub-Widgets
		if not element.icon then
			element.icon = element:CreateTexture(nil, "ARTWORK")
			element.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			element.icon:SetAllPoints(element)
		end

		if not element.cd then
			element.cd = CreateFrame("Cooldown", nil, element, "CooldownFrameTemplate")
			element.cd:SetAllPoints(element)
			element.cd:SetReverse(true)
			element.cd:SetHideCountdownNumbers(true)
			element.cd:SetAlpha(0.7)
		end

		if not element.timer then
			element.timer = element:CreateFontString(nil, "OVERLAY")
			element.timer:SetFont(element.font, element.fontHeight, element.fontFlags)
			element.timer:SetPoint("CENTER", element, 1, 0)
		end

		if not element.count then
			element.count = element:CreateFontString(nil, "OVERLAY")
			element.count:SetFont(element.font, element.fontHeight, element.fontFlags)
			element.count:SetPoint("BOTTOMRIGHT", element, "BOTTOMRIGHT", 2, 0)
			element.count:SetTextColor(1, 0.9, 0)
		end

		if not element.KKUI_Border then
			element:CreateBorder()
		end

		-- Update the dispelList at login and whenever spells change (only fires for a player frame)
		self:RegisterEvent("SPELLS_CHANGED", UpdateDispelList, true)
		self:RegisterEvent("UNIT_AURA", Update)

		HideElement(self, self.unit)

		return true
	end
end

local function Disable(self)
	local element = self.RaidDebuffs

	if element then
		if element.debuffCache then
			clearDebuffCache(element.debuffCache)
		end
		element.debuffCache = nil
		self:UnregisterEvent("SPELLS_CHANGED", UpdateDispelList)
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("RaidDebuffs", Update, Enable, Disable)
