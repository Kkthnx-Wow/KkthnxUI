--[=[
.icon [texture]
.count [fontstring]
.cd [cooldown]

.ShowBossDebuff [boolean]
.BossDebuffPriority [number]

.ShowDispelableDebuff [boolean]
.DispelPriority [table] { [type] = prio }
.DispelFilter [table] { [type] = true }
.DebuffTypeColor [table] { [type] = { r, g, b } }

.Debuffs [table] { [name(string)|id(number)] = prio(number) }
.MatchBySpellName [boolean]

.SetDebuffTypeColor [function] function(r, g, b) end
--]=]

local K, C, L = unpack(select(2, ...))
local _, ns = ...
local oUF = ns.oUF or oUF

local bossDebuffPrio = 9999999
local invalidPrio = -1
local auraFilters = {
	["HARMFUL"] = true,
}

local DispellColor = {
	["Magic"]	= {0.2, 0.6, 1},
	["Curse"]	= {0.6, 0, 1},
	["Disease"]	= {0.6, 0.4, 0},
	["Poison"]	= {0, 0.6, 0},
	["none"]	= {1, 1, 1},
}

DispellColor.none = {1, 0, 0}

local DispellPriority = {
	["Magic"]	= 4,
	["Curse"]	= 3,
	["Disease"]	= 2,
	["Poison"]	= 1,
}

local DispellFilter
do
	local dispellClasses = {
		["DRUID"] = {
			["Magic"] = false,
			["Curse"] = true,
			["Poison"] = true,
		},
		["MONK"] = {
			["Magic"] = false,
			["Poison"] = true,
			["Disease"] = true,
		},
		["PALADIN"] = {
			["Magic"] = false,
			["Poison"] = true,
			["Disease"] = true,
		},
		["PRIEST"] = {
			["Magic"] = false,
			["Disease"] = false,
		},
		["SHAMAN"] = {
			["Magic"] = false,
			["Curse"] = true,
		},
	}

	DispellFilter = dispellClasses[K.Class] or {}
end

local function CheckSpec()
	if K.Class == "DRUID" then
		if K.Spec == 4 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif K.Class == "MONK" then
		if K.Spec == 2 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif K.Class == "PALADIN" then
		if K.Spec == 1 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif K.Class == "PRIEST" then
		if K.Spec == 3 then
			DispellFilter.Magic = false
			DispellFilter.Disease = false
		else
			DispellFilter.Magic = true
			DispellFilter.Disease = true
		end
	elseif K.Class == "SHAMAN" then
		if K.Spec == 3 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	end
end

local function formatTime(s)
	if s > 60 then
		return format("%dm", s/60), s%60
	elseif s < 1 then
		return format("%.1f", s), s - floor(s)
	else
		return format("%d", s), s - floor(s)
	end
end

local abs = math.abs
local function OnUpdate(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.expirationTime - GetTime()
		if self.reverse then timeLeft = abs((self.expirationTime - GetTime()) - self.duration) end
		if timeLeft > 0 then
			local text = formatTime(timeLeft)
			self.time:SetText(text)
		else
			self:SetScript("OnUpdate", nil)
			self.time:Hide()
		end
		self.elapsed = 0
	end
end

local UpdateDebuffFrame = function(rd)
	if rd.index and rd.type and rd.filter then
		local name, rank, icon, count, debuffType, duration, expirationTime, _, _, _, spellId, _, isBossDebuff = UnitAura(rd.__owner.unit, rd.index, rd.filter)

		if rd.icon then
			rd.icon:SetTexture(icon)
			rd.icon:Show()
		end

		if rd.count then
			if count and (count > 1) then
				rd.count:SetText(count)
				rd.count:Show()
			else
				rd.count:Hide()
			end
		end

		if spellId and K.RaidDebuffsReverse[spellId] then
			rd.reverse = true
		else
			rd.reverse = nil
		end

		if rd.time then
			rd.duration = duration
			if duration and (duration > 0) then
				rd.expirationTime = expirationTime
				rd.nextUpdate = 0
				rd:SetScript("OnUpdate", OnUpdate)
				rd.time:Show()
			else
				rd:SetScript("OnUpdate", nil)
				rd.time:Hide()
			end
		end

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

		if not rd:IsShown() then
			rd:Show()
		end
	else
		if rd:IsShown() then
			rd:Hide()
		end
	end
end

local Update = function(self, event, unit)
	if unit ~= self.unit then return end
	local rd = self.RaidDebuffs
	rd.priority = invalidPrio

	for filter in next, (rd.Filters or auraFilters) do
		local i = 0
		while(true) do
			i = i + 1
			local name, rank, icon, count, debuffType, duration, expirationTime, _, _, _, spellId, _, isBossDebuff = UnitAura(unit, i, filter)
			if not name then break end

			if rd.ShowBossDebuff and isBossDebuff then
				local prio = rd.BossDebuffPriority or bossDebuffPrio
				if prio and prio > rd.priority then
					rd.priority = prio
					rd.index = i
					rd.type = "Boss"
					rd.filter = filter
				end
			end

			if rd.ShowDispellableDebuff and debuffType then
				local disPrio = rd.DispellPriority or DispellPriority
				local disFilter = rd.DispellFilter or DispellFilter
				local prio

				if rd.FilterDispellableDebuff and disFilter then
					prio = disFilter[debuffType] and disPrio[debuffType]
				else
					prio = disPrio[debuffType]
				end

				if prio and (prio > rd.priority) then
					rd.priority = prio
					rd.index = i
					rd.type = "Dispel"
					rd.filter = filter
				end
			end

			local prio = rd.Debuffs and rd.Debuffs[rd.MatchBySpellName and name or spellId]
			local prioPvP

			if C.Raidframe.PvPDebuffs == true then
			prioPvP = rd.Debuffs and K.PvPDebuffs[rd.MatchBySpellName and name or spellId]
			end

			if not K.RaidDebuffsIgnore[spellId] and (prio and (prio > rd.priority) or prioPvP and (prioPvP > rd.priority)) then
				if (prio and not prioPvP) or ((prio and prioPvP) and prio > prioPvP) then
					rd.priority = prio
				else
					rd.priority = prioPvP
				end
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

local Enable = function(self)
	local rd = self.RaidDebuffs
	if rd then
		self:RegisterEvent("UNIT_AURA", Path)
		rd.ForceUpdate = ForceUpdate
		rd.__owner = self
		return true
	end
	self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
	CheckSpec()
end

local Disable = function(self)
	if self.RaidDebuffs then
		self:UnregisterEvent("UNIT_AURA", Path)
		self.RaidDebuffs:Hide()
		self.RaidDebuffs.__owner = nil
	end
	self:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
end

oUF:AddElement("RaidDebuffs", Update, Enable, Disable)