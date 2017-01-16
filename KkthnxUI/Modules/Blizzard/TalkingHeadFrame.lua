local K, C, L = unpack(select(2, ...))

local unpack = unpack
local ipairs = ipairs
local table_remove = table.remove

local hooksecurefunc = hooksecurefunc
local IsAddOnLoaded = IsAddOnLoaded

-- No point caching anything here, but list them here for mikk's FindGlobals script
-- GLOBALS: CreateFrame, TalkingHeadFrame, UIPARENT_MANAGED_FRAME_POSITIONS, TalkingHead_LoadUI
-- GLOBALS: Model_ApplyUICamera, AlertFrame

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
    end
    self:UnregisterEvent("ADDON_LOADED")
end)

-- Main script
local SetTalkingHead = CreateFrame("Frame")
SetTalkingHead:RegisterEvent("ADDON_LOADED")
SetTalkingHead:SetScript("OnEvent", function(self, event)
    if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
        self:UnregisterEvent(event)

        local scale = C.Blizzard.TalkingHeadScale or 1

        if scale < 0.5 then
            scale = 0.5
        elseif scale > 2 then
            scale = 2
        end

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

        TalkingHeadFrame.ignoreFramePositionManager = true
        UIPARENT_MANAGED_FRAME_POSITIONS.TalkingHeadFrame = nil

        TalkingHeadFrame:ClearAllPoints()
        TalkingHeadFrame:SetPoint(unpack(C.Position.TalkingHead))

        Movers:RegisterFrame(TalkingHeadFrame)

        -- Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
        -- We do this to prevent alerts from anchoring to this frame when it is shown.
        for index, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
            if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == TalkingHeadFrame then
                table.remove(AlertFrame.alertFrameSubSystems, index)
            end
        end
    else
        TalkingHead_LoadUI()
    end

    -- Use this to prevent the frame from auto closing, so you have time to test things.
    -- TalkingHeadFrame:UnregisterEvent("SOUNDKIT_FINISHED")
    -- TalkingHeadFrame:UnregisterEvent("TALKINGHEAD_CLOSE")
    -- TalkingHeadFrame:UnregisterEvent("LOADING_SCREEN_ENABLED")
end)