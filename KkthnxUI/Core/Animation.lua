local K = unpack(select(2, ...))

-- Sourced: ElvUI (Elvz)
-- Edited: KkthnxUI (Kkthnx)

local FADEFRAMES, FADEMANAGER = {}, CreateFrame("FRAME")
FADEMANAGER.delay = 0.025

function K.FlashLoopFinished(self, requested)
	if not requested then
		self:Play()
	end
end

function K.SetUpAnimGroup(obj, Type, ...)
	if not Type then
		Type = "Flash"
	end

	if string.sub(Type, 1, 5) == "Flash" then
		obj.anim = obj:CreateAnimationGroup("Flash")
		obj.anim.fadein = obj.anim:CreateAnimation("ALPHA", "FadeIn")
		obj.anim.fadein:SetFromAlpha(0)
		obj.anim.fadein:SetToAlpha(1)
		obj.anim.fadein:SetOrder(2)

		obj.anim.fadeout = obj.anim:CreateAnimation("ALPHA", "FadeOut")
		obj.anim.fadeout:SetFromAlpha(1)
		obj.anim.fadeout:SetToAlpha(0)
		obj.anim.fadeout:SetOrder(1)

		if Type == "FlashLoop" then
			obj.anim:SetScript("OnFinished", K.FlashLoopFinished)
		end
	else
		local x, y, duration, customName = ...
		if not customName then
			customName = "anim"
		end

		local anim = obj:CreateAnimationGroup("Move_In")
		obj[customName] = anim

		anim.in1 = anim:CreateAnimation("Translation")
		anim.in1:SetDuration(0)
		anim.in1:SetOrder(1)
		anim.in1:SetOffset(K.Scale(x), K.Scale(y))

		anim.in2 = anim:CreateAnimation("Translation")
		anim.in2:SetDuration(duration)
		anim.in2:SetOrder(2)
		anim.in2:SetSmoothing("OUT")
		anim.in2:SetOffset(K.Scale(-x), K.Scale(-y))

		anim.out1 = obj:CreateAnimationGroup("Move_Out")
		anim.out1:SetScript("OnFinished", function()
			obj:Hide()
		end)

		anim.out2 = anim.out1:CreateAnimation("Translation")
		anim.out2:SetDuration(duration)
		anim.out2:SetOrder(1)
		anim.out2:SetSmoothing("IN")
		anim.out2:SetOffset(K.Scale(x), K.Scale(y))
	end
end

function K.Flash(obj, duration, loop)
	if not obj.anim then
		K.SetUpAnimGroup(obj, loop and "FlashLoop" or "Flash")
	end

	if not obj.anim:IsPlaying() then
		obj.anim.fadein:SetDuration(duration)
		obj.anim.fadeout:SetDuration(duration)
		obj.anim:Play()
	end
end

function K.StopFlash(obj)
	if obj.anim and obj.anim:IsPlaying() then
		obj.anim:Stop()
	end
end

function K.SlideIn(obj, customName)
	if not customName then
		customName = "anim"
	end

	if not obj[customName] then
		return
	end

	obj[customName].out1:Stop()
	obj[customName]:Play()
	obj:Show()
end

function K.SlideOut(obj, customName)
	if not customName then
		customName = "anim"
	end

	if not obj[customName] then
		return
	end

	obj[customName]:Finish()
	obj[customName]:Stop()
	obj[customName].out1:Play()
end

function K.UIFrameFade_OnUpdate(_, elapsed)
	FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

	if FADEMANAGER.timer > FADEMANAGER.delay then
		FADEMANAGER.timer = 0

		for frame, info in next, FADEFRAMES do
			-- Reset the timer if there isn"t one, this is just an internal counter
			if frame:IsVisible() then
				info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.delay)
			else
				info.fadeTimer = info.timeToFade + 1
			end

			-- If the fadeTimer is less then the desired fade time then set the alpha otherwise hold the fade state, call the finished function, or just finish the fade
			if info.fadeTimer < info.timeToFade then
				if info.mode == "IN" then
					frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
				else
					frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
				end
			else
				frame:SetAlpha(info.endAlpha)

				-- If there is a fadeHoldTime then wait until its passed to continue on
				if info.fadeHoldTime and info.fadeHoldTime > 0 then
					info.fadeHoldTime = info.fadeHoldTime - elapsed
				else
					-- Complete the fade and call the finished function if there is one
					K.UIFrameFadeRemoveFrame(frame)

					if info.finishedFunc then
						if info.finishedArgs then
							info.finishedFunc(unpack(info.finishedArgs))
						else -- optional method
							info.finishedFunc(info.finishedArg1, info.finishedArg2, info.finishedArg3, info.finishedArg4, info.finishedArg5)
						end

						if not info.finishedFuncKeep then
							info.finishedFunc = nil
						end
					end
				end
			end
		end

		if not next(FADEFRAMES) then
			FADEMANAGER:SetScript("OnUpdate", nil)
		end
	end
end

-- Generic Fade Function
function K.UIFrameFade(frame, info)
	if not frame or frame:IsForbidden() then return end

	frame.fadeInfo = info

	if not info.mode then
		info.mode = "IN"
	end

	if info.mode == "IN" then
		if not info.startAlpha then
			info.startAlpha = 0
		end

		if not info.endAlpha then
			info.endAlpha = 1
		end

		if not info.diffAlpha then
			info.diffAlpha = info.endAlpha - info.startAlpha
		end
	else
		if not info.startAlpha then
			info.startAlpha = 1
		end

		if not info.endAlpha then
			info.endAlpha = 0
		end

		if not info.diffAlpha then
			info.diffAlpha = info.startAlpha - info.endAlpha
		end
	end

	frame:SetAlpha(info.startAlpha)

	if not frame:IsProtected() then
		frame:Show()
	end

	if not FADEFRAMES[frame] then
		FADEFRAMES[frame] = info -- Read Below Comment
		FADEMANAGER:SetScript("OnUpdate", K.UIFrameFade_OnUpdate)
	else
		FADEFRAMES[frame] = info -- Keep These Both, We Need This Updated In The Event Its Changed To Another Ref From A Plugin Or Sth, Don't Move It Up!
	end
end

-- Convenience Function To Do A Simple Fade In
function K.UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
	if not frame or frame:IsForbidden() then
		return
	end

	if frame.FadeObject then
		frame.FadeObject.fadeTimer = nil
	else
		frame.FadeObject = {}
	end

	frame.FadeObject.mode = "IN"
	frame.FadeObject.timeToFade = timeToFade
	frame.FadeObject.startAlpha = startAlpha
	frame.FadeObject.endAlpha = endAlpha
	frame.FadeObject.diffAlpha = endAlpha - startAlpha

	K.UIFrameFade(frame, frame.FadeObject)
end

-- Convenience Function To Do A Simple Fade Out
function K.UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
	if not frame or frame:IsForbidden() then
		return
	end

	if frame.FadeObject then
		frame.FadeObject.fadeTimer = nil
	else
		frame.FadeObject = {}
	end

	frame.FadeObject.mode = "OUT"
	frame.FadeObject.timeToFade = timeToFade
	frame.FadeObject.startAlpha = startAlpha
	frame.FadeObject.endAlpha = endAlpha
	frame.FadeObject.diffAlpha = startAlpha - endAlpha

	K.UIFrameFade(frame, frame.FadeObject)
end

function K.UIFrameFadeRemoveFrame(frame)
	if frame and FADEFRAMES[frame] then
		if frame.FadeObject then
			frame.FadeObject.fadeTimer = nil
		end

		FADEFRAMES[frame] = nil
	end
end