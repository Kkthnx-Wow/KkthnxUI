--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Game Menu frame and buttons.
-- - Design: Applies custom borders and skins buttons within the Game Menu UI.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local table_insert = _G.table.insert
local hooksecurefunc = _G.hooksecurefunc

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local GameMenuFrame = _G.GameMenuFrame
local Game16Font = _G.Game16Font

-- REASON: Main entry point for Blizzard Game Menu skinning.
table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if not C_AddOns_IsAddOnLoaded("ConsolePort_Menu") then
		local GameMenuFrame = _G.GameMenuFrame
		GameMenuFrame:StripTextures()
		GameMenuFrame:CreateBorder(nil, nil, C["General"].BorderStyle ~= "KkthnxUI_Pixel" and 32 or nil, nil, C["General"].BorderStyle ~= "KkthnxUI_Pixel" and -10 or nil)

		GameMenuFrame.Header:StripTextures()
		GameMenuFrame.Header:ClearAllPoints()
		GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)
		GameMenuFrame.Header.Text:SetFontObject(Game16Font)
		GameMenuFrame.Header.Text:SetTextColor(K.r, K.g, K.b)

		hooksecurefunc(GameMenuFrame, "InitButtons", function(menu)
			if not menu.buttonPool then
				return
			end

			for button in menu.buttonPool:EnumerateActive() do
				if not button.IsSkinned then
					button:SkinButton(true)
					button.KKUI_Border:SetOffset(-8)
					button.KKUI_Background:SetPoint("TOPLEFT", button, "TOPLEFT", 4, -4)
					button.KKUI_Background:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 4)
				end
			end

			if menu.KkthnxUI and not menu.KkthnxUI.IsSkinned then
				menu.KkthnxUI:SkinButton(true)
				menu.KkthnxUI.KKUI_Border:SetOffset(-8)
				menu.KkthnxUI.KKUI_Background:SetPoint("TOPLEFT", menu.KkthnxUI, "TOPLEFT", 4, -4)
				menu.KkthnxUI.KKUI_Background:SetPoint("BOTTOMRIGHT", menu.KkthnxUI, "BOTTOMRIGHT", -4, 4)
			end
		end)
	end

	if C_AddOns_IsAddOnLoaded("OptionHouse") then
		_G.GameMenuButtonOptionHouse:SkinButton()
	end
end)
