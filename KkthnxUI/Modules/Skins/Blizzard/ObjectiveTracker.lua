local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = _G.table.insert
local pairs = _G.pairs
local unpack = _G.unpack

local hooksecurefunc = _G.hooksecurefunc

local function AffixesSetup(self)
	for _, frame in ipairs(self.Affixes) do
		frame.Border:SetTexture(nil)
		frame.Portrait:SetTexture(nil)
		if not frame.bg then
			frame.Portrait:SetTexCoord(unpack(K.TexCoords))
			frame.bg = CreateFrame("Frame", nil, frame)
			frame.bg:SetFrameLevel(frame:GetFrameLevel())
			frame.bg:SetAllPoints(frame.Portrait)
			frame.bg:CreateBorder()
		end

		if frame.info then
			frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
		elseif frame.affixID then
			local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
			frame.Portrait:SetTexture(filedataid)
		end
	end
end

local function ReskinObjectiveTracker()
	local colorR, colorG, colorB = K.r, K.g, K.b
	local LE_QUEST_FREQUENCY_DAILY = LE_QUEST_FREQUENCY_DAILY or 2
	local C_QuestLog_IsQuestReplayable = C_QuestLog.IsQuestReplayable

	local function reskinQuestIcon(_, block)
		local itemButton = block.itemButton
		if itemButton and not itemButton.styled then
			itemButton:SetNormalTexture("")
			itemButton:SetPushedTexture("")
			itemButton:GetHighlightTexture():SetColorTexture(1, 1, 1, .25)
			itemButton.icon:SetTexCoord(unpack(K.TexCoords))
			itemButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

			itemButton.styled = true
		end

		local rightButton = block.rightButton
		if rightButton and not rightButton.styled then
			rightButton:SetNormalTexture("")
			rightButton:SetPushedTexture("")
			rightButton:SetSize(22, 22)
			rightButton.Icon:SetPoint("TOPLEFT", rightButton, "TOPLEFT", 1, -1)
			rightButton.Icon:SetPoint("BOTTOMRIGHT", rightButton, "BOTTOMRIGHT", -1, 1)
			rightButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

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

		local text = header.Text
		text:SetFontObject(K.GetFont(C["UIFonts"].QuestTrackerFonts))
		text:SetFont(select(1, text:GetFont()), 13, select(3, text:GetFont()))
		text:SetParent(header)
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
		bar:SetHeight(18)

		bar.spark = bar:CreateTexture(nil, "OVERLAY")
		bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
		bar.spark:SetTexture(C["Media"].Spark_128)
		bar.spark:SetSize(32, bar:GetHeight())
		bar.spark:SetBlendMode("ADD")
		bar.spark:SetAlpha(0.9)

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
			if not icon.bg then
				icon.bg = CreateFrame("Frame", nil, bar)
				icon.bg:SetFrameLevel(bar:GetFrameLevel())
				icon.bg:SetAllPoints(icon)
				icon.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
			end

			icon:SetTexCoord(unpack(K.TexCoords))
			icon:ClearAllPoints()
			icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 6, 0)
			icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 24, 0)
			icon:SetDrawLayer("BACKGROUND", 0) -- -1
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

	-- Reskin Blocks
	hooksecurefunc("ScenarioStage_CustomizeBlock", function(block)
		block.NormalBG:SetTexture("")
		if not block.bg then
			block.bg = CreateFrame("Frame", nil, block)
			block.bg:SetPoint("TOPLEFT", block.GlowTexture, 4, -2)
			block.bg:SetPoint("BOTTOMRIGHT", block.GlowTexture, -4, 2)
			block.bg:SetFrameLevel(block:GetFrameLevel())
			block.bg:CreateBorder()
		end
	end)

	hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "Update", function()
		local widgetContainer = ScenarioStageBlock.WidgetContainer
		if not widgetContainer then
			return
		end

		local widgetFrame = widgetContainer:GetChildren()
		if widgetFrame and widgetFrame.Frame then
			widgetFrame.Frame:SetAlpha(0)
			for _, bu in next, {widgetFrame.CurrencyContainer:GetChildren()} do
				if bu and not bu.styled then
					bu.Icon:SetTexCoord(unpack(K.TexCoords))
					bu.bg = CreateFrame("Frame", nil, bu)
					bu.bg:SetAllPoints(bu.Icon)
					bu.bg:SetFrameLevel(bu:GetFrameLevel())
					bu.bg:CreateBorder(nil, nil, 10, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
					bu.styled = true
				end
			end
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_ShowBlock", function()
		local block = ScenarioChallengeModeBlock
		if not block.bg then
			block.TimerBG:Hide()
			block.TimerBGBack:Hide()
			block.timerbg = CreateFrame("Frame", nil, block)
			block.timerbg:SetPoint("TOPLEFT", block.TimerBGBack, 6, -2)
			block.timerbg:SetPoint("BOTTOMRIGHT", block.TimerBGBack, -6, -5)
			block.timerbg:CreateBorder()

			block.StatusBar:SetStatusBarTexture(C["Media"].Texture)
			block.StatusBar:SetStatusBarColor(colorR, colorG, colorB)
			block.StatusBar:SetHeight(10)

			select(3, block:GetRegions()):Hide()
			block.bg = CreateFrame("Frame", nil, block)
			block.bg:SetPoint("TOPLEFT", block, 4, -2)
			block.bg:SetPoint("BOTTOMRIGHT", block, -4, 0)
			block.bg:SetFrameLevel(block:GetFrameLevel())
			block.bg:CreateBorder()
		end
	end)

	hooksecurefunc("Scenario_ChallengeMode_SetUpAffixes", AffixesSetup)

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
				if isComplete then
					title = "|cffff78ff"..title
				elseif C_QuestLog_IsQuestReplayable(questID) then
					title = "|cff00ff00"..title
				elseif frequency == LE_QUEST_FREQUENCY_DAILY then
					title = "|cff3399ff"..title
				else
					title = "["..level.."] "..title
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