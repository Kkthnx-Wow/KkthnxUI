local _, ns = ...
local oUF = ns.oUF or oUF
local K, C = unpack(select(2, ...))

local _G = _G
local math_floor = _G.math.floor
local math_fmod = _G.math.fmod
local string_format = _G.string.format

local GetTime = _G.GetTime

local PortraitTimerDB = {}
local day, hour, minute = 86400, 3600, 60

do
	local function add(list, filter)
		for i = 1, #list do
			PortraitTimerDB[list[i]] = true
		end
    end

	add(C.PTAuras_Immunity, "HELPFUL")
	add(C.PTAuras_Stun, "HARMFUL")
	add(C.PTAuras_CC, "HARMFUL")
	add(C.PTAuras_CCImmunity, "HELPFUL")
	add(C.PTAuras_Defensive, "HELPFUL")
	add(C.PTAuras_Offensive, "HELPFUL")
	add(C.PTAuras_Helpful, "HELPFUL")
	add(C.PTAuras_Silence, "HARMFUL")
	add(C.PTAuras_Misc, "HELPFUL")
end

local function ExactTime(time)
	return string_format("%.1f", time), (time * 100 - math_floor(time * 100))/100
end

local function FormatTime(s)
	if (s >= day) then
		return string_format("%dd", math_floor(s/day + 0.5))
	elseif (s >= hour) then
		return string_format("%dh", math_floor(s/hour + 0.5))
	elseif (s >= minute) then
		return string_format("%dm", math_floor(s/minute + 0.5))
	end

	return string_format("%d", math_fmod(s, minute))
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

local Update = function(self, _, unit)
	if (self.unit ~= unit) then
		return
	end

	local pt = self.PortraitTimer
	local UnitDebuff, index = UnitDebuff, 0
	while (true) do
		index = index + 1
		local name, texture, _, _, duration, expires, _, _, _, spellId = (UnitDebuff or UnitBuff)(unit, index)
		if name then
			if PortraitTimerDB[spellId] then
                if (pt.texture ~= texture) then
                    pt.Icon:SetTexture(texture)
                    pt.Icon:SetTexCoord(unpack(K.TexCoords))
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
				break
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