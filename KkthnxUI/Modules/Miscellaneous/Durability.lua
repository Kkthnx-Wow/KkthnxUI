local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DurabilityFrame")

local _G = _G

function Module:PositionDurabilityFrame()
	DurabilityFrame:SetFrameStrata("HIGH")

	local function SetPosition(self, _, parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			DurabilityFrame:ClearAllPoints()
			DurabilityFrame:SetPoint("RIGHT", Minimap, "RIGHT")
			DurabilityFrame:SetScale(0.6)
		end
	end

	hooksecurefunc(DurabilityFrame, "SetPoint", SetPosition)
end

function Module:OnEnable()
	self:PositionDurabilityFrame()
end
