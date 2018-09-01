local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local table_insert = table.insert

local function SkinFactionbarTextures()
	local function UpdateFactionbarTextures()
		for i = 1, GetNumFactions() do
			local statusbar = _G["ReputationBar"..i.."ReputationBar"]
			local factionTexture = K.GetTexture(C["Skins"].Texture)

			if statusbar then
				statusbar:SetStatusBarTexture(factionTexture)
			end
		end
	end

	ReputationFrame:HookScript("OnShow", UpdateFactionbarTextures)
	hooksecurefunc("ExpandFactionHeader", UpdateFactionbarTextures)
	hooksecurefunc("CollapseFactionHeader", UpdateFactionbarTextures)
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinFactionbarTextures)