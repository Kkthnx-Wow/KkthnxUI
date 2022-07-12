local K = unpack(KkthnxUI)

local _G = _G
local string_format = _G.string.format
local table_insert = _G.table.insert

local COVENANT_PREVIEW_SOULBINDS = _G.COVENANT_PREVIEW_SOULBINDS
local C_Covenants_GetActiveCovenantID = _G.C_Covenants.GetActiveCovenantID
local C_Soulbinds_GetActiveSoulbindID = _G.C_Soulbinds.GetActiveSoulbindID
local C_Soulbinds_GetConduitCollectionData = _G.C_Soulbinds.GetConduitCollectionData
local C_Soulbinds_GetConduitQuality = _G.C_Soulbinds.GetConduitQuality
local C_Soulbinds_GetConduitSpellID = _G.C_Soulbinds.GetConduitSpellID
local C_Soulbinds_GetSoulbindData = _G.C_Soulbinds.GetSoulbindData
local CreateAtlasMarkup = _G.CreateAtlasMarkup
local GameTooltip = _G.GameTooltip
local GetSpellInfo = _G.GetSpellInfo

local function AddTexture(texture)
	return texture and string_format("|T%s:16:16:0:0:50:50:4:46:4:46|t", texture) or ""
end

local function LandingButton_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
	GameTooltip:SetText(self.title, 1, 1, 1)
	GameTooltip:AddLine(self.description, nil, nil, nil, true)

	local covenantID = C_Covenants_GetActiveCovenantID()
	local soulbindID = C_Soulbinds_GetActiveSoulbindID()
	if covenantID > 0 and soulbindID > 0 then
		local soulbindData = C_Soulbinds_GetSoulbindData(soulbindID)

		-- load Soulbinds UI if needed (Blizzard one)
		if not IsAddOnLoaded("Blizzard_Soulbinds") then
			LoadAddOn("Blizzard_Soulbinds")
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(string_format("|cffFFFFFF%s:|r %s", COVENANT_PREVIEW_SOULBINDS, soulbindData.name), nil, nil, nil, true)

		local nodes = soulbindData.tree.nodes
		local conduits = {}
		local traits = {}

		for _, node in ipairs(nodes) do
			if node.state == Enum.SoulbindNodeState.Selected then
				if node.conduitID and node.conduitID > 0 and node.conduitRank and node.conduitType then
					table_insert(conduits, { id = node.conduitID, rank = node.conduitRank, type = node.conduitType })
				elseif node.icon and node.spellID and select(1, GetSpellInfo(node.spellID)) then
					table_insert(traits, { icon = node.icon, spellName = select(1, GetSpellInfo(node.spellID)) })
				end
			end
		end

		if next(conduits) then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Conduits", 1, 0.93, 0.73)
			for i = 1, #conduits do
				local name, _, icon = GetSpellInfo(C_Soulbinds_GetConduitSpellID(conduits[i].id, conduits[i].rank))
				local conduitItemLevel = C_Soulbinds_GetConduitCollectionData(conduits[i].id).conduitItemLevel
				local conduitQuality = C_Soulbinds_GetConduitQuality(conduits[i].id, conduits[i].rank)
				local color = K.QualityColors[conduitQuality]

				GameTooltip:AddLine(
					CreateAtlasMarkup(_G.Soulbinds.GetConduitEmblemAtlas(conduits[i].type))
						.. " ["
						.. conduitItemLevel
						.. "] "
						.. AddTexture(icon)
						.. " "
						.. K.RGBToHex(color.r, color.g, color.b)
						.. name
						.. "|r "
				)
			end
		end

		if next(traits) then
			if #conduits > 0 then
				GameTooltip:AddLine(" ")
			end
			GameTooltip:AddLine(GARRISON_TRAITS, 1, 0.93, 0.73)
			for i = 1, #traits do
				GameTooltip:AddLine(AddTexture(traits[i].icon) .. " " .. traits[i].spellName .. "|r ")
			end
		end
	end

	GameTooltip:Show()
end

K.LandingButton_OnEnter = LandingButton_OnEnter
