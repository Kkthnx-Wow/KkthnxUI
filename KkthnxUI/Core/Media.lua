local K, C = unpack(select(2, ...))

local KkthnxUIMedia = CreateFrame("Frame", "KkthnxUIFonts")

-- Create our own fonts
local KkthnxUIFont = CreateFont("KkthnxUIFont")
KkthnxUIFont:SetFont(C["Media"].Font, 12)
KkthnxUIFont:SetShadowColor(0, 0, 0, 1)
KkthnxUIFont:SetShadowOffset(1.25, -1.25)

local KkthnxUIFontOutline = CreateFont("KkthnxUIFontOutline")
KkthnxUIFontOutline:SetFont(C["Media"].Font, 12, "OUTLINE")
KkthnxUIFontOutline:SetShadowColor(0, 0, 0, 0)
KkthnxUIFontOutline:SetShadowOffset(0, -0)

local PTSansNarrowFont = CreateFont("PTSansNarrowFont")
PTSansNarrowFont:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\PT_Sans_Narrow.ttf]], 12)
PTSansNarrowFont:SetShadowColor(0, 0, 0, 1)
PTSansNarrowFont:SetShadowOffset(1.25, -1.25)

local PTSansNarrowFontOutline = CreateFont("PTSansNarrowFontOutline")
PTSansNarrowFontOutline:SetFont([[Interface\AddOns\KkthnxUI\Media\Fonts\PT_Sans_Narrow.ttf]], 12, "OUTLINE")
PTSansNarrowFontOutline:SetShadowColor(0, 0, 0, 0)
PTSansNarrowFontOutline:SetShadowOffset(0, -0)

local TextureTable = {
	["Blank"] = C["Media"].Blank,
	["DiabolicUI"] = C["Media"].DiabolicUI,
	["Flat"] = C["Media"].FlatTexture,
	["KkthnxUI"] = C["Media"].Texture,
	["Tukui"] = C["Media"].Tukui,
}

local FontTable = {
	-- Blizzard Fonts
	["Blizzard"] = "GameFontWhite",
	-- KkthnxUI Fonts
	["KkthnxUI Outline"] = "KkthnxUIFontOutline",
	["KkthnxUI"] = "KkthnxUIFont",
	-- Extra Fonts
	["Sans Narrow"] = "PTSansNarrowFont",
	["Sans Narrow Outline"] = "PTSansNarrowFontOutline",
}

function K.GetFont(font)
	if FontTable[font] then
		return FontTable[font]
	else
		return FontTable["KkthnxUI Font"] -- Return something to prevent errors
	end
end

function K.GetTexture(texture)
	if TextureTable[texture] then
		return TextureTable[texture]
	else
		return TextureTable["KkthnxUI Texture"] -- Return something to prevent errors
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