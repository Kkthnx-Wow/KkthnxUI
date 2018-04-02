local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "<name> was unable to locate oUF install.")

--[[
info = {
	mode 			= "IN" (nil) or "OUT",
	startAlpha		= alpha value to start at,
endAlpha		= alpha value to end at,
timeToFade		= duration of animation,
startDelay		= seconds to wait before starting animation,
fadeHoldTime 	= seconds to wait after ending animation before calling finishedFunc,
finishedFunc	= function to call after animation has ended,
}
--]]

-- If you plan to reuse `info`, it should be passed as a single table,
-- NOT a reference, as the table will be directly edited.

frameFadeFrame = CreateFrame("Frame")
FADEFRAMES = {}

function frameIsFading(frame)
	for index, value in pairs(FADEFRAMES) do
		if value == frame then
			return true
		end
	end
end

function frameFadeRemoveFrame(frame)
	tDeleteItem(FADEFRAMES, frame)
end

function frameFadeOnUpdate(self, elapsed)
	local frame, info
	for index, value in pairs(FADEFRAMES) do
		frame, info = value, value.fadeInfo

		if info.startDelay and info.startDelay > 0 then
			info.startDelay = info.startDelay - elapsed
		else
			info.fadeTimer = (info.fadeTimer and info.fadeTimer + elapsed) or 0

			if info.fadeTimer < info.timeToFade then
				-- perform animation in either direction
				if info.mode == "IN" then
					frame:SetAlpha((info.fadeTimer / info.timeToFade) * (info.endAlpha - info.startAlpha) + info.startAlpha)
				elseif info.mode == "OUT" then
					frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * (info.startAlpha - info.endAlpha) + info.endAlpha)
				end
			else
				-- animation has ended
				frame:SetAlpha(info.endAlpha)

				if info.fadeHoldTime and info.fadeHoldTime > 0 then
					info.fadeHoldTime = info.fadeHoldTime - elapsed
				else
					frameFadeRemoveFrame(frame)

					if info.finishedFunc then
						info.finishedFunc(frame)
						info.finishedFunc = nil
					end
				end
			end
		end
	end

	if #FADEFRAMES == 0 then
		self:SetScript("OnUpdate", nil)
	end
end

function frameFade(frame, info)
	if not frame then return end

	if frameIsFading(frame) then
		-- cancel the current operation
		-- the code calling this should make sure not to interrupt a
		-- necessary finishedFunc. This will entirely skip it.
		frameFadeRemoveFrame(frame)
	end

	info = info or {}
	info.mode = info.mode or "IN"

	if info.mode == "IN" then
		info.startAlpha	= info.startAlpha or 0
		info.endAlpha	= info.endAlpha or 1
	elseif info.mode == "OUT" then
		info.startAlpha	= info.startAlpha or 1
		info.endAlpha	= info.endAlpha or 0
	end

	frame:SetAlpha(info.startAlpha)
	frame.fadeInfo = info

	tinsert(FADEFRAMES, frame)
	frameFadeFrame:SetScript("OnUpdate", frameFadeOnUpdate)
end

local function Cutaway_SetValue(bar,value)
	if not bar:IsVisible() then
		bar:orig_SetValue_Cutaway(value)
		return
	end

	if value < bar:GetValue() then
		if not frameIsFading(bar.Cutaway_Fader) then
			if bar:GetReverseFill() then
				bar.Cutaway_Fader:SetPoint("RIGHT", bar:GetStatusBarTexture(), "LEFT")
				bar.Cutaway_Fader:SetPoint("LEFT", bar, "RIGHT", -(bar:GetValue() / select(2, bar:GetMinMaxValues())) * bar:GetWidth(), 0)
			else
				bar.Cutaway_Fader:SetPoint("LEFT", bar:GetStatusBarTexture(), "RIGHT")
				bar.Cutaway_Fader:SetPoint("RIGHT", bar, "LEFT", (bar:GetValue() / select(2, bar:GetMinMaxValues())) * bar:GetWidth(), 0)
			end

			bar.Cutaway_Fader.right = bar:GetValue()

			frameFade(bar.Cutaway_Fader, {
				mode = "OUT",
				timeToFade = 1
			})
		end
	end

	if bar.Cutaway_Fader.right and value > bar.Cutaway_Fader.right then
		frameFadeRemoveFrame(bar.Cutaway_Fader)
		bar.Cutaway_Fader:SetAlpha(0)
	end

	bar:orig_SetValue_Cutaway(value)
end

local function Cutaway_SetStatusBarColor(bar,...)
	bar:orig_SetStatusBarColor_Cutaway(...)
	bar.Cutaway_Fader:SetVertexColor(...)
end

local function CutawayBar_Create(frame, bar)
	local fader = bar:CreateTexture(nil, "ARTWORK")
	fader:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
	fader:SetVertexColor(bar:GetStatusBarColor())
	fader:SetAlpha(0)

	fader:SetPoint("TOP")
	fader:SetPoint("BOTTOM")

	bar.orig_SetValue_Cutaway = bar.SetValue
	bar.SetValue = Cutaway_SetValue

	bar.orig_SetStatusBarColor_Cutaway = bar.SetStatusBarColor
	bar.SetStatusBarColor = Cutaway_SetStatusBarColor

	bar.Cutaway_Fader = fader
end

local function Cutaway_Hook(frame)
	frame.CutawayBar = CutawayBar_Create

	for k, v in pairs({"Health", "Power"}) do
		if frame[v] and frame[v].Cutaway then
			frame:CutawayBar(frame[v])
		end
	end
end

for i, f in ipairs(oUF.objects) do
	Cutaway_Hook(f)
end

oUF:RegisterInitCallback(Cutaway_Hook)