local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = _G.table.insert
local pairs = _G.pairs
local unpack = _G.unpack

local hooksecurefunc = _G.hooksecurefunc

local function ReskinObjectiveTracker()
	local colorR, colorG, colorB = K.r, K.g, K.b
	local LE_QUEST_FREQUENCY_DAILY = LE_QUEST_FREQUENCY_DAILY or 2
	-- local C_QuestLog_IsQuestReplayable = C_QuestLog.IsQuestReplayable

	local function reskinQuestIcon(_, block)
		local itemButton = block.itemButton
		if itemButton and not itemButton.styled then
			itemButton:SetNormalTexture("")
			itemButton:SetPushedTexture("")
			itemButton.icon:SetTexCoord(unpack(K.TexCoords))
			itemButton:CreateBorder()
			itemButton:CreateInnerShadow()

			itemButton.styled = true
		end

		local rightButton = block.rightButton
		if rightButton and not rightButton.styled then
			rightButton:SetNormalTexture("")
			rightButton:SetPushedTexture("")
			rightButton:SetSize(22, 22)
			rightButton.Icon:SetSize(18, 18)
			rightButton:CreateBorder()
			rightButton:CreateInnerShadow()

			rightButton.styled = true
		end
	end
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", reskinQuestIcon)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", reskinQuestIcon)

	-- Reskin Headers
	local function reskinHeader(header)
		header.Text:SetTextColor(colorR, colorG, colorB)
		header.Background:Hide()

		local headerBG = header:CreateTexture(nil, "ARTWORK")
		headerBG:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
		headerBG:SetTexCoord(0, 0.66, 0, 0.31)
		headerBG:SetVertexColor(colorR, colorG, colorB, 0.8)
		headerBG:SetPoint("BOTTOMLEFT", 0, -4)
		headerBG:SetSize(250, 30)
	end

	local headers = {
		ObjectiveTrackerBlocksFrame.QuestHeader,
		ObjectiveTrackerBlocksFrame.AchievementHeader,
		ObjectiveTrackerBlocksFrame.ScenarioHeader,
		BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		WORLD_QUEST_TRACKER_MODULE.Header,
		ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader
	}

	for _, header in pairs(headers) do
		reskinHeader(header)
	end

	-- Reskin Progressbars
	local function reskinBarTemplate(bar)
		if not bar then
			return
		end

		bar:StripTextures()
		bar:SetStatusBarTexture(C["Media"].Texture)
		bar:SetStatusBarColor(colorR, colorG, colorB)

		bar.spark = bar:CreateTexture(nil, "OVERLAY")
		bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
		bar.spark:SetTexture(C["Media"].Spark_128)
		bar.spark:SetSize(64, bar:GetHeight())
		bar.spark:SetBlendMode("ADD")
		bar.spark:SetAlpha(0.8)

		bar.bg = CreateFrame("Frame", nil, bar)
		bar.bg:SetFrameLevel(bar:GetFrameLevel())
		bar.bg:SetAllPoints(bar)
		bar.bg:CreateBorder()
	end

	local function reskinProgressbar(_, _, line)
		local progressBar = line.ProgressBar
		local bar = progressBar.Bar
		local icon = bar.Icon

		if not bar.bg then
			bar:SetPoint("LEFT", 24, 0)
			reskinBarTemplate(bar)
			BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop

			icon:SetMask(nil)

			icon.bg = CreateFrame("Frame", nil, bar)
			icon.bg:SetFrameLevel(bar:GetFrameLevel())
			icon.bg:SetAllPoints(icon)
			icon.bg:CreateBorder()
			icon.bg:CreateInnerShadow()

			icon:SetTexCoord(unpack(K.TexCoords))
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 6, 0)
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 24, 0)
		end

		if icon.bg then
			icon.bg:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
		end
	end
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", reskinProgressbar)

	hooksecurefunc(QUEST_TRACKER_MODULE, "AddProgressBar", function(_, _, line)
		local progressBar = line.ProgressBar
		local bar = progressBar.Bar

		if not bar.bg then
			bar:ClearAllPoints()
			bar:SetPoint("LEFT")
			reskinBarTemplate(bar)
		end
	end)

	local function reskinTimerBar(_, _, line)
		local timerBar = line.TimerBar
		local bar = timerBar.Bar

		if not bar.bg then
			reskinBarTemplate(bar)
		end
	end
	hooksecurefunc(QUEST_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)
	hooksecurefunc(ACHIEVEMENT_TRACKER_MODULE, "AddTimerBar", reskinTimerBar)

	-- Minimize Button
	local minimize = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	minimize:SetSize(22, 22)
	minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	minimize:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	minimize:SetHighlightTexture(false or "")
	minimize:SetDisabledTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButtonDisabled")
	minimize:HookScript("OnClick", function()
		if ObjectiveTrackerFrame.collapsed then
			minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		else
			minimize:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		end
	end)

	-- Show quest color and level
	local function Showlevel(_, _, _, title, level, _, isHeader, _, isComplete, frequency, questID)
		if ENABLE_COLORBLIND_MODE == "1" then
			return
		end

		for button in pairs(QuestScrollFrame.titleFramePool.activeObjects) do
			if title and not isHeader and button.questID == questID then
				local title = "["..level.."] "..title
				if isComplete then
					title = "|cffff78ff"..title
					--elseif C_QuestLog_IsQuestReplayable(questID) then
					--	title = "|cff00ff00"..title
				elseif frequency == LE_QUEST_FREQUENCY_DAILY then
					title = "|cff3399ff"..title
				end
				button.Text:SetText(title)
				button.Text:SetPoint("TOPLEFT", 24, -5)
				button.Text:SetWidth(205)
				button.Text:SetWordWrap(false)
				button.Check:SetPoint("LEFT", button.Text, button.Text:GetWrappedWidth(), 0)
			end
		end
	end

	hooksecurefunc("QuestLogQuests_AddQuestButton", Showlevel)
end

table_insert(Module.NewSkin["KkthnxUI"], ReskinObjectiveTracker)