--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Central utility library for various core functions and helpers.
-- - Design: Lightweight, high-performance, and cached for frequent access.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- ---------------------------------------------------------------------------
-- Locals & Global Caching
-- ---------------------------------------------------------------------------

-- PERF: Cache Lua globals for speed and consistency.
local select = select
local unpack = unpack
local type = type
local tonumber = tonumber
local pairs = pairs
local ipairs = ipairs
local next = next

-- Table functions
local table_insert = table.insert
local table_wipe = table.wipe
local strsplit = strsplit

-- Math functions
local math_floor = math.floor
local math_abs = math.abs

-- String functions
local string_format = string.format
local string_match = string.match
local string_find = string.find
local string_gsub = string.gsub
local string_lower = string.lower

-- WoW API caching (common APIs used in utilities)
local UnitClass = UnitClass
local UnitIsPlayer = UnitIsPlayer
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos

-- Additional WoW API caching
local ENCHANTED_TOOLTIP_LINE = ENCHANTED_TOOLTIP_LINE
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local ITEM_LEVEL = ITEM_LEVEL
local UIParent = UIParent
local UnitIsTapDenied = UnitIsTapDenied
local UnitReaction = UnitReaction

-- ---------------------------------------------------------------------------
-- Core Utility API
-- ---------------------------------------------------------------------------

do
	function K.Print(...)
		print("|cff3c9bedKkthnxUI:|r", ...)
	end

	-- PERF: Optimized ShortValue with zero GC churn by using math for rounding instead of string.format
	-- where possible. Cached format strings avoid repeated allocations in hot paths like damage meters.
	local format1 = "%.1f"
	-- local format2 = "%.2f" -- No used atm

	function K.ShortValue(n)
		if not n or type(n) ~= "number" then
			return ""
		end

		local abs_n = math_abs(n)

		-- NOTE: Avoid formatting small numbers to save CPU cycles and memory allocations.
		if abs_n < 1e3 then
			return n
		end

		local prefixStyle = C["General"].NumberPrefixStyle
		local suffix, div = "", 1

		-- REASON: Calculate suffix and divisor for SI-style or localized numbering.
		if abs_n >= 1e12 then
			suffix, div = (prefixStyle == 1 and "t" or "z"), 1e12
		elseif abs_n >= 1e9 then
			suffix, div = (prefixStyle == 1 and "b" or "y"), 1e9
		elseif abs_n >= 1e6 then
			suffix, div = (prefixStyle == 1 and "m" or "w"), 1e6
		elseif abs_n >= 1e3 then
			suffix, div = (prefixStyle == 1 and "k" or "w"), 1e3
		end

		-- PERF: Final formatting using math for rounding to avoid GC pressure.
		local val = n / div
		if val < 10 then
			-- Round to 1 decimal place using cached format string
			local rounded = math_floor(val * 10 + 0.5) / 10
			return string_format(format1, rounded) .. suffix
		else
			return math_floor(val + 0.5) .. suffix
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

		return math_floor(number * mult + 0.5) / mult
	end
end

-- ---------------------------------------------------------------------------
-- Path-based Table Access
-- ---------------------------------------------------------------------------

do
	local keysTable = {}
	-- REASON: Allows setting nested values via string paths (e.g., "General.FontSize").
	function K.SetValueByPath(tbl, path, value)
		table_wipe(keysTable)
		local n = select("#", strsplit(".", path))
		for i = 1, n do
			keysTable[i] = select(i, strsplit(".", path))
		end

		local current = tbl
		for i = 1, #keysTable - 1 do
			if not current[keysTable[i]] or type(current[keysTable[i]]) ~= "table" then
				current[keysTable[i]] = {}
			end
			current = current[keysTable[i]]
		end
		current[keysTable[#keysTable]] = value
	end

	function K.GetValueByPath(tbl, path)
		if not path then
			return nil
		end
		table_wipe(keysTable)
		local n = select("#", strsplit(".", path))
		for i = 1, n do
			keysTable[i] = select(i, strsplit(".", path))
		end

		local current = tbl
		for i = 1, #keysTable do
			if not current or type(current) ~= "table" or not current[keysTable[i]] then
				return nil
			end
			current = current[keysTable[i]]
		end
		return current
	end
end

-- ---------------------------------------------------------------------------
-- Color & Atlas Helpers
-- ---------------------------------------------------------------------------

do
	local factor = 255
	local colorCache = {}

	-- REASON: Convert RGB values to hex string; caches results to minimize string allocations.
	function K.RGBToHex(r, g, b)
		if type(r) == "table" then
			r, g, b = r.r or r[1], r.g or r[2], r.b or r[3]
		end

		if not r then
			return
		end
		r = r or 1
		g = g or 1
		b = b or 1

		local key = math_floor(r * 1000000000 + g * 1000000 + b * 1000)

		if colorCache[key] then
			return colorCache[key]
		end
		local hex = string_format("|cff%02x%02x%02x", math_floor(r * factor + 0.5), math_floor(g * factor + 0.5), math_floor(b * factor + 0.5))
		colorCache[key] = hex
		return hex
	end

	-- COMPAT: Uses Blizzard's class-specific atlas textures for consistent UI iconography.
	function K.GetClassIcon(class, iconSize)
		local size = iconSize or 16
		if class then
			return string_format("|A:groupfinder-icon-class-%s:%d:%d|a ", string_lower(class), size, size)
		end
	end

	-- NOTE: Pre-formatted hex strings for class colors to avoid inline conversion.
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

	function K.GetClassColor(class)
		return ClassColors[class]
	end

	function K.GetClassIconAndColor(class, iconSize)
		local classIcon = K.GetClassIcon(class, iconSize)
		local classColor = K.GetClassColor(class)
		return classIcon .. classColor
	end

	-- REASON: Extracts texture coordinate data from an atlas info object for use in font strings (|T...|t).
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

-- ---------------------------------------------------------------------------
-- Table Manipulation
-- ---------------------------------------------------------------------------

do
	function K.CopyTable(source, target, seen)
		target = target or {}
		seen = seen or {}

		-- NOTE: Recursively copies tables while tracking seen objects to prevent infinite loops.
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
			table_wipe(list)
		end

		for word in gmatch(variable, "%S+") do
			local converted = tonumber(word) or word -- Convert to number if possible
			list[converted] = true
		end
	end
end

-- ---------------------------------------------------------------------------
-- UI Component Helpers
-- ---------------------------------------------------------------------------

do
	-- Gradient Frame
	local gradientFrom, gradientTo = CreateColor(0, 0, 0, 0.5), CreateColor(0.3, 0.3, 0.3, 0.3)
	function K.CreateGF(self, w, h, o, r, g, b, a1, a2)
		self:SetSize(w, h)
		self:SetFrameStrata("BACKGROUND")
		local gradientFrame = self:CreateTexture(nil, "BACKGROUND")
		gradientFrame:SetAllPoints()
		gradientFrame:SetTexture(C["Media"].Textures.White8x8Texture)
		gradientFrame:SetGradient("Vertical", gradientFrom, gradientTo)
	end

	function K.CreateFontString(self, size, text, textstyle, classcolor, anchor, x, y)
		if not self then
			return
		end

		local fs = self:CreateFontString(nil, "OVERLAY")

		-- REASON: Ensures the font string is valid and applies consistent outlining or shadows.
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

-- ---------------------------------------------------------------------------
-- Unit & Class Color Logic
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- Addon State & Delay Logic
-- ---------------------------------------------------------------------------

do
	function K.TogglePanel(frame)
		if frame:IsShown() then
			frame:Hide()
		else
			frame:Show()
		end
	end

	-- REASON: Resolves the numeric NPC ID from a GUID; handles varying GUID formats.
	function K.GetNPCID(guid)
		local id = tonumber(string_match((guid or ""), "%-(%d-)%-%x-$"))
		return id
	end

	function K.CheckAddOnState(addon)
		if type(addon) ~= "string" then
			return false
		end

		return K.AddOns[string_lower(addon)] or false
	end

	function K.GetAddOnVersion(addon)
		return K.AddOnVersion[string_lower(addon)] or nil
	end

	function K.GetAddOnEnableState(addon, character)
		return C_AddOns.GetAddOnEnableState(addon, character)
	end

	function K.IsAddOnEnabled(addon)
		return K.GetAddOnEnableState(addon, K.Name) == 2
	end

	local function CreateClosure(func, data)
		return function()
			func(unpack(data))
		end
	end

	-- NOTE: Delayed function execution with support for packed arguments via closures.
	function K.Delay(delay, func, ...)
		if type(delay) ~= "number" or type(func) ~= "function" then
			return false
		end

		local args = { ... } -- delay: Restrict to the lowest time that the API allows us
		C_Timer.After(delay < 0.01 and 0.01 or delay, (#args <= 0 and func) or CreateClosure(func, args))

		return true
	end

	local FADEFRAMES, FADEMANAGER = {}, CreateFrame("FRAME")
	-- REASON: Weak keys allow frames to be garbage collected even if they are in the fade queue.
	setmetatable(FADEFRAMES, { __mode = "k" })
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
						-- REASON: Fade complete; cleanup and trigger optional callbacks.
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
			FADEFRAMES[frame] = info
			FADEMANAGER:SetScript("OnUpdate", K.UIFrameFade_OnUpdate)
		else
			-- NOTE: Update reference in case it was changed by a plugin or external call.
			FADEFRAMES[frame] = info
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

-- ---------------------------------------------------------------------------
-- Item Level & NPC Resolution
-- ---------------------------------------------------------------------------

do
	local iLvlDB = {}
	local enchantString = string_gsub(ENCHANTED_TOOLTIP_LINE, "%%s", "(.+)")
	local itemLevelString = "^" .. string_gsub(ITEM_LEVEL, "%%d", "")
	local isUnknownString = {
		[TRANSMOGRIFY_TOOLTIP_APPEARANCE_UNKNOWN] = true,
		[TRANSMOGRIFY_TOOLTIP_ITEM_UNKNOWN_APPEARANCE_KNOWN] = true,
	}

	local slotData = { gems = {}, gemsColor = {} }
	-- PERF: Optimized item level scanner using C_TooltipInfo; supports full scans for gems/enchants.
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
					local found = text and string_find(text, itemLevelString)
					if found then
						local level = string_match(text, "(%d+)%)?$")
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
						slotData.enchantText = string_match(lineData.leftText, enchantString)
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
				local found = text and string_find(text, itemLevelString)
				if found then
					local level = string_match(text, "(%d+)%)?$")
					iLvlDB[link] = tonumber(level)
					break
				end
			end
			return iLvlDB[link]
		end
	end

	-- PERF: Clear item level cache on world transitions to maintain a slim memory footprint.
	local function ClearItemLevelCache()
		table_wipe(iLvlDB)
	end
	K:RegisterEvent("PLAYER_ENTERING_WORLD", ClearItemLevelCache)
	K:RegisterEvent("PLAYER_LEAVING_WORLD", ClearItemLevelCache)

	local pendingNPCs, nameCache, callbacks = {}, {}, {}
	local loadingStr = "..."
	local pendingFrame = CreateFrame("Frame")
	pendingFrame:Hide()
	pendingFrame:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > 1 then
			if next(pendingNPCs) then
				for npcID, count in pairs(pendingNPCs) do
					if count > 2 then
						nameCache[npcID] = UNKNOWN
						if callbacks[npcID] then
							callbacks[npcID](UNKNOWN)
						end
						pendingNPCs[npcID] = nil
					else
						-- REASON: Retry NPC resolution for entries that are still loading or nil.
						local name = K.GetNPCName(npcID, callbacks[npcID])
						if name and name ~= loadingStr then
							pendingNPCs[npcID] = nil
						else
							pendingNPCs[npcID] = pendingNPCs[npcID] + 1
						end
					end
				end
			else
				self:Hide()
			end

			self.elapsed = 0
		end
	end)

	function K.GetNPCName(npcID, callback)
		local name = nameCache[npcID]
		if not name then
			name = loadingStr
			local data = C_TooltipInfo.GetHyperlink(format("unit:Creature-0-0-0-0-%d", npcID))
			local lineData = data and data.lines
			if lineData then
				name = lineData[1] and lineData[1].leftText
			end
			if name == loadingStr then
				-- NOTE: NPC is not yet in cache; queue it for the throttled OnUpdate processor.
				if not pendingNPCs[npcID] then
					pendingNPCs[npcID] = 1
					pendingFrame:Show()
				end
			else
				nameCache[npcID] = name
			end
		end
		if callback then
			callback(name)
			callbacks[npcID] = callback
		end

		return name
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

-- ---------------------------------------------------------------------------
-- Role & Chat Channel Helpers
-- ---------------------------------------------------------------------------

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
	-- NOTE: Update player role on specialization or talent changes for UI adaptation.
	K:RegisterEvent("PLAYER_LOGIN", CheckRole)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", CheckRole)
	K:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", CheckRole)

	-- Role Icons
	local GroupRoleTex = {
		TANK = "groupfinder-icon-role-micro-tank",
		HEALER = "groupfinder-icon-role-micro-heal",
		DAMAGER = "groupfinder-icon-role-micro-dps",
		DPS = "groupfinder-icon-role-micro-dps",
	}

	function K.ReskinSmallRole(self, role)
		self:SetTexCoord(0, 1, 0, 1)
		self:SetAtlas(GroupRoleTex[role])
	end

	function K.CheckChat()
		-- REASON: Resolves the appropriate chat channel based on the current group type.
		return IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY"
	end
end

-- ---------------------------------------------------------------------------
-- Tooltip & Anchor Helpers
-- ---------------------------------------------------------------------------

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

-- ---------------------------------------------------------------------------
-- UI Features: Perks Theme Overlay
-- ---------------------------------------------------------------------------

do
	local OverlayManager = { overlays = {} }
	local managerFrame = CreateFrame("Frame")
	local overlayCount = 0 -- active overlays; enables lazy event registration

	local function getThemePrefix()
		local prefix
		if C_PerksActivities and C_PerksActivities.GetPerksUIThemePrefix then
			prefix = C_PerksActivities.GetPerksUIThemePrefix()
		end
		if not prefix or prefix == "" then
			if C_PerksActivities and C_PerksActivities.GetPerksActivitiesInfo then
				local info = C_PerksActivities.GetPerksActivitiesInfo()
				prefix = info and info.uiTextureKit or prefix
			end
		end
		-- REASON: Do not hardcode seasonal fallbacks; only use Blizzard's active theme.
		return prefix
	end

	local function atlasExists(name)
		return name and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name)
	end

	local function pickAtlas(variant, suffix)
		local prefix = getThemePrefix()
		local trySuffixes = {}
		if suffix and suffix ~= "" then
			table_insert(trySuffixes, suffix)
		end
		if variant == "tp" then
			-- Common Trading Post suffixes
			table_insert(trySuffixes, "topbig")
			table_insert(trySuffixes, "topsmall")
			table_insert(trySuffixes, "top")
		else
			-- Traveler's Log common pieces
			table_insert(trySuffixes, "top")
			table_insert(trySuffixes, "box")
		end
		for _, s in ipairs(trySuffixes) do
			local atlas = ("perks-theme-%s-%s-%s"):format(prefix, variant, s)
			if atlasExists(atlas) then
				return atlas
			end
		end
		-- cross-variant fallback using the same active prefix only
		if variant == "tp" then
			local altList = { "top", "box" }
			for _, s in ipairs(altList) do
				local alt = ("perks-theme-%s-tl-%s"):format(prefix, s)
				if atlasExists(alt) then
					return alt
				end
			end
		else
			local altList = { "topbig", "topsmall", "top" }
			for _, s in ipairs(altList) do
				local alt = ("perks-theme-%s-tp-%s"):format(prefix, s)
				if atlasExists(alt) then
					return alt
				end
			end
		end
		return nil
	end

	local function updateOverlay(entry)
		if not entry or not entry.tex or not entry.holder or not entry.parent then
			return
		end
		local opts = entry.opts or {}
		local variant = opts.variant or "tp" -- "tp" (trading post) or "tl" (traveler's log)
		local suffix = opts.suffix or (variant == "tp" and "topbig" or "top")
		local atlas = pickAtlas(variant, suffix)
		if atlas then
			entry.tex:SetAtlas(atlas, true)
			entry.holder:SetSize(entry.tex:GetWidth(), entry.tex:GetHeight())
			entry.tex:Show()
			entry.holder:Show()
		else
			entry.tex:Hide()
			entry.holder:Hide()
		end
	end

	local function register(entry)
		OverlayManager.overlays[entry] = true
		overlayCount = overlayCount + 1
		-- NOTE: Lazily register events only when the first overlay is attached to save resources.
		if overlayCount == 1 then
			managerFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
			managerFrame:RegisterEvent("CALENDAR_UPDATE_EVENT_LIST")
			managerFrame:RegisterEvent("PERKS_ACTIVITIES_UPDATED")
			managerFrame:RegisterEvent("CVAR_UPDATE")
			managerFrame:SetScript("OnEvent", function()
				K.RefreshPerksThemeOverlays()
			end)
		end
	end

	local function unregister(entry)
		if OverlayManager.overlays[entry] then
			OverlayManager.overlays[entry] = nil
			overlayCount = overlayCount - 1
			if overlayCount <= 0 then
				overlayCount = 0
				managerFrame:UnregisterEvent("PLAYER_ENTERING_WORLD")
				managerFrame:UnregisterEvent("CALENDAR_UPDATE_EVENT_LIST")
				managerFrame:UnregisterEvent("PERKS_ACTIVITIES_UPDATED")
				managerFrame:UnregisterEvent("CVAR_UPDATE")
				managerFrame:SetScript("OnEvent", nil)
			end
		end
	end

	function K.RefreshPerksThemeOverlays()
		for entry in pairs(OverlayManager.overlays) do
			updateOverlay(entry)
		end
	end

	-- events are registered lazily in register()/unregister()

	-- Public API: attach a themed overlay to any frame
	--- Creates a themed Trading Post/Traveler's Log overlay anchored to a frame.
	-- @param parent Frame: parent holder frame (required)
	-- @param opts table|nil: variant("tp"|"tl"), suffix, point, relPoint, x, y, strata, level, anchorTo
	-- @return table overlay handle with :Refresh() and :SetShown(bool)
	function K.CreatePerksThemeOverlay(parent, opts)
		if not parent then
			return
		end
		opts = opts or {}
		local holder = CreateFrame("Frame", nil, parent)
		holder:SetFrameStrata(opts.strata or "TOOLTIP")
		holder:SetFrameLevel(opts.level or (parent:GetFrameLevel() + 10))
		holder:Hide()

		local tex = holder:CreateTexture(nil, "ARTWORK", nil, 7)
		tex:SetDrawLayer("ARTWORK", 7)
		tex:Hide()
		tex:ClearAllPoints()

		-- REASON: Default anchor is above the frame; allows overrides for flexible UI placement.
		local point = opts.point or "TOP"
		local relPoint = opts.relPoint or "TOP"
		local x = opts.x or 0
		local y = opts.y or 0
		holder:ClearAllPoints()
		local anchorTarget = opts.anchorTo or parent
		holder:SetPoint(point, anchorTarget, relPoint, x, y)
		tex:SetPoint("TOP", holder, "TOP", 0, 0)

		local entry = { parent = parent, holder = holder, tex = tex, opts = opts }
		register(entry)
		updateOverlay(entry)

		-- convenience methods
		function entry:Refresh()
			updateOverlay(self)
		end
		function entry:SetShown(shown)
			if shown then
				self.holder:Show()
				self.tex:Show()
			else
				self.holder:Hide()
				self.tex:Hide()
			end
		end

		return entry
	end

	--- Destroys a previously created overlay and unregisters updates.
	-- @param entry table overlay handle returned by K.CreatePerksThemeOverlay
	function K.DestroyPerksThemeOverlay(entry)
		if not entry then
			return
		end
		unregister(entry)
		if entry.tex then
			entry.tex:Hide()
			entry.tex:SetTexture(nil)
		end
		if entry.holder then
			entry.holder:Hide()
			entry.holder:SetParent(nil)
		end
		entry.parent = nil
		entry.opts = nil
	end

	-- Sugar alias
	function K.AttachPerksTheme(frame, opts)
		return K.CreatePerksThemeOverlay(frame, opts)
	end
end

-- ---------------------------------------------------------------------------
-- Overlay Glow Functions
-- ---------------------------------------------------------------------------

do
	function K.CreateGlowFrame(self, size)
		local glowFrame = CreateFrame("Frame", nil, self)
		glowFrame:SetPoint("CENTER")
		glowFrame:SetSize(size + 8, size + 8)

		return glowFrame
	end
end

-- ---------------------------------------------------------------------------
-- Positional Helpers
-- ---------------------------------------------------------------------------

do
	-- REASON: Enables drag-and-drop functionality for any frame; supports persistent positioning.
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
end

-- NOTE: Shortens a string to a specific number of characters, handling multi-byte UTF-8 sequences.
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

-- ---------------------------------------------------------------------------
-- Interface Option Helpers
-- ---------------------------------------------------------------------------

do
	function K.HideInterfaceOption(self)
		if not self then
			return
		end

		self:SetAlpha(0)
		self:SetScale(0.0001)
	end
end

-- ---------------------------------------------------------------------------
-- Time & Money Formatting
-- ---------------------------------------------------------------------------

do
	-- Variables to store time-related values in seconds
	local day, hour, minute, pointFive = 86400, 3600, 60, 0.5
	-- REASON: Formats raw seconds into human-readable strings with class coloring and color thresholds.
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

-- ---------------------------------------------------------------------------
-- Interface Option Helpers
-- ---------------------------------------------------------------------------

do
	function K.HideInterfaceOption(self)
		if not self then
			return
		end

		self:SetAlpha(0)
		self:SetScale(0.0001)
	end
end

-- ---------------------------------------------------------------------------
-- Time & Money Formatting
-- ---------------------------------------------------------------------------

do
	-- Variables to store time-related values in seconds
	local day, hour, minute, pointFive = 86400, 3600, 60, 0.5
	-- REASON: Formats raw seconds into human-readable strings with class coloring and color thresholds.
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

-- ---------------------------------------------------------------------------
-- Map & Money Logic
-- ---------------------------------------------------------------------------

do
	local mapRects = {}
	local tempVec2D = CreateVector2D(0, 0)
	local vecZero = CreateVector2D(0, 0)
	local vecOne = CreateVector2D(1, 1)
	-- REASON: Translates world coordinates to map-specific relative coordinates (0.0 - 1.0).
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
			local pos1 = select(2, C_Map_GetWorldPosFromMapPos(mapID, vecZero))
			local pos2 = select(2, C_Map_GetWorldPosFromMapPos(mapID, vecOne))
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

-- ---------------------------------------------------------------------------
-- Unified Widget Factory
-- ---------------------------------------------------------------------------

-- NOTE: Centralized UI toolkit for consistent styling across all GUI modules.
-- This eliminates code duplication and ensures theme consistency.

K.WidgetFactory = {}

-- REASON: Creates a colored background texture with default or custom alpha.
function K.WidgetFactory.CreateBackdrop(parent, r, g, b, a)
	local bg = parent:CreateTexture(nil, "BACKGROUND")
	bg:SetAllPoints()
	bg:SetTexture(C["Media"].Textures.White8x8Texture)
	bg:SetVertexColor(r or 0.05, g or 0.05, b or 0.05, a or 0.9)
	return bg
end

-- REASON: Creates a styled button with hover effects and consistent theme-aware coloring.
function K.WidgetFactory.CreateButton(parent, text, width, height, onClick)
	local button = CreateFrame("Button", nil, parent)
	button:SetSize(width or 120, height or 28)

	-- Default colors (Silver/Blue theme)
	local ACCENT_COLOR = { K.r, K.g, K.b }
	local TEXT_COLOR = { 0.9, 0.9, 0.9, 1 }

	-- Clean button background
	local buttonBg = button:CreateTexture(nil, "BACKGROUND")
	buttonBg:SetAllPoints()
	buttonBg:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBg:SetVertexColor(0.15, 0.15, 0.15, 1)
	button.KKUI_Background = buttonBg

	-- Subtle border for depth
	local buttonBorder = button:CreateTexture(nil, "BORDER")
	buttonBorder:SetPoint("TOPLEFT", -1, 1)
	buttonBorder:SetPoint("BOTTOMRIGHT", 1, -1)
	buttonBorder:SetTexture(C["Media"].Textures.White8x8Texture)
	buttonBorder:SetVertexColor(0.3, 0.3, 0.3, 0.8)
	button.KKUI_Border = buttonBorder

	-- Hover effects for clean design
	button:SetScript("OnEnter", function(self)
		self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		self.KKUI_Border:SetVertexColor(ACCENT_COLOR[1], ACCENT_COLOR[2], ACCENT_COLOR[3], 1)
		if self.Text then
			self.Text:SetTextColor(1, 1, 1, 1)
		end
	end)

	button:SetScript("OnLeave", function(self)
		self.KKUI_Background:SetVertexColor(0.15, 0.15, 0.15, 1)
		self.KKUI_Border:SetVertexColor(0.3, 0.3, 0.3, 0.8)
		if self.Text then
			self.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
		end
	end)

	-- Click effect
	button:SetScript("OnMouseDown", function(self)
		self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.6, ACCENT_COLOR[2] * 0.6, ACCENT_COLOR[3] * 0.6, 1)
	end)

	button:SetScript("OnMouseUp", function(self)
		if self:IsMouseOver() then
			self.KKUI_Background:SetVertexColor(ACCENT_COLOR[1] * 0.8, ACCENT_COLOR[2] * 0.8, ACCENT_COLOR[3] * 0.8, 1)
		else
			self.KKUI_Background:SetVertexColor(0.15, 0.15, 0.15, 1)
		end
	end)

	-- Button text
	button.Text = button:CreateFontString(nil, "OVERLAY")
	button.Text:SetFontObject(K.UIFont)
	button.Text:SetTextColor(TEXT_COLOR[1], TEXT_COLOR[2], TEXT_COLOR[3], TEXT_COLOR[4])
	button.Text:SetText(text)
	button.Text:SetPoint("CENTER")

	if onClick then
		button:SetScript("OnClick", onClick)
	end

	return button
end
