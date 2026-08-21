--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/Anchor.lua
	Purpose:
		A movable anchor for the default tooltip position, set in the Move UI
		screen like every other frame, plus the cursor-anchor and hide-in-combat
		options.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Tooltip")

function Module:SetupAnchor()
	-- Blizzard re-anchors GameTooltip on each show, so we re-point it to the
	-- anchor in the SetDefaultAnchor hook rather than attaching it once.
	local anchor = CreateFrame("Frame", "KKUI_TooltipAnchor", UIParent)
	anchor:SetSize(130, 34)
	self.anchor = anchor

	-- The bag bar module loads after the tooltip, so pin the mover once it exists:
	-- 6px left of the bag bar (whose bottom already sits 6px above the micro menu),
	-- falling back to the corner. Deferred so KKUI_BagBar is created first.
	C_Timer.After(1, function()
		local bagbar = _G.KKUI_BagBar
		local point = bagbar and { "BOTTOMRIGHT", bagbar, "BOTTOMLEFT", -6, 0 } or { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -220, 240 }
		K.CreateMover(anchor, "GameTooltip", L["Tooltip"], point, 130, 34)
	end)

	hooksecurefunc("GameTooltip_SetDefaultAnchor", function(tt, parent)
		if C.Tooltip.HideInCombat and InCombatLockdown() then
			tt:Hide()
			return
		end
		if C.Tooltip.CursorAnchor then
			tt:SetOwner(parent, "ANCHOR_CURSOR")
		else
			tt:SetOwner(parent, "ANCHOR_NONE")
			tt:ClearAllPoints()
			tt:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
		end
	end)
end
