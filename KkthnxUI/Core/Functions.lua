local K, C = KkthnxUI[1], KkthnxUI[2]

local math_abs = math.abs
local math_floor = math.floor
local mod = mod
local select = select
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match
local table_wipe = table.wipe
local tonumber = tonumber
local type = type
local unpack = unpack

local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos
local CreateVector2D = CreateVector2D
local ENCHANTED_TOOLTIP_LINE = ENCHANTED_TOOLTIP_LINE
local GameTooltip = GameTooltip
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetTime = GetTime
local ITEM_LEVEL = ITEM_LEVEL
local IsInRaid = IsInRaid
local UIParent = UIParent
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitReaction = UnitReaction

-- General Utility Functions
do
	function K.Print(...)
		print("|cff3c9bedKkthnxUI:|r", ...)
	end

	function K.ShortValue(n)
		local prefixStyle = C["General"].NumberPrefixStyle.Value
		local abs_n = abs(n)
		local suffix, div = "", 1

		-- Calculate the appropriate suffix and division factor.
		if abs_n >= 1e12 then
			suffix, div = (prefixStyle == 1 and "t" or "z"), 1e12
		elseif abs_n >= 1e9 then
			suffix, div = (prefixStyle == 1 and "b" or "y"), 1e9
		elseif abs_n >= 1e6 then
			suffix, div = (prefixStyle == 1 and "m" or "w"), 1e6
		elseif abs_n >= 1e3 then
			suffix, div = (prefixStyle == 1 and "k" or "w"), 1e3
		end

		-- Format the shortened value.
		local val = n / div
		if div > 1 and val < 10 then
			return string_format("%.1f%s", val, suffix)
		else
			return string_format("%d%s", val, suffix)
		end
	end

	function K.Round(number, idp)
		if type(number) ~= "number" then
			return
		end

		if idp ~= nil and type(idp) ~= "number" then
			return
		end

		idp = idp or 0
		local mult = 10 ^ idp

		return math.floor(number * mult + 0.5) / mult
	end
end

-- Color-related Functions
do
	local factor = 255
	function K.RGBToHex(r, g, b)
		-- Check if r is a table, and extract r, g, b values from it if necessary
		if type(r) == "table" then
			r, g, b = r.r or r[1], r.g or r[2], r.b or r[3]
		end
		-- Check if r is not nil, and return the hex code if true
		if r then
			-- Convert RGB values to hexadecimal format
			local hex = string.format("%02x%02x%02x", r * factor, g * factor, b * factor)
			-- Return the hex code with alpha value appended
			return "|cff" .. hex
		end
	end

	-- Function to get the class icon using atlas textures
	function K.GetClassIcon(class, iconSize)
		local size = iconSize or 16
		if class then
			return string.format("|A:groupfinder-icon-class-%s:%d:%d|a ", string.lower(class), size, size)
		end
	end

	-- Table for class colors
	local ClassColors = {
		DEATHKNIGHT = "|CFFC41F3B",
		DEMONHUNTER = "|CFFA330C9",
		DRUID = "|CFFFF7D0A",
		EVOKER = "|CFF33937F",
		HUNTER = "|CFFA9D271",
		MAGE = "|CFF40C7EB",
		MONK = "|CFF00FF96",
		PALADIN = "|CFFF58CBA",
		PRIEST = "|CFFFFFFFF",
		ROGUE = "|CFFFFF569",
		SHAMAN = "|CFF0070DE",
		WARLOCK = "|CFF8787ED",
		WARRIOR = "|CFFC79C6E",
	}

	-- Function to get the class color
	function K.GetClassColor(class)
		return ClassColors[class]
	end

	-- Function to get the class icon and color
	function K.GetClassIconAndColor(class, iconSize)
		local classIcon = K.GetClassIcon(class, iconSize)
		local classColor = K.GetClassColor(class)
		return classIcon .. classColor
	end

	function K.GetTextureStrByAtlas(info, sizeX, sizeY)
		local file = info and info.file
		if not file then
			return
		end

		local width = info.width
		local height = info.height
		local left = info.leftTexCoord
		local right = info.rightTexCoord
		local top = info.topTexCoord
		local bottom = info.bottomTexCoord

		local atlasWidth = width / (right - left)
		local atlasHeight = height / (bottom - top)

		sizeX = sizeX or 0
		sizeY = sizeY or 0

		return string_format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", file, sizeX, sizeY, atlasWidth, atlasHeight, atlasWidth * left, atlasWidth * right, atlasHeight * top, atlasHeight * bottom)
	end
end

-- Table-related Functions
do
	function K.CopyTable(source, target, seen)
		target = target or {}
		seen = seen or {}

		if seen[source] then
			return seen[source]
		end

		seen[source] = target

		for key, value in pairs(source) do
			if type(value) == "table" then
				target[key] = K.CopyTable(value, target[key] or {}, seen)
			else
				target[key] = value
			end
		end

		return target
	end

	function K.SplitList(list, variable, cleanup)
		variable = variable or ""

		if cleanup then
			wipe(list)
		end

		for word in gmatch(variable, "%S+") do
			word = tonumber(word) or word -- Convert to number if possible
			list[word] = true
		end
	end
end

-- Gradient Frame and Font String Functions
do
	-- Gradient Frame
	local gradientFrom, gradientTo = CreateColor(0, 0, 0, 0.5), CreateColor(0.3, 0.3, 0.3, 0.3)
	function K.CreateGF(self, w, h, o, r, g, b, a1, a2)
		-- set the size of the frame
		self:SetSize(w, h)
		-- set the frame strata
		self:SetFrameStrata("BACKGROUND")
		-- create the gradient texture
		local gradientFrame = self:CreateTexture(nil, "BACKGROUND")
		-- set the texture to cover the entire frame
		gradientFrame:SetAllPoints()
		-- set the texture to the white 8x8 texture
		gradientFrame:SetTexture(C["Media"].Textures.White8x8Texture)
		-- set the gradient type and colors
		gradientFrame:SetGradient("Vertical", gradientFrom, gradientTo)
	end

	function K.CreateFontString(self, size, text, textstyle, classcolor, anchor, x, y)
		if not self then
			return
		end

		local fs = self:CreateFontString(nil, "OVERLAY")

		-- check if fontstring is created or not
		if not fs then
			return
		end

		if not textstyle or textstyle == "" then
			fs:SetFont(select(1, KkthnxUIFont:GetFont()), size, "")
			fs:SetShadowOffset(1, -1 / 2)
		else
			fs:SetFont(select(1, KkthnxUIFont:GetFont()), size, "OUTLINE")
			fs:SetShadowOffset(0, 0)
		end
		fs:SetText(text)
		fs:SetWordWrap(false)

		if classcolor and type(classcolor) == "boolean" then
			fs:SetTextColor(K.r, K.g, K.b)
		elseif classcolor == "system" then
			fs:SetTextColor(1, 0.8, 0)
		else
			fs:SetTextColor(1, 1, 1)
		end

		-- check if position is set
		if anchor and x and y then
			fs:SetPoint(anchor, x, y)
		else
			fs:SetPoint("CENTER", 1, 0)
		end

		return fs
	end
end

-- Class Color and Unit Color Functions
do
	function K.ColorClass(class)
		local color = K.ClassColors[class]
		if not color then
			return 1, 1, 1
		end
		return color.r, color.g, color.b
	end

	function K.UnitColor(unit)
		local r, g, b = 1, 1, 1

		if UnitIsPlayer(unit) or UnitInPartyIsAI(unit) then
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
end

-- Other Utility Functions
do
	function K.TogglePanel(frame)
		-- check if the frame is currently shown
		if frame:IsShown() then
			-- if the frame is shown, hide it
			frame:Hide()
		else
			-- if the frame is not shown, show it
			frame:Show()
		end
	end

	function K.GetNPCID(guid)
		local id = tonumber(string_match((guid or ""), "%-(%d-)%-%x-$"))
		return id
	end

	function K.CheckAddOnState(addon)
		if type(addon) ~= "string" then
			return false
		end

		-- Perform the check
		return K.AddOns[string_lower(addon)] or false
	end

	function K.GetAddOnVersion(addon)
		return K.AddOnVersion[string_lower(addon)] or nil
	end

	local function CreateClosure(func, data)
		return function()
			func(unpack(data))
		end
	end

	function K.Delay(delay, func, ...)
		if type(delay) ~= "number" or type(func) ~= "function" then
			return false
		end

		local args = { ... } -- delay: Restrict to the lowest time that the API allows us
		C_Timer.After(delay < 0.01 and 0.01 or delay, (#args <= 0 and func) or CreateClosure(func, args))

		return true
	end

	local FADEFRAMES, FADEMANAGER = {}, CreateFrame("FRAME")
	FADEMANAGER.delay = 0.05

	function K.UIFrameFade_OnUpdate(_, elapsed)
		FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

		if FADEMANAGER.timer > FADEMANAGER.delay then
			FADEMANAGER.timer = 0

			for frame, info in next, FADEFRAMES do
				-- Reset the timer if there isn't one, this is just an internal counter
				if frame:IsVisible() then
					info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.delay)
				else
					info.fadeTimer = info.timeToFade + 1
				end

				-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
				if info.fadeTimer < info.timeToFade then
					if info.mode == "IN" then
						frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
					else
						frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
					end
				else
					frame:SetAlpha(info.endAlpha)

					-- If there is a fadeHoldTime then wait until its passed to continue on
					if info.fadeHoldTime and info.fadeHoldTime > 0 then
						info.fadeHoldTime = info.fadeHoldTime - elapsed
					else
						-- Complete the fade and call the finished function if there is one
						K.UIFrameFadeRemoveFrame(frame)

						if info.finishedFunc then
							if info.finishedArgs then
								info.finishedFunc(unpack(info.finishedArgs))
							else -- optional method
								info.finishedFunc(info.finishedArg1, info.finishedArg2, info.finishedArg3, info.finishedArg4, info.finishedArg5)
							end

							if not info.finishedFuncKeep then
								info.finishedFunc = nil
							end
						end
					end
				end
			end

			if not next(FADEFRAMES) then
				FADEMANAGER:SetScript("OnUpdate", nil)
			end
		end
	end

	-- Generic fade function
	function K.UIFrameFade(frame, info)
		if not frame or frame:IsForbidden() then
			return
		end

		if not info.mode then
			info.mode = "IN"
		end

		if info.mode == "IN" then
			if not info.startAlpha then
				info.startAlpha = 0
			end
			if not info.endAlpha then
				info.endAlpha = 1
			end
			if not info.diffAlpha then
				info.diffAlpha = info.endAlpha - info.startAlpha
			end
		else
			if not info.startAlpha then
				info.startAlpha = 1
			end
			if not info.endAlpha then
				info.endAlpha = 0
			end
			if not info.diffAlpha then
				info.diffAlpha = info.startAlpha - info.endAlpha
			end
		end

		frame.fadeInfo = info
		frame:SetAlpha(info.startAlpha)

		if not FADEFRAMES[frame] then
			FADEFRAMES[frame] = info -- read below comment
			FADEMANAGER:SetScript("OnUpdate", K.UIFrameFade_OnUpdate)
		else
			FADEFRAMES[frame] = info -- keep these both, we need this updated in the event its changed to another ref from a plugin or sth, don't move it up!
		end
	end

	-- Convenience function to do a simple fade in
	function K.UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
		if not frame or frame:IsForbidden() then
			return
		end

		if frame.FadeObject then
			frame.FadeObject.fadeTimer = nil
		else
			frame.FadeObject = {}
		end

		frame.FadeObject.mode = "IN"
		frame.FadeObject.timeToFade = timeToFade
		frame.FadeObject.startAlpha = startAlpha
		frame.FadeObject.endAlpha = endAlpha
		frame.FadeObject.diffAlpha = endAlpha - startAlpha

		K.UIFrameFade(frame, frame.FadeObject)
	end

	-- Convenience function to do a simple fade out
	function K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
		if not frame or frame:IsForbidden() then
			return
		end

		if frame.FadeObject then
			frame.FadeObject.fadeTimer = nil
		else
			frame.FadeObject = {}
		end

		frame.FadeObject.mode = "OUT"
		frame.FadeObject.timeToFade = timeToFade
		frame.FadeObject.startAlpha = startAlpha
		frame.FadeObject.endAlpha = endAlpha
		frame.FadeObject.diffAlpha = startAlpha - endAlpha

		K.UIFrameFade(frame, frame.FadeObject)
	end

	function K.UIFrameFadeRemoveFrame(frame)
		if frame and FADEFRAMES[frame] then
			if frame.FadeObject then
				frame.FadeObject.fadeTimer = nil
			end

			FADEFRAMES[frame] = nil
		end
	end
end

-- Item Level Functions
do
	local iLvlDB = {}
	local enchantString = string_gsub(ENCHANTED_TOOLTIP_LINE, "%%s", "(.+)")
	local itemLevelString = "^" .. string_gsub(ITEM_LEVEL, "%%d", "")
	local isUnknownString = {
		[TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN] = true,
		[TRANSMOGRIFY_TOOLTIP_ITEM_UNKNOWN_APPEARANCE_KNOWN] = true,
	}

	local slotData = { gems = {}, gemsColor = {} }
	function K.GetItemLevel(link, arg1, arg2, fullScan)
		if fullScan then
			local data = C_TooltipInfo.GetInventoryItem(arg1, arg2)
			if not data then
				return
			end

			table_wipe(slotData.gems)
			table_wipe(slotData.gemsColor)
			slotData.iLvl = nil
			slotData.enchantText = nil

			local isHoA = data.id == 158075
			local num = 0
			for i = 2, #data.lines do
				local lineData = data.lines[i]
				if not slotData.iLvl then
					local text = lineData.leftText
					local found = text and strfind(text, itemLevelString)
					if found then
						local level = strmatch(text, "(%d+)%)?$")
						slotData.iLvl = tonumber(level) or 0
					end
				elseif isHoA then
					if lineData.essenceIcon then
						num = num + 1
						slotData.gems[num] = lineData.essenceIcon
						slotData.gemsColor[num] = lineData.leftColor
					end
				else
					if lineData.enchantID then
						slotData.enchantText = strmatch(lineData.leftText, enchantString)
					elseif lineData.gemIcon then
						num = num + 1
						slotData.gems[num] = lineData.gemIcon
					elseif lineData.socketType then
						num = num + 1
						slotData.gems[num] = format("Interface\\ItemSocketingFrame\\UI-EmptySocket-%s", lineData.socketType)
					end
				end
			end

			return slotData
		else
			if iLvlDB[link] then
				return iLvlDB[link]
			end

			local data
			if arg1 and type(arg1) == "string" then
				data = C_TooltipInfo.GetInventoryItem(arg1, arg2)
			elseif arg1 and type(arg1) == "number" then
				data = C_TooltipInfo.GetBagItem(arg1, arg2)
			else
				data = C_TooltipInfo.GetHyperlink(link, nil, nil, true)
			end
			if not data then
				return
			end

			for i = 2, 5 do
				local lineData = data.lines[i]
				if not lineData then
					break
				end
				local text = lineData.leftText
				local found = text and strfind(text, itemLevelString)
				if found then
					local level = strmatch(text, "(%d+)%)?$")
					iLvlDB[link] = tonumber(level)
					break
				end
			end
			return iLvlDB[link]
		end
	end

	function K.IsUnknownTransmog(bagID, slotID)
		local data = C_TooltipInfo.GetBagItem(bagID, slotID)
		local lineData = data and data.lines
		if not lineData then
			return
		end

		for i = #lineData, 1, -1 do
			local line = lineData[i]
			if line.price then
				return false
			end
			return line.leftText and isUnknownString[line.leftText]
		end
	end
end

-- Role Updater and Chat Channel Check Functions
do
	local function CheckRole()
		local tree = GetSpecialization()

		if not tree then
			K.Role = nil
			return
		end

		local _, _, _, _, role, stat = GetSpecializationInfo(tree)
		if role == "TANK" then
			K.Role = "Tank"
		elseif role == "HEALER" then
			K.Role = "Healer"
		elseif role == "DAMAGER" then
			-- Check if the player is a caster class
			if stat == 4 then -- 1 Strength, 2 Agility, 4 Intellect
				K.Role = "Caster"
			else
				K.Role = "Melee"
			end
		end
	end
	K:RegisterEvent("PLAYER_LOGIN", CheckRole)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", CheckRole)
	K:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", CheckRole)

	-- Role Icons
	local GroupRoleTex = {
		TANK = "roleicon-tiny-tank",
		HEALER = "roleicon-tiny-healer",
		DAMAGER = "roleicon-tiny-dps",
		DPS = "roleicon-tiny-dps",
	}

	function K.ReskinSmallRole(self, role)
		self:SetTexCoord(0, 1, 0, 1)
		self:SetAtlas(GroupRoleTex[role])
	end

	function K.CheckChat()
		return IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"
	end
end

-- Tooltip Functions
do
	function K.GetAnchors(frame)
		local x, y = frame:GetCenter()

		if not x or not y then
			return "CENTER"
		end

		local hhalf = (x > UIParent:GetWidth() * 2 / 3) and "RIGHT" or (x < UIParent:GetWidth() / 3) and "LEFT" or ""
		local vhalf = (y > UIParent:GetHeight() / 2) and "TOP" or "BOTTOM"

		return vhalf .. hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP") .. hhalf
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

		-- Set the GameTooltip's owner and relative position to the 'self' object.
		GameTooltip:SetOwner(self, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(self))
		GameTooltip:ClearLines()

		-- Check for various conditions to display the proper content
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
				r, g, b = 1, 0.8, 0
			elseif self.color == "info" then
				r, g, b = 0.5, 0.7, 1
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
end

-- Overlay Glow Functions
do
	function K.CreateGlowFrame(self, size)
		local glowFrame = CreateFrame("Frame", nil, self)
		glowFrame:SetPoint("CENTER")
		glowFrame:SetSize(size + 8, size + 8)

		return glowFrame
	end
end

-- Movable Frame and String Shortening Functions
do
	function K.CreateMoverFrame(self, parent, saved)
		local frame = parent or self
		if not (frame and type(frame) == "table" and frame.SetMovable) then
			return -- Exit if `frame` is invalid
		end

		frame:SetMovable(true)
		frame:SetUserPlaced(true)
		frame:SetClampedToScreen(true)

		if not (self and type(self) == "table" and self.EnableMouse) then
			return -- Exit if `self` is invalid
		end

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
			if KkthnxUIDB.Variables and KkthnxUIDB.Variables[K.Realm] and KkthnxUIDB.Variables[K.Realm][K.Name] then
				KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"] = KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"] or {}
				KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][frame:GetName()] = { orig, "UIParent", tar, x, y }
			end
		end)
	end

	function K.RestoreMoverFrame(self)
		if not (self and type(self) == "table" and self.GetName) then
			return -- Exit if `self` is invalid
		end

		local name = self:GetName()
		if name and KkthnxUIDB.Variables and KkthnxUIDB.Variables[K.Realm] and KkthnxUIDB.Variables[K.Realm][K.Name] then
			local anchorData = KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"] and KkthnxUIDB.Variables[K.Realm][K.Name]["TempAnchor"][name]
			if anchorData then
				self:ClearAllPoints()
				self:SetPoint(unpack(anchorData))
			end
		end
	end

	function K.ShortenString(string, numChars, dots)
		local bytes = string:len()
		if bytes <= numChars then
			return string
		else
			local len, pos = 0, 1
			while pos <= bytes do
				len = len + 1
				local c = string:byte(pos)
				if c > 0 and c <= 127 then
					pos = pos + 1
				elseif c >= 192 and c <= 223 then
					pos = pos + 2
				elseif c >= 224 and c <= 239 then
					pos = pos + 3
				elseif c >= 240 and c <= 247 then
					pos = pos + 4
				end

				if len == numChars then
					break
				end
			end

			if len == numChars and pos <= bytes then
				return string:sub(1, pos - 1) .. (dots and "..." or "")
			else
				return string
			end
		end
	end
end

-- Interface Option Functions
do
	function K.HideInterfaceOption(self)
		if not self then
			return
		end

		self:SetAlpha(0)
		self:SetScale(0.0001)
	end
end

-- Time Formatting Functions
do
	-- Variables to store time-related values in seconds
	local day, hour, minute, pointFive = 86400, 3600, 60, 0.5
	function K.FormatTime(s)
		if s >= day then
			return string_format("%d" .. K.MyClassColor .. "d", s / day + pointFive), s % day
		elseif s >= hour then
			return string_format("%d" .. K.MyClassColor .. "h", s / hour + pointFive), s % hour
		elseif s >= minute then
			return string_format("%d" .. K.MyClassColor .. "m", s / minute + pointFive), s % minute
		elseif s > 10 then
			return string_format("|cffcccc33%d|r", s + 0.5), s - math_floor(s)
		elseif s > 3 then
			return string_format("|cffffff00%d|r", s + 0.5), s - math_floor(s)
		else
			return string_format("|cffff0000%.1f|r", s), s - string_format("%.1f", s)
		end
	end

	function K.FormatTimeRaw(s)
		if s >= day then
			return string_format("%dd", s / day + pointFive)
		elseif s >= hour then
			return string_format("%dh", s / hour + pointFive)
		elseif s >= minute then
			return string_format("%dm", s / minute + pointFive)
		else
			return string_format("%d", s + pointFive)
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
end

-- Map Position and Money Formatting Functions
do
	local mapRects = {}
	local tempVec2D = CreateVector2D(0, 0)
	function K.GetPlayerMapPos(mapID)
		if not mapID then
			return
		end

		tempVec2D.x, tempVec2D.y = UnitPosition("player")
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

			mapRect = { pos1, pos2 }
			mapRect[2]:Subtract(mapRect[1])
			mapRects[mapID] = mapRect
		end

		tempVec2D:Subtract(mapRect[1])
		return tempVec2D.y / mapRect[2].y, tempVec2D.x / mapRect[2].x
	end

	function K.FormatMoney(amount)
		if type(amount) ~= "number" then
			return "Invalid amount" -- Handle non-numeric input gracefully
		end

		local coppername = "|cffeda55fc|r"
		local goldname = "|cffffd700g|r"
		local silvername = "|cffc7c7cfs|r"

		local value = math_abs(amount)
		local gold = math_floor(value / 10000)
		local silver = math_floor(mod(value / 100, 100))
		local copper = math_floor(mod(value, 100))

		if gold > 0 then
			-- stylua: ignore
			return string_format("%s%s %02d%s %02d%s", BreakUpLargeNumbers(gold), goldname, silver, silvername, copper, coppername)
		elseif silver > 0 then
			return string_format("%d%s %02d%s", silver, silvername, copper, coppername)
		else
			return string_format("%d%s", copper, coppername)
		end
	end
end
