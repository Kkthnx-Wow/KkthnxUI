local K, C, L, _ = select(2, ...):unpack()

local OrderHallSkin = CreateFrame("Frame")
OrderHallSkin:RegisterEvent("ADDON_LOADED")

local function Abbrev(AreaName)
	local NewAreaName = (string.len(AreaName) > 18) and string.gsub(AreaName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or AreaName
	return K.ShortenString(NewAreaName, 18, false)
end

OrderHallSkin:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "Blizzard_OrderHallUI" then
		OrderHallSkin:RegisterEvent("DISPLAY_SIZE_CHANGED")
		OrderHallSkin:RegisterEvent("UI_SCALE_CHANGED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_ADDED")
		OrderHallSkin:RegisterEvent("GARRISON_FOLLOWER_REMOVED")

		OrderHallCommandBar:HookScript("OnShow", function()
			if not OrderHallCommandBar.styled then
				OrderHallCommandBar:StripTextures()
				OrderHallCommandBar:SetTemplate("Transparent")
				OrderHallCommandBar:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)

				OrderHallCommandBar:ClearAllPoints()
				OrderHallCommandBar:SetPoint("TOP", UIParent, 0, 0)
				OrderHallCommandBar:SetWidth(480)
				OrderHallCommandBar:SetHeight(28)

				OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				OrderHallCommandBar.ClassIcon:SetSize(40, 20)
				OrderHallCommandBar.ClassIcon:SetAlpha(1)
				OrderHallCommandBar.ClassIcon:ClearAllPoints()
				OrderHallCommandBar.ClassIcon:SetPoint("LEFT", OrderHallCommandBar, "LEFT", 2, 0)

				OrderHallCommandBar.AreaName:ClearAllPoints()
				OrderHallCommandBar.AreaName:SetPoint("LEFT", OrderHallCommandBar.ClassIcon, "RIGHT", 5, 0.5)
				OrderHallCommandBar.AreaName:SetFont(C.Media.Font, 12, "OUTLINE")
				OrderHallCommandBar.AreaName:SetText(Abbrev(OrderHallCommandBar.AreaName:GetText()))
				OrderHallCommandBar.AreaName:SetTextColor(1, 1, 1)
				OrderHallCommandBar.AreaName:SetShadowOffset(0, 0)

				OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
				OrderHallCommandBar.CurrencyIcon:ClearAllPoints()
				OrderHallCommandBar.CurrencyIcon:SetPoint("LEFT", OrderHallCommandBar.AreaName, "RIGHT", 5, -0.5)
				OrderHallCommandBar.CurrencyIcon:SetSize(26, 26)
				OrderHallCommandBar.Currency:ClearAllPoints()
				OrderHallCommandBar.Currency:SetPoint("LEFT", OrderHallCommandBar.CurrencyIcon, "RIGHT", 5, 0.5)
				OrderHallCommandBar.Currency:SetFont(C.Media.Font, 12, "OUTLINE")
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
					child.TroopPortraitCover:Hide()

					child.Icon:SetSize(40, 20)

					child.Count:SetFont(C.Media.Font, 12, "OUTLINE")
					child.Count:SetTextColor(1, 1, 1)
					child.Count:SetShadowOffset(0, 0)

					index = index + 1
				end
			end
		end)
	end
end)