local K, C = unpack(select(2, ...))

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

C.themes["Blizzard_AchievementUI"] = function()
	AchievementFrameSummaryCategoriesStatusBar:StripTextures()
	AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
	AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
	AchievementFrameSummaryCategoriesStatusBarTitle:SetTextColor(1, 1, 1)
	AchievementFrameSummaryCategoriesStatusBarTitle:SetPoint("LEFT", AchievementFrameSummaryCategoriesStatusBar, "LEFT", 6, 0)
	AchievementFrameSummaryCategoriesStatusBarText:SetPoint("RIGHT", AchievementFrameSummaryCategoriesStatusBar, "RIGHT", -5, 0)
	AchievementFrameSummaryCategoriesStatusBar:CreateBorder()

	for i = 1, 12 do
		local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
		bu:StripTextures()
		bu:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
		bu:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		bu:CreateBorder()

		bu.label:SetTextColor(1, 1, 1)
		bu.label:SetPoint("LEFT", bu, "LEFT", 6, 0)
		bu.text:SetPoint("RIGHT", bu, "RIGHT", -5, 0)

		_G[bu:GetName().."ButtonHighlight"]:StripTextures()
		_G[bu:GetName().."ButtonHighlight".."Middle"]:SetColorTexture(1, 1, 1, 0.2)
		_G[bu:GetName().."ButtonHighlight".."Middle"]:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
		_G[bu:GetName().."ButtonHighlight".."Middle"]:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
	end

	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local bar = _G["AchievementFrameProgressBar"..index]
		if not bar.styled then
			bar:StripTextures()
			bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
			bar:CreateBorder()

			bar.styled = true
		end
	end)

	local bars = {AchievementFrameComparisonSummaryPlayerStatusBar, AchievementFrameComparisonSummaryFriendStatusBar}
	for _, bar in pairs(bars) do
		bar:StripTextures()
		bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].SkinTextures))
		bar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		bar.title:SetTextColor(1, 1, 1)
		bar.title:SetPoint("LEFT", bar, "LEFT", 6, 0)
		bar.text:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
		bar:CreateBorder()
	end
end