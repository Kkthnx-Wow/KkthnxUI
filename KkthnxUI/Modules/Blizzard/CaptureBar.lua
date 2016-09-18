local K, C, L, _ = select(2, ...):unpack()
if C.Blizzard.CaptureBar ~= true then return end

local _G = _G
local select = select
local unpack = unpack
local hooksecurefunc = hooksecurefunc

-- Reposition Capture Bar
local function CaptureUpdate()
	if not NUM_EXTENDED_UI_FRAMES then return end
	for i = 1, NUM_EXTENDED_UI_FRAMES do
		local barname = "WorldStateCaptureBar"..i
		local bar = _G[barname]

		if(bar and bar:IsVisible()) then
			bar:ClearAllPoints()
			if i == 1 then
				bar:SetPoint(unpack(C.Position.CaptureBar))
			else
				bar:SetPoint("TOPLEFT", _G["WorldStateCaptureBar"..i - 1], "BOTTOMLEFT", 0, -7)
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

				if not bar.shadow then
					bar.shadow = CreateFrame("Frame", nil, bar)
					bar.shadow:SetFrameLevel(0)
					bar.shadow:SetBackdrop(K.ShadowBackdrop)
					bar.shadow:SetPoint("TOPLEFT", left, -2, 2)
					bar.shadow:SetPoint("BOTTOMRIGHT", right, 2, -2)
					bar.shadow:SetBackdropBorderColor(0, 0, 0, 1)
				end

				bar.skinned = true
			end
		end
	end
end
hooksecurefunc("UIParent_ManageFramePositions", CaptureUpdate)

-- BATTLEFIELD SCORE FRAME
local function StateUpdate()
	if not NUM_ALWAYS_UP_UI_FRAMES then return end
	for i = 1, NUM_ALWAYS_UP_UI_FRAMES do
		local f = _G["AlwaysUpFrame"..i]

		if f then
			f:ClearAllPoints()
			f:SetFrameStrata("BACKGROUND")
			if i == 1 then
				f:SetPoint(unpack(C.Position.Attempt))
			else
				f:SetPoint("TOPLEFT", _G["AlwaysUpFrame"..i-1], "BOTTOMLEFT", 0, 0)
			end
		end
	end
end
hooksecurefunc("WorldStateAlwaysUpFrame_Update", StateUpdate)