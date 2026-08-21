--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/Skin.lua
	Purpose:
		Apply the KkthnxUI border and dark background to the game tooltips, keep
		Blizzard from re-adding its own backdrop, and restyle the pooled bars
		(reputation, quest, item level) Blizzard injects into them.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Tooltip")

local _G = _G
local ipairs = ipairs

-- Apply our border and background to a tooltip once, hiding the stock frame.
local function SkinTooltip(tt)
	if not tt or tt.__kkuiSkinned then
		return
	end
	tt.__kkuiSkinned = true

	if tt.NineSlice then
		tt.NineSlice:SetAlpha(0)
	end
	if tt.SetBackdrop then
		tt:SetBackdrop(nil)
	end

	-- The navy gradient panel, matching the bags and options window instead of a
	-- flat black fill.
	K.CreateGradientBackground(tt, 0.92)
	K.CreateBorder(tt)
end
Module.SkinTooltip = SkinTooltip

local function BarTexture()
	return K.GetTexture(C.Unitframe and C.Unitframe.Texture or "KkthnxUI")
end

-- Skin the pooled bars Blizzard drops into tooltips (reputation, quest, item
-- level requirements). We strip their border/divider art and give them our own
-- texture and backdrop so they match the rest of the tooltip.
local function SkinInsetStatusBar(bar)
	if not bar or bar.__kkuiBar then
		return
	end
	bar.__kkuiBar = true
	local fill = bar:GetStatusBarTexture()
	for _, region in ipairs({ bar:GetRegions() }) do
		if region ~= fill and region.GetObjectType and region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		end
	end
	bar:SetStatusBarTexture(BarTexture())
	K.CreateBackground(bar, 0.1, 0.1, 0.1, 0.9)
	K.CreateBorder(bar)
end

local function SkinInsetProgressBar(progressBar)
	local bar = progressBar and progressBar.Bar
	if not bar or bar.__kkuiBar then
		return
	end
	bar.__kkuiBar = true
	for _, key in ipairs({ "BorderLeft", "BorderRight", "BorderMid", "LeftDivider", "RightDivider" }) do
		if bar[key] then
			bar[key]:SetTexture(nil)
		end
	end
	bar:SetStatusBarTexture(BarTexture())
	K.CreateBackground(bar, 0.1, 0.1, 0.1, 0.9)
	K.CreateBorder(bar)
end

local SKIN_LIST = {
	"GameTooltip",
	"ItemRefTooltip",
	"ItemRefShoppingTooltip1",
	"ItemRefShoppingTooltip2",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"FriendsTooltip",
	"EmbeddedItemTooltip",
	"WorldMapTooltip",
	"GameTooltipTooltip",
	"NamePlateTooltip",
	"BattlePetTooltip",
	"PetBattlePrimaryUnitTooltip",
	"PetBattlePrimaryAbilityTooltip",
	"ReputationParagonTooltip",
	"QuickKeybindTooltip",
	"GameSmallHeaderTooltip",
}

-- Tooltips that live as fields on another frame rather than as globals.
local function SkinNestedTooltips()
	if _G.QuestScrollFrame then
		SkinTooltip(_G.QuestScrollFrame.StoryTooltip)
		SkinTooltip(_G.QuestScrollFrame.CampaignTooltip)
	end
end

function Module:SetupSkins()
	for _, name in ipairs(SKIN_LIST) do
		SkinTooltip(_G[name])
	end
	SkinNestedTooltips()

	-- Keep Blizzard from re-adding its backdrop on shared tooltips.
	if _G.SharedTooltip_SetBackdropStyle then
		hooksecurefunc("SharedTooltip_SetBackdropStyle", function(tt)
			if tt.NineSlice then
				tt.NineSlice:SetAlpha(0)
			end
		end)
	end

	-- Skin the pooled reputation / quest / requirement bars as they are acquired.
	if _G.GameTooltip_ShowStatusBar then
		hooksecurefunc("GameTooltip_ShowStatusBar", function(tt)
			if tt.statusBarPool then
				SkinInsetStatusBar(tt.statusBarPool:GetNextActive())
			end
		end)
	end
	if _G.GameTooltip_ShowProgressBar then
		hooksecurefunc("GameTooltip_ShowProgressBar", function(tt)
			if tt.progressBarPool then
				SkinInsetProgressBar(tt.progressBarPool:GetNextActive())
			end
		end)
	end

	-- Late-created tooltips (some Blizzard addons) get skinned on first show.
	_G.GameTooltip:HookScript("OnShow", function(tt)
		SkinTooltip(tt)
	end)

	-- The client's TooltipComparisonManager:AnchorShoppingTooltips lays the compare
	-- tooltips flush against the main tooltip and each other. Our border sits a few
	-- pixels outside the frame, so add a small gap by post-hooking that function
	-- and nudging only the point that joins the stack to the main tooltip. We keep
	-- Blizzard's own ST1<->ST2 relationship untouched, so there is no anchor cycle.
	local mgr = _G.TooltipComparisonManager
	if mgr and mgr.AnchorShoppingTooltips then
		local GAP = 6
		-- Find the side point that joins this tooltip to the main tooltip (its
		-- relative frame is neither shopping tooltip) and push it out by the gap.
		local function NudgeJoin(tt, st1, st2)
			if not tt then
				return
			end
			for i = 1, tt:GetNumPoints() do
				local point, relTo, relPoint, x, y = tt:GetPoint(i)
				if relTo ~= st1 and relTo ~= st2 then
					if point == "LEFT" and relPoint == "RIGHT" then
						tt:SetPoint("LEFT", relTo, "RIGHT", (x or 0) + GAP, y or 0)
						return
					elseif point == "RIGHT" and relPoint == "LEFT" then
						tt:SetPoint("RIGHT", relTo, "LEFT", (x or 0) - GAP, y or 0)
						return
					end
				end
			end
		end
		hooksecurefunc(mgr, "AnchorShoppingTooltips", function(self)
			local tips = self.tooltip and self.tooltip.shoppingTooltips
			if not tips then
				return
			end
			NudgeJoin(tips[1], tips[1], tips[2])
			NudgeJoin(tips[2], tips[1], tips[2])
		end)
	end
end
