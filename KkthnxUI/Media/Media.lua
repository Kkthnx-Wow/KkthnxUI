local K, C = KkthnxUI[1], KkthnxUI[2]

local mediaFolder = K.MediaFolder
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
		White8x8Texture = "Interface\\BUTTONS\\WHITE8X8",
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

function K.GetTexture(texture)
	-- Check if the texture exists in your custom media
	if statusbars[texture] then
		return statusbars[texture]
	end

	-- Check if LibSharedMedia is loaded and has the texture
	if K.LibSharedMedia then
		local libTexture = K.LibSharedMedia:Fetch("statusbar", texture)
		if libTexture then
			return libTexture
		end
	end

	-- Fallback to the default texture if neither are found
	return defaultTexture
end

-- ENHANCED TEXTURE SYSTEM FOR NEW GUI

-- Function to get all available statusbar textures with proper formatting for dropdowns
function K.GetAllStatusbarTextures()
	local textures = {}

	-- First, add all KkthnxUI custom textures
	for name, path in pairs(C["Media"].Statusbars) do
		table.insert(textures, {
			text = name,
			value = name,
			texture = path,
			isCustom = true,
			category = "KkthnxUI",
		})
	end

	-- Then add LibSharedMedia textures (if available)
	if K.LibSharedMedia then
		local sharedMediaTextures = K.LibSharedMedia:List("statusbar")
		for _, textureName in ipairs(sharedMediaTextures) do
			-- Only add if it's not already in our custom textures
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

	-- Sort textures: KkthnxUI first, then LibSharedMedia, then alphabetically within each category
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

-- Function to validate if a texture exists and get its path
function K.ValidateTexture(textureName)
	-- Check custom textures first
	if statusbars[textureName] then
		return statusbars[textureName], true
	end

	-- Check LibSharedMedia
	if K.LibSharedMedia then
		local success, texture = pcall(K.LibSharedMedia.Fetch, K.LibSharedMedia, "statusbar", textureName)
		if success and texture then
			return texture, false
		end
	end

	-- Return default if not found
	return defaultTexture, true
end

-- Function to get texture info for GUI display
function K.GetTextureInfo(textureName)
	local texturePath, isCustom = K.ValidateTexture(textureName)
	return {
		name = textureName,
		path = texturePath,
		isCustom = isCustom,
		category = isCustom and "KkthnxUI" or "LibSharedMedia",
	}
end

-- Register your custom media with LibSharedMedia if it's loaded
if K.LibSharedMedia then
	for mediaType, mediaTable in pairs(C["Media"]) do
		if mediaType == "Statusbars" then
			-- Register statusbar textures
			for name, path in pairs(mediaTable) do
				K.LibSharedMedia:Register("statusbar", name, path)
			end
			-- elseif mediaType == "Fonts" then
			-- 	-- Register fonts
			-- 	for name, path in pairs(mediaTable) do
			-- 		K.LibSharedMedia:Register("font", name, path)
			-- 	end
			-- elseif mediaType == "Sounds" then
			-- 	-- Register sounds
			-- 	for name, path in pairs(mediaTable) do
			-- 		K.LibSharedMedia:Register("sound", name, path)
			-- 	end
		end
	end
end

-- Debug function to print all available textures (useful for testing)
function K.PrintAvailableTextures()
	local allTextures = K.GetAllStatusbarTextures()
	print("|cff669DFFKkthnxUI:|r Available Statusbar Textures:")
	for i, textureInfo in ipairs(allTextures) do
		local categoryColor = textureInfo.isCustom and "|cff00ff00" or "|cff00bfff"
		print(string.format("  %d. %s%s|r (%s)", i, categoryColor, textureInfo.text, textureInfo.category))
	end
	print("|cff669DFFKkthnxUI:|r Total textures available:", #allTextures)
end

-- ENHANCED BORDER SYSTEM FOR NEW GUI

-- Function to get all available border styles with proper formatting for dropdowns
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

-- Function to validate if a border style exists
function K.ValidateBorderStyle(borderName)
	local validBorders = { "KkthnxUI", "AzeriteUI", "KkthnxUI_Blank", "KkthnxUI_Pixel" }

	for _, validBorder in ipairs(validBorders) do
		if borderName == validBorder then
			return true
		end
	end

	return false
end

-- Function to get border info for GUI display
function K.GetBorderInfo(borderName)
	local allBorders = K.GetAllBorderStyles()

	for _, borderInfo in ipairs(allBorders) do
		if borderInfo.value == borderName then
			return borderInfo
		end
	end

	-- Return default if not found
	return { name = "KkthnxUI", value = "KkthnxUI", description = "Default KkthnxUI border style" }
end

-- Debug function to print all available borders (useful for testing)
function K.PrintAvailableBorders()
	local allBorders = K.GetAllBorderStyles()
	print("|cff669DFFKkthnxUI:|r Available Border Styles:")
	for i, borderInfo in ipairs(allBorders) do
		print(string.format("  %d. |cff00ff00%s|r (%s) - %s", i, borderInfo.text, borderInfo.value, borderInfo.description))
	end
	print("|cff669DFFKkthnxUI:|r Total border styles available:", #allBorders)
end
