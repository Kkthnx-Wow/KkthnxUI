local K = unpack(select(2, ...))
local Module = K:NewModule("DevCore")

local GUI = K["GUI"]

function Module:OnEnable()
	local gui = CreateFrame("Button", "KKUI_GameMenuFrame", GameMenuFrame, "GameMenuButtonTemplate, BackdropTemplate")
	gui:SetText(K.InfoColor.."KkthnxUI|r")
	gui:SetPoint("TOP", GameMenuButtonAddons, "BOTTOM", 0, -21)
	GameMenuFrame:HookScript("OnShow", function(self)
		GameMenuButtonLogout:SetPoint("TOP", gui, "BOTTOM", 0, -21)
		self:SetHeight(self:GetHeight() + gui:GetHeight() + 22)
	end)

	gui:SetScript("OnClick", function()
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
			return
		end

		GUI:Toggle()
		HideUIPanel(GameMenuFrame)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
	end)
end



local function AddTexture(texture)
    return texture and format("|T%s:16:16:0:0:50:50:4:46:4:46|t", texture) or ""
end

local function LandingButton_OnEnter(self)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
    GameTooltip:SetText(self.title, 1, 1, 1);
    GameTooltip:AddLine(self.description, nil, nil, nil, true)

    local covenantID = C_Covenants.GetActiveCovenantID()
    local soulbindID = C_Soulbinds.GetActiveSoulbindID()
    if covenantID > 0 and soulbindID > 0 then
        local soulbindData = C_Soulbinds.GetSoulbindData(soulbindID)

        -- load Soulbinds UI if needed (Blizzard one)
        if not IsAddOnLoaded("Blizzard_Soulbinds") then
            LoadAddOn("Blizzard_Soulbinds")
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(format("|cffFFFFFF%s:|r %s", COVENANT_PREVIEW_SOULBINDS, soulbindData.name), nil, nil, nil, true)

        local nodes = soulbindData.tree.nodes
        local conduits = {}
        local traits = {}

        for _, node in ipairs(nodes) do
            if node.state == Enum.SoulbindNodeState.Selected then
                if node.conduitID and node.conduitID > 0 and node.conduitRank and node.conduitType then
                    tinsert(conduits, {id = node.conduitID, rank = node.conduitRank, type = node.conduitType})
                elseif node.icon and node.spellID and select(1, GetSpellInfo(node.spellID)) then
                    tinsert(traits, {icon = node.icon, spellName = select(1, GetSpellInfo(node.spellID))})
                end
            end
        end

        if next(conduits) then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Conduits", 1, 0.93, 0.73)
            for i = 1, #conduits do
                local name, _, icon = GetSpellInfo(C_Soulbinds.GetConduitSpellID(conduits[i].id, conduits[i].rank))
                local conduitItemLevel = C_Soulbinds.GetConduitCollectionData(conduits[i].id).conduitItemLevel
                local conduitQuality = C_Soulbinds.GetConduitQuality(conduits[i].id, conduits[i].rank)
                local color = ITEM_QUALITY_COLORS[conduitQuality]

                GameTooltip:AddLine(CreateAtlasMarkup(Soulbinds.GetConduitEmblemAtlas(conduits[i].type)).." ["..conduitItemLevel.."]  "..AddTexture(icon).." "..K.RGBToHex(color.r, color.g, color.b)..name.."|r ")
            end
        end

        if next(traits) then
            if #conduits > 0 then GameTooltip:AddLine(" ") end
            GameTooltip:AddLine(GARRISON_TRAITS, 1, 0.93, 0.73)
            for i = 1, #traits do
                GameTooltip:AddLine(AddTexture(traits[i].icon).." "..traits[i].spellName.."|r ")
            end
        end
    end

    GameTooltip:Show()
end
K.LandingButton_OnEnter = LandingButton_OnEnter