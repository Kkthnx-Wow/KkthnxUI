local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Skins")

local r, g, b = K.r, K.g, K.b
local select, pairs = select, pairs

local function reskinHeader(header)
	if not header then
		return
	end

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

	-- Reskin Headers
	local headers = {
		_G.ObjectiveTrackerBlocksFrame.QuestHeader,
		_G.ObjectiveTrackerBlocksFrame.AchievementHeader,
		_G.ObjectiveTrackerBlocksFrame.ScenarioHeader,
		_G.ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		_G.ObjectiveTrackerBlocksFrame.ProfessionHeader,
		_G.BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		_G.WORLD_QUEST_TRACKER_MODULE.Header,
		_G.ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader,
	}
	for _, header in pairs(headers) do
		reskinHeader(header)
	end
end)
