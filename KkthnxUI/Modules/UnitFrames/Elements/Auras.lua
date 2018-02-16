local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _G = _G
local string_format = string.format
local table_sort = table.sort

local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetTime = _G.GetTime
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitCanAttack = _G.UnitCanAttack
local UnitIsFriend = _G.UnitIsFriend

local function FilterSharedBuffs(_, _, _, name)
	if not name then
		return nil
	end

	if K.UnImportantBuffs[name] then
		return false
	else
		return true
	end

	return true
end

local function FilterGroupDebuffs(_, unit, button, name, _, _, _, _, _, _, caster, _, _, _, _, isBossDebuff, casterIsPlayer)
	if not name then
		return nil
	end

	if (not UnitIsFriend("player", unit)) then
		return button.isPlayer or caster == "pet" or not casterIsPlayer or isBossDebuff or K.ImportantDebuffs[name]
	else
		return true
	end

	return false
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

local function SortAurasByTime(a, b)
	if a:IsShown() and b:IsShown() then
		local aTime = a.expiration or -1
		local bTime = b.expiration or -1
		if (aTime and bTime) then
			return aTime < bTime
		end
	elseif a:IsShown() then
		return true
	end
end

local function SortAuras(self)
	table_sort(self, SortAurasByTime)
	return 1, self.createdIcons
end

local function PostUpdateAura(self, unit, button, index)
	local name, _, _, _, debuffType, duration, expiration, caster, isStealable = UnitAura(unit, index, button.filter)
	local isPlayer = (caster == "player" or caster == "vehicle")
	local isFriend = unit and UnitIsFriend("player", unit) and not UnitCanAttack("player", unit)

	button.isPlayer = isPlayer
	button.isFriend = isFriend
	button.isStealable = isStealable
	button.debuffType = debuffType
	button.duration = duration
	button.expiration = expiration
	button.name = name

	if button.isDebuff then
		if (not button.isFriend and not button.isPlayer and not C["Unitframe"].OnlyShowPlayerDebuff) then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not unit:find("arena%d")) and true or false)
		else
			local color = DebuffTypeColor[button.debuffType] or DebuffTypeColor.none
			if (button.name == "Unstable Affliction" or button.name == "Vampiric Touch") and K.Class ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r, color.g, color.b)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if (button.isStealable) and not button.isFriend then
			button:SetBackdropBorderColor(1, 0.85, 0)
		else
			button:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end
	end

	local size = button:GetParent().size
	if size then
		button:SetSize(size, size)
	end

	if button.expiration and button.duration and (button.duration ~= 0) then
		local getTime = GetTime()
		if not button:GetScript("OnUpdate") then
			button.expirationTime = button.expiration
			button.expirationSaved = button.expiration - getTime
			button.nextupdate = -1
			button:SetScript("OnUpdate", CreateAuraTimer)
		end
		if (button.expirationTime ~= button.expiration) or (button.expirationSaved ~= (button.expiration - getTime)) then
			button.expirationTime = button.expiration
			button.expirationSaved = button.expiration - getTime
			button.nextupdate = -1
		end
	end

	if button.expiration and button.duration and (button.duration == 0 or button.expiration <= 0) then
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

			Debuffs:SetHeight(28)
			Debuffs:SetWidth(self.Health:GetWidth())
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
			Debuffs.size = 28
			Debuffs.num = 12

			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
			Buffs.PostCreateIcon = PostCreateAura
			Buffs.PostUpdateIcon = PostUpdateAura
			Buffs.CustomFilter = FilterSharedBuffs
			self.Buffs = Buffs

			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
			Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
			Debuffs.PostCreateIcon = PostCreateAura
			Debuffs.PostUpdateIcon = PostUpdateAura
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
			Auras.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
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
			Auras.CustomFilter = FilterSharedBuffs
			self.Auras = Auras
		end
	elseif (unit == "focus") then
		if C["Unitframe"].DebuffsOnTop then
			Buffs:SetHeight(21)
			Buffs:SetWidth(self.Power:GetWidth())
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Buffs.size = 21
			Buffs.num = 15

			Debuffs:SetHeight(28)
			Debuffs:SetWidth(self.Health:GetWidth())
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
			Debuffs.size = 28
			Debuffs.num = 12

			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
			Buffs.PostCreateIcon = PostCreateAura
			Buffs.PostUpdateIcon = PostUpdateAura
			Buffs.CustomFilter = FilterSharedBuffs
			self.Buffs = Buffs

			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
			Debuffs.PostCreateIcon = PostCreateAura
			Debuffs.PostUpdateIcon = PostUpdateAura
			self.Debuffs = Debuffs
		else
			local Auras = CreateFrame("Frame", self:GetName().."Auras", self)
			Auras.gap = true
			Auras.size = 21
			Auras:SetHeight(21)
			Auras:SetWidth(130)
			Auras:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Auras.initialAnchor = "TOPLEFT"
			Auras["growth-x"] = "RIGHT"
			Auras["growth-y"] = "DOWN"
			Auras.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
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

		Debuffs:SetHeight(28)
		Debuffs:SetWidth(self.Power:GetWidth())
		Debuffs:SetPoint("LEFT", self, "RIGHT", 3, 0)
		Debuffs.size = 28
		Debuffs.num = 3

		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		Buffs.CustomFilter = FilterSharedBuffs
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		Debuffs.CustomFilter = FilterGroupDebuffs
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
		Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
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
		Buffs:SetHeight(21)
		Buffs:SetWidth(self.Power:GetWidth())
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 21
		Buffs.num = 5

		Debuffs:SetHeight(26)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("RIGHT", self.Portrait, "LEFT", -6, 10)
		Debuffs.size = 26
		Debuffs.num = 10

		Buffs.spacing = 6
		Buffs.initialAnchor = "LEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and SortAuras or nil
		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	elseif (unit == "arena") then
		Buffs:SetHeight(21)
		Buffs:SetWidth(self.Power:GetWidth())
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 21
		Buffs.num = 5

		Debuffs:SetHeight(26)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("RIGHT", self.Portrait, "LEFT", -6, 10)
		Debuffs.size = 26
		Debuffs.num = 10

		Buffs.spacing = 6
		Buffs.initialAnchor = "LEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end
end