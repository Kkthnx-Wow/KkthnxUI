local K, C, L, _ = select(2, ...):unpack()

if InCombatLockdown() then return end
local table = table
local tremove = tremove
local CreateFrame = CreateFrame

local frameFadeManager = CreateFrame("FRAME")
local FADEFRAMES = {}

function K:UIFrameFade_OnUpdate(elapsed)
	local index = 1
	local frame, fadeInfo
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index]
		fadeInfo = FADEFRAMES[index].fadeInfo
		-- Reset the timer if there isn't one, this is just an internal counter
		fadeInfo.fadeTimer = (fadeInfo.fadeTimer or 0) + elapsed
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed

		-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
		if ( fadeInfo.fadeTimer < fadeInfo.timeToFade ) then
			if ( fadeInfo.mode == "IN" ) then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha)
			elseif ( fadeInfo.mode == "OUT" ) then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha)  + fadeInfo.endAlpha)
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha)
			-- If there is a fadeHoldTime then wait until its passed to continue on
			if(fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0) then
				fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed
			else
				-- Complete the fade and call the finished function if there is one
				K:UIFrameFadeRemoveFrame(frame)
				if ( fadeInfo.finishedFunc ) then
					fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4)
					fadeInfo.finishedFunc = nil
				end
			end
		end

		index = index + 1
	end

	if ( #FADEFRAMES == 0 ) then
		frameFadeManager:SetScript("OnUpdate", nil)
	end
end

-- Generic fade function
function K:UIFrameFade(frame, fadeInfo)
	if (not frame) then
		return
	end
	if ( not fadeInfo.mode ) then
		fadeInfo.mode = "IN"
	end
	local alpha
	if ( fadeInfo.mode == "IN" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 0
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 1.0
		end
		alpha = 0
	elseif ( fadeInfo.mode == "OUT" ) then
		if ( not fadeInfo.startAlpha ) then
			fadeInfo.startAlpha = 1.0
		end
		if ( not fadeInfo.endAlpha ) then
			fadeInfo.endAlpha = 0
		end
		alpha = 1.0
	end
	frame:SetAlpha(fadeInfo.startAlpha)

	frame.fadeInfo = fadeInfo
	if not frame:IsProtected() then
		frame:Show()
	end

	local index = 1
	while FADEFRAMES[index] do
		-- If frame is already set to fade then return
		if ( FADEFRAMES[index] == frame ) then
			return
		end
		index = index + 1
	end
	FADEFRAMES[#FADEFRAMES + 1] = frame
	frameFadeManager:SetScript("OnUpdate", K.UIFrameFade_OnUpdate)
end

-- Convenience function to do a simple fade in
function K:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {}
	fadeInfo.mode = "IN"
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha
	fadeInfo.endAlpha = endAlpha
	K:UIFrameFade(frame, fadeInfo)
end

-- Convenience function to do a simple fade out
function K:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {}
	fadeInfo.mode = "OUT"
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha
	fadeInfo.endAlpha = endAlpha
	K:UIFrameFade(frame, fadeInfo)
end

function K:tDeleteItem(table, item)
	local index = 1
	while table[index] do
		if ( item == table[index] ) then
			tremove(table, index)
			break
		else
			index = index + 1
		end
	end
end

function K:UIFrameFadeRemoveFrame(frame)
	K:tDeleteItem(FADEFRAMES, frame)
end