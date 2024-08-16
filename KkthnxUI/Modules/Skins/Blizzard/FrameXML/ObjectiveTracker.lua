local K, C = KkthnxUI[1], KkthnxUI[2]

local function reskinHeader(header)
	header.Text:SetTextColor(K.r, K.g, K.b)
	header.Background:SetTexture(nil)
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, 0.66, 0, 0.31)
	bg:SetVertexColor(K.r, K.g, K.b, 0.8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)
	header.bg = bg -- accessable for other addons
end

tinsert(C.defaultThemes, function()
	-- Reskin Headers
	local mainHeader = ObjectiveTrackerFrame.Header
	mainHeader:StripTextures() -- main header looks simple this way

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
	for _, tracker in pairs(trackers) do
		reskinHeader(tracker.Header)
	end
end)
