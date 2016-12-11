local K, C, L = unpack(select(2, ...))

-- WoW Lua
local _G = _G

-- Wow API
local hooksecurefunc = hooksecurefunc

-- GLOBALS: DurabilityFrame, UIParent

local Durability = CreateFrame("Frame", nil, UIParent)
Durability:RegisterEvent("PLAYER_LOGIN")
Durability:SetScript("OnEvent", function(self, event)
	hooksecurefunc(DurabilityFrame, "SetPoint", function(self, _, parent)
		if ((parent == "MinimapCluster") or (parent == _G["MinimapCluster"])) then
			self:ClearAllPoints()

			if (C.ActionBar.BottomBars == 2) then
				self:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 228)
			else
				self:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 200)
			end
		end
	end)
end)
