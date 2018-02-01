local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local string_match = string.match

-- Wow API
local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local GetScreenResolutions = _G.GetScreenResolutions
local GetCurrentResolution = _G.GetCurrentResolution
local UIParent = _G.UIParent
local SetCVar = _G.SetCVar

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ForceQuit, WorldMapFrame, UIParent, StaticPopup_Show

-- Optimize graphic after we enter world
local PixelPerfect = CreateFrame("Frame")
PixelPerfect:RegisterEvent("ADDON_LOADED")
PixelPerfect:RegisterEvent("PLAYER_REGEN_ENABLED")
PixelPerfect:RegisterEvent("PLAYER_REGEN_DISABLED")
PixelPerfect:RegisterEvent("LOADING_SCREEN_DISABLED")
PixelPerfect:SetScript("OnEvent", function(self, event)
	if (C["General"] and C["General"].AutoScale) then
		if not InCombatLockdown() then
			local InterfaceScale = 768 / K.ScreenHeight
			if (InterfaceScale < 0.64) then
				C["General"].AutoScale = false
				UIParent:SetScale(InterfaceScale)
			else
				self:UnregisterEvent("UI_SCALE_CHANGED")
				SetCVar("uiScale", InterfaceScale)
			end
		else
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end

		if event == "PLAYER_REGEN_ENABLED" then
			self:UnregisterEvent("PLAYER_REGEN_ENABLED")
		end
	end
end)

K["PixelPerfect"] = PixelPerfect