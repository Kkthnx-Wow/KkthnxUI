local K, C = unpack(KkthnxUI)

K.TextureTable = {
	["AltzUI"] = C["Media"].Statusbars.AltzUIStatusbar,
	["AsphyxiaUI"] = C["Media"].Statusbars.AsphyxiaUIStatusbar,
	["AzeriteUI"] = C["Media"].Statusbars.AzeriteUIStatusbar,
	["Blank"] = C["Media"].Statusbars.Blank,
	["Clean"] = C["Media"].Statusbars.CleanStatusbar,
	["Flat"] = C["Media"].Statusbars.FlatStatusbar,
	["Glamour7"] = C["Media"].Statusbars.Glamour7Statusbar,
	["GoldpawUI"] = C["Media"].Statusbars.GoldpawUIStatusbar,
	["KkthnxUI"] = C["Media"].Statusbars.KkthnxUIStatusbar,
	["Palooza"] = C["Media"].Statusbars.PaloozaStatusbar,
	["PinkGradient"] = C["Media"].Statusbars.PinkGradientStatusbar,
	["Rain"] = C["Media"].Statusbars.RainStatusbar,
	["SkullFlowerUI"] = C["Media"].Statusbars.SkullFlowerUIStatusbar,
	["Tukui"] = C["Media"].Statusbars.TukuiStatusbar,
	["Water"] = C["Media"].Statusbars.WaterStatusbar,
	["Wglass"] = C["Media"].Statusbars.WGlassStatusbar,
	["ZorkUI"] = C["Media"].Statusbars.ZorkUIStatusbar,
}

function K.GetTexture(texture)
	if K.TextureTable[texture] then
		return K.TextureTable[texture]
	else
		return K.TextureTable["KkthnxUI"] -- Return something to prevent errors
	end
end
