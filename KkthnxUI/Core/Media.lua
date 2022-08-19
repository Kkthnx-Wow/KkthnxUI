local K, C = unpack(KkthnxUI)

local _G = _G

local CreateFrame = _G.CreateFrame
local KkthnxUIFont = _G.KkthnxUIFont
local KkthnxUIFontOutline = _G.KkthnxUIFontOutline

local KkthnxUIMedia = CreateFrame("Frame", "KKUI_FontStyles")

local shadowOffset = K.Mult or 1

-- Create our own fonts. KkthnxUIFont, KkthnxUIFontOutline is xml based
-- We just adjust them here to follow our format :D

KkthnxUIFont:SetShadowColor(0, 0, 0, 1)
KkthnxUIFont:SetShadowOffset(shadowOffset, -shadowOffset / 2)

KkthnxUIFontOutline:SetShadowColor(0, 0, 0, 0)
KkthnxUIFontOutline:SetShadowOffset(0, -0)

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

function K.GetTexture(texture)
	if TextureTable[texture] then
		return TextureTable[texture]
	else
		return TextureTable["KkthnxUI"] -- Return something to prevent errors
	end
end

function KkthnxUIMedia:RegisterTexture(name, path)
	if not TextureTable[name] then
		TextureTable[name] = path
	end
end

K["TextureTable"] = TextureTable
