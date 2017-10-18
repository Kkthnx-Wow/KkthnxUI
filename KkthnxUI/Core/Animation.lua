local K, C, L = unpack(select(2, ...))

-- Sourced: ElvUI (Elvz)
-- Edited: KkthnxUI (Kkthnx)

-- GLOBALS: unpack, select, _G, table

-- luacheck: globals unpack select _G table

-- Lua API
local _G = _G
local table_remove = table.remove
local select = select
local unpack = unpack

-- Wow API
local CreateFrame = _G.CreateFrame

local function SetAnimationGroup(object, type, ...)
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
			if (not requested) then
				object.anim:Play()
			end
		end)
	end
end

function K.UIFrameFlash(object, duration, loop)
	if not object.anim then
		SetAnimationGroup(object, loop and "FlashLoop" or "Flash")
	end

	if not object.anim.playing then
		object.anim.fadein:SetDuration(duration)
		object.anim.fadeout:SetDuration(duration)
		object.anim:Play()
		object.anim.playing = true
	end
end

function K.UIFrameStopFlash(object)
	if object.anim and object.anim.playing then
		object.anim:Stop()
		object.anim.playing = nil
	end
end

local frameFadeManager = CreateFrame("FRAME")
local FADEFRAMES = {}

local function tDeleteItem(table, item)
	local index = 1
	while table[index] do
		if (item == table[index]) then
			table_remove(table, index)
			break
		else
			index = index + 1
		end
	end
end

local function UIFrameFade_OnUpdate(self, elapsed)
	local index = 1
	local frame, fadeInfo
	while FADEFRAMES[index] do
		frame = FADEFRAMES[index]
		fadeInfo = FADEFRAMES[index].fadeInfo
		-- Reset the timer if there isn't one, this is just an internal counter
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
				tDeleteItem(FADEFRAMES, frame)
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
local function UIFrameFade(frame, fadeInfo)
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
	frameFadeManager:SetScript("OnUpdate", UIFrameFade_OnUpdate)
end

-- Convenience function to do a simple fade in
function K.UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {}
	fadeInfo.mode = "IN"
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha
	fadeInfo.endAlpha = endAlpha
	UIFrameFade(frame, fadeInfo)
end

-- Convenience function to do a simple fade out
function K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	local fadeInfo = {}
	fadeInfo.mode = "OUT"
	fadeInfo.timeToFade = timeToFade
	fadeInfo.startAlpha = startAlpha
	fadeInfo.endAlpha = endAlpha
	UIFrameFade(frame, fadeInfo)
end