--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins and styles Blizzard's encounter and event timer bars (e.g., battleground starts).
-- - Design: Hooks the START_TIMER event to iterate and apply custom textures and borders to timer bars.
-- - Events: START_TIMER
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local pairs = pairs

-- ---------------------------------------------------------------------------
-- Skinning Logic
-- ---------------------------------------------------------------------------
local function setupTimerTracker(bar)
	-- REASON: Standardizes the appearance of timer bars with KkthnxUI textures and a clean border.
	local texture = K.GetTexture(C["General"].Texture)

	bar:SetSize(222, 22)
	-- REASON: Strips default Blizzard textures for a flat, modern aesthetic.
	bar:StripTextures()
	bar:SetStatusBarTexture(texture)

	-- REASON: Adds a spark texture to the progress bar to make the timer's movement more visually distinct.
	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetSize(64, bar:GetHeight())
	bar.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)

	bar:CreateBorder()

	bar.styled = true
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateTimerTracker()
	-- REASON: Entry point for timer bar skinning; registers for the start-of-encounter timer event.
	local function updateTimerTracker()
		local timerTracker = _G.TimerTracker
		if not (timerTracker and timerTracker.timerList) then
			return
		end

		for _, timer in pairs(timerTracker.timerList) do
			if timer.bar and not timer.bar.styled then
				setupTimerTracker(timer.bar)
			end
		end
	end

	K:RegisterEvent("START_TIMER", updateTimerTracker, true)
end
