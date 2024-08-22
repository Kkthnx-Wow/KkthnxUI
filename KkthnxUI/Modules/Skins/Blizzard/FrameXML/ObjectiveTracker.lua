local K, C = KkthnxUI[1], KkthnxUI[2]

local tinsert = table.insert
local pairs = pairs

-- Function to reskin headers
local function reskinHeader(header)
	header.Text:SetTextColor(K.r, K.g, K.b)
	header.Background:SetTexture(nil)

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, 0.66, 0, 0.31)
	bg:SetVertexColor(K.r, K.g, K.b, 0.8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)

	header.bg = bg
end

-- Add the theme reskin to default themes
tinsert(C.defaultThemes, function()
	local mainHeader = ObjectiveTrackerFrame.Header
	mainHeader:StripTextures()

	local trackers = {
		ScenarioObjectiveTracker,
		UIWidgetObjectiveTracker,
		CampaignQuestObjectiveTracker,
		QuestObjectiveTracker,
		AdventureObjectiveTracker,
		AchievementObjectiveTracker,
		MonthlyActivitiesObjectiveTracker,
		ProfessionsRecipeTracker,
		BonusObjectiveTracker,
		WorldQuestObjectiveTracker,
	}

	-- Reskin each tracker header in the list
	for _, tracker in pairs(trackers) do
		reskinHeader(tracker.Header)
	end
end)
