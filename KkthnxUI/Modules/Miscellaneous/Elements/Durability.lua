local K = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

function Module:CreateDurabilityFrame()
	local DurabilityFrame = _G.DurabilityFrame

	DurabilityFrame:SetFrameStrata("HIGH")

	local function SetPosition(_, _, parent)
		if (parent == "MinimapCluster") or (parent == _G["MinimapCluster"]) then
			DurabilityFrame:ClearAllPoints()
			DurabilityFrame:SetPoint("RIGHT", Minimap, "RIGHT")
			DurabilityFrame:SetScale(0.6)
		end
	end

	hooksecurefunc(DurabilityFrame, "SetPoint", SetPosition)
end