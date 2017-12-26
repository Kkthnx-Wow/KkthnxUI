local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("ObjectiveTrackerSkin", "AceHook-3.0")

local unpack = unpack
local hooksecurefunc = hooksecurefunc

-- GLOBALS: ObjectiveTrackerBlocksFrame, ObjectiveTrackerFrame, BonusObjectiveTrackerProgressBar_PlayFlareAnim
-- GLOBALS: SCENARIO_TRACKER_MODULE, BONUS_OBJECTIVE_TRACKER_MODULE, WORLD_QUEST_TRACKER_MODULE, QUEST_TRACKER_MODULE, DEFAULT_OBJECTIVE_TRACKER_MODULE

local function StatusBarColorGradient(bar, value, max)
    local current = (not max and value) or (value and max and max ~= 0 and value/max)
    if not (bar and current) then return end
    local r, g, b = K.ColorGradient(current, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
    bar:SetStatusBarColor(r, g, b)
end

function Module:OnInitialize()
	ObjectiveTrackerBlocksFrame.QuestHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:FontTemplate(nil, 13, "")
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetShadowOffset(1.25, -1.25)
	ObjectiveTrackerBlocksFrame.AchievementHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:FontTemplate(nil, 13, "")
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetShadowOffset(1.25, -1.25)
	ObjectiveTrackerBlocksFrame.ScenarioHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:FontTemplate(nil, 13, "")
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetShadowOffset(1.25, -1.25)

	BONUS_OBJECTIVE_TRACKER_MODULE.Header:StripTextures()
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:FontTemplate(nil, 13, "")
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetShadowOffset(1.25, -1.25)
	WORLD_QUEST_TRACKER_MODULE.Header:StripTextures()
	WORLD_QUEST_TRACKER_MODULE.Header.Text:FontTemplate(nil, 13, "")
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetShadowOffset(1.25, -1.25)

	for _, headerName in next, {"QuestHeader", "AchievementHeader", "ScenarioHeader"} do
        local header = ObjectiveTrackerBlocksFrame[headerName]

        local background = header:CreateTexture(nil, "ARTWORK")
        background:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
        background:SetTexCoord(0, 0.6640625, 0, 0.3125)
        background:SetVertexColor(K.Color.r * 0.7, K.Color.g * 0.7, K.Color.b * 0.7)
        background:SetPoint("BOTTOMLEFT", -24, -4)
        background:SetSize(200, 24)
    end

	local function ColorProgressBars(self, value)
		if not (self.Bar and value) then return end
		StatusBarColorGradient(self.Bar, value, 100)
	end

	BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop

	local function PositionFindGroupButton(block, button)
		if button and button.GetPoint then
			local a, b, c, d, e = button:GetPoint()
			if block.groupFinderButton and b == block.groupFinderButton and block.itemButton and button == block.itemButton then
				-- this fires when there is a group button and a item button to the left of it
				-- we push the item button away from the group button (to the left)
				button:SetPoint(a, b, c, d-(4 and -1 or 1), e)
			elseif b == block and block.groupFinderButton and button == block.groupFinderButton then
				-- this fires when there is a group finder button
				-- we push the group finder button down slightly
				button:SetPoint(a, b, c, d, e-(4 and 2 or -1))
			end
		end
	end


	hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", ColorProgressBars) --[Color]: Bonus Objective Progress Bar
	hooksecurefunc("ObjectiveTrackerProgressBar_SetValue", ColorProgressBars) --[Color]: Quest Progress Bar
	hooksecurefunc("ScenarioTrackerProgressBar_SetValue", ColorProgressBars) --[Color]: Scenario Progress Bar
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", PositionFindGroupButton) --[Move]: The eye & quest item to the left of the eye
end