local K = unpack(KkthnxUI)
local oUF = K.oUF

local _G = _G
local addon = {}

K.oUF_RaidDebuffs = addon
_G.oUF_RaidDebuffs = K.oUF_RaidDebuffs
if not _G.oUF_RaidDebuffs then
	_G.oUF_RaidDebuffs = addon
end

local type = _G.type
local pairs = _G.pairs
local wipe = _G.wipe

local GetSpecialization = _G.GetSpecialization
local GetSpellInfo = _G.GetSpellInfo
local UnitAura = _G.UnitAura
local UnitCanAttack = _G.UnitCanAttack
local UnitIsCharmed = _G.UnitIsCharmed

local debuff_data = {}
addon.DebuffData = debuff_data
addon.ShowDispellableDebuff = true
addon.FilterDispellableDebuff = true
addon.MatchBySpellName = false
addon.priority = 10

local function add(spell, priority, stackThreshold)
	if addon.MatchBySpellName and type(spell) == "number" then
		spell = GetSpellInfo(spell)
	end

	if spell then
		debuff_data[spell] = {
			priority = (addon.priority + priority),
			stackThreshold = (stackThreshold or 0),
		}
	end
end

function addon:RegisterDebuffs(t)
	for spell in pairs(t) do
		if type(t[spell]) == "boolean" then
			local oldValue = t[spell]
			t[spell] = { enable = oldValue, priority = 0, stackThreshold = 0 }
		else
			if t[spell].enable then
				add(spell, t[spell].priority, t[spell].stackThreshold)
			end
		end
	end
end

function addon:ResetDebuffData()
	wipe(debuff_data)
end

local DispellColor = {
	["Magic"] = { 0.2, 0.6, 1 },
	["Curse"] = { 0.6, 0, 1 },
	["Disease"] = { 0.6, 0.4, 0 },
	["Poison"] = { 0, 0.6, 0 },
	["none"] = { 1, 1, 1 },
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
		["DRUID"] = {
			["Magic"] = false,
			["Curse"] = true,
			["Poison"] = true,
		},
		["MONK"] = {
			["Magic"] = true,
			["Poison"] = true,
			["Disease"] = true,
		},
		["PALADIN"] = {
			["Magic"] = false,
			["Poison"] = true,
			["Disease"] = true,
		},
		["PRIEST"] = {
			["Magic"] = true,
			["Disease"] = true,
		},
		["SHAMAN"] = {
			["Magic"] = false,
			["Curse"] = true,
		},
		["MAGE"] = {
			["Curse"] = true,
		},
	}

	DispellFilter = dispellClasses[K.Class] or {}
end

local function CheckSpec()
	if K.Class == "DRUID" then
		if GetSpecialization() == 4 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif K.Class == "MONK" then
		if GetSpecialization() == 2 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif K.Class == "PALADIN" then
		if GetSpecialization() == 1 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	elseif K.Class == "SHAMAN" then
		if GetSpecialization() == 3 then
			DispellFilter.Magic = true
		else
			DispellFilter.Magic = false
		end
	end
end

local function UpdateDebuff(self, name, icon, count, debuffType, duration, expiration, _, stackThreshold)
	local rd = self.RaidDebuffs

	if name and (count >= stackThreshold) then
		rd.icon:SetTexture(icon)
		rd.icon:Show()
		rd.duration = duration

		if rd.count then
			if count and count > 1 then
				rd.count:SetText(count)
				rd.count:Show()
			else
				rd.count:SetText("")
				rd.count:Hide()
			end
		end

		if rd.timer then
			rd.duration = duration
			if duration and duration > 0 and rd:GetSize() > 20 then
				rd.expiration = expiration
				rd.nextUpdate = 0
				rd:SetScript("OnUpdate", K.CooldownOnUpdate)
				rd.timer:Show()
			else
				rd:SetScript("OnUpdate", nil)
				rd.timer:Hide()
			end
		end

		if rd.cd then
			if duration and duration > 0 then
				rd.cd:SetCooldown(expiration - duration, duration)
				rd.cd:Show()
			else
				rd.cd:Hide()
			end
		end

		local c = DispellColor[debuffType] or DispellColor.none
		if rd.KKUI_Border then
			rd.KKUI_Border:SetVertexColor(c[1], c[2], c[3])
		end

		rd:Show()
	else
		rd:Hide()
	end
end

local function Update(self, _, unit)
	if unit ~= self.unit then
		return
	end

	local rd = self.RaidDebuffs
	local _name, _icon, _count, _dtype, _duration, _endTime, _spellId, _
	local _priority, priority = 0, 0
	local _stackThreshold = 0

	-- store if the unit its charmed, mind controlled units (Imperial Vizier Zor'lok: Convert)
	local isCharmed = UnitIsCharmed(unit)
	-- store if we cand attack that unit, if its so the unit its hostile (Amber-Shaper Un'sok: Reshape Life)
	local canAttack = UnitCanAttack("player", unit)
	for i = 1, 40 do
		local name, icon, count, debuffType, duration, expirationTime, _, _, _, spellId = UnitAura(unit, i, "HARMFUL")
		if not name then
			break
		end

		-- we coudln't dispell if the unit its charmed, or its not friendly
		if addon.ShowDispellableDebuff and (rd.showDispellableDebuff ~= false) and debuffType and not isCharmed and not canAttack then
			if addon.FilterDispellableDebuff then
				DispellPriority[debuffType] = (DispellPriority[debuffType] or 0) + addon.priority -- Make Dispell buffs on top of Boss Debuffs
				priority = DispellFilter[debuffType] and DispellPriority[debuffType] or 0
				if priority == 0 then
					debuffType = nil
				end
			else
				priority = DispellPriority[debuffType] or 0
			end

			if priority > _priority then
				_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
			end
		end

		local debuff
		if rd.onlyMatchSpellID then
			debuff = debuff_data[spellId]
		else
			if debuff_data[spellId] then
				debuff = debuff_data[spellId]
			else
				debuff = debuff_data[name]
			end
		end

		priority = debuff and debuff.priority
		if priority and not rd.BlackList[spellId] and (priority > _priority) then
			_priority, _name, _icon, _count, _dtype, _duration, _endTime, _spellId = priority, name, icon, count, debuffType, duration, expirationTime, spellId
		end
	end

	if rd.forceShow then
		_spellId = 47540
		_name, _, _icon = GetSpellInfo(_spellId)
		_count, _dtype, _duration, _endTime, _stackThreshold = 5, "Magic", 0, 60, 0
	end

	if _name then
		_stackThreshold = debuff_data[addon.MatchBySpellName and _name or _spellId] and debuff_data[addon.MatchBySpellName and _name or _spellId].stackThreshold or _stackThreshold
	end

	UpdateDebuff(self, _name, _icon, _count, _dtype, _duration, _endTime, _spellId, _stackThreshold)

	-- Reset the DispellPriority
	DispellPriority["Magic"] = 4
	DispellPriority["Curse"] = 3
	DispellPriority["Disease"] = 2
	DispellPriority["Poison"] = 1
end

local function Enable(self)
	local rd = self.RaidDebuffs
	if rd then
		self:RegisterEvent("UNIT_AURA", Update)

		rd.BlackList = rd.BlackList or {
				[105171] = true, -- Deep Corruption
				[108220] = true, -- Deep Corruption
				[116095] = true, -- Disable, Slow
				[137637] = true, -- Warbringer, Slow
			}

		return true
	end

	CheckSpec()
	self:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec, true)
end

local function Disable(self)
	if self.RaidDebuffs then
		self:UnregisterEvent("UNIT_AURA", Update)
		self.RaidDebuffs:Hide()
	end

	self:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec, true)
end

oUF:AddElement("RaidDebuffs", Update, Enable, Disable)
