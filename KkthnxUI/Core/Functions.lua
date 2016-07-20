local K, C, L, _ = select(2, ...):unpack()

local format, find, gsub = string.format, string.find, string.gsub
local match = string.match
local floor, ceil = math.floor, math.ceil
local print = print
local reverse = string.reverse
local tonumber, type = tonumber, type
local unpack, select = unpack, select
local CreateFrame = CreateFrame
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellInfo = GetSpellInfo
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local UnitStat, UnitAttackPower, UnitBuff = UnitStat, UnitAttackPower, UnitBuff
local tinsert, tremove = tinsert, tremove
local Locale = GetLocale()

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

K.TexCoords = {5/65, 59/64, 5/64, 59/64}

K.Print = function(...)
	print("|cff2eb6ffKkthnxUI|r:", ...)
end

K.SetFontString = function(parent, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset((0), -(0))

	return fs
end

K.Comma = function(num)
	local Left, Number, Right = match(num, "^([^%d]*%d)(%d*)(.-)$")

	return 	Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) .. Right
end

-- ShortValue
-- We show a different value for the Chinese client.
if (Locale == "zhCN") then
	K.ShortValue = function(value)
		value = tonumber(value)
		if not value then return "" end
		if value >= 1e8 then
			return ("%.1f亿"):format(value / 1e8):gsub("%.?0+([km])$", "%1")
		elseif value >= 1e4 or value <= -1e3 then
			return ("%.1f万"):format(value / 1e4):gsub("%.?0+([km])$", "%1")
		else
			return floor(tostring(value))
		end 
	end
else
	K.ShortValue = function(value)
		value = tonumber(value)
		if not value then return "" end
		if value >= 1e6 then
			return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
		elseif value >= 1e3 or value <= -1e3 then
			return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
		else
			return floor(tostring(value))
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

-- RGBToHex Color
K.RGBToHex = function(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
    g = g <= 1 and g >= 0 and g or 0
    b = b <= 1 and b >= 0 and b or 0

    return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

K.CheckChat = function(warning)
    local numParty, numRaid = GetNumPartyMembers(), GetNumRaidMembers()
    if (numRaid > 0) then
        if warning and (UnitIsPartyLeader("player")) or (UnitIsRaidOfficer("player")) then
            return "RAID_WARNING"
        else
            return "RAID"
        end
        elseif (numParty > 0) then
            return "PARTY"
        end
    return "SAY"
end

local RoleUpdater = CreateFrame("Frame")
local function CheckRole(self, event, unit)
	if event == "UNIT_AURA" and unit ~= "player" then return end
	if (K.Class == "PALADIN" and UnitBuff("player", GetSpellInfo(25780))) and GetCombatRatingBonus(CR_DEFENSE_SKILL) > 100 or
	(K.Class == "WARRIOR" and GetBonusBarOffset() == 2) or
	(K.Class == "DEATHKNIGHT" and UnitBuff("player", GetSpellInfo(48263))) or
	(K.Class == "DRUID" and GetBonusBarOffset() == 3) then
		K.Role = "Tank"
	else
		local playerint = select(2, UnitStat("player", 4))
		local playeragi	= select(2, UnitStat("player", 2))
		local base, posBuff, negBuff = UnitAttackPower("player")
		local playerap = base + posBuff + negBuff

		if ((playerap > playerint) or (playeragi > playerint)) and not (UnitBuff("player", GetSpellInfo(24858)) or UnitBuff("player", GetSpellInfo(65139))) then
			K.Role = "Melee"
		else
			K.Role = "Caster"
		end
	end
	-- Unregister useless events
	if event == "PLAYER_ENTERING_WORLD" then
		if K.Class ~= "WARRIOR" and  K.Class ~= "DRUID" then
			RoleUpdater:UnregisterEvent("UPDATE_BONUS_ACTIONBAR")	
		end
		RoleUpdater:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end	
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("UNIT_AURA")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:SetScript("OnEvent", CheckRole)
CheckRole()

function K.ShortenString(string, numChars, dots)
	local bytes = string:len()
	if(bytes <= numChars) then
		return string
	else
		local len, pos = 0, 1
		while(pos <= bytes) do
			len = len + 1
			local c = string:byte(pos)
			if(c > 0 and c <= 127) then
				pos = pos + 1
			elseif(c >= 192 and c <= 223) then
				pos = pos + 2
			elseif(c >= 224 and c <= 239) then
				pos = pos + 3
			elseif(c >= 240 and c <= 247) then
				pos = pos + 4
			end
			if(len == numChars) then break end
		end

		if(len == numChars and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

K.RuneColor = {
	[1] = {r = 0.7, g = 0.1, b = 0.1},
	[2] = {r = 0.7, g = 0.1, b = 0.1},
	[3] = {r = 0.4, g = 0.8, b = 0.2},
	[4] = {r = 0.4, g = 0.8, b = 0.2},
	[5] = {r = 0.0, g = 0.6, b = 0.8},
	[6] = {r = 0.0, g = 0.6, b = 0.8},
}

K.ComboColor = {
	[1] = {r = 1.0, g = 1.0, b = 1.0},
	[2] = {r = 1.0, g = 1.0, b = 1.0},
	[3] = {r = 1.0, g = 1.0, b = 1.0},
	[4] = {r = 0.9, g = 0.7, b = 0.0},
	[5] = {r = 1.0, g = 0.0, b = 0.0},
}

K.TimeColors = {
	[0] = "|cffeeeeee",
	[1] = "|cffeeeeee",
	[2] = "|cffeeeeee",
	[3] = "|cffeeeeee",
	[4] = "|cfffe0000"
}

K.TimeFormats = {
	[0] = {"%dd", "%dd"},
	[1] = {"%dh", "%dh"},
	[2] = {"%dm", "%dm"},
	[3] = {"%ds", "%d"},
	[4] = {"%.1fs", "%.1f"}
}

K.GetTimeInfo = function(s, threshhold)
	local Day, Hour, Minute = 86400, 3600, 60
	local Dayish, Hourish, Minuteish = 3600 * 23.5, 60 * 59.5, 59.5
	local HalfDayish, HalfHourish, HalfMinuteish = Day / 2 + 0.5, Hour / 2 + 0.5, Minute / 2 + 0.5

	if(s < Minute) then
		if(s >= threshhold) then
			return floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif(s < Hour) then
		local Minutes = floor((s / Minute) + 0.5)
		return ceil(s / Minute), 2, Minutes > 1 and (s - (Minutes * Minute - HalfMinuteish)) or (s - Minuteish)
	elseif(s < Day) then
		local Hours = floor((s / Hour) + 0.5)
		return ceil(s / Hour), 1, Hours > 1 and (s - (Hours * Hour - HalfHourish)) or (s - Hourish)
	else
		local Days = floor((s / Day) + 0.5)
		return ceil(s / Day), 0, Days > 1 and (s - (Days * Day - HalfDayish)) or (s - Dayish)
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

-- Add time before calling a function
local waitTable = {}
local waitFrame
K.Delay = function(delay, func, ...)
	if(type(delay) ~= "number" or type(func) ~= "function") then
		return false
	end
	if(waitFrame == nil) then
		waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
		waitFrame:SetScript("onUpdate", function (self, elapse)
			local count = #waitTable
			local i = 1
			while(i <= count) do
				local waitRecord = tremove(waitTable,i)
				local d = tremove(waitRecord,1)
				local f = tremove(waitRecord,1)
				local p = tremove(waitRecord,1)
				if(d > elapse) then
					tinsert(waitTable, i, {d-elapse, f, p})
					i = i + 1
				else
					count = count - 1
					f(unpack(p))
				end
			end
		end)
	end
	tinsert(waitTable, {delay, func, {...}})
	return true
end