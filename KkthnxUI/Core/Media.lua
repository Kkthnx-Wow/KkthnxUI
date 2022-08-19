local K, C = unpack(KkthnxUI)

K.TextureTable = {
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
	if K.TextureTable[texture] then
		return K.TextureTable[texture]
	else
		return K.TextureTable["KkthnxUI"] -- Return something to prevent errors
	end
end
