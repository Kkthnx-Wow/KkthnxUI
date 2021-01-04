local K, C = unpack(select(2, ...))

local _G = _G

local CreateFont = _G.CreateFont
local CreateFrame = _G.CreateFrame

local KkthnxUIMedia = CreateFrame("Frame", "KKUI_Fonts")

local shadowOffset = K.Mult or 1
local fontSize = 12

-- Create our own fonts
local KkthnxUIFont = CreateFont("KkthnxUIFont")
KkthnxUIFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]], fontSize, "")
KkthnxUIFont:SetShadowColor(0, 0, 0, 1)
KkthnxUIFont:SetShadowOffset(shadowOffset, -shadowOffset / 2)

local KkthnxUIFontOutline = CreateFont("KkthnxUIFontOutline")
KkthnxUIFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]], fontSize, "OUTLINE")
KkthnxUIFontOutline:SetShadowColor(0, 0, 0, 0)
KkthnxUIFontOutline:SetShadowOffset(0, -0)

local PTSansNarrowFont = CreateFont("SansNarrowFont")
PTSansNarrowFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\PT_Sans_Narrow.ttf]], fontSize, "")
PTSansNarrowFont:SetShadowColor(0, 0, 0, 1)
PTSansNarrowFont:SetShadowOffset(shadowOffset, -shadowOffset / 2)

local PTSansNarrowFontOutline = CreateFont("SansNarrowFontOutline")
PTSansNarrowFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\PT_Sans_Narrow.ttf]], fontSize, "OUTLINE")
PTSansNarrowFontOutline:SetShadowColor(0, 0, 0, 0)
PTSansNarrowFontOutline:SetShadowOffset(0, -0)

local ExpresswayFont = CreateFont("ExpresswayFont")
ExpresswayFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Expressway.ttf]], fontSize, "")
ExpresswayFont:SetShadowColor(0, 0, 0, 1)
ExpresswayFont:SetShadowOffset(shadowOffset, -shadowOffset / 2)

local ExpresswayFontOutline = CreateFont("ExpresswayFontOutline")
ExpresswayFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Expressway.ttf]], fontSize, "OUTLINE")
ExpresswayFontOutline:SetShadowColor(0, 0, 0, 0)
ExpresswayFontOutline:SetShadowOffset(0, -0)

local FuturaFont = CreateFont("FuturaFont")
FuturaFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Futura_Medium_BT.ttf]], fontSize, "")
FuturaFont:SetShadowColor(0, 0, 0, 1)
FuturaFont:SetShadowOffset(shadowOffset, -shadowOffset/2)

local FuturaFontOutline = CreateFont("FuturaFontOutline")
FuturaFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\Futura_Medium_BT.ttf]], fontSize, "OUTLINE")
FuturaFontOutline:SetShadowColor(0, 0, 0, 0)
FuturaFontOutline:SetShadowOffset(0, -0)

local BlizzardFont = CreateFont("BlizzardFont")
BlizzardFont:SetFont(_G.STANDARD_TEXT_FONT, fontSize, "")
BlizzardFont:SetShadowColor(0, 0, 0, 1)
BlizzardFont:SetShadowOffset(shadowOffset, -shadowOffset/2)

local BlizzardFontOutline = CreateFont("BlizzardFontOutline")
BlizzardFontOutline:SetFont(_G.STANDARD_TEXT_FONT, fontSize, "OUTLINE")
BlizzardFontOutline:SetShadowColor(0, 0, 0, 0)
BlizzardFontOutline:SetShadowOffset(0, -0)

local TextureTable = {
	["AltzUI"] = C["Media"].Statusbars.AltzUIStatusbar,
	["AsphyxiaUI"] = C["Media"].Statusbars.AsphyxiaUIStatusbar,
	["AzeriteUI"] = C["Media"].Statusbars.AzeriteUIStatusbar,
	["Blank"] = C["Media"].Statusbars.Blank,
	["DiabolicUI"] = C["Media"].Statusbars.DiabolicUIStatusbar,
	["Flat"] = C["Media"].Statusbars.FlatStatusbar,
	["GoldpawUI"] = C["Media"].Statusbars.GoldpawUIStatusbar,
	["KkthnxUI"] = C["Media"].Statusbars.KkthnxUIStatusbar,
	["Palooza"] = C["Media"].Statusbars.PaloozaStatusbar,
	["SkullFlowerUI"] = C["Media"].Statusbars.SkullFlowerUIStatusbar,
	["Tukui"] = C["Media"].Statusbars.TukuiStatusbar,
	["ZorkUI"] = C["Media"].Statusbars.ZorkUIStatusbar,
}

local FontTable = {
	["Blizzard Outline"] = "BlizzardFontOutline",
	["Blizzard"] = "BlizzardFont",
	["Expressway Outline"] = "ExpresswayFontOutline",
	["Expressway"] = "ExpresswayFont",
	["Futura Outline"] = "FuturaFontOutline",
	["Futura"] = "FuturaFont",
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