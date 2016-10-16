local K, C, L = select(2, ...):unpack()

local format, find, gsub = string.format, string.find, string.gsub
local match = string.match
local floor, ceil = math.floor, math.ceil
local print = print
local reverse = string.reverse
local tonumber, type = tonumber, type
local unpack, select = unpack, select
local modf = math.modf
local len = string.len
local CreateFrame = CreateFrame
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellInfo = GetSpellInfo
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local UnitStat, UnitAttackPower, UnitBuff = UnitStat, UnitAttackPower, UnitBuff
local tinsert, tremove = tinsert, tremove
local Locale = GetLocale()

K.Print = function(...)
	print("|cff3c9bedKkthnxUI|r:", ...)
end

K.Backdrop = {bgFile = C.Media.Blank, edgeFile = C.Media.Blizz, edgeSize = 14, insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}}
K.Border = {edgeFile = C.Media.Blizz, edgeSize = 14}
K.BorderBackdrop = {bgFile = C.Media.Blank}
K.PixelBorder = {edgeFile = C.Media.Blank, edgeSize = K.Mult, insets = {left = K.Mult, right = K.Mult, top = K.Mult, bottom = K.Mult}}
K.ShadowBackdrop = {edgeFile = C.Media.Glow, edgeSize = 3, insets = {left = 5, right = 5, top = 5, bottom = 5}}

-- This frame everything in KkthnxUI should be anchored to for Eyefinity support.
K.UIParent = CreateFrame("Frame", "KkthnxUIParent", UIParent)
K.UIParent:SetFrameLevel(UIParent:GetFrameLevel())
K.UIParent:SetPoint("CENTER", UIParent, "CENTER")
K.UIParent:SetSize(UIParent:GetSize())
K.UIParent.origHeight = K.UIParent:GetHeight()

K.TexCoords = {0.08, 0.92, 0.08, 0.92}

value = {r = 23/255, g = 132/255, b = 209/255}
local ValueColor = K.RGBToHex(value.r, value.g, value.b)
K.Print = function(...)
	print(ValueColor..K.UIName..":|r", ...)
end

K.SetFontString = function(parent, fontName, fontHeight, fontStyle, justify)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH(justify or "CENTER")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(K.Mult, -K.Mult)

	return fs
end

K.Comma = function(num)
	local Left, Number, Right = match(num, "^([^%d]*%d)(%d*)(.-)$")

	return 	Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) .. Right
end

-- Shortvalue, we show a different value for the chinese client.
K.ShortValue = function(value)
	if (Locale == "zhCN") then
		if abs(value) >= 1e8 then
			return format("%.1fY", value / 1e8)
		elseif abs(value) >= 1e4 then
			return format("%.1fW", value / 1e4)
		else
			return format("%d", value)
		end
	else
		if abs(value) >= 1e9 then
			return format("%.1fG", value / 1e9)
		elseif abs(value) >= 1e6 then
			return format("%.1fM", value / 1e6)
		elseif abs(value) >= 1e3 then
			return format("%.1fk", value / 1e3)
		else
			return format("%d", value)
		end
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

-- Create a fake backdrop frame.
K.CreateVirtualFrame = function(parent, point)
	if point == nil then point = parent end

	if point.backdrop then return end
	parent.backdrop = CreateFrame("Frame", nil , parent)
	parent.backdrop:SetAllPoints()
	parent.backdrop:SetBackdrop(K.Backdrop)
	parent.backdrop:SetPoint("TOPLEFT", point, -3 * K.NoScaleMult, 3 * K.NoScaleMult)
	parent.backdrop:SetPoint("BOTTOMRIGHT", point, 3 * K.NoScaleMult, -3 * K.NoScaleMult)
	parent.backdrop:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	parent.backdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))

	if parent:GetFrameLevel() - 1 > 0 then
		parent.backdrop:SetFrameLevel(parent:GetFrameLevel() - 1)
	else
		parent.backdrop:SetFrameLevel(0)
	end
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

-- Player"s role check
local isCaster = {
	DEATHKNIGHT = {nil, nil, nil},
	DEMONHUNTER = {nil, nil},
	DRUID = {true},
	HUNTER = {nil, nil, nil},
	MAGE = {true, true, true},
	MONK = {nil, nil, nil},
	PALADIN = {nil, nil, nil},
	PRIEST = {nil, nil, true},
	ROGUE = {nil, nil, nil},
	SHAMAN = {true},
	WARLOCK = {true, true, true},
	WARRIOR = {nil, nil, nil}
}

local function CheckRole(self, event, unit)
	local Spec = GetSpecialization()
	local Role = Spec and GetSpecializationRole(Spec)

	if Role == "TANK" then
		K.Role = "Tank"
	elseif Role == "HEALER" then
		K.Role = "Healer"
	elseif Role == "DAMAGER" then
		if isCaster[K.Class][Spec] then
			K.Role = "Caster"
		else
			K.Role = "Melee"
		end
	end
end
local RoleUpdater = CreateFrame("Frame")
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)

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

-- Add time before calling a function
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