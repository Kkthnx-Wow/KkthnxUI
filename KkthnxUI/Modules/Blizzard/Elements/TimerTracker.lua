local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Blizzard")

-- Sourced: NDui

local _G = _G
local pairs = _G.pairs

local function SetupTimerTracker(bar)
	local texture = K.GetTexture(C["General"].Texture)
	-- local text = _G[bar:GetName() .. "Text"]

	bar:SetSize(222, 22)
	bar:StripTextures()
	bar:SetStatusBarTexture(texture)

	-- text:SetAllPoints()

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetWidth(64)
	bar.spark:SetHeight(bar:GetHeight())
	bar.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

	bar:CreateBorder()
end

function Module:CreateTimerTracker()
	local function UpdateTimerTracker()
		for _, timer in pairs(TimerTracker.timerList) do
			if timer.bar and not timer.bar.styled then
				SetupTimerTracker(timer.bar)

				timer.bar.styled = true
			end
		end
	end

	K:RegisterEvent("START_TIMER", UpdateTimerTracker, true)
end
