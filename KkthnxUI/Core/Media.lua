local K, C = unpack(select(2, ...))

local _G = _G

local CreateFont = _G.CreateFont
local CreateFrame = _G.CreateFrame

local KkthnxUIMedia = CreateFrame("Frame", "KkthnxUIFonts")

local s = 1
-- local fontsDB = {normal = {}, outline = {}}
-- local fontPrefix = "KkthnxUI"

-- for i = 10, 100 do
-- 	local fontNormal = _G[fontPrefix.."Font"..i]
-- 	if fontNormal then
-- 		fontsDB.normal[i] = fontNormal
-- 		fontsDB.normal[i]:SetShadowColor(0, 0, 0, 1)
-- 		fontsDB.normal[i]:SetShadowOffset(1, -1 / 2)
-- 	end

-- 	local fontOutline = _G[fontPrefix.."Font"..i.."_Outline"]
-- 	if fontOutline then
-- 		fontsDB.outline[i] = fontOutline
-- 	end
-- end

-- function K.GetFonts(size, outline)
-- 	return fontsDB[outline and "outline" or "normal"][size]
-- end

-- Create our own fonts
local KkthnxUIFont = CreateFont("KkthnxUIFont")
KkthnxUIFont:SetFont(C["Media"].Font, 12)
KkthnxUIFont:SetShadowColor(0, 0, 0, 1)
KkthnxUIFont:SetShadowOffset(s, -s/2)

local KkthnxUIFontOutline = CreateFont("KkthnxUIFontOutline")
KkthnxUIFontOutline:SetFont(C["Media"].Font, 12, "OUTLINE")
KkthnxUIFontOutline:SetShadowColor(0, 0, 0, 0)
KkthnxUIFontOutline:SetShadowOffset(0, -0)

local PTSansNarrowFont = CreateFont("SansNarrowFont")
PTSansNarrowFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\PT_Sans_Narrow.ttf]], 12)
PTSansNarrowFont:SetShadowColor(0, 0, 0, 1)
PTSansNarrowFont:SetShadowOffset(s, -s/2)

local PTSansNarrowFontOutline = CreateFont("SansNarrowFontOutline")
PTSansNarrowFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\PT_Sans_Narrow.ttf]], 12, "OUTLINE")
PTSansNarrowFontOutline:SetShadowColor(0, 0, 0, 0)
PTSansNarrowFontOutline:SetShadowOffset(0, -0)

local ExpresswayFont = CreateFont("ExpresswayFont")
ExpresswayFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Expressway.ttf]], 12)
ExpresswayFont:SetShadowColor(0, 0, 0, 1)
ExpresswayFont:SetShadowOffset(s, -s/2)

local ExpresswayFontOutline = CreateFont("ExpresswayFontOutline")
ExpresswayFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Expressway.ttf]], 12, "OUTLINE")
ExpresswayFontOutline:SetShadowColor(0, 0, 0, 0)
ExpresswayFontOutline:SetShadowOffset(0, -0)

local BlizzardFont = CreateFont("BlizzardFont")
BlizzardFont:SetFont(_G.STANDARD_TEXT_FONT, 12)
BlizzardFont:SetShadowColor(0, 0, 0, 1)
BlizzardFont:SetShadowOffset(s, -s/2)

local BlizzardFontOutline = CreateFont("BlizzardFontOutline")
BlizzardFontOutline:SetFont(_G.STANDARD_TEXT_FONT, 12, "OUTLINE")
BlizzardFontOutline:SetShadowColor(0, 0, 0, 0)
BlizzardFontOutline:SetShadowOffset(0, -0)

local TextureTable = {
	["AltzUI"] = C["Media"].AltzUI,
	["AsphyxiaUI"] = C["Media"].AsphyxiaUI,
	["AzeriteUI"] = C["Media"].AzeriteUI,
	["Blank"] = C["Media"].Blank,
	["DiabolicUI"] = C["Media"].DiabolicUI,
	["Flat"] = C["Media"].FlatTexture,
	["GoldpawUI"] = C["Media"].GoldpawUI,
	["KkthnxUI"] = C["Media"].Texture,
	["SkullFlowerUI"] = C["Media"].SkullFlowerUI,
	["Tukui"] = C["Media"].Tukui,
	["ZorkUI"] = C["Media"].ZorkUI,
}

local FontTable = {
	["Blizzard Outline"] = "BlizzardFontOutline",
	["Blizzard"] = "BlizzardFont",
	["Expressway Outline"] = "ExpresswayFontOutline",
	["Expressway"] = "ExpresswayFont",
	["KkthnxUI Outline"] = "KkthnxUIFontOutline",
	["KkthnxUI"] = "KkthnxUIFont",
	["SansNarrow Outline"] = "SansNarrowFontOutline",
	["SansNarrow"] = "SansNarrowFont",
}

function K.GetFont(font)
	if FontTable[font] then
		return FontTable[font]
	else
		return FontTable["KkthnxUI"] -- Return something to prevent errors
	end
end

function K.GetTexture(texture)
	if TextureTable[texture] then
		return TextureTable[texture]
	else
		return TextureTable["KkthnxUI"] -- Return something to prevent errors
	end
end

function KkthnxUIMedia:RegisterTexture(name, path)
	if (not TextureTable[name]) then
		TextureTable[name] = path
	end
end

function KkthnxUIMedia:RegisterFont(name, path)
	if (not FontTable[name]) then
		FontTable[name] = path
	end
end

K["Media"] = KkthnxUIMedia
K["FontTable"] = FontTable
K["TextureTable"] = TextureTable