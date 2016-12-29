local K, C, L = unpack(select(2, ...))

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

function K.Print(...)
	print("|cff3c9bed" .. K.UIName .. "|r:", ...)
end

function K.SetFontString(parent, fontName, fontHeight, fontStyle, justify)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH(justify or "CENTER")
	fs:SetShadowColor(0, 0, 0, 1)
	fs:SetShadowOffset(K.Mult, -K.Mult)

	return fs
end

function K.Comma(num)
	local Left, Number, Right = match(num, "^([^%d]*%d)(%d*)(.-)$")

	return 	Left .. reverse(gsub(reverse(Number), "(%d%d%d)", "%1,")) .. Right
end

function K.ShortValue(value)
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
function K.Round(num, idp)
	if (idp and idp > 0) then
		local mult = 10 ^ idp
		return floor(num * mult + 0.5) / mult
	end
	return floor(num + 0.5)
end

-- RgbToHex color
function K.RGBToHex(r, g, b)
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return format("|cff%02x%02x%02x", r*255, g*255, b*255)
end

function K.CheckAddOn(addon)
	return K.AddOns[strlower(addon)] or false
end

-- We might need to move these to API?
function K.CreateBlizzardFrame(frame, point)
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

function K.SetBlizzardBorder(frame, r, g, b, a)
	if not a then a = 1 end
	frame.backdrop:SetBackdropBorderColor(r, g, b, a)
end

function K.CreateShadowFrame(frame, point)
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

function K.SetShadowBorder(frame, r, g, b, a)
	if not a then a = 0.9 end
	frame.backdrop:SetBackdropBorderColor(r, g, b, a)
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

function K.UTF8Sub(string, numChars, dots)
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
			return string:sub(1, pos - 1)..(dots and '...' or '')
		else
			return string
		end
	end
end

local SetUpAnimGroup = function(self)
	self.anim = self:CreateAnimationGroup()
	self.anim:SetLooping("BOUNCE")
	self.anim.fade = self.anim:CreateAnimation("Alpha")
	self.anim.fade:SetFromAlpha(1)
	self.anim.fade:SetToAlpha(0)
	self.anim.fade:SetDuration(0.6)
	self.anim.fade:SetSmoothing("IN_OUT")
end

function K.Flash(self)
	if not self.anim then
		SetUpAnimGroup(self)
	end

	if not self.anim:IsPlaying() then
		self.anim:Play()
	end
end

function K.StopFlash(self)
	if self.anim then
		self.anim:Finish()
	end
end

function K.FormatMoney(value)
	if value >= 1e4 then
		return format("|cffffd700%dg |r|cffc7c7cf%ds |r|cffeda55f%dc|r", value/1e4, strsub(value, -4) / 1e2, strsub(value, -2))
	elseif value >= 1e2 then
		return format("|cffc7c7cf%ds |r|cffeda55f%dc|r", strsub(value, -4) / 1e2, strsub(value, -2))
	else
		return format("|cffeda55f%dc|r", strsub(value, -2))
	end
end

-- http://www.wowwiki.com/ColorGradient
function K.ColorGradient(a, b, ...)
	local percent

	if(b == 0) then
		percent = 0
	else
		percent = a / b
	end

	if (percent >= 1) then
		local r, g, b = select(select("#", ...) - 2, ...)

		return r, g, b
	elseif (percent <= 0) then
		local r, g, b = ...

		return r, g, b
	end

	local num = (select("#", ...) / 3)
	local segment, relpercent = modf(percent * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2 - r1) * relpercent, g1 + (g2 - g1) * relpercent, b1 + (b2 - b1) * relpercent
end

-- Example:
-- killMenuOption(true, "InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait")
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
--
-- 'panel_id' is basically the number of the submenu, when all menus are still there.
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
			panel:SetParent(UIHider)
			if panel.UnregisterAllEvents then
				panel:UnregisterAllEvents()
			end
			panel.cancel = function() end
			panel.okay = function() end
			panel.refresh = function() end
		end
	end
end

-- Format seconds to min/ hour / day
function K.FormatTime(s)
	local day, hour, minute = 86400, 3600, 60

	if s >= day then
		return format("%dd", floor(s / day + 0.5)), s % day
	elseif s >= hour then
		return format("%dh", floor(s / hour + 0.5)), s % hour
	elseif s >= minute then
		return format("%dm", floor(s / minute + 0.5)), s % minute
	elseif s >= minute / 12 then
		return floor(s + 0.5), (s * 100 - floor(s * 100)) / 100
	end
	return format("%.1f", s), (s * 100 - floor(s * 100)) / 100
end

--Add time before calling a function
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
				local waitRecord = tremove(waitTable,i)
				local d = tremove(waitRecord,1)
				local f = tremove(waitRecord,1)
				local p = tremove(waitRecord,1)
				if (d > elapse) then
					tinsert(waitTable,i,{d-elapse,f,p})
					i = i + 1
				else
					count = count - 1
					f(unpack(p))
				end
			end
		end)
	end
	tinsert(waitTable,{delay,func,{...}})
	return true
end

-- Currencys
local GetCurrencyInfo = GetCurrencyInfo
function K.Currency(id, weekly, capped)
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