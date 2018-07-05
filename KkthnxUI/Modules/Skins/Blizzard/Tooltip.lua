local K, C = unpack(select(2, ...))
local ModuleSkins = K:GetModule("Skins")
local Module = K:GetModule("Tooltip")

local _G = _G
local unpack = unpack
local pairs = pairs
local table_insert = table.insert

local hooksecurefunc = hooksecurefunc

local function SkinTooltip()
    if C["Tooltip"].Enable ~= true then
        return
    end

    local GameTooltipStatusBarTexture = K.GetTexture(C["Tooltip"].Texture)

    ItemRefCloseButton:SkinCloseButton()

    -- World Quest Reward Icon
    WorldMapTooltip.ItemTooltip.Icon:SetTexCoord(unpack(K.TexCoords))
    hooksecurefunc(WorldMapTooltip.ItemTooltip.IconBorder, "SetVertexColor", function(self, r, g, b)
        self:GetParent().Borders:SetBackdropBorderColor(r, g, b)
        self:SetTexture("")
    end)

    hooksecurefunc(WorldMapTooltip.ItemTooltip.IconBorder, "Hide", function(self)
        self:GetParent().Borders:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
    end)

    WorldMapTooltip.ItemTooltip.Backgrounds = WorldMapTooltip.ItemTooltip:CreateTexture(nil, "BACKGROUND", -1)
    WorldMapTooltip.ItemTooltip.Backgrounds:SetOutside(WorldMapTooltip.ItemTooltip.Icon)
	WorldMapTooltip.ItemTooltip.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	WorldMapTooltip.ItemTooltip.Borders = CreateFrame("Frame", nil, WorldMapTooltip.ItemTooltip)
	WorldMapTooltip.ItemTooltip.Borders:SetOutside(WorldMapTooltip.ItemTooltip.Icon)
	K.CreateBorder(WorldMapTooltip.ItemTooltip.Borders)

    WorldMapTooltip.ItemTooltip.Count:ClearAllPoints()
    WorldMapTooltip.ItemTooltip.Count:SetPoint("BOTTOMRIGHT", WorldMapTooltip.ItemTooltip.Icon, "BOTTOMRIGHT", 1, 0)

    local function QuestRewardsBarColor(tooltip, questID)
        if not tooltip or not questID then
            return
        end

        local name, cur, max, sb, _ = tooltip.GetName and tooltip:GetName()
        if name and name == "WorldMapTooltip" then
            name = "WorldMapTaskTooltip"
        end

        sb = name and _G[name .. "StatusBar"]
        if not sb then
            return
        end

        if sb.Bar and sb.Bar.GetValue then
            cur = sb.Bar:GetValue()
            if cur then
                if sb.Bar.GetMinMaxValues then
                    _, max = sb.Bar:GetMinMaxValues()
                end

                ModuleSkins:StatusBarColorGradient(sb.Bar, cur, max)
            end
        end
    end
    hooksecurefunc("GameTooltip_AddQuestRewardsToTooltip", QuestRewardsBarColor)

    local GameTooltip = _G["GameTooltip"]
    local GameTooltipStatusBar = _G["GameTooltipStatusBar"]

    local tooltips = {
        AutoCompleteBox,
        FriendsTooltip,
        GameTooltip,
        ItemRefShoppingTooltip1,
        ItemRefShoppingTooltip2,
        ItemRefShoppingTooltip3,
        ItemRefTooltip,
        ShoppingTooltip1,
        ShoppingTooltip2,
        ShoppingTooltip3,
        WorldMapCompareTooltip1,
        WorldMapCompareTooltip2,
        WorldMapCompareTooltip3,
        WorldMapTooltip
    }

    for _, tt in pairs(tooltips) do
        Module:SecureHookScript(tt, "OnShow", "SetStyle")
    end

    GameTooltipStatusBar:SetStatusBarTexture(GameTooltipStatusBarTexture)
    GameTooltipStatusBar:CreateShadow()
    GameTooltipStatusBar:ClearAllPoints()
    GameTooltipStatusBar:SetPoint("BOTTOMLEFT", GameTooltip, "TOPLEFT", 1, 6)
    GameTooltipStatusBar:SetPoint("BOTTOMRIGHT", GameTooltip, "TOPRIGHT", -1, 6)

    GameTooltipStatusBar.Background = GameTooltipStatusBar:CreateTexture(nil, "BACKGROUND", -1)
	GameTooltipStatusBar.Background:SetAllPoints()
    GameTooltipStatusBar.Background:SetColorTexture(C["Media"].BackdropColor[1],C["Media"].BackdropColor[2],C["Media"].BackdropColor[3],C["Media"].BackdropColor[4])

    Module:SecureHook("GameTooltip_ShowStatusBar", "GameTooltip_ShowStatusBar")
    Module:SecureHookScript(GameTooltip, "OnSizeChanged", "CheckBackdropColor")
    Module:SecureHookScript(GameTooltip, "OnUpdate", "CheckBackdropColor")
    Module:RegisterEvent("CURSOR_UPDATE", "CheckBackdropColor")
end

table_insert(ModuleSkins.SkinFuncs["KkthnxUI"], SkinTooltip)