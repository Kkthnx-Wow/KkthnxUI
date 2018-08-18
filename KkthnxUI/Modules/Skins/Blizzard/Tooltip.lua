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
        self:GetParent().Backdrop:SetBackdropBorderColor(r, g, b)
        self:SetTexture("")
    end)

    hooksecurefunc(WorldMapTooltip.ItemTooltip.IconBorder, "Hide", function(self)
        self:GetParent().Backdrop:SetBackdropBorderColor()
    end)

    WorldMapTooltip.ItemTooltip:CreateBackdrop()
    WorldMapTooltip.ItemTooltip.Backdrop:SetOutside(WorldMapTooltip.ItemTooltip.Icon)
     WorldMapTooltip.ItemTooltip.Backdrop:SetFrameLevel(WorldMapTooltip.ItemTooltip:GetFrameLevel())
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

    --local function SetBackdropStyle(self)
    --    if not self or self:IsForbidden() then
    --        return
    --    end

    --    if self.IsSkinned then
    --        self:SetBackdrop(nil)
    --    end
    --end
    --hooksecurefunc("GameTooltip_SetBackdropStyle", SetBackdropStyle)

    local GameTooltip = _G["GameTooltip"]
    local GameTooltipStatusBar = _G["GameTooltipStatusBar"]

    local StoryTooltip = QuestScrollFrame.StoryTooltip
	StoryTooltip:SetFrameLevel(4)

    local WarCampaignTooltip = QuestScrollFrame.WarCampaignTooltip

    local tooltips = {
		GameTooltip,
        ItemRefTooltip,
        ItemRefShoppingTooltip1,
        ItemRefShoppingTooltip2,
        ItemRefShoppingTooltip3,
        AutoCompleteBox,
        FriendsTooltip,
        ShoppingTooltip1,
        ShoppingTooltip2,
        ShoppingTooltip3,
        WorldMapTooltip,
        WorldMapCompareTooltip1,
        WorldMapCompareTooltip2,
        WorldMapCompareTooltip3,
        ReputationParagonTooltip,
        StoryTooltip,
        EmbeddedItemTooltip,
        WarCampaignTooltip,
    }

    for _, tt in pairs(tooltips) do
        tt:SetBackdrop(nil)
        tt.SetBackdrop = K.Noop
        if tt.BackdropFrame then
            tt.BackdropFrame:SetBackdrop(nil)
        end

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

    Module:SecureHook("GameTooltip_ShowStatusBar")
    Module:SecureHook("GameTooltip_UpdateStyle", "SetStyle")

    -- [Backdrop coloring] There has to be a more elegant way of doing this.
	Module:SecureHookScript(GameTooltip, "OnUpdate", "CheckBackdropColor")
end

table_insert(ModuleSkins.SkinFuncs["KkthnxUI"], SkinTooltip)