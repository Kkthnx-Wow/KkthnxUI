local K, C = unpack(KkthnxUI)

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

C.themes["Blizzard_AchievementUI"] = function()
	local achievementSummaryStatusBar = AchievementFrameSummaryCategoriesStatusBar
	if achievementSummaryStatusBar then
		SetupStatusBar(achievementSummaryStatusBar)
		achievementSummaryStatusBar.Title:SetPoint("LEFT", achievementSummaryStatusBar, "LEFT", 6, 0)
		achievementSummaryStatusBar.Text:SetPoint("RIGHT", achievementSummaryStatusBar, "RIGHT", -5, 0)
	end

	for i = 1, 12 do
		local category = _G["AchievementFrameSummaryCategoriesCategory" .. i]
		SetupAchievementSummaryCategory(category)
	end
end
