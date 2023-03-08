local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- Sourced: NDui

local function SetupMirrorBar(bar)
	local statusBar = bar.StatusBar
	local text = bar.Text
	local spark = bar.Spark

	bar:SetSize(222, 22)
	bar:StripTextures(true)

	statusBar:SetAllPoints()

	text:ClearAllPoints()
	text:SetFontObject(K.UIFont)
	text:SetFont(text:GetFont(), 12, nil)
	text:SetPoint("BOTTOM", bar, "TOP", 0, 4)

	spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetSize(64, bar:GetHeight())
	spark:SetTexture(C["Media"].Textures.Spark128Texture)
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	bar:CreateBorder()
end

function Module:CreateMirrorBars()
	local previousBar
	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		SetupMirrorBar(bar)

		if previousBar then
			bar:SetPoint("TOP", previousBar, "BOTTOM", 0, -6)
		end
		previousBar = bar
	end
end
