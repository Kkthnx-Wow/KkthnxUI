local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

local pairs = pairs

local function StyleTimerBar(bar)
	local texture = K.GetTexture(C["General"].Texture)

	bar:SetSize(222, 22)
	bar:StripTextures()
	bar:SetStatusBarTexture(texture)

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetSize(64, bar:GetHeight())
	bar.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

	bar:CreateBorder()

	bar.styled = true -- set styled flag on the bar
end

function Module:CreateTimerTracker()
	local function UpdateTimerTracker()
		for _, timer in pairs(_G.TimerTracker.timerList) do
			if timer.bar and not timer.bar.styled then -- only apply style if not styled before
				StyleTimerBar(timer.bar)
			end
		end
	end

	K:RegisterEvent("START_TIMER", UpdateTimerTracker, true)
end
