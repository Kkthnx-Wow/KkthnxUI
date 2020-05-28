local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

-- Lua API
local _G = _G
local ipairs = _G.ipairs
local table_remove = _G.table.remove

-- WoW Objects
local UIParent = _G.UIParent
local IsAddOnLoaded = _G.IsAddOnLoaded

local function InitializeTalkingHead()
	local TalkingHeadFrame = _G.TalkingHeadFrame

	-- Prevent WoW from moving the frame around
	TalkingHeadFrame.ignoreFramePositionManager = true
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.TalkingHeadFrame = nil

	-- Set default position
	TalkingHeadFrame:ClearAllPoints()
	TalkingHeadFrame:SetPoint("TOP", UIParent, "TOP", 0, -18)

	K.Mover(TalkingHeadFrame, "Talking Head Frame", "Talking Head Frame", {"TOP", UIParent, "TOP", 0, -18})

	-- Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
	-- We do this to prevent alerts from anchoring to this frame when it is shown.
	for index, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
			table_remove(_G.AlertFrame.alertFrameSubSystems, index)
		end
	end
end

function Module:CreateTalkingHeadFrame()
	if K.CheckAddOnState("Immersion") or C["Misc"].NoTalkingHead then
		return
	end

	if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		InitializeTalkingHead()
	else --We want the mover to be available immediately, so we load it ourselves
		local f = CreateFrame("Frame")
		f:RegisterEvent("PLAYER_ENTERING_WORLD")
		f:SetScript("OnEvent", function(frame, event)
			frame:UnregisterEvent(event)
			_G.TalkingHead_LoadUI()
			InitializeTalkingHead()
		end)
	end
end