local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _G = _G
local string_format = string.format
local table_sort = table.sort

local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetTime = _G.GetTime
local UnitAura = _G.UnitAura
local UnitIsFriend = _G.UnitIsFriend
local UnitCanAttack = _G.UnitCanAttack

local BLACKLIST = {
	[113942] = true, -- Demonic: Gateway
	[117870] = true, -- Touch of The Titans
	[123981] = true, -- Perdition
	[124273] = true, -- Stagger
	[124274] = true, -- Stagger
	[124275] = true, -- Stagger
	[126434] = true, -- Tushui Champion
	[126436] = true, -- Huojin Champion
	[143625] = true, -- Brawling Champion
	[15007] = true, -- Ress Sickness
	[170616] = true, -- Pet Deserter
	[182957] = true, -- Treasures of Stormheim
	[182958] = true, -- Treasures of Azsuna
	[185719] = true, -- Treasures of Val'sharah
	[186401] = true, -- Sign of the Skirmisher
	[186403] = true, -- Sign of Battle
	[186404] = true, -- Sign of the Emissary
	[186406] = true, -- Sign of the Critter
	[188741] = true, -- Treasures of Highmountain
	[199416] = true, -- Treasures of Suramar
	[225787] = true, -- Sign of the Warrior
	[225788] = true, -- Sign of the Emissary
	[227723] = true, -- Mana Divining Stone
	[231115] = true, -- Treasures of Broken Shore
	[233641] = true, -- Legionfall Commander
	[23445] = true, -- Evil Twin
	[237137] = true, -- Knowledgeable
	[237139] = true, -- Power Overwhelming
	[239966] = true, -- War Effort
	[239967] = true, -- Seal Your Fate
	[239968] = true, -- Fate Smiles Upon You
	[239969] = true, -- Netherstorm
	[240979] = true, -- Reputable
	[240980] = true, -- Light As a Feather
	[240985] = true, -- Reinforced Reins
	[240986] = true, -- Worthy Champions
	[240987] = true, -- Well Prepared
	[240989] = true, -- Heavily Augmented
	[24755] = true, -- Tricked or Treated
	[25163] = true, -- Oozeling's Disgusting Aura
	[26013] = true, -- Deserter
	[36032] = true, -- Arcane Charge
	[36893] = true, -- Transporter Malfunction
	[36900] = true, -- Soul Split: Evil!
	[36901] = true, -- Soul Split: Good
	[39953] = true, -- A'dal's Song of Battle
	[41425] = true, -- Hypothermia
	[55711] = true, -- Weakened Heart
	[57723] = true, -- Exhaustion (heroism debuff)
	[57724] = true, -- Sated (lust debuff)
	[57819] = true, -- Argent Champion
	[57820] = true, -- Ebon Champion
	[57821] = true, -- Champion of the Kirin Tor
	[58539] = true, -- Watcher's Corpse
	[71041] = true, -- Dungeon Deserter
	[72968] = true, -- Precious's Ribbon
	[80354] = true, -- Temporal Displacement (timewarp debuff)
	[8326] = true, -- Ghost
	[85612] = true, -- Fiona's Lucky Charm
	[85613] = true, -- Gidwin's Weapon Oil
	[85614] = true, -- Tarenar's Talisman
	[85615] = true, -- Pamela's Doll
	[85616] = true, -- Vex'tul's Armbands
	[85617] = true, -- Argus' Journal
	[85618] = true, -- Rimblat's Stone
	[85619] = true, -- Beezil's Cog
	[8733] = true, -- Blessing of Blackfathom
	[89140] = true, -- Demonic Rebirth: Cooldown
	[93337] = true, -- Champion of Ramkahen
	[93339] = true, -- Champion of the Earthen Ring
	[93341] = true, -- Champion of the Guardians of Hyjal
	[93347] = true, -- Champion of Therazane
	[93368] = true, -- Champion of the Wildhammer Clan
	[93795] = true, -- Stormwind Champion
	[93805] = true, -- Ironforge Champion
	[93806] = true, -- Darnassus Champion
	[93811] = true, -- Exodar Champion
	[93816] = true, -- Gilneas Champion
	[93821] = true, -- Gnomeregan Champion
	[93825] = true, -- Orgrimmar Champion
	[93827] = true, -- Darkspear Champion
	[93828] = true, -- Silvermoon Champion
	[93830] = true, -- Bilgewater Champion
	[94158] = true, -- Champion of the Dragonmaw Clan
	[94462] = true, -- Undercity Champion
	[94463] = true, -- Thunder Bluff Champion
	[95809] = true, -- Insanity debuff (hunter pet heroism: ancient hysteria)
	[97340] = true, -- Guild Champion
	[97341] = true, -- Guild Champion
	[97821] = true, -- Void-Touched
}

local function CustomDefaultFilter(self, unit, aura, _, _, _, _, debuffType, duration, _, caster, isStealable, _, spellID, _, isBossAura)
	if BLACKLIST[spellID] then
		return false
	end

	local isFriend = UnitIsFriend("player", unit)

	isBossAura = isBossAura or caster and (UnitIsUnit(caster, "boss1") or UnitIsUnit(caster, "boss2") or UnitIsUnit(caster, "boss3") or UnitIsUnit(caster, "boss4") or UnitIsUnit(caster, "boss5"))

	if isBossAura then
		return true
	end

	if caster and UnitIsUnit(unit, caster) then
		if duration and duration ~= 0 then
			return true
		else
			return true and true
		end
	end

	if aura.isPlayer or (caster and UnitIsUnit(caster, "pet")) then
		if duration and duration ~= 0 then
			return true
		else
			return true and true
		end
	end

	if isFriend then
		if aura.isDebuff then
			if debuffType and K.IsDispellableByMe(debuffType) then
				return true
			end
		end
	else
		if isStealable then
			return true
		end
	end

	return false
end

local function CustomBossFilter(self, unit, aura, _, _, _, _, debuffType, duration, _, caster, isStealable, _, _, _, isBossAura)
	local isFriend = UnitIsFriend("player", unit)

	isBossAura = isBossAura or caster and (UnitIsUnit(caster, "boss1") or UnitIsUnit(caster, "boss2") or UnitIsUnit(caster, "boss3") or UnitIsUnit(caster, "boss4") or UnitIsUnit(caster, "boss5"))

	if isBossAura then
		return true
	end

	if aura.isPlayer or (caster and UnitIsUnit(caster, "pet")) then
		if duration and duration ~= 0 then
			return false
		else
			return false and false
		end
	end

	if isFriend then
		if aura.isDebuff then
			if debuffType and K.IsDispellableByMe(debuffType) then
				return false
			end
		end
	else
		if isStealable then
			return false
		end
	end

	return false
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

	button.Animation = button:CreateAnimationGroup()
	button.Animation:SetLooping("BOUNCE")

	button.Animation.FadeOut = button.Animation:CreateAnimation("Alpha")
	button.Animation.FadeOut:SetFromAlpha(1)
	button.Animation.FadeOut:SetToAlpha(0.2)
	button.Animation.FadeOut:SetDuration(.9)
	button.Animation.FadeOut:SetSmoothing("IN_OUT")

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

local function PostUpdateAura(self, unit, button, index)
	local name, _, _, _, debuffType, duration, expiration, _, isStealable = UnitAura(unit, index, button.filter)
	local isFriend = UnitIsFriend("player", unit) and not UnitCanAttack("player", unit)

	if button.isDebuff then
		if (not isFriend and button.caster ~= "player" and button.caster ~= "vehicle") then
			button:SetBackdropBorderColor(0.9, 0.1, 0.1)
			button.icon:SetDesaturated((unit and not unit:find("arena%d")) and true or false)
		else
			local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
			if (name == "Unstable Affliction" or name == "Vampiric Touch") and K.Class ~= "WARLOCK" then
				button:SetBackdropBorderColor(0.05, 0.85, 0.94)
			else
				button:SetBackdropBorderColor(color.r * 0.6, color.g * 0.6, color.b * 0.6)
			end
			button.icon:SetDesaturated(false)
		end
	else
		if (isStealable) and not isFriend and not button.Animation.Playing then
			button:SetBackdropBorderColor(237/255, 234/255, 142/255)
			button.Animation:Play()
			button.Animation.Playing = true
		else
			button:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
			button.Animation:Stop()
			button.Animation.Playing = false
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

			Debuffs:SetHeight(28)
			Debuffs:SetWidth(self.Health:GetWidth())
			Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
			Debuffs.size = 28
			Debuffs.num = 12

			Buffs.spacing = 6
			Buffs.initialAnchor = "TOPLEFT"
			Buffs["growth-y"] = "DOWN"
			Buffs["growth-x"] = "RIGHT"
			Buffs.CustomFilter = CustomDefaultFilter
			Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
			Buffs.PostCreateIcon = PostCreateAura
			Buffs.PostUpdateIcon = PostUpdateAura
			self.Buffs = Buffs

			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.CustomFilter = CustomDefaultFilter
			Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
			Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
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
			Auras.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
			Auras.numBuffs = 15
			Auras.numDebuffs = 12
			Auras.spacing = 6
			Auras.showStealableBuffs = true
			function Auras.PostUpdateGapIcon(self, unit, icon, visibleBuffs)
				icon:Hide()
			end
			Auras.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
			Auras.PostCreateIcon = PostCreateAura
			Auras.PostUpdateIcon = PostUpdateAura
			self.Auras = Auras
		end
	end

	if (unit == "focus") then
		if C["Unitframe"].DebuffsOnTop then
			local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
			local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

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
			Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
			Buffs.PostCreateIcon = PostCreateAura
			Buffs.PostUpdateIcon = PostUpdateAura
			self.Buffs = Buffs

			Debuffs.spacing = 6
			Debuffs.initialAnchor = "TOPLEFT"
			Debuffs["growth-y"] = "UP"
			Debuffs["growth-x"] = "RIGHT"
			Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
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
			Auras.spacing = 6
			Auras.showStealableBuffs = true
			Auras.PostUpdateGapIcon = function(self, unit, icon, visibleBuffs)
				icon:Hide()
			end
			Auras.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
			Auras.PostCreateIcon = PostCreateAura
			Auras.PostUpdateIcon = PostUpdateAura
			self.Auras = Auras
		end
	end

	-- Party.
	if (unit == "party") then
		local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

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
		Buffs.CustomFilter = CustomDefaultFilter
		Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.CustomFilter = CustomDefaultFilter
		Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
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
		Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
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
		Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
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

		Debuffs:SetHeight(26)
		Debuffs:SetWidth(self.Health:GetWidth())
		Debuffs:SetPoint("RIGHT", self.Portrait, "LEFT", -6, 10)
		Debuffs.size = 26
		Debuffs.num = 10

		Buffs.spacing = 6
		Buffs.initialAnchor = "LEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.CustomFilter = CustomBossFilter
		Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.CustomFilter = CustomBossFilter
		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
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
		Buffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "RIGHT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PreSetPosition = (not self:GetScript("OnUpdate")) and PreSetPosition or nil
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end
end