--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Handles castbar functionality including ticks, latency, and visual updates.
-- - Design: Modular element for oUF unitframes, handling both player and unit castbars.
-- - Events: UNIT_SPELLCAST_START, UNIT_SPELLCAST_STOP, UNIT_SPELLCAST_CHANNEL_START, etc.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- -- REASON: Localize C-functions (Snake Case)
-- local math_floor = _G.math.floor
-- local math_min = _G.math.min
-- local string_format = _G.string.format
-- local string_upper = _G.string.upper
-- local tonumber = _G.tonumber
-- local unpack = _G.unpack

-- -- REASON: Localize Globals
-- local GetTime = _G.GetTime
-- local IsPlayerSpell = _G.IsPlayerSpell
-- local UnitCanAttack = _G.UnitCanAttack
-- local UnitClass = _G.UnitClass
-- local UnitExists = _G.UnitExists
-- local UnitInVehicle = _G.UnitInVehicle
-- local UnitIsPlayer = _G.UnitIsPlayer
-- local UnitIsUnit = _G.UnitIsUnit
-- local UnitName = _G.UnitName
-- local UnitReaction = _G.UnitReaction
-- local YOU = _G.YOU

-- local channelingTicks = {
-- 	[740] = 4, -- Tranquility
-- 	[755] = 5, -- Life Tap
-- 	[5143] = 4, -- Arcane Missiles
-- 	[12051] = 6, -- Evocation
-- 	[15407] = 6, -- Mind Flay
-- 	[47757] = 3, -- Penance
-- 	[47758] = 3, -- Penance
-- 	[48045] = 6, -- Mind Sear
-- 	[64843] = 4, -- Divine Hymn
-- 	[120360] = 15, -- Barrage
-- 	[198013] = 10, -- Eye Beam
-- 	[198590] = 5, -- Drain Soul
-- 	[205021] = 5, -- Frostbolt
-- 	[205065] = 6, -- Void Torrent
-- 	[206931] = 3, -- Blooddrinker
-- 	[212084] = 10, -- Fel Devastation
-- 	[234153] = 5, -- Drain Life
-- 	[257044] = 7, -- Rapid Fire
-- 	[291944] = 6, -- Rejuvenation, Zandalari Trolls
-- 	[314791] = 4, -- Metamorphosis, Demon Hunter
-- 	[324631] = 8, -- Blood and Thunder, Covenant
-- 	[356995] = 3, -- Decimate, Dragon's Breath
-- }

-- if K.Class == "PRIEST" then
-- 	local function updateTicks()
-- 		local numTicks = 3
-- 		if IsPlayerSpell(193134) then
-- 			numTicks = 4
-- 		end
-- 		channelingTicks[47757] = numTicks
-- 		channelingTicks[47758] = numTicks
-- 	end

-- 	-- REASON: Update ticks on login and talent changes to account for Haste/Talent effects.
-- 	K:RegisterEvent("PLAYER_LOGIN", updateTicks)
-- 	K:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
-- end

-- -- REASON: Creates or updates the visual tick marks on the castbar for channeled spells.
-- local function CreateAndUpdateBarTicks(bar, ticks, numTicks)
-- 	for i = 1, #ticks do
-- 		local t = ticks[i]
-- 		if t and t:IsShown() then
-- 			t:Hide()
-- 		end
-- 	end

-- 	if numTicks and numTicks > 0 then
-- 		local width, height = bar:GetSize()
-- 		local delta = width / numTicks
-- 		for i = 1, numTicks - 1 do
-- 			local tex = ticks[i]
-- 			if not tex then
-- 				tex = bar:CreateTexture(nil, "OVERLAY")
-- 				tex:SetAtlas("UI-Frame-DastardlyDuos-ProgressBar-BorderTick", false)
-- 				tex:SetWidth(3)
-- 				tex:SetHeight(height)
-- 				tex:SetVertexColor(0.8, 0.8, 0.8, 0.8)
-- 				ticks[i] = tex
-- 			end
-- 			tex:ClearAllPoints()
-- 			tex:SetPoint("RIGHT", bar, "LEFT", delta * i, 0)
-- 			if not tex:IsShown() then
-- 				tex:Show()
-- 			end
-- 		end
-- 	end
-- end

function Module:UpdateCastbarGlow(unit)
	if self.barGlow and self.spellID then
		local isImportant = C_Spell.IsSpellImportant(self.spellID) -- C["Nameplate"].CastbarGlow
		self.barGlow:SetAlphaFromBoolean(isImportant, 0.7, 0)
	end
end

function Module:UpdateSpellTarget(unit)
	if not C["Nameplate"].CastTarget then
		return
	end
	if self.spellTarget then
		local isTargetingYou = UnitIsSpellTarget(unit, "player")
		if self.isYou then
			self.isYou:SetAlphaFromBoolean(isTargetingYou, 1, 0)
		end
		self.spellTarget:SetAlphaFromBoolean(isTargetingYou, 0, 1)

		local name = UnitSpellTargetName(unit)
		local class = UnitSpellTargetClass(unit)
		self.spellTarget:SetText(name or "")
		if class then
			self.spellTarget:SetTextColor(C_ClassColor.GetClassColor(class):GetRGB())
		else
			self.spellTarget:SetTextColor(1, 1, 1)
		end
	end
end

local OwnCastColor = { r = 0.3, g = 0.7, b = 1 }
local CastingColor = { r = 0.3, g = 0.7, b = 1 }
local NotInterruptColor = { r = 1, g = 0.5, b = 0.5 }

function Module:UpdateCastBarColors()
	local castingColor = CastingColor
	local ownCastColor = OwnCastColor
	local notInterruptColor = NotInterruptColor

	Module.CastingColor = Module.CastingColor or CreateColor(0, 0, 0)
	Module.OwnCastColor = Module.OwnCastColor or CreateColor(0, 0, 0)
	Module.NotInterruptColor = Module.NotInterruptColor or CreateColor(0, 0, 0)

	Module.CastingColor:SetRGB(castingColor.r, castingColor.g, castingColor.b)
	Module.OwnCastColor:SetRGB(ownCastColor.r, ownCastColor.g, ownCastColor.b)
	Module.NotInterruptColor:SetRGB(notInterruptColor.r, notInterruptColor.g, notInterruptColor.b)
end

function Module:UpdateCastBarColor(unit)
	if unit == "player" then
		self:SetStatusBarColor(Module.OwnCastColor:GetRGB())
	elseif not UnitIsUnit(unit, "player") then
		self:GetStatusBarTexture():SetVertexColorFromBoolean(self.notInterruptible, Module.NotInterruptColor, Module.CastingColor)
	else
		self:SetStatusBarColor(Module.CastingColor:GetRGB())
	end

	Module.UpdateSpellTarget(self, unit)
	Module.UpdateCastbarGlow(self, unit)
end

function Module:Castbar_FailedColor(unit)
	self:SetStatusBarColor(1, 0.1, 0)
end

function Module:Castbar_UpdateInterrupted(unit, interruptedBy)
	self:SetStatusBarColor(1, 0.1, 0)

	if self.spellTarget and interruptedBy ~= nil then -- C["Nameplate"].Interruptor
		local sourceName = UnitNameFromGUID(interruptedBy)
		local _, class = GetPlayerInfoByGUID(interruptedBy)
		class = class or "PRIEST"
		local classColor = C_ClassColor.GetClassColor(class)
		self.Text:SetText(INTERRUPTED .. " > " .. classColor:WrapTextInColorCode(sourceName))
		self.Time:SetText("")
	end
end

-- Empower Pips
Module.PipColors = {
	[1] = { 0.08, 1, 0, 0.5 },
	[2] = { 1, 0.1, 0.1, 0.5 },
	[3] = { 1, 0.5, 0, 0.5 },
	[4] = { 0.1, 0.7, 0.7, 0.5 },
	[5] = { 0, 1, 1, 0.5 },
	[6] = { 0, 0.5, 1, 0.5 },
}

function Module:CreatePip(stage)
	local _, height = self:GetSize()

	local pip = CreateFrame("Frame", nil, self, "CastingBarFrameStagePipTemplate")
	pip.BasePip:SetTexture(C["Media"].Textures.White8x8Texture)
	pip.BasePip:SetVertexColor(0, 0, 0)
	pip.BasePip:SetWidth(2)
	pip.BasePip:SetHeight(height)
	pip.tex = pip:CreateTexture(nil, "ARTWORK", nil, 2)
	pip.tex:SetTexture(K.GetTexture(C["General"].Texture))
	pip.tex:SetVertexColor(unpack(Module.PipColors[stage]))

	return pip
end

function Module:PostUpdatePips(numStages)
	if not numStages then
		return
	end

	local pips = self.Pips
	local num = #numStages

	for stage = 1, num do
		local pip = pips[stage]
		if stage == num then
			local firstPip = pips[1]
			local anchor = pips[num]
			firstPip.tex:SetPoint("BOTTOMRIGHT", self)
			firstPip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
		end

		if stage ~= 1 then
			local anchor = pips[stage - 1]
			pip.tex:SetPoint("BOTTOMRIGHT", pip.BasePip, "BOTTOMLEFT")
			pip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
		end
	end
end

function Module:CustomTimeText(durationObject)
	if durationObject then
		local duration = durationObject:GetRemainingDuration()
		local total = durationObject:GetTotalDuration()
		local delayText = ""
		if self.delay ~= 0 then
			delayText = format("|cffff0000%s%.2f|r", self.channeling and "-" or "+", self.delay)
		end
		self.Time:SetFormattedText("%.1f%s - %.1f", duration, delayText, total)
	end
end
