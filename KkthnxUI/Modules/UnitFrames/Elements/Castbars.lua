local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true or C["Unitframe"].Castbars ~= true then return end

local _G = _G
local math_abs = math.abs
local pairs = pairs
local select = select
local tonumber = tonumber
local unpack = unpack
local math_min = math.min

-- Wow API
local CreateFrame = _G.CreateFrame
local GetNetStats = _G.GetNetStats
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local UnitBuff = _G.UnitBuff
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitIsPlayer = _G.UnitIsPlayer
local UnitReaction = _G.UnitReaction
local UnitSpellHaste = _G.UnitSpellHaste

local Movers = K.Movers

local CastbarFont = K.GetFont(C["Unitframe"].Font)
local CastbarTexture = K.GetTexture(C["Unitframe"].Texture)

-- All unit-frame Cast bar functions
local ticks = {}
local function HideTicks()
	for i = 1, #ticks do
		ticks[i]:Hide()
	end
end

local function SetCastTicks(self, numTicks, extraTickRatio)
	-- Adjust tick heights
	self.tickHeight = self:GetHeight()

	extraTickRatio = extraTickRatio or 0
	HideTicks()
	if numTicks and numTicks <= 0 then return end
	local w = self:GetWidth()
	local d = w / (numTicks + extraTickRatio)
	for i = 1, numTicks do
		if not ticks[i] then
			ticks[i] = self:CreateTexture(nil, "OVERLAY")
			ticks[i]:SetTexture(CastbarTexture)
			ticks[i]:SetVertexColor(0, 0, 0, 0.8)
			ticks[i]:SetWidth(2) -- We could use 1
		end

		ticks[i]:SetHeight(self.tickHeight)

		ticks[i]:ClearAllPoints()
		ticks[i]:SetPoint("RIGHT", self, "LEFT", d * i, 0)
		ticks[i]:Show()
	end
end

local MageSpellName = GetSpellInfo(5143) -- Arcane Missiles
local MageBuffName = GetSpellInfo(166872) -- 4p T17 bonus proc for arcane

local function PostCastStart(self, unit, name)
	if unit == "vehicle" then unit = "player" end

	self.Text:SetText(name)

	-- Get length of Time, then calculate available length for Text
	local timeWidth = self.Time:GetStringWidth()
	local textWidth = self:GetWidth() - timeWidth - 10
	local textStringWidth = self.Text:GetStringWidth()

	if timeWidth == 0 or textStringWidth == 0 then
		K.Delay(0.05, function() -- Delay may need tweaking
			textWidth = self:GetWidth() - self.Time:GetStringWidth() - 10
			textStringWidth = self.Text:GetStringWidth()
			if textWidth > 0 then self.Text:SetWidth(math_min(textWidth, textStringWidth)) end
		end)
	else
		self.Text:SetWidth(math_min(textWidth, textStringWidth))
	end

	self.Spark:SetSize(14, self:GetHeight() * 3.2)

	self.unit = unit

	if C["Unitframe"].CastbarTicks and unit == "player" then
		local baseTicks = K.ChannelTicks[name]

		-- Detect channeling spell and if it"s the same as the previously channeled one
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

			SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			local extraTickRatio = extraTick / hastedTickSize

			SetCastTicks(self, baseTicks, extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			SetCastTicks(self, baseTicks)
		else
			HideTicks()
		end
	elseif unit == "player" then
		HideTicks()
	end

	local colors = K.Colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C["Unitframe"].CastReactionColor and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.notInterruptible and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
end

local function PostCastStop(self)
	self.chainChannel = nil
	self.prevSpellCast = nil
end

local function PostCastFailed(self)
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetStatusBarColor(1, 0, 0)

	self.Spark:SetPoint("CENTER", self, "RIGHT")

	self.Time:SetText("")
end

local function PostChannelUpdate(self, unit, name)
	if not (unit == "player" or unit == "vehicle") then return end

	if C["Unitframe"].CastbarTicks then
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

			SetCastTicks(self, baseTicks + bonusTicks, self.extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			SetCastTicks(self, baseTicks, self.extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			if self.chainChannel then
				baseTicks = baseTicks + 1
			end
			SetCastTicks(self, baseTicks)
		else
			HideTicks()
		end
	else
		HideTicks()
	end
end

local function PostCastInterruptible(self, unit)
	if unit == "vehicle" or unit == "player" then return end

	local colors = K.Colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C["Unitframe"].CastReactionColor and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
end

local function PostCastNotInterruptible(self)
	local colors = K.Colors
	self:SetStatusBarColor(colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3])
end

local function CustomCastDelayText(self, duration)
	if self.casting then
		duration = self.max - duration
	end

	if self.channeling then
		self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(duration, self.delay))
	else
		self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(math_abs(duration - self.max), "+", self.delay))
	end
end

local function CustomTimeText(self, duration)
	if self.max > 600 then
		return self.Time:SetText("")
	end

	if self.channeling then
		self.Time:SetText(("%.1f"):format(duration))
	else
		self.Time:SetText(("%.1f"):format(math_abs(duration - self.max)))
	end
end

function K.CreateCastBar(self, unit)
	local castbar = CreateFrame("StatusBar", "$parentCastbar", self)
	castbar:SetStatusBarTexture(CastbarTexture)
	castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
	castbar:SetClampedToScreen(true)
	castbar:SetTemplate("Transparent", true)

	local spark = castbar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Spark)
	spark:SetBlendMode("ADD")
	castbar.Spark = spark

	local shield = castbar:CreateTexture(nil, "OVERLAY")
	shield:SetTexture[[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]]
	shield:SetPoint("LEFT", castbar, "RIGHT", -4, 12)
	castbar.Shield = shield

	if unit == "player" then
		castbar:SetPoint("BOTTOM", "ActionBarAnchor", "TOP", 0, 203)
		K.Movers:RegisterFrame(castbar)
	elseif unit == "target" then
		castbar:SetPoint("BOTTOM", "oUF_PlayerCastbar", "TOP", 0, 6)
		K.Movers:RegisterFrame(castbar)
	elseif unit == "focus" or unit == "boss" then
		castbar:SetPoint("LEFT", 4, 0)
		castbar:SetPoint("RIGHT", -28, 0)
		castbar:SetPoint("TOP", 0, 20)
		castbar:SetHeight(18)
	end

	if (unit == "player") then
		local safeZone = castbar:CreateTexture(nil, "OVERLAY")
		safeZone:SetTexture(CastbarTexture)
		safeZone:SetVertexColor(0.69, 0.31, 0.31)
		castbar.SafeZone = safeZone
	end

	if (unit == "player" or unit == "target" or unit == "focus") then
		local time = castbar:CreateFontString(nil, "OVERLAY", CastbarFont)
		time:SetPoint("RIGHT", -3.5, 0)
		if K.Class == "PRIEST" then
			time:SetTextColor(0.84, 0.75, 0.65)
		end
		time:SetJustifyH("RIGHT")
		castbar.Time = time

		castbar.CustomTimeText = CustomTimeText
		castbar.CustomDelayText = CustomCastDelayText

		local text = castbar:CreateFontString(nil, "OVERLAY", CastbarFont)
		text:SetPoint("LEFT", 3.5, 0)
		text:SetPoint("RIGHT", time, "LEFT", -3.5, 0)
		if K.Class == "PRIEST" then
			text:SetTextColor(0.84, 0.75, 0.65)
		end
		text:SetJustifyH("LEFT")
		text:SetWordWrap(false)
		castbar.Text = text
	end

	if (unit ~= "pet") then
		local button = CreateFrame("Frame", nil, castbar)
		button:SetSize(20, 20)
		button:SetTemplate("Transparent", true)

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetSize(castbar:GetHeight(), castbar:GetHeight())
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button:SetAllPoints(icon)
		if (unit == "player") then
			icon:SetPoint("LEFT", castbar, "RIGHT", 6, 0)
		elseif (unit == "target") then
			icon:SetPoint("RIGHT", castbar, "LEFT", -6, 0)
		else
			icon:SetPoint("LEFT", castbar, "RIGHT", 6, 0)
		end

		castbar.Icon = icon
	end

	castbar.timeToHold = 0.4
	castbar.PostCastStart = PostCastStart
	castbar.PostChannelStart = PostCastStart
	castbar.PostCastStop = PostCastStop
	castbar.PostChannelStop = PostCastStop
	castbar.PostCastFailed = PostCastFailed
	castbar.PostCastInterrupted = PostCastFailed
	castbar.PostChannelUpdate = PostChannelUpdate
	castbar.PostCastInterruptible = PostCastInterruptible
	castbar.PostCastNotInterruptible = PostCastNotInterruptible

	self.Castbar = castbar
end