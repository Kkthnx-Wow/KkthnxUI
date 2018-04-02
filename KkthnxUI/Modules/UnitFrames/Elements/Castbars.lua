local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true or C["Unitframe"].Castbars ~= true then return end

local _G = _G
local math_abs = math.abs
local math_min = math.min
local tonumber = tonumber

-- Wow API
local CreateFrame = _G.CreateFrame
local GetSpellInfo = _G.GetSpellInfo
local UnitBuff = _G.UnitBuff
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitIsPlayer = _G.UnitIsPlayer
local UnitReaction = _G.UnitReaction
local UnitSpellHaste = _G.UnitSpellHaste

local Movers = K.Movers

local CastbarFont = K.GetFont(C["Unitframe"].Font)
local CastbarTexture = K.GetTexture(C["Unitframe"].Texture)

local MageSpellName = GetSpellInfo(5143) -- Arcane Missiles
local MageBuffName = GetSpellInfo(166872) -- 4p T17 bonus proc for arcane

-- All unitframe Cast bar functions
local ticks = {}
local function HideTicks()
	for i = 1, #ticks do
		ticks[i]:Hide()
	end
end

local function SetCastTicks(castbar, numTicks, extraTickRatio)
	-- Adjust tick heights
	castbar.tickHeight = castbar:GetHeight()

	extraTickRatio = extraTickRatio or 0
	HideTicks()
	if numTicks and numTicks <= 0 then return end
	local w = castbar:GetWidth()
	local d = w / (numTicks + extraTickRatio)
	for i = 1, numTicks do
		if not ticks[i] then
			ticks[i] = castbar:CreateTexture(nil, "OVERLAY")
			ticks[i]:SetTexture(CastbarTexture)
			ticks[i]:SetVertexColor(0, 0, 0, 0.8)
			ticks[i]:SetWidth(2) -- We could use 1
		end

		ticks[i]:SetHeight(castbar.tickHeight)

		ticks[i]:ClearAllPoints()
		ticks[i]:SetPoint("RIGHT", castbar, "LEFT", d * i, 0)
		ticks[i]:Show()
	end
end

local function PostCastStart(castbar, unit, name)
	if not C["Unitframe"].Castbars then return end

	if unit == "vehicle" then unit = "player" end

	local text = castbar.Text
	if (text) then
		castbar.Text:SetText(name)
	end

	-- Get length of Time, then calculate available length for Text
	local timeWidth = castbar.Time:GetStringWidth()
	local textWidth = castbar:GetWidth() - timeWidth - 10
	local textStringWidth = castbar.Text:GetStringWidth()

	if timeWidth == 0 or textStringWidth == 0 then
		K.Delay(0.05, function() -- Delay may need tweaking
			textWidth = castbar:GetWidth() - castbar.Time:GetStringWidth() - 10
			textStringWidth = castbar.Text:GetStringWidth()
			if textWidth > 0 then castbar.Text:SetWidth(math_min(textWidth, textStringWidth)) end
		end)
	else
		castbar.Text:SetWidth(math_min(textWidth, textStringWidth))
	end

	castbar.Spark:SetSize(128, castbar:GetHeight())

	castbar.unit = unit

	if C["Unitframe"].CastbarTicks and unit == "player" then
		local baseTicks = K.ChannelTicks[name]

		-- Detect channeling spell and if it"s the same as the previously channeled one
		if baseTicks and name == castbar.prevSpellCast then
			castbar.chainChannel = true
		elseif baseTicks then
			castbar.chainChannel = nil
			castbar.prevSpellCast = name
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
			local extraTick = castbar.max - hastedTickSize * (baseTicks + bonusTicks)
			local extraTickRatio = extraTick / hastedTickSize

			SetCastTicks(castbar, baseTicks + bonusTicks, extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = castbar.max - hastedTickSize * (baseTicks)
			local extraTickRatio = extraTick / hastedTickSize

			SetCastTicks(castbar, baseTicks, extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			SetCastTicks(castbar, baseTicks)
		else
			HideTicks()
		end
	elseif unit == "player" then
		HideTicks()
	end

	local colors = K.Colors
	local r, g, b = colors.status.castColor[1], colors.status.castColor[2], colors.status.castColor[3]

	local t
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C["Unitframe"].CastReactionColor and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if (t) then
		r, g, b = t[1], t[2], t[3]
	end

	if castbar.notInterruptible and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3]
	end

	castbar:SetStatusBarColor(r, g, b)
end

local function PostCastFailedOrInterrupted(castbar, unit, name, castID)
	castbar:SetStatusBarColor(1, 0, 0)
	castbar:SetValue(castbar.max)

	local spark = castbar.Spark
	if (spark) then
		spark:SetPoint("CENTER", castbar, "RIGHT")
		spark:SetWidth(0.001) -- This should hide it without an issue.
	end

	local time = castbar.Time
	if (time) then
		time:SetText("")
	end
end

local function PostCastStop(castbar)
	castbar.chainChannel = nil
	castbar.prevSpellCast = nil
end

local function PostChannelUpdate(castbar, unit, name)
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
			local extraTick = castbar.max - hastedTickSize * (baseTicks + bonusTicks)
			if castbar.chainChannel then
				castbar.extraTickRatio = extraTick / hastedTickSize
				castbar.chainChannel = nil
			end

			SetCastTicks(castbar, baseTicks + bonusTicks, castbar.extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = castbar.max - hastedTickSize * (baseTicks)
			if castbar.chainChannel then
				castbar.extraTickRatio = extraTick / hastedTickSize
				castbar.chainChannel = nil
			end

			SetCastTicks(castbar, baseTicks, castbar.extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			if castbar.chainChannel then
				baseTicks = baseTicks + 1
			end
			SetCastTicks(castbar, baseTicks)
		else
			HideTicks()
		end
	else
		HideTicks()
	end
end

local function PostCastInterruptible(castbar, unit)
	if unit == "vehicle" or unit == "player" then return end

	local colors = K.Colors
	local r, g, b = colors.status.castColor[1], colors.status.castColor[2], colors.status.castColor[3]

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

	if castbar.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3]
	end

	castbar:SetStatusBarColor(r, g, b)
end

local function PostCastNotInterruptible(castbar)
	local colors = K.Colors
	castbar:SetStatusBarColor(colors.status.castNoInterrupt[1], colors.status.castNoInterrupt[2], colors.status.castNoInterrupt[3])
end

local function CustomCastDelayText(castbar, duration)
	if castbar.casting then
		duration = castbar.max - duration
	end

	if castbar.channeling then
		castbar.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(duration, castbar.delay))
	else
		castbar.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(math_abs(duration - castbar.max), "+", castbar.delay))
	end
end

local function CustomTimeText(castbar, duration)
	if castbar.max > 600 then
		return castbar.Time:SetText("")
	end

	if castbar.channeling then
		castbar.Time:SetText(("%.1f"):format(duration))
	else
		castbar.Time:SetText(("%.1f"):format(math_abs(duration - castbar.max)))
	end
end

function K.CreateCastBar(self, unit)
	unit = unit:match("^(%a-)%d+") or unit

	local castbar = CreateFrame("StatusBar", "$parentCastbar", self)
	castbar:SetStatusBarTexture(CastbarTexture)
	castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
	castbar:SetClampedToScreen(true)
	castbar:SetTemplate("Transparent", true)

	if (unit == "player") then
		castbar:SetPoint("BOTTOM", "ActionBarAnchor", "TOP", 0, 203)
		K.Movers:RegisterFrame(castbar)
	elseif unit == "target" then
		castbar:SetPoint("BOTTOM", "oUF_PlayerCastbar", "TOP", 0, 6)
		K.Movers:RegisterFrame(castbar)
	elseif (unit == "focus" or unit == "arena" or unit == "boss") then
		castbar:SetPoint("LEFT", 4, 0)
		castbar:SetPoint("RIGHT", -28, 0)
		castbar:SetPoint("TOP", 0, 20)
		castbar:SetHeight(18)
	end

	castbar.timeToHold = 0.4
	castbar.PostCastStart = PostCastStart
	castbar.PostChannelStart = PostCastStart
	castbar.PostCastStop = PostCastStop
	castbar.PostChannelStop = PostCastStop
	castbar.PostChannelUpdate = PostChannelUpdate
	castbar.PostCastInterruptible = PostCastInterruptible
	castbar.PostCastNotInterruptible = PostCastNotInterruptible
	castbar.PostCastFailed = PostCastFailedOrInterrupted
	castbar.PostCastInterrupted = PostCastFailedOrInterrupted

	local spark = castbar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Spark_128)
	spark:SetBlendMode("ADD")
	castbar.Spark = spark

	if (unit == "target") then
		local shield = castbar:CreateTexture(nil, "ARTWORK")
		shield:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CastBorderShield")
		shield:SetPoint("RIGHT", castbar, "LEFT", 34, 12)
		castbar.Shield = shield
	end

	if (unit == "player") then
		local safeZone = castbar:CreateTexture(nil, "ARTWORK")
		safeZone:SetTexture(CastbarTexture)
		safeZone:SetPoint("RIGHT")
		safeZone:SetPoint("TOP")
		safeZone:SetPoint("BOTTOM")
		safeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		safeZone:SetWidth(0.0001)
		castbar.SafeZone = safeZone
	end

	if (unit == "player" or unit == "target" or unit == "focus" or unit == "arena" or unit == "boss") then
		local time = castbar:CreateFontString(nil, "OVERLAY", CastbarFont)
		time:SetPoint("RIGHT", -3.5, 0)
		time:SetTextColor(0.84, 0.75, 0.65)
		time:SetJustifyH("RIGHT")
		castbar.Time = time

		castbar.CustomTimeText = CustomTimeText
		castbar.CustomDelayText = CustomCastDelayText

		local text = castbar:CreateFontString(nil, "OVERLAY", CastbarFont)
		text:SetPoint("LEFT", 3.5, 0)
		text:SetPoint("RIGHT", time, "LEFT", -3.5, 0)
		text:SetTextColor(0.84, 0.75, 0.65)
		text:SetJustifyH("LEFT")
		text:SetWordWrap(false)
		castbar.Text = text
	end

	if (unit ~= "pet" and C["Unitframe"].CastbarIcon) then
		local button = CreateFrame("Frame", nil, castbar)
		button:SetSize(20, 20)
		button:SetTemplate("Transparent", true)

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetSize(castbar:GetHeight(), castbar:GetHeight())
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button:SetAllPoints(icon)
		if (unit == "player") then
			icon:SetPoint("RIGHT", castbar, "LEFT", -6, 0)
		elseif (unit == "target") then
			icon:SetPoint("LEFT", castbar, "RIGHT", 6, 0)
		else
			icon:SetPoint("LEFT", castbar, "RIGHT", 6, 0)
		end

		castbar.Icon = icon
	end

	self.Castbar = castbar
end