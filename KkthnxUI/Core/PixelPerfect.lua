local K, C, L = unpack(select(2, ...))

-- Big thanks to Goldpaw for failproofing this badass script some more.

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
		-- Make sure that UI scaling is turned on
		local UseUIScale = GetCVarBool("useUiScale")
		if not UseUIScale then
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


-- -- Optimize graphic after we enter world
-- local PixelPerfect = CreateFrame("Frame")
-- PixelPerfect:RegisterEvent("PLAYER_ENTERING_WORLD")
-- PixelPerfect:RegisterEvent("CINEMATIC_STOP")
-- PixelPerfect:RegisterEvent("UI_SCALE_CHANGED")
-- PixelPerfect:RegisterEvent("DISPLAY_SIZE_CHANGED")
-- PixelPerfect:SetScript("OnEvent", function(self, event)
-- 	if InCombatLockdown() then
-- 		self:RegisterEvent("PLAYER_REGEN_ENABLED")
-- 		return
-- 	end
-- 	if event ~= "CINEMATIC_STOP" and InCinematic() then return end
--
-- 	-- Make sure that UI scaling is turned on
-- 	local UseUIScale = GetCVarBool("useUiScale")
-- 	if not UseUIScale then
-- 		SetCVar("useUiScale", 1)
-- 	end
--
-- 	-- Automatically change the scale if auto scaling is activated
-- 	if C.General.AutoScale then
-- 		if (format("%.2f", GetCVar("uiScale")) ~= format("%.2f", C.General.UIScale)) then
-- 			SetCVar("uiScale", C.General.UIScale)
-- 			if not RequireRestart then
-- 				StaticPopup_Show("CLIENT_RESTART")
-- 				RequireRestart = true
-- 			end
-- 		end
--
-- 		-- Allow 4K and WQHD resolution to have an uiScale lower than 0.64, which is
-- 		-- The lowest value of UIParent scale by default
-- 		if (C.General.UIScale < 0.64) then
-- 			UIParent:SetScale(C.General.UIScale)
-- 			if not RequireRestart then
-- 				StaticPopup_Show("CLIENT_RESTART")
-- 				RequireRestart = true
-- 			end
-- 		end
-- 	end
--
-- 	if event == "PLAYER_ENTERING_WORLD" then
-- 		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
-- 	elseif event == "PLAYER_REGEN_ENABLED" then
-- 		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
-- 	end
-- end)