local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local ipairs, tremove = ipairs, tremove

function Module:ScaleTalkingHeadFrame()
	local scale = 1
	local TalkingHeadFrame = _G.TalkingHeadFrame
	local width, height = TalkingHeadFrame:GetSize()
    if TalkingHeadFrame.Mover then
	    TalkingHeadFrame.Mover:SetSize(width * scale, height * scale)
    end
	TalkingHeadFrame:SetScale(scale)

	-- Reset Model Camera
	local model = TalkingHeadFrame.MainFrame.Model
	if model.uiCameraID then
		model:RefreshCamera()
		_G.Model_ApplyUICamera(model, model.uiCameraID)
	end

	-- Use this to prevent the frame from auto closing, so you have time to test things.
	-- TalkingHeadFrame:UnregisterEvent('SOUNDKIT_FINISHED')
	-- TalkingHeadFrame:UnregisterEvent('TALKINGHEAD_CLOSE')
	-- TalkingHeadFrame:UnregisterEvent('LOADING_SCREEN_ENABLED')
end

local function InitializeTalkingHead()
	local TalkingHeadFrame = _G.TalkingHeadFrame

	-- Prevent WoW from moving the frame around
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.TalkingHeadFrame = nil

	-- Set default position
	TalkingHeadFrame:ClearAllPoints()
	TalkingHeadFrame:SetPoint("TOP", UIParent, "TOP", -1, -18)

	local scale = 1
	local width, height = TalkingHeadFrame:GetSize()
    if not TalkingHeadFrame.Mover then
		TalkingHeadFrame.Mover = K.Mover(TalkingHeadFrame, "TalkingHeadFrame", "Talking Head Frame", {"TOP", UIParent, "TOP", -1, -18}, width * scale, height * scale)
	else
		TalkingHeadFrame.Mover:SetSize(width * scale, height * scale)
	end
	print(TalkingHeadFrame:GetSize())

	-- Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
	-- We do this to prevent alerts from anchoring to this frame when it is shown.
	for index, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
			tremove(_G.AlertFrame.alertFrameSubSystems, index)
		end
	end
end

local function LoadTalkingHead()
	if not _G.TalkingHeadFrame then
		_G.TalkingHead_LoadUI()
	end

	InitializeTalkingHead()
	Module:ScaleTalkingHeadFrame()
end

function Module:CreateTalkingHeadPosition()
    if C["Misc"].NoTalkingHead then
        return
    end

	if not K.CheckAddOnState("Blizzard_TalkingHeadUI") then
        return
    end

	-- wait until first frame, then load talking head (if it isnt yet) and spawn the mover
	C_Timer.After(1, LoadTalkingHead)
end