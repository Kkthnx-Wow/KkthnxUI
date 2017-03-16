local K, C, L = unpack(select(2, ...))

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
local function TalkingHead_Init()
	if not isInit then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_TalkingHeadUI") then
			isLoaded = LoadAddOn("Blizzard_TalkingHeadUI")
		end

		if isLoaded then
			TalkingHeadFrame.ignoreFramePositionManager = true
			UIPARENT_MANAGED_FRAME_POSITIONS["TalkingHeadFrame"] = nil

			for i, subSystem in pairs(AlertFrame.alertFrameSubSystems) do
				if subSystem.anchorFrame and subSystem.anchorFrame == TalkingHeadFrame then
					table.remove(AlertFrame.alertFrameSubSystems, i)
				end
			end

			TalkingHeadFrame:ClearAllPoints()
			TalkingHeadFrame:SetPoint(unpack(C.Position.TalkingHead))
			Movers:RegisterFrame(TalkingHeadFrame)

			TalkingHeadFrame:SetScale(C.Blizzard.TalkingHeadScale or 1)

			isInit = true

			return true
		end
	end
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", TalkingHead_Init)