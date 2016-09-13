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

-- THIS FRAME EVERYTHING IN KKTHNXUI SHOULD BE ANCHORED TO FOR EYEFINITY SUPPORT.
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
	fs:SetShadowOffset(0, -0)

	return fs
end

K.Comma = function(num)
	local Left, Number, Right = match(num, "^([^%d]*%d)(%d*)(.-)$")

	return 	Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) .. Right
end

-- SHORTVALUE, WE SHOW A DIFFERENT VALUE FOR THE CHINESE CLIENT.
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

-- ROUNDING
K.Round = function(number, decimals)
	if (not decimals) then
		decimals = 0
	end

	return format(format("%%.%df", decimals), number)
end

-- RGBTOHEX COLOR
K.RGBToHex = function(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0

	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- HELPER FUNCTION FOR MOVING A BLIZZARD FRAME THAT HAS A SETMOVEABLE FLAG
K.ModifyFrame = function(frame, anchor, parent, posX, posY, scale)
	frame:SetMovable(true)
	frame:ClearAllPoints()
	if(parent == nil) then frame:SetPoint(anchor, posX, posY) else frame:SetPoint(anchor, parent, posX, posY) end
	if(scale ~= nil) then frame:SetScale(scale) end
	frame:SetUserPlaced(true)
	frame:SetMovable(false)
end

-- HELPER FUNCTION FOR MOVING A BLIZZARD FRAME THAT DOES NOT HAVE A SETMOVEABLE FLAG
K.ModifyBasicFrame = function(frame, anchor, parent, posX, posY, scale)
	frame:ClearAllPoints()
	if(parent == nil) then frame:SetPoint(anchor, posX, posY) else frame:SetPoint(anchor, parent, posX, posY) end
	if(scale ~= nil) then frame:SetScale(scale) end
end

-- CREATE A FAKE BACKDROP FRAME??
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

K.FormatMoney = function(value)
	if value >= 1e4 then
		return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
	elseif value >= 1e2 then
		return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
	else
		return format("|cffeda55f%dc|r", strsub(value, -2))
	end
end

-- ADD TIME BEFORE CALLING A FUNCTION
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
				local waitRecord = tremove(waitTable, i)
				local d = tremove(waitRecord, 1)
				local f = tremove(waitRecord, 1)
				local p = tremove(waitRecord, 1)
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