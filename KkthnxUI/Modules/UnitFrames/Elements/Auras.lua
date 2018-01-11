local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end
local LibButtonGlow = LibStub("LibButtonGlow-1.0", true)

local _G = _G
local string_format = string.format
local table_sort = table.sort

local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetTime = _G.GetTime
local UnitAura = _G.UnitAura
local UnitIsFriend = _G.UnitIsFriend

local ImportantDebuffs = {
	[6788] = K.Class == "PRIEST", -- Weakened Soul
	[25771] = K.Class == "PALADIN", -- Forbearance
	[212570] = true, -- Surrendered Soul
}

local function CustomTargetBuffFilter(...) -- Buffs
	local _, unit, aura, _, _, _, _, _, _, _, caster, _, _, _, _, _, casterIsPlayer = ...
	if(UnitIsFriend(unit, "player")) then
		return aura.isPlayer or caster == "pet" or not casterIsPlayer
	else
		return true
	end
end

local function CustomTargetDebuffFilter(...) -- Debuffs
	local _, unit, aura, _, _, _, _, _, _, _, caster, _, _, spellID, _, isBossDebuff, casterIsPlayer = ...
	if (not UnitIsFriend(unit, "player")) then
		return aura.isPlayer or caster == "pet" or not casterIsPlayer or isBossDebuff or ImportantDebuffs[spellID]
	else
		return true
	end
end

local function CustomPartyDebuffFilter(...) -- Debuffs
	local _, _, _, _, _, _, _, _, _, _, _, _, _, id = ...
	return id == 160029
end

local function CreateAuraTimer(self, elapsed)
	self.expiration = self.expiration - elapsed
	if self.nextupdate > 0 then
		self.nextupdate = self.nextupdate - elapsed
		return
	end

	if (self.expiration <= 0) then
		self:SetScript("OnUpdate", nil)

		if(self.text:GetFont()) then
			self.text:SetText("")
		end

		return
	end

	local timervalue, formatid
	timervalue, formatid, self.nextupdate = K.GetTimeInfo(self.expiration, 4)

	if self.text:GetFont() then
		self.text:SetFormattedText(string_format("%s%s|r", K.TimeColors[formatid], K.TimeFormats[formatid][2]), timervalue)
	end
end

local function PostCreateAura(self, button)
	button.text = button.cd:CreateFontString(nil, "OVERLAY")
	button.text:FontTemplate(nil, self.size * 0.46)
	button.text:SetPoint("CENTER", 1, 1)
	button.text:SetJustifyH("CENTER")

	button:SetTemplate("Transparent", true)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse(true)
	button.cd:SetInside(button, 1, 1)
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
	if (a and b) then
		if a:IsShown() and b:IsShown() then
			local aTime = a.expiration or -1
			local bTime = b.expiration or -1
			if (aTime and bTime) then
				return aTime > bTime
			end
		elseif a:IsShown() then
			return true
		end
	end
end

local function PreSetPosition(self)
	table_sort(self, SortAurasByTime)
	return 1, self.createdIcons
end

local function PostUpdateAura(self, unit, button, index, offset, filter, isDebuff, duration, timeLeft)
	local name, _, _, _, dtype, duration, expiration, _, isStealable = UnitAura(unit, index, button.filter)
	local isFriend = UnitIsFriend("player", unit)

	if button.isDebuff then
		if (not isFriend and button.caster ~= "player" and button.caster ~= "vehicle") then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not unit:find("arena%d")) and true or false)
		else
			local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and K.Class ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if (isStealable) and not isFriend then
			button:SetBackdropBorderColor(237/255, 234/255, 142/255)
			LibButtonGlow.ShowOverlayGlow(button) -- Idk how well this is going to work.
		else
			button:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
			LibButtonGlow.HideOverlayGlow(button)
		end
	end

	local size = button:GetParent().size
	if size then
		button:SetSize(size, size)
	end

	button.spell = name
	button.isStealable = isStealable
	button.duration = duration

	if expiration and duration ~= 0 then
		if not button:GetScript("OnUpdate") then
			button.expirationTime = expiration
			button.expiration = expiration - GetTime()
			button.nextupdate = -1
			button:SetScript("OnUpdate", CreateAuraTimer)
		end
		if (button.expirationTime ~= expiration) or (button.expiration ~= (expiration - GetTime())) then
			button.expirationTime = expiration
			button.expiration = expiration - GetTime()
			button.nextupdate = -1
		end
	end

	if duration == 0 or expiration == 0 then
		button.expirationTime = nil
		button.expiration = nil
		button.priority = nil
		button.duration = nil
		button:SetScript("OnUpdate", nil)

		if (button.text:GetFont()) then
			button.text:SetText("")
		end
	end
end

-- We will handle these individually so we can have the up most control of our auras on each unit/frame
function K.CreateAuras(self, unit)
	unit = unit:match("^(.-)%d+") or unit

	if (unit == "target") then
		if C["Unitframe"].DebuffsOnTop then
			local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
			local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

			Buffs:SetHeight(21)
			Buffs:SetWidth(self.Power:GetWidth())
			Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
			Buffs.size = 21
			Buffs.num = 15
			Buffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerTargetBuffs

			Debuffs:SetHeight(28)
			Debuffs:SetWidth(self.Health:GetWidth())
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
			Debuffs.size = 28
			Debuffs.num = 12
			Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerTargetDebuffs

			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.CustomFilter = CustomTargetBuffFilter
			Buffs.PreSetPosition = PreSetPosition
			Buffs.PostCreateIcon = PostCreateAura
			Buffs.PostUpdateIcon = PostUpdateAura
			self.Buffs = Buffs

			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.CustomFilter = CustomTargetDebuffFilter
			Debuffs.PreSetPosition = PreSetPosition
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
			Auras.numBuffs = 15
			Auras.numDebuffs = 12
			Auras.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerAuras
			Auras.spacing = 6
			Auras.showStealableBuffs = true
			Auras.PostUpdateGapIcon = function(self, unit, icon, visibleBuffs)
				icon:Hide()
			end
			Auras.PreSetPosition = PreSetPosition
			Auras.PostCreateIcon = PostCreateAura
			Auras.PostUpdateIcon = PostUpdateAura
			self.Auras = Auras
		end
	end

	-- Party.
	if (unit == "party") then
		local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Buffs:SetHeight(19)
		Buffs:SetWidth(self:GetWidth())
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 19
		Buffs.num = 4

		Debuffs:SetHeight(30)
		Debuffs:SetWidth(self.Power:GetWidth())
		Debuffs:SetPoint("LEFT", self, "RIGHT", 3, 0)
		Debuffs.size = 30
		Debuffs.num = 4

		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PreSetPosition = PreSetPosition
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.CustomFilter = CustomPartyDebuffFilter
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end

	if (unit == "targettarget") then
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Debuffs:SetHeight(self.Portrait:GetHeight() - 4)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("LEFT", self.Portrait, "RIGHT", 6, 0)
		Debuffs.size = self.Portrait:GetHeight() - 4
		Debuffs.num = 4

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "LEFT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end

	if (unit == "pet") then
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Debuffs:SetHeight(self.Portrait:GetHeight() - 4)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("RIGHT", self.Portrait, "LEFT", -6, 0)
		Debuffs.size = self.Portrait:GetHeight() - 4
		Debuffs.num = 4

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end

	-- Boss.
	if (unit == "boss") then
		local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Buffs:SetHeight(21)
		Buffs:SetWidth(self.Power:GetWidth())
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 21
		Buffs.num = 5
		Buffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerBossBuffs

		Debuffs:SetHeight(26)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("RIGHT", self.Portrait, "LEFT", -6, 10)
		Debuffs.size = 26
		Debuffs.num = 10
		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerBossDebuffs

		Buffs.spacing = 6
		Buffs.initialAnchor = "LEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PreSetPosition = PreSetPosition
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end

	if (unit == "arena") then
		local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

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
		Buffs.PreSetPosition = PreSetPosition
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end
end