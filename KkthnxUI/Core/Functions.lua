local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local math_ceil = math.ceil
local math_floor = math.floor
local math_modf = math.modf
local string_format = string.format
local string_lower = string.lower
local table_insert = table.insert
local table_remove = table.remove

-- Wow API
local CreateFrame = _G.CreateFrame
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
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: UIFrameHider, UIHider

-- Backdrop & Borders
K.Backdrop = {bgFile = C.Media.Blank, edgeFile = C.Media.Blizz, edgeSize = 14, insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}}
K.Border = {edgeFile = C.Media.Blizz, edgeSize = 14}
K.BorderBackdrop = {bgFile = C.Media.Blank, insets = {left = 1, right = 1, top = 1, bottom = 1}}
K.BorderBackdropTwo = {bgFile = C.Media.Blank, insets = {top = -K.Mult, left = -K.Mult, bottom = -K.Mult, right = -K.Mult}}
K.PixelBorder = {edgeFile = C.Media.Blank, edgeSize = K.Mult, insets = {left = K.Mult, right = K.Mult, top = K.Mult, bottom = K.Mult}}
K.TwoPixelBorder = {bgFile = C.Media.Blank, edgeFile = C.Media.Blank, tile = true, tileSize = 16, edgeSize = 2, insets = {left = 2, right = 2, top = 2, bottom = 2}}
K.ShadowBackdrop = {edgeFile = C.Media.Glow, edgeSize = 3, insets = {left = 5, right = 5, top = 5, bottom = 5}}

function K.Print(...)
	print("|cff3c9bed"..K.UIName.."|r:", ...)
end

function K.SetFontString(parent, fontName, fontSize, fontStyle, justify)
	if not fontSize or fontSize < 6 then
		fontSize = 13
	end
	fontSize = fontSize * 1

	local fontString = parent:CreateFontString(nil, "OVERLAY")
	fontString:SetFont(fontName, fontSize, fontStyle)
	fontString:SetJustifyH(justify or "CENTER")
	fontString:SetWordWrap(false)
	fontString:SetShadowOffset(K.Mult or 1, -K.Mult or -1)
	fontString.baseSize = fontSize

	return fontString
end

-- Return short value of a number
function K.ShortValue(value)
	if not value then return "" end

	value = tonumber(value)

	if GetLocale() == "zhCN" then
		if value >= 1e8 then
			return ("%.1f亿"):format(value / 1e8):gsub("%.?0+([km])$", "%1")
		elseif value >= 1e4 or value <= -1e3 then
			return ("%.1f万"):format(value / 1e4):gsub("%.?0+([km])$", "%1")
		else
			return tostring(math_floor(value))
		end
	else
		if value >= 1e9 then
			return ("%.1fb"):format(value / 1e9):gsub("%.?0+([kmb])$", "%1")
		elseif value >= 1e6 then
			return ("%.1fm"):format(value / 1e6):gsub("%.?0+([kmb])$", "%1")
		elseif value >= 1e3 or value <= -1e3 then
			return ("%.1fk"):format(value / 1e3):gsub("%.?0+([kmb])$", "%1")
		else
			return tostring(math_floor(value))
		end
	end
end

-- Return rounded number
function K.Round(num, idp)
	if(idp and idp > 0) then
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

function K.CheckAddOn(addon)
	return K.AddOns[string_lower(addon)] or false
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

function K.UTF8Sub(str, i, dots)
	if not str then return end
	local bytes = str:len()
	if bytes <= i then
		return str
	else
		local len, pos = 0, 1
		while pos <= bytes do
			len = len + 1
			local c = str:byte(pos)
			if c > 0 and c <= 127 then
				pos = pos + 1
			elseif c >= 192 and c <= 223 then
				pos = pos + 2
			elseif c >= 224 and c <= 239 then
				pos = pos + 3
			elseif c >= 240 and c <= 247 then
				pos = pos + 4
			end
			if len == i then break end
		end
		if len == i and pos <= bytes then
			return str:sub(1, pos - 1)..(dots and "..." or "")
		else
			return str
		end
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

K.LockedCVars = {}
K.IgnoredCVars = {}

local UpdateCVar = CreateFrame("Frame")
UpdateCVar:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)
UpdateCVar:RegisterEvent("PLAYER_REGEN_ENABLED")
function UpdateCVar:PLAYER_REGEN_ENABLED(_)
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
function K:LockCVar(cvarName, value)
	if (GetCVar(cvarName) ~= value) then
		SetCVar(cvarName, value)
	end
	self.LockedCVars[cvarName] = value
end

function K:IgnoreCVar(cvarName, ignore)
	ignore = not not ignore -- cast to bool, just in case
	self.IgnoredCVars[cvarName] = ignore
end

-- Personal Dev use only
K.IsDev = {Aceer = true, Kkthnx = true, Kkthnxx = true, Pervie = true, Tatterdots = true} -- We will add more of my names as we go.
K.IsDevRealm = {Stormreaver = true} -- Don"t forget to update realm name(s) if we ever transfer realms.
-- If we forget it could be easly picked up by another player who matches these combinations.
-- End result we piss off people and we do not want to do that. :(

function K.IsDeveloper()
	return K.IsDev[K.Name] or false
end

function K.IsDeveloperRealm()
	return K.IsDevRealm[K.Realm] or false
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

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

-- Example: killMenuOption(true, "InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait")
function K.KillMenuOption(option_shrink, option_name)
	local option = _G[option_name]
	if not(option) or not(option.IsObjectType) or not(option:IsObjectType("Frame")) then
		return
	end
	option:SetParent(UIFrameHider)
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
			panel:SetParent(UIFrameHider)
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

-- Add time before calling a function
local waitTable = {}
local waitFrame
function K.Delay(delay, func, ...)
	if (type(delay) ~= "number" or type(func) ~= "function") then
		return false
	end
	if (waitFrame == nil) then
		waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
		waitFrame:SetScript("onUpdate", function (_, elapse)
			local count = #waitTable
			local i = 1
			while(i <= count) do
				local waitRecord = table_remove(waitTable, i)
				local d = table_remove(waitRecord,1)
				local f = table_remove(waitRecord,1)
				local p = table_remove(waitRecord,1)
				if (d > elapse) then
					table_insert(waitTable, i, {d-elapse, f, p})
					i = i + 1
				else
					count = count - 1
					f(unpack(p))
				end
			end
		end)
	end
	table_insert(waitTable, {delay, func, {...}})
	return true
end