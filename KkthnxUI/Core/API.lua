--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/API.lua
	Purpose:
		Engine level helpers used everywhere: player info, pixel perfect
		scaling, colors, fonts, printing, and small utility creators.
		Kept dependency free so it can load right after the engine.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- ---------------------------------------------------------------------------
-- Local caching
-- ---------------------------------------------------------------------------

local _G = _G
local select = select
local type = type
local tostring = tostring
local floor = math.floor
local ceil = math.ceil
local abs = math.abs
local max = math.max
local min = math.min
local format = string.format
local strfind = string.find

local UIParent = UIParent
local GetPhysicalScreenSize = GetPhysicalScreenSize
local InCombatLockdown = InCombatLockdown

-- ---------------------------------------------------------------------------
-- Player info
-- ---------------------------------------------------------------------------

local name, realm = UnitName("player"), GetRealmName()
local _, class = UnitClass("player")
local _, race = UnitRace("player")
local faction = UnitFactionGroup("player")

K.Name = name
K.Realm = realm
K.Class = class
K.Race = race
K.Faction = faction
K.Level = UnitLevel("player")
K.Locale = GetLocale()
K.GUID = UnitGUID("player")

K.ClassColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class] or { r = 1, g = 1, b = 1 }

K.MediaFolder = "Interface\\AddOns\\KkthnxUI\\Media\\"

-- ---------------------------------------------------------------------------
-- Printing
-- ---------------------------------------------------------------------------

local titleTag = "|cff5C8BCFKkthnxUI|r: "

function K.Print(...)
	print(titleTag .. format(...))
end

-- Shared no-op, handy for neutering Blizzard globals.
function K.Noop() end

-- Midnight-safe aura read. C_UnitAuras.GetAuraDataByIndex throws ("Auras cannot
-- be accessed when secret while tainted") for a secret aura while our code is on
-- the stack (enemies, and some hidden player auras). Wrap it so callers get nil
-- instead of an error. The full display for secret-aura units needs the
-- CustomAuraContainer intrinsic system, which is a larger rework.
local GetAuraDataByIndex = C_UnitAuras and C_UnitAuras.GetAuraDataByIndex
function K.GetAuraData(unit, index, filter)
	if not GetAuraDataByIndex then
		return nil
	end
	local ok, data = pcall(GetAuraDataByIndex, unit, index, filter)
	if ok then
		return data
	end
	return nil
end

-- ---------------------------------------------------------------------------
-- Math helpers
-- ---------------------------------------------------------------------------

function K.Round(number, decimals)
	decimals = decimals or 0
	local mult = 10 ^ decimals
	return floor(number * mult + 0.5) / mult
end

function K.Clamp(value, low, high)
	return max(low, min(high, value))
end

-- Short numeric formatting (12.3k, 4.5m, ...)
function K.ShortValue(value)
	local absValue = value < 0 and -value or value
	if absValue >= 1e9 then
		return format("%.1fb", value / 1e9)
	elseif absValue >= 1e6 then
		return format("%.1fm", value / 1e6)
	elseif absValue >= 1e3 then
		return format("%.1fk", value / 1e3)
	end
	return tostring(value)
end

-- ---------------------------------------------------------------------------
-- Colors
-- ---------------------------------------------------------------------------

function K.RGBToHex(r, g, b)
	if type(r) == "table" then
		r, g, b = r.r or r[1], r.g or r[2], r.b or r[3]
	end
	return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- ---------------------------------------------------------------------------
-- Pixel perfect scaling (K.Pixel)
-- ---------------------------------------------------------------------------
-- 768 is WoW's reference height, so perfect = 768 / physicalHeight is the size
-- of one physical pixel at scale 1.0. mult is that pixel size at the current
-- UIParent scale. When the UIParent scale equals perfect, mult == 1 and every
-- integer is already pixel aligned. Pixel.Scale snaps any value onto that grid.

local Pixel = {}
K.Pixel = Pixel

Pixel.physicalWidth, Pixel.physicalHeight = GetPhysicalScreenSize()
Pixel.perfect = 768 / Pixel.physicalHeight
Pixel.mult = Pixel.perfect / (UIParent and UIParent:GetScale() or 1)

-- Mirror onto the engine for older call sites and the border system.
K.ScreenWidth, K.ScreenHeight = Pixel.physicalWidth, Pixel.physicalHeight
K.Resolution = format("%dx%d", K.ScreenWidth, K.ScreenHeight)
K.Mult = Pixel.mult

-- Ideal pixel perfect scale, clamped to WoW's valid range.
function Pixel.BestScale()
	return K.Clamp(Pixel.perfect, 0.4, 1.15)
end
K.GetPerfectScale = Pixel.BestScale

-- Recalculate mult after a scale or resolution change.
function Pixel.UpdateMult()
	Pixel.physicalWidth, Pixel.physicalHeight = GetPhysicalScreenSize()
	Pixel.perfect = 768 / Pixel.physicalHeight
	local uiScale = (C.General and C.General.UIScale) or Pixel.BestScale()
	Pixel.mult = Pixel.perfect / (uiScale ~= 0 and uiScale or 1)

	K.ScreenWidth, K.ScreenHeight = Pixel.physicalWidth, Pixel.physicalHeight
	K.Resolution = format("%dx%d", K.ScreenWidth, K.ScreenHeight)
	K.Mult = Pixel.mult
end
K.UpdatePixelMult = Pixel.UpdateMult

-- Snap a value onto the physical pixel grid, rounding magnitude toward zero
-- so opposite edges stay symmetric.
function Pixel.Scale(value)
	if value == 0 then
		return 0
	end
	local m = Pixel.mult
	if m == 1 then
		return value
	end
	local pixels = value / m
	pixels = value > 0 and floor(pixels) or ceil(pixels)
	local snapped = pixels * m
	return snapped == 0 and (value > 0 and m or -m) or snapped
end
K.Scale = Pixel.Scale

-- Nearest whole pixel snap for save paths without a frame reference.
function Pixel.Snap(value)
	if value == 0 then
		return 0
	end
	local result = floor(value / Pixel.mult + 0.5) * Pixel.mult
	local rounded = floor(result + 0.5)
	if abs(result - rounded) < 0.001 then
		result = rounded
	end
	return result
end

-- Apply the configured (or auto) UIParent scale. Deferred in combat.
local pendingScale
function K:SetupUIScale(init)
	local general = C.General or {}
	if general.AutoScale then
		general.UIScale = Pixel.BestScale()
	end
	local scale = general.UIScale or Pixel.BestScale()

	if init then
		Pixel.UpdateMult()
		return
	end

	if InCombatLockdown() then
		if not pendingScale then
			pendingScale = true
			local core = K:GetModule("Core", true)
			if core then
				core:RegisterEvent("PLAYER_REGEN_ENABLED", function(mod)
					mod:UnregisterEvent("PLAYER_REGEN_ENABLED")
					pendingScale = nil
					K:SetupUIScale()
				end)
			end
		end
		return
	end

	UIParent:SetScale(scale)
	Pixel.UpdateMult()
end

-- Some retail values are "secret" (protected) and cannot be read in combat.
K.IsSecret = _G.issecretvalue or function()
	return false
end

-- Threat colouring shared by nameplates and unit frames, so both read the same
-- way. The colour flips by role: a tank wants aggro (green while holding it), while
-- everyone else wants none (red the moment they pull it). A nil result means the
-- safe case, so the caller keeps the normal reaction colour.
do
	local THREAT_HOLD = { 0.2, 0.8, 0.2 }
	local THREAT_WARN = { 0.9, 0.7, 0.2 }
	local THREAT_AGGRO = { 0.9, 0.2, 0.2 }

	-- Are we tanking right now? Assigned group role first, then the spec's role so
	-- it still reads correctly while solo.
	function K.PlayerIsTank()
		local role = _G.UnitGroupRolesAssigned and _G.UnitGroupRolesAssigned("player")
		if role == "TANK" then
			return true
		end
		local spec = _G.GetSpecialization and _G.GetSpecialization()
		if spec and _G.GetSpecializationRole then
			return _G.GetSpecializationRole(spec) == "TANK"
		end
		return false
	end

	function K.ThreatFillColor(status, isTank)
		if isTank then
			if status == 3 then
				return THREAT_HOLD
			elseif status == 2 or status == 1 then
				return THREAT_WARN
			end
			return THREAT_AGGRO -- someone else is tanking
		else
			if status == 3 then
				return THREAT_AGGRO -- you pulled aggro
			elseif status == 2 or status == 1 then
				return THREAT_WARN
			end
		end
	end
end

-- Disable pixel snapping on a texture or line so our own snap wins.
function K.DisablePixelSnap(object)
	if object.SetSnapToPixelGrid then
		object:SetSnapToPixelGrid(false)
		object:SetTexelSnappingBias(0)
	end
end

-- ---------------------------------------------------------------------------
-- Fonts
-- ---------------------------------------------------------------------------

-- An outlined glyph already has a hard edge, so a drop shadow on top of it just
-- reads as mud. Only offset the shadow when the font is not outlined.
local function ShadowOffset(style)
	if style and strfind(style, "OUTLINE") then
		return 0, 0
	end
	return 1, -1
end

function K.SetFontString(parent, font, size, style, ...)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(font, size, style or "")
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0, 1)
	fs:SetShadowOffset(ShadowOffset(style))
	if select("#", ...) > 0 then
		fs:SetPoint(...)
	end
	return fs
end

-- Return the outline flag string based on the user preference.
function K.FontOutlineStyle()
	return (C.General and C.General.FontOutline) and "OUTLINE" or ""
end

-- Convenience: apply the addon font at a size to an existing FontString.
function K.SetFont(fontString, size, style)
	fontString:SetFont(K.GetFont(C.General and C.General.Font), size or 12, style or "")
	fontString:SetShadowColor(0, 0, 0, 1)
	fontString:SetShadowOffset(ShadowOffset(style))
	return fontString
end

-- ---------------------------------------------------------------------------
-- Small creators
-- ---------------------------------------------------------------------------

-- Create a plain textured backdrop layer on a frame. Border comes separately.
function K.CreateBackground(frame, r, g, b, a)
	local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
	bg:SetAllPoints()
	bg:SetColorTexture(r or 0.06, g or 0.06, b or 0.06, a or 0.9)
	K.DisablePixelSnap(bg)
	frame.KKUI_Background = bg
	return bg
end

-- ---------------------------------------------------------------------------
-- GUI icon atlas
-- ---------------------------------------------------------------------------
-- One texture sheet holds every config and bag toolbar icon on an 8x4 grid of
-- 128px cells (see Media/Textures/GUI/CategoryIcons). SetGUIIcon points a texture
-- at the sheet and crops it to one cell by its row-major index (0 based).

local GUI_ICON_ATLAS = "Interface/AddOns/KkthnxUI/Media/Textures/GUI/CategoryIcons"
local GUI_ICON_COLS, GUI_ICON_ROWS = 8, 4
-- Crop a little off each cell edge so the dark gap and rounded corner between the
-- tiles never bleeds into the drawn icon. A fraction of one cell, per side.
local GUI_ICON_INSET = 0.08

function K.SetGUIIcon(texture, index)
	if not texture or type(index) ~= "number" then
		return
	end
	local col = index % GUI_ICON_COLS
	local row = math.floor(index / GUI_ICON_COLS)
	local left = (col + GUI_ICON_INSET) / GUI_ICON_COLS
	local right = (col + 1 - GUI_ICON_INSET) / GUI_ICON_COLS
	local top = (row + GUI_ICON_INSET) / GUI_ICON_ROWS
	local bottom = (row + 1 - GUI_ICON_INSET) / GUI_ICON_ROWS
	texture:SetTexture(GUI_ICON_ATLAS)
	texture:SetTexCoord(left, right, top, bottom)
end
