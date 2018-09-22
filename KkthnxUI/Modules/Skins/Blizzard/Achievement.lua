local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function SkinAchievement()
	if (not IsAddOnLoaded("Blizzard_AchievementUI")) then
		return
	end

	local function SkinStatusBar(bar)
		local barTexture = K.GetTexture(C["Skins"].Texture)
		bar:StripTextures()
		bar:SetStatusBarTexture(barTexture)
		bar:SetStatusBarColor(4/255, 179/255, 30/255)
		bar:CreateBorder()
		local StatusBarName = bar:GetName()

		if _G[StatusBarName .. "Title"] then
			_G[StatusBarName .. "Title"]:SetPoint("LEFT", 4, 0)
		end

		if _G[StatusBarName .. "Label"] then
			_G[StatusBarName .. "Label"]:SetPoint("LEFT", 4, 0)
		end

		if _G[StatusBarName .. "Text"] then
			_G[StatusBarName .. "Text"]:SetPoint("RIGHT", -4, 0)
		end
	end

	SkinStatusBar(AchievementFrameSummaryCategoriesStatusBar)
	SkinStatusBar(AchievementFrameComparisonSummaryPlayerStatusBar)
	SkinStatusBar(AchievementFrameComparisonSummaryFriendStatusBar)
	AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints()
	AchievementFrameComparisonSummaryFriendStatusBar.text:SetPoint("CENTER")
	AchievementFrameComparisonHeader:SetPoint("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 45, -20)

	for i = 1, 12 do
		local frame = _G["AchievementFrameSummaryCategoriesCategory" .. i]
		local button = _G["AchievementFrameSummaryCategoriesCategory" .. i .. "Button"]
		local highlight = _G["AchievementFrameSummaryCategoriesCategory" .. i .. "ButtonHighlight"]
		SkinStatusBar(frame)
		button:StripTextures()
		highlight:StripTextures()

		--_G[highlight:GetName().."Middle"]:SetColorTexture(1, 1, 1, 0.1)
		--_G[highlight:GetName().."Middle"]:SetAllPoints(frame)
	end
end


Module.SkinFuncs["Blizzard_AchievementUI"] = SkinAchievement