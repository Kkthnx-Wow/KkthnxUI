local K = unpack(KkthnxUI)
local oUF = K.oUF

-- By Tukz, for Tukui

local Tracker = {
	-- EVOKER
	[355941] = { 0.33, 0.33, 0.77 }, -- Dream Breath
	[363502] = { 0.33, 0.33, 0.70 }, -- Dream Flight
	[366155] = { 0.14, 1.00, 0.88 }, -- Reversion
	[364343] = { 0.13, 0.87, 0.50 }, -- Echo
	[357170] = { 0.11, 0.57, 0.71 }, -- Time Dilation
	-- ROGUE
	[57934] = { 0.89, 0.09, 0.05 }, -- Tricks of the Trade
	-- WARRIOR
	[3411] = { 0.89, 0.09, 0.05 }, -- Intervene
	-- PRIEST
	[139] = { 0.4, 0.7, 0.2 }, -- Renew
	[17] = { 0.7, 0.7, 0.7 }, -- Power Word: Shield
	[193065] = { 0.54, 0.21, 0.78 }, -- Masochism
	[194384] = { 1, 1, 0.66 }, -- Atonement
	[214206] = { 1, 1, 0.66 }, -- Atonement (PvP)
	[33206] = { 0.47, 0.35, 0.74 }, -- Pain Suppression
	[41635] = { 0.2, 0.7, 0.2 }, -- Prayer of Mending
	[47788] = { 0.86, 0.45, 0 }, -- Guardian Spirit
	[6788] = { 0.89, 0.1, 0.1 }, -- Weakened Soul
	-- DRUID
	[774] = { 0.8, 0.4, 0.8 }, -- Rejuvenation
	[155777] = { 0.8, 0.4, 0.8 }, -- Germination
	[8936] = { 0.2, 0.8, 0.2 }, -- Regrowth
	[33763] = { 0.4, 0.8, 0.2 }, -- Lifebloom
	[188550] = { 0.4, 0.8, 0.2 }, -- Lifebloom (Shadowlands Legendary)
	[48438] = { 0.8, 0.4, 0 }, -- Wild Growth
	[207386] = { 0.4, 0.2, 0.8 }, -- Spring Blossoms
	[102351] = { 0.2, 0.8, 0.8 }, -- Cenarion Ward (Initial Buff)
	[102352] = { 0.2, 0.8, 0.8 }, -- Cenarion Ward (HoT)
	[200389] = { 1, 1, 0.4 }, -- Cultivation
	[203554] = { 1, 1, 0.4 }, -- Focused Growth (PvP)
	-- PALADIN
	[53563] = { 0.7, 0.3, 0.7 }, -- Beacon of Light
	[156910] = { 0.7, 0.3, 0.7 }, -- Beacon of Faith
	[200025] = { 0.7, 0.3, 0.7 }, -- Beacon of Virtue
	[1022] = { 0.2, 0.2, 1 }, -- Blessing of Protection
	[1044] = { 0.89, 0.45, 0 }, -- Blessing of Freedom
	[6940] = { 0.89, 0.1, 0.1 }, -- Blessing of Sacrifice
	[204018] = { 0.2, 0.2, 1 }, -- Blessing of Spellwarding
	[223306] = { 0.7, 0.7, 0.3 }, -- Bestow Faith
	[287280] = { 0.2, 0.8, 0.2 }, -- Glimmer of Light (T50 Talent)
	[157047] = { 0.15, 0.58, 0.84 }, -- Saved by the Light (T25 Talent)
	-- SHAMAN
	[61295] = { 0.7, 0.3, 0.7 }, -- Riptide
	[974] = { 0.2, 0.2, 1 }, -- Earth Shield
	-- HUNTER
	[90361] = { 0.34, 0.47, 0.31 }, -- Spirit Mend (HoT)
	-- MONK
	[115175] = { 0.6, 0.9, 0.9 }, -- Soothing Mist
	[116841] = { 0.12, 1.00, 0.53 }, -- Tiger's Lust (Freedom)
	[116849] = { 0.2, 0.8, 0.2 }, -- Life Cocoon
	[119611] = { 0.3, 0.8, 0.6 }, -- Renewing Mist
	[124682] = { 0.8, 0.8, 0.25 }, -- Enveloping Mist
	[191840] = { 0.27, 0.62, 0.7 }, -- Essence Font
	[325209] = { 0.3, 0.6, 0.6 }, -- Enveloping Breath
	-- PET
	-- Warlock Pets
	[193396] = { 0.6, 0.2, 0.8 }, -- Demonic Empowerment
	-- Hunter Pets
	[272790] = { 0.89, 0.09, 0.05 }, -- Frenzy
	[136] = { 0.2, 0.8, 0.2 }, -- Mend Pet
}

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

	local PositionX = (id * AuraTrack.IconSize) - AuraTrack.IconSize + (AuraTrack.Spacing * id)
	local r, g, b = unpack(Tracker[spellID])

	if not AuraTrack.Auras[id] then
		AuraTrack.Auras[id] = CreateFrame("Frame", nil, AuraTrack)
		AuraTrack.Auras[id]:SetSize(AuraTrack.IconSize, AuraTrack.IconSize)
		AuraTrack.Auras[id]:SetPoint("TOPLEFT", PositionX, AuraTrack.IconSize / 3)

		AuraTrack.Auras[id].Backdrop = AuraTrack.Auras[id]:CreateTexture(nil, "BACKGROUND")
		AuraTrack.Auras[id].Backdrop:SetPoint("TOPLEFT", AuraTrack.Auras[id], -1, 1)
		AuraTrack.Auras[id].Backdrop:SetPoint("BOTTOMRIGHT", AuraTrack.Auras[id], 1, -1)

		if AuraTrack.Auras[id].Backdrop.CreateShadow then
			AuraTrack.Auras[id]:CreateShadow()
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
	AuraTrack.Auras[id].Backdrop:SetColorTexture(r * 0.2, g * 0.2, b * 0.2)
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

	AuraTrack.MaxAuras = AuraTrack.MaxAuras or floor(Size / AuraTrack.Thickness)

	if id > AuraTrack.MaxAuras then
		return
	end

	local r, g, b = unpack(Tracker[spellID])
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

		AuraTrack.Auras[id].Backdrop = AuraTrack.Auras[id]:CreateTexture(nil, "BACKGROUND")
		AuraTrack.Auras[id].Backdrop:SetAllPoints()
	end

	AuraTrack.Auras[id].Expiration = expiration
	AuraTrack.Auras[id].Duration = duration
	AuraTrack.Auras[id]:SetStatusBarTexture(AuraTrack.Texture)
	AuraTrack.Auras[id]:SetStatusBarColor(r, g, b)
	AuraTrack.Auras[id].Backdrop:SetColorTexture(r * 0.2, g * 0.2, b * 0.2)

	if expiration > 0 and duration > 0 then
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

	local ID = 0

	if self.AuraTrack:GetWidth() == 0 then
		return
	end

	self.AuraTrack.MaxAuras = self.AuraTrack.MaxAuras or 4
	self.AuraTrack.Spacing = self.AuraTrack.Spacing or 6
	self.AuraTrack.IconSize = (self.AuraTrack:GetWidth() / self.AuraTrack.MaxAuras) - self.AuraTrack.Spacing - (self.AuraTrack.Spacing / self.AuraTrack.MaxAuras)

	for i = 1, 40 do
		local _, texture, count, _, duration, expiration, caster, _, _, spellID = UnitAura(unit, i, "HELPFUL")

		if self.AuraTrack.Tracker[spellID] and (caster == "player" or caster == "pet") then
			ID = ID + 1

			if self.AuraTrack.Icons then
				UpdateIcon(self, unit, spellID, texture, ID, expiration, duration, count)
			else
				UpdateBar(self, unit, spellID, texture, ID, expiration, duration)
			end
		end
	end

	for i = ID + 1, self.AuraTrack.MaxAuras do
		if self.AuraTrack.Auras[i] and self.AuraTrack.Auras[i]:IsShown() then
			self.AuraTrack.Auras[i]:Hide()
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
