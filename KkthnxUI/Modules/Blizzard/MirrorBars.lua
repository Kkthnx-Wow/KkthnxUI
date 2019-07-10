local K, C = unpack(select(2, ...))
local Module = K:NewModule("MirrorBars")

-- Sourced: NDui

local function reskinTimerBar(bar)
	bar:SetSize(202, 22)

	local statusbar = _G[bar:GetName().."StatusBar"]
	statusbar.Text = _G[bar:GetName().."Text"]
	statusbar.barTexture = K.GetTexture(C["UITextures"].GeneralTextures)
	statusbar.barFont = K.GetFont(C["UIFonts"].GeneralFonts)
	if statusbar then
		statusbar:SetAllPoints()
		statusbar:SetStatusBarTexture(statusbar.barTexture)

		statusbar.Text:ClearAllPoints()
		statusbar.Text:SetPoint("CENTER", statusbar)
		statusbar.Text:SetFontObject(statusbar.barFont)

		statusbar.Spark = statusbar:CreateTexture(nil, "OVERLAY")
		statusbar.Spark:SetWidth(128)
		statusbar.Spark:SetHeight(statusbar:GetHeight())
		statusbar.Spark:SetTexture(C["Media"].Spark_128)
		statusbar.Spark:SetBlendMode("ADD")
		statusbar.Spark:SetPoint("CENTER", statusbar:GetStatusBarTexture(), "RIGHT", 0, 0)
	else
		bar:SetStatusBarTexture(statusbar.barTexture)

		bar.Text:ClearAllPoints()
		bar.Text:SetPoint("CENTER", bar)
		bar.Text:SetFontObject(statusbar.barFont)

		bar.Spark = bar:CreateTexture(nil, "OVERLAY")
		bar.Spark:SetWidth(128)
		bar.Spark:SetHeight(bar:GetHeight())
		bar.Spark:SetTexture(C["Media"].Spark_128)
		bar.Spark:SetBlendMode("ADD")
		bar.Spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	bar:CreateBorder(nil, nil, nil, true)
end

function Module:ReskinMirrorBars()
	local previous
	for i = 1, MIRRORTIMER_NUMTIMERS do
		local bar = _G["MirrorTimer"..i]
		reskinTimerBar(bar)

		if previous then
			bar:SetPoint("TOP", previous, "BOTTOM", 0, -6)
		end
		previous = bar
	end
end

function Module:OnInitialize()
	self:ReskinMirrorBars()
end