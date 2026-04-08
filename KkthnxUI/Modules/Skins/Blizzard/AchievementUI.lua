--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Achievement UI summary bars and categories.
-- - Design: Applies custom status bar textures, gradients, and borders to achievement summary elements.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local CreateColor = _G.CreateColor

local AchievementFrameSummaryCategoriesStatusBar = _G.AchievementFrameSummaryCategoriesStatusBar

local function SetupStatusBar(statusBar)
	statusBar:StripTextures()
	statusBar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	statusBar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, 0.4, 0, 1), CreateColor(0, 0.6, 0, 1))
	statusBar:CreateBorder()
end

local function SetupAchievementSummaryCategory(category)
	SetupStatusBar(category)
	category.Label:SetTextColor(1, 1, 1)
	category.Label:SetPoint("LEFT", category, "LEFT", 6, 0)
	category.Text:SetPoint("RIGHT", category, "RIGHT", -5, 0)
	_G[category:GetName() .. "ButtonHighlight"]:SetAlpha(0)
end

local function StyleAchievementFrameSummaryCategories()
	for i = 1, 12 do
		local category = _G["AchievementFrameSummaryCategoriesCategory" .. i]
		if category then
			SetupAchievementSummaryCategory(category)
		end
	end
end

-- REASON: Main entry point for Blizzard Achievement UI skinning.
C.themes["Blizzard_AchievementUI"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local statusBar = AchievementFrameSummaryCategoriesStatusBar
	if statusBar then
		StyleAchievementSummaryStatusBar(statusBar)
	end

	StyleAchievementFrameSummaryCategories()
end
