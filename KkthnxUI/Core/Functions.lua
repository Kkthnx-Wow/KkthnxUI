--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Central utility library for various core functions and helpers.
-- - Design: Lightweight, high-performance, and cached for frequent access.
-- - Events: PLAYER_ENTERING_WORLD, PLAYER_LEAVING_WORLD, PLAYER_LOGIN, PLAYER_TALENT_UPDATE, PLAYER_SPECIALIZATION_CHANGED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- ---------------------------------------------------------------------------
-- LOCALS & GLOBAL CACHING
-- ---------------------------------------------------------------------------

-- PERF: Cache Lua globals for speed and consistency.
local ipairs, next, pairs, select, type, unpack = ipairs, next, pairs, select, type, unpack
local tonumber = tonumber

local table_insert = table.insert
local table_wipe = table.wipe

local math_abs = math.abs
local math_floor = math.floor
local math_modf = math.modf

-- SECRET (Midnight 12.0): cache the global probes as upvalues; K.IsSecret/etc are
-- hot-path guards called per-aura/per-frame. Both may be nil on pre-12.0 clients.
local issecretvalue = rawget(_G, "issecretvalue")
local issecrettable = rawget(_G, "issecrettable")

local string_find = string.find
local string_format = string.format
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_lower = string.lower
local string_match = string.match

local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos
local C_Timer_After = C_Timer.After
local C_TooltipInfo_GetBagItem = C_TooltipInfo.GetBagItem
local C_TooltipInfo_GetHyperlink = C_TooltipInfo.GetHyperlink
local C_TooltipInfo_GetInventoryItem = C_TooltipInfo.GetInventoryItem

local ENCHANTED_TOOLTIP_LINE = ENCHANTED_TOOLTIP_LINE
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local ITEM_LEVEL = ITEM_LEVEL
local UIParent = UIParent
local UnitClass = UnitClass
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitReaction = UnitReaction

-- ---------------------------------------------------------------------------
-- SECRET VALUE API (Midnight 12.0)
-- ---------------------------------------------------------------------------

-- REASON: Midnight returns "secret" values from combat/instance APIs that cannot
-- be compared, used in arithmetic, or used as table keys without erroring.
-- issecretvalue()/issecrettable() are themselves always safe to call (even on a
-- secret). Centralize the guards here (mirroring oUF/NDui) so every module shares
-- one API instead of redefining a local IsSecret helper in each file. Each module
-- should alias these at file scope, e.g. `local IsSecret = K.IsSecret`.
do
	-- Returns true only when the value is a secret value.
	function K.IsSecret(value)
		return issecretvalue ~= nil and issecretvalue(value)
	end

	-- Convenience inverse: true when the value is safe to read/compare/index.
	function K.NotSecret(value)
		return issecretvalue == nil or not issecretvalue(value)
	end

	-- Returns true only when the object is a secret table (cannot be indexed).
	function K.IsSecretTable(object)
		return issecrettable ~= nil and issecrettable(object)
	end

	-- Convenience inverse: true when the table is safe to index/iterate.
	function K.NotSecretTable(object)
		return issecrettable == nil or not issecrettable(object)
	end

	local ShouldUnitIdentityBeSecret = C_Secrets and C_Secrets.ShouldUnitIdentityBeSecret

	-- True when a unit token's identity is hidden (instances / restricted).
	function K.IsSecretUnit(unit)
		if not (unit and ShouldUnitIdentityBeSecret) then
			return false
		end
		local ok, value = pcall(ShouldUnitIdentityBeSecret, unit)
		return ok and value
	end

	function K.NotSecretUnit(unit)
		return not K.IsSecretUnit(unit)
	end

	-- Safe UnitIsUnit: token comparison (ShouldUnitComparisonBeSecret) returns a
	-- secret boolean in instances, so testing the raw result errors. This mirrors
	-- oUF's Private.unitIsUnit shim. Fail closed: a secret result becomes false so
	-- callers (target glows, mouseover checks) simply don't trigger rather than
	-- crash. Returns a plain boolean that is always safe to test.
	local UnitIsUnit = UnitIsUnit
	function K.UnitIsUnit(unitA, unitB)
		local result = UnitIsUnit(unitA, unitB)
		if issecretvalue ~= nil and issecretvalue(result) then
			return false
		end
		return result
	end

	--- Read a boolean when safe; returns true/false, or nil when secret.
	function K.BooleanIsTrue(value)
		if K.NotSecret(value) then
			return value and true or false
		end
		return nil
	end

	local dispelColorCurve

	--- Midnight dispel ColorCurve for C_UnitAuras.GetAuraDispelTypeColor (shared by Auras + oUF hooks).
	function K.GetDispelColorCurve(oUFRef)
		if dispelColorCurve ~= nil then
			return dispelColorCurve or nil
		end

		local CurveUtil = C_CurveUtil
		local oUF = oUFRef or K.oUF
		if not (CurveUtil and CurveUtil.CreateColorCurve and oUF and oUF.Enum and oUF.colors) then
			dispelColorCurve = false
			return nil
		end

		local curve = CurveUtil.CreateColorCurve()
		if Enum and Enum.LuaCurveType then
			curve:SetType(Enum.LuaCurveType.Step)
		end

		for _, dispelIndex in next, oUF.Enum.DispelType do
			local color = oUF.colors.dispel[dispelIndex]
			if color then
				curve:AddPoint(dispelIndex, color)
			end
		end

		dispelColorCurve = curve
		return curve
	end

	--- Resolve debuff border RGB via aura instance + dispel curve (no secret dispelName read).
	function K.GetAuraDispelBorderRGB(unit, auraInstanceID, oUFRef)
		local curve = K.GetDispelColorCurve(oUFRef)
		if not (curve and auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor) then
			return nil
		end

		local ok, color = pcall(C_UnitAuras.GetAuraDispelTypeColor, unit, auraInstanceID, curve)
		if not ok or not color then
			return nil
		end

		if color.GetRGB then
			return color:GetRGB()
		end

		if color.r and color.g and color.b then
			return color.r, color.g, color.b
		end

		return nil
	end

	--- NexEnhance alias: true when a value is safe to read/compare/index.
	function K.CanAccessValue(value)
		return K.NotSecret(value)
	end

	--- Hide cooldown swipe when a DurationObject reports zero (permanent aura).
	function K.MaskCooldownSwipeFromDurationObject(cooldown, durObj)
		if not (cooldown and durObj and durObj.IsZero and cooldown.SetAlphaFromBoolean) then
			return
		end
		cooldown:SetAlphaFromBoolean(durObj:IsZero(), 0, 1)
	end

	local DISPEL_INDEX_TO_NAME = {
		[1] = "Magic",
		[2] = "Curse",
		[3] = "Disease",
		[4] = "Poison",
	}

	local function colorDistance(r, g, b, cr, cg, cb)
		local dr, dg, db = r - cr, g - cg, b - cb
		return dr * dr + dg * dg + db * db
	end

	--- Resolve dispel type name from aura instance when dispelName is secret.
	function K.GetAuraDispelTypeName(unit, auraInstanceID, oUFRef)
		local oUF = oUFRef or K.oUF
		local curve = K.GetDispelColorCurve(oUF)
		if not (curve and auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraDispelTypeColor and oUF and oUF.colors) then
			return nil
		end

		local ok, color = pcall(C_UnitAuras.GetAuraDispelTypeColor, unit, auraInstanceID, curve)
		if not ok or not color then
			return nil
		end

		local cr, cg, cb
		if color.GetRGB then
			cr, cg, cb = color:GetRGB()
		elseif color.r then
			cr, cg, cb = color.r, color.g, color.b
		end

		if not (cr and K.NotSecret(cr) and K.NotSecret(cg) and K.NotSecret(cb)) then
			return nil
		end

		local bestName, bestDist
		for index, name in pairs(DISPEL_INDEX_TO_NAME) do
			local ref = oUF.colors.dispel[index]
			if ref then
				local rr, rg, rb
				if ref.GetRGB then
					rr, rg, rb = ref:GetRGB()
				elseif ref.r then
					rr, rg, rb = ref.r, ref.g, ref.b
				elseif ref[1] then
					rr, rg, rb = ref[1], ref[2], ref[3]
				end
				if rr and K.NotSecret(rr) then
					local d = colorDistance(cr, cg, cb, rr, rg, rb)
					if not bestDist or d < bestDist then
						bestDist = d
						bestName = name
					end
				end
			end
		end

		return bestName
	end
end
do
	local UnitIsPlayer = UnitIsPlayer
	local UnitReaction = UnitReaction
	local UnitSelectionType = UnitSelectionType
	local UnitSelectionColor = UnitSelectionColor
	local UnitIsFriend = UnitIsFriend
	local UnitPlayerControlled = UnitPlayerControlled
	local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
	local UnitIsOtherPlayersPet = UnitIsOtherPlayersPet
	local CompactUnitFrame_IsOnThreatListWithPlayer = CompactUnitFrame_IsOnThreatListWithPlayer
	local FACTION_BAR_COLORS = FACTION_BAR_COLORS

	local SELECTION_TYPE_TO_FACTION = {
		[0] = 2,
		[1] = 3,
		[2] = 4,
		[3] = 5,
	}

	local SELECTION_RGB_REFS = {
		{ 2, 1.0, 0.0, 0.0 },
		{ 3, 1.0, 0.5, 0.0 },
		{ 4, 1.0, 1.0, 0.0 },
		{ 5, 0.0, 1.0, 0.0 },
	}

	local function colorDistance(r, g, b, cr, cg, cb)
		local dr, dg, db = r - cr, g - cg, b - cb
		return dr * dr + dg * dg + db * db
	end

	local function factionIndexFromSelectionRGB(sr, sg, sb)
		local bestIdx, bestDist
		for i = 1, #SELECTION_RGB_REFS do
			local ref = SELECTION_RGB_REFS[i]
			local d = colorDistance(sr, sg, sb, ref[2], ref[3], ref[4])
			if not bestDist or d < bestDist then
				bestDist = d
				bestIdx = ref[1]
			end
		end
		return bestIdx
	end

	local function resolveFactionTint(factionIdx)
		local color = FACTION_BAR_COLORS and FACTION_BAR_COLORS[factionIdx]
		if not color then
			return nil
		end

		if factionIdx == 3 then
			local mix = 0.7
			return color.r + (1.0 - color.r) * mix, color.g + (0.52 - color.g) * mix, color.b + (0.0 - color.b) * mix
		end

		return color.r, color.g, color.b
	end

	function K.IsFriendlyControlledUnit(unit)
		if not unit or K.IsSecret(unit) or K.IsSecretUnit(unit) then
			return false
		end

		if K.UnitIsUnit(unit, "pet") then
			return true
		end

		if UnitIsOtherPlayersPet then
			local otherPet = UnitIsOtherPlayersPet(unit)
			if K.NotSecret(otherPet) and otherPet then
				return true
			end
		end

		if not UnitPlayerControlled then
			return false
		end

		local controlled = UnitPlayerControlled(unit)
		if K.IsSecret(controlled) or not controlled then
			return false
		end

		if UnitIsOwnerOrControllerOfUnit then
			local owned = UnitIsOwnerOrControllerOfUnit("player", unit)
			if K.NotSecret(owned) and owned then
				return true
			end
		end

		if UnitIsFriend then
			local friend = UnitIsFriend("player", unit)
			if K.NotSecret(friend) and friend then
				return true
			end
		end

		return false
	end

	--- NPC reaction tint using UnitSelectionType/Color with UnitReaction fallback.
	function K.GetNpcReactionColor(unit)
		if not unit or not FACTION_BAR_COLORS or K.IsSecret(unit) or K.IsSecretUnit(unit) then
			return nil
		end

		if K.IsFriendlyControlledUnit(unit) then
			return resolveFactionTint(5)
		end

		local factionIdx

		if UnitSelectionType then
			local selType = UnitSelectionType(unit, false)
			if K.NotSecret(selType) and selType ~= nil then
				factionIdx = SELECTION_TYPE_TO_FACTION[selType]
			end
		end

		if not factionIdx and UnitSelectionColor then
			local sr, sg, sb = UnitSelectionColor(unit, false)
			if K.NotSecret(sr) and K.NotSecret(sg) and K.NotSecret(sb) then
				factionIdx = factionIndexFromSelectionRGB(sr, sg, sb)
			end
		end

		if not factionIdx then
			local reaction = UnitReaction(unit, "player")
			if K.IsSecret(reaction) or not reaction then
				return nil
			end
			factionIdx = reaction
		end

		if CompactUnitFrame_IsOnThreatListWithPlayer and UnitIsFriend then
			local onThreat = CompactUnitFrame_IsOnThreatListWithPlayer(unit)
			if K.NotSecret(onThreat) and onThreat then
				local isFriend = UnitIsFriend("player", unit)
				if K.NotSecret(isFriend) and not isFriend then
					factionIdx = 2
				end
			end
		end

		return resolveFactionTint(factionIdx)
	end
end

-- ---------------------------------------------------------------------------
-- CORE UTILITY API
-- ---------------------------------------------------------------------------

do
	function K.Print(...)
		print("|cff3c9bedKkthnxUI:|r", ...)
	end

	-- PERF: Optimized ShortValue with zero GC churn by using math for rounding instead of string.format
	-- where possible. Cached format strings avoid repeated allocations in hot paths like damage meters.
	local format1 = "%.1f"

	function K.ShortValue(n)
		if not n or type(n) ~= "number" or K.IsSecret(n) then
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
-- PATH-BASED TABLE ACCESS
-- ---------------------------------------------------------------------------

do
	-- PERF: Shared scratch table for path key splitting; avoids allocating a new table on every call.
	-- NOTE: Safe for single-threaded use; Lua cannot interleave calls between SetValueByPath/GetValueByPath.
	local keysTable = {}
	local keysTableN = 0

	-- REASON: Allows setting nested values via dot-delimited string paths (e.g., "General.FontSize").
	-- PERF: Uses string_gmatch iteration into the reused keysTable instead of { strsplit(...) } per call.
	function K.SetValueByPath(tbl, path, value)
		if not path or not tbl then
			return
		end

		-- REASON: Clear only the live portion of the buffer; avoids table_wipe overhead on a large table.
		for i = 1, keysTableN do
			keysTable[i] = nil
		end
		keysTableN = 0

		for key in string_gmatch(path, "[^%.]+") do
			keysTableN = keysTableN + 1
			keysTable[keysTableN] = key
		end

		local current = tbl
		for i = 1, keysTableN - 1 do
			local key = keysTable[i]
			if not current[key] or type(current[key]) ~= "table" then
				current[key] = {}
			end
			current = current[key]
		end
		if keysTableN > 0 then
			current[keysTable[keysTableN]] = value
		end
	end

	function K.GetValueByPath(tbl, path)
		if not path or not tbl then
			return nil
		end

		-- PERF: Reuse the same buffer; clear only the live entries.
		for i = 1, keysTableN do
			keysTable[i] = nil
		end
		keysTableN = 0

		for key in string_gmatch(path, "[^%.]+") do
			keysTableN = keysTableN + 1
			keysTable[keysTableN] = key
		end

		local current = tbl
		for i = 1, keysTableN do
			local key = keysTable[i]
			if not current or type(current) ~= "table" or not current[key] then
				return nil
			end
			current = current[key]
		end
		return current
	end
end

-- ---------------------------------------------------------------------------
-- COLOR & ATLAS HELPERS
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

	-- MIDNIGHT (12.0): oUF moved to C_CurveUtil color curves and dropped the classic
	-- arithmetic gradient helpers (oUF:ColorGradient / oUF:RGBColorGradient). KkthnxUI
	-- still relies on them for non-secret scalars (durability, memory, rep, zoom, health%),
	-- so restore them on K.oUF here. Definitions are guarded so a future oUF that brings
	-- the methods back will win, and we never edit the vendored library.
	-- SECRET: callers may pass a value that becomes secret in combat/instances (e.g. a
	-- health percentage); guard before any arithmetic and fall back to white.
	local function ComputeGradient(a, b, ...)
		if K.IsSecret(a) or K.IsSecret(b) then
			return 1, 1, 1
		end

		local percent = a / b
		if percent <= 0 then
			local r, g, bl = ...
			return r, g, bl
		elseif percent >= 1 then
			return select(select("#", ...) - 2, ...)
		end

		local num = select("#", ...) / 3
		local segment, relperc = math_modf(percent * (num - 1))
		local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)
		return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
	end

	if K.oUF and not K.oUF.RGBColorGradient then
		function K.oUF:RGBColorGradient(...)
			return ComputeGradient(...)
		end
	end

	if K.oUF and not K.oUF.ColorGradient then
		function K.oUF:ColorGradient(...)
			return ComputeGradient(...)
		end
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
-- TABLE MANIPULATION
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

		for word in string_gmatch(variable, "[^,%s]+") do
			local converted = tonumber(word) or word
			list[converted] = true
		end
	end

	-- REASON: Lazily retrieve character-specific variables securely.
	-- Reduces repeated table lookups across multiple modules (Inventory, etc).
	local charVars
	function K.GetCharVars()
		if charVars then
			return charVars
		end

		local db = KkthnxUIDB and KkthnxUIDB.Variables
		if db and db[K.Realm] and db[K.Realm][K.Name] then
			charVars = db[K.Realm][K.Name]
		end
		return charVars
	end
end

-- ---------------------------------------------------------------------------
-- UI COMPONENT HELPERS
-- ---------------------------------------------------------------------------

do
	function K.CreateGF(self, w, h, o, r, g, b, a1, a2)
		self:SetSize(w, h)
		self:SetFrameStrata("BACKGROUND")
		local gradientFrame = self:CreateTexture(nil, "BACKGROUND")
		gradientFrame:SetAllPoints()
		gradientFrame:SetTexture(C["Media"].Textures.White8x8Texture)
		gradientFrame:SetGradient("Vertical", CreateColor(0, 0, 0, 0.5), CreateColor(0.3, 0.3, 0.3, 0.3))
	end

	function K.CreateFontString(self, size, text, textstyle, classcolor, anchor, x, y)
		if not self then
			return
		end

		local fs
		if not textstyle or textstyle == "" then
			fs = K.CreatePlainFS(self, size, text, "OVERLAY")
		else
			fs = self:CreateFontString(nil, "OVERLAY")
			if not fs then
				return
			end
			fs:SetFont(select(1, KkthnxUIFont:GetFont()), size, "OUTLINE")
			fs:SetShadowOffset(0, 0)
			fs:SetText(text)
		end

		if not fs then
			return
		end

		fs:SetWordWrap(false)

		if classcolor and type(classcolor) == "boolean" then
			fs:SetTextColor(K.r, K.g, K.b)
		elseif classcolor == "system" then
			fs:SetTextColor(1, 0.8, 0)
		else
			fs:SetTextColor(1, 1, 1)
		end

		-- NOTE: Check if target anchor point is defined.
		if anchor and x and y then
			fs:SetPoint(anchor, x, y)
		else
			fs:SetPoint("CENTER", 1, 0)
		end

		return fs
	end

	-- REASON: 12.0.7 slug-shadow workaround — duplicate string with manual offset shadow.
	function K.StripColorCodes(text)
		if not text then
			return ""
		end
		return string_gsub(string_gsub(text, "|c%x%x%x%x%x%x%x", ""), "|r", "")
	end

	function K.CreatePlainFS(parent, size, text, layer)
		local lyr = layer or "OVERLAY"
		local sz = size or 12
		local font = select(1, KkthnxUIFont:GetFont())

		local shadow = parent:CreateFontString(nil, lyr)
		shadow:SetFont(font, sz, "")
		shadow:SetTextColor(0, 0, 0, 0.85)

		local fs = parent:CreateFontString(nil, lyr)
		fs:SetFont(font, sz, "")
		fs.kkShadow = shadow
		shadow:SetPoint("CENTER", fs, "CENTER", 1, -1)

		if text then
			K.SetPlainText(fs, text)
		end
		return fs
	end

	function K.SetPlainText(fs, text)
		fs:SetText(text or "")
		local shadow = fs.kkShadow
		if shadow then
			shadow:SetText(K.StripColorCodes(text))
		end
	end

	function K.SetPlainFormattedText(fs, fmt, ...)
		K.SetPlainText(fs, string_format(fmt, ...))
	end
end

-- ---------------------------------------------------------------------------
-- UNIT & CLASS COLOR LOGIC
-- ---------------------------------------------------------------------------

do
	-- REASON: Safe accessor for class color table (returns white if class is invalid).
	function K.ColorClass(class)
		local color = K.ClassColors[class]
		if not color then
			return 1, 1, 1
		end
		return color.r, color.g, color.b
	end

	-- REASON: Centralized unit coloring logic (Class -> Tap Denied -> Reaction).
	-- SECRET (12.0): in instances a unit's identity is hidden, so UnitIsPlayer /
	-- UnitIsTapDenied / UnitReaction return secret booleans/values that can't be
	-- boolean-tested. Bail to white whenever any read is secret (mirrors NDui's
	-- safe fallback) so callers like the tooltip never crash on a secret identity.
	function K.UnitColor(unit)
		local r, g, b = 1, 1, 1

		if K.IsSecret(unit) then
			return r, g, b
		end

		local isPlayer = UnitIsPlayer(unit)
		if K.IsSecret(isPlayer) then
			return r, g, b
		end

		if not isPlayer then
			local isAI = UnitInPartyIsAI(unit)
			if K.IsSecret(isAI) then
				return r, g, b
			end
			isPlayer = isAI
		end

		if isPlayer then
			local class = select(2, UnitClass(unit))
			if class and K.NotSecret(class) then
				r, g, b = K.ColorClass(class)
			end
		else
			local tapped = UnitIsTapDenied(unit)
			if K.IsSecret(tapped) then
				return r, g, b
			end

			if tapped then
				r, g, b = 0.6, 0.6, 0.6
			else
				local reaction = UnitReaction(unit, "player")
				if reaction and K.NotSecret(reaction) then
					local color = K.Colors.reaction[reaction]
					r, g, b = color[1], color[2], color[3]
				end
			end
		end

		return r, g, b
	end
end

-- ---------------------------------------------------------------------------
-- ADDON STATE & DELAY LOGIC
-- ---------------------------------------------------------------------------

do
	-- NOTE: Simple helper to toggle frame visibility state.
	function K.TogglePanel(frame)
		if frame:IsShown() then
			frame:Hide()
		else
			frame:Show()
		end
	end

	-- REASON: Resolves the numeric NPC ID from a GUID; handles varying GUID formats.
	-- GUID format: Creature-0-ServerID-InstanceID-ZoneID-NPCID-SpawnUID
	-- Use greedy %d+ and %x+ for clarity and fewer backtrack attempts.
	-- SECRET (12.0): UnitGUID can return a secret string in instances; string_match
	-- on it throws, so bail before any Lua string ops (fail closed -> nil).
	function K.GetNPCID(guid)
		if not guid or K.IsSecret(guid) then
			return nil
		end

		local id = tonumber(string_match(guid, "%-(%d+)%-%x+$"))
		return id
	end

	-- PERF: Cached lookup for addon state to avoid repeated C_AddOns introspection.
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

	-- REASON: Binds arguments to a function for delayed execution (avoids global state reliance).
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

		local args = { ... }
		-- PERF: Clamp delay to minimum 10ms to satisfy C_Timer API requirements.
		C_Timer_After(delay < 0.01 and 0.01 or delay, (#args <= 0 and func) or CreateClosure(func, args))

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
				-- NOTE: Initialize or increment internal fade counter.
				if frame:IsVisible() then
					info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.delay)
				else
					info.fadeTimer = info.timeToFade + 1
				end

				-- REASON: Incrementally update alpha until target duration is reached, then finalize state.
				if info.fadeTimer < info.timeToFade then
					if info.mode == "IN" then
						frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
					else
						frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
					end
				else
					frame:SetAlpha(info.endAlpha)

					-- NOTE: Delay cleanup if a hold duration is specified.
					if info.fadeHoldTime and info.fadeHoldTime > 0 then
						info.fadeHoldTime = info.fadeHoldTime - elapsed
					else
						-- REASON: Fade complete; cleanup and trigger optional callbacks.
						K.UIFrameFadeRemoveFrame(frame)

						if info.finishedFunc then
							if info.finishedArgs then
								info.finishedFunc(unpack(info.finishedArgs))
							else
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
-- ITEM LEVEL & NPC RESOLUTION
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
			local data = C_TooltipInfo_GetInventoryItem(arg1, arg2)
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
						slotData.gems[num] = string_format("Interface\\ItemSocketingFrame\\UI-EmptySocket-%s", lineData.socketType)
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
				data = C_TooltipInfo_GetInventoryItem(arg1, arg2)
			elseif arg1 and type(arg1) == "number" then
				data = C_TooltipInfo_GetBagItem(arg1, arg2)
			else
				data = C_TooltipInfo_GetHyperlink(link, nil, nil, true)
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
			local data = C_TooltipInfo_GetHyperlink(string_format("unit:Creature-0-0-0-0-%d", npcID))
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
		-- FIX: ONLY fire callback if we've successfully resolved the name!
		if callback and name ~= loadingStr then
			callback(name)
			callbacks[npcID] = nil
		elseif callback then
			callbacks[npcID] = callback
		end

		return name
	end

	function K.IsUnknownTransmog(bagID, slotID)
		local data = C_TooltipInfo_GetBagItem(bagID, slotID)
		local lineData = data and data.lines
		if not lineData then
			return
		end

		for i = #lineData, 1, -1 do
			local line = lineData[i]
			if line.price then
				return false
			end
			if line.leftText and isUnknownString[line.leftText] then
				return true
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- ROLE & CHAT CHANNEL HELPERS
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
			if stat == 4 then -- NOTE: 1 Strength, 2 Agility, 4 Intellect.
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
-- TOOLTIP & ANCHOR HELPERS
-- ---------------------------------------------------------------------------

do
	-- REASON: Calculates smart tooltip anchoring to keep it strictly on-screen based on quadrant.
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

		-- NOTE: Set the GameTooltip's owner and relative position to the 'self' object.
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
-- UI FEATURES: PERKS THEME OVERLAY
-- ---------------------------------------------------------------------------

do
	local OverlayManager = { overlays = {} }
	local managerFrame = CreateFrame("Frame")
	local overlayCount = 0

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
			table_insert(trySuffixes, "topbig")
			table_insert(trySuffixes, "topsmall")
			table_insert(trySuffixes, "top")
		else
			table_insert(trySuffixes, "top")
			table_insert(trySuffixes, "box")
		end
		for _, s in ipairs(trySuffixes) do
			local atlas = ("perks-theme-%s-%s-%s"):format(prefix, variant, s)
			if atlasExists(atlas) then
				return atlas
			end
		end
		-- REASON: Cross-variant fallback using the same active prefix only.
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
		local variant = opts.variant or "tp"
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

	function K.AttachPerksTheme(frame, opts)
		return K.CreatePerksThemeOverlay(frame, opts)
	end
end

-- ---------------------------------------------------------------------------
-- OVERLAY GLOW FUNCTIONS
-- ---------------------------------------------------------------------------

do
	function K.CreateGlowFrame(self, size)
		local glowFrame = CreateFrame("Frame", nil, self)
		glowFrame:SetPoint("CENTER")
		glowFrame:SetSize(size + 8, size + 8)

		return glowFrame
	end

	-- Tutorial-frame glow ring (NexEnhance-style). opts.outset, opts.blend ("BLEND"|"ADD"), opts.color {r,g,b}.
	local GLOW_TEX_H = "Interface/TutorialFrame/UIFrameTutorialGlow"
	local GLOW_TEX_V = "Interface/TutorialFrame/UIFrameTutorialGlowVertical"

	function K.CreateGlowBorder(frame, opts)
		if not frame or frame.kkGlowBorder then
			return frame
		end

		opts = opts or {}
		local out = opts.outset or 8
		local blend = opts.blend or "ADD"
		local color = opts.color

		local topLeft = frame:CreateTexture(nil, "BORDER")
		topLeft:SetTexture(GLOW_TEX_H)
		topLeft:SetSize(16, 16)
		topLeft:SetTexCoord(0.03125, 0.53125, 0.570312, 0.695312)
		topLeft:SetPoint("TOPLEFT", frame, "TOPLEFT", -out, out)

		local topRight = frame:CreateTexture(nil, "BORDER")
		topRight:SetTexture(GLOW_TEX_H)
		topRight:SetSize(16, 16)
		topRight:SetTexCoord(0.03125, 0.53125, 0.710938, 0.835938)
		topRight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", out - 1, out)

		local bottomLeft = frame:CreateTexture(nil, "BORDER")
		bottomLeft:SetTexture(GLOW_TEX_H)
		bottomLeft:SetSize(16, 16)
		bottomLeft:SetTexCoord(0.03125, 0.53125, 0.289062, 0.414062)
		bottomLeft:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", -out, -out)

		local bottomRight = frame:CreateTexture(nil, "BORDER")
		bottomRight:SetTexture(GLOW_TEX_H)
		bottomRight:SetSize(16, 16)
		bottomRight:SetTexCoord(0.03125, 0.53125, 0.429688, 0.554688)
		bottomRight:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", out, -out)

		local top = frame:CreateTexture(nil, "BORDER")
		top:SetTexture(GLOW_TEX_H)
		top:SetPoint("TOPLEFT", topLeft, "TOPRIGHT")
		top:SetPoint("BOTTOMRIGHT", topRight, "BOTTOMLEFT")
		top:SetTexCoord(0, 0.5, 0.148438, 0.273438)

		local bottom = frame:CreateTexture(nil, "BORDER")
		bottom:SetTexture(GLOW_TEX_H)
		bottom:SetPoint("TOPLEFT", bottomLeft, "TOPRIGHT")
		bottom:SetPoint("BOTTOMRIGHT", bottomRight, "BOTTOMLEFT")
		bottom:SetTexCoord(0, 0.5, 0.0078125, 0.132812)

		local left = frame:CreateTexture(nil, "BORDER")
		left:SetTexture(GLOW_TEX_V)
		left:SetPoint("TOPLEFT", topLeft, "BOTTOMLEFT")
		left:SetPoint("BOTTOMRIGHT", bottomLeft, "TOPRIGHT")
		left:SetTexCoord(0.015625, 0.265625, 0, 1)

		local right = frame:CreateTexture(nil, "BORDER")
		right:SetTexture(GLOW_TEX_V)
		right:SetPoint("TOPLEFT", topRight, "BOTTOMLEFT", 1, 0)
		right:SetPoint("BOTTOMRIGHT", bottomRight, "TOPRIGHT", 1, 0)
		right:SetTexCoord(0.296875, 0.546875, 0, 1)

		for _, piece in next, { topLeft, topRight, bottomLeft, bottomRight, top, bottom, left, right } do
			piece:SetBlendMode(blend)
			if color then
				piece:SetDesaturated(true)
				piece:SetVertexColor(color[1], color[2], color[3])
			end
		end

		frame.kkGlowBorder = true
		return frame
	end
end

-- ---------------------------------------------------------------------------
-- POSITIONAL HELPERS
-- ---------------------------------------------------------------------------

do
	-- REASON: Enables drag-and-drop functionality for any frame; supports persistent positioning.
	function K.CreateMoverFrame(self, parent, saved)
		local frame = parent or self
		if not (frame and type(frame) == "table" and frame.SetMovable) then
			return
		end

		frame:SetMovable(true)
		frame:SetUserPlaced(true)
		frame:SetClampedToScreen(true)

		if not (self and type(self) == "table" and self.EnableMouse) then
			return
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
			return
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
-- INTERFACE OPTION HELPERS
-- ---------------------------------------------------------------------------

do
	function K.HideInterfaceOption(self)
		if not self then
			return
		end

		self:SetAlpha(0)
		self:SetScale(0.0001)
	end

	function K.ShowInterfaceOption(self)
		if not self then
			return
		end

		self:SetAlpha(1)
		self:SetScale(1)
	end
end

-- ---------------------------------------------------------------------------
-- TIME & MONEY FORMATTING
-- ---------------------------------------------------------------------------

do
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
-- MAP & MONEY LOGIC
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
			return "Invalid amount"
		end

		local coppername = "|cffeda55fc|r"
		local goldname = "|cffffd700g|r"
		local silvername = "|cffc7c7cfs|r"

		local value = math_abs(amount)
		local gold = math_floor(value / 10000)
		local silver = math_floor((value / 100) % 100)
		local copper = math_floor(value % 100)

		if gold > 0 then
			return string_format("%s%s %02d%s %02d%s", BreakUpLargeNumbers(gold), goldname, silver, silvername, copper, coppername)
		elseif silver > 0 then
			return string_format("%d%s %02d%s", silver, silvername, copper, coppername)
		else
			return string_format("%d%s", copper, coppername)
		end
	end
end

