local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = _G.table.insert
local pairs = _G.pairs
local unpack = _G.unpack

local hooksecurefunc = _G.hooksecurefunc

local r, g, b = K.r, K.g, K.b
local function reskinQuestIcon(button)
	if not button or button.styled then
		return
	end

	button:SetNormalTexture("")
	button:SetPushedTexture("")
	button:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
	local icon = button.icon or button.Icon
	if icon then
		icon:SetTexCoord(unpack(K.TexCoords))
		local bg = CreateFrame("Frame", nil, button)
		bg:SetAllPoints(icon)
		bg:SetFrameLevel(button:GetFrameLevel())
		bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	end

	button.styled = true
end

local function reskinQuestIcons(_, block)
	reskinQuestIcon(block.itemButton)
	reskinQuestIcon(block.rightButton)
end

local function reskinHeader(header)
	header.Text:SetTextColor(r, g, b)
	header.Background:SetTexture(nil)
	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, .66, 0, .31)
	bg:SetVertexColor(r, g, b, .8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)
end

local function reskinBarTemplate(bar)
	if bar.bg then
		return
	end

	bar:StripTextures()
	bar:SetStatusBarTexture(C["Media"].Texture)
	bar:SetStatusBarColor(r, g, b)
	bar.bg = CreateFrame("Frame", nil, bar)
	bar.bg:SetAllPoints(bar)
	bar.bg:SetFrameLevel(bar:GetFrameLevel())
	bar.bg:CreateBorder()
	K:SmoothBar(bar)
end

local function reskinProgressbar(_, _, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar

	if not bar.bg then
		bar:ClearAllPoints()
		bar:SetPoint("LEFT")
		reskinBarTemplate(bar)
	end
end

local function reskinProgressbarWithIcon(_, _, line)
	local progressBar = line.ProgressBar
	local bar = progressBar.Bar
	local icon = bar.Icon

	if not bar.bg then
		bar:SetPoint("LEFT", 22, 0)
		reskinBarTemplate(bar)
		BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop

		icon:SetMask(nil)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 5, 0)
		icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 25, 0)
	end

	if icon.bg then
		icon.bg:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
	end
end

local function reskinTimerBar(_, _, line)
	local timerBar = line.TimerBar
	local bar = timerBar.Bar

	if not bar.bg then
		reskinBarTemplate(bar)
	end
end

local function ReskinObjectiveTracker()
	-- QuestIcons
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", reskinQuestIcons)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", reskinQuestIcons)
	hooksecurefunc(CAMPAIGN_QUEST_TRACKER_MODULE, "AddObjective", reskinQuestIcons)

	-- Reskin Progressbars
	hooksecurefunc(QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)
	hooksecurefunc(CAMPAIGN_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)

	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", reskinProgressbarWithIcon)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbarWithIcon)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", reskinProgressbarWithIcon)

	hooksecurefunc(QUEST_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)
	hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)

	-- Reskin Headers
	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
		ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader
	}
	for _, header in pairs(headers) do
		reskinHeader(header)
	end

	-- -- Minimize Button
	-- local minimize = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	-- minimize:SetSize(22, 22)
	-- minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	-- minimize:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	-- minimize:SetHighlightTexture(false or "")
	-- minimize:SetDisabledTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButtonDisabled")
	-- minimize:HookScript("OnClick", function()
	-- 	if ObjectiveTrackerFrame.collapsed then
	-- 		minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	-- 	else
	-- 		minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	-- 	end
	-- end)

	-- for _, header in pairs(headers) do
	-- 	local minimize = header.MinimizeButton
	-- 	if minimize then
	-- 		minimize:SetSize(22, 22)
	-- 		minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	-- 		minimize:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	-- 		minimize:SetHighlightTexture(false or "")
	-- 		minimize:SetDisabledTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButtonDisabled")
	-- 		minimize:HookScript("OnClick", function()
	-- 			if header.collapsed then
	-- 				minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	-- 			else
	-- 				minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	-- 			end
	-- 		end)
	-- 	end
	-- end
end

table_insert(Module.NewSkin["KkthnxUI"], ReskinObjectiveTracker)