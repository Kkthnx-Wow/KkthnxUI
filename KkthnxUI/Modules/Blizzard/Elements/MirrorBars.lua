local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

-- Sourced: ElvUI

local function MirrorTimer_OnUpdate(frame, elapsed)
	if frame.paused then return end
	if frame.timeSinceUpdate >= 0.3 then
		local minutes = frame.value / 60
		local seconds = frame.value % 60
		local text = frame.label:GetText()

		if frame.value > 0 then
			frame.TimerText:SetFormattedText("%s (%d:%02d)", text, minutes, seconds)
		else
			frame.TimerText:SetFormattedText("%s (0:00)", text)
		end

		frame.timeSinceUpdate = 0
	else
		frame.timeSinceUpdate = frame.timeSinceUpdate + elapsed
	end
end

function Module:CreateMirrorBars()
	-- Mirror Timers (Underwater Breath etc.), credit to Azilroka
	for i = 1, _G.MIRRORTIMER_NUMTIMERS do
		local mirrorTimer = _G["MirrorTimer"..i]
		local statusBar = _G["MirrorTimer"..i.."StatusBar"]
		local text = _G["MirrorTimer"..i.."Text"]

		mirrorTimer:StripTextures()
		mirrorTimer:SetSize(222, 22)
		mirrorTimer.label = text

		statusBar:SetStatusBarTexture(K.GetTexture(C["UITextures"].GeneralTextures))
		statusBar:CreateBorder()
		statusBar:SetSize(222, 22)

		statusBar.Spark = statusBar:CreateTexture(nil, "OVERLAY")
		statusBar.Spark:SetWidth(64)
		statusBar.Spark:SetHeight(statusBar:GetHeight())
		statusBar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		statusBar.Spark:SetBlendMode("ADD")
		statusBar.Spark:SetPoint("CENTER", statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)
		statusBar.Spark:SetAlpha(0.9)

		text:Hide()

		local TimerText = mirrorTimer:CreateFontString(nil, "OVERLAY")
		TimerText:FontTemplate()
		TimerText:SetPoint("CENTER", statusBar, "CENTER", 0, 0)
		mirrorTimer.TimerText = TimerText

		mirrorTimer.timeSinceUpdate = 0.3 --Make sure timer value updates right away on first show
		mirrorTimer:HookScript("OnUpdate", MirrorTimer_OnUpdate)

		K.Mover(mirrorTimer, "MirrorTimer"..i.."Mover", "MirrorTimer"..i.."Mover", {mirrorTimer:GetPoint()}) -- ??
	end
end