local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G

-- Wow API
local UIParent = _G.UIParent
local C_Timer_After = _G.C_Timer.After

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: OrderHallCommandBar

local OrderHallSkin = CreateFrame("Frame")
OrderHallSkin:RegisterEvent("ADDON_LOADED")
OrderHallSkin:SetScript("OnEvent", function(self, event, addon)
	if (event == "ADDON_LOADED" and addon == "Blizzard_OrderHallUI") then
		OrderHallSkin:RegisterEvent("DISPLAY_SIZE_CHANGED")
		OrderHallSkin:RegisterEvent("UI_SCALE_CHANGED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_ADDED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_REMOVED")

		self.styled = false

		OrderHallCommandBar:HookScript("OnShow", function()
			local bar = OrderHallCommandBar
			if not bar.styled then

				bar:EnableMouse(false)
				bar.Background:SetAtlas(nil)

				bar.ClassIcon:Hide()
				bar.AreaName:Hide()

				bar.CurrencyIcon:ClearAllPoints()
				bar.CurrencyIcon:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 2, 0)
				bar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)

				bar.Currency:ClearAllPoints()
				bar.Currency:SetPoint("LEFT", bar.CurrencyIcon, "RIGHT", 5, 0)
				bar.Currency:SetTextColor(.9, .9, .9)
				bar.Currency:SetShadowOffset(0.75, -.75)

				bar.WorldMapButton:UnregisterAllEvents()
				bar.WorldMapButton:Hide()

				bar.styled = true
			end
		end)
	elseif event ~= "ADDON_LOADED" then
		local bar = OrderHallCommandBar

		local index = 1
		C_Timer_After(0.3, function() -- Give it a bit more time to collect.
			local last
			for i, child in ipairs({bar:GetChildren()}) do
				if child.Icon and child.Count and child.TroopPortraitCover then
					child:ClearAllPoints()
					child:SetPoint("LEFT", bar.Currency, "RIGHT", 10 + (index - 1) * 70, 0)
					child:SetWidth(60)

					child.TroopPortraitCover:Hide()
					child.Icon:ClearAllPoints()
					child.Icon:SetPoint("LEFT", child, "LEFT", 0, 0)
					child.Icon:SetSize(32, 16)

					child.Count:ClearAllPoints()
					child.Count:SetPoint("LEFT", child.Icon, "RIGHT", 5, 0)
					child.Count:SetTextColor(.9, .9, .9)
					child.Count:SetShadowOffset(.75, -.75)

					last = child.Count

					index = index + 1
				end
			end
		end)
	end
end)

-- Credits
-- Lars "Goldpaw" Norberg for the design.