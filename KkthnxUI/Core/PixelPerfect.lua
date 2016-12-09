local K, C, L = select(2, ...):unpack()

-- Lua API
local format = string.format

-- Wow API
local GetCVar = GetCVar
local SetCVar = SetCVar
local StaticPopup_Show = StaticPopup_Show

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ForceQuit, WorldMapFrame, UIParent

local RequireRestart = false

if C.General.AutoScale then
	C.General.UIScale = min(2, max(0.32, 768 / string.match(K.Resolution, "%d+x(%d+)")))
end

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
PixelPerfect:SetScript("OnEvent", function(self, event)
	if (event == "DISPLAY_SIZE_CHANGED") then
		if C.General.AutoScale and not RequireRestart then
			StaticPopup_Show("CLIENT_RESTART")
		end

		RequireRestart = true
	else
		local UseUIScale = GetCVar("useUiScale")

		if (UseUIScale ~= "1") then
			SetCVar("useUiScale", 1)
		end

		if (format("%.2f", GetCVar("uiScale")) ~= format("%.2f", C.General.UIScale)) then
			SetCVar("uiScale", C.General.UIScale)
		end

		-- Allow 4K and WQHD resolution to have an uiScale lower than 0.64, which is
		-- The lowest value of UIParent scale by default
		if (C.General.UIScale < 0.64) then
			UIParent:SetScale(C.General.UIScale)
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("DISPLAY_SIZE_CHANGED")
	end
end)