local K, C = unpack(select(2, ...))

-- Sourced: ElvUI (Elvz)

local _G = _G
local pairs = _G.pairs
local type = _G.type

local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitCastingInfo = _G.UnitCastingInfo
local UnitChannelInfo = _G.UnitChannelInfo
local UnitExists = _G.UnitExists
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax

local frames, allFrames = {}, {}
local showStatus

local function CheckForReset()
	for frame, _ in pairs(allFrames) do
		if frame.fadeInfo and frame.fadeInfo.reset then
			frame:SetAlpha(1)
			frame.fadeInfo.reset = nil
		end
	end
end

local function FadeFramesInOut(fade, unit)
	for frame, _ in pairs(frames) do
		if not UnitExists(unit) then
			return
		end
		if fade then
			if frame:GetAlpha() ~= 1 or (frame.fadeInfo and frame.fadeInfo.endAlpha == 0) then
				UIFrameFadeIn(frame, 0.2, frame:GetAlpha(), 1)
			end
		else
			if frame:GetAlpha() ~= 0 then
				UIFrameFadeOut(frame, 0.2, frame:GetAlpha(), C["General"].GlobalFade)
				frame.fadeInfo.finishedFunc = CheckForReset
			else
				showStatus = false
				return
			end
		end
	end

	if unit == "player" then
		showStatus = fade
	end
end

local function Update(self, arg1, arg2)
	if arg1 == "UNIT_HEALTH" and self and self.unit ~= arg2 then
		return
	end

	if type(arg1) == "boolean" and not frames[self] then
		return
	end

	if not frames[self] then
		UIFrameFadeIn(self, 0.15, self:GetAlpha(), 1)
		self.fadeInfo.reset = true
		return
	end

	local combat = UnitAffectingCombat("player")
	local cur, max = UnitHealth("player"), UnitHealthMax("player")
	local cast, channel = UnitCastingInfo("player"), UnitChannelInfo("player")
	local target, focus = UnitExists("target"), UnitExists("focus")

	if (cast or channel) and showStatus ~= true then
		FadeFramesInOut(true, frames[self])
	elseif cur ~= max and showStatus ~= true then
		FadeFramesInOut(true, frames[self])
	elseif (target or focus) and showStatus ~= true then
		FadeFramesInOut(true, frames[self])
	elseif arg1 == true and showStatus ~= true then
		FadeFramesInOut(true, frames[self])
	else
		if combat and showStatus ~= true then
			FadeFramesInOut(true, frames[self])
		elseif not target and not combat and not focus and (cur == max) and not (cast or channel) then
			FadeFramesInOut(false, frames[self])
		end
	end
end

local function Enable(self, unit)
	if self.CombatFade then
		frames[self] = self.unit
		allFrames[self] = self.unit

		if unit == "player" then
			showStatus = false
		end

		self:RegisterEvent("PLAYER_ENTERING_WORLD", Update, true)
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Update, true)
		self:RegisterEvent("PLAYER_REGEN_DISABLED", Update, true)
		self:RegisterEvent("PLAYER_TARGET_CHANGED", Update, true)
		self:RegisterEvent("UNIT_HEALTH", Update)
		self:RegisterEvent("UNIT_SPELLCAST_START", Update)
		self:RegisterEvent("UNIT_SPELLCAST_STOP", Update)
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", Update)
		self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Update)
		self:RegisterEvent("UNIT_PORTRAIT_UPDATE", Update)
		self:RegisterEvent("UNIT_MODEL_CHANGED", Update)

		if not self.CombatFadeHooked then
			self:HookScript("OnEnter", function(self)
				Update(self, true)
			end)

			self:HookScript("OnLeave", function(self)
				Update(self, false)
			end)

			self.CombatFadeHooked = true
		end

		return true
	end
end

local function Disable(self)
	if (self.CombatFade) then
		frames[self] = nil
		Update(self)

		self:UnregisterEvent("PLAYER_ENTERING_WORLD", Update)
		self:UnregisterEvent("PLAYER_REGEN_ENABLED", Update)
		self:UnregisterEvent("PLAYER_REGEN_DISABLED", Update)
		self:UnregisterEvent("PLAYER_TARGET_CHANGED", Update)
		self:UnregisterEvent("PLAYER_FOCUS_CHANGED", Update)
		self:UnregisterEvent("UNIT_HEALTH", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_START", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_STOP", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", Update)
		self:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", Update)
		self:UnregisterEvent("UNIT_PORTRAIT_UPDATE", Update)
		self:UnregisterEvent("UNIT_MODEL_CHANGED", Update)
	end
end

K.oUF:AddElement("CombatFade", Update, Enable, Disable)