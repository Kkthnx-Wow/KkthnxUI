local K, C, L = unpack(select(2, ...))
local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

local GetTime, GetSpellInfo, UnitAura = GetTime, GetSpellInfo, UnitAura
local floor, fmod = floor, math.fmod
local day, hour, minute = 86400, 3600, 60

local PortraitTimerDB = {}

do
	local function add(list, filter)
		for i = 1, #list do
			PortraitTimerDB[list[i]] = true
		end
	end
	add(K.AuraList.CC, "HARMFUL")
	add(K.AuraList.CCImmunity, "HELPFUL")
	add(K.AuraList.Defensive, "HELPFUL")
	add(K.AuraList.Helpful, "HELPFUL")
	add(K.AuraList.Immunity, "HELPFUL")
	add(K.AuraList.Misc, "HELPFUL")
	add(K.AuraList.Offensive, "HELPFUL")
	add(K.AuraList.Silence, "HARMFUL")
	add(K.AuraList.Stun, "HARMFUL")
end

local function ExactTime(time)
	return format("%.1f", time), (time * 100 - floor(time * 100))/100
end

local function FormatTime(s)
	if (s >= day) then
		return format("%dd", floor(s/day + 0.5))
	elseif (s >= hour) then
		return format("%dh", floor(s/hour + 0.5))
	elseif (s >= minute) then
		return format("%dm", floor(s/minute + 0.5))
	end

	return format("%d", fmod(s, minute))
end

local function AuraTimer(self, elapsed)
	self.elapsed = (self.elapsed or 0) + elapsed

	if (self.elapsed < 0.1) then
		return
	end

	self.elapsed = 0

	local timeLeft = self.expires - GetTime()
	if (timeLeft <= 0) then
		self.Remaining:SetText(nil)
	else
		if (timeLeft <= 5) then
			self.Remaining:SetText("|cffff0000"..ExactTime(timeLeft).."|r")
		else
			self.Remaining:SetText(FormatTime(timeLeft))
		end
	end
end

local Update = function(self, event, unit)
	if (self.unit ~= unit) then
		return
	end

	local pt = self.PortraitTimer
	local UnitDebuff, index = UnitDebuff, 0
	while (true) do
		index = index + 1
		local name, _, texture, _, _, duration, expires, _, _, _, spellId = (UnitDebuff or UnitBuff)(unit, index)
		if name then
			if PortraitTimerDB[spellId] then

				if (pt.texture ~= texture) then
					SetPortraitToTexture(pt.Icon, texture)
					pt.texture = texture
				end

				if (pt.expires ~= expires) or (pt.duration ~= duration) then
					pt.expires = expires
					pt.duration = duration
					pt:SetScript("OnUpdate", AuraTimer)
				end

				pt:Show()

				if (self.CombatFeedbackText) then
					self.CombatFeedbackText.maxAlpha = 0
				end

				return
			end
		else
			if UnitDebuff then
				UnitDebuff = nil
				index = 0
			else
				break;
			end
		end
	end
	if (pt:IsShown()) then
		pt:Hide()
	end

	if (self.CombatFeedbackText) then
		self.CombatFeedbackText.maxAlpha = 1
	end
end

local Enable = function(self)
	local pt = self.PortraitTimer
	if (pt) then
		self:RegisterEvent("UNIT_AURA", Update)
		return true
	end
end

local Disable = function(self)
	local pt = self.PortraitTimer
	if (pt) then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement("PortraitTimer", Update, Enable, Disable)