local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Skins")

local r, g, b = K.r, K.g, K.b
local select, pairs = select, pairs

local function reskinHeader(header)
	header.Text:SetTextColor(r, g, b)
	header.Background:SetTexture(nil)
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, 0.66, 0, 0.31)
	bg:SetVertexColor(r, g, b, 0.8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)
	header.bg = bg -- accessable for other addons
end

tinsert(C.defaultThemes, function()
	if IsAddOnLoaded("!KalielsTracker") then
		return
	end

	-- Reskin Progressbars
	BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop

	-- Reskin Headers
	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		ObjectiveTrackerBlocksFrame.ProfessionHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
		ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader,
	}
	for _, header in pairs(headers) do
		reskinHeader(header)
	end
end)
