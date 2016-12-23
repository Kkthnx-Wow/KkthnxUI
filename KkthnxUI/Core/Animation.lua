local K, C, L = unpack(select(2, ...))
-- Animation Functions

-- Lua API
local tremove = tremove
local random = math.random

K.SetUpAnimGroup = function(object, type, ...)
	if not type then type = "Flash" end

	if type == "Flash" then
		object.anim = object:CreateAnimationGroup("Flash")
		object.anim.fadein = object.anim:CreateAnimation("ALPHA", "FadeIn")
		object.anim.fadein:SetFromAlpha(0)
		object.anim.fadein:SetToAlpha(1)
		object.anim.fadein:SetOrder(2)

		object.anim.fadeout = object.anim:CreateAnimation("ALPHA", "FadeOut")
		object.anim.fadeout:SetFromAlpha(1)
		object.anim.fadeout:SetToAlpha(0)
		object.anim.fadeout:SetOrder(1)
	elseif type == "FlashLoop" then
		object.anim = object:CreateAnimationGroup("Flash")
		object.anim.fadein = object.anim:CreateAnimation("ALPHA", "FadeIn")
		object.anim.fadein:SetFromAlpha(0)
		object.anim.fadein:SetToAlpha(1)
		object.anim.fadein:SetOrder(2)

		object.anim.fadeout = object.anim:CreateAnimation("ALPHA", "FadeOut")
		object.anim.fadeout:SetFromAlpha(1)
		object.anim.fadeout:SetToAlpha(0)
		object.anim.fadeout:SetOrder(1)

		object.anim:SetScript("OnFinished", function(_, requested)
			if(not requested) then
				object.anim:Play()
			end
		end)
	else
		local x, y, duration, customName = ...
		if not customName then
			customName = "anim"
		end
		object[customName] = object:CreateAnimationGroup("Move_In")
		object[customName].in1 = object[customName]:CreateAnimation("Translation")
		object[customName].in1:SetDuration(0)
		object[customName].in1:SetOrder(1)
		object[customName].in2 = object[customName]:CreateAnimation("Translation")
		object[customName].in2:SetDuration(duration)
		object[customName].in2:SetOrder(2)
		object[customName].in2:SetSmoothing("OUT")
		object[customName].out1 = object:CreateAnimationGroup("Move_Out")
		object[customName].out2 = object[customName].out1:CreateAnimation("Translation")
		object[customName].out2:SetDuration(duration)
		object[customName].out2:SetOrder(1)
		object[customName].out2:SetSmoothing("IN")
		object[customName].in1:SetOffset(K.Scale(x), K.Scale(y))
		object[customName].in2:SetOffset(K.Scale(-x), K.Scale(-y))
		object[customName].out2:SetOffset(K.Scale(x), K.Scale(y))
		object[customName].out1:SetScript("OnFinished", function() object:Hide() end)
	end
end

K.Flash = function(object, duration, loop)
	if not object.anim then
		K.SetUpAnimGroup(object, loop and "FlashLoop" or "Flash")
	end

	if not object.anim.playing then
		object.anim.fadein:SetDuration(duration)
		object.anim.fadeout:SetDuration(duration)
		object.anim:Play()
		object.anim.playing = true
	end
end

K.StopFlash = function(object)
	if object.anim and object.anim.playing then
		object.anim:Stop()
		object.anim.playing = nil
	end
end

K.SlideIn = function(object, customName)
	if not customName then
		customName = "anim"
	end
	if not object[customName] then return end

	object[customName].out1:Stop()
	object:Show()
	object[customName]:Play()
end

K.SlideOut = function(object, customName)
	if not customName then
		customName = "anim"
	end
	if not object[customName] then return end

	object[customName]:Finish()
	object[customName]:Stop()
	object[customName].out1:Play()
end

local frameFadeManager = CreateFrame("FRAME")
local FADEFRAMES = {}

K.UIFrameFade_OnUpdate = function(self, elapsed)
	local index = 1
	local frame, fadeInfo
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index]
		fadeInfo = FADEFRAMES[index].fadeInfo
		-- Reset the timer if there isn"t one, this is just an internal counter
		fadeInfo.fadeTimer = (fadeInfo.fadeTimer or 0) + elapsed
		fadeInfo.fadeTimer = fadeInfo.fadeTimer + elapsed

		-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
		if (fadeInfo.fadeTimer < fadeInfo.timeToFade) then
			if (fadeInfo.mode == "IN") then
				frame:SetAlpha((fadeInfo.fadeTimer / fadeInfo.timeToFade) * (fadeInfo.endAlpha - fadeInfo.startAlpha) + fadeInfo.startAlpha)
			elseif (fadeInfo.mode == "OUT") then
				frame:SetAlpha(((fadeInfo.timeToFade - fadeInfo.fadeTimer) / fadeInfo.timeToFade) * (fadeInfo.startAlpha - fadeInfo.endAlpha) + fadeInfo.endAlpha)
			end
		else
			frame:SetAlpha(fadeInfo.endAlpha)
			-- If there is a fadeHoldTime then wait until its passed to continue on
			if (fadeInfo.fadeHoldTime and fadeInfo.fadeHoldTime > 0 ) then
				fadeInfo.fadeHoldTime = fadeInfo.fadeHoldTime - elapsed
			else
				-- Complete the fade and call the finished function if there is one
				K.UIFrameFadeRemoveFrame(frame)
				if (fadeInfo.finishedFunc) then
					fadeInfo.finishedFunc(fadeInfo.finishedArg1, fadeInfo.finishedArg2, fadeInfo.finishedArg3, fadeInfo.finishedArg4)
					fadeInfo.finishedFunc = nil
				end
			end
		end

		index = index + 1
	end

	if (#FADEFRAMES == 0) then
		frameFadeManager:SetScript("OnUpdate", nil)
	end
end

-- Generic fade function
K.UIFrameFade = function(frame, fadeInfo)
	if (not frame) then
		return
	end
	if (not fadeInfo.mode) then
		fadeInfo.mode = "IN"
	end
	if (fadeInfo.mode == "IN") then
		if (not fadeInfo.startAlpha) then
			fadeInfo.startAlpha = 0
		end
		if (not fadeInfo.endAlpha) then
			fadeInfo.endAlpha = 1.0
		end
	elseif (fadeInfo.mode == "OUT") then
		if (not fadeInfo.startAlpha) then
			fadeInfo.startAlpha = 1.0
		end
		if (not fadeInfo.endAlpha) then
			fadeInfo.endAlpha = 0
		end
	end
	frame:SetAlpha(fadeInfo.startAlpha)

	frame.fadeInfo = fadeInfo
	if not frame:IsProtected() then
		frame:Show()
	end

	local index = 1
	while FADEFRAMES[index] do
		-- If frame is already set to fade then return
		if (FADEFRAMES[index] == frame) then
			return
		end
		index = index + 1
	end
	FADEFRAMES[#FADEFRAMES + 1] = frame
	frameFadeManager:SetScript("OnUpdate", K.UIFrameFade_OnUpdate)
end

-- Convenience function to do a simple fade in
K.UIFrameFadeIn = function(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {}
	fadeInfo.mode = "IN"
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha
	fadeInfo.endAlpha = endAlpha
	K.UIFrameFade(frame, fadeInfo)
end

-- Convenience function to do a simple fade out
K.UIFrameFadeOut = function(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {}
	fadeInfo.mode = "OUT"
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha
	fadeInfo.endAlpha = endAlpha
	K.UIFrameFade(frame, fadeInfo)
end

K.tDeleteItem = function(table, item)
	local index = 1
	while table[index] do
		if (item == table[index]) then
			tremove(table, index)
			break
		else
			index = index + 1
		end
	end
end

K.UIFrameFadeRemoveFrame = function(frame)
	K.tDeleteItem(FADEFRAMES, frame)
end