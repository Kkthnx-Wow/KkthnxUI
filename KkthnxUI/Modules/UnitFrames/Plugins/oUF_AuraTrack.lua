local K = KkthnxUI[1]
local oUF = K.oUF

-- By Tukz, for Tukui

-- Localize frequently used APIs and utilities for performance
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitAura = UnitAura
local AuraUtil_UnpackAuraData = AuraUtil and AuraUtil.UnpackAuraData
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
local math_floor = math.floor

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

if not UnitAura then
	UnitAura = function(unitToken, index, filter)
		local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter)

		if not auraData then
			return nil
		end

		return AuraUtil.UnpackAuraData(auraData)
	end
end

-- Handle per-tick countdown updates; min/max is set when duration changes
local function OnUpdate(self)
	local Time = GetTime()
	local Timeleft = self.Expiration - Time
	local Duration = self.Duration

	if self.SetMinMaxValues then
		self:SetMinMaxValues(0, Duration)
		self:SetValue(Timeleft)
	end
end

local function UpdateIcon(self, _, spellID, texture, id, expiration, duration, count)
	local AuraTrack = self.AuraTrack

	if id > AuraTrack.MaxAuras then
		return
	end

	local iconSize = AuraTrack.IconSize
	local spacing = AuraTrack.Spacing
	local PositionX = (id * iconSize) - iconSize + (spacing * id)
	local color = Tracker[spellID]
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

	AuraTrack.Auras[id].Expiration = expiration
	AuraTrack.Auras[id].Duration = duration
	if AuraTrack.Auras[id].Shadow then
		AuraTrack.Auras[id].Shadow:SetBackdropColor(r * 0.2, g * 0.2, b * 0.2)
	end
	AuraTrack.Auras[id].Cooldown:SetCooldown(expiration - duration, duration)
	AuraTrack.Auras[id]:Show()

	if count and count > 1 then
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

local function UpdateBar(self, _, spellID, _, id, expiration, duration)
	local AuraTrack = self.AuraTrack
	local Orientation = self.Health:GetOrientation()
	local Size = Orientation == "HORIZONTAL" and AuraTrack:GetHeight() or AuraTrack:GetWidth()

	local thickness = AuraTrack.Thickness
	AuraTrack.MaxAuras = AuraTrack.MaxAuras or math_floor(Size / thickness)

	if id > AuraTrack.MaxAuras then
		return
	end

	local color = Tracker[spellID]
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

	AuraTrack.Auras[id].Expiration = expiration
	AuraTrack.Auras[id].Duration = duration
	AuraTrack.Auras[id]:SetStatusBarTexture(AuraTrack.Texture)
	AuraTrack.Auras[id]:SetStatusBarColor(r, g, b)
	if AuraTrack.Auras[id].Shadow then
		AuraTrack.Auras[id].Shadow:SetBackdropColor(r * 0.2, g * 0.2, b * 0.2)
	end

	if expiration > 0 and duration > 0 then
		AuraTrack.Auras[id]:SetMinMaxValues(0, duration)
		AuraTrack.Auras[id]:SetScript("OnUpdate", OnUpdate)
	else
		AuraTrack.Auras[id]:SetScript("OnUpdate", nil)
		AuraTrack.Auras[id]:SetMinMaxValues(0, 1)
		AuraTrack.Auras[id]:SetValue(1)
	end

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

	for i = 1, 40 do
		local _, texture, count, _, duration, expiration, caster, _, _, spellID = UnitAura(unit, i, "HELPFUL")

		local track = AuraTrack.Tracker[spellID]
		if track and (caster == "player" or caster == "pet") then
			ID = ID + 1

			if AuraTrack.Icons then
				UpdateIcon(self, unit, spellID, texture, ID, expiration, duration, count)
			else
				UpdateBar(self, unit, spellID, texture, ID, expiration, duration)
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
		AuraTrack.Texture = AuraTrack.Texture or [[Interface\\TargetingFrame\\UI-StatusBar]]
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
