local K, C, L = unpack(select(2, ...))

local OrderHallSkin = CreateFrame("Frame")

local ipairs = ipairs

OrderHallSkin:RegisterEvent("ADDON_LOADED")
OrderHallSkin:SetScript("OnEvent", function(self, event, addon)
	if (event == "ADDON_LOADED" and addon == "Blizzard_OrderHallUI") then
		OrderHallSkin:RegisterEvent("DISPLAY_SIZE_CHANGED")
		OrderHallSkin:RegisterEvent("UI_SCALE_CHANGED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_ADDED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_REMOVED")

		OrderHallCommandBar:HookScript("OnShow", function()
			if not OrderHallCommandBar.styled then
				OrderHallCommandBar:EnableMouse(false)
				OrderHallCommandBar.Background:SetAtlas(nil)

				OrderHallCommandBar.ClassIcon:ClearAllPoints()
				OrderHallCommandBar.ClassIcon:SetPoint("TOPLEFT", 4, -4)
				OrderHallCommandBar.ClassIcon:SetSize(40, 20)
				OrderHallCommandBar.ClassIcon:SetAlpha(1)

				OrderHallCommandBar.AreaName:ClearAllPoints()
				OrderHallCommandBar.AreaName:SetPoint("LEFT", OrderHallCommandBar.ClassIcon, "RIGHT", 5, 0)
				OrderHallCommandBar.AreaName:SetFont(C.Media.Font, 14, "OUTLINE")
				OrderHallCommandBar.AreaName:SetTextColor(K.Color.r, K.Color.g, K.Color.b)
				OrderHallCommandBar.AreaName:SetShadowOffset(0, 0)

				OrderHallCommandBar.CurrencyIcon:ClearAllPoints()
				OrderHallCommandBar.CurrencyIcon:SetPoint("LEFT", OrderHallCommandBar.AreaName, "RIGHT", 5, 0)
				OrderHallCommandBar.Currency:ClearAllPoints()
				OrderHallCommandBar.Currency:SetPoint("LEFT", OrderHallCommandBar.CurrencyIcon, "RIGHT", 5, 0)
				OrderHallCommandBar.Currency:SetFont(C.Media.Font, 14, "OUTLINE")
				OrderHallCommandBar.Currency:SetTextColor(1, 1, 1)
				OrderHallCommandBar.Currency:SetShadowOffset(0, 0)

				OrderHallCommandBar.WorldMapButton:Kill()

				OrderHallCommandBar.styled = true
			end
		end)
	elseif event ~= "ADDON_LOADED" then
		local index = 1
		C_Timer.After(0.1, function()
			for i, child in ipairs({OrderHallCommandBar:GetChildren()}) do
				if child.Icon and child.Count and child.TroopPortraitCover then
					child:SetPoint("TOPLEFT", OrderHallCommandBar.ClassIcon, "BOTTOMLEFT", -5, -index * 25 + 20)
					child.TroopPortraitCover:Hide()

					child.Icon:SetSize(40, 20)

					child.Count:SetFont(C.Media.Font, 14, "OUTLINE")
					child.Count:SetTextColor(1, 1, 1)
					child.Count:SetShadowOffset(0, 0)

					index = index + 1
				end
			end
		end)
	end
end)