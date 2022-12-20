local K, C = unpack(KkthnxUI)

local _G = _G

local function SetupStatusbar(bar)
	bar:StripTextures()
	bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	bar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, 0.4, 0, 1), CreateColor(0, 0.6, 0, 1))
	bar:CreateBorder()
end

C.themes["Blizzard_AchievementUI"] = function()
	local bar = AchievementFrameSummaryCategoriesStatusBar
	if bar then
		SetupStatusbar(bar)
		_G[bar:GetName() .. "Title"]:SetPoint("LEFT", bar, "LEFT", 6, 0)
		_G[bar:GetName() .. "Text"]:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
	end

	for i = 1, 12 do
		local bu = _G["AchievementFrameSummaryCategoriesCategory" .. i]
		SetupStatusbar(bu)
		bu.Label:SetTextColor(1, 1, 1)
		bu.Label:SetPoint("LEFT", bu, "LEFT", 6, 0)
		bu.Text:SetPoint("RIGHT", bu, "RIGHT", -5, 0)
		_G[bu:GetName() .. "ButtonHighlight"]:SetAlpha(0)
	end
end
