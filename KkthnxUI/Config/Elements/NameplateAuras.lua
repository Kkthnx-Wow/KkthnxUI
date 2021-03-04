local _, C = unpack(select(2, ...))

local _G = _G

local C_EncounterJournal_GetSectionInfo = _G.C_EncounterJournal.GetSectionInfo

C.NameplateWhiteList = {
	[1022] = true,
	[107079] = true,
	[117405] = true,
	[127797] = true,
	[186265] = true,
	[20549] = true,
	[2094] = true,
	[226510] = true,
	[228318] = true,
	[228626] = true,
	[23920] = true,
	[272295] = true,
	[317936] = true,
	[320293] = true,
	[321402] = true,
	[322433] = true,
	[326450] = true,
	[327416] = true,
	[327812] = true,
	[328175] = true,
	[331510] = true,
	[333227] = true,
	[333241] = true,
	[333737] = true,
	[334695] = true,
	[336449] = true,
	[336451] = true,
	[339917] = true,
	[323149] = true,
	[340357] = true,
	[343470] = true,
	[343502] = true,
	[343553] = true,
	[343558] = true,
	[344739] = true,
	[328351] = true,
	[345902] = true,
	[346792] = true,
	[45438] = true,
	[642] = true,
}

C.NameplateBlackList = {
	[15407] = true,
	[199721] = true,
	[206930] = true,
	[214968] = true,
	[214975] = true,
	[273977] = true,
	[276919] = true,
	[51714] = true,
}

local function GetSectionInfo(id)
	return C_EncounterJournal_GetSectionInfo(id).title
end

C.NameplateCustomUnits = {
	[120651] = true,
	[153401] = true,
	[156795] = true,
	[157610] = true,
	[164464] = true,
	[165251] = true,
	[165556] = true,
	[170234] = true,
	[170851] = true,
	[171341] = true,
	[174773] = true,
	[175992] = true,
	[GetSectionInfo(21953)] = true,
	[GetSectionInfo(22161)] = true,
}

C.NameplateShowPowerList = {
	[165556] = true,
	[GetSectionInfo(22339)] = true,
}

-- C.MajorSpells = {
-- 	--[32011] = true, -- TEST
-- 	[317936] = true,
-- 	[321828] = true,
-- 	[324293] = true,
-- 	[324667] = true,
-- 	[325700] = true,
-- 	[326046] = true,
-- 	[326450] = true,
-- 	[326827] = true,
-- 	[326831] = true,
-- 	[327413] = true,
-- 	[328400] = true,
-- 	[330586] = true,
-- 	[330868] = true,
-- 	[332084] = true,
-- 	[332612] = true,
-- 	[332706] = true,
-- 	[333294] = true,
-- 	[334051] = true,
-- 	[334664] = true,
-- 	[334748] = true,
-- 	[334749] = true,
-- 	[338357] = true,
-- 	[341969] = true,
-- }