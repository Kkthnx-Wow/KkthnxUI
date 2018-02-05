local K, C = unpack(select(2, ...))

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

local function LoadSkin()
	QuestMapFrame.QuestsFrame.StoryTooltip:SetTemplate("Transparent", true)

	WorldMapFrame.UIElementsFrame.BountyBoard.BountyName:FontTemplate(nil, 14, "OUTLINE")

	WorldMapFrameAreaLabel:FontTemplate(nil, 30)
	WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
	WorldMapFrameAreaLabel:SetTextColor(0.9, 0.8, 0.6)
	WorldMapFrameAreaDescription:FontTemplate(nil, 20)
	WorldMapFrameAreaDescription:SetShadowOffset(2, -2)
	WorldMapFrameAreaPetLevels:FontTemplate(nil, 20)
	WorldMapFrameAreaPetLevels:SetShadowOffset(2, -2)
	WorldMapZoneInfo:FontTemplate(nil, 25)
	WorldMapZoneInfo:SetShadowOffset(2, -2)
end

tinsert(K.SkinFuncs["KkthnxUI"], LoadSkin)