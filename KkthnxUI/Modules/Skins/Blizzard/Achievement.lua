local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function ReskinAchievementUI()
	local function SkinStatusBar(bar)
		local barTexture = K.GetTexture(C["UITextures"].SkinTextures)
		bar:StripTextures()
		bar:SetStatusBarTexture(barTexture)
		bar:SetStatusBarColor(4/255, 179/255, 30/255)
		bar:CreateBorder()
		local StatusBarName = bar:GetName()

		if _G[StatusBarName.."Title"] then
			_G[StatusBarName.."Title"]:SetPoint("LEFT", 4, 0)
		end

		if _G[StatusBarName.."Label"] then
			_G[StatusBarName.."Label"]:SetPoint("LEFT", 4, 0)
		end

		if _G[StatusBarName.."Text"] then
			_G[StatusBarName.."Text"]:SetPoint("RIGHT", -4, 0)
		end
	end

	SkinStatusBar(_G.AchievementFrameSummaryCategoriesStatusBar)
	SkinStatusBar(_G.AchievementFrameComparisonSummaryPlayerStatusBar)
	SkinStatusBar(_G.AchievementFrameComparisonSummaryFriendStatusBar)
	_G.AchievementFrameComparisonSummaryFriendStatusBar.text:ClearAllPoints()
	_G.AchievementFrameComparisonSummaryFriendStatusBar.text:SetPoint("CENTER")
	_G.AchievementFrameComparisonHeader:SetPoint("BOTTOMRIGHT", _G.AchievementFrameComparison, "TOPRIGHT", 45, -20)

	for i = 1, 12 do
		local frame = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local button = _G["AchievementFrameSummaryCategoriesCategory"..i.."Button"]
		local highlight = _G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]
		SkinStatusBar(frame)
		button:StripTextures()
		highlight:StripTextures()
	end
end

Module.NewSkin["Blizzard_AchievementUI"] = ReskinAchievementUI