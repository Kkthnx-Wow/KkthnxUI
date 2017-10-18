local _, ns = ...
local oUF = ns.oUF
if not oUF then return end

-- Lua API
local _G = _G
local math_abs = math.abs
local math_floor = math.floor
local select = select
local string_format = string.format

-- WoW API
local GetActiveSpecGroup = _G.GetActiveSpecGroup
local GetSpecialization = _G.GetSpecialization
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitIsCharmed = _G.UnitIsCharmed

local SymbiosisName = GetSpellInfo(110309)
local CleanseName = GetSpellInfo(4987)

local bossDebuffPrio = 9999999
local invalidPrio = -1
local auraFilters = {
	["HARMFUL"] = true,
}

local DispellColor = {
	["Magic"] = {0.2, 0.6, 1},
	["Curse"] = {0.6, 0, 1},
	["Disease"] = {0.6, 0.4, 0},
	["Poison"] = {0, 0.6, 0},
	["none"] = {1, 1, 1},
}

local DispellPriority = {
	["Magic"] = 4,
	["Curse"] = 3,
	["Disease"] = 2,
	["Poison"] = 1,
}

local DispellFilter
do
	local dispellClasses = {
		['PRIEST'] = {
			['Magic'] = true,
			['Disease'] = true,
		},
		['SHAMAN'] = {
			['Magic'] = false,
			['Curse'] = true,
		},
		['PALADIN'] = {
			['Poison'] = true,
			['Magic'] = false,
			['Disease'] = true,
		},
		['DRUID'] = {
			['Magic'] = false,
			['Curse'] = true,
			['Poison'] = true,
			['Disease'] = false,
		},
		['MONK'] = {
			['Magic'] = false,
			['Disease'] = true,
			['Poison'] = true,
		},
	}

	DispellFilter = dispellClasses[select(2, UnitClass('player'))] or {}
end

local function CheckTalentTree(tree)
	local activeGroup = GetActiveSpecGroup()
	if activeGroup and GetSpecialization(false, false, activeGroup) then
		return tree == GetSpecialization(false, false, activeGroup)
	end
end

local playerClass = select(2, UnitClass('player'))
local function CheckSpec(self, event, levels)
	-- Not interested in gained points from leveling
	if event == "CHARACTER_POINTS_CHANGED" and levels > 0 then return end

	-- Check for certain talents to see if we can dispel magic or not
	if playerClass == "PALADIN" then
		if CheckTalentTree(1) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif playerClass == "SHAMAN" then
		if CheckTalentTree(3) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif playerClass == "DRUID" then
		if CheckTalentTree(4) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif playerClass == "MONK" then
		if CheckTalentTree(2) then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	end
end

local function CheckSymbiosis()
	if GetSpellInfo(SymbiosisName) == CleanseName then
		DispellFilter.Disease = true
	else
		DispellFilter.Disease = false
	end
end

local function formatTime(s)
	if s > 60 then
		return string_format('%dm', s / 60), s%60
	elseif s < 1 then
		return string_format("%.1f", s), s - math_floor(s)
	else
		return string_format('%d', s), s - math_floor(s)
	end
end

local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.endTime - GetTime()
		if timeLeft > 0 then
			local text = formatTime(timeLeft)
			self.time:SetText(text)
		else
			self:SetScript('OnUpdate', nil)
			self.time:Hide()
		end
		self.elapsed = 0
	end
end

local UpdateDebuffFrame = function(rd)
	if rd.index and rd.type and rd.filter then
		local name, rank, icon, count, debuffType, duration, expirationTime, _, _, _, spellId, _, isBossDebuff = UnitAura(rd.__owner.unit, rd.index, rd.filter)

		rd.duration = duration

		if rd.icon then
			rd.icon:SetTexture(icon)
			rd.icon:Show()
		end

		if rd.count then
			if (count and (count > 0)) then
				rd.count:SetText(count)
				rd.count:Show()
			else
				rd.count:SetText("")
				rd.count:Hide()
			end
		end

		-- if rd.time then
		-- 	if duration and (duration > 0) then
		-- 		rd.expirationTime = expirationTime
		-- 		rd.nextUpdate = 0
		-- 		rd:SetScript("OnUpdate", OnUpdate)
		-- 		rd.time:Show()
		-- 	else
		-- 		rd:SetScript("OnUpdate", nil)
		-- 		rd.time:Hide()
		-- 	end
		-- end

		if rd.cd then
			if duration and (duration > 0) then
				rd.cd:SetCooldown(expirationTime - duration, duration)
				rd.cd:Show()
			else
				rd.cd:Hide()
			end
		end

		local c = DispellColor[debuffType] or DispellColor.none
		rd:SetBackdropBorderColor(c[1], c[2], c[3])

		if (not rd:IsShown()) then
			rd:Show()
		end
	else
		if (rd:IsShown()) then
			rd:Hide()
		end
	end
end

local Update = function(self, event, unit)
	if unit ~= self.unit then return end
	local rd = self.RaidDebuffs
	rd.priority = invalidPrio

	-- store if the unit its charmed, mind controlled units (Imperial Vizier Zor'lok: Convert)
	local isCharmed = UnitIsCharmed(unit)

	-- store if we cand attack that unit, if its so the unit its hostile (Amber-Shaper Un'sok: Reshape Life)
	local canAttack = UnitCanAttack("player", unit)

	for filter in next, (rd.Filters or auraFilters) do
		local i = 0
		while true do
			i = i + 1
			local name, rank, icon, count, debuffType, duration, expirationTime, _, _, _, spellId, _, isBossDebuff = UnitAura(unit, i, filter)
			if not name then break end

			if rd.ShowBossDebuff and isBossDebuff and (filter == "HARMFUL") then
				local prio = rd.BossDebuffPriority or bossDebuffPrio
				if prio and prio > rd.priority then
					rd.priority = prio
					rd.index = i
					rd.type = "Boss"
					rd.filter = filter
				end
			end

			if (rd.ShowDispellableDebuff ~= false) and debuffType and (not isCharmed) and (not canAttack) then
				local disPrio = rd.DispellPriority or DispellPriority
				local disFilter = rd.DispellFilter or DispellFilter
				local prio

				if rd.FilterDispellableDebuff and disFilter then
					prio = disFilter[debuffType] and disPrio[debuffType]
				else
					prio = disPrio[debuffType] or 0
				end

				if prio and (prio > rd.priority) then
					rd.priority = prio
					rd.index = i
					rd.type = "Dispel"
					rd.filter = filter
				end
			end

			local prio = rd.Debuffs and rd.Debuffs[rd.MatchBySpellName and name or spellId]
			if (prio and (prio > rd.priority)) then
				rd.priority = prio
				rd.index = i
				rd.type = "Custom"
				rd.filter = filter
			end
		end
	end

	if rd.priority == invalidPrio then
		rd.index = nil
		rd.filter = nil
		rd.type = nil
	end

	return UpdateDebuffFrame(rd)
end

local Path = function(self, ...)
	return (self.RaidDebuffs.Override or Update) (self, ...)
end

local ForceUpdate = function(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	if self.RaidDebuffs then
		self:RegisterEvent('UNIT_AURA', Update)
		self.RaidDebuffs.ForceUpdate = ForceUpdate
		self.RaidDebuffs.__owner = self
		return true
	end
	-- Need to run these always
	self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	self:RegisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
	if playerClass == "DRUID" then
		self:RegisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end
end

local function Disable(self)
	if self.RaidDebuffs then
		self:UnregisterEvent('UNIT_AURA', Update)
		self.RaidDebuffs:Hide()
		self.RaidDebuffs.__owner = nil
	end
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	self:UnregisterEvent("CHARACTER_POINTS_CHANGED", CheckSpec)
	if playerClass == "DRUID" then
		self:UnregisterEvent("SPELLS_CHANGED", CheckSymbiosis)
	end
end

oUF:AddElement('RaidDebuffs', Update, Enable, Disable)