local K = unpack(select(2, ...))
local Module = K:NewModule("CaptureBar", "AceEvent-3.0", "AceHook-3.0");

local _G = _G

local hooksecurefunc = _G.hooksecurefunc
local UIParent = _G.UIParent

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: NUM_EXTENDED_UI_FRAMES, hooksecurefunc

local function CaptureUpdate()
	if NUM_EXTENDED_UI_FRAMES then
		local captureBar
		for i = 1, NUM_EXTENDED_UI_FRAMES do
			captureBar = _G["WorldStateCaptureBar" .. i]

			if captureBar and captureBar:IsVisible() then
				captureBar:ClearAllPoints()

				if (i == 1) then
					captureBar:SetPoint("TOP", UIParent, "TOP", 0, -170)
				else
					captureBar:SetPoint("TOPLEFT", _G["WorldStateCaptureBar" .. i - 1], "TOPLEFT", 0, -45)
				end
			end
		end
	end
end

function Module:PositionCaptureBar()
	hooksecurefunc("UIParent_ManageFramePositions", CaptureUpdate)
end

function Module:OnEnable()
	self:PositionCaptureBar()
end
