local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert

local hooksecurefunc = _G.hooksecurefunc

local function SkinWorldMapStuff()
	QuestMapFrame.QuestsFrame.StoryTooltip:SetTemplate("Transparent")

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

table_insert(Module.SkinFuncs["KkthnxUI"], SkinWorldMapStuff)