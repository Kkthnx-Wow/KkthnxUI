local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Blizzard")

-- Sourced: NDui

local function SetupMirrorBars(bar)
	local statusbar = _G[bar:GetName() .. "StatusBar"]
	local text = _G[bar:GetName() .. "Text"]
	local texture = K.GetTexture(C["General"].Texture)

	bar:SetSize(222, 22)
	bar:StripTextures()

	statusbar:SetAllPoints()
	statusbar:SetStatusBarTexture(texture)
	text:SetAllPoints()

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetWidth(64)
	bar.spark:SetHeight(bar:GetHeight())
	bar.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetPoint("CENTER", statusbar:GetStatusBarTexture(), "RIGHT", 0, 0)

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
