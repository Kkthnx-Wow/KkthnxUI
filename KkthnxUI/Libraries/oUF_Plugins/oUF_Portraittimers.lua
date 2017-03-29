local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

-- Lua API
local math_floor = math.floor
local math_fmod = math.fmod
local string_format = string.format
local math_ceil = math.ceil

-- Wow API
local UnitBuff = _G.UnitBuff
local UnitDebuff = _G.UnitDebuff
local GetTime = _G.GetTime

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SetPortraitToTexture

local PortraitTimerDB = {}

do
	local function AddFilterList(list, filter)
		for i = 1, #list do
			PortraitTimerDB[list[i]] = true
		end
	end
	AddFilterList(K.AuraList.CC, "HARMFUL")
	AddFilterList(K.AuraList.CCImmunity, "HELPFUL")
	AddFilterList(K.AuraList.Defensive, "HELPFUL")
	AddFilterList(K.AuraList.Helpful, "HELPFUL")
	AddFilterList(K.AuraList.Immunity, "HELPFUL")
	AddFilterList(K.AuraList.Misc, "HELPFUL")
	AddFilterList(K.AuraList.Offensive, "HELPFUL")
	AddFilterList(K.AuraList.Silence, "HARMFUL")
	AddFilterList(K.AuraList.Stun, "HARMFUL")
end

local function ExactTime(time)
	return string_format("%.1f", time), (time * 100 - math_floor(time * 100))/100
end

local function FormatTime(time)
	local Day, Hour, Minute = 86400, 3600, 60

	if (time >= Day) then
		return string_format("%dd", math_ceil(time / Day))
	elseif (time >= Hour) then
		return string_format("%dh", math_ceil(time / Hour))
	elseif (time >= Minute) then
		return string_format("%dm", math_ceil(time / Minute))
	elseif (time >= Minute / 12) then
		return math_floor(time)
	end

	return string_format("%.1f", time)
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
		if (timeLeft <= 3) then
			self.Remaining:SetText("|cffff0000"..ExactTime(timeLeft).."|r")
		else
			self.Remaining:SetText("|cfffefefe"..FormatTime(timeLeft).."|r")
		end
	end
end

local function Update(self, event, unit)
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