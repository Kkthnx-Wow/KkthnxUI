local K, C = unpack(select(2, ...))

local _G = _G
local assert = assert
local hooksecurefunc = hooksecurefunc
local math_abs = math.abs
local math_ceil = math.ceil
local math_floor = math.floor
local mod = mod
local next = next
local pairs = pairs
local print = print
local select = select
local string_format = string.format
local string_lower = string.lower
local table_insert = table.insert
local table_remove = table.remove
local type = type
local unpack = unpack

local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local GetCVar = _G.GetCVar
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetSpecialization = _G.GetSpecialization
local GetSpecializationRole = _G.GetSpecializationRole
local InCombatLockdown = _G.InCombatLockdown
local IsEveryoneAssistant = _G.IsEveryoneAssistant
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE
local SetCVar = _G.SetCVar
local UIParent = _G.UIParent
local UnitGroupRolesAssigned = _G.UnitGroupRolesAssigned
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

K.DispelClasses = {
	["PRIEST"] = {
		["Magic"] = true,
		["Disease"] = true
	},
	["SHAMAN"] = {
		["Magic"] = false,
		["Curse"] = true
	},
	["PALADIN"] = {
		["Poison"] = true,
		["Magic"] = false,
		["Disease"] = true
	},
	["DRUID"] = {
		["Magic"] = false,
		["Curse"] = true,
		["Poison"] = true,
		["Disease"] = false,
	},
	["MONK"] = {
		["Magic"] = false,
		["Disease"] = true,
		["Poison"] = true
	}
}

function K.Print(...)
	print("|cff3c9bed"..K.Title.."|r:", ...)
end

function K.SetFontString(parent, fontName, fontSize, fontStyle, justify)
	if not fontSize then
		fontSize = 12
	end

	local fontString = parent:CreateFontString(nil, "OVERLAY")
	fontString:SetFont(fontName, fontSize, fontStyle)
	fontString:SetJustifyH(justify or "CENTER")
	fontString:SetWordWrap(false)
	fontString:SetShadowOffset(K.Mult or 1, -K.Mult or - 1)
	fontString.baseSize = fontSize

	return fontString
end

local shortValueDec
function K.ShortValue(v)
	shortValueDec = string_format("%%.%df", C["Unitframe"].DecimalLength or 1)
	if C["Unitframe"].NumberPrefixStyle.Value == "METRIC" then
		if math_abs(v) >= 1e12 then
			return string_format(shortValueDec.."T", v / 1e12)
		elseif math_abs(v) >= 1e9 then
			return string_format(shortValueDec.."G", v / 1e9)
		elseif math_abs(v) >= 1e6 then
			return string_format(shortValueDec.."M", v / 1e6)
		elseif math_abs(v) >= 1e3 then
			return string_format(shortValueDec.."k", v / 1e3)
		else
			return string_format("%.0f", v)
		end
	elseif C["Unitframe"].NumberPrefixStyle.Value == "CHINESE" then
		if math_abs(v) >= 1e8 then
			return string_format(shortValueDec.."Y", v / 1e8)
		elseif math_abs(v) >= 1e4 then
			return string_format(shortValueDec.."W", v / 1e4)
		else
			return string_format("%.0f", v)
		end
	elseif C["Unitframe"].NumberPrefixStyle.Value == "KOREAN" then
		if math_abs(v) >= 1e8 then
			return string_format(shortValueDec.."억", v / 1e8)
		elseif math_abs(v) >= 1e4 then
			return string_format(shortValueDec.."만", v / 1e4)
		elseif math_abs(v) >= 1e3 then
			return string_format(shortValueDec.."천", v / 1e3)
		else
			return string_format("%.0f", v)
		end
	elseif C["Unitframe"].NumberPrefixStyle.Value == "GERMAN" then
		if math_abs(v) >= 1e12 then
			return string_format(shortValueDec.."Bio", v / 1e12)
		elseif math_abs(v) >= 1e9 then
			return string_format(shortValueDec.."Mrd", v / 1e9)
		elseif math_abs(v) >= 1e6 then
			return string_format(shortValueDec.."Mio", v / 1e6)
		elseif math_abs(v) >= 1e3 then
			return string_format(shortValueDec.."Tsd", v / 1e3)
		else
			return string_format("%.0f", v)
		end
	else
		if math_abs(v) >= 1e12 then
			return string_format(shortValueDec.."T", v / 1e12)
		elseif math_abs(v) >= 1e9 then
			return string_format(shortValueDec.."B", v / 1e9)
		elseif math_abs(v) >= 1e6 then
			return string_format(shortValueDec.."M", v / 1e6)
		elseif math_abs(v) >= 1e3 then
			return string_format(shortValueDec.."K", v / 1e3)
		else
			return string_format("%s", v)
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

-- RGB to Hex
function K.RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string_format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

function K.CheckAddOnState(addon)
	return K.AddOns[string_lower(addon)] or false
end

function K.GetPlayerRole()
	local assignedRole = UnitGroupRolesAssigned("player")
	if (assignedRole == "NONE") then
		local spec = GetSpecialization()
		return GetSpecializationRole(spec)
	end

	return assignedRole
end

function K.IsDispellableByMe(debuffType)
	if not K.DispelClasses[K.Class] then
		return
	end

	if K.DispelClasses[K.Class][debuffType] then
		return true
	end
end

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

function K:PLAYER_ENTERING_WORLD()
	self:MapInfo_Update()
end

K.LockedCVars = {}
K.IgnoredCVars = {}

function K:PLAYER_REGEN_ENABLED(_)
	if (self.CVarUpdate) then
		for cvarName, value in pairs(K.LockedCVars) do
			if (not K.IgnoredCVars[cvarName] and (GetCVar(cvarName) ~= value)) then
				SetCVar(cvarName, value)
			end
		end

		self.CVarUpdate = nil
	end
end

local function CVAR_UPDATE(cvarName, value)
	if (not K.IgnoredCVars[cvarName] and K.LockedCVars[cvarName] and K.LockedCVars[cvarName] ~= value) then
		if(InCombatLockdown()) then
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
	ignore = not not ignore -- Cast to bool, just in case
	K.IgnoredCVars[cvarName] = ignore
end

local styles = {
	-- keep percents in this table with `PERCENT` in the key, and `%.1f%%` in the value somewhere.
	-- we use these two things to follow our setting for decimal length. they need to be EXACT.
	["CURRENT"] = "%s",
	["CURRENT_MAX"] = "%s - %s",
	["CURRENT_PERCENT"] = "%s - %.1f%%",
	["CURRENT_MAX_PERCENT"] = "%s - %s | %.1f%%",
	["PERCENT"] = "%.1f%%",
	["DEFICIT"] = "-%s"
}

local gftDec, gftUseStyle, gftDeficit
function K.GetFormattedText(style, min, max)
	assert(styles[style], "Invalid format style: "..style)
	assert(min, "You need to provide a current value. Usage: K.GetFormattedText(style, min, max)")
	assert(max, "You need to provide a maximum value. Usage: K.GetFormattedText(style, min, max)")

	if max == 0 then
		max = 1
	end

	gftDec = (C["Unitframe"].DecimalLength or 1)
	if (gftDec ~= 1) and style:find("PERCENT") then
		gftUseStyle = styles[style]:gsub("%%%.1f%%%%", "%%."..gftDec.."f%%%%")
	else
		gftUseStyle = styles[style]
	end

	if style == "DEFICIT" then
		gftDeficit = max - min
		return ((gftDeficit > 0) and string_format(gftUseStyle, K.ShortValue(gftDeficit))) or ""
	elseif style == "PERCENT" then
		return string_format(gftUseStyle, min / max * 100)
	elseif style == "CURRENT" or ((style == "CURRENT_MAX" or style == "CURRENT_MAX_PERCENT" or style == "CURRENT_PERCENT") and min == max) then
		return string_format(styles["CURRENT"], K.ShortValue(min))
	elseif style == "CURRENT_MAX" then
		return string_format(gftUseStyle, K.ShortValue(min), K.ShortValue(max))
	elseif style == "CURRENT_PERCENT" then
		return string_format(gftUseStyle, K.ShortValue(min), min / max * 100)
	elseif style == "CURRENT_MAX_PERCENT" then
		return string_format(gftUseStyle, K.ShortValue(min), K.ShortValue(max), min / max * 100)
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

	if (x > (screenWidth / 3) and x < (screenWidth / 3) * 2) and y > (screenHeight / 3) * 2 then
		point = "TOP"
	elseif x < (screenWidth / 3) and y > (screenHeight / 3)*2 then
		point = "TOPLEFT"
	elseif x > (screenWidth / 3) * 2 and y > (screenHeight / 3) * 2 then
		point = "TOPRIGHT"
	elseif (x > (screenWidth / 3) and x < (screenWidth / 3) * 2) and y < (screenHeight / 3) then
		point = "BOTTOM"
	elseif x < (screenWidth / 3) and y < (screenHeight / 3) then
		point = "BOTTOMLEFT"
	elseif x > (screenWidth / 3) * 2 and y < (screenHeight / 3) then
		point = "BOTTOMRIGHT"
	elseif x < (screenWidth / 3) and (y > (screenHeight / 3) and y < (screenHeight / 3) * 2) then
		point = "LEFT"
	elseif x > (screenWidth / 3) * 2 and y < (screenHeight / 3) * 2 and y > (screenHeight / 3) then
		point = "RIGHT"
	else
		point = "CENTER"
	end

	return point
end

function K.ColorGradient(perc, ...)
	if perc >= 1 then
		return select(select("#", ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = select("#", ...) / 3
	local segment, relperc = math.modf(perc*(num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2-r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
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

function K.FormatMoney(amount)
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
			return math_floor(s), 3, 0.51
		else
			return s, 4, 0.051
		end
	elseif s < HOUR then
		local minutes = math_floor((s/MINUTE)+.5)
		return math_ceil(s / MINUTE), 2, minutes > 1 and (s - (minutes*MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
	elseif s < DAY then
		local hours = math_floor((s/HOUR)+.5)
		return math_ceil(s / HOUR), 1, hours > 1 and (s - (hours*HOUR - HALFHOURISH)) or (s - HOURISH)
	else
		local days = math_floor((s/DAY)+.5)
		return math_ceil(s / DAY), 0, days > 1 and (s - (days*DAY - HALFDAYISH)) or (s - DAYISH)
	end
end

-- Add time before calling a function
local waitTable = {}
local waitFrame
function K.Delay(delay, func, ...)
	if (type(delay) ~= "number") or (type(func) ~= "function") then
		return false
	end
	local extend = {...}
	if not next(extend) then
		C_Timer_After(delay, func)
		return true
	else
		if waitFrame == nil then
			waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
			waitFrame:SetScript("onUpdate",function (_, elapse)
				local waitRecord, waitDelay, waitFunc, waitParams
				local i, count = 1, #waitTable
				while i <= count do
					waitRecord = table_remove(waitTable, i)
					waitDelay = table_remove(waitRecord, 1)
					waitFunc = table_remove(waitRecord, 1)
					waitParams = table_remove(waitRecord, 1)
					if waitDelay > elapse then
						table_insert(waitTable, i, {waitDelay - elapse, waitFunc, waitParams})
						i = i + 1
					else
						count = count - 1
						waitFunc(unpack(waitParams))
					end
				end
			end)
		end
		table_insert(waitTable, {delay, func, extend})
		return true
	end
end