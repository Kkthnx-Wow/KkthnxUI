local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true and C.Raidframe.Enable ~= true then return end

-- Lua API
local abs = math.abs
local format = string.format
local min, max = math.min, math.max
local pairs = pairs
local select = select
local tinsert = table.insert
local type = type
local unpack = unpack

-- Wow API
local CreateFrame = CreateFrame
local GetNetStats = GetNetStats
local GetSpellInfo = GetSpellInfo
local GetTime = GetTime
local UnitCanAttack = UnitCanAttack
local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsFriend = UnitIsFriend
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitIsUnit = UnitIsUnit
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitSelectionColor = UnitSelectionColor

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: PLAYER_OFFLINE, DEAD, UnitFrame_OnLeave, UnitFrame_OnEnter

local _, ns = ...
local oUF = ns.oUF or oUF
local colors = K.Colors

function K.MatchUnit(unit)
	if (unit:match("vehicle")) then
		return "player"
	elseif (unit:match("party%d")) then
		return "party"
	elseif (unit:match("arena%d")) then
		return "arena"
	elseif (unit:match("boss%d")) then
		return "boss"
	elseif (unit:match("partypet%d")) then
		return "pet"
	else
		return unit
	end
end

function K.MultiCheck(what, ...)
	for i = 1, select("#", ...) do
		if (what == select(i, ...)) then
			return true
		end
	end

	return false
end

local function UpdatePortraitColor(self, unit, cur, max)
	if (not UnitIsConnected(unit)) then
		self.Portrait:SetVertexColor(0.5, 0.5, 0.5, 0.7)
	elseif (UnitIsDead(unit)) then
		self.Portrait:SetVertexColor(0.35, 0.35, 0.35, 0.7)
	elseif (UnitIsGhost(unit)) then
		self.Portrait:SetVertexColor(0.3, 0.3, 0.9, 0.7)
	elseif (cur / max * 100 < 25) then
		if (UnitIsPlayer(unit)) then
			if (self.MatchUnit ~= "player") then
				self.Portrait:SetVertexColor(1, 0, 0, 0.7)
			end
		end
	else
		self.Portrait:SetVertexColor(1, 1, 1, 1)
	end
end

local TEXT_PERCENT, TEXT_SHORT, TEXT_LONG, TEXT_MINMAX, TEXT_MAX, TEXT_DEF, TEXT_NONE = 0, 1, 2, 3, 4, 5, 6
local function SetValueText(element, tag, cur, max, notMana)
	if (not max or max == 0) then max = 100 end -- </ not sure why this happens > --

	if (tag == TEXT_PERCENT) and (max < 200) then
		tag = TEXT_SHORT -- </ Shows energy etc. with real number > --
	end

	local s

	if tag == TEXT_SHORT then
		s = format("%s", cur > 0 and K.ShortValue(cur) or "")
	elseif tag == TEXT_LONG then
		s = format("%s - %.1f%%", K.ShortValue(cur), cur / max * 100)
	elseif tag == TEXT_MINMAX then
		s = format("%s/%s", K.ShortValue(cur), K.ShortValue(max))
	elseif tag == TEXT_MAX then
		s = format("%s", K.ShortValue(max))
	elseif tag == TEXT_DEF then
		s = format("%s", (cur == max and "" or "-"..K.ShortValue(max - cur)))
	elseif tag == TEXT_PERCENT then
		s = format("%d%%", cur / max * 100)
	else
		s = ""
	end

	element:SetFormattedText("|cff%02x%02x%02x%s|r", 1 * 255, 1 * 255, 1 * 255, s)
end

-- </ PostHealth update > --
do
	local tagtable = {
		NUMERIC = {TEXT_MINMAX, TEXT_SHORT, TEXT_MAX},
		BOTH	= {TEXT_MINMAX, TEXT_LONG, TEXT_MAX},
		PERCENT = {TEXT_SHORT, TEXT_PERCENT, TEXT_PERCENT},
		MINIMAL = {TEXT_SHORT, TEXT_PERCENT, TEXT_NONE},
		DEFICIT = {TEXT_DEF, TEXT_DEF, TEXT_NONE},
	}

	function K.PostUpdateHealth(Health, unit, cur, max)
		if not unit then return end -- </ Blizz bug in 7.1 > --

		local absent = not UnitIsConnected(unit) and PLAYER_OFFLINE or UnitIsGhost(unit) and GetSpellInfo(8326) or UnitIsDead(unit) and DEAD
		local self = Health:GetParent()
		local uconfig = ns.config[self.MatchUnit]

		if (self.Portrait) then
			UpdatePortraitColor(self, unit, cur, max)
		end

		if (self.Name) and (self.Name.Bg) then -- </ For boss frames > --
			self.Name.Bg:SetVertexColor(UnitSelectionColor(unit))
		end

		if absent then
			Health:SetStatusBarColor(0.5, 0.5, 0.5)
			if Health.Value then
				Health.Value:SetText(absent)
			end
			return
		end

		if not cur then
			cur = UnitHealth(unit)
			max = UnitHealthMax(unit) or 1
		end

		if uconfig.HealthTag == "DISABLE" then
			Health.Value:SetText(nil)
		elseif self.isMouseOver then
			SetValueText(Health.Value, tagtable[uconfig.HealthTag][1], cur, max, 1, 1, 1)
		elseif cur < max then
			SetValueText(Health.Value, tagtable[uconfig.HealthTag][2], cur, max, 1, 1, 1)
		else
			SetValueText(Health.Value, tagtable[uconfig.HealthTag][3], cur, max, 1, 1, 1)
		end
	end
end

-- </ PostPower update > --
do
	local tagtable = {
		NUMERIC	= {TEXT_MINMAX, TEXT_SHORT, TEXT_MAX},
		PERCENT	= {TEXT_SHORT, TEXT_PERCENT, TEXT_PERCENT},
		MINIMAL	= {TEXT_SHORT, TEXT_PERCENT, TEXT_NONE},
	}

	function K.PostUpdatePower(Power, unit, cur, max)
		local self = Power:GetParent()
		local uconfig = ns.config[self.MatchUnit]

		if (UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)) or (max == 0) then
			Power:SetValue(0)
			if Power.Value then
				Power.Value:SetText("")
			end
			return
		end

		if not Power.Value then return end

		if (not cur) then
			max = UnitPower(unit) or 1
			cur = UnitPowerMax(unit)
		end

		if uconfig.PowerTag == "DISABLE" then
			Power.Value:SetText(nil)
		elseif self.isMouseOver then
			SetValueText(Power.Value, tagtable[uconfig.PowerTag][1], cur, max, 1, 1, 1)
		elseif cur < max then
			SetValueText(Power.Value, tagtable[uconfig.PowerTag][2], cur, max, 1, 1, 1)
		else
			SetValueText(Power.Value, tagtable[uconfig.PowerTag][3], cur, max, 1, 1, 1)
		end
	end
end

-- </ Mouseover enter > --
function K.UnitFrame_OnEnter(self)
	if self.__owner then
		self = self.__owner
	end
	if not self:IsEnabled() then return end -- </ arena prep > --

	UnitFrame_OnEnter(self)

	self.isMouseOver = true
	if self.mouseovers then
		for _, text in pairs (self.mouseovers) do
			text:ForceUpdate()
		end
	end

	if (self.AdditionalPower and self.AdditionalPower.Value) then
		self.AdditionalPower.Value:Show()
	end
end

-- </ Mouseover leave > --
function K.UnitFrame_OnLeave(self)
	if self.__owner then
		self = self.__owner
	end
	if not self:IsEnabled() then return end -- </ arena prep > --
	UnitFrame_OnLeave(self)

	self.isMouseOver = nil
	if self.mouseovers then
		for _, text in pairs (self.mouseovers) do
			text:ForceUpdate()
		end
	end

	if (self.AdditionalPower and self.AdditionalPower.Value) then
		self.AdditionalPower.Value:Hide()
	end
end

-- </ Statusbar functions > --
function K.CreateStatusBar(self, noBG)
	local StatusBar = CreateFrame("StatusBar", "oUFKkthnxStatusBar", self) -- global name to avoid Blizzard /fstack error
	StatusBar:SetStatusBarTexture(C.Media.Texture)

	StatusBar.Texture = StatusBar:GetStatusBarTexture()
	StatusBar.Texture:SetDrawLayer("BORDER")
	StatusBar.Texture:SetHorizTile(false)
	StatusBar.Texture:SetVertTile(false)

	if not noBG then
		StatusBar.BG = StatusBar:CreateTexture(nil, "BACKGROUND")
		StatusBar.BG:SetTexture(C.Media.Blank)
		StatusBar.BG:SetColorTexture(unpack(C.Media.Backdrop_Color))
		StatusBar.BG:SetAllPoints(true)
	end

	local SmoothBar = self.SmoothBar or self.__owner and self.__owner.SmoothBar
	if SmoothBar and C.Unitframe.Smooth then
		SmoothBar(nil, StatusBar) -- nil should be self but isn't used
		StatusBar.__smooth = true
	end

	return StatusBar
end

-- </ AuraWatch > --
local CountOffSets = {
	TOPLEFT = {6, 1},
	TOPRIGHT = {-6, 1},
	BOTTOMLEFT = {6, 1},
	BOTTOMRIGHT = {-6, 1},
	LEFT = {6, 1},
	RIGHT = {-6, 1},
	TOP = {0, 0},
	BOTTOM = {0, 0},
}

function K.CreateAuraWatchIcon(self, icon)
	icon:SetBackdrop(K.TwoPixelBorder)
	icon.icon:SetPoint("TOPLEFT", icon, 1, -1)
	icon.icon:SetPoint("BOTTOMRIGHT", icon, -1, 1)
	icon.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon.icon:SetDrawLayer("ARTWORK")
	if icon.cd then
		icon.cd:SetReverse(true)
	end
	icon.overlay:SetTexture()
end

function K.CreateAuraWatch(self, unit)
	local auras = CreateFrame("Frame", nil, self)
	auras:SetPoint("TOPLEFT", self.Health, 0, 0)
	auras:SetPoint("BOTTOMRIGHT", self.Health, 0, 0)
	auras.icons = {}
	auras.PostCreateIcon = K.CreateAuraWatchIcon

	local buffs = {}
	if K.RaidBuffs["ALL"] then
		for key, value in pairs(K.RaidBuffs["ALL"]) do
			tinsert(buffs, value)
		end
	end

	if K.RaidBuffs[K.Class] then
		for key, value in pairs(K.RaidBuffs[K.Class]) do
			tinsert(buffs, value)
		end
	end

	if buffs then
		for key, spell in pairs(buffs) do
			local icon = CreateFrame("Frame", nil, auras)
			icon.spellID = spell[1]
			icon.anyUnit = spell[4]
			icon.strictMatching = spell[5]
			icon:SetWidth(6)
			icon:SetHeight(6)
			icon:SetPoint(spell[2], 0, 0)

			local tex = icon:CreateTexture(nil, "OVERLAY")
			tex:SetAllPoints(icon)
			tex:SetTexture(C.Media.Blank)
			if spell[3] then
				tex:SetVertexColor(unpack(spell[3]))
			else
				tex:SetVertexColor(0.8, 0.8, 0.8)
			end

			local count = K.SetFontString(icon, C.Media.Font, C.Media.Font_Size - 2, C.Media.Font_Style, "CENTER")
			count:SetPoint("CENTER", unpack(CountOffSets[spell[2]]))
			icon.count = count

			auras.icons[spell[1]] = icon
		end
	end

	self.AuraWatch = auras
end

-- </ All unitframe castbar functions > --
local ticks = {}
function K.HideTicks()
	for i = 1, #ticks do
		ticks[i]:Hide()
	end
end

function K.SetCastTicks(self, numTicks, extraTickRatio)
	-- Adjust tick heights
	self.tickHeight = self:GetHeight()

	extraTickRatio = extraTickRatio or 0
	K.HideTicks()
	if numTicks and numTicks <= 0 then return end;
	local w = self:GetWidth()
	local d = w / (numTicks + extraTickRatio)
	for i = 1, numTicks do
		if not ticks[i] then
			ticks[i] = self:CreateTexture(nil, "OVERLAY")
			ticks[i]:SetTexture(C.Media.Texture)
			ticks[i]:SetVertexColor(0, 0, 0, 0.8)
			ticks[i]:SetWidth(2) -- We could use 1
		end

		ticks[i]:SetHeight(self.tickHeight)

		ticks[i]:ClearAllPoints()
		ticks[i]:SetPoint("RIGHT", self, "LEFT", d * i, 0)
		ticks[i]:Show()
	end
end

local MageSpellName = GetSpellInfo(5143) --Arcane Missiles
local MageBuffName = GetSpellInfo(166872) --4p T17 bonus proc for arcane

function K.PostCastStart(self, unit, name)
	if unit == "vehicle" then unit = "player" end

	-- if C.Unitframe.DisplayTarget and self.curTarget then
	-- 	self.Text:SetText(name.." --> "..self.curTarget)
	-- else
	-- 	self.Text:SetText(name)
	-- end

	if unit == "player" and C.Unitframe.CastbarLatency == true and self.Latency then
		local _, _, _, lag = GetNetStats()
		local latency = GetTime() - (self.castSent or 0)
		lag = lag / 1e3 > self.max and self.max or lag / 1e3
		latency = latency > self.max and lag or latency
		self.Latency:SetText(("%dms"):format(latency * 1e3))
		self.castSent = nil
	end

	if C.Unitframe.CastbarTicks and unit == "player" then
		local baseTicks = K.ChannelTicks[name]

		-- Detect channeling spell and if it's the same as the previously channeled one
		if baseTicks and name == self.prevSpellCast then
			self.chainChannel = true
		elseif baseTicks then
			self.chainChannel = nil
			self.prevSpellCast = name
		end

		if baseTicks and K.ChannelTicksSize[name] and K.HastedChannelTicks[name] then
			local tickIncRate = 1 / baseTicks
			local curHaste = UnitSpellHaste("player") * 0.01
			local firstTickInc = tickIncRate / 2
			local bonusTicks = 0
			if curHaste >= firstTickInc then
				bonusTicks = bonusTicks + 1
			end

			local x = tonumber(K.Round(firstTickInc + tickIncRate, 2))
			while curHaste >= x do
				x = tonumber(K.Round(firstTickInc + (tickIncRate * bonusTicks), 2))
				if curHaste >= x then
					bonusTicks = bonusTicks + 1
				end
			end

			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			local extraTickRatio = extraTick / hastedTickSize

			K.SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			local extraTickRatio = extraTick / hastedTickSize

			K.SetCastTicks(self, baseTicks, extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			K.SetCastTicks(self, baseTicks)
		else
			K.HideTicks()
		end
	elseif unit == "player" then
		K.HideTicks()
	end

	-- Colors, you know Colours? ;)
	local color
	local r, g, b = 1.0, 0.7, 0.0, 0.5

	self:SetBackdropBorderColor(1, 1, 1)
	if C.Unitframe.CastbarIcon then
		self.Button:SetBackdropBorderColor(1, 1, 1)
	end

	if C.Unitframe.CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = K.Colors.class[class]
	elseif C.Unitframe.CastUnitReaction and UnitReaction(unit, "player") then
		color = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if (color) then
		r, g, b = color[1], color[2], color[3]
	end

	if self.interrupt and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = unpack(K.Colors.uninterruptible)
		self:SetBackdropBorderColor(r, g, b)
		if C.Unitframe.CastbarIcon then
			self.Button:SetBackdropBorderColor(r, g, b)
		end
	end

	self:SetStatusBarColor(r, g, b)
	if self.Background:IsShown() then
		self.Background:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
	end
end

function K.PostCastStop(self)
	self.chainChannel = nil
	self.prevSpellCast = nil
end

function K.PostChannelUpdate(self, unit, name)
	if not (unit == "player" or unit == "vehicle") then return end

	if C.Unitframe.CastbarTicks then
		local baseTicks = K.ChannelTicks[name]

		if baseTicks and K.ChannelTicksSize[name] and K.HastedChannelTicks[name] then
			local tickIncRate = 1 / baseTicks
			local curHaste = UnitSpellHaste("player") * 0.01
			local firstTickInc = tickIncRate / 2
			local bonusTicks = 0
			if curHaste >= firstTickInc then
				bonusTicks = bonusTicks + 1
			end

			local x = tonumber(K.Round(firstTickInc + tickIncRate, 2))
			while curHaste >= x do
				x = tonumber(K.Round(firstTickInc + (tickIncRate * bonusTicks), 2))
				if curHaste >= x then
					bonusTicks = bonusTicks + 1
				end
			end

			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			K.SetCastTicks(self, baseTicks + bonusTicks, self.extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			K.SetCastTicks(self, baseTicks, self.extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			if self.chainChannel then
				baseTicks = baseTicks + 1
			end
			K.SetCastTicks(self, baseTicks)
		else
			K.HideTicks()
		end
	else
		K.HideTicks()
	end
end

function K.PostCastInterruptible(self, unit)
	if unit == "vehicle" or unit == "player" then return end

	-- Colors, you know Colours? ;)
	local color
	local r, g, b = 1.0, 0.7, 0.0, 0.5

	self:SetBackdropBorderColor(1, 1, 1)
	if C.Unitframe.CastbarIcon then
		self.Button:SetBackdropBorderColor(1, 1, 1)
	end

	if C.Unitframe.CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = K.Colors.class[class]
	elseif C.Unitframe.CastUnitReaction and UnitReaction(unit, "player") then
		color = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if (color) then
		r, g, b = color[1], color[2], color[3]
	end

	if self.interrupt and UnitCanAttack("player", unit) then
		r, g, b = unpack(K.Colors.uninterruptible)
		self:SetBackdropBorderColor(r, g, b)
		if C.Unitframe.CastbarIcon then
			self.Button:SetBackdropBorderColor(r, g, b)
		end
	end

	self:SetStatusBarColor(r, g, b)
	if self.Background:IsShown() then
		self.Background:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
	end
end

function K.PostCastNotInterruptible(self)
	self:SetStatusBarColor(unpack(K.Colors.uninterruptible))
end

function K.CustomDelayText(self, duration)
	self.Time:SetFormattedText("%.1f|cffff0000%.1f|r", self.max - duration, -self.delay)
end

function K.CustomTimeText(self, duration)
	self.Time:SetFormattedText("%.1f", self.max - duration)
end