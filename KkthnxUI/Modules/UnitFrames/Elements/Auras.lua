local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _G = _G
local string_format = string.format

local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetTime = _G.GetTime
local UnitCanAttack = _G.UnitCanAttack
local UnitIsFriend = _G.UnitIsFriend
local UnitAura = _G.UnitAura

local function FilterSharedBuffs(_, _, _, name)
	if (K.UnImportantBuffs[name]) then
		return false
	else
		return true
	end
end

local function FilterGroupDebuffs(_, unit, button, name, _, _, _, _, _, _, caster, _, _, _, _, isBossDebuff, casterIsPlayer)
	if (not UnitIsFriend("player", unit)) then
		return button.isPlayer or caster == "pet" or not casterIsPlayer or isBossDebuff or K.ImportantDebuffs[name]
	else
		return false
	end
end

local function CreateAuraTimer(self, elapsed)
	self.expirationSaved = self.expirationSaved - elapsed
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
		return
	end

	if self.expirationSaved <= 0 then
		self:SetScript("OnUpdate", nil)
		if (self.text:GetFont()) then
			self.text:SetText("")
		end
		return
	end

	local timervalue, formatid
	timervalue, formatid, self.nextupdate = K.GetTimeInfo(self.expirationSaved, 4)
	if self.text:GetFont() then
		self.text:SetFormattedText(string_format("%s%s|r", K.TimeColors[formatid], K.TimeFormats[formatid][2]), timervalue)
	else
		self.text:SetFormattedText(string_format("%s%s|r", K.TimeColors[formatid], K.TimeFormats[formatid][2]), timervalue)
	end
end

local function PostCreateAura(self, button)
	button:SetTemplate("Transparent", true)

	button.text = button.cd:CreateFontString(nil, "OVERLAY")
	button.text:FontTemplate(nil, self.size * 0.46)
	button.text:SetPoint("CENTER", 1, 1)
	button.text:SetJustifyH("CENTER")

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetPoint("TOPLEFT", 1, -1)
	button.cd:SetPoint("BOTTOMRIGHT", -1, 1)
	button.cd:SetHideCountdownNumbers(true)

	button.icon:SetAllPoints(button)
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	button.icon:SetDrawLayer("ARTWORK")

	button.count:FontTemplate(nil, self.size * 0.46)
	button.count:ClearAllPoints()
	button.count:SetPoint("BOTTOMRIGHT", 1, 1)
	button.count:SetJustifyH("RIGHT")

	button.overlay:SetTexture(nil)
	button.stealable:SetTexture(nil)
end

local function PostUpdateAura(self, unit, button, index)
	local name, _, _, _, debuffType, duration, expiration, caster, isStealable = UnitAura(unit, index, button.filter)
	local isPlayer = (caster == "player" or caster == "vehicle")
	local isFriend = unit and UnitIsFriend("player", unit) and not UnitCanAttack("player", unit)

	if button.isDebuff then
		if (not isFriend and not isPlayer and not C["Unitframe"].OnlyShowPlayerDebuff) then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not unit:find("arena%d")) and true or false)
		else
			local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and K.Class ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r, color.g, color.b)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if (isStealable) and not isFriend then
			button:SetBackdropBorderColor(1, 0.85, 0)
		else
			button:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end
	end

	if expiration and duration and (duration ~= 0) then
		local getTime = GetTime()
		if not button:GetScript("OnUpdate") then
			button.expirationTime = expiration
			button.expirationSaved = expiration - getTime
			button.nextupdate = -1
			button:SetScript("OnUpdate", CreateAuraTimer)
		end
		if (button.expirationTime ~= expiration) or (button.expirationSaved ~= (expiration - getTime)) then
			button.expirationTime = expiration
			button.expirationSaved = expiration - getTime
			button.nextupdate = -1
		end
	end

	if expiration and duration and (duration == 0 or expiration <= 0) then
		button.expirationTime = nil
		button.expirationSaved = nil
		button:SetScript("OnUpdate", nil)
		if button.text:GetFont() then
			button.text:SetText("")
		end
	end
end

-- We will handle these individually so we can have the up most control of our auras on each unit/frame
function K.CreateAuras(self, unit)
	unit = unit:match("^(%a-)%d+") or unit

	local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
	local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	local Auras = CreateFrame("Frame", self:GetName().."Auras", self)

	if (unit == "target") then
		if C["Unitframe"].DebuffsOnTop then
			Buffs:SetHeight(21)
			Buffs:SetWidth(self.Power:GetWidth())
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Buffs.size = 21
			Buffs.num = 15
			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.PostCreateIcon = PostCreateAura
			Buffs.PostUpdateIcon = PostUpdateAura
			Buffs.CustomFilter = FilterSharedBuffs

			Debuffs:SetHeight(28)
			Debuffs:SetWidth(self.Health:GetWidth())
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
			Debuffs.size = 28
			Debuffs.num = 12
			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
			Debuffs.PostCreateIcon = PostCreateAura
			Debuffs.PostUpdateIcon = PostUpdateAura

			self.Buffs = Buffs
			self.Debuffs = Debuffs
		else
			Auras.gap = true
			Auras.size = 21
			Auras:SetHeight(21)
			Auras:SetWidth(130)
			Auras:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Auras.initialAnchor = "TOPLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "DOWN"
			Auras.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
			Auras.numBuffs = 15
			Auras.numDebuffs = 12
			Auras.spacing = 6
			Auras.showStealableBuffs = true
			function Auras.PostUpdateGapIcon(self, unit, icon, visibleBuffs)
				icon:Hide()
			end
			Auras.PostCreateIcon = PostCreateAura
			Auras.PostUpdateIcon = PostUpdateAura
			self.Auras = Auras
		end
	elseif (unit == "focus") then
		if C["Unitframe"].DebuffsOnTop then
			Buffs:SetHeight(21)
			Buffs:SetWidth(self.Power:GetWidth())
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Buffs.size = 21
			Buffs.num = 15
			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.PostCreateIcon = PostCreateAura
			Buffs.PostUpdateIcon = PostUpdateAura
			Buffs.CustomFilter = FilterSharedBuffs

			Debuffs:SetHeight(28)
			Debuffs:SetWidth(self.Health:GetWidth())
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
			Debuffs.size = 28
			Debuffs.num = 12
			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.PostCreateIcon = PostCreateAura
			Debuffs.PostUpdateIcon = PostUpdateAura

			self.Buffs = Buffs
			self.Debuffs = Debuffs
		else
			Auras.gap = true
			Auras.size = 21
			Auras:SetHeight(21)
			Auras:SetWidth(130)
			Auras:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Auras.initialAnchor = "TOPLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "DOWN"
			Auras.numBuffs = 15
			Auras.numDebuffs = 12
			Auras.spacing = 6
			Auras.showStealableBuffs = true
			Auras.PostUpdateGapIcon = function(self, unit, icon, visibleBuffs)
				icon:Hide()
			end
			Auras.PostCreateIcon = PostCreateAura
			Auras.PostUpdateIcon = PostUpdateAura
			self.Auras = Auras
		end
	elseif (unit == "party") then
		Buffs:SetHeight(20)
		Buffs:SetWidth(self:GetWidth())
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 20
		Buffs.num = 4
		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		Buffs.CustomFilter = FilterSharedBuffs

		Debuffs:SetHeight(28)
		Debuffs:SetWidth(self.Power:GetWidth())
		Debuffs:SetPoint("LEFT", self, "RIGHT", 3, 0)
		Debuffs.size = 28
		Debuffs.num = 3
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		Debuffs.CustomFilter = FilterGroupDebuffs

		self.Buffs = Buffs
		self.Debuffs = Debuffs
	elseif (unit == "targettarget") then
		Debuffs:SetHeight(self.Portrait:GetHeight() - 4)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("LEFT", self.Portrait, "RIGHT", 6, 0)
		Debuffs.size = self.Portrait:GetHeight() - 4
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "LEFT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura

		self.Debuffs = Debuffs
	elseif (unit == "pet") then
		Debuffs:SetHeight(self.Portrait:GetHeight() - 4)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("RIGHT", self.Portrait, "LEFT", -6, 0)
		Debuffs.size = self.Portrait:GetHeight() - 4
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura

		self.Debuffs = Debuffs
	elseif (unit == "boss") then
		Buffs:SetHeight(self.Power:GetHeight())
		Buffs:SetWidth(self.Power:GetWidth())
		Buffs:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMLEFT", -6, 0)
		Buffs.size = self.Power:GetHeight()
		Buffs.num = 4
		Buffs.spacing = 6
		Buffs.initialAnchor = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "LEFT"
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura

		Debuffs:SetHeight(self.Health:GetHeight())
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("TOPRIGHT", self.Portrait, "TOPLEFT", -6, 0)
		Debuffs.size = self.Health:GetHeight()
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura

		self.Buffs = Buffs
		self.Debuffs = Debuffs
	elseif (unit == "arena") then
		Buffs:SetHeight(self.Power:GetHeight())
		Buffs:SetWidth(self.Power:GetWidth())
		Buffs:SetPoint("BOTTOMRIGHT", self.Trinket, "BOTTOMLEFT", -6, 0)
		Buffs.size = self.Power:GetHeight()
		Buffs.num = 4
		Buffs.spacing = 6
		Buffs.initialAnchor = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "LEFT"
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura

		Debuffs:SetHeight(self.Health:GetHeight())
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("TOPRIGHT", self.Trinket, "TOPLEFT", -6, 0)
		Debuffs.size = self.Health:GetHeight()
		Debuffs.num = 4
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura

		self.Buffs = Buffs
		self.Debuffs = Debuffs
	end
end