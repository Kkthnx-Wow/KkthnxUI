local K, C, L = select(2, ...):unpack()
if IsAddOnLoaded("DugisGuideViewerZ") then return end

local ObjectiveTracker = CreateFrame("Frame", "ObjectiveTracker", UIParent)

--Cache global variables
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local GetScreenWidth = GetScreenWidth
local GetScreenHeight = GetScreenHeight
local format = string.format
local blocks = {}
local tooltips = {}
local frequencies = {
	[LE_QUEST_FREQUENCY_DAILY] = {"*", DAILY},
	[LE_QUEST_FREQUENCY_WEEKLY] = {"**", WEEKLY},
}
local classcolor = ("|cff%.2x%.2x%.2x"):format(K.Color.r * 255, K.Color.g * 255, K.Color.b * 255)

local ObjectiveFrameHolder = CreateFrame("Frame", "ObjectiveFrameHolder", K.UIParent)
ObjectiveFrameHolder:SetWidth(130)
ObjectiveFrameHolder:SetHeight(22)
ObjectiveFrameHolder:SetPoint(unpack(C.Position.ObjectiveTracker))

function ObjectiveTracker:ObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetHeight(700) -- was 480
end

local function IsFramePositionedLeft(frame)
	local x = frame:GetCenter()
	local screenWidth = GetScreenWidth()
	local screenHeight = GetScreenHeight()
	local positionedLeft = false

	if x and x < (screenWidth / 2) then
		positionedLeft = true
	end

	return positionedLeft
end

--Questtags
if C.Misc.QuestLevel == true then
	local function CreateQuestTag(level, questTag, frequency)
		local tag = ""

		if level == -1 then level = "*" else level = tonumber(level) end

		if questTag == ELITE then
			tag = "+"
		elseif questTag == QUEST_TAG_GROUP then
			tag = "g"
		elseif questTag == QUEST_TAG_PVP then
			tag = "pvp"
		elseif questTag == QUEST_TAG_DUNGEON then
			tag = "d"
		elseif questTag == QUEST_TAG_HEROIC then
			tag = "hc"
		elseif questTag == QUEST_TAG_RAID then
			tag = "r"
		elseif questTag == QUEST_TAG_RAID10 then
			tag = "r10"
		elseif questTag == QUEST_TAG_RAID25 then
			tag = "r25"
		elseif questTag == QUEST_TAG_SCENARIO then
			tag = "s"
		elseif questTag == QUEST_TAG_ACCOUNT then
			tag = "a"
		elseif questTag == QUEST_TAG_LEGENDARY then
			tag = "leg"
		end

		local color = classcolor
		if (level == nil or tonumber(level) == nil) then level = 0 end
		local col = GetQuestDifficultyColor(level)
		if not col then col = {r = 1, g = 1, b = 1} end
		if frequency == 2 then tag = tag .. "*" elseif frequency == 3 then tag = tag .. "**" end
	if tag ~= "" then tag = (color .. "%s|r"):format(tag) end
	tag = ("[|cff%2x%2x%2x%s|r%s|cff%1$2x%2$2x%3$2x|r] "):format(col.r * 255, col.g * 255, col.b * 255, level, tag)
	return tag
end

-- Questtitle
hooksecurefunc(QUEST_TRACKER_MODULE, "Update", function(self)
	local num = GetNumQuestLogEntries()
	for i = 1, num do
		local title, level, groupSize, isHeader, isCollapsed, isComplete, frequency, questID, startEvent, displayQuestID, isOnMap, hasLocalPOI, isTask, isBounty, isStory = GetQuestLogTitle(i)
		if questID and questID ~= 0 then
			local block = QUEST_TRACKER_MODULE:GetBlock(questID)
			local tagID, tagName = GetQuestTagInfo(questID)
			local tags = {tagName}
			local questText = GetQuestLogQuestText(i)
			local color = classcolor

			if frequencies[frequency] then tinsert(tags,frequencies[frequency][2]) end
			tooltips[questID] = false
			tooltips[questID] = {title}
			tinsert(tooltips[questID],{" ", " "})
			tinsert(tooltips[questID],{"Questlevel:", color .. level .. "|r"})
			tinsert(tooltips[questID],{"Questtag:", color .. table.concat(tags, "|r, "..color) .. "|r"})
			tinsert(tooltips[questID],{"QuestID:", color .. questID .. "|r"})
			tinsert(tooltips[questID],{" ", " "})
			tinsert(tooltips[questID], questText)

			QUEST_TRACKER_MODULE:SetStringText(block.HeaderText, title, nil, OBJECTIVE_TRACKER_COLOR["Header"])
			if not blocks[questID] and block.HeaderButton then
				blocks[questID] = true
			end

			block.HeaderText:SetFont(STANDARD_TEXT_FONT, 12)
			block.HeaderText:SetShadowOffset(.7, -.7)
			block.HeaderText:SetShadowColor(0, 0, 0, 1)
			block.HeaderText:SetWordWrap(true)

			local heightcheck = block.HeaderText:GetNumLines()

			if heightcheck == 2 then
				local height = block:GetHeight()
				block:SetHeight(height*2) -- + 16
			end

			local oldBlockHeight = block.height
			local oldHeight = QUEST_TRACKER_MODULE:SetStringText(block.HeaderText, title, nil, OBJECTIVE_TRACKER_COLOR["Header"])
			local newTitle = CreateQuestTag(level, tagID, frequency) .. title
			local newHeight = QUEST_TRACKER_MODULE:SetStringText(block.HeaderText, newTitle, nil, OBJECTIVE_TRACKER_COLOR["Header"])
		end
	end
end)
end

function ObjectiveTracker:Enable()
	local Movers = K.Movers

	Movers:RegisterFrame(ObjectiveFrameHolder)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
	ObjectiveTracker:ObjectiveFrameHeight()
	ObjectiveTrackerFrame:SetClampedToScreen(false)

	local function ObjectiveTrackerFrame_SetPosition(_, _, parent)
		if parent ~= ObjectiveFrameHolder then
			ObjectiveTrackerFrame:ClearAllPoints()
			ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder, "TOP")
		end
	end
	hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", ObjectiveTrackerFrame_SetPosition)

	local function RewardsFrame_SetPosition(block)
		local rewardsFrame = ObjectiveTrackerBonusRewardsFrame
		rewardsFrame:ClearAllPoints()
		rewardsFrame:SetPoint("TOPRIGHT", block, "TOPLEFT", 10, -4)
	end
	hooksecurefunc("BonusObjectiveTracker_AnimateReward", RewardsFrame_SetPosition)
end

ObjectiveTracker:RegisterEvent("PLAYER_LOGIN")
ObjectiveTracker:SetScript("OnEvent", ObjectiveTracker.Enable)
