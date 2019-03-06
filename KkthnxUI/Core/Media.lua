local K, C = unpack(select(2, ...))

local KkthnxUIMedia = CreateFrame("Frame", "KkthnxUIFonts")

-- Create our own fonts
local KkthnxUIFont = CreateFont("KkthnxUIFont")
KkthnxUIFont:SetFont(C["Media"].Font, 12)
KkthnxUIFont:SetShadowColor(0, 0, 0, 1)
KkthnxUIFont:SetShadowOffset(1.25, -1.25)

local KkthnxUIFontOutline = CreateFont("KkthnxUIFontOutline")
KkthnxUIFontOutline:SetFont(C["Media"].Font, 12, "THINOUTLINE")
KkthnxUIFontOutline:SetShadowColor(0, 0, 0, 0)
KkthnxUIFontOutline:SetShadowOffset(0, -0)

local PTSansNarrowFont = CreateFont("SansNarrowFont")
PTSansNarrowFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\PT_Sans_Narrow.ttf]], 12)
PTSansNarrowFont:SetShadowColor(0, 0, 0, 1)
PTSansNarrowFont:SetShadowOffset(1.25, -1.25)

local PTSansNarrowFontOutline = CreateFont("SansNarrowFontOutline")
PTSansNarrowFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\PT_Sans_Narrow.ttf]], 12, "OUTLINE")
PTSansNarrowFontOutline:SetShadowColor(0, 0, 0, 0)
PTSansNarrowFontOutline:SetShadowOffset(0, -0)

local ExpresswayFont = CreateFont("ExpresswayFont")
ExpresswayFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Expressway.ttf]], 12)
ExpresswayFont:SetShadowColor(0, 0, 0, 1)
ExpresswayFont:SetShadowOffset(1.25, -1.25)

local ExpresswayFontOutline = CreateFont("ExpresswayFontOutline")
ExpresswayFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Expressway.ttf]], 12, "OUTLINE")
ExpresswayFontOutline:SetShadowColor(0, 0, 0, 0)
ExpresswayFontOutline:SetShadowOffset(0, -0)

local TextureTable = {
	["AltzUI"] = C["Media"].AltzUI,
	["AsphyxiaUI"] = C["Media"].AsphyxiaUI,
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
	-- Blizzard Fonts
	["Blizzard"] = "GameFontWhite",
	-- KkthnxUI Fonts
	["KkthnxUI Outline"] = "KkthnxUIFontOutline",
	["KkthnxUI"] = "KkthnxUIFont",
	-- Extra Fonts
	["SansNarrow"] = "SansNarrowFont",
	["SansNarrow Outline"] = "SansNarrowFontOutline",
	["Expressway"] = "ExpresswayFont",
	["Expressway Outline"] = "ExpresswayFontOutline"
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