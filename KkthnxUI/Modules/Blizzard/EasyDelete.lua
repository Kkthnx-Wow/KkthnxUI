local K, C, L = select(2, ...):unpack()
if C.Blizzard.EasyDelete ~= true then return end

local EasyDelete = CreateFrame("Frame")

function EasyDelete:DELETE_ITEM_CONFIRM(...)
	if StaticPopup1EditBox:IsShown() then
		StaticPopup1EditBox:Hide()
		StaticPopup1Button1:Enable()

		local Link = select(3, GetCursorInfo())

		EasyDelete.Link:SetText(Link)
		EasyDelete.Link:Show()
	end
end

function EasyDelete:ADDON_LOADED(addon)
	if addon ~= "KkthnxUI" then return end

	-- create item Link container
	EasyDelete.Link = StaticPopup1:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	EasyDelete.Link:SetPoint("CENTER", StaticPopup1EditBox)
	EasyDelete.Link:Hide()

	StaticPopup1:HookScript("OnHide", function(self)
		EasyDelete.Link:Hide()
	end)
end

EasyDelete:SetScript("OnEvent", function(self, event, ...)
	self[event](self, ...)
end)

EasyDelete:RegisterEvent("ADDON_LOADED")
EasyDelete:RegisterEvent("DELETE_ITEM_CONFIRM")
