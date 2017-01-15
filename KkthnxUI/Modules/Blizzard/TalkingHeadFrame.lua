local K, C, L = unpack(select(2, ...))

local unpack = unpack
local ipairs = ipairs
local table_remove = table.remove

local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded

-- No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: CreateFrame, TalkingHeadFrame, UIPARENT_MANAGED_FRAME_POSITIONS, TalkingHead_LoadUI
-- GLOBALS: Model_ApplyUICamera, AlertFrame, table, hooksecurefunc

local TalkingHead = CreateFrame("Frame")
local Movers = K.Movers

-- Hide TalkingHeadFrame option
local HideTalkingHead = CreateFrame("Frame")
HideTalkingHead:RegisterEvent("ADDON_LOADED")
HideTalkingHead:SetScript("OnEvent", function(self, event, addon)
	if C.Blizzard.HideTalkingHead ~= true then return end
	if addon == "Blizzard_TalkingHeadUI" then
		hooksecurefunc("TalkingHeadFrame_PlayCurrent", function()
			TalkingHeadFrame:Hide()
		end)

		self:UnregisterEvent("ADDON_LOADED")
	end
end)

-- Main script
function TalkingHead:ScaleTalkingHeadFrame()
	local scale = C.Blizzard.TalkingHeadScale or 1

	-- Sanitize
	if scale < 0.5 then
		scale = 0.5
	elseif scale > 2 then
		scale = 2
	end

	-- :SetScale no longer triggers OnSizeChanged in Legion, and as such the mover will not update its size
	-- Calculate dirtyWidth/dirtyHeight based on original size and scale
	-- This way the mover frame will use the right size when we manually trigger "OnSizeChanged"
	local width = TalkingHeadFrame:GetWidth() * scale
	local height = TalkingHeadFrame:GetHeight() * scale
	TalkingHeadFrame.dirtyWidth = width
	TalkingHeadFrame.dirtyHeight = height

	TalkingHeadFrame:SetScale(scale)

	-- Reset Model Camera
	local model = TalkingHeadFrame.MainFrame.Model
	if model.uiCameraID then
		model:RefreshCamera()
		Model_ApplyUICamera(model, model.uiCameraID)
	end
end

function TalkingHead:InitializeTalkingHead()
	-- Prevent WoW from moving the frame around
	TalkingHeadFrame.ignoreFramePositionManager = true
	UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil

	-- Set default position
	TalkingHeadFrame:ClearAllPoints()
	TalkingHeadFrame:SetPoint(unpack(C.Position.TalkingHead))

	Movers:RegisterFrame(TalkingHeadFrame)

	-- Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
	-- We do this to prevent alerts from anchoring to this frame when it is shown.
	for index, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
		if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
			table_remove(AlertFrame.alertFrameSubSystems, index)
		end
	end
end

if C.Blizzard.HideTalkingHead ~= true then
	if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
		TalkingHead:UnregisterEvent("PLAYER_ENTERING_WORLD")
		TalkingHead:InitializeTalkingHead()
		TalkingHead:ScaleTalkingHeadFrame()
	else
		TalkingHead:RegisterEvent("PLAYER_ENTERING_WORLD")
		TalkingHead_LoadUI()
		TalkingHead:InitializeTalkingHead()
		TalkingHead:ScaleTalkingHeadFrame()
	end
end