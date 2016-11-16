local K, C, L = unpack(select(2, ...))

if not C.General.PathFinder then return end

KkthnxPathFinder = LibStub("AceAddon-3.0"):NewAddon("KkthnxPathFinder", "AceEvent-3.0")

function KkthnxPathFinder:OnInitialize()
	if not KkthnxPathFinderCDB then
		KkthnxPathFinderCDB = {}
	end
	if not KkthnxPathFinderCDB.selectedPathBySpec then
		KkthnxPathFinderCDB.selectedPathBySpec = {}
	end
end

function KkthnxPathFinder:OnEnable()
	self:RegisterEvent("ARTIFACT_UPDATE")
	self:RegisterEvent("ARTIFACT_MAX_RANKS_UPDATE")
	self:RefreshPerkRanks()
end

function KkthnxPathFinder:OnDisable()
	self:UnregisterAllEvents()
	local powers = C_ArtifactUI.GetPowers()
	for i, powerID in ipairs(powers) do
		local powerButton = ArtifactPerksMixin.powerIDToPowerButton[powerID]
		if powerButton and powerButton.ArtifactPathIndex then
			powerButton.ArtifactPathIndex:Hide()
		end
	end
end

function KkthnxPathFinder:ARTIFACT_UPDATE()
	self:RefreshPerkRanks()
end

function KkthnxPathFinder:ARTIFACT_MAX_RANKS_UPDATE()
	self:RefreshPerkRanks()
end

function KkthnxPathFinder:GetCurrentPaths()
    local _, className = UnitClass("player")
	local artifactItemId = C_ArtifactUI.GetArtifactInfo()
	local pathTable = self.Data

	local currentPath = nil
	local currentPathName = nil

	if pathTable[className] and pathTable[className][artifactItemId] then
		return pathTable[className][artifactItemId]
	end
	return nil
end

local function GetPowerInfoMaps()
	local powers = C_ArtifactUI.GetPowers()
	if not powers then return nil end
	local powerInfo, spellInfo = {}, {}

	for i, powerID in ipairs(powers) do
		local spellID, _, currentRank, maxRank, bonusRanks, x, y = C_ArtifactUI.GetPowerInfo(powerID)
		powerInfo[powerID] = {}
		powerInfo[powerID].spellID = spellID
		powerInfo[powerID].powerID = powerID
		powerInfo[powerID].buttonIndex = i
		powerInfo[powerID].currentRank = currentRank
		powerInfo[powerID].maxRank = maxRank
		powerInfo[powerID].bonusRanks = bonusRanks
		powerInfo[powerID].x = x
		powerInfo[powerID].y = y
		powerInfo[powerID].isFinished = currentRank == maxRank
		spellInfo[spellID] = powerInfo[powerID]
	end
	return powers, powerInfo, spellInfo
end

local brokenSpellId = {}

local function CreateIndexesForPowers(currentPath, spellInfo)
	local selectionPath = {}
	local isNextChecking = true

	for i,spellID in ipairs(currentPath) do
		if not spellInfo[spellID] then
			if not brokenSpellId[spellID] then
		    	local _, className = UnitClass("player")
				local artifactItemId = C_ArtifactUI.GetArtifactInfo()
				DEFAULT_CHAT_FRAME:AddMessage("Artifact spell not found. Please report a bug in Path data: "..tostring(spellID).." "..className.."/"..tostring(artifactItemId))
				brokenSpellId[spellID] = 1
			end
		else
			local isNext = false
			if isNextChecking then
				if not spellInfo[spellID].isFinished then
					isNext = true
					isNextChecking = false
				end
			end
			local powerID = spellInfo[spellID].powerID
			selectionPath[powerID] = {}
			selectionPath[powerID].index = i
			selectionPath[powerID].isNext = isNext
		end
	end
	return selectionPath
end

local function CreateButtonOverlay(powerButton)
	local button = powerButton:CreateFontString(nil, "OVERLAY")
	button:SetFont(C.Media.Font, 22, C.Media.Font_Style)
	button:SetPoint("CENTER",powerButton.Icon,"CENTER",0,0)
	return button
end

function KkthnxPathFinder:RefreshSelectedPath()
	local currentPaths = KkthnxPathFinder:GetCurrentPaths()
	local pathCount = 0
	if not currentPaths then return 0 end
 	for _ in pairs(currentPaths) do pathCount = pathCount + 1 end
 	local artifactItemId = C_ArtifactUI.GetArtifactInfo()

	if pathCount == 0 then
		self.selectedName = nil
		self.selectedPath = nil
	elseif pathCount == 1 or not KkthnxPathFinderCDB.selectedPathBySpec[artifactItemId] then
		self.selectedName, self.selectedPath = next(currentPaths)
	else
		self.selectedName = KkthnxPathFinderCDB.selectedPathBySpec[artifactItemId]
		if currentPaths[self.selectedName] then
			self.selectedPath = currentPaths[self.selectedName]
		else
			self.selectedName, self.selectedPath = next(currentPaths)
		end
	end
	KkthnxPathFinderCDB.selectedPathBySpec[artifactItemId] = self.selectedName
	return pathCount
end

local function DropDown_Initialize(self, level)
	local info = UIDropDownMenu_CreateInfo()
	local num = 1
	local selectedNum = nil
	for k, v in pairs(KkthnxPathFinder:GetCurrentPaths()) do
		info = UIDropDownMenu_CreateInfo()
		info.text = k
		info.value = num
		info.func = function (self)
			UIDropDownMenu_SetSelectedID(ArtifactFrame.PerksTab.KkthnxPathFinderFilter, self:GetID())
			KkthnxPathFinder.selectedPath = v
			KkthnxPathFinder.selectedName = k
			KkthnxPathFinderCDB.selectedPathBySpec[C_ArtifactUI.GetArtifactInfo()] = k
			KkthnxPathFinder:RefreshPerkRanks()
		end
		info.checked = KkthnxPathFinder.selectedName == k
		if info.checked then selectedNum = num end
		num = num + 1
		UIDropDownMenu_AddButton(info, level)
	end
	if selectedNum then
		UIDropDownMenu_SetSelectedID(ArtifactFrame.PerksTab.KkthnxPathFinderFilter, selectedNum)
	end
end

function KkthnxPathFinder:RefreshFilter()
	local pathCount = KkthnxPathFinder:RefreshSelectedPath()
	if pathCount < 2 then
		if ArtifactFrame.PerksTab.KkthnxPathFinderFilter then
			ArtifactFrame.PerksTab.KkthnxPathFinderFilter:Hide()
		end
		return
	end

	if not ArtifactFrame.PerksTab.KkthnxPathFinderFilter then
		ArtifactFrame.PerksTab.KkthnxPathFinderFilter = CreateFrame("Frame", "KkthnxPathFinderFilter", ArtifactFrame.PerksTab, "UIDropDownMenuTemplate")
	else
		ArtifactFrame.PerksTab.KkthnxPathFinderFilter:Show()
	end
	local FilterDropDown = ArtifactFrame.PerksTab.KkthnxPathFinderFilter
	UIDropDownMenu_Initialize(FilterDropDown, DropDown_Initialize)
	UIDropDownMenu_SetWidth(FilterDropDown, 200)
	UIDropDownMenu_SetButtonWidth(FilterDropDown, 144)
	UIDropDownMenu_JustifyText(FilterDropDown, "LEFT")
	FilterDropDown:SetPoint("TOPRIGHT", ArtifactFrame.PerksTab, "TOPRIGHT", 0, -50)
end

function KkthnxPathFinder:HideAll()
	local powers = C_ArtifactUI.GetPowers()
	for i, powerID in ipairs(powers) do
		local powerButton = ArtifactFrame.PerksTab:GetOrCreatePowerButton(i)
		if powerButton and powerButton.ArtifactPathIndex then
			powerButton.ArtifactPathIndex:Hide()
			powerButton.StarBurst:SetAlpha(0)
		end
	end
	if ArtifactFrame.PerksTab.KkthnxPathFinderFilter then
		ArtifactFrame.PerksTab.KkthnxPathFinderFilter:Hide()
	end
end

function KkthnxPathFinder:RefreshPerkRanks()
    if not ArtifactFrame or not ArtifactFrame.PerksTab then return end

	self:RefreshFilter()

	local currentPath = self.selectedPath
	if currentPath then
		local powers, powerInfo, spellInfo = GetPowerInfoMaps()
		if not powers then return end
		local selectionPath = CreateIndexesForPowers(currentPath, spellInfo)

		for i, powerID in ipairs(powers) do
			local powerButton = ArtifactFrame.PerksTab:GetOrCreatePowerButton(i)
			if powerButton then
				if not powerButton.ArtifactPathIndex then
					powerButton.ArtifactPathIndex = CreateButtonOverlay(powerButton)
				else
					powerButton.ArtifactPathIndex:Show()
				end
				powerButton.StarBurst:SetAlpha(0)
				powerButton.ArtifactPathIndex:SetTextColor(1, 1, 1, 1)
				powerButton.ArtifactPathIndex:SetText("")

				if selectionPath[powerID] then
					if (C_ArtifactUI.GetTotalPurchasedRanks() == 0 and selectionPath[powerID].index>2) or
					   (selectionPath[powerID].index == 18 and not selectionPath[powerID].isNext)
					then
						powerButton.ArtifactPathIndex:Hide()
					else
						powerButton.ArtifactPathIndex:SetText(tostring(selectionPath[powerID].index))
						if selectionPath[powerID].isNext then
							powerButton.ArtifactPathIndex:SetTextColor(1, 0, 0, 1)
							powerButton.StarBurst:SetAlpha(0.9)
						end
					end
				end
			end
		end
	end
end

local pathTable = {
 ["DEATHKNIGHT"] = {
     [128402] = {
           ["Blood - Survivability"] = {205223, 221775, 192542, 192557, 192538, 192464, 192567, 192447, 192558, 192548, 192450, 192457, 193213, 192453, 192514, 192570, 192460, 214903},
           ["Blood - DPS"] =           {205223, 221775, 192514, 192570, 192450, 192548, 192464, 192567, 192457, 193213, 192542, 192557, 192447, 192558, 192538, 192460, 192453, 214903},
         },
     [128292] = {
           ["Frost"] =                 {189186, 218931, 189144, 189179, 204875, 189164, 190778, 189080, 189180, 189092, 189185, 189086, 189154, 189097, 189184, 189147, 205209, 214904},
         },
     [128403] = {
           ["Unholy"] =                {220143, 218280, 208598, 191488, 191637, 191747, 191494, 191584, 191760, 191731, 191485, 191442, 191565, 191741, 191419, 191592, 191721, 214906},
         },
 },
 ["DEMONHUNTER"] = {
     [127829] = {
           ["Havoc"] =         {201467, 214795, 201457, 201470, 201460, 201469, 201459, 201472, 201455, 201456, 201473, 201458, 201454, 201468, 201463, 201471, 201464, 214907},
         },
     [128831] = {
           ["Vengeance"] =     {207407, 214744, 212827, 218910, 212817, 213017, 207343, 212894, 207347, 213010, 207375, 212821, 212829, 212816, 207387, 207352, 212819, 214909},
         },
 },
 ["DRUID"] = {
     [128858] = {
           ["Balance"] =       {202767, 214514, 202445, 202918, 203018, 202996, 202384, 202386, 202466, 202940, 202433, 213682, 202890, 202426, 214508, 202464, 202302, 214910},
         },
     [128860] = {
           ["Feral"] =         {210722, 214736, 210593, 210650, 210590, 210579, 210570, 210663, 210575, 210702, 210666, 210631, 210676, 210571, 210637, 210557, 210638, 214911},
         },
     [128821] = {
           ["Guardian - Adaptive Fur"] =      {200851, 215061, 200440, 200400, 215799, 200402, 200515, 200409, 200855, 200395, 200850, 200415, 200399, 200854, 200414, 208762, 214996, 214912},
           ["Guardian - Gory Fur"] =          {200851, 215061, 200440, 200400, 215799, 200402, 200515, 200409, 200855, 200415, 200399, 200854, 200395, 200850, 200414, 208762, 214996, 214912},
         },
	 [128306] = {
           ["Restoration - Throughput"] =     {208253, 222644, 186320, 189787, 189760, 189849, 186393, 189754, 189744, 189857, 189757, 186396, 189772, 189870, 189749, 189768, 186372, 214913},
           ["Restoration - Mana"] =           {208253, 222644, 189757, 186396, 189772, 189870, 186320, 189787, 186393, 189760, 189849, 189754, 189744, 189857, 189749, 189768, 186372, 214913},
         },
 },
 ["HUNTER"] = {
     [128861] = {
           ["Beast Mastery"] = {197344, 215779, 197139, 197160, 197162, 197248, 197047, 206910, 197354, 197343, 197080, 197038, 207068, 197140, 197199, 197138, 197178, 214914},
         },
     [128826] = {
           ["Marksmanship"] =  {204147, 214826, 190467, 204219, 190449, 190567, 191339, 190529, 204089, 190457, 190852, 190520, 191048, 190462, 191328, 190503, 190514, 214915},
         },
     [128808] = {
           ["Survival"] =      {203415, 221773, 203673, 203638, 203670, 203755, 203752, 203578, 203757, 203669, 225092, 224764, 203563, 203566, 203577, 203754, 203749, 214916},
         },
 },
 ["MAGE"] = {
     [127857] = {
           ["Arcane"] =        {224968, 187318, 187258, 187264, 210716, 215463, 187276, 187321, 188006, 187287, 187301, 210725, 187304, 187313, 187310, 187680, 210730, 214917},
         },
     [128820] = {
           ["Fire"] =          {194466, 221844, 194318, 194239, 194224, 194331, 194313, 215796, 194314, 215773, 194312, 194431, 194234, 194487, 210182, 194315, 227481, 214918},
         },
     [128862] = {
           ["Frost"] =         {214634, 214629, 195322, 195352, 195419, 214626, 214776, 195345, 195351, 220817, 195317, 195448, 195315, 214664, 195354, 195615, 195323, 214919},
         },
 },
 ["MONK"] = {
     [128938] = {
           ["Brewmaster"] =    {214326, 214428, 213047, 213049, 213116, 216424, 213062, 213050, 213055, 213340, 213051, 213180, 213133, 214372, 213136, 213161, 213183, 214920},
         },
     [128937] = {
           ["Mistweaver - Dancing Mists"] =         {205406, 214516, 199485, 199384, 199366, 199887, 199563, 199372, 199380, 199365, 199573, 199367, 199665, 199364, 199640, 199377, 199401, 214921},
           ["Mistweaver - Blessing of Yu'lon"] =    {205406, 214516, 199485, 199384, 199366, 199887, 199563, 199372, 199367, 199665, 199380, 199365, 199573, 199364, 199640, 199377, 199401, 214921},
         },
     [128940] = {
           ["Windwalker - Single Target / Raid"] =  {205320, 195265, 195263, 195266, 195244, 195291, 195298, 195243, 196082, 195300, 218607, 195650, 195399, 195269, 195267, 195380, 195295, 214922},
           ["Windwalker - AoE / Leveling"] =        {205320, 195265, 195269, 195267, 195380, 195650, 218607, 195300, 195243, 196082, 195298, 195291, 195399, 195263, 195266, 195244, 195295, 214922},
         },
 },
 ["PALADIN"] = {
     [128823] = {
           ["Holy"] =          {200652, 222648, 200302, 200315, 200373, 200294, 200474, 200482, 200311, 200326, 200430, 200296, 200298, 200421, 200407, 200327, 200316, 214923},
         },
     [128866] = {
           ["Protection"] =    {209202, 221841, 209225, 209226, 209229, 209218, 209474, 209224, 209389, 209223, 209220, 209341, 209285, 209216, 209539, 209376, 209217, 214924},
         },
     [120978] = {
           ["Retribution"] =   {205273, 214081, 186927, 184759, 186945, 186941, 185086, 185368, 179546, 184778, 186788, 186934, 186773, 184843, 182234, 186944, 193058, 207604},
         },
 },
 ["PRIEST"] = {
     [128868] = {
           ["Discipline"] =    {207946, 216122, 197708, 197729, 197781, 216212, 197716, 198068, 197715, 197762, 198074, 197727, 197713, 197815, 197779, 197766, 197711, 214925},
         },
     [128825] = {
           ["Holy"] =          {196684, 222646, 196422, 196418, 196430, 196429, 196489, 196578, 196358, 196779, 196416, 208065, 196492, 196437, 196434, 196355, 196419, 214926},
         },
     [128827] = {
           ["Shadow"] =        {205065, 215322, 194093, 193644, 194024, 193642, 193643, 194378, 193647, 194007, 193371, 194026, 194002, 194179, 194016, 194018, 193645, 214927},
         },
 },
 ["ROGUE"] = {
     [128870] = {
           ["Assassination"] = {192759, 214368, 192310, 192384, 192349, 192329, 192923, 192318, 192657, 192376, 192424, 192315, 192428, 192326, 192323, 192422, 192345, 214928},
         },
     [128872] = {
           ["Outlaw"] =        {202665, 202463, 202514, 202524, 202533, 202820, 202753, 202507, 202530, 202522, 202755, 202521, 202897, 216230, 202769, 202628, 202907, 214929},
         },
     [128476] = {
           ["Subtlety"] =      {209782, 221856, 197234, 197241, 197244, 197256, 197231, 209835, 197239, 197406, 197386, 209781, 197233, 197235, 197369, 197610, 197604, 214930},
         },
 },
 ["SHAMAN"] = {
     [128935] = {
           ["Elemental"] =     {205495, 215414, 191740, 191512, 191569, 191572, 191861, 191602, 191504, 191493, 191717, 191499, 191598, 192630, 191577, 191647, 191582, 214931},
         },
     [128819] = {
           ["Enhancement"] =   {204945, 198228, 198299, 198292, 198434, 198296, 198505, 198367, 198248, 198361, 198238, 198736, 215381, 198349, 198247, 198236, 199107, 214932},
         },
     [128911] = {
           ["Restoration - Mythic/Raid"] =      {207778, 224841, 207092, 207206, 207285, 207360, 207088, 207118, 207351, 207355, 207356, 207348, 207362, 207255, 207358, 214933},
           ["Restoration - Dungeon/Casual"] =   {207778, 224841, 207092, 207206, 207285, 207360, 207088, 207118, 207255, 207358, 207351, 207355, 207356, 207348, 207362, 214933},
         },
 },
 ["WARLOCK"] = {
     [128942] = {
           ["Affliction"] =    {216698, 221862, 199153, 199282, 199214, 199471, 199163, 199112, 199472, 199111, 199212, 201424, 199158, 199220, 199152, 199120, 199257, 214934},
         },
     [128943] = {
           ["Demonology"] =    {211714, 221882, 211108, 211158, 211144, 211099, 211119, 211219, 218572, 211106, 211530, 211123, 218567, 211131, 211720, 211105, 211126, 214935},
         },
     [128941] = {
           ["Destruction"] =   {196586, 215183, 196305, 215273, 196432, 196301, 196227, 219195, 224103, 196258, 215223, 196236, 196217, 219415, 196222, 196211, 196675, 214936},
         },
 },
 ["WARRIOR"] = {
     [128910] = {
           ["Arms"] =          {209577, 209480, 209472, 209548, 209494, 209574, 209483, 209492, 209566, 216274, 209554, 209459, 209462, 209481, 209573, 209541, 209559, 214937},
         },
     [128908] = {
           ["Fury"] =          {205545, 200847, 200853, 200860, 200861, 200871, 200849, 200872, 200870, 200846, 200875, 200863, 200857, 200845, 216273, 200856, 200859, 214938},
         },
     [128289] = {
           ["Protection"] =    {203524, 188647, 188639, 203227, 203225, 188672, 203576, 203261, 203230, 189059, 188635, 188683, 188651, 188778, 188632, 216272, 188644, 214939},
         },
 },
}

pathTable["DEATHKNIGHT"][128293] = pathTable["DEATHKNIGHT"][128292]
pathTable["DEMONHUNTER"][127830] = pathTable["DEMONHUNTER"][127829]
pathTable["DEMONHUNTER"][128832] = pathTable["DEMONHUNTER"][128831]
pathTable["DRUID"][128859] = pathTable["DRUID"][128860]
pathTable["DRUID"][128822] = pathTable["DRUID"][128821]
pathTable["MAGE"][133959] = pathTable["MAGE"][128820]
pathTable["MONK"][133948] = pathTable["MONK"][128940]
pathTable["PALADIN"][128867] = pathTable["PALADIN"][128866]
pathTable["PRIEST"][133958] = pathTable["PRIEST"][128827]
pathTable["ROGUE"][128869] = pathTable["ROGUE"][128870]
pathTable["ROGUE"][134552] = pathTable["ROGUE"][128872]
pathTable["ROGUE"][128479] = pathTable["ROGUE"][128872]
pathTable["SHAMAN"][128936] = pathTable["SHAMAN"][128935]
pathTable["SHAMAN"][128873] = pathTable["SHAMAN"][128819]
pathTable["SHAMAN"][128934] = pathTable["SHAMAN"][128911]
pathTable["WARLOCK"][137246] = pathTable["WARLOCK"][128943]
pathTable["WARRIOR"][134553] = pathTable["WARRIOR"][128908]
pathTable["WARRIOR"][128288] = pathTable["WARRIOR"][128289]

KkthnxPathFinder.Data = pathTable