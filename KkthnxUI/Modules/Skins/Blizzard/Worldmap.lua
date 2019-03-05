local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert

local hooksecurefunc = _G.hooksecurefunc

local function SkinWorldMapStuff()
	-- QuestMapFrame.QuestsFrame.StoryTooltip:CreateBorder()
	-- QuestScrollFrame.WarCampaignTooltip:CreateBorder()

	--WorldMapFrameHomeButton.text:FontTemplate()
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinWorldMapStuff)