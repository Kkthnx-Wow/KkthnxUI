local _, C = unpack(select(2, ...))

local _G = _G

local C_EncounterJournal_GetSectionInfo = _G.C_EncounterJournal.GetSectionInfo

C.NameplateWhiteList = {
	[642]		= true,
	[1022]		= true,
	[23920]		= true,
	[45438]		= true,
	[186265]	= true,
	[2094]		= true,
	[117405]	= true,
	[127797]	= true,
	[20549] 	= true,
	[107079] 	= true,
	[272295] 	= true,
	[228318]	= true,
	[226510]	= true,
	[343553]	= true,
	[343502]	= true,
	[320293]	= true,
	[331510]	= true,
	[333241]	= true,
	[336449]	= true,
	[336451]	= true,
	[333737]	= true,
	[328175]	= true,
	[340357]	= true,
	[228626]	= true,
	[344739]	= true,
	[333227]	= true,
	[326450]	= true,
	[343558]	= true,
	[343470]	= true,
	[322433]	= true,
	[321402]	= true,
	[327416]	= true,
	[317936]	= true,
	[327812]	= true,
	[334695]	= true,
	[345902]	= true,
	[346792]	= true,
}

C.NameplateBlackList = {
	[15407]		= true,
	[51714]		= true,
	[199721]	= true,
	[214968]	= true,
	[214975]	= true,
	[273977]	= true,
	[276919]	= true,
	[206930]	= true,
}

local function GetSectionInfo(id)
	return C_EncounterJournal_GetSectionInfo(id).title
end

C.NameplateCustomUnits = {
	[153401] = true,
	[157610] = true,
	[156795] = true,
	[120651] = true,
	[174773] = true,
	[GetSectionInfo(22161)] = true,
	[170851] = true,
	[165556] = true,
	[170234] = true,
	[164464] = true,
	[GetSectionInfo(21953)] = true,
	[175992] = true,
}

C.NameplateShowPowerList = {
	[165556] = true,
	[GetSectionInfo(22339)] = true,
}