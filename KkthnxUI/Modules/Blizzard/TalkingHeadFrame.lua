local K, C = unpack(select(2, ...))
local TalkingHead = K:NewModule("TalkingHead")

local _G = _G
local ipairs = ipairs
local unpack = unpack

local IsAddOnLoaded = _G.IsAddOnLoaded
local LoadAddOn = _G.LoadAddOn

-- No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: CreateFrame, TalkingHeadFrame, UIPARENT_MANAGED_FRAME_POSITIONS, TalkingHead_LoadUI
-- GLOBALS: Model_ApplyUICamera, AlertFrame

local Movers = K.Movers
local isInit = false

-- We set our TalkingHeadFrame scale and position here.
function TalkingHead:OnEnable()
	if not isInit then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_TalkingHeadUI") then
			isLoaded = LoadAddOn("Blizzard_TalkingHeadUI")
		end

		if isLoaded then
			local frameScale = C["General"].TalkingHeadScale or 1
			local frameAlpha = C["General"].TalkingHeadAlpha or 0.75

			-- Sanitize
			if frameScale < 0.5 then
				frameScale = 0.5
			elseif frameScale > 2 then
				frameScale = 2
			end

			-- Calculate dirtyWidth/dirtyHeight based on original size and scale
			-- This way the mover frame will use the right size when we manually trigger "OnSizeChanged"
			local FrameWidth = TalkingHeadFrame:GetWidth() * frameScale
			local FrameHeight = TalkingHeadFrame:GetHeight() * frameScale
			TalkingHeadFrame.dirtyWidth = FrameWidth
			TalkingHeadFrame.dirtyHeight = FrameHeight

			TalkingHeadFrame.ignoreFramePositionManager = true
			UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil

			for i, subSystem in pairs(AlertFrame.alertFrameSubSystems) do
				if subSystem.anchorFrame and subSystem.anchorFrame == TalkingHeadFrame then
					table.remove(AlertFrame.alertFrameSubSystems, i)
				end
			end

			TalkingHeadFrame:ClearAllPoints()
			TalkingHeadFrame:SetPoint(C.Position.TalkingHead[1], C.Position.TalkingHead[2], C.Position.TalkingHead[3], C.Position.TalkingHead[4], C.Position.TalkingHead[5])
			TalkingHeadFrame:SetScale(frameScale)
			TalkingHeadFrame:SetAlpha(frameAlpha)

			Movers:RegisterFrame(TalkingHeadFrame)

			isInit = true

			return true
		end
	end
end