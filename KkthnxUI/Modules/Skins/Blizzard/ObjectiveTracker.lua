local K, C, L = select(2, ...):unpack()
-- if C.Skins.ObjectiveTracker ~= true then return end

local Skinning = CreateFrame("Frame")

local unpack = unpack
local function LoadSkin()
	ObjectiveTrackerBlocksFrame.QuestHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetFont(C.Media.Font, 14)
	ObjectiveTrackerBlocksFrame.AchievementHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetFont(C.Media.Font, 14)
	ObjectiveTrackerBlocksFrame.ScenarioHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetFont(C.Media.Font, 14)
	BONUS_OBJECTIVE_TRACKER_MODULE.Header:StripTextures()
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetFont(C.Media.Font, 14)
	WORLD_QUEST_TRACKER_MODULE.Header:StripTextures()
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetFont(C.Media.Font, 14)

	-- Skin ObjectiveTrackerFrame item buttons
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(30, 30)
			item:SetTemplate("Transparent")
			--item:StyleButton()
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(unpack(K.TexCoords))
			item.icon:SetPoint("TOPLEFT", item, 4, -4)
			item.icon:SetPoint("BOTTOMRIGHT", item, -4, 4)
			item.Cooldown:SetAllPoints(item.icon)
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(C.Media.Font, 14, "OUTLINE")
			item.Count:SetShadowOffset(1, -1)
			item.skinned = true
		end
	end)

	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", function(_, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(30, 30)
			item:SetTemplate("Transparent")
			--item:StyleButton()
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(unpack(K.TexCoords))
			item.icon:SetPoint("TOPLEFT", item, 4, -4)
			item.icon:SetPoint("BOTTOMRIGHT", item, -4, 4)
			item.Cooldown:SetAllPoints(item.icon)
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(C.Media.Font, 14, "OUTLINE")
			item.Count:SetShadowOffset(5, -5)
			item.skinned = true
		end
	end)
end

Skinning:RegisterEvent("PLAYER_LOGIN")
Skinning:SetScript("OnEvent", LoadSkin)