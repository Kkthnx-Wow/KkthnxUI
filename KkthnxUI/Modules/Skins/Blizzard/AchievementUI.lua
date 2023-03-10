local K, C = KkthnxUI[1], KkthnxUI[2]

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
	local statusBar = AchievementFrameSummaryCategoriesStatusBar
	if statusBar and statusBar:GetName() then
		SetupStatusBar(statusBar)
		local name = statusBar:GetName()
		local title = _G[name .. "Title"]
		local text = _G[name .. "Text"]
		if title and text then
			title:SetPoint("LEFT", statusBar, "LEFT", 6, 0)
			text:SetPoint("RIGHT", statusBar, "RIGHT", -5, 0)
		end
	end

	for i = 1, 12 do
		local category = _G["AchievementFrameSummaryCategoriesCategory" .. i]
		SetupAchievementSummaryCategory(category)
	end
end
