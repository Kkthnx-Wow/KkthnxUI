local K, C = unpack(select(2, ...))

-- Big thanks to Goldpaw for failproofing this badass script some more.

-- Lua API
local _G = _G
local math_max = math.max
local math_min = math.min
local string_format = string.format
local string_match = string.match

-- Wow API
local CanCancelScene = _G.CanCancelScene
local CanExitVehicle = _G.CanExitVehicle
local CinematicFrame = _G.CinematicFrame
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local InCinematic = _G.InCinematic
local InCombatLockdown = _G.InCombatLockdown
local SetCVar = _G.SetCVar

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ForceQuit, WorldMapFrame, UIParent

local IsLocked = false

-- Optimize graphic after we enter world
local PixelPerfect = CreateFrame("Frame")
PixelPerfect:RegisterEvent("PLAYER_ENTERING_WORLD")
PixelPerfect:RegisterEvent("CINEMATIC_STOP")
PixelPerfect:RegisterEvent("UI_SCALE_CHANGED")
PixelPerfect:SetScript("OnEvent", function(self, event)
	-- Prevent a C stack overflow
	if IsLocked then
		return
	end
	IsLocked = true

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if event ~= "CINEMATIC_STOP" and InCinematic() then
		return
	end

	if InCinematic() and not (CinematicFrame.isRealCinematic or CanCancelScene() or CanExitVehicle()) then
		return
	end

	-- Make sure that UI scaling is turned on
	local UseUIScale = GetCVarBool("useUiScale")
	if not UseUIScale then
		SetCVar("useUiScale", 1)
	end

	-- Automatically change the scale if auto scaling is activated
	if C["General"].AutoScale then
		C["General"].UIScale = math_min(2, math_max(0.32, 768 / string_match(K.Resolution, "%d+x(%d+)")))
	end

	if (string_format("%.2f", GetCVar("uiScale")) ~= string_format("%.2f", C["General"].UIScale)) then
		SetCVar("uiScale", C["General"].UIScale)
	end

	-- Allow 4K and WQHD resolution to have an uiScale lower than 0.64, which is
	-- The lowest value of UIParent scale by default
	if C["General"].UIScale < 0.64 then
		C["General"].UIScale = C["General"].UIScale + (C["General"].UIScale / 3)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
	self:RegisterEvent("DISPLAY_SIZE_CHANGED")

	IsLocked = false
end)