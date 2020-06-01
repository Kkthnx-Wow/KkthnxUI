local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local bit_band = _G.bit.band
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local CombatLogGetCurrentEventInfo = _G.CombatLogGetCurrentEventInfo
local CreateFrame = _G.CreateFrame
local GetActionInfo = _G.GetActionInfo
local GetActionTexture = _G.GetActionTexture
local GetContainerItemID = _G.GetContainerItemID
local GetInventoryItemID = _G.GetInventoryItemID
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetItemCooldown = _G.GetItemCooldown
local GetItemInfo = _G.GetItemInfo
local GetPetActionCooldown = _G.GetPetActionCooldown
local GetPetActionInfo = _G.GetPetActionInfo
local GetSpellCooldown = _G.GetSpellCooldown
local GetSpellInfo = _G.GetSpellInfo
local GetSpellTexture = _G.GetSpellTexture
local GetTime = _G.GetTime
local IsInInstance = _G.IsInInstance
local PlaySound = _G.PlaySound
local hooksecurefunc = _G.hooksecurefunc

local fadeInTime, fadeOutTime, maxAlpha, elapsed, runtimer = 0.5, 0.7, 1, 0, 0
local animScale, iconSize, holdTime, threshold = C["PulseCooldown"].AnimScale, C["PulseCooldown"].Size, C["PulseCooldown"].HoldTime, C["PulseCooldown"].Threshold
local cooldowns, animating, watching = {}, {}, {}

K.PulseIgnoredSpells = {
	GetSpellInfo(110560), -- Garrison Hearthstone
	GetSpellInfo(140192), -- Dalaran Hearthstone
	GetSpellInfo(6948),	-- Hearthstone
	GetSpellInfo(125439), -- Revive Battle Pets
}

local PulseCooldownFrame = CreateFrame("Frame", "PulseCooldownFrame", UIParent)
-- PulseCooldownFrame:CreateBorder()
-- PulseCooldownFrame:CreateInnerShadow()
PulseCooldownFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 260)

PulseCooldownFrame.Icon = PulseCooldownFrame:CreateTexture(nil, "ARTWORK")
PulseCooldownFrame.Icon:SetTexCoord(unpack(K.TexCoords))
PulseCooldownFrame.Icon:SetAllPoints(PulseCooldownFrame)

-- Utility Functions
local function tcount(tab)
	local n = 0
	for _ in pairs(tab) do
		n = n + 1
	end

	return n
end

local function memoize(f)
	local cache = nil
	local memoized = {}

	local function get()
		if (cache == nil) then
			cache = f()
		end

		return cache
	end

	memoized.resetCache = function()
		cache = nil
	end

	setmetatable(memoized, {__call = get})

	return memoized
end

local function GetPetActionIndexByName(name)
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		if GetPetActionInfo(i) == name then
			return i
		end
	end

	return nil
end

-- Cooldown/Animation
local function OnUpdate(_, update)
	elapsed = elapsed + update
	if elapsed > 0.05 then
		for i, v in pairs(watching) do
			if GetTime() >= v[1] + 0.5 then
				local getCooldownDetails
				if v[2] == "spell" then
					getCooldownDetails = memoize(function()
						local start, duration, enabled = GetSpellCooldown(v[3])
						return {name = GetSpellInfo(v[3]), texture = GetSpellTexture(v[3]), start = start, duration = duration, enabled = enabled}
					end)
				elseif v[2] == "item" then
					getCooldownDetails = memoize(function()
						local start, duration, enabled = GetItemCooldown(i)
						return {name = GetItemInfo(i), texture = v[3], start = start, duration = duration, enabled = enabled}
					end)
				elseif v[2] == "pet" then
					getCooldownDetails = memoize(function()
						local name, texture = GetPetActionInfo(v[3])
						local start, duration, enabled = GetPetActionCooldown(v[3])
						return {name = name, texture = texture, isPet = true, start = start, duration = duration, enabled = enabled}
					end)
				end

				local cooldown = getCooldownDetails()
				if K.PulseIgnoredSpells[cooldown.name] then
					watching[i] = nil
				else
					if cooldown.enabled ~= 0 then
						if cooldown.duration and cooldown.duration > threshold and cooldown.texture then
							cooldowns[i] = getCooldownDetails
						end
					end

					if not (cooldown.enabled == 0 and v[2] == "spell") then
						watching[i] = nil
					end
				end
			end
		end

		for i, getCooldownDetails in pairs(cooldowns) do
			local cooldown = getCooldownDetails()
			local remaining = cooldown.duration - (GetTime() - cooldown.start)
			if remaining <= 0 then
				table_insert(animating, {cooldown.texture, cooldown.isPet, cooldown.name})
				cooldowns[i] = nil
			end
		end

		elapsed = 0
		if #animating == 0 and tcount(watching) == 0 and tcount(cooldowns) == 0 then
			PulseCooldownFrame:SetScript("OnUpdate", nil)
			return
		end
	end

	if #animating > 0 then
		runtimer = runtimer + update
		if runtimer > (fadeInTime + holdTime + fadeOutTime) then
			table_remove(animating, 1)
			runtimer = 0
			PulseCooldownFrame.Icon:SetTexture(nil)
			-- PulseCooldownFrame:SetBackdropBorderColor(0, 0, 0, 0)
			-- PulseCooldownFrame:SetBackdropColor(0, 0, 0, 0)
			-- PulseCooldownFrame.InnerShadow:SetVertexColor(0, 0, 0, 0)
		else
			if not PulseCooldownFrame.Icon:GetTexture() then
				PulseCooldownFrame.Icon:SetTexture(animating[1][1])
				if C["PulseCooldown"].Sound == true then
					PlaySound(18192, "Master")
				end
			end

			local alpha = maxAlpha
			if runtimer < fadeInTime then
				alpha = maxAlpha * (runtimer / fadeInTime)
			elseif runtimer >= fadeInTime + holdTime then
				alpha = maxAlpha - (maxAlpha * ((runtimer - holdTime - fadeInTime) / fadeOutTime))
			end

			PulseCooldownFrame:SetAlpha(alpha)

			local scale = iconSize + (iconSize * ((animScale - 1) * (runtimer / (fadeInTime + holdTime + fadeOutTime))))
			PulseCooldownFrame:SetWidth(scale)
			PulseCooldownFrame:SetHeight(scale)
			-- PulseCooldownFrame:SetBackdropBorderColor()
			-- PulseCooldownFrame:SetBackdropColor(.04, .04, .04, 0.9)
			-- PulseCooldownFrame.InnerShadow:SetVertexColor(.04, .04, .04, 1)
		end
	end
end

-- Event Handlers
function Module:ADDON_LOADED()
	for _, v in pairs(K.PulseIgnoredSpells) do
		K.PulseIgnoredSpells[v] = true
	end

	K:UnregisterEvent("ADDON_LOADED", self.ADDON_LOADED)
end

function Module:SPELL_UPDATE_COOLDOWN()
	for _, getCooldownDetails in pairs(cooldowns) do
		getCooldownDetails.resetCache()
	end
end

function Module:UNIT_SPELLCAST_SUCCEEDED(unit, _, spellID)
	if unit == "player" then
		watching[spellID] = {GetTime(), "spell", spellID}
		PulseCooldownFrame:SetScript("OnUpdate", OnUpdate)
	end
end

function Module:COMBAT_LOG_EVENT_UNFILTERED()
	local _, eventType, _, _, _, sourceFlags, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
	if eventType == "SPELL_CAST_SUCCESS" then
		if (bit_band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) == COMBATLOG_OBJECT_TYPE_PET and bit_band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE) then
			local name = GetSpellInfo(spellID)
			local index = GetPetActionIndexByName(name)
			if index and not select(7, GetPetActionInfo(index)) then
				watching[spellID] = {GetTime(), "pet", index}
			elseif not index and spellID then
				watching[spellID] = {GetTime(), "spell", spellID}
			else
				return
			end

			PulseCooldownFrame:SetScript("OnUpdate", OnUpdate)
		end
	end
end

function Module:PLAYER_ENTERING_WORLD()
	local _, instanceType = IsInInstance()
	if instanceType == "arena" then
		PulseCooldownFrame:SetScript("OnUpdate", nil)
		table_wipe(cooldowns)
		table_wipe(watching)
	end
end

local function UseAction(slot)
	local actionType, itemID = GetActionInfo(slot)
	if actionType == "item" then
		local texture = GetActionTexture(slot)
		watching[itemID] = {GetTime(), "item", texture}
	end
end

local function UseInventoryItem(slot)
	local itemID = GetInventoryItemID("player", slot)
	if itemID then
		local texture = GetInventoryItemTexture("player", slot)
		watching[itemID] = {GetTime(), "item", texture}
	end
end

local function UseContainerItem(bag, slot)
	local itemID = GetContainerItemID(bag, slot)
	if itemID then
		local texture = select(10, GetItemInfo(itemID))
		watching[itemID] = {GetTime(), "item", texture}
	end
end

function Module:CreatePulseCooldown()
	if not C["PulseCooldown"].Enable then
		return
	end

	local Anchor = CreateFrame("Frame", "PulseCooldownAnchor", UIParent)
	Anchor:SetSize(C["PulseCooldown"].Size, C["PulseCooldown"].Size)
	Anchor:SetPoint("CENTER", UIParent, "CENTER", 0, 260)

	PulseCooldownFrame:SetPoint("CENTER", Anchor, "CENTER", 0, 0)

	K.Mover(PulseCooldownFrame, "PulseCooldown", "PulseCooldown", {"CENTER", UIParent, "CENTER", 0, 260}, C["PulseCooldown"].Size, C["PulseCooldown"].Size)

	K:RegisterEvent("ADDON_LOADED", self.ADDON_LOADED)
	K:RegisterEvent("SPELL_UPDATE_COOLDOWN", self.SPELL_UPDATE_COOLDOWN)
	K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", self.UNIT_SPELLCAST_SUCCEEDED)
	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", self.COMBAT_LOG_EVENT_UNFILTERED)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.PLAYER_ENTERING_WORLD)
	PulseCooldownFrame:SetScript("OnEvent", function(self, event, ...)
		self[event](self, ...)
	end)

	hooksecurefunc("UseAction", UseAction)
	hooksecurefunc("UseInventoryItem", UseInventoryItem)
	hooksecurefunc("UseContainerItem", UseContainerItem)
end

SlashCmdList.PulseCooldown = function()
	table_insert(animating, {GetSpellTexture(87214)})
	if C["PulseCooldown"].Sound == true then
		PlaySoundFile(18192, "Master")
	end

	PulseCooldownFrame:SetScript("OnUpdate", OnUpdate)
end
SLASH_PulseCooldown1 = "/pulsecd"