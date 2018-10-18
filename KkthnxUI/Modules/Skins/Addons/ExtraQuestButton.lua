local K = unpack(select(2, ...))
if not K.CheckAddOnState("ExtraQuestButton") then
	return
end

-- local Module = K:GetModule("Skins")

local SkinExtraQuestButton = CreateFrame("Frame")
SkinExtraQuestButton:RegisterEvent("ADDON_LOADED")
SkinExtraQuestButton:RegisterEvent("PLAYER_ENTERING_WORLD")
SkinExtraQuestButton:SetScript("OnEvent", function()
	ExtraQuestButton.Artwork:Kill()
	ExtraQuestButton.Icon:SetTexCoord(unpack(K.TexCoords))
	ExtraQuestButton.Icon:SetAllPoints()
	ExtraQuestButton.Icon:SetDrawLayer("OVERLAY")
	ExtraQuestButton:SetCheckedTexture("")
	ExtraQuestButton.HotKey:ClearAllPoints()
	ExtraQuestButton.HotKey:SetPoint("TOP", ExtraQuestButton, "TOP", 0, -1)

	ExtraQuestButton:StyleButton()
	ExtraQuestButton:CreateBorder()
end)