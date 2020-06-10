local K, C = unpack(select(2, ...))

local _G = _G
local math_abs = _G.math.abs
local math_floor = _G.math.floor
local mod = _G.mod
local next = _G.next
local select = _G.select
local string_find = _G.string.find
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_join = _G.string.join
local string_lower = _G.string.lower
local string_match = _G.string.match
local table_insert = _G.table.insert
local table_remove = _G.table.remove
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber
local type = _G.type
local unpack = _G.unpack

local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local ENCHANTED_TOOLTIP_LINE = _G.ENCHANTED_TOOLTIP_LINE
local GameTooltip = _G.GameTooltip
local GetSpecialization = _G.GetSpecialization
local GetSpecializationInfo = _G.GetSpecializationInfo
local GetSpellDescription = _G.GetSpellDescription
local IsEveryoneAssistant = _G.IsEveryoneAssistant
local IsInGroup = _G.IsInGroup
local IsInRaid = _G.IsInRaid
local ITEM_LEVEL = _G.ITEM_LEVEL
local ITEM_SPELL_TRIGGER_ONEQUIP = _G.ITEM_SPELL_TRIGGER_ONEQUIP
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = _G.LE_PARTY_CATEGORY_INSTANCE
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitReaction = _G.UnitReaction

local iLvlDB = {}
local enchantString = string_gsub(ENCHANTED_TOOLTIP_LINE, "%%s", "(.+)")
local essenceDescription = GetSpellDescription(277253)
local essenceTextureID = 2975691
local itemLevelString = string_gsub(ITEM_LEVEL, "%%d", "")
K.activeTimers = K.activeTimers or {} -- Active timer list
local activeTimers = K.activeTimers -- Upvalue our private data
K.hooks = {}
local Hooks = K.hooks

function K.Print(...)
	(_G.DEFAULT_CHAT_FRAME):AddMessage(string_join("", "|cff3c9bed", "KkthnxUI:|r ", ...))
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

-- Itemlevel
function K:InspectItemTextures()
	if not K.ScanTooltip.gems then
		K.ScanTooltip.gems = {}
	else
		table_wipe(K.ScanTooltip.gems)
	end

	if not K.ScanTooltip.essences then
		K.ScanTooltip.essences = {}
	else
		for _, essences in pairs(K.ScanTooltip.essences) do
			table_wipe(essences)
		end
	end

	local step = 1
	for i = 1, 10 do
		local tex = _G[K.ScanTooltip:GetName().."Texture"..i]
		local texture = tex and tex:IsShown() and tex:GetTexture()
		if texture then
			if texture == essenceTextureID then
				local selected = (K.ScanTooltip.gems[i-1] ~= essenceTextureID and K.ScanTooltip.gems[i-1]) or nil
				if not K.ScanTooltip.essences[step] then
					K.ScanTooltip.essences[step] = {}
				end
				K.ScanTooltip.essences[step][1] = selected -- essence texture if selected or nil
				K.ScanTooltip.essences[step][2] = tex:GetAtlas() -- atlas place 'tooltip-heartofazerothessence-major' or 'tooltip-heartofazerothessence-minor'
				K.ScanTooltip.essences[step][3] = texture -- border texture placed by the atlas

				step = step + 1
				if selected then K.ScanTooltip.gems[i-1] = nil end
			else
				K.ScanTooltip.gems[i] = texture
			end
		end
	end

	return K.ScanTooltip.gems, K.ScanTooltip.essences
end

function K:InspectItemInfo(text, slotInfo)
	local itemLevel = string_find(text, itemLevelString) and string_match(text, "(%d+)%)?$")
	if itemLevel then
		slotInfo.iLvl = tonumber(itemLevel)
	end

	local enchant = string_match(text, enchantString)
	if enchant then
		slotInfo.enchantText = enchant
	end
end

function K:CollectEssenceInfo(index, lineText, slotInfo)
	local step = 1
	local essence = slotInfo.essences[step]
	if essence and next(essence) and (string_find(lineText, ITEM_SPELL_TRIGGER_ONEQUIP, nil, true) and string_find(lineText, essenceDescription, nil, true)) then
		for i = 4, 2, -1 do
			local line = _G[K.ScanTooltip:GetName().."TextLeft"..index-i]
			local text = line and line:GetText()

			if text and (not string_match(text, "^[ +]")) and essence and next(essence) then
				local r, g, b = line:GetTextColor()
				essence[4] = r
				essence[5] = g
				essence[6] = b

				step = step + 1
				essence = slotInfo.essences[step]
			end
		end
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
		slotInfo.gems, slotInfo.essences = K:InspectItemTextures()

		for i = 1, K.ScanTooltip:NumLines() do
			local line = _G[K.ScanTooltip:GetName().."TextLeft"..i]
			if line then
				local text = line:GetText() or ""
				K:InspectItemInfo(text, slotInfo)
				K:CollectEssenceInfo(i, text, slotInfo)
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

	K.Specialization = tree
	local _, _, _, _, role, stat = GetSpecializationInfo(tree)
	if role == "TANK" then
		K.Role = "Tank"
	elseif role == "HEALER" then
		K.Role = "Healer"
	elseif role == "DAMAGER" then
		if stat == 4 then	--1力量，2敏捷，4智力
			K.Role = "Caster"
		else
			K.Role = "Melee"
		end
	end
end
K:RegisterEvent("PLAYER_ENTERING_WORLD", CheckRole)
K:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", CheckRole)
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
	self.anchor = anchor
	self.text = text
	self.color = color

	self:SetScript("OnEnter", tooltipOnEnter)
	self:SetScript("OnLeave", K.HideTooltip)
end

function K.Scale(x)
	local mult = C.mult
	return mult * math_floor(x / mult + .5)
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

function K.ColorGradient(perc, ...)
	if perc >= 1 then
		return select(select("#", ...) - 2, ...)
	elseif perc <= 0 then
		return ...
	end

	local num = select("#", ...) / 3
	local segment, relperc = math.modf(perc * (num - 1))
	local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
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
		return string_format("%dd", s/day)
	elseif s >= hour then
		return string_format("%dh", s/hour)
	elseif s >= minute then
		return string_format("%dm", s/minute)
	elseif s >= 3 then
		return math_floor(s)
	else
		return string_format("%d", s)
	end
end

function K:CooldownOnUpdate(elapsed, raw)
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

-- Money text formatting, code taken from Scrooge by thelibrarian (http://www.wowace.com/addons/scrooge)
local ICON_COPPER = "|TInterface\\MoneyFrame\\UI-CopperIcon:12:12|t"
local ICON_SILVER = "|TInterface\\MoneyFrame\\UI-SilverIcon:12:12|t"
local ICON_GOLD = "|TInterface\\MoneyFrame\\UI-GoldIcon:12:12|t"
function K.FormatMoney(amount)
	local coppername = "|cffeda55fc|r" or ICON_COPPER
	local silvername = "|cffc7c7cfs|r" or ICON_SILVER
	local goldname = "|cffffd700g|r" or ICON_GOLD

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

function K:ClearHook(frame, handler, hook, uniqueID)
	if (not Hooks[frame]) or (not Hooks[frame][handler]) then
		return
	end

	local hookList = Hooks[frame][handler]

	if uniqueID then
		hookList.unique[uniqueID] = nil
	else
		for id = #hookList.list,1,-1 do
			local func = hookList.list[id]
			if (func == hook) then
				table.remove(hookList.list, id)
			end
		end
	end
end

function K:SetHook(frame, handler, hook, uniqueID)
	-- If the hook is a method, we need a uniqueID for our module reference list!
	if (type(hook) == "string") then
		-- Let's make this backwards compatible and just make up an ID when it's not provided(?)
		if (not uniqueID) then
			uniqueID = (self:GetName()).."_"..hook
		end

		-- Reference the module
		K[uniqueID] = self
	end

	if (not Hooks[frame]) then
		Hooks[frame] = {}
	end

	if (not Hooks[frame][handler]) then
		Hooks[frame][handler] = { list = {}, unique = {} }
		-- We only need a single handler
		-- Problem discovered in 8.2.0:
		-- The 'self' here will only refer to the first module
		-- that registered a hook for this frame and script handler.
		-- Meaning unless we track each registration's module,
		-- we'll get a nil error or weird bug by usind the wrong 'self'!
		local hookList = Hooks[frame][handler]
		frame:HookScript(handler, function(...)
			for id,func in pairs(hookList.unique) do
				if (type(func) == "string") then
					local module = K[id]
					if (module) then
						module[func](module, id, ...)
					end
				else
					-- We allow unique hooks to just run a function
					-- without passing the self.
					func(...)
				end
			end

			-- This only ever occurs when the hook is a function,
			-- and no uniqueID is given.
			for _, func in ipairs(hookList.list) do
				func(...)
			end
		end)
	end

	local hookList = Hooks[frame][handler]
	if uniqueID then
		hookList.unique[uniqueID] = hook
	else
		local exists
		for _, func in ipairs(hookList.list) do
			if (func == hook) then
				exists = true
				break
			end
		end

		if (not exists) then
			table_insert(hookList.list, hook)
		end
	end
end

-- Ripped out of AceTimer :|
local function new(self, loop, func, delay, ...)
	if delay < 0.01 then
		delay = 0.01 -- Restrict to the lowest time that the C_Timer API allows us
	end

	local timer = {
		object = self,
		func = func,
		looping = loop,
		argsCount = select("#", ...),
		delay = delay,
		ends = GetTime() + delay,
		...
	}

	activeTimers[timer] = timer

	-- Create new timer closure to wrap the "timer" object
	timer.callback = function()
		if not timer.cancelled then
			if type(timer.func) == "string" then
				-- We manually set the unpack count to prevent issues with an arg set that contains nil and ends with nil
				-- e.g. local t = {1, 2, nil, 3, nil} print(#t) will result in 2, instead of 5. This fixes said issue.
				timer.object[timer.func](timer.object, unpack(timer, 1, timer.argsCount))
			else
				timer.func(unpack(timer, 1, timer.argsCount))
			end

			if timer.looping and not timer.cancelled then
				-- Compensate delay to get a perfect average delay, even if individual times don't match up perfectly
				-- due to fps differences
				local time = GetTime()
				local delay = timer.delay - (time - timer.ends)
				-- Ensure the delay doesn't go below the threshold
				if delay < 0.01 then
					delay = 0.01
				end

				C_Timer_After(delay, timer.callback)
				timer.ends = time + delay
			else
				activeTimers[timer.handle or timer] = nil
			end
		end
	end

	C_Timer_After(delay, timer.callback)
	return timer
end

-- Schedule a new one-shot timer.
function K:ScheduleTimer(func, delay, ...)
	if not func or not delay then
		K.Print(": ScheduleTimer(callback, delay, args...): 'callback' and 'delay' must have set values.", 2)
	end

	if type(func) == "string" then
		if type(self) ~= "table" then
			K.Print(": ScheduleTimer(callback, delay, args...): 'self' - must be a table.", 2)
		elseif not self[func] then
			K.Print(": ScheduleTimer(callback, delay, args...): Tried to register '"..func.."' as the callback, but it doesn't exist in the module.", 2)
		end
	end

	return new(self, nil, func, delay, ...)
end

-- Schedule a repeating timer.
function K:ScheduleRepeatingTimer(func, delay, ...)
	if not func or not delay then
		K.Print(": ScheduleRepeatingTimer(callback, delay, args...): 'callback' and 'delay' must have set values.", 2)
	end

	if type(func) == "string" then
		if type(self) ~= "table" then
			K.Print(": ScheduleRepeatingTimer(callback, delay, args...): 'self' - must be a table.", 2)
		elseif not self[func] then
			K.Print(": ScheduleRepeatingTimer(callback, delay, args...): Tried to register '"..func.."' as the callback, but it doesn't exist in the module.", 2)
		end
	end

	return new(self, true, func, delay, ...)
end

-- Cancels a timer with the given id, registered by the same addon object as used for `:ScheduleTimer`
function K:CancelTimer(id)
	local timer = activeTimers[id]

	if not timer then
		return false
	else
		timer.cancelled = true
		activeTimers[id] = nil
		return true
	end
end

-- Cancels all timers registered to the current addon object ('self')
function K:CancelAllTimers()
	for k,v in next, activeTimers do
		if v.object == self then
			K.CancelTimer(self, k)
		end
	end
end

-- Returns the time left for a timer with the given id, registered by the current addon object ('self').
function K:TimeLeft(id)
	local timer = activeTimers[id]
	if not timer then
		return 0
	else
		return timer.ends - GetTime()
	end
end