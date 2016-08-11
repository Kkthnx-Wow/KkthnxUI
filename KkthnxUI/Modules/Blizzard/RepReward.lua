local K, C, L, _ = select(2, ...):unpack()
if C.Blizzard.Reputations ~= true then return end

local pairs = pairs
local floor = math.floor
local CreateFrame = CreateFrame
local UnitRace = UnitRace
local GetFactionInfo = GetFactionInfo
local GetQuestLogSelection = GetQuestLogSelection
local GetQuestLogTitle = GetQuestLogTitle
local GetNumQuestLogRewardFactions = GetNumQuestLogRewardFactions
local GetTitleText = GetTitleText
local GetQuestLogRewardFactionInfo = GetQuestLogRewardFactionInfo
local GetFactionInfoByID = GetFactionInfoByID

local questIndex, questName, numRewFactions
local updateInterval = 1.0
local timeSinceLastUpdate = 0

function CalcBonusRep(factionName)
	local bonusRep = 0
	local buffs = {
		-- SETTING THE DEFAULTS TO FALSE SO THAT YOU CAN START OUT ASSUMING THE PLAYER DOESN'T HAVE THE BUFF
		["Spirit of Sharing"] = {faction="all", bonusAmt=0.1},
        ["Grim Visage"] = {faction="all", bonusAmt=0.1},
        ["Unburdened"] = {faction="all", bonusAmt=0.1},
		["Banner of Cooperation"] = {faction="all", bonusAmt=0.05},
		["Standard of Unity"] = {faction="all", bonusAmt=0.1},
		["Battle Standard of Coordination"] = {faction="all", bonusAmt=0.15},
		["Nazgrel's Fervor"] = {faction="Thrallmar", bonusAmt=0.10},
		["Trollbane's Command"] = {faction="Honor Hold", bonusAmt=0.10},
		["A'dal's Song of Battle"] = {faction="Sha'tar", bonusAmt=0.10},
		["WHEE!"] = {faction="all", bonusAmt=0.10},
		["Darkmoon Top Rat"] = {faction="all", bonusAmt=0.10},
		["Berserker Rage"] = {faction="all", bonusAmt=1.0},
	}

	for buff, buffInfo in pairs(buffs) do
		if UnitBuff("player", buff) then
			if buffInfo.faction == "all" or buffInfo.faction == factionName then
				bonusRep = bonusRep + buffInfo.bonusAmt
			end
		end
	end

	local _, raceEn = UnitRace("player")
	if raceEn == "Human" then
		bonusRep = bonusRep + 0.1
	end
	return bonusRep
end

function CalcBonusRepCommendation(factionName)
	local factionIndex = 1
	local lastFactionName, name, hasBonusRepGain
	local bonusRepCommendation = 1
	repeat
		name, _, _, _, _, _, _, _, _, _, _, _, _, _, hasBonusRepGain, _ = GetFactionInfo(factionIndex)
		if name == lastFactionName then break end
		lastFactionName = name
		if name == factionName then
			if hasBonusRepGain then
				bonusRepCommendation = 2
			end
			break
		end
		factionIndex = factionIndex + 1
	until factionIndex > 200
	return bonusRepCommendation
end

function ShowReputations()
	local stringRep
	local numRewFactions = 0
	if QuestLogPopupDetailFrame:IsVisible() then
		questIndex = GetQuestLogSelection()
		questName = GetQuestLogTitle(questIndex)
		numRewFactions = GetNumQuestLogRewardFactions()
	elseif QuestFrameDetailPanel:IsVisible() or QuestFrameRewardPanel:IsVisible() then
		questIndex = nil
		questName = GetTitleText()
		numRewFactions = GetNumQuestLogRewardFactions()
	end
	if questName then
		local foundRep = false
		local factionId, amtRep, factionName, isHeader, hasRep, bonusRep, bonusRepCommendation, amtBonus, amtBase, stringRepColor1, stringRepColor2, stringRepLine
		for i = 1, numRewFactions do
			factionId, amtBase = GetQuestLogRewardFactionInfo(i)
			factionName, _, _, _, _, _, _, _, isHeader, _, hasRep = GetFactionInfoByID(factionId)
			if factionName and (not isHeader or hasRep) then
				foundRep = true
				amtBase = floor(amtBase / 100)
				bonusRep = CalcBonusRep(factionName)
				bonusRepCommendation = CalcBonusRepCommendation(factionName)
				if factionName == "Cenarion Circle" or factionName == "Timbermaw Hold" or factionName == "Argent Dawn" then
					amtBase = amtBase * 2
				elseif factionName == "Thorium Brotherhood" then
					amtBase = amtBase * 4
				end
				amtRep = floor((amtBase * (1 + bonusRep)) * bonusRepCommendation)
				amtBonus = amtRep - amtBase
				if amtBase < 0 then
					stringRepColor1 = "|cff621a00"
					stringRepColor2 = "|r"
				else
					stringRepColor1 = ""
					stringRepColor2 = ""
				end

				stringRepLine = factionName..": "..stringRepColor1..amtRep..stringRepColor2
				if amtBonus ~= 0 then
					stringRepLine = stringRepLine.."\n"..stringRepColor1.." ("..amtBase.." base + "..amtBonus.." bonus)"..stringRepColor2
				end
				if stringRep then
					stringRep = stringRep.."\n\n"..stringRepLine
				else
					stringRep = stringRepLine
				end
				stringRepLine = nil
			end
		end
		if not foundRep then
			stringRep = "No Reputations Reward"
		end
	end
	return stringRep, numRewFactions
end

local ReputationsTitleFrame = CreateFrame("Frame")
ReputationsTitleFrame:SetSize(288, 20)
ReputationsTitleFrame.text = ReputationsTitleFrame:CreateFontString(nil, "ARTWORK", "QuestFont_Shadow_Huge")
ReputationsTitleFrame.text:SetAllPoints(true)
ReputationsTitleFrame.text:SetJustifyH("LEFT")
ReputationsTitleFrame.text:SetJustifyV("TOP")
ReputationsTitleFrame.text:SetTextColor(0, 0, 0, 1)

local ReputationsDetailFrame = CreateFrame("Frame")
ReputationsDetailFrame:SetSize(288, 200)
ReputationsDetailFrame.text = ReputationsDetailFrame:CreateFontString(nil, "ARTWORK", "QuestFontNormalSmall")
ReputationsDetailFrame.text:SetAllPoints(true)
ReputationsDetailFrame.text:SetJustifyH("LEFT")
ReputationsDetailFrame.text:SetJustifyV("TOP")
ReputationsDetailFrame.text:SetTextColor(0, 0, 0, 1)

local function Reputations_ShowTitle()
	if QuestInfoRewardsHeader then
		ReputationsTitleFrame.text:SetTextColor(QuestInfoRewardsHeader:GetTextColor())
	end
	ReputationsTitleFrame.text:SetText("Reputations")
	return ReputationsTitleFrame
end

local function Reputations_ShowDetail()
	local stringRep, numRepFactions = ShowReputations()
	local windowSize
	if QuestInfoDescriptionText then
		ReputationsDetailFrame.text:SetTextColor(QuestInfoDescriptionText:GetTextColor())
	end
	if numRepFactions then
		windowSize = numRepFactions * 30 + 20
		ReputationsDetailFrame:SetSize(288, windowSize)
	end
	ReputationsDetailFrame.text:SetText(stringRep)
	return ReputationsDetailFrame
end

local posSpacer = 0
for i = #QUEST_TEMPLATE_LOG.elements-2, 1, -3 do
	if QUEST_TEMPLATE_LOG.elements[i] == QuestInfo_ShowSpacer then
		posSpacer = i
		break
	end
end
if posSpacer > 0 then
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer, Reputations_ShowTitle)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer +1, 0)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer +2, -10)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer +3, Reputations_ShowDetail)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer +4, 0)
	table.insert(QUEST_TEMPLATE_LOG.elements, posSpacer +5, -5)
else
	table.insert(QUEST_TEMPLATE_LOG.elements, Reputations_ShowTitle)
	table.insert(QUEST_TEMPLATE_LOG.elements, 0)
	table.insert(QUEST_TEMPLATE_LOG.elements, -10)
	table.insert(QUEST_TEMPLATE_LOG.elements, Reputations_ShowDetail)
	table.insert(QUEST_TEMPLATE_LOG.elements, 0)
	table.insert(QUEST_TEMPLATE_LOG.elements, -5)
end

for i = #QUEST_TEMPLATE_DETAIL.elements -2, 1, -3 do
	if QUEST_TEMPLATE_DETAIL.elements[i] == QuestInfo_ShowSpacer then
		posSpacer = i
		break
	end
end
if posSpacer > 0 then
	table.insert(QUEST_TEMPLATE_DETAIL.elements, posSpacer, Reputations_ShowTitle)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, posSpacer +1, 0)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, posSpacer +2, -10)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, posSpacer +3, Reputations_ShowDetail)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, posSpacer +4, 0)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, posSpacer +5, -5)
else
	table.insert(QUEST_TEMPLATE_DETAIL.elements, Reputations_ShowTitle)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, 0)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, -10)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, Reputations_ShowDetail)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, 0)
	table.insert(QUEST_TEMPLATE_DETAIL.elements, -5)
end

for i = #QUEST_TEMPLATE_REWARD.elements -2, 1, -3 do
	if QUEST_TEMPLATE_REWARD.elements[i] == QuestInfo_ShowSpacer then
		posSpacer = i
		break
	end
end
if posSpacer > 0 then
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer, Reputations_ShowTitle)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer +1, 0)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer +2, -10)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer +3, Reputations_ShowDetail)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer +4, 0)
	table.insert(QUEST_TEMPLATE_REWARD.elements, posSpacer +5, -5)
else
	table.insert(QUEST_TEMPLATE_REWARD.elements, Reputations_ShowTitle)
	table.insert(QUEST_TEMPLATE_REWARD.elements, 0)
	table.insert(QUEST_TEMPLATE_REWARD.elements, -10)
	table.insert(QUEST_TEMPLATE_REWARD.elements, Reputations_ShowDetail)
	table.insert(QUEST_TEMPLATE_REWARD.elements, 0)
	table.insert(QUEST_TEMPLATE_REWARD.elements, -5)
end