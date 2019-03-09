local K, C, L = unpack(select(2, ...))

local _G = _G
local string_format = string.format

local UIParent = _G.UIParent
local CreateFrame = _G.CreateFrame
local GetCVar = _G.GetCVar
local SetCVar = _G.SetCVar
local ACCEPT = _G.ACCEPT

local RequireReload = false

K.PopupDialogs["FORCE_RELOAD"] = {
	text = L["StaticPopups"].Config_Reload,
	button1 = ACCEPT,
	OnAccept = function()
		RequireReload = false
		ReloadUI()
	end,
	hideOnEscape = false,
	whileDead = 1,
	preferredIndex = 3
}

-- Optimize graphic after we enter world
local PixelPerfect = CreateFrame("Frame")
PixelPerfect:RegisterEvent("PLAYER_LOGIN")
PixelPerfect:RegisterEvent("PLAYER_ENTERING_WORLD")
PixelPerfect:SetScript("OnEvent", function(self, event)
	local Scaling = C["General"].Scaling.Value
	local Adjust = (K.ScreenHeight / 10000) / 2

	if (event == "PLAYER_LOGIN") then
		if (Scaling == "Smallest") then
			if (K.ScreenHeight >= 1600) then
				-- 0.35555556416512 + 0.108 = 0.463 on 4K monitor
				K.UIScale = K.UIScale + Adjust
			else
				K.UIScale = 0.64 - Adjust
			end
		elseif (Scaling == "Small") then
			K.UIScale = 0.64
		elseif (Scaling == "Medium") then
			K.UIScale = 0.64 + Adjust
		elseif (Scaling == "Large") then
			K.UIScale = 0.64 + Adjust + Adjust
		elseif (Scaling == "Oversize") then
			K.UIScale = 0.64 + Adjust + Adjust + Adjust
		end

		-- This is for 4K with pixel pecfection scaling
		if (K.ScreenHeight >= 1600) and (Scaling == "Pixel Perfection") then
			K.UIScale = K.UIScale * 2 -- Pixel Perfection Scaling, X 2 to still be almost pixel perfect, should be around 0.71
		end
	end

	if (event == "DISPLAY_SIZE_CHANGED") then
		if not RequireReload then
			K.StaticPopup_Show("FORCE_RELOAD")
		end

		RequireReload = true
	elseif (event == "PLAYER_ENTERING_WORLD") then
		local UseUIScale = GetCVar("useUiScale")

		if (UseUIScale ~= "1") then
			SetCVar("useUiScale", 1)
		end

		if (string_format("%.2f", GetCVar("uiScale")) ~= string_format("%.2f", K.UIScale)) then
			SetCVar("uiScale", K.UIScale)
		end

		-- Allow 4K and WQHD Resolution to have an UIScale lower than 0.64, which is
		-- the lowest value of UIParent scale by default
		if (K.UIScale < 0.64) then
			UIParent:SetScale(K.UIScale)
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:RegisterEvent("DISPLAY_SIZE_CHANGED")
	end
end)