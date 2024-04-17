local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- Sourced: NDui

local function SetupMirrorBar(bar)
	-- local statusBar = bar.StatusBar
	local statusbar = bar.StatusBar or _G[bar:GetName() .. "StatusBar"]
	if statusbar then
		statusbar:SetAllPoints()
	elseif bar.SetStatusBarTexture then
		bar:SetStatusBarTexture()
	end

	local text = bar.Text
	local spark = bar.Spark

	bar:SetSize(222, 22)
	bar:StripTextures(true)

	text:ClearAllPoints()
	text:SetFontObject(K.UIFont)
	text:SetFont(text:GetFont(), 12, nil)
	text:SetPoint("BOTTOM", bar, "TOP", 0, 4)

	spark = bar:CreateTexture(nil, "OVERLAY")
	spark:SetSize(64, bar:GetHeight())
	spark:SetTexture(C["Media"].Textures.Spark128Texture)
	spark:SetBlendMode("ADD")
	spark:SetPoint("CENTER", statusbar:GetStatusBarTexture(), "RIGHT", 0, 0)

	bar:CreateBorder()
end

function Module:CreateMirrorBars()
	hooksecurefunc(MirrorTimerContainer, "SetupTimer", function(self, timer)
		local bar = self:GetAvailableTimer(timer)
		if not bar.styled then
			SetupMirrorBar(bar)
			bar.styled = true
		end
	end)
end
