--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Centralized media repository and management system.
-- - Design: Handles textures, borders, fonts, and sounds with LibSharedMedia integration.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local mediaFolder = K.MediaFolder

-- ---------------------------------------------------------------------------
-- MEDIA DEFINITIONS
-- ---------------------------------------------------------------------------

-- REASON: Centralized table for all internal media assets. Used for both static
-- references and dynamic GUI population.
C["Media"] = {
	["Sounds"] = {
		KillingBlow = mediaFolder .. "Sounds\\KillingBlow.ogg",
	},
	["Backdrops"] = {
		ColorBackdrop = { 0.060, 0.060, 0.060, 0.9 },
	},
	["Borders"] = {
		AzeriteUIBorder = mediaFolder .. "Border\\AzeriteUI\\Border.tga",
		AzeriteUITooltipBorder = mediaFolder .. "Border\\AzeriteUI\\Border_Tooltip.tga",
		ColorBorder = { 1, 1, 1 },
		GlowBorder = mediaFolder .. "Border\\Border_Glow_Overlay.tga",
		KkthnxUIBorder = mediaFolder .. "Border\\KkthnxUI\\Border.tga",
		KkthnxUITooltipBorder = mediaFolder .. "Border\\KkthnxUI\\Border_Tooltip.tga",
		KkthnxUI_BlankBorder = mediaFolder .. "Border\\KkthnxUI_Blank\\Border.tga",
		KkthnxUI_BlankTooltipBorder = mediaFolder .. "Border\\KkthnxUI_Blank\\Border_Tooltip.tga",
		KkthnxUI_PixelBorder = mediaFolder .. "Border\\KkthnxUI_Pixel\\Border.tga",
		KkthnxUI_PixelTooltipBorder = mediaFolder .. "Border\\KkthnxUI_Pixel\\Border_Tooltip.tga",
	},
	["Textures"] = {
		ArrowTexture = mediaFolder .. "Textures\\Arrow.tga",
		BlankTexture = mediaFolder .. "Textures\\BlankTexture.blp",
		CopyChatTexture = mediaFolder .. "Chat\\Copy.tga",
		GlowTexture = mediaFolder .. "Textures\\GlowTex.tga",
		LogoSmallTexture = mediaFolder .. "Textures\\LogoSmall.tga",
		LogoTexture = mediaFolder .. "Textures\\Logo.tga",
		MouseoverTexture = mediaFolder .. "Textures\\Mouseover.tga",
		NewClassIconsTexture = mediaFolder .. "Unitframes\\NEW-ICONS-CLASSES.blp",
		Spark128Texture = mediaFolder .. "Textures\\Spark_128.tga",
		Spark16Texture = mediaFolder .. "Textures\\Spark_16.tga",
		TargetIndicatorTexture = mediaFolder .. "Nameplates\\TargetIndicatorArrow.blp",
		SkullIcon = mediaFolder .. "Textures\\SkullIcon.tga",
		BagQuestIcon = mediaFolder .. "Textures\\BagQuestIcon.tga",
		QuestIcon = mediaFolder .. "Textures\\QuestIcon.tga",
		ChatBubbleIcon = mediaFolder .. "Textures\\ChatBubbleIcon.tga",
		White8x8Texture = "Interface\\BUTTONS\\WHITE8X8",
		StarIcon = mediaFolder .. "Textures\\StarIcon.tga",
	},
	["Fonts"] = {
		BlankFont = mediaFolder .. "Fonts\\Invisible.ttf",
	},
	["Statusbars"] = {
		AltzUI = mediaFolder .. "Statusbars\\AltzUI.tga",
		AsphyxiaUI = mediaFolder .. "Statusbars\\AsphyxiaUI.tga",
		AzeriteUI = mediaFolder .. "Statusbars\\AzeriteUI.tga",
		Clean = mediaFolder .. "Statusbars\\Clean.tga",
		Flat = mediaFolder .. "Statusbars\\Flat.tga",
		Glamour7 = mediaFolder .. "Statusbars\\Glamour7.tga",
		GoldpawUI = mediaFolder .. "Statusbars\\GoldpawUI.tga",
		KkthnxUI = mediaFolder .. "Statusbars\\Statusbar",
		Kui = mediaFolder .. "Statusbars\\KuiStatusbar.tga",
		KuiBright = mediaFolder .. "Statusbars\\KuiStatusbarBright.tga",
		Ohi_Dragon = mediaFolder .. "Statusbars\\Ohi_Dragon.tga",
		Palooza = mediaFolder .. "Statusbars\\Palooza.tga",
		PinkGradient = mediaFolder .. "Statusbars\\PinkGradient.tga",
		Rain = mediaFolder .. "Statusbars\\Rain.tga",
		SkullFlowerUI = mediaFolder .. "Statusbars\\SkullFlowerUI.tga",
		Tukui = mediaFolder .. "Statusbars\\ElvTukUI.tga",
		WGlass = mediaFolder .. "Statusbars\\Wglass.tga",
		Water = mediaFolder .. "Statusbars\\Water.tga",
		ZorkUI = mediaFolder .. "Statusbars\\ZorkUI.tga",
	},
}

local statusbars = C["Media"].Statusbars
local defaultTexture = statusbars.KkthnxUI

-- ---------------------------------------------------------------------------
-- TEXTURE HELPERS
-- ---------------------------------------------------------------------------

-- REASON: Main accessor for statusbar textures. Prioritizes internal media before
-- falling back to LibSharedMedia or the global default.
function K.GetTexture(texture)
	-- NOTE: Check internal media table first for performance and consistency.
	if statusbars[texture] then
		return statusbars[texture]
	end

	-- NOTE: LibSharedMedia allows users to use textures from other addons/fonts.
	if K.LibSharedMedia then
		local libTexture = K.LibSharedMedia:Fetch("statusbar", texture)
		if libTexture then
			return libTexture
		end
	end

	-- NOTE: Fallback to the primary addon texture to ensure no blank bars.
	return defaultTexture
end

-- ---------------------------------------------------------------------------
-- ENHANCED TEXTURE SYSTEM (GUI)
-- ---------------------------------------------------------------------------

-- REASON: Generates a complete list of textures for use in dropdown menus.
-- Groups internal KkthnxUI textures at the top for better user experience.
function K.GetAllStatusbarTextures()
	local textures = {}

	-- NOTE: Add custom KkthnxUI textures as the primary category.
	for name, path in pairs(C["Media"].Statusbars) do
		table.insert(textures, {
			text = name,
			value = name,
			texture = path,
			isCustom = true,
			category = "KkthnxUI",
		})
	end

	-- NOTE: Import external textures from LibSharedMedia if available.
	if K.LibSharedMedia then
		local sharedMediaTextures = K.LibSharedMedia:List("statusbar")
		for _, textureName in ipairs(sharedMediaTextures) do
			-- PERF: Avoid duplicates if an internal texture has the same name as an external one.
			local isCustom = false
			for _, existingTexture in ipairs(textures) do
				if existingTexture.value == textureName then
					isCustom = true
					break
				end
			end

			if not isCustom then
				table.insert(textures, {
					text = textureName,
					value = textureName,
					texture = K.LibSharedMedia:Fetch("statusbar", textureName),
					isCustom = false,
					category = "LibSharedMedia",
				})
			end
		end
	end

	-- REASON: Sort textures by category (Addon first) and then alphabetically.
	table.sort(textures, function(a, b)
		if a.category ~= b.category then
			if a.category == "KkthnxUI" then
				return true
			elseif b.category == "KkthnxUI" then
				return false
			end
		end
		return a.text < b.text
	end)

	return textures
end

-- REASON: Verifies existence and returns file paths with custom/LSM metadata.
function K.ValidateTexture(textureName)
	-- NOTE: Custom textures are immediate lookups.
	if statusbars[textureName] then
		return statusbars[textureName], true
	end

	-- NOTE: LSM lookups used safely via pcall to catch potential library errors.
	if K.LibSharedMedia then
		local success, texture = pcall(K.LibSharedMedia.Fetch, K.LibSharedMedia, "statusbar", textureName)
		if success and texture then
			return texture, false
		end
	end

	return defaultTexture, true
end

-- NOTE: Wrapper to provide detailed texture metadata for the GUI rendering engine.
function K.GetTextureInfo(textureName)
	local texturePath, isCustom = K.ValidateTexture(textureName)
	return {
		name = textureName,
		path = texturePath,
		isCustom = isCustom,
		category = isCustom and "KkthnxUI" or "LibSharedMedia",
	}
end

-- ---------------------------------------------------------------------------
-- SHAREDMEDIA REGISTRATION
-- ---------------------------------------------------------------------------

-- REASON: Registers internal media with the shared pool so other addons (e.g. WeakAuras)
-- can utilize KkthnxUI's custom assets.
if K.LibSharedMedia then
	for mediaType, mediaTable in pairs(C["Media"]) do
		if mediaType == "Statusbars" then
			for name, path in pairs(mediaTable) do
				K.LibSharedMedia:Register("statusbar", name, path)
			end
			-- NOTE: Other media types (fonts, sounds) are currently registered
			-- locally or as needed to avoid overhead.
		end
	end
end

-- NOTE: Utility function for developers to debug available assets in-game.
function K.PrintAvailableTextures()
	local allTextures = K.GetAllStatusbarTextures()
	print("|cff669DFFKkthnxUI:|r Available Statusbar Textures:")
	for i, textureInfo in ipairs(allTextures) do
		local categoryColor = textureInfo.isCustom and "|cff00ff00" or "|cff00bfff"
		print(string.format("  %d. %s%s|r (%s)", i, categoryColor, textureInfo.text, textureInfo.category))
	end
	print("|cff669DFFKkthnxUI:|r Total textures available:", #allTextures)
end

-- ---------------------------------------------------------------------------
-- ENHANCED BORDER SYSTEM (GUI)
-- ---------------------------------------------------------------------------

-- REASON: Provides the list of supported border styles for the appearance configuration.
function K.GetAllBorderStyles()
	local borders = {}
	local borderStyles = {
		{ name = "KkthnxUI", value = "KkthnxUI", description = "Default KkthnxUI border style" },
		{ name = "AzeriteUI", value = "AzeriteUI", description = "Clean Azerite-inspired border" },
		{ name = "KkthnxUI Blank", value = "KkthnxUI_Blank", description = "Minimal blank border style" },
		{ name = "KkthnxUI Pixel", value = "KkthnxUI_Pixel", description = "Sharp pixel-perfect border" },
	}

	for _, borderInfo in ipairs(borderStyles) do
		table.insert(borders, {
			text = borderInfo.name,
			value = borderInfo.value,
			description = borderInfo.description,
		})
	end

	return borders
end

-- NOTE: Validation helper to ensure selected border options remain valid across updates.
function K.ValidateBorderStyle(borderName)
	local validBorders = { "KkthnxUI", "AzeriteUI", "KkthnxUI_Blank", "KkthnxUI_Pixel" }

	for _, validBorder in ipairs(validBorders) do
		if borderName == validBorder then
			return true
		end
	end

	return false
end

-- REASON: Retrieves full border metadata for display in the configuration tooltips/labels.
function K.GetBorderInfo(borderName)
	local allBorders = K.GetAllBorderStyles()

	for _, borderInfo in ipairs(allBorders) do
		if borderInfo.value == borderName then
			return borderInfo
		end
	end

	-- NOTE: Default to KkthnxUI if specified border is missing or invalid.
	return { name = "KkthnxUI", value = "KkthnxUI", description = "Default KkthnxUI border style" }
end

-- NOTE: Debug helper for border style validation.
function K.PrintAvailableBorders()
	local allBorders = K.GetAllBorderStyles()
	print("|cff669DFFKkthnxUI:|r Available Border Styles:")
	for i, borderInfo in ipairs(allBorders) do
		print(string.format("  %d. |cff00ff00%s|r (%s) - %s", i, borderInfo.text, borderInfo.value, borderInfo.description))
	end
	print("|cff669DFFKkthnxUI:|r Total border styles available:", #allBorders)
end
