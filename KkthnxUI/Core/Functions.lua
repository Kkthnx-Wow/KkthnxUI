local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local math_abs = math.abs
local math_ceil = math.ceil
local math_floor = math.floor
local math_modf = math.modf
local mod = mod
local pairs = pairs
local print = print
local select = select
local string_find = string.find
local string_format = string.format
local string_lower = string.lower
local string_sub = string.sub
local table_insert = table.insert
local table_remove = table.remove
local tonumber = tonumber
local tostring = tostring
local type = type
local unpack = unpack

-- Wow API
local CreateFrame = _G.CreateFrame
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetCVar = _G.GetCVar
local GetLocale = _G.GetLocale
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local InCombatLockdown = _G.InCombatLockdown
local IsEveryoneAssistant = _G.IsEveryoneAssistant
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE
local SetCVar = _G.SetCVar
local UIParent = _G.UIParent
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: K.UIFrameHider, UIHider

K.Incompats = {}
K.LockedCVars = {}
K.IgnoredCVars = {}

-- Backdrop & Borders
K.Backdrop = {bgFile = C["Media"].Blank, edgeFile = C["Media"].Border, edgeSize = 14, insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}}
K.Border = {edgeFile = C["Media"].Border, edgeSize = 14}
K.BorderBackdrop = {bgFile = C["Media"].Blank, insets = {left = 2, right = 2, top = 2, bottom = 2}}
K.BorderBackdropTwo = {bgFile = C["Media"].Blank, insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult}}
K.PixelBorder = {edgeFile = C["Media"].Blank, edgeSize = K.Mult, insets = {left = K.Mult, right = K.Mult, top = K.Mult, bottom = K.Mult}}
K.ShadowBackdrop = {edgeFile = C["Media"].Glow, edgeSize = 3, insets = {left = 5, right = 5, top = 5, bottom = 5}}
K.TwoPixelBorder = {bgFile = C["Media"].Blank, edgeFile = C["Media"].Blank, tile = true, tileSize = 16, edgeSize = 2, insets = {left = 2, right = 2, top = 2, bottom = 2}}

function K.Print(...)
	print("|cff3c9bed"..K.Title.."|r:", ...)
end

function K.SetFontString(parent, fontName, fontSize, fontStyle, justify)
	if not fontSize or fontSize < 9 then
		fontSize = 13
	end

	local fontString = parent:CreateFontString(nil, "OVERLAY")
	fontString:SetFont(fontName, fontSize, fontStyle)
	fontString:SetJustifyH(justify or "CENTER")
	-- fontString:SetWordWrap(Wrap)
	fontString:SetShadowOffset(K.Mult or 1, - K.Mult or - 1)
	fontString.baseSize = fontSize

	return fontString
end

-- Return short value of a number
local shortValueFormat
function K.ShortValue(v)
	if C["General"].NumberPrefixStyle.Value == "METRIC" then
		if math_abs(v) >= 1e9 then
			return string_format("%.1fG", v / 1e9)
		elseif math_abs(v) >= 1e6 then
			return string_format("%.1fM", v / 1e6)
		elseif math_abs(v) >= 1e3 then
			return string_format("%.1fk", v / 1e3)
		else
			return string_format("%d", v)
		end
	elseif C["General"].NumberPrefixStyle.Value == "CHINESE" then
		if math_abs(v) >= 1e8 then
			return string_format("%.1fY", v / 1e8)
		elseif math_abs(v) >= 1e4 then
			return string_format("%.1fW", v / 1e4)
		else
			return string_format("%d", v)
		end
	elseif C["General"].NumberPrefixStyle.Value == "KOREAN" then
		if math_abs(v) >= 1e8 then
			return string_format("%.1f억", v / 1e8)
		elseif math_abs(v) >= 1e4 then
			return string_format("%.1f만", v / 1e4)
		elseif math_abs(v) >= 1e3 then
			return string_format("%.1f천", v / 1e3)
		else
			return string_format("%d", v)
		end
	elseif C["General"].NumberPrefixStyle.Value == "GERMAN" then
		if math_abs(v) >= 1e9 then
			return string_format("%.1fMrd", v / 1e9)
		elseif math_abs(v) >= 1e6 then
			return string_format("%.1fMio", v / 1e6)
		elseif math_abs(v) >= 1e3 then
			return string_format("%.1fTsd", v / 1e3)
		else
			return string_format("%d", v)
		end
	elseif C["General"].NumberPrefixStyle.Value == "DEFAULT" then
		if math_abs(v) >= 1e9 then
			return string_format("%.1fB", v / 1e9)
		elseif math_abs(v) >= 1e6 then
			return string_format("%.1fM", v / 1e6)
		elseif math_abs(v) >= 1e3 then
			return string_format("%.1fK", v / 1e3)
		else
			return string_format("%d", v)
		end
	else -- So it has something to return if nothing. DEFAULT
		if math_abs(v) >= 1e9 then
			return string_format("%.1fB", v / 1e9)
		elseif math_abs(v) >= 1e6 then
			return string_format("%.1fM", v / 1e6)
		elseif math_abs(v) >= 1e3 then
			return string_format("%.1fK", v / 1e3)
		else
			return string_format("%d", v)
		end
	end
end

-- Return rounded number
function K.Round(num, idp)
	if (idp and idp > 0) then
		local mult = 10 ^ idp
		return math_floor(num * mult + 0.5) / mult
	end
	return math_floor(num + 0.5)
end

-- Better split function
function K.Split(str, del)
	local t = {}
	local index = 0
	while (string_find(str, del)) do
		local s, e = string_find(str, del)
		t[index] = string_sub(str, 1, s - 1)
		str = string_sub(str, s + #del)
		index = index + 1
	end
	table_insert(t, str)
	return t
end

-- lua doesn"t have a good function for finding a value in a table
function K.InTable (e, t)
	for _, v in pairs(t) do
		if (v == e) then return true end
	end
	return false
end

-- RGB to Hex
function K.RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string_format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

function K.IsIncompatible(self)
	if (not K.Incompats[self]) then
		return false
	end
	for addonName, condition in pairs(K.Incompats[self]) do
		if (type(condition) == "function") then
			if K.IsAddOnEnabled(addonName) then
				return condition(self)
			end
		else
			if K.IsAddOnEnabled(addonName) then
				return true
			end
		end
	end
	return false
end

function K.SetIncompatible(self, ...)
	if (not K.Incompats[self]) then
		K.Incompats[self] = {}
	end
	local numArgs = select("#", ...)
	local currentArg = 1

	while currentArg <= numArgs do
		local addonName = select(currentArg, ...)
		self.Check(addonName, currentArg, "string")

		local condition
		if (numArgs > currentArg) then
			local nextArg = select(currentArg + 1, ...)
			if (type(nextArg) == "function") then
				condition = nextArg
				currentArg = currentArg + 1
			end
		end
		currentArg = currentArg + 1
		K.Incompats[self][addonName] = condition and condition or true
	end
end

--	Player's role check
local isCaster = {
	DEATHKNIGHT = {nil, nil, nil},
	DEMONHUNTER = {nil, nil},
	DRUID = {true}, -- Balance
	HUNTER = {nil, nil, nil},
	MAGE = {true, true, true},
	MONK = {nil, nil, nil},
	PALADIN = {nil, nil, nil},
	PRIEST = {nil, nil, true}, -- Shadow
	ROGUE = {nil, nil, nil},
	SHAMAN = {true}, -- Elemental
	WARLOCK = {true, true, true},
	WARRIOR = {nil, nil, nil}
}

local function CheckRole(self, event, unit)
	local spec = GetSpecialization()
	local role = spec and GetSpecializationRole(spec)

	if role == "TANK" then
		K.Role = "Tank"
	elseif role == "HEALER" then
		K.Role = "Healer"
	elseif role == "DAMAGER" then
		if isCaster[K.Class][spec] then
			K.Role = "Caster"
		else
			K.Role = "Melee"
		end
	end
end
local RoleUpdater = CreateFrame("Frame")
RoleUpdater:RegisterEvent("PLAYER_ENTERING_WORLD")
RoleUpdater:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RoleUpdater:RegisterEvent("CHARACTER_POINTS_CHANGED")
RoleUpdater:RegisterEvent("LFG_ROLE_UPDATE")
RoleUpdater:RegisterEvent("PLAYER_ROLES_ASSIGNED")
RoleUpdater:RegisterEvent("PLAYER_TALENT_UPDATE")
RoleUpdater:RegisterEvent("PVP_ROLE_UPDATE")
RoleUpdater:RegisterEvent("ROLE_CHANGED_INFORM")
RoleUpdater:RegisterEvent("UNIT_INVENTORY_CHANGED")
RoleUpdater:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
RoleUpdater:SetScript("OnEvent", CheckRole)

-- Chat channel check
function K.CheckChat(warning)
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

-- Tooltip code ripped from StatBlockCore by Funkydude
function K.GetAnchors(frame)
	local x, y = frame:GetCenter()

	if not x or not y then return "CENTER" end
	local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"

	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

function K.ShortenString(string, numChars, dots)
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

local LockCVars = CreateFrame("Frame")
LockCVars:SetScript("OnEvent", function(self, event, ...) return self[event] and self[event](self, event, ...) end)
LockCVars:RegisterEvent("PLAYER_REGEN_ENABLED")
function LockCVars:PLAYER_REGEN_ENABLED(_)
	if (self.CVarUpdate) then
		for cvarName, value in pairs(self.LockedCVars) do
			if (not self.IgnoredCVars[cvarName] and (GetCVar(cvarName) ~= value)) then
				SetCVar(cvarName, value)
			end
		end
		self.CVarUpdate = nil
	end
end

local function CVAR_UPDATE(cvarName, value)
	if (not K.IgnoredCVars[cvarName] and K.LockedCVars[cvarName] and K.LockedCVars[cvarName] ~= value) then
		if (InCombatLockdown()) then
			K.CVarUpdate = true
			return
		end

		SetCVar(cvarName, K.LockedCVars[cvarName])
	end
end

hooksecurefunc("SetCVar", CVAR_UPDATE)
function K.LockCVar(cvarName, value)
	if (GetCVar(cvarName) ~= value) then
		SetCVar(cvarName, value)
	end
	K.LockedCVars[cvarName] = value
end

function K.IgnoreCVar(cvarName, ignore)
	ignore = not not ignore -- cast to bool, just in case
	K.IgnoredCVars[cvarName] = ignore
end

local styles = {
	["CURRENT"] = "%s",
	["CURRENT_MAX"] = "%s - %s",
	["CURRENT_PERCENT"] =  "%s - %.1f%%",
	["CURRENT_MAX_PERCENT"] = "%s - %s | %.1f%%",
	["PERCENT"] = "%.1f%%",
	["DEFICIT"] = "-%s"
}

function K.GetFormattedText(style, min, max)
	assert(styles[style], "Invalid format style: "..style)
	assert(min, "You need to provide a current value. Usage: K.GetFormattedText(style, min, max)")
	assert(max, "You need to provide a maximum value. Usage: K.GetFormattedText(style, min, max)")

	if max == 0 then max = 1 end

	local useStyle = styles[style]

	if style == "DEFICIT" then
		local deficit = max - min
		if deficit <= 0 then
			return ""
		else
			return format(useStyle, K.ShortValue(deficit))
		end
	elseif style == "PERCENT" then
		local s = format(useStyle, min / max * 100)
		return s
	elseif style == "CURRENT" or ((style == "CURRENT_MAX" or style == "CURRENT_MAX_PERCENT" or style == "CURRENT_PERCENT") and min == max) then
		return format(styles["CURRENT"],  K.ShortValue(min))
	elseif style == "CURRENT_MAX" then
		return format(useStyle,  K.ShortValue(min), K.ShortValue(max))
	elseif style == "CURRENT_PERCENT" then
		local s = format(useStyle, K.ShortValue(min), min / max * 100)
		return s
	elseif style == "CURRENT_MAX_PERCENT" then
		local s = format(useStyle, K.ShortValue(min), K.ShortValue(max), min / max * 100)
		return s
	end
end

function K.GetScreenQuadrant(frame)
	local x, y = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local point

	if not frame:GetCenter() then
		return "UNKNOWN", frame:GetName()
	end

	if (x > (screenWidth / 3) and x < (screenWidth / 3)*2) and y > (screenHeight / 3)*2 then
		point = "TOP"
	elseif x < (screenWidth / 3) and y > (screenHeight / 3)*2 then
		point = "TOPLEFT"
	elseif x > (screenWidth / 3)*2 and y > (screenHeight / 3)*2 then
		point = "TOPRIGHT"
	elseif (x > (screenWidth / 3) and x < (screenWidth / 3)*2) and y < (screenHeight / 3) then
		point = "BOTTOM"
	elseif x < (screenWidth / 3) and y < (screenHeight / 3) then
		point = "BOTTOMLEFT"
	elseif x > (screenWidth / 3)*2 and y < (screenHeight / 3) then
		point = "BOTTOMRIGHT"
	elseif x < (screenWidth / 3) and (y > (screenHeight / 3) and y < (screenHeight / 3)*2) then
		point = "LEFT"
	elseif x > (screenWidth / 3)*2 and y < (screenHeight / 3)*2 and y > (screenHeight / 3) then
		point = "RIGHT"
	else
		point = "CENTER"
	end

	return point
end
-- http://www.wowwiki.com/ColorGradient
function K.ColorGradient(perc, ...)
	if perc >= 1 then
		return select(select("#", ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = select("#", ...) / 3
	local segment, relperc = math_modf(perc * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1)*relperc
end

-- Example: killMenuOption(true, "InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait")
function K.KillMenuOption(option_shrink, option_name)
	local option = _G[option_name]
	if not(option) or not(option.IsObjectType) or not(option:IsObjectType("Frame")) then
		return
	end
	option:SetParent(K.UIFrameHider)
	if option.UnregisterAllEvents then
		option:UnregisterAllEvents()
	end
	if option_shrink then
		option:SetHeight(0.00001)
	end
	option.cvar = ""
	option.uvar = ""
	option.value = nil
	option.oldValue = nil
	option.defaultValue = nil
	option.setFunc = function() end
end

-- Example (killing the status text panel in WotLK, Cata and MoP):
-- K.KillMenuPanel(9, "InterfaceOptionsStatusTextPanel")

-- "panel_id" is basically the number of the submenu, when all menus are still there.
-- Note that the this sometimes change between expansions, so you really need to check
-- to make sure you are removing the right one.
function K.KillMenuPanel(panel_id, panel_name)
	-- remove an entire blizzard options panel,
	-- and disable its automatic cancel/okay functionality
	-- this is needed, or the option will be reset when the menu closes
	-- it is also a major source of taint related to the Compact group frames!
	if panel_id then
		local category = _G["InterfaceOptionsFrameCategoriesButton" .. panel_id]
		if category then
			category:SetScale(0.00001)
			category:SetAlpha(0)
		end
	end
	if panel_name then
		local panel = _G[panel_name]
		if panel then
			panel:SetParent(K.UIFrameHider)
			if panel.UnregisterAllEvents then
				panel:UnregisterAllEvents()
			end
			panel.cancel = function() end
			panel.okay = function() end
			panel.refresh = function() end
		end
	end
end

-- Format seconds to min/hour/day
local Day, Hour, Minute = 86400, 3600, 60

function K.FormatTime(time)
	if (time >= Day) then
		return string_format("%dd", math_ceil(time / Day))
	elseif (time >= Hour) then
		return string_format("%dh", math_ceil(time / Hour))
	elseif (time >= Minute) then
		return string_format("%dm", math_ceil(time / Minute))
	elseif (time >= Minute / 12) then
		return math_floor(time)
	end

	return string_format("%.1f", time)
end

-- Money text formatting, code taken from Scrooge by thelibrarian (http://www.wowace.com/addons/scrooge/)
local COLOR_COPPER = "|cffeda55f"
local COLOR_GOLD = "|cffffd700"
local COLOR_SILVER = "|cffc7c7cf"
local ICON_COPPER = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12|t"
local ICON_GOLD = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12|t"
local ICON_SILVER = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12|t"

function K.FormatMoney(amount, style)
	local coppername = "|cffeda55fc|r"
	local silvername = "|cffc7c7cfs|r"
	local goldname = "|cffffd700g|r"
	local value = math_abs(amount)
	local gold = math_floor(value / 10000)
	local silver = math_floor(mod(value / 100, 100))
	local copper = math_floor(mod(value, 100))

	local str = ""
	if gold > 0 then
		str = string_format("%d%s%s", gold, goldname, (silver > 0 or copper > 0) and " " or "")
	end
	if silver > 0 then
		str = string_format("%s%d%s%s", str, silver, silvername, copper > 0 and " " or "")
	end
	if copper > 0 or value == 0 then
		str = string_format("%s%d%s", str, copper, coppername)
	end

	return str
end

function K.AbbreviateString(string, allUpper)
	local newString = ""
	local words = {string.split(" ", string)}
	for _, word in pairs(words) do
		word = string.utf8sub(word, 1, 1) -- Get only first letter of each word
		if (allUpper) then
			word = word:upper()
		end
		newString = newString .. word
	end

	return newString
end

-- aura time colors for days, hours, minutes, seconds, fadetimer
K.TimeColors = {
	[0] = "|cffeeeeee",
	[1] = "|cffeeeeee",
	[2] = "|cffeeeeee",
	[3] = "|cffeeeeee",
	[4] = "|cfffe0000",
}
-- short and long aura time formats
K.TimeFormats = {
	[0] = {"%dd", "%dd"},
	[1] = {"%dh", "%dh"},
	[2] = {"%dm", "%dm"},
	[3] = {"%ds", "%d"},
	[4] = {"%.1fs", "%.1f"},
}

local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for calculating aura time text
local DAYISH, HOURISH, MINUTEISH = HOUR * 23.5, MINUTE * 59.5, 59.5 --used for caclculating aura time at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times
-- will return the the value to display, the formatter id to use and calculates the next update for the Aura
function K.GetTimeInfo(s, threshhold)
	if s < MINUTE then
		if s >= threshhold then
			return math.floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif s < HOUR then
		local minutes = math.floor((s/MINUTE)+.5)
		return math.ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAY then
		local hours = math.floor((s/HOUR)+.5)
		return math.ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = math.floor((s/DAY)+.5)
		return math.ceil(s / DAY), 0, days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

-- Add time before calling a function
local waitTable = {}
local waitFrame
function K.Delay(delay, func, ...)
	if(type(delay) ~= "number" or type(func) ~= "function") then
		return false
	end
	local extend = {...}
	if not next(extend) then
		C_Timer.After(delay, func)
		return true
	else
		if(waitFrame == nil) then
			waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
			waitFrame:SetScript("onUpdate", function (_, elapse)
				local count = #waitTable
				local i = 1
				while(i <= count) do
					local waitRecord = table.remove(waitTable, i)
					local d = table.remove(waitRecord, 1)
					local f = table.remove(waitRecord, 1)
					local p = table.remove(waitRecord, 1)
					if(d > elapse) then
					  table.insert(waitTable, i, {d - elapse, f, p})
					  i = i + 1
					else
					  count = count - 1
					  f(unpack(p))
					end
				end
			end)
		end
		table.insert(waitTable, {delay, func, extend})
		return true
	end
end