--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell (Ported from ShestakUI)
-- Notes:
-- - Purpose: Flashes a large icon in the middle of the screen when a cooldown finishes.
-- - Design: Uses OnUpdate to track cooldowns from spellcasts and items.
-- - Events: PLAYER_ENTERING_WORLD, UNIT_SPELLCAST_SUCCEEDED, COMBAT_LOG_EVENT_UNFILTERED, SPELL_UPDATE_COOLDOWN
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local GetTime = GetTime
local table_insert = table.insert
local table_remove = table.remove
local wipe = wipe
local pairs = pairs
local next = next

-- PERF: Cache frequent WoW API calls
local C_Spell_GetSpellCooldown = C_Spell.GetSpellCooldown
local C_Spell_GetSpellName = C_Spell.GetSpellName
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local C_Item_GetItemCooldown = C_Item.GetItemCooldown
local C_Item_GetItemInfo = C_Item.GetItemInfo
local GetPetActionInfo = GetPetActionInfo
local GetPetActionCooldown = GetPetActionCooldown
local PlaySoundFile = PlaySoundFile
local bit_band = bit.band

-- ---------------------------------------------------------------------------
-- Constants and Locals
-- ---------------------------------------------------------------------------
local fadeInTime, fadeOutTime, maxAlpha, elapsed, runtimer = 0.5, 0.7, 1, 0, 0
local cooldowns, animating, watching = {}, {}, {}
local pulse_ignored_spells = {}

-- PERF: Table pool to avoid allocating garbage on every ability use
local tablePool = {}
local function GetTable()
	local t = next(tablePool)
	if t then
		tablePool[t] = nil
		return t
	end
	return {}
end

local function ReleaseTable(t)
	wipe(t)
	tablePool[t] = true
end

-- ---------------------------------------------------------------------------
-- Utility Functions
-- ---------------------------------------------------------------------------
local function tcount(tab)
	local n = 0
	for _ in pairs(tab) do
		n = n + 1
	end
	return n
end

local function GetPetActionIndexByName(name)
	for i = 1, NUM_PET_ACTION_SLOTS, 1 do
		if GetPetActionInfo(i) == name then
			return i
		end
	end
	return nil
end

-- ---------------------------------------------------------------------------
-- PulseCD Logic
-- ---------------------------------------------------------------------------
local function OnUpdate(_, update)
	elapsed = elapsed + update
	if elapsed > 0.05 then
		for i, v in pairs(watching) do
			if GetTime() >= v.time + 0.5 then
				local name, texture, start, duration, enabled, isPet
				if v.type == "spell" then
					name = C_Spell_GetSpellName(v.id)
					texture = C_Spell_GetSpellTexture(v.id)
					local cdInfo = C_Spell_GetSpellCooldown(v.id)
					if cdInfo then
						start, duration, enabled = cdInfo.startTime, cdInfo.duration, cdInfo.isEnabled and 1 or 0
					else
						start, duration, enabled = 0, 0, 0
					end
				elseif v.type == "item" then
					name = C_Item_GetItemInfo(i)
					texture = v.id -- we store the texture as the ID for items
					start, duration, enabled = C_Item_GetItemCooldown(i)
				elseif v.type == "pet" then
					name, texture = GetPetActionInfo(v.id)
					start, duration, enabled = GetPetActionCooldown(v.id)
					isPet = true
				end

				if name and pulse_ignored_spells[name] then
					ReleaseTable(v)
					watching[i] = nil
				else
					if enabled ~= 0 then
						if duration and duration > C["ActionBar"].PulseCDThreshold and texture then
							local cd = GetTable()
							cd.name = name
							cd.texture = texture
							cd.start = start
							cd.duration = duration
							cd.isPet = isPet
							cd.type = v.type
							cd.id = v.id
							cooldowns[i] = cd
						end
					end
					if not (enabled == 0 and v.type == "spell") then
						ReleaseTable(v)
						watching[i] = nil
					end
				end
			end
		end

		for i, cd in pairs(cooldowns) do
			local remaining = cd.duration - (GetTime() - cd.start)
			if remaining <= 0.2 then
				local anim = GetTable()
				anim.texture = cd.texture
				anim.isPet = cd.isPet
				anim.name = cd.name
				table_insert(animating, anim)
				ReleaseTable(cd)
				cooldowns[i] = nil
			end
		end

		elapsed = 0
		if #animating == 0 and tcount(watching) == 0 and tcount(cooldowns) == 0 then
			Module.PulseFrame:SetScript("OnUpdate", nil)
			return
		end
	end

	if #animating > 0 then
		runtimer = runtimer + update
		if runtimer > (fadeInTime + C["ActionBar"].PulseCDHoldTime + fadeOutTime) then
			local anim = table_remove(animating, 1)
			ReleaseTable(anim)
			runtimer = 0
			Module.PulseIcon:SetTexture(nil)
			if Module.PulseFrame.KKUI_Border then
				Module.PulseFrame.KKUI_Border:SetVertexColor(0, 0, 0, 0)
			end
			if Module.PulseFrame.KKUI_Background then
				Module.PulseFrame.KKUI_Background:SetVertexColor(0, 0, 0, 0)
			end
		else
			if not Module.PulseIcon:GetTexture() then
				Module.PulseIcon:SetTexture(animating[1].texture)
				if C["ActionBar"].PulseCDSound then
					PlaySoundFile(567439, "Master")
				end
			end
			local alpha = maxAlpha
			if runtimer < fadeInTime then
				alpha = maxAlpha * (runtimer / fadeInTime)
			elseif runtimer >= fadeInTime + C["ActionBar"].PulseCDHoldTime then
				alpha = maxAlpha - (maxAlpha * ((runtimer - C["ActionBar"].PulseCDHoldTime - fadeInTime) / fadeOutTime))
			end
			Module.PulseFrame:SetAlpha(alpha)
			local scale = C["ActionBar"].PulseCDSize + (C["ActionBar"].PulseCDSize * ((C["ActionBar"].PulseCDAnimScale - 1) * (runtimer / (fadeInTime + C["ActionBar"].PulseCDHoldTime + fadeOutTime))))
			Module.PulseFrame:SetWidth(scale)
			Module.PulseFrame:SetHeight(scale)
			if Module.PulseFrame.KKUI_Border then
				Module.PulseFrame.KKUI_Border:SetVertexColor(1, 1, 1, 1)
			end
			if Module.PulseFrame.KKUI_Background then
				Module.PulseFrame.KKUI_Background:SetVertexColor(0, 0, 0, 0.8)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreatePulseCD()
	if not C["ActionBar"].PulseCD then
		return
	end

	local anchor = CreateFrame("Frame", "KKUI_PulseCDAnchor", UIParent)
	anchor:SetSize(C["ActionBar"].PulseCDSize, C["ActionBar"].PulseCDSize)
	K.Mover(anchor, "PulseCD", "PulseCD", { "CENTER", UIParent, "CENTER", 0, 0 })

	local frame = CreateFrame("Frame", "KKUI_PulseCDFrame", anchor)
	frame:SetPoint("CENTER", anchor, "CENTER")
	frame:SetSize(C["ActionBar"].PulseCDSize, C["ActionBar"].PulseCDSize)
	frame:CreateBorder()
	frame:SetAlpha(0)

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetAllPoints()

	Module.PulseFrame = frame
	Module.PulseIcon = icon

	-- Events
	K:RegisterEvent("SPELL_UPDATE_COOLDOWN", function()
		for i, cd in pairs(cooldowns) do
			if cd.type == "spell" then
				local cdInfo = C_Spell_GetSpellCooldown(cd.id)
				if cdInfo and cdInfo.startTime then
					cd.start = cdInfo.startTime
					cd.duration = cdInfo.duration
				end
			elseif cd.type == "item" then
				local start, duration = C_Item_GetItemCooldown(i)
				if start then
					cd.start = start
					cd.duration = duration
				end
			elseif cd.type == "pet" then
				local start, duration = GetPetActionCooldown(cd.id)
				if start then
					cd.start = start
					cd.duration = duration
				end
			end
		end
	end)

	K:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", function(_, unit, _, spellID)
		if unit == "player" then
			local texture = C_Spell_GetSpellTexture(spellID)
			local t1 = GetInventoryItemTexture("player", 13)
			local t2 = GetInventoryItemTexture("player", 14)
			if texture == t1 or texture == t2 then
				return
			end -- Fix wrong buff cd for trinket
			local w = GetTable()
			w.time = GetTime()
			w.type = "spell"
			w.id = spellID
			watching[spellID] = w
			frame:SetScript("OnUpdate", OnUpdate)
		end
	end)

	K:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(_, _, eventType, _, _, _, sourceFlags, _, _, _, _, _, spellID)
		if eventType == "SPELL_CAST_SUCCESS" then
			if bit_band(sourceFlags, COMBATLOG_OBJECT_TYPE_PET) == COMBATLOG_OBJECT_TYPE_PET and bit_band(sourceFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE then
				local name = C_Spell_GetSpellName(spellID)
				local index = GetPetActionIndexByName(name)
				if index and not select(7, GetPetActionInfo(index)) then
					local w = GetTable()
					w.time = GetTime()
					w.type = "pet"
					w.id = index
					watching[spellID] = w
				elseif not index and spellID then
					local w = GetTable()
					w.time = GetTime()
					w.type = "spell"
					w.id = spellID
					watching[spellID] = w
				else
					return
				end
				frame:SetScript("OnUpdate", OnUpdate)
			end
		end
	end)

	K:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		local _, instanceType = IsInInstance()
		if instanceType == "arena" then
			frame:SetScript("OnUpdate", nil)
			for i, v in pairs(cooldowns) do
				ReleaseTable(v)
				cooldowns[i] = nil
			end
			for i, v in pairs(watching) do
				ReleaseTable(v)
				watching[i] = nil
			end
		end
	end)

	hooksecurefunc("UseAction", function(slot)
		local actionType, itemID = GetActionInfo(slot)
		if actionType == "item" then
			local texture = GetActionTexture(slot)
			local w = GetTable()
			w.time = GetTime()
			w.type = "item"
			w.id = texture
			watching[itemID] = w
		end
	end)

	hooksecurefunc("UseInventoryItem", function(slot)
		local itemID = GetInventoryItemID("player", slot)
		if itemID then
			local texture = GetInventoryItemTexture("player", slot)
			local w = GetTable()
			w.time = GetTime()
			w.type = "item"
			w.id = texture
			watching[itemID] = w
		end
	end)

	SlashCmdList.PulseCD = function()
		local anim = GetTable()
		anim.texture = C_Spell_GetSpellTexture(87214)
		table_insert(animating, anim)
		if C["ActionBar"].PulseCDSound then
			PlaySoundFile(567439, "Master")
		end
		frame:SetScript("OnUpdate", OnUpdate)
	end
	SLASH_PulseCD1 = "/pulsecd"
end
