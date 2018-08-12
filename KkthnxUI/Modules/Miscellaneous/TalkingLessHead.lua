local K, C = unpack(select(2, ...))
if C["Misc"].TalkingLessHead ~= true then
	return
end

local Module = K:NewModule("TalkingLessHead", "AceEvent-3.0")

-- Sourced: TalkLess (C) Kruithne <kruithne@gmail.com>

local _G = _G
local string_format = string.format

local C_TalkingHead_GetCurrentLineInfo = _G.C_TalkingHead.GetCurrentLineInfo
local C_Timer_After = _G.C_Timer.After
local IsAddOnLoaded = _G.IsAddOnLoaded
local playerName = _G.UnitName("player")
local playerRealm = _G.GetRealmName()
local PlaySound = _G.PlaySound
local StopSound = _G.StopSound

local function KkthnxUI_TalkingHeadFrame_PlayCurrent()
	local frame = _G["TalkingHeadFrame"]
	local model = frame.MainFrame.Model

	if (frame.finishTimer) then
		frame.finishTimer:Cancel()
		frame.finishTimer = nil
	end

	if (frame.voHandle) then
		StopSound(frame.voHandle)
		frame.voHandle = nil
	end

	local currentDisplayInfo = model:GetDisplayInfo()
	local displayInfo, cameraID, vo, _, _, _, name, text, isNewTalkingHead = C_TalkingHead_GetCurrentLineInfo()

	if KkthnxUIData[playerRealm][playerName].TalkLess[vo] then
		-- We've already heard this line before.
		return
	else
		-- New line, flag it as heard.
		KkthnxUIData[playerRealm][playerName].TalkLess[vo] = true
	end

	local textFormatted = string_format(text)
	if (displayInfo and displayInfo ~= 0) then
		frame:Show()
		if (currentDisplayInfo ~= displayInfo) then
			model.uiCameraID = cameraID
			model:SetDisplayInfo(displayInfo)
		else
			if (model.uiCameraID ~= cameraID) then
				model.uiCameraID = cameraID
				Model_ApplyUICamera(model, model.uiCameraID)
			end

			TalkingHeadFrame_SetupAnimations(model)
		end

		if (isNewTalkingHead) then
			TalkingHeadFrame_Reset(frame, textFormatted, name)
			TalkingHeadFrame_FadeinFrames()
		else
			if (name ~= frame.NameFrame.Name:GetText()) then
				-- Fade out the old name and fade in the new name
				frame.NameFrame.Fadeout:Play()
				C_Timer_After(0.25, function()
					frame.NameFrame.Name:SetText(name)
				end)

				C_Timer_After(0.5, function()
					frame.NameFrame.Fadein:Play()
				end)

				frame.MainFrame.TalkingHeadsInAnim:Play()
			end

			if (textFormatted ~= frame.TextFrame.Text:GetText()) then
				-- Fade out the old text and fade in the new text
				frame.TextFrame.Fadeout:Play()
				C_Timer_After(0.25, function()
					frame.TextFrame.Text:SetText(textFormatted)
				end)

				C_Timer_After(0.5, function()
					frame.TextFrame.Fadein:Play()
				end)
			end
		end


		local success, voHandle = PlaySound(vo, "Talking Head", true, true)
		if (success) then
			frame.voHandle = voHandle
		end
	end
end

function Module:OnDataLoad()
	if not KkthnxUIData[playerRealm][playerName].TalkLess then
		KkthnxUIData[playerRealm][playerName].TalkLess = {}
	end

	TalkingHeadFrame_PlayCurrent = KkthnxUI_TalkingHeadFrame_PlayCurrent
end

function Module:OnEnable()
	if C["Misc"].TalkingLessHead ~= true then
		return
	end

	if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		Module:OnDataLoad()
	else
		local forceLoad = CreateFrame("Frame")
		forceLoad:RegisterEvent("PLAYER_ENTERING_WORLD")
		forceLoad:SetScript("OnEvent", function(self, event)
			self:UnregisterEvent(event)
			TalkingHead_LoadUI()
			Module:OnDataLoad()
		end)
	end
end