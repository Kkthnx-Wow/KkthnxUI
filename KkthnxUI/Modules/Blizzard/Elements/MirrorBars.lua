local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Blizzard")

-- Sourced: NDui

local function SetupMirrorBars(bar)
	local statusbar = bar.StatusBar
	local text = bar.Text
	local spark = bar.Spark
	-- local texture = K.GetTexture(C["General"].Texture)

	bar:SetSize(222, 22)
	bar:StripTextures(true)

	statusbar:SetAllPoints()
	-- statusbar:SetStatusBarTexture(texture) -- Does not do anything?

	text:ClearAllPoints()
	text:SetFontObject(K.UIFont)
	text:SetFont(select(1, text:GetFont()), 12, select(3, text:GetFont()))
	text:SetPoint("BOTTOM", bar, "TOP", 0, 4)

	spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetWidth(64)
	spark:SetHeight(bar:GetHeight())
	spark:SetTexture(C["Media"].Textures.Spark128Texture)
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", statusbar:GetStatusBarTexture(), "RIGHT", 0, 0)

	bar:CreateBorder()
end

function Module:CreateMirrorBars()
	local previous
	for i = 1, 3 do
		local bar = _G["MirrorTimer" .. i]
		SetupMirrorBars(bar)

		if previous then
			bar:SetPoint("TOP", previous, "BOTTOM", 0, -6)
		end
		previous = bar
	end
end
