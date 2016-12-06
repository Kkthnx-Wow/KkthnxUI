local K, C, L = select(2, ...):unpack()

-- Lua API
local abs = math.abs
local floor, ceil = math.floor, math.ceil
local format, find, gsub = format, string.find, string.gsub
local len = string.len
local match = string.match
local modf = math.modf
local print = print
local reverse = string.reverse
local strsub = string.sub
local tinsert, tremove = tinsert, tremove
local tonumber, type = tonumber, type
local unpack, select = unpack, select

-- Wow API
local CreateFrame = CreateFrame
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local GetCombatRatingBonus = GetCombatRatingBonus
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local GetNumWatchedTokens = GetNumWatchedTokens
local GetSpellInfo = GetSpellInfo
local IsEveryoneAssistant = IsEveryoneAssistant
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitStat, UnitAttackPower, UnitBuff = UnitStat, UnitAttackPower, UnitBuff

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, WEEKLY

local Locale = GetLocale()

K.Backdrop = {bgFile = C.Media.Blank, edgeFile = C.Media.Blizz, edgeSize = 14, insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}}
K.Border = {edgeFile = C.Media.Blizz, edgeSize = 14}
K.BorderBackdrop = {bgFile = C.Media.Blank}
K.BorderBackdropTwo = {bgFile = C.Media.Blank, insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult}}
K.PixelBorder = {edgeFile = C.Media.Blank, edgeSize = K.Mult, insets = {left = K.Mult, right = K.Mult, top = K.Mult, bottom = K.Mult}}
K.TwoPixelBorder = {bgFile = C.Media.Blank, edgeFile = C.Media.Blank, tile = true, tileSize = 16, edgeSize = 2, insets = {left = 2, right = 2, top = 2, bottom = 2}}
K.ShadowBackdrop = {edgeFile = C.Media.Glow, edgeSize = 3, insets = {left = 5, right = 5, top = 5, bottom = 5}}

K.TexCoords = {0.08, 0.92, 0.08, 0.92}

K.PriestColors = {
	r = 0.99,
	g = 0.99,
	b = 0.99,
	colorStr = "fcfcfc"
}

K.Print = function(...)
	print("|cff3c9bed" .. K.UIName .. "|r:", ...)
end

K.SetFontString = function(parent, fontName, fontHeight, fontStyle, justify)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH(justify or "CENTER")
	fs:SetShadowColor(0, 0, 0, 1)
	fs:SetShadowOffset(K.Mult, -K.Mult) -- Temp

	return fs
end

K.Comma = function(num)
	local Left, Number, Right = match(num, "^([^%d]*%d)(%d*)(.-)$")

	return 	Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) .. Right
end

K.ShortValue = function(value)
	if value >= 1e11 then
		return ("%.0fb"):format(value / 1e9)
	elseif value >= 1e10 then
		return ("%.1fb"):format(value / 1e9):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e9 then
		return ("%.2fb"):format(value / 1e9):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e8 then
		return ("%.0fm"):format(value / 1e6)
	elseif value >= 1e7 then
		return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e6 then
		return ("%.2fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
	elseif value >= 1e5 then
		return ("%.0fk"):format(value / 1e3)
	elseif value >= 1e3 then
		return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
	else
		return value
	end
end

-- Rounding
K.Round = function(number, decimals)
	if (not decimals) then
		decimals = 0
	end

	return format(format("%%.%df", decimals), number)
end

-- RgbToHex color
K.RGBToHex = function(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0

	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- We might need to move these to API?
K.CreateBlizzardFrame = function(frame, point)
	if point == nil then point = frame end

	if point.backdrop then return end
	frame.backdrop = CreateFrame("Frame", nil , frame)
	frame.backdrop:SetAllPoints()
	frame.backdrop:SetBackdrop(K.Backdrop)
	frame.backdrop:SetPoint("TOPLEFT", point, -3 * K.NoScaleMult, 3 * K.NoScaleMult)
	frame.backdrop:SetPoint("BOTTOMRIGHT", point, 3 * K.NoScaleMult, -3 * K.NoScaleMult)
	frame.backdrop:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	frame.backdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))

	if frame:GetFrameLevel() - 1 > 0 then
		frame.backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
	else
		frame.backdrop:SetFrameLevel(0)
	end
end

K.SetBlizzardBorder = function(frame, r, g, b, a)
	if not a then a = 1 end
	frame.backdrop:SetBackdropBorderColor(r, g, b, a)
end

K.CreateShadowFrame = function(frame, point)
	if point == nil then point = frame end

	if point.backdrop then return end
	frame.backdrop = CreateFrame("Frame", nil , frame)
	frame.backdrop:SetAllPoints()
	frame.backdrop:SetBackdrop({
		bgFile = C.Media.Blank,
		edgeFile = C.Media.Glow,
		edgeSize = 3 * K.NoScaleMult,
		insets = {top = 3 * K.NoScaleMult, left = 3 * K.NoScaleMult, bottom = 3 * K.NoScaleMult, right = 3 * K.NoScaleMult}
	})
	frame.backdrop:SetPoint("TOPLEFT", point, -3 * K.NoScaleMult, 3 * K.NoScaleMult)
	frame.backdrop:SetPoint("BOTTOMRIGHT", point, 3 * K.NoScaleMult, -3 * K.NoScaleMult)
	frame.backdrop:SetBackdropColor(.05, .05, .05, .9)
	frame.backdrop:SetBackdropBorderColor(0, 0, 0, 1)

	if frame:GetFrameLevel() - 1 > 0 then
		frame.backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
	else
		frame.backdrop:SetFrameLevel(0)
	end
end

K.SetShadowBorder = function(frame, r, g, b, a)
	if not a then a = 0.9 end
	frame.backdrop:SetBackdropBorderColor(r, g, b, a)
end

-- Chat channel check
K.CheckChat = function(warning)
	if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
		return "INSTANCE_CHAT"
	elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
		if warning and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant()) then
			return "RAID_WARNING"
		else
			return "RAID"
		end
	elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
		return "PARTY"
	end
	return "SAY"
end

K.ShortenString = function(string, numChars, dots)
	local bytes = string:len()
	if (bytes <= numChars) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if (c > 0 and c <= 127) then
				pos = pos + 1
			elseif (c >= 192 and c <= 223) then
				pos = pos + 2
			elseif (c >= 224 and c <= 239) then
				pos = pos + 3
			elseif (c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if (len == numChars) then break end
		end

		if (len == numChars and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

K.Abbreviate = function(name)
	local newname = (len(name) > 18) and gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
	return K.ShortenString(newname, 18, false)
end

K.FormatMoney = function(value)
	if value >= 1e4 then
		return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
	elseif value >= 1e2 then
		return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
	else
		return format("|cffeda55f%dc|r", strsub(value, -2))
	end
end

-- Color Gradient
K.ColorGradient = function(a, b, ...)
	local Percent

	if(b == 0) then
		Percent = 0
	else
		Percent = a / b
	end

	if (Percent >= 1) then
		local R, G, B = select(select("#", ...) - 2, ...)

		return R, G, B
	elseif (Percent <= 0) then
		local R, G, B = ...

		return R, G, B
	end

	local Num = (select("#", ...) / 3)
	local Segment, RelPercent = modf(Percent * (Num - 1))
	local R1, G1, B1, R2, G2, B2 = select((Segment * 3) + 1, ...)

	return R1 + (R2 - R1) * RelPercent, G1 + (G2 - G1) * RelPercent, B1 + (B2 - B1) * RelPercent
end

-- Format seconds to min/ hour / day
K.FormatTime = function(s)
	local Day, Hour, Minute = 86400, 3600, 60

	if (s >= Day) then
		return format("%dd", ceil(s / Day))
	elseif (s >= Hour) then
		return format("%dh", ceil(s / Hour))
	elseif (s >= Minute) then
		return format("%dm", ceil(s / Minute))
	elseif (s >= Minute / 12) then
		return floor(s)
	end

	return format("%.1f", s)
end

--Add time before calling a function
local TimerParent = CreateFrame("Frame")
K.UnusedTimers = {}

local TimerOnFinished = function(self)
	self.Func(unpack(self.Args))
	tinsert(K.UnusedTimers, self)
end

K.NewTimer = function()
	local Parent = TimerParent:CreateAnimationGroup()
	local Timer = Parent:CreateAnimation("Alpha")

	Timer:SetScript("OnFinished", TimerOnFinished)
	Timer.Parent = Parent

	return Timer
end

K.Delay = function(delay, func, ...)
	if (type(delay) ~= "number" or type(func) ~= "function") then
		return
	end

	local Timer

	if K.UnusedTimers[1] then
		Timer = tremove(K.UnusedTimers, 1) -- Recycle a timer
	else
		Timer = K.NewTimer() -- Or make a new one if needed
	end

	Timer.Args = {...}
	Timer.Func = func
	Timer:SetDuration(delay)
	Timer.Parent:Play()
end

-- Currencys
local GetCurrencyInfo = GetCurrencyInfo
K.Currency = function(id, weekly, capped)
	local name, amount, tex, week, weekmax, maxed, discovered = GetCurrencyInfo(id)

	local r, g, b = 1, 1, 1
	for i = 1, GetNumWatchedTokens() do
		local _, _, _, itemID = GetBackpackCurrencyInfo(i)
		if id == itemID then r, g, b = .77, .12, .23 end
	end

	if (amount == 0 and r == 1) then return end
	if weekly then
		if id == 390 then week = floor(abs(week) / 100) end
		if discovered then GameTooltip:AddDoubleLine("\124T" .. tex .. ":12\124t " .. name, "Current: " .. amount .. " - " .. WEEKLY .. ": " .. week .. " / " .. weekmax, r, g, b, r, g, b) end
	elseif capped then
		if id == 392 then maxed = 4000 end
		if discovered then GameTooltip:AddDoubleLine("\124T" .. tex .. ":12\124t " .. name, amount .. " / " .. maxed, r, g, b, r, g, b) end
	else
		if discovered then GameTooltip:AddDoubleLine("\124T" .. tex .. ":12\124t " .. name, amount, r, g, b, r, g, b) end
	end
end