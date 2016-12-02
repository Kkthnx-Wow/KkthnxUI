local K, C, L = select(2, ...):unpack()

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LevelUpDisplay, BossBanner, hooksecurefunc
local LevelUpBossBanner = CreateFrame("Frame")

local Movers = K.Movers

local Holder = CreateFrame("Frame", "LevelUpBossBannerHolder", UIParent)
Holder:SetSize(200, 20)
Holder:SetPoint("TOP", K.UIParent, "TOP", 0, -120)

function LevelUpBossBanner:Handle_LevelUpDisplay_BossBanner()
  Movers:RegisterFrame(Holder)

	local function Reanchor(frame, _, anchor)
		if anchor ~= Holder then
			frame:ClearAllPoints()
			frame:SetPoint("TOP", Holder)
		end
	end

	--Level Up Display
	LevelUpDisplay:ClearAllPoints()
	LevelUpDisplay:SetPoint("TOP", Holder)
	hooksecurefunc(LevelUpDisplay, "SetPoint", Reanchor)

	--Boss Banner
	BossBanner:ClearAllPoints()
	BossBanner:SetPoint("TOP", Holder)
	hooksecurefunc(BossBanner, "SetPoint", Reanchor)
end

LevelUpBossBanner:RegisterEvent("PLAYER_LOGIN")
LevelUpBossBanner:SetScript("OnEvent", LevelUpBossBanner.Handle_LevelUpDisplay_BossBanner)