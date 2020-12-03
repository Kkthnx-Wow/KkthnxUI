local K, C = unpack(select(2, ...))

local _G = _G
local math_abs = _G.math.abs
local math_floor = _G.math.floor
local mod = _G.mod
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_lower = _G.string.lower
local string_match = _G.string.match
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

local C_Map_GetWorldPosFromMapPos = _G.C_Map.GetWorldPosFromMapPos
local CreateVector2D = _G.CreateVector2D
local ENCHANTED_TOOLTIP_LINE = _G.ENCHANTED_TOOLTIP_LINE
local GameTooltip = _G.GameTooltip
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local GetTime = _G.GetTime
local ITEM_LEVEL = _G.ITEM_LEVEL
local IsEveryoneAssistant = _G.IsEveryoneAssistant
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitReaction = _G.UnitReaction

local iLvlDB = {}
local enchantString = string_gsub(ENCHANTED_TOOLTIP_LINE, "%%s", "(.+)")
local itemLevelString = string_gsub(ITEM_LEVEL, "%%d", "")

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)

function K.Print(...)
	print("|cff3c9bedKkthnxUI:|r", ...)
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

		return string_format("|cff%02x%02x%02x", r*255, g*255, b*255)
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

function K.CreateFontString(self, size, text, textstyle, classcolor, anchor, x, y)
	local fs = self:CreateFontString(nil, "OVERLAY")

	if textstyle == " " or textstyle == "" or textstyle == nil then
		fs:SetFont(C["Media"].Font, size, "")
		fs:SetShadowOffset(1, -1 / 2)
	else
		fs:SetFont(C["Media"].Font, size, "OUTLINE")
		fs:SetShadowOffset(0, 0)
	end
	fs:SetText(text)
	fs:SetWordWrap(false)

	if classcolor and type(classcolor) == "boolean" then
		fs:SetTextColor(K.r, K.g, K.b)
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
		r, g, b = 0.6, 0.6, 0.6
	else
		local reaction = UnitReaction(unit, "player")
		if reaction then
			local color = K.Colors.reaction[reaction]
			r, g, b = color[1], color[2], color[3]
		end
	end

	return r, g, b
end

function K.TogglePanel(frame)
	if frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
	end
end

function K.GetNPCID(guid)
	local id = tonumber(string_match((guid or ""), "%-(%d-)%-%x-$"))
	return id
end

function K.CheckAddOnState(addon)
	return K.AddOns[string_lower(addon)] or false
end

function K.GetAddOnVersion(addon)
	return K.AddOnVersion[string_lower(addon)] or nil
end

function K.HelpInfoAcknowledge(callbackArg)
	KkthnxUIData[K.Realm][K.Name].Help[callbackArg] = true
end

-- Itemlevel
function K.InspectItemTextures()
	if not K.ScanTooltip.gems then
		K.ScanTooltip.gems = {}
	else
		table_wipe(K.ScanTooltip.gems)
	end

	for i = 1, 10 do
		local tex = _G[K.ScanTooltip:GetName().."Texture"..i]
		local texture = tex and tex:IsShown() and tex:GetTexture()
		if texture then
			K.ScanTooltip.gems[i] = texture
		end
	end

	return K.ScanTooltip.gems
end

function K.InspectItemInfo(text, slotInfo)
	local itemLevel = string_find(text, itemLevelString) and string_match(text, "(%d+)%)?$")
	if itemLevel then
		slotInfo.iLvl = tonumber(itemLevel)
	end

	local enchant = string_match(text, enchantString)
	if enchant then
		slotInfo.enchantText = enchant
	end
end

function K.GetItemLevel(link, arg1, arg2, fullScan)
	if fullScan then
		K.ScanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		K.ScanTooltip:SetInventoryItem(arg1, arg2)

		if not K.ScanTooltip.slotInfo then
			K.ScanTooltip.slotInfo = {}
		else
			table_wipe(K.ScanTooltip.slotInfo)
		end

		local slotInfo = K.ScanTooltip.slotInfo
		slotInfo.gems = K.InspectItemTextures()

		for i = 1, K.ScanTooltip:NumLines() do
			local line = _G[K.ScanTooltip:GetName().."TextLeft"..i]
			if line then
				local text = line:GetText() or ""
				K.InspectItemInfo(text, slotInfo)
			end
		end

		return slotInfo
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
			local line = _G[K.ScanTooltip:GetName().."TextLeft"..i]
			if line then
				local text = line:GetText() or ""
				local found = string_find(text, itemLevelString)
				if found then
					local level = string_match(text, "(%d+)%)?$")
					iLvlDB[link] = tonumber(level)
					break
				end
			end
		end

		return iLvlDB[link]
	end
end

-- RoleUpdater
local function CheckRole()
	local tree = GetSpecialization()
	if not tree then
		return
	end

	local _, _, _, _, role, stat = GetSpecializationInfo(tree)
	if role == "TANK" then
		K.Role = "Tank"
	elseif role == "HEALER" then
		K.Role = "Healer"
	elseif role == "DAMAGER" then
		if stat == 4 then	-- 1 Strength, 2 Agility, 4 Intellect
			K.Role = "Caster"
		else
			K.Role = "Melee"
		end
	end
end
K:RegisterEvent("PLAYER_LOGIN", CheckRole)
K:RegisterEvent("PLAYER_TALENT_UPDATE", CheckRole)

-- Chat channel check
function K.CheckChat(useRaidWarning)
	if IsPartyLFG() then
		return "INSTANCE_CHAT"
	elseif IsInRaid() then
		if useRaidWarning and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant()) then
			return "RAID_WARNING"
		else
			return "RAID"
		end
	elseif IsInGroup() then
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
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()

	if self.title then
		GameTooltip:AddLine(self.title)
	end

	if self.text and string_find(self.text, "|H.+|h") then
		GameTooltip:SetHyperlink(self.text)
	elseif tonumber(self.text) then
		GameTooltip:SetSpellByID(self.text)
	elseif self.text then
		local r, g, b = 1, 1, 1
		if self.color == "class" then
			r, g, b = K.r, K.g, K.b
		elseif self.color == "system" then
			r, g, b = 1, .8, 0
		elseif self.color == "info" then
			r, g, b = .6, .8, 1
		end

		GameTooltip:AddLine(self.text, r, g, b, 1)
	end

	GameTooltip:Show()
end

function K.AddTooltip(self, anchor, text, color)
	if not self then
		return
	end

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
		while (pos <= bytes) do
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

			if (len == numChars) then
				break
			end
		end

		if (len == numChars and pos <= bytes) then
			return string:sub(1, pos - 1)..(dots and "..." or "")
		else
			return string
		end
	end
end

function K.HideInterfaceOption(self)
	if not self then
		return
	end

	self:SetAlpha(0)
	self:SetScale(0.0001)
end

-- Timer Format
local day, hour, minute = 86400, 3600, 60
function K.FormatTime(s)
	if s >= day then
		return string_format("%d"..K.MyClassColor.."d", s / day), s % day
	elseif s >= hour then
		return string_format("%d"..K.MyClassColor.."h", s / hour), s % hour
	elseif s >= minute then
		return string_format("%d"..K.MyClassColor.."m", s / minute), s % minute
	elseif s > 10 then
		return string_format("|cffcccc33%d|r", s), s - math_floor(s)
	elseif s > 3 then
		return string_format("|cffffff00%d|r", s), s - math_floor(s)
	else
		if C["ActionBar"].DecimalCD then
			return string_format("|cffff0000%.1f|r", s), s - string_format("%.1f", s)
		else
			return string_format("|cffff0000%d|r", s + .5), s - math_floor(s)
		end
	end
end

function K.FormatTimeRaw(s)
	if s >= day then
		return string_format("%dd", s / day)
	elseif s >= hour then
		return string_format("%dh", s / hour)
	elseif s >= minute then
		return string_format("%dm", s / minute)
	elseif s >= 3 then
		return math_floor(s)
	else
		return string_format("%d", s)
	end
end

function K.CooldownOnUpdate(self, elapsed, raw)
	local formatTime = raw and K.FormatTimeRaw or K.FormatTime
	self.elapsed = (self.elapsed or 0) + elapsed
	if self.elapsed >= 0.1 then
		local timeLeft = self.expiration - GetTime()
		if timeLeft > 0 then
			local text = formatTime(timeLeft)
			self.timer:SetText(text)
		else
			self:SetScript("OnUpdate", nil)
			self.timer:SetText(nil)
		end
		self.elapsed = 0
	end
end

function K.GetPlayerMapPos(mapID)
	tempVec2D.x, tempVec2D.y = _G.UnitPosition("player")
	if not tempVec2D.x then
		return
	end

	local mapRect = mapRects[mapID]
	if not mapRect then
		local pos1 = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
		local pos2 = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
		if not pos1 or not pos2 then
			return
		end

		mapRect = {pos1, pos2}
		mapRect[2]:Subtract(mapRect[1])

		mapRects[mapID] = mapRect
	end
	tempVec2D:Subtract(mapRect[1])

	return tempVec2D.y/mapRect[2].y, tempVec2D.x/mapRect[2].x
end

-- Money text formatting, code taken from Scrooge by thelibrarian (http://www.wowace.com/addons/scrooge)
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

function K.CheckSavedVariables()
	if not KkthnxUIData then
		KkthnxUIData = {}
	end

	if not KkthnxUIData[K.Realm] then
		KkthnxUIData[K.Realm] = {}
	end

	if not KkthnxUIData[K.Realm][K.Name] then
		KkthnxUIData[K.Realm][K.Name] = {}
	end

	if KkthnxUIData[K.Realm][K.Name].AutoQuest == nil then
		KkthnxUIData[K.Realm][K.Name].AutoQuest = false
	end

	if not KkthnxUIData[K.Realm][K.Name].BindType then
		KkthnxUIData[K.Realm][K.Name].BindType = 1
	end

	if not KkthnxUIData[K.Realm][K.Name].ChangeLog then
		KkthnxUIData[K.Realm][K.Name].ChangeLog = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].CustomJunkList then
		KkthnxUIData[K.Realm][K.Name].CustomJunkList = {}
	end

	if KkthnxUIData[K.Realm][K.Name].DetectVersion == nil then
		KkthnxUIData[K.Realm][K.Name].DetectVersion = K.Version
	end

	if not KkthnxUIData[K.Realm][K.Name].FavouriteItems then
		KkthnxUIData[K.Realm][K.Name].FavouriteItems = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].Mover then
		KkthnxUIData[K.Realm][K.Name].Mover = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].AuraWatchMover then
		KkthnxUIData[K.Realm][K.Name].AuraWatchMover = {}
	end

	if KkthnxUIData[K.Realm][K.Name].RevealWorldMap == nil then
		KkthnxUIData[K.Realm][K.Name].RevealWorldMap = false
	end

	if not KkthnxUIData[K.Realm][K.Name].SplitCount then
		KkthnxUIData[K.Realm][K.Name].SplitCount = 1
	end

	if not KkthnxUIData[K.Realm][K.Name].ContactList then
		KkthnxUIData[K.Realm][K.Name].ContactList = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].TempAnchor then
		KkthnxUIData[K.Realm][K.Name].TempAnchor = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].InternalCD then
		KkthnxUIData[K.Realm][K.Name].InternalCD = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].AuraWatchList then
		KkthnxUIData[K.Realm][K.Name].AuraWatchList = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].AuraWatchList.Switcher then
		KkthnxUIData[K.Realm][K.Name].AuraWatchList.Switcher = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].AuraWatchList.IgnoreSpells then
		KkthnxUIData[K.Realm][K.Name].AuraWatchList.IgnoreSpells = {}
	end

	if not KkthnxUIData[K.Realm][K.Name].Help then
		KkthnxUIData[K.Realm][K.Name].Help = {}
	end
end