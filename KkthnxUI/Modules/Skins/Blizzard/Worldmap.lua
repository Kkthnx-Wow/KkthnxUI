local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert

local hooksecurefunc = _G.hooksecurefunc

local function SkinWorldMapStuff()
	QuestMapFrame.QuestsFrame.StoryTooltip:StripTextures(true)

	QuestMapFrame.QuestsFrame.StoryTooltip.Backgrounds = QuestMapFrame.QuestsFrame.StoryTooltip:CreateTexture(nil, "BACKGROUND", -1)
    QuestMapFrame.QuestsFrame.StoryTooltip.Backgrounds:SetAllPoints(QuestMapFrame.QuestsFrame.StoryTooltip)
	QuestMapFrame.QuestsFrame.StoryTooltip.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	QuestMapFrame.QuestsFrame.StoryTooltip.Borders = CreateFrame("Frame", nil, QuestMapFrame.QuestsFrame.StoryTooltip)
	QuestMapFrame.QuestsFrame.StoryTooltip.Borders:SetAllPoints(QuestMapFrame.QuestsFrame.StoryTooltip)
	K.CreateBorder(QuestMapFrame.QuestsFrame.StoryTooltip.Borders)
	QuestMapFrame.QuestsFrame.StoryTooltip.Borders:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])

	WorldMapFrame.UIElementsFrame.BountyBoard.BountyName:FontTemplate(nil, 14, "OUTLINE")

	WorldMapFrameAreaDescription:FontTemplate(nil, 20)
	WorldMapFrameAreaDescription:SetShadowOffset(2, -2)
	WorldMapFrameAreaLabel:FontTemplate(nil, 30)
	WorldMapFrameAreaLabel:SetShadowOffset(2, -2)
	WorldMapFrameAreaLabel:SetTextColor(0.9, 0.8, 0.6)
	WorldMapFrameAreaPetLevels:FontTemplate(nil, 20)
	WorldMapFrameAreaPetLevels:SetShadowOffset(2, -2)
	WorldMapZoneInfo:FontTemplate(nil, 25)
	WorldMapZoneInfo:SetShadowOffset(2, -2)
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinWorldMapStuff)