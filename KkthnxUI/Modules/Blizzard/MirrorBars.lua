local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local Movers = K.Movers

local function MirrorTimer_OnUpdate(frame, elapsed)
	if (frame.paused) then
		return
	end

	if frame.timeSinceUpdate >= 0.3 then
		local minutes = frame.value / 60
		local seconds = frame.value % 60
		local text = frame.label:GetText()

		if frame.value > 0 then
			frame.TimerText:SetText(format("%s (%d:%02d)", text, minutes, seconds))
		else
			frame.TimerText:SetText(format("%s (0:00)", text))
		end
		frame.timeSinceUpdate = 0
	else
		frame.timeSinceUpdate = frame.timeSinceUpdate + elapsed
	end
end

-- Mirror Timers (Underwater Breath etc.), credit to Azilroka
for i = 1, MIRRORTIMER_NUMTIMERS do
	local mirrorTimer = _G["MirrorTimer"..i]
	local statusBar = _G["MirrorTimer"..i.."StatusBar"]
	local text = _G["MirrorTimer"..i.."Text"]

	mirrorTimer:StripTextures()
	mirrorTimer:SetSize(222, 24)
	mirrorTimer.label = text
	statusBar:SetStatusBarTexture(C.Media.Texture)
	K.CreateBorder(statusBar, -1)
	statusBar:SetSize(222, 24)
	text:Hide()

	local Backdrop = select(1, mirrorTimer:GetRegions())
	Backdrop:SetTexture(C.Media.Blank)
	Backdrop:SetVertexColor(unpack(C.Media.Backdrop_Color))
	Backdrop:SetAllPoints(statusBar)

	local TimerText = mirrorTimer:CreateFontString(nil, "OVERLAY")
	TimerText:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	TimerText:SetPoint("CENTER", statusBar, "CENTER", 0, 0)
	mirrorTimer.TimerText = TimerText

	mirrorTimer.timeSinceUpdate = 0.3 -- Make sure timer value updates right away on first show
	mirrorTimer:HookScript("OnUpdate", MirrorTimer_OnUpdate)

	Movers:RegisterFrame(mirrorTimer)
end