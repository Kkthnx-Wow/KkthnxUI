--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Cooldown Viewer (Cooldown Manager).
-- - Design: Hooks CooldownViewerMixin to apply KkthnxUI border and status bar styling.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local ipairs = _G.ipairs
local hooksecurefunc = _G.hooksecurefunc

local CooldownViewerMixin = _G.CooldownViewerMixin
local EssentialCooldownViewer = _G.EssentialCooldownViewer
local UtilityCooldownViewer = _G.UtilityCooldownViewer
local BuffIconCooldownViewer = _G.BuffIconCooldownViewer
local BuffBarCooldownViewer = _G.BuffBarCooldownViewer

local function ReskinCooldownViewerItem(item)
	if not item or item.styled then
		return
	end

	-- REASON: standard square textures for KkthnxUI style.
	local icon = item.Icon
	if icon then
		if icon.SetTexCoord then
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		elseif icon.Icon and icon.Icon.SetTexCoord then
			-- COMPAT: BuffBarItemTemplate uses a Frame named "Icon" containing a Texture named "Icon".
			icon.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		end

		if item.IconMask then
			item.IconMask:Hide()
		elseif icon.IconMask then
			icon.IconMask:Hide()
		end
	end

	-- NOTE: Essential/Utility items have an IconOverlay that doesn't fit the square theme.
	if item.IconOverlay then
		item.IconOverlay:SetAlpha(0)
	end

	-- NOTE: Handle the specific elements via their mixin accessors if they exist.
	local cooldown = item.GetCooldownFrame and item:GetCooldownFrame()
	if cooldown then
		-- NOTE: ActionBars/Cooldown.lua usually handles the text styling for these.
	end

	local chargeCount = item.GetChargeCountFrame and item:GetChargeCountFrame()
	if chargeCount then
		-- Potential font styling for charges
	end

	local applications = item.GetApplicationsFrame and item:GetApplicationsFrame()
	if applications then
		-- Potential font styling for stacks
	end

	local bar = item.GetBarFrame and item:GetBarFrame()
	if bar then
		bar:StripTextures()
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		bar:CreateBorder()
	end

	-- REASON: Consistent border and shadow application.
	item:CreateBorder()

	item.styled = true
end

-- ---------------------------------------------------------------------------
-- BLIZZARD_COOLDOWNVIEWER REGISTRATION
-- ---------------------------------------------------------------------------

-- REASON: Main entry point for Blizzard Cooldown Viewer skinning.
C.themes["Blizzard_CooldownViewer"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- REASON: Standardize the main cooldown viewer frame containers via mixin hook.
	if CooldownViewerMixin then
		hooksecurefunc(CooldownViewerMixin, "OnAcquireItemFrame", function(self, itemFrame)
			ReskinCooldownViewerItem(itemFrame)
		end)
	end

	-- REASON: Catch any already-existing frames if the addon was loaded mid-session.
	local viewers = {
		EssentialCooldownViewer,
		UtilityCooldownViewer,
		BuffIconCooldownViewer,
		BuffBarCooldownViewer,
	}

	for _, viewer in ipairs(viewers) do
		if viewer and viewer.itemFramePool then
			for itemFrame in viewer.itemFramePool:EnumerateActive() do
				ReskinCooldownViewerItem(itemFrame)
			end
		end
	end
end
