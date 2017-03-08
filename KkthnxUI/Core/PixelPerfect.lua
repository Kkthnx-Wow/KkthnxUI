local K, C, L = unpack(select(2, ...))

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
local ReloadUI = _G.ReloadUI
local SetCVar = _G.SetCVar

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ForceQuit, WorldMapFrame, UIParent, StaticPopup_Show

local Lock = false
local RequireRestart = false

StaticPopupDialogs["CLIENT_RESTART"] = {
	text = L.Popup.ResolutionChanged,
	button1 = "Restart Client",
	button2 = RELOADUI,
	OnAccept = function(self) RequireRestart = false ForceQuit() end,
	OnCancel = function(self) RequireRestart = false ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3
}

-- Optimize graphic after we enter world
local PixelPerfect = CreateFrame("Frame")
PixelPerfect:RegisterEvent("PLAYER_ENTERING_WORLD")
PixelPerfect:RegisterEvent("CINEMATIC_STOP")
PixelPerfect:RegisterEvent("UI_SCALE_CHANGED")
PixelPerfect:RegisterEvent("DISPLAY_SIZE_CHANGED")
PixelPerfect:SetScript("OnEvent", function(self, event)
	-- Prevent a C stack overflow
	if Lock == true then
		return
	end

	if Lock == false then
		Lock = true
	end

	if InCombatLockdown() then
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
		return
	end

	if event ~= "CINEMATIC_STOP" and InCinematic() then
		return
	end

	if InCinematic() and not(CinematicFrame.isRealCinematic or CanCancelScene() or CanExitVehicle()) then
		return
	end

	-- Make sure that UI scaling is turned on
	local UseUIScale = GetCVarBool("useUiScale")
	if not UseUIScale then
		SetCVar("useUiScale", 1)
		WorldMapFrame.hasTaint = true
	end

	-- Automatically change the scale if auto scaling is activated
	if C.General.AutoScale then
		C.General.UIScale = math_min(2, math_max(0.32, 768 / string_match(K.Resolution, "%d+x(%d+)")))
	end

	if (string_format("%.2f", GetCVar("uiScale")) ~= string_format("%.2f", C.General.UIScale)) then
		SetCVar("uiScale", C.General.UIScale)
		if RequireRestart == false then
			if C.General.UIScale >= 0.64 then
				StaticPopup_Show("CLIENT_RESTART")
				RequireRestart = true
			end
		end
	end

	-- Allow 4K and WQHD resolution to have an uiScale lower than 0.64, which is
	-- The lowest value of UIParent scale by default
	if (C.General.UIScale < 0.64) then
		UIParent:SetScale(C.General.UIScale)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if Lock == true then
		Lock = false
	end
end)