local K, C, L = unpack(select(2, ...))

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
local RequireReload = false

-- Optimize graphic after we enter world
local PixelPerfect = CreateFrame("Frame")
PixelPerfect:RegisterEvent("PLAYER_LOGIN")
PixelPerfect:RegisterEvent("VARIABLES_LOADED")
PixelPerfect:RegisterEvent("ADDON_LOADED")
PixelPerfect:RegisterEvent("CINEMATIC_STOP")
PixelPerfect:RegisterEvent("UI_SCALE_CHANGED")
PixelPerfect:SetScript("OnEvent", function(self, event)
	if Lock then
		return
	end
	Lock = true

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

	if C["General"].AutoScale then
		C["General"].UIScale = math_max(0.64, math_min(1.15, 768 / K.ScreenHeight))
	else
		C["General"].UIScale = math_max(0.64, math_min(1.15, C["General"].UIScale or 768 / K.ScreenHeight or UIParent:GetScale()))
	end

	if C["General"].AutoScale then
		-- Set UIScale, NOTE: SetCVar for UIScale can cause taints so only do this when we need to..
		if K.Round and K.Round(UIParent:GetScale(), 5) ~= K.Round(C["General"].UIScale, 5) and (event == "PLAYER_LOGIN") then
			SetCVar("useUiScale", 1)
			SetCVar("uiScale", C["General"].UIScale)
			WorldMapFrame.hasTaint = true
		end
		-- SetCVar for UI scale only accepts value as low as 0.64, so scale UIParent if needed
		if (C["General"].UIScale < 0.64) then
			UIParent:SetScale(C["General"].UIScale)
		end
	end

	if (string_format("%.2f", GetCVar("uiScale")) ~= string_format("%.2f", C["General"].UIScale)) then
		SetCVar("uiScale", C["General"].UIScale)
		if not RequireReload then
			if C["General"].UIScale >= 0.64 then
				StaticPopup_Show("CONFIG_RL")
				RequireReload = true
			end
		end
	end

	if event == "PLAYER_LOGIN" then
		self:UnregisterEvent("PLAYER_LOGIN")
	elseif event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	self:RegisterEvent("DISPLAY_SIZE_CHANGED")

	Lock = false
end)

K.PixelPerfect = PixelPerfect