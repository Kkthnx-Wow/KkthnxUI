local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G

-- Wow API
local NUM_EXTENDED_UI_FRAMES = NUM_EXTENDED_UI_FRAMES

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent

local function CaptureUpdate()
	if not NUM_EXTENDED_UI_FRAMES then return end
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		local barname = "WorldStateCaptureBar"..i
		local bar = _G[barname]

		if bar and bar:IsVisible() then
			bar:ClearAllPoints()
			if i == 1 then
				bar:SetPoint(unpack(C.Position.CaptureBar))
			else
				bar:SetPoint("TOPLEFT", _G["WorldStateCaptureBar"..i-1], "BOTTOMLEFT", 0, -7)
			end
			if not bar.skinned then
				local left = _G[barname.."LeftBar"]
				local right = _G[barname.."RightBar"]
				local middle = _G[barname.."MiddleBar"]
				select(4, bar:GetRegions()):Hide()
				_G[barname.."LeftLine"]:SetAlpha(0)
				_G[barname.."RightLine"]:SetAlpha(0)
				_G[barname.."LeftIconHighlight"]:SetAlpha(0)
				_G[barname.."RightIconHighlight"]:SetAlpha(0)

				left:SetTexture(C.Media.Texture)
				right:SetTexture(C.Media.Texture)
				middle:SetTexture(C.Media.Texture)

				left:SetVertexColor(0.2, 0.6, 1)
				right:SetVertexColor(0.9, 0.2, 0.2)
				middle:SetVertexColor(0.8, 0.8, 0.8)

				bar.skinned = true
			end
		end
	end
end
hooksecurefunc("UIParent_ManageFramePositions", CaptureUpdate)