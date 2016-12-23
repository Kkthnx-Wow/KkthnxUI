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
local GetSpellInfo = GetSpellInfo
local UnitClass = UnitClass
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsGhost = UnitIsGhost
local UnitIsPlayer = UnitIsPlayer
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitSelectionColor = UnitSelectionColor

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PLAYER_OFFLINE, DEAD, UnitFrame_OnLeave, UnitFrame_OnEnter

local _, ns = ...
local oUF = ns.oUF or oUF
local colors = K.Colors

function K.UnitframeValue(self)
	if self <= 999 then
		return self
	end
	local Value
	if self >= 1000000 then
		Value = format("%.1fm", self/1000000)
		return Value
	elseif self >= 1000 then
		Value = format("%.1fk", self/1000)
		return Value
	end
end

function K.cUnit(unit)
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
			if (unit ~= "player") then
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
		s = format("%s", cur > 0 and K.UnitframeValue(cur) or "")
	elseif tag == TEXT_LONG then
		s = format("%s - %.1f%%", K.UnitframeValue(cur), cur / max * 100)
	elseif tag == TEXT_MINMAX then
		s = format("%s/%s", K.UnitframeValue(cur), K.UnitframeValue(max))
	elseif tag == TEXT_MAX then
		s = format("%s", K.UnitframeValue(max))
	elseif tag == TEXT_DEF then
		s = format("%s", (cur == max and "" or "-"..K.UnitframeValue(max - cur)))
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
		local uconfig = ns.config[self.cUnit]

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
		local uconfig = ns.config[self.cUnit]

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
function K.CreateStatusBar(parent, layer, name, AddBackdrop)
	if type(layer) ~= "string" then layer = "BORDER" end
	local bar = CreateFrame("StatusBar", name, parent)
	bar:SetStatusBarTexture(C.Media.Texture, layer)
	bar.texture = C.Media.Texture

	if AddBackdrop then
		bar:SetBackdrop({bgFile = C.Media.Blank})
		local r,g,b,a = unpack(C.Media.Backdrop_Color)
		bar:SetBackdropColor(r, g, b, a)
	end

	return bar
end

K.RaidBuffsTrackingPosition = {
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
	icon.icon:SetPoint("TOPLEFT", 1, -1)
	icon.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	icon.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	icon.icon:SetDrawLayer("ARTWORK")

	if (icon.cd) then
		icon.cd:SetHideCountdownNumbers(true)
		icon.cd:SetReverse(true)
	end

	icon.overlay:SetTexture()
end

-- </ Create the icon > --
function K.CreateAuraWatch(self)
	local Class = select(2, UnitClass("player"))
	local Auras = CreateFrame("Frame", nil, self)
	Auras:SetPoint("TOPLEFT", self.Health, 2, -2)
	Auras:SetPoint("BOTTOMRIGHT", self.Health, -2, 2)
	Auras.presentAlpha = 1
	Auras.missingAlpha = 0
	Auras.icons = {}
	Auras.PostCreateIcon = K.CreateAuraWatchIcon
	Auras.strictMatching = true

	if (not C.Raidframe.AuraWatchTimers) then
		Auras.hideCooldown = true
	end

	local buffs = {}
	if (K.RaidBuffsTracking["ALL"]) then
		for key, value in pairs(K.RaidBuffsTracking["ALL"]) do
			tinsert(buffs, value)
		end
	end

	if (K.RaidBuffsTracking[Class]) then
		for key, value in pairs(K.RaidBuffsTracking[Class]) do
			tinsert(buffs, value)
		end
	end

	-- </ Cornerbuffs > --
	if buffs then
		for key, spell in pairs(buffs) do
			local Icon = CreateFrame("Frame", nil, Auras)
			Icon.spellID = spell[1]
			Icon.anyUnit = spell[4]
			Icon:SetWidth(6)
			Icon:SetHeight(6)
			Icon:SetPoint(spell[2], 0, 0)
			local Texture = Icon:CreateTexture(nil, "OVERLAY")
			Texture:SetAllPoints(Icon)
			Texture:SetTexture(C.Media.Blank)

			if (spell[3]) then
				Texture:SetVertexColor(unpack(spell[3]))
			else
				Texture:SetVertexColor(0.8, 0.8, 0.8)
			end

			local Count = Icon:CreateFontString(nil, "OVERLAY")
			Count:SetFont(C.Media.Font, 9, "THINOUTLINE")
			Count:SetPoint("CENTER", unpack(K.RaidBuffsTrackingPosition[spell[2]]))
			Icon.count = Count
			Auras.icons[spell[1]] = Icon
		end
	end

	self.AuraWatch = Auras
end

-- </ Castbar functions > --
local ticks = {}
local channelingTicks = K.CastBarTicks

local setBarTicks = function(Castbar, ticknum)
	for k, v in pairs(ticks) do
		v:Hide()
	end
	if ticknum and ticknum > 0 then
		local delta = Castbar:GetWidth() / ticknum
		for k = 1, ticknum do
			if not ticks[k] then
				ticks[k] = Castbar:CreateTexture(nil, "OVERLAY")
				ticks[k]:SetTexture(C.Media.Blank)
				ticks[k]:SetVertexColor(unpack(C.Media.Border_Color))
				ticks[k]:SetWidth(1)
				ticks[k]:SetHeight(Castbar:GetHeight())
				ticks[k]:SetDrawLayer("OVERLAY", 7)
			end
			ticks[k]:ClearAllPoints()
			ticks[k]:SetPoint("CENTER", Castbar, "RIGHT", -delta * k, 0)
			ticks[k]:Show()
		end
	end
end

K.PostCastStart = function(Castbar, unit, name, castid)
	Castbar.channeling = false
	if unit == "vehicle" then unit = "player" end

	if unit == "player" and C.Unitframe.CastbarLatency == true and Castbar.Latency then
		local _, _, _, lag = GetNetStats()
		local latency = GetTime() - (Castbar.castSent or 0)
		lag = lag / 1e3 > Castbar.max and Castbar.max or lag / 1e3
		latency = latency > Castbar.max and lag or latency
		Castbar.Latency:SetText(("%dms"):format(latency * 1e3))
		Castbar.SafeZone:SetWidth(Castbar:GetWidth() * latency / Castbar.max)
		Castbar.SafeZone:ClearAllPoints()
		Castbar.SafeZone:SetPoint("TOPRIGHT")
		Castbar.SafeZone:SetPoint("BOTTOMRIGHT")
		Castbar.castSent = nil
	end

	if unit == "player" and C.Unitframe.CastbarTicks == true then
		setBarTicks(Castbar, 0)
	end

	local r, g, b, color
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = K.Colors.class[class]
	else
		local reaction = K.Colors.reaction[UnitReaction(unit, "player")]
		if reaction then
			r, g, b = reaction[1], reaction[2], reaction[3]
		else
			r, g, b = 1, 1, 1
		end
	end

	if color then
		r, g, b = color[1], color[2], color[3]
	end

	if Castbar.interrupt and UnitCanAttack("player", unit) then
		Castbar:SetStatusBarColor(0.87 * 0.8, 0.37 * 0.8, 0.37 * 0.8)
		Castbar.bg:SetVertexColor(0.87 * 0.1, 0.37 * 0.1, 0.37 * 0.1, 0.6)
		Castbar.Overlay:SetBackdropBorderColor(0.87, 0.37, 0.37)
		if C.Unitframe.CastbarIcon == true and (unit == "target" or unit == "focus") then
			Castbar.Button:SetBackdropBorderColor(0.87, 0.37, 0.37)
		end
	else
		if unit == "pet" or unit == "vehicle" then
			local _, class = UnitClass("player")
			local r, g, b = unpack(K.Colors.class[class])
			if b then
				Castbar:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
				Castbar.bg:SetVertexColor(r * 0.1, g * 0.1, b * 0.1, 0.9)
			end
		else
			Castbar:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
			Castbar.bg:SetVertexColor(r * 0.1, g * 0.1, b * 0.1, 0.9)
		end
		Castbar.Overlay:SetBackdropBorderColor(unpack(C.Media.Border_Color))
		if C.Unitframe.CastbarIcon == true and (unit == "target" or unit == "focus") then
			Castbar.Button:SetBackdropBorderColor(unpack(C.Media.Border_Color))
		end
	end
end

K.PostChannelStart = function(Castbar, unit, name)
	Castbar.channeling = true
	if unit == "vehicle" then unit = "player" end

	if unit == "player" and C.Unitframe.CastbarLatency == true and Castbar.Latency then
		local _, _, _, lag = GetNetStats()
		local latency = GetTime() - (Castbar.castSent or 0)
		lag = lag / 1e3 > Castbar.max and Castbar.max or lag / 1e3
		latency = latency > Castbar.max and lag or latency
		Castbar.Latency:SetText(("%dms"):format(latency * 1e3))
		Castbar.SafeZone:SetWidth(Castbar:GetWidth() * latency / Castbar.max)
		Castbar.SafeZone:ClearAllPoints()
		Castbar.SafeZone:SetPoint("TOPLEFT")
		Castbar.SafeZone:SetPoint("BOTTOMLEFT")
		Castbar.castSent = nil
	end

	if unit == "player" and C.Unitframe.CastbarTicks == true then
		local spell = UnitChannelInfo(unit)
		Castbar.channelingTicks = channelingTicks[spell] or 0
		setBarTicks(Castbar, Castbar.channelingTicks)
	end

	local r, g, b, color
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		color = K.Colors.class[class]
	else
		local reaction = K.Colors.reaction[UnitReaction(unit, "player")]
		if reaction then
			r, g, b = reaction[1], reaction[2], reaction[3]
		else
			r, g, b = 1, 1, 1
		end
	end

	if color then
		r, g, b = color[1], color[2], color[3]
	end

	if Castbar.interrupt and UnitCanAttack("player", unit) then
		Castbar:SetStatusBarColor(0.87 * 0.8, 0.37 * 0.8, 0.37 * 0.8)
		Castbar.bg:SetVertexColor(0 * 0.1, 0 * 0.1, 0 * 0.1, 0.9)
		Castbar.Overlay:SetBackdropBorderColor(0.87, 0.37, 0.37)
		if C.Unitframe.CastbarIcon == true and (unit == "target" or unit == "focus") then
			Castbar.Button:SetBackdropBorderColor(0.87, 0.37, 0.37)
		end
	else
		if unit == "pet" or unit == "vehicle" then
			local _, class = UnitClass("player")
			local r, g, b = unpack(K.Colors.class[class])
			if b then
				Castbar:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
				Castbar.bg:SetVertexColor(r * 0.1, g * 0.1, b * 0.1, 0.9)
			end
		else
			Castbar:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
			Castbar.bg:SetVertexColor(r * 0.1, g * 0.1, b * 0.1, 0.9)
		end
		Castbar.Overlay:SetBackdropBorderColor(unpack(C.Media.Border_Color))
		if C.Unitframe.CastbarIcon == true and (unit == "target" or unit == "focus") then
			Castbar.Button:SetBackdropBorderColor(unpack(C.Media.Border_Color))
		end
	end
end

K.CustomCastTimeText = function(self, duration)
	self.Time:SetText(("%.1f / %.1f"):format(self.channeling and duration or self.max - duration, self.max))
end

K.CustomCastDelayText = function(self, duration)
	self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(self.channeling and duration or self.max - duration, self.channeling and "-" or "+", abs(self.delay)))
end