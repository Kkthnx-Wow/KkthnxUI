local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

-- Lua API
local _G = _G
local ipairs = _G.ipairs
local table_remove = _G.table.remove

-- WoW Objects
local UIParent = _G.UIParent
local UIPARENT_MANAGED_FRAME_POSITIONS = _G.UIPARENT_MANAGED_FRAME_POSITIONS

function Module:InitializeTalkingHead()
	local content = _G.TalkingHeadFrame

	-- This means the addon hasn't been loaded,
	-- so we register a listener and return.
	if (not content) then
		return K:RegisterEvent("ADDON_LOADED", Module.WaitForTalkingHead)
	end

	-- Put the actual talking head into our /moverui holder
	content:ClearAllPoints()
	content:SetPoint("BOTTOM", Module.frame, "BOTTOM", 0, 0)
	content.ignoreFramePositionManager = true

	-- Kill off Blizzard's repositioning
	UIParent:UnregisterEvent("TALKINGHEAD_REQUESTED")
	UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil

	-- Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
	-- We do this to prevent alerts from anchoring to this frame when it is shown.
	local AlertFrame = _G.AlertFrame
	for index, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		if (alertFrameSubSystem.anchorFrame and (alertFrameSubSystem.anchorFrame == content)) then
			table_remove(AlertFrame.alertFrameSubSystems, index)
		end
	end
end

function Module:WaitForTalkingHead(_, ...)
	local addon = ...
	if (addon ~= "Blizzard_TalkingHeadUI") then
		return
	end

	Module:InitializeTalkingHead()
	K:UnregisterEvent("ADDON_LOADED", Module.WaitForTalkingHead)
end

function Module:CreateTalkingHeadFrame()
	if K.CheckAddOnState("Immersion") or C["Misc"].NoTalkingHead then
		return
	end

	-- Create our container frame
	Module.frame = CreateFrame("Frame", "KKUITalkingHeadMover", UIParent)
	Module.frame:SetPoint("TOP", UIParent, "TOP", 0, -18)
	Module.frame:SetSize(570, 155)

	K.Mover(Module.frame, "TalkingHeadFrame", "TalkingHeadFrame", {"TOP", UIParent, "TOP", 0, -18}, 570, 155)
end