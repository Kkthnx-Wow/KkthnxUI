local K, C, L = select(2, ...):unpack()

local _G = _G

local Durability = CreateFrame("Frame", nil, UIParent)

local AddHooks = function()
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
end

Durability:RegisterEvent("PLAYER_LOGIN")
Durability:SetScript("OnEvent", AddHooks)
