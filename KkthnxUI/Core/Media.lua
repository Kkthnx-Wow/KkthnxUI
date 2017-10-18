local K, C = unpack(select(2, ...))

local KkthnxUIMedia = CreateFrame("Frame")

-- Create our own fonts
local KkthnxUIFont = CreateFont("KkthnxUIFont")
KkthnxUIFont:SetFont(C["Media"].Font, 12, "")
KkthnxUIFont:SetShadowColor(0, 0, 0, 1)
KkthnxUIFont:SetShadowOffset(1.25, -1.25)

local KkthnxUIFontOutline = CreateFont("KkthnxUIFontOutline")
KkthnxUIFontOutline:SetFont(C["Media"].Font, 12, "OUTLINE")
KkthnxUIFontOutline:SetShadowColor(0, 0, 0, 0)
KkthnxUIFontOutline:SetShadowOffset(0, -0)

local TextureTable = {
	["Blank Texture"] = C["Media"].Blank,
	["KkthnxUI Texture"] = C["Media"].Texture,
}

local FontTable = {
	-- Blizzard Fonts
	["Blizzard Font"] = "GameFontWhite",
	-- KkthnxUI Fonts
	["KkthnxUI Font Outline"] = "KkthnxUIFontOutline",
	["KkthnxUI Font"] = "KkthnxUIFont",
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