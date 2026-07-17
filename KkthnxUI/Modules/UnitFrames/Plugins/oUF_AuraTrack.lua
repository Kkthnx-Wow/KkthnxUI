--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Tracking auras for oUF layouts.
-- - Design: Per-unit aura tracking icons for raid/party frames.
-- - Events: UNIT_AURA.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local oUF = K.oUF
local IsSecret = K.IsSecret
local IsSecretTable = K.IsSecretTable
local NotSecret = K.NotSecret

-- REASON: Localize frequently used APIs and utilities for performance
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime

local math_floor = _G.math.floor

-- PERF: read aura rows directly; UnitAura/AuraUtil.UnpackAuraData unpacks points and
-- errors when that table is secret in instances (12.0).
local C_UnitAuras_GetAuraDataByIndex = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataByIndex
local C_UnitAuras_GetAuraDuration = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDuration

-- Fallback icons when icon field is secret (Ellesmere SECRET_SPELL_ICONS subset).
local SECRET_SPELL_ICONS = {
	[102342] = 136097, -- Ironbark
	[33206] = 135936, -- Pain Suppression
	[10060] = 135939, -- Power Infusion
	[47788] = 237542, -- Guardian Spirit
	[116849] = 636288, -- Life Cocoon
	[443113] = 615340, -- Strength of the Black Ox
	[1022] = 135964, -- Blessing of Protection
	[6940] = 135966, -- Blessing of Sacrifice
	[1044] = 135968, -- Blessing of Freedom
	[357170] = 4630500, -- Time Dilation
	[363534] = 4630498, -- Rewind
}

local Tracker = {
	-- PRIEST
	[194384] = { 1, 1, 0.66 }, -- Redeemer
	[214206] = { 1, 1, 0.66 }, -- Redeemer (PvP)
	[41635] = { 0.2, 0.7, 0.2 }, -- Healing Preamble
	[193065] = { 0.54, 0.21, 0.78 }, -- Remorseful Weight
	[139] = { 0.4, 0.7, 0.2 }, -- Recovery
	[17] = { 0.7, 0.7, 0.7 }, -- Power Word: Shield
	[47788] = { 0.86, 0.45, 0 }, -- Guardian Spirit
	[33206] = { 0.47, 0.35, 0.74 }, -- Pain Suppression
	[6788] = { 0.86, 0.11, 0.11 }, -- Weakness Soul

	-- DRUID
	[774] = { 0.8, 0.4, 0.8 }, -- Rejuvenation
	[155777] = { 0.6, 0.4, 0.8 }, -- Germination
	[8936] = { 0.2, 0.8, 0.2 }, -- Healing
	[33763] = { 0.4, 0.8, 0.2 }, -- Lifebloom
	[188550] = { 0.4, 0.8, 0.2 }, -- Lifebloom (Orange)
	[48438] = { 0.8, 0.4, 0 }, -- Wild Growth
	[29166] = { 0, 0.4, 1 }, -- Innervate
	[391891] = { 0, 0.8, 0.4 }, -- Metamorphosis Frenzy
	[102351] = { 0.2, 0.8, 0.8 }, -- Cenarion Ward
	[102352] = { 0.2, 0.8, 0.8 }, -- Cenarion Ward (HoT)
	[200389] = { 1, 1, 0.4 }, -- Cultivate

	-- EVOKER
	[355941] = { 0.4, 0.7, 0.2 }, -- Breath of Dreams
	[364343] = { 0, 0.8, 0.8 }, -- Echo
	[366155] = { 1, 0.9, 0.5 }, -- Reverse
	[370888] = { 0, 0.4, 1 }, -- Twin Wardens
	[357170] = { 0.47, 0.35, 0.74 }, -- Time Dilation

	-- PALADIN
	[287280] = { 1, 0.8, 0 }, -- Holy Flash
	[53563] = { 0.7, 0.3, 0.7 }, -- Beacon
	[156910] = { 0.7, 0.3, 0.7 }, -- Faith Beacon
	[200025] = { 0.7, 0.3, 0.7 }, -- Virtue Beacon
	[1022] = { 0.2, 0.2, 1 }, -- Protection
	[1044] = { 0.89, 0.45, 0 }, -- Freedom
	[6940] = { 0.89, 0.1, 0.1 }, -- Sacrifice
	[223306] = { 0.7, 0.7, 0.3 }, -- Bestow Faith
	[25771] = { 0.86, 0.11, 0.11 }, -- Forbearance

	-- SHAMAN
	[61295] = { 0.2, 0.8, 0.8 }, -- Riptide
	[974] = { 1, 0.8, 0 }, -- Earth Shield
	[383648] = { 1, 0.8, 0 }, -- Earth Shield (PvP)

	-- MONK
	[119611] = { 0.3, 0.8, 0.6 }, -- Revival
	[116849] = { 0.2, 0.8, 0.2 }, -- Cocoon of Enveloping
	[124682] = { 0.8, 0.8, 0.25 }, -- Enveloping Mist
	[191840] = { 0.27, 0.62, 0.7 }, -- Essence Font

	-- ROGUE
	[57934] = { 0.9, 0.1, 0.1 }, -- Misdirection

	-- WARRIOR
	[114030] = { 0.2, 0.2, 1 }, -- Vigilance

	-- HUNTER
	[34477] = { 0.9, 0.1, 0.1 }, -- Misdirection
	[90361] = { 0.4, 0.8, 0.2 }, -- Spirit Mend

	-- WARLOCK
	[20707] = { 0.8, 0.4, 0.8 }, -- Soulstone
}

local function ReadTrackedAura(auraData)
	if not auraData then
		return
	end

	-- Midnight: UnpackAuraData unpack(auraData.points) errors when points is secret.
	if auraData.points and (IsSecret(auraData.points) or IsSecretTable(auraData.points)) then
		return
	end

	local spellID = auraData.spellId
	local caster = auraData.sourceUnit
	local duration = auraData.duration
	local expiration = auraData.expirationTime
	local count = auraData.applications
	local texture = auraData.icon
	local auraInstanceID = auraData.auraInstanceID

	-- Only skip spellId as a table key when it's secret; keep the row.
	if IsSecret(spellID) then
		spellID = nil
	end

	if spellID or auraInstanceID then
		return spellID, texture, count, duration, expiration, caster, auraInstanceID
	end
end

-- Plain-duration fallback only. Prefer SetCooldownFromDurationObject / SetTimerDuration.
local function OnUpdate(self)
	local Time = GetTime()
	local Timeleft = self.Expiration - Time
	local Duration = self.Duration

	if self.SetMinMaxValues then
		self:SetMinMaxValues(0, Duration)
		self:SetValue(Timeleft)
	end
end

local function ApplyIconDuration(button, unit, auraInstanceID, expiration, duration)
	local cd = button.Cooldown
	if not cd then
		return
	end

	local durObj = auraInstanceID and C_UnitAuras_GetAuraDuration and C_UnitAuras_GetAuraDuration(unit, auraInstanceID)
	if durObj and cd.SetCooldownFromDurationObject then
		cd:SetCooldownFromDurationObject(durObj)
		button:SetScript("OnUpdate", nil)
		return
	end

	if NotSecret(expiration) and NotSecret(duration) and expiration and duration and expiration > 0 and duration > 0 then
		cd:SetCooldown(expiration - duration, duration)
	else
		cd:Clear()
	end
end

local function ApplyBarDuration(bar, unit, auraInstanceID, expiration, duration)
	local durObj = auraInstanceID and C_UnitAuras_GetAuraDuration and C_UnitAuras_GetAuraDuration(unit, auraInstanceID)
	if durObj and bar.SetTimerDuration then
		bar:SetTimerDuration(durObj)
		bar:SetScript("OnUpdate", nil)
		return
	end

	if NotSecret(expiration) and NotSecret(duration) and expiration and duration and expiration > 0 and duration > 0 then
		bar.Expiration = expiration
		bar.Duration = duration
		bar:SetMinMaxValues(0, duration)
		bar:SetScript("OnUpdate", OnUpdate)
	else
		bar:SetScript("OnUpdate", nil)
		bar:SetMinMaxValues(0, 1)
		bar:SetValue(1)
	end
end

local function UpdateIcon(self, unit, spellID, texture, id, expiration, duration, count, auraInstanceID)
	local AuraTrack = self.AuraTrack

	if id > AuraTrack.MaxAuras then
		return
	end

	local iconSize = AuraTrack.IconSize
	local spacing = AuraTrack.Spacing
	local PositionX = (id * iconSize) - iconSize + (spacing * id)
	local color = AuraTrack.Tracker[spellID]
	local r, g, b = color[1], color[2], color[3]

	if not AuraTrack.Auras[id] then
		AuraTrack.Auras[id] = CreateFrame("Frame", nil, AuraTrack)
		AuraTrack.Auras[id]:SetSize(AuraTrack.IconSize, AuraTrack.IconSize)
		AuraTrack.Auras[id]:SetPoint("TOPLEFT", PositionX, AuraTrack.IconSize / 3)

		if not AuraTrack.Auras[id].Shadow then
			AuraTrack.Auras[id]:CreateShadow(true)
		end

		AuraTrack.Auras[id].Texture = AuraTrack.Auras[id]:CreateTexture(nil, "ARTWORK")
		AuraTrack.Auras[id].Texture:SetAllPoints()
		AuraTrack.Auras[id].Texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)

		AuraTrack.Auras[id].Cooldown = CreateFrame("Cooldown", nil, AuraTrack.Auras[id], "CooldownFrameTemplate")
		AuraTrack.Auras[id].Cooldown:SetAllPoints()
		AuraTrack.Auras[id].Cooldown:SetReverse(true)
		AuraTrack.Auras[id].Cooldown:SetHideCountdownNumbers(true)

		AuraTrack.Auras[id].Count = AuraTrack.Auras[id]:CreateFontString(nil, "OVERLAY")
		AuraTrack.Auras[id].Count:SetFont(AuraTrack.Font, 12, "OUTLINE")
		AuraTrack.Auras[id].Count:SetPoint("CENTER", 1, 0)
	end

	if AuraTrack.Auras[id].Shadow then
		AuraTrack.Auras[id].Shadow:SetBackdropColor(r * 0.2, g * 0.2, b * 0.2)
	end
	ApplyIconDuration(AuraTrack.Auras[id], unit, auraInstanceID, expiration, duration)
	AuraTrack.Auras[id]:Show()

	if NotSecret(count) and count and count > 1 then
		AuraTrack.Auras[id].Count:SetText(count)
	else
		AuraTrack.Auras[id].Count:SetText("")
	end

	if AuraTrack.SpellTextures then
		AuraTrack.Auras[id].Texture:SetTexture(texture)
	else
		AuraTrack.Auras[id].Texture:SetColorTexture(r, g, b)
	end
end

local function UpdateBar(self, unit, spellID, _, id, expiration, duration, _, auraInstanceID)
	local AuraTrack = self.AuraTrack
	local Orientation = self.Health:GetOrientation()
	local Size = Orientation == "HORIZONTAL" and AuraTrack:GetHeight() or AuraTrack:GetWidth()

	local thickness = AuraTrack.Thickness
	AuraTrack.MaxAuras = AuraTrack.MaxAuras or math_floor(Size / thickness)

	if id > AuraTrack.MaxAuras then
		return
	end

	local color = AuraTrack.Tracker[spellID]
	local r, g, b = color[1], color[2], color[3]
	local Position = (id * AuraTrack.Thickness) - AuraTrack.Thickness
	local X = Orientation == "VERTICAL" and -Position or 0
	local Y = Orientation == "HORIZONTAL" and -Position or 0
	local SizeX = Orientation == "VERTICAL" and AuraTrack.Thickness or AuraTrack:GetWidth()
	local SizeY = Orientation == "VERTICAL" and AuraTrack:GetHeight() or AuraTrack.Thickness

	if not AuraTrack.Auras[id] then
		AuraTrack.Auras[id] = CreateFrame("StatusBar", nil, AuraTrack)

		AuraTrack.Auras[id]:SetSize(SizeX, SizeY)
		AuraTrack.Auras[id]:SetPoint("TOPRIGHT", X, Y)

		if Orientation == "VERTICAL" then
			AuraTrack.Auras[id]:SetOrientation("VERTICAL")
		end

		if not AuraTrack.Auras[id].Shadow then
			AuraTrack.Auras[id]:CreateShadow(true)
		end
	end

	AuraTrack.Auras[id]:SetStatusBarTexture(AuraTrack.Texture)
	AuraTrack.Auras[id]:SetStatusBarColor(r, g, b)
	if AuraTrack.Auras[id].Shadow then
		AuraTrack.Auras[id].Shadow:SetBackdropColor(r * 0.2, g * 0.2, b * 0.2)
	end

	ApplyBarDuration(AuraTrack.Auras[id], unit, auraInstanceID, expiration, duration)
	AuraTrack.Auras[id]:Show()
end

local function Update(self, _, unit)
	if self.unit ~= unit then
		return
	end

	local AuraTrack = self.AuraTrack
	local ID = 0

	if AuraTrack:GetWidth() == 0 then
		return
	end

	AuraTrack.MaxAuras = AuraTrack.MaxAuras or 4
	AuraTrack.Spacing = AuraTrack.Spacing or 6
	AuraTrack.IconSize = (AuraTrack:GetWidth() / AuraTrack.MaxAuras) - AuraTrack.Spacing - (AuraTrack.Spacing / AuraTrack.MaxAuras)

	if C_UnitAuras_GetAuraDataByIndex then
		for i = 1, 40 do
			local spellID, texture, count, duration, expiration, caster, auraInstanceID = ReadTrackedAura(
				C_UnitAuras_GetAuraDataByIndex(unit, i, "HELPFUL")
			)

			-- When spellId is secret (SecretWhenUnitAuraRestricted), fingerprint like Ellesmere.
			if not spellID and auraInstanceID and K.IdentifySecretPlayerAura then
				spellID = K.IdentifySecretPlayerAura(unit, auraInstanceID)
				if spellID then
					if IsSecret(texture) or not texture then
						texture = SECRET_SPELL_ICONS[spellID]
					end
					if IsSecret(caster) or not caster then
						caster = "player"
					end
				end
			end

			if spellID and NotSecret(caster) and (caster == "player" or caster == "pet") then
				local track = AuraTrack.Tracker[spellID]
				if track then
					ID = ID + 1

					if AuraTrack.Icons then
						UpdateIcon(self, unit, spellID, texture, ID, expiration, duration, count, auraInstanceID)
					else
						UpdateBar(self, unit, spellID, texture, ID, expiration, duration, count, auraInstanceID)
					end
				end
			end
		end
	end

	for i = ID + 1, AuraTrack.MaxAuras do
		if AuraTrack.Auras[i] and AuraTrack.Auras[i]:IsShown() then
			AuraTrack.Auras[i]:Hide()
		end
	end
end

local function Path(self, ...)
	return (self.AuraTrack.Override or Update)(self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
	local AuraTrack = self.AuraTrack

	if AuraTrack then
		AuraTrack.__owner = self
		AuraTrack.ForceUpdate = ForceUpdate

		AuraTrack.Tracker = AuraTrack.Tracker or Tracker
		AuraTrack.Thickness = AuraTrack.Thickness or 5
		AuraTrack.Texture = AuraTrack.Texture or "Interface\\TargetingFrame\\UI-StatusBar"
		AuraTrack.SpellTextures = AuraTrack.SpellTextures or AuraTrack.Icons == nil and true
		AuraTrack.Icons = AuraTrack.Icons or AuraTrack.Icons == nil and true
		AuraTrack.Auras = {}

		self:RegisterEvent("UNIT_AURA", Path)

		return true
	end
end

local function Disable(self)
	local AuraTrack = self.AuraTrack

	if AuraTrack then
		self:UnregisterEvent("UNIT_AURA", Path)
	end
end

oUF:AddElement("AuraTrack", Path, Enable, Disable)
