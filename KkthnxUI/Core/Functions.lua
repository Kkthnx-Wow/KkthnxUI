local K, C = unpack(select(2, ...))

local _G = _G
local assert = _G.assert
local math_abs = _G.math.abs
local math_ceil = _G.math.ceil
local math_floor = _G.math.floor
local mod = _G.mod
local select = _G.select
local string_format = _G.string.format
local string_gmatch = _G.string.gmatch
local string_join = _G.string.join
local string_lower = _G.string.lower
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local table_wipe = _G.table.wipe
local type = _G.type
local unpack = _G.unpack

local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetSpecialization = _G.GetSpecialization
local IsEveryoneAssistant = _G.IsEveryoneAssistant
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitReaction = _G.UnitReaction
local GameTooltip = _G.GameTooltip

function K.Print(...)
	(_G.DEFAULT_CHAT_FRAME):AddMessage(string_join("", "|cff3c9bed", "KkthnxUI:|r ", ...))
end

-- Table
function K.CopyTable(source, target)
	for key, value in pairs(source) do
		if type(value) == "table" then
			if not target[key] then
				target[key] = {}
			end

			for k in pairs(value) do
				target[key][k] = value[k]
			end
		else
			target[key] = value
		end
	end
end

function K.SplitList(list, variable, cleanup)
	if cleanup then
		table_wipe(list)
	end

	for word in string_gmatch(variable, "%S+") do
		list[word] = true
	end
end

-- Return short value of a number
function K.ShortValue(n)
	if C["General"].NumberPrefixStyle.Value == 1 then
		if n >= 1e12 then
			return string_format("%.2ft", n / 1e12)
		elseif n >= 1e9 then
			return string_format("%.2fb", n / 1e9)
		elseif n >= 1e6 then
			return string_format("%.2fm", n / 1e6)
		elseif n >= 1e3 then
			return string_format("%.1fk", n / 1e3)
		else
			return string_format("%.0f", n)
		end
	elseif C["General"].NumberPrefixStyle.Value == 2 then
		if n >= 1e12 then
			return string_format("%.2f".."z", n / 1e12)
		elseif n >= 1e8 then
			return string_format("%.2f".."y", n / 1e8)
		elseif n >= 1e4 then
			return string_format("%.1f".."w", n / 1e4)
		else
			return string_format("%.0f", n)
		end
	else
		return string_format("%.0f", n)
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

-- RGBToHex
function K.RGBToHex(r, g, b)
	if r then
		if type(r) == "table" then
			if r.r then
				r, g, b = r.r, r.g, r.b
			else
				r, g, b = unpack(r)
			end
		end
		return string_format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
	end
end

-- Gradient Frame
function K.CreateGF(self, w, h, o, r, g, b, a1, a2)
	self:SetSize(w, h)
	self:SetFrameStrata("BACKGROUND")

	local gradientFrame = self:CreateTexture(nil, "BACKGROUND")
	gradientFrame:SetAllPoints()
	gradientFrame:SetTexture(C["Media"].Blank)
	gradientFrame:SetGradientAlpha(o, r, g, b, a1, r, g, b, a2)
end

function K.CreateFontString(self, size, text, classcolor, anchor, x, y)
	local fs = self:CreateFontString(nil, "OVERLAY")
	fs:SetFont(C.Media.Font, size, "OUTLINE")
	fs:SetText(text)
	fs:SetWordWrap(false)

	if classcolor and type(classcolor) == "boolean" then
		fs:SetTextColor(1, 1, 1)
	elseif classcolor == "system" then
		fs:SetTextColor(1, .8, 0)
	end

	if anchor and x and y then
		fs:SetPoint(anchor, x, y)
	else
		fs:SetPoint("CENTER", 1, 0)
	end

	return fs
end

function K.ColorClass(class)
	local color = K.ClassColors[class]
	if not color then
		return 1, 1, 1
	end

	return color.r, color.g, color.b
end

function K.UnitColor(unit)
	local r, g, b = 1, 1, 1
	if UnitIsPlayer(unit) then
		local class = select(2, UnitClass(unit))
		if class then
			r, g, b = K.ColorClass(class)
		end
	elseif UnitIsTapDenied(unit) then
		r, g, b = .6, .6, .6
	else
		local reaction = UnitReaction(unit, "player")
		if reaction then
			local color = K.Colors.reaction[reaction]
			r, g, b = color[1], color[2], color[3]
		end
	end

	return r, g, b
end

function K.GetNPCID(guid)
	local id = tonumber(string.match((guid or ""), "%-(%d-)%-%x-$"))
	return id
end

function K.CheckAddOnState(addon)
	return K.AddOns[string_lower(addon)] or false
end

function K.GetAddOnVersion(addon)
	return K.AddOnVersion[string_lower(addon)] or nil
end

-- Itemlevel
local iLvlDB = {}
local itemLevelString = gsub(ITEM_LEVEL, "%%d", "")
local enchantString = gsub(ENCHANTED_TOOLTIP_LINE, "%%s", "(.+)")
local essenceTextureID = 2975691
local texturesDB, essencesDB = {}, {}
function K:InspectItemTextures(clean, grabTextures)
	table_wipe(texturesDB)
	table_wipe(essencesDB)

	for i = 1, 5 do
		local tex = _G[K.ScanTooltip:GetName().."Texture"..i]
		local texture = tex and tex:GetTexture()
		if texture then
			if grabTextures then
				if texture == essenceTextureID then
					local selected = (texturesDB[i-1] ~= essenceTextureID and texturesDB[i-1]) or nil
					essencesDB[i] = {selected, tex:GetAtlas(), texture}
					if selected then texturesDB[i-1] = nil end
				else
					texturesDB[i] = texture
				end
			end

			if clean then
				tex:SetTexture()
			end
		end
	end

	return texturesDB, essencesDB
end

function K:InspectItemInfo(text, iLvl, enchantText)
	local itemLevel = strfind(text, itemLevelString) and strmatch(text, "(%d+)%)?$")
	if itemLevel then
		iLvl = tonumber(itemLevel)
	end

	local enchant = strmatch(text, enchantString)
	if enchant then
		enchantText = enchant
	end

	return iLvl, enchantText
end

function K.GetItemLevel(link, arg1, arg2, fullScan)
	if fullScan then
		K:InspectItemTextures(true)
		K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		K.ScanTooltip:SetInventoryItem(arg1, arg2)

		local iLvl, enchantText, gems, essences
		gems, essences = K:InspectItemTextures(nil, true)

		for i = 1, K.ScanTooltip:NumLines() do
			local text = _G[K.ScanTooltip:GetName().."TextLeft"..i]:GetText() or ""
			iLvl, enchantText = K:InspectItemInfo(text, iLvl, enchantText)
			if enchantText then
				break
			end
		end

		return iLvl, enchantText, gems, essences
	else
		if iLvlDB[link] then
			return iLvlDB[link]
		end

		K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		if arg1 and type(arg1) == "string" then
			K.ScanTooltip:SetInventoryItem(arg1, arg2)
		elseif arg1 and type(arg1) == "number" then
			K.ScanTooltip:SetBagItem(arg1, arg2)
		else
			K.ScanTooltip:SetHyperlink(link)
		end

		for i = 2, 5 do
			local text = _G[K.ScanTooltip:GetName().."TextLeft"..i]:GetText() or ""
			local found = strfind(text, itemLevelString)
			if found then
				local level = strmatch(text, "(%d+)%)?$")
				iLvlDB[link] = tonumber(level)
				break
			end
		end

		return iLvlDB[link]
	end
end

local function CheckRole()
	local tree = GetSpecialization()
	if not tree then return end
	local _, _, _, _, role, stat = GetSpecializationInfo(tree)
	if role == "TANK" then
		K.Role = "Tank"
	elseif role == "HEALER" then
		K.Role = "Healer"
	elseif role == "DAMAGER" then
		if stat == 4 then
			K.Role = "Caster"
		else
			K.Role = "Melee"
		end
	end
end
K:RegisterEvent("PLAYER_LOGIN", CheckRole)
K:RegisterEvent("PLAYER_TALENT_UPDATE", CheckRole)

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

	if not x or not y then
		return "CENTER"
	end

	local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"

	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

function K.HideTooltip()
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:Hide()
end

local function tooltipOnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()
	if tonumber(self.text) then
		GameTooltip:SetSpellByID(self.text)
	else
		local r, g, b = 1, 1, 1
		if self.color == "class" then
			r, g, b = K.Color.r, K.Color.g, K.Color.b
		elseif self.color == "system" then
			r, g, b = 1, .8, 0
		end
		GameTooltip:AddLine(self.text, r, g, b, 1)
	end
	GameTooltip:Show()
end

function K.AddTooltip(self, anchor, text, color)
	self.anchor = anchor
	self.text = text
	self.color = color

	self:SetScript("OnEnter", tooltipOnEnter)
	self:SetScript("OnLeave", K.HideTooltip)
end

-- Movable Frame
function K.CreateMoverFrame(self, parent, saved)
	local frame = parent or self
	frame:SetMovable(true)
	frame:SetUserPlaced(true)
	frame:SetClampedToScreen(true)

	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function()
		frame:StartMoving()
	end)
	self:SetScript("OnDragStop", function()
		frame:StopMovingOrSizing()
		if not saved then
			return
		end
		local orig, _, tar, x, y = frame:GetPoint()
		KkthnxUIData[K.Realm][K.Name]["TempAnchor"][frame:GetName()] = {orig, "UIParent", tar, x, y}
	end)
end

function K.RestoreMoverFrame(self)
	local name = self:GetName()
	if name and KkthnxUIData[K.Realm][K.Name]["TempAnchor"][name] then
		self:ClearAllPoints()
		self:SetPoint(unpack(KkthnxUIData[K.Realm][K.Name]["TempAnchor"][name]))
	end
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
	local segment, relperc = math.modf(perc * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2-r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

function K.HideInterfaceOption(self)
	self:SetAlpha(0)
	self:SetScale(.0001)
end

-- Format seconds to min/hour/day
local Day, Hour, Minute = 86400, 3600, 60
function K.FormatTime(s)
	if s >= Day then
		return string_format("%d"..K.MyClassColor.."d", s / Day), s % Day
	elseif s >= Hour then
		return string_format("%d"..K.MyClassColor.."h", s / Hour), s % Hour
	elseif s >= Minute then
		return string_format("%d"..K.MyClassColor.."m", s / Minute), s % Minute
	elseif s > 10 then
		return string_format("|cffcccc33%d|r", s), s - math_floor(s)
	elseif s > 3 then
		return string_format("|cffffff00%d|r", s), s - math_floor(s)
	else
		return string_format("|cffff0000%.1f|r", s), s - string_format("%.1f", s)
	end
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
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY / 2 + 0.5, HOUR / 2 + 0.5, MINUTE / 2 + 0.5 --used for calculating next update times
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
function K.WaitFunc(_, elapse)
	local i = 1
	while i <= #K.WaitTable do
		local data = K.WaitTable[i]
		if data[1] > elapse then
			data[1], i = data[1] - elapse, i + 1
		else
			table_remove(K.WaitTable, i)
			data[2](unpack(data[3]))

			if #K.WaitTable == 0 then
				K.WaitFrame:Hide()
			end
		end
	end
end

K.WaitTable = {}
K.WaitFrame = CreateFrame("Frame", "KkthnxUI_WaitFrame", _G.UIParent)
K.WaitFrame:SetScript("OnUpdate", K.WaitFunc)

-- Add time before calling a function
function K.Delay(delay, func, ...)
	if type(delay) ~= "number" or type(func) ~= "function" then
		return false
	end

	-- Restrict to the lowest time that the C_Timer API allows us
	if delay < 0.01 then
		delay = 0.01
	end

	if select("#", ...) <= 0 then
		C_Timer_After(delay, func)
	else
		table_insert(K.WaitTable, {delay, func, {...}})
		K.WaitFrame:Show()
	end

	return true
end