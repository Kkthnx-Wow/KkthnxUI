--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: When our tooltip icons / quality border are on, suppress Pawn's
--   overlapping corner icons and green upgrade border tint.
-- - Design: PawnRegisterThirdPartyTooltip + post-hook PawnAttachIconToTooltip.
-- - Live: RefreshPawnIntegration on Tooltip.Icons / Tooltip.ClassColor.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

local ipairs = ipairs
local hooksecurefunc = hooksecurefunc
local C_AddOns = C_AddOns

local PAWN_ADDON = "Pawn"
local PAWN_REGISTRY = "KkthnxUI"

-- Tooltips Pawn may attach corner icons to (see PawnToggleTooltipIcons).
local PAWN_ICON_TOOLTIPS = {
	"ItemRefTooltip",
	"ItemRefTooltip2",
	"ItemRefTooltip3",
	"ItemRefTooltip4",
	"ItemRefTooltip5",
	"ShoppingTooltip1",
	"ShoppingTooltip2",
	"ComparisonTooltip1",
	"ComparisonTooltip2",
}

local installed
local pawnRegistered

local function PawnEnabled()
	if C_AddOns.IsAddOnLoaded(PAWN_ADDON) then
		return true
	end
	local name, _, _, enabled = C_AddOns.GetAddOnInfo(PAWN_ADDON)
	return name == PAWN_ADDON and enabled
end

local function ShouldOverrideIcons()
	return C["Tooltip"].Icons
end

-- ClassColor here is the quality-tint border toggle in our GUI.
local function ShouldOverrideBorder()
	return C["Tooltip"].ClassColor
end

local function SetKkthnxBorderColor(tooltip, r, g, b)
	local bg = tooltip and tooltip.bg
	if bg and bg.KKUI_Border then
		bg.KKUI_Border:SetVertexColor(r, g, b)
	end
end

local function HidePawnIconFrame(tooltip)
	if tooltip and tooltip.PawnIconFrame then
		tooltip.PawnIconFrame:Hide()
	end
end

local function HideAllPawnIcons()
	if _G.PawnHideTooltipIcon then
		for i = 1, #PAWN_ICON_TOOLTIPS do
			PawnHideTooltipIcon(PAWN_ICON_TOOLTIPS[i])
		end
		return
	end
	for i = 1, #PAWN_ICON_TOOLTIPS do
		HidePawnIconFrame(_G[PAWN_ICON_TOOLTIPS[i]])
	end
end

local function OnPawnBorderColor(tooltip, r, g, b)
	if not tooltip or tooltip:IsForbidden() then
		return
	end

	if ShouldOverrideBorder() then
		-- Pawn's green upgrade tint — our quality border owns item frames.
		if r == 0 and g == 1 and b == 0 then
			return
		end
	end

	SetKkthnxBorderColor(tooltip, r, g, b)
end

local function OnPawnAttachIcon(tooltip)
	if ShouldOverrideIcons() then
		HidePawnIconFrame(tooltip)
	end
end

local function RegisterPawnTooltip()
	if pawnRegistered or not _G.PawnRegisterThirdPartyTooltip then
		return
	end
	PawnRegisterThirdPartyTooltip(PAWN_REGISTRY, {
		SetBackdropBorderColor = OnPawnBorderColor,
	})
	pawnRegistered = true
end

function Module:RefreshPawnIntegration()
	if not installed then
		return
	end
	if ShouldOverrideIcons() then
		HideAllPawnIcons()
	elseif _G.PawnToggleTooltipIcons then
		PawnToggleTooltipIcons()
	end
end

function Module:SetupPawnIntegration()
	local function Install()
		if installed or not C_AddOns.IsAddOnLoaded(PAWN_ADDON) then
			return
		end
		if not (_G.PawnRegisterThirdPartyTooltip or _G.PawnAttachIconToTooltip) then
			return
		end

		installed = true
		RegisterPawnTooltip()
		if _G.PawnAttachIconToTooltip then
			hooksecurefunc("PawnAttachIconToTooltip", OnPawnAttachIcon)
		end
		Module:RefreshPawnIntegration()
	end

	if C_AddOns.IsAddOnLoaded(PAWN_ADDON) then
		Install()
	else
		Module:RegisterTooltips(PAWN_ADDON, Install)
	end
end

function Module:PawnIsAvailable()
	return PawnEnabled()
end
