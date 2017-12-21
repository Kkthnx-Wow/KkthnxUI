local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local string_format = string.format

local Movers = K.Movers
local MirrorTimerFont = K.GetFont(C["Unitframe"].Font)
local MirrorTimerTexture = K.GetTexture(C["Unitframe"].Texture)

local function MirrorTimer_OnUpdate(frame, elapsed)
	if (frame.paused) then
		return
	end

	if frame.timeSinceUpdate >= 0.3 then
		local minutes = frame.value / 60
		local seconds = frame.value % 60
		local text = frame.label:GetText()

		if frame.value > 0 then
			frame.TimerText:SetText(string_format("%s (%d:%02d)", text, minutes, seconds))
		else
			frame.TimerText:SetText(string_format("%s (0:00)", text))
		end
		frame.timeSinceUpdate = 0
	else
		frame.timeSinceUpdate = frame.timeSinceUpdate + elapsed
	end
end

-- Mirror Timers (Underwater Breath etc.), credit to Azilroka
for i = 1, MIRRORTIMER_NUMTIMERS do
	if C["Unitframe"].Enable ~= true then return end

	local mirrorTimer = _G["MirrorTimer"..i]
	local statusBar = _G["MirrorTimer"..i.."StatusBar"]
	local text = _G["MirrorTimer"..i.."Text"]

	mirrorTimer:StripTextures()
	mirrorTimer:SetSize(222, 22)
	mirrorTimer.label = text
	statusBar:SetStatusBarTexture(MirrorTimerTexture)
	statusBar:SetTemplate("Transparent")
	statusBar:SetSize(222, 22)
	text:Hide()

	statusBar.spark = statusBar:CreateTexture(nil, "ARTWORK", nil, 1)
	statusBar.spark:SetWidth(12)
	statusBar.spark:SetHeight(statusBar:GetHeight() * 2)
	statusBar.spark:SetTexture(C["Media"].Spark)
	statusBar.spark:SetBlendMode("ADD")
	statusBar.spark:SetPoint("CENTER", statusBar:GetStatusBarTexture(), "RIGHT", 0, 0)

	local TimerText = mirrorTimer:CreateFontString(nil, "OVERLAY")
	TimerText:SetFont(C["Media"].Font, 13)
	TimerText:SetShadowOffset(1.25, -1.25)
	TimerText:SetPoint("CENTER", statusBar, "CENTER", 0, 0)
	mirrorTimer.TimerText = TimerText

	mirrorTimer.timeSinceUpdate = 0.3 -- Make sure timer value updates right away on first show
	mirrorTimer:HookScript("OnUpdate", MirrorTimer_OnUpdate)

	Movers:RegisterFrame(mirrorTimer)
end