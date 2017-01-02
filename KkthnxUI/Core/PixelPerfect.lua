local K, C, L = unpack(select(2, ...))

-- Big thanks to Goldpaw for failproofing this badass script some more.

-- Lua API
local format = string.format
local min, max = math.min, math.max
local strmatch = string.match

-- Wow API
local GetCVar = GetCVar
local GetCVarBool = GetCVarBool
local InCinematic = InCinematic
local InCombatLockdown = InCombatLockdown
local SetCVar = SetCVar
local StaticPopup_Show = StaticPopup_Show

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ForceQuit, WorldMapFrame, UIParent

local Lock = false
local RequireRestart = false

StaticPopupDialogs["CLIENT_RESTART"] = {
	text = L.Popup.ResolutionChanged,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function(self) RequireRestart = false ForceQuit() end,
	OnCancel = function(self) RequireRestart = false end,
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

	-- Make sure that UI scaling is turned on
	local UseUIScale = GetCVarBool("useUiScale")
	if not UseUIScale then
		K.LockCVar("useUiScale", 1)
	end

	-- Automatically change the scale if auto scaling is activated
	if C.General.AutoScale then
		C.General.UIScale = min(2, max(0.32, 768 / strmatch(K.Resolution, "%d+x(%d+)")))
	end

	if (format("%.2f", GetCVar("uiScale")) ~= format("%.2f", C.General.UIScale)) then
		SetCVar("uiScale", C.General.UIScale)
		if not RequireRestart then
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

	Lock = false
end)