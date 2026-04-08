--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins and re-anchors Blizzard's mirror timer bars (breathing, fatigue, etc.).
-- - Design: Hooks MirrorTimerContainer:SetupTimer to apply custom styling to each bar.
-- - Events: Hooked into MirrorTimerContainer:SetupTimer
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local MirrorTimerContainer = _G.MirrorTimerContainer
local hooksecurefunc = _G.hooksecurefunc

-- ---------------------------------------------------------------------------
-- Skinning Logic
-- ---------------------------------------------------------------------------
local function setupMirrorBar(bar)
	-- REASON: Ensures the status bar component of the mirror timer is correctly positioned and styled.
	local statusbar = bar.StatusBar or _G[bar:GetName() .. "StatusBar"]
	if statusbar then
		statusbar:SetAllPoints()
	elseif bar.SetStatusBarTexture then
		bar:SetStatusBarTexture()
	end

	local text = bar.Text
	local spark = bar.Spark

	bar:SetSize(222, 22)
	-- REASON: Removes default Blizzard textures to allow for KkthnxUI's border and backdrop.
	bar:StripTextures(true)

	if text then
		text:ClearAllPoints()
		text:SetFontObject(K.UIFont)
		text:SetFont(text:GetFont(), 12, nil)
		text:SetPoint("BOTTOM", bar, "TOP", 0, 4)
	end

	-- REASON: Adds a custom spark texture to the status bar to enhance visibility of the progress.
	if statusbar and statusbar.GetStatusBarTexture then
		spark = bar:CreateTexture(nil, "OVERLAY")
		spark:SetSize(64, bar:GetHeight())
		spark:SetTexture(C["Media"].Textures.Spark128Texture)
		spark:SetBlendMode("ADD")
		spark:SetPoint("CENTER", statusbar:GetStatusBarTexture(), "RIGHT", 0, 0)
	end

	bar:CreateBorder()
end

-- ---------------------------------------------------------------------------
-- Module Registration
-- ---------------------------------------------------------------------------
function Module:CreateMirrorBars()
	-- REASON: Entry point for mirror bar skinning; hooks the standard Blizzard timer container.
	if not MirrorTimerContainer then
		return
	end

	hooksecurefunc(MirrorTimerContainer, "SetupTimer", function(self, timer)
		local bar = self:GetAvailableTimer(timer)
		if bar and not bar.styled then
			setupMirrorBar(bar)
			bar.styled = true
		end
	end)
end
