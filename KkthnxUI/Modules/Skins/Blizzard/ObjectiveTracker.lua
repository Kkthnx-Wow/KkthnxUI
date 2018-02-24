local K, C, L = unpack(select(2, ...))

if K.CheckAddOnState("!KalielsTracker") then
	return
end

local _G = _G
local unpack = unpack
local hooksecurefunc = hooksecurefunc
local next = next
local select = select

local GetNumQuestWatches = _G.GetNumQuestWatches
local GetQuestWatchInfo = _G.GetQuestWatchInfo
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor

local function LoadSkin()
	ObjectiveTrackerBlocksFrame.QuestHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:FontTemplate(nil, 13, "OUTLINE")
	ObjectiveTrackerBlocksFrame.QuestHeader.Text:SetShadowOffset(0, -0)
	ObjectiveTrackerBlocksFrame.AchievementHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:FontTemplate(nil, 13, "OUTLINE")
	ObjectiveTrackerBlocksFrame.AchievementHeader.Text:SetShadowOffset(0, -0)
	ObjectiveTrackerBlocksFrame.ScenarioHeader:StripTextures()
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:FontTemplate(nil, 13, "OUTLINE")
	ObjectiveTrackerBlocksFrame.ScenarioHeader.Text:SetShadowOffset(0, -0)

	BONUS_OBJECTIVE_TRACKER_MODULE.Header:StripTextures()
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:FontTemplate(nil, 13, "OUTLINE")
	BONUS_OBJECTIVE_TRACKER_MODULE.Header.Text:SetShadowOffset(0, -0)
	WORLD_QUEST_TRACKER_MODULE.Header:StripTextures()
	WORLD_QUEST_TRACKER_MODULE.Header.Text:FontTemplate(nil, 13, "OUTLINE")
	WORLD_QUEST_TRACKER_MODULE.Header.Text:SetShadowOffset(0, -0)

	local MinimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	MinimizeButton:SetSize(22, 22)
	MinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	MinimizeButton:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	MinimizeButton:SetHighlightTexture(false or "")
	MinimizeButton:SetDisabledTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButtonDisabled")
	MinimizeButton:HookScript("OnClick", function(self)
		if ObjectiveTrackerFrame.collapsed then
			MinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		else
			MinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		end
	end)

	for _, headerName in next, {"QuestHeader", "AchievementHeader", "ScenarioHeader"} do
        local header = ObjectiveTrackerBlocksFrame[headerName]

        local background = header:CreateTexture(nil, "ARTWORK")
        background:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
        background:SetTexCoord(0, 0.6640625, 0, 0.3125)
        background:SetVertexColor(K.Color.r * 0.7, K.Color.g * 0.7, K.Color.b * 0.7)
        background:SetPoint("BOTTOMLEFT", -30, -4)
        background:SetSize(210, 30)
    end

    for i = 1, select("#", ObjectiveTrackerBlocksFrame:GetChildren()) do
    	local v = select(i, ObjectiveTrackerBlocksFrame:GetChildren())
    	if (v and v.ModuleName and (v.ModuleName == "WORLD_QUEST_TRACKER_MODULE" or v.ModuleName == "BONUS_OBJECTIVE_TRACKER_MODULE")) then
        	local header = v

        	local background = header:CreateTexture(nil, "ARTWORK")
        	background:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
        	background:SetTexCoord(0, 0.6640625, 0, 0.3125)
        	background:SetVertexColor(K.Color.r * 0.7, K.Color.g * 0.7, K.Color.b * 0.7)
        	background:SetPoint("BOTTOMLEFT", -30, -4)
        	background:SetSize(210, 30)
    	end
	end

	local function ColorProgressBars(self, value)
		if not (self.Bar and value) then
			return
		end
		self.Bar:SetStatusBarColorGradient(value, 100)
	end

	local function SkinItemButton(self, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(24, 24)
			item:SetTemplate("ActionButton", true)
			item:SetBackdropBorderColor(1, 1, 0)
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			item.icon:SetAllPoints()
			item.Cooldown:SetPoint("TOPLEFT", 1, -1)
			item.Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(C["Media"].Font, 12, "OUTLINE")
			item.Count:SetShadowOffset(5, -5)
			item.skinned = true
		end
	end

	BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop

	local function SetQuestDifficultyColor()
	for i = 1, GetNumQuestWatches() do
		local questID, _, questIndex = GetQuestWatchInfo(i)
		if not questID then
			break
		end
		local _, level = GetQuestLogTitle(questIndex)
		local col = GetQuestDifficultyColor(level)
		local block = QUEST_TRACKER_MODULE:GetExistingBlock(questID)
		if block then
				block.HeaderText:SetTextColor(col.r, col.g, col.b)
				block.HeaderText.col = col
			end
		end
	end

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

	hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", ColorProgressBars) -- [Color]: Bonus Objective Progress Bar
	hooksecurefunc("ObjectiveTrackerProgressBar_SetValue", ColorProgressBars) -- [Color]: Quest Progress Bar
	hooksecurefunc("ScenarioTrackerProgressBar_SetValue", ColorProgressBars) -- [Color]: Scenario Progress Bar
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", PositionFindGroupButton) -- [Move]: The eye & quest item to the left of the eye
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", SkinItemButton) -- [Skin]: Quest Item Buttons
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", SkinItemButton) -- [Skin]: World Quest Item Buttons
end

tinsert(K.SkinFuncs["KkthnxUI"], LoadSkin)