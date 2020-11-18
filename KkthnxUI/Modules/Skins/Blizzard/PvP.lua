local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function SkinPvP()
	local HonorFrame = _G["HonorFrame"]
	local ConquestFrame = _G["ConquestFrame"]
	local pvpTexture = K.GetTexture(C["UITextures"].SkinTextures)
	local isAlliance = _G.UnitFactionGroup("player") == "Alliance"

	-- Honor Frame StatusBar
	local HFCB = HonorFrame.ConquestBar
	if HFCB then
		HFCB:SetStatusBarTexture(pvpTexture)
		if (isAlliance) then
			HFCB:SetStatusBarColor(74/255, 84/255, 232/255)
		else
			HFCB:SetStatusBarColor(229/255, 13/255, 18/255)
		end
	end

	-- Conquest Frame StatusBar
	local CFCB = ConquestFrame.ConquestBar
	if CFCB then
		CFCB:SetStatusBarTexture(pvpTexture)
		if (isAlliance) then
			CFCB:SetStatusBarColor(74/255, 84/255, 232/255)
		else
			CFCB:SetStatusBarColor(229/255, 13/255, 18/255)
		end
	end
end

-- Module.NewSkin["Blizzard_PVPUI"] = SkinPvP