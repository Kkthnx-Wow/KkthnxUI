local K, C, L = unpack(select(2, ...))
if not K.IsDeveloper and not K.IsDeveloperRealm then return end

-- Always debug our temp code.
if LibDebug then LibDebug() end

local EasyDelete = CreateFrame("Frame", "EasyDeleteConfirmFrame")
EasyDelete:RegisterEvent("ADDON_LOADED")
EasyDelete:RegisterEvent("DELETE_ITEM_CONFIRM")
EasyDelete:SetScript("OnEvent", function(self, event)
	if StaticPopup1EditBox:IsShown() then
		StaticPopup1EditBox:Hide()
		StaticPopup1Button1:Enable()

		local Link = select(3, GetCursorInfo())

		EasyDelete.Link:SetText(link)
		EasyDelete.Link:Show()
	end

	-- Create item link container
	EasyDelete.Link = StaticPopup1:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	EasyDelete.Link:SetPoint("CENTER", StaticPopup1EditBox)
	EasyDelete.Link:Hide()

	StaticPopup1:HookScript("OnHide", function(self)
		EasyDelete.Link:Hide()
	end)
end)