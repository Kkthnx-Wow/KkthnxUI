local K, C, L = select(2, ...):unpack()
if C.General.QuestSounds ~= true then return end

local pairs = pairs

local GetNumQuestLeaderBoards = GetNumQuestLeaderBoards
local GetQuestLogLeaderBoard = GetQuestLogLeaderBoard
local GetQuestLogTitle = GetQuestLogTitle
local GetQuestLink = GetQuestLink
local PlaySoundFile = PlaySoundFile

local sounds = {
  questComplete = "Sound\\Creature\\Peon\\PeonBuildingComplete1.ogg",
  objectiveComplete = "Sound\\Creature\\Peasant\\PeasantWhat3.ogg",
  objectiveProgress = "Sound\\creature\\Peon\\PeonWhat3.ogg"
}

local QuestSounds = CreateFrame("Frame")
local events = {}

QuestSounds.questIndex = 0
QuestSounds.questId = 0
QuestSounds.completeCount = 0

local function countCompleteObjectives(index)
  local n = 0
  for i = 1, GetNumQuestLeaderBoards(index) do
    local _, _, finished = GetQuestLogLeaderBoard(i, index)
    if finished then
      n = n + 1
    end
  end
  return n
end

function QuestSounds:setQuest(index)
  self.questIndex = index
  if index > 0 then
    local q = {GetQuestLogTitle(index)}
    local id = q[8]
    self.questId = id
    if id and id > 0 then
      self.completeCount = countCompleteObjectives(index)
    end
  end
end

function QuestSounds:checkQuest()
  if self.questIndex > 0 then
    local index = self.questIndex
    self.questIndex = 0
    local q = {GetQuestLogTitle(index)}
    local title = q[1]
    local level = q[2]
    local complete = q[6]
    local daily = q[7]
    local id = q[8]
    local link = GetQuestLink(index)
    if id == self.questId then
      if id and id > 0 then
        local objectivesComplete = countCompleteObjectives(index)
        if complete then
          QuestSounds:Play(sounds.questComplete)
        elseif objectivesComplete > self.completeCount then
          QuestSounds:Play(sounds.objectiveComplete)
        end
      end
    end
  end
end

function QuestSounds:init()
  self:SetScript("OnEvent", function(frame, event, ...)
    local handler = events[event]
    if handler then
      handler(frame, ...)
    end
  end)
  for k,v in pairs(events) do
    self:RegisterEvent(k)
  end
end

function QuestSounds:Play(sound)
  if sound and sound ~= "" then
    PlaySoundFile(sound)
  end
end

function events:UNIT_QUEST_LOG_CHANGED(unit)
  if unit == "player" then
    QuestSounds:checkQuest()
  end
end

function events:QUEST_WATCH_UPDATE(index)
  QuestSounds:setQuest(index)
end

QuestSounds:RegisterEvent("PLAYER_LOGIN")
QuestSounds:SetScript("OnEvent", QuestSounds.init)
