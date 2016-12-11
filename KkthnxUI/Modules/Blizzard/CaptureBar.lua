local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G

-- Wow API
local NUM_EXTENDED_UI_FRAMES = NUM_EXTENDED_UI_FRAMES

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent

local function CaptureUpdate()
	local Frames = NUM_EXTENDED_UI_FRAMES

	if Frames then
		for i = 1, NUM_EXTENDED_UI_FRAMES do
			local Bar = _G["WorldStateCaptureBar" .. i]

			if Bar and Bar:IsVisible() then
				Bar:ClearAllPoints()

				if (i == 1) then
					Bar:SetPoint("TOP", UIParent, "TOP", 0, -120)
				else
					Bar:SetPoint("TOPLEFT", _G["WorldStateCaptureBar" .. i - 1], "TOPLEFT", 0, -25)
				end
			end
		end
	end
end

hooksecurefunc("UIParent_ManageFramePositions", CaptureUpdate)