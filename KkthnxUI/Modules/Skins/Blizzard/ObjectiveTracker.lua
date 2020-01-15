local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert

local hooksecurefunc = _G.hooksecurefunc
-- local C_QuestLog_IsQuestReplayable = _G.C_QuestLog.IsQuestReplayable -- PartySync

local function ReskinObjectiveTracker()
	local ObjectiveTrackerFrame = _G["ObjectiveTrackerFrame"]
	local TrackerTexture = K.GetTexture(C["UITextures"].QuestTrackerTexture)
	local TrackerFont = K.GetFont(C["UIFonts"].QuestTrackerFonts)

	local function SkinOjectiveTrackerHeaders()
		local frame = ObjectiveTrackerFrame.MODULES

		if frame then
			for i = 1, #frame do
				local modules = frame[i]
				if modules then
					local header = modules.Header

					local background = modules.Header.Background
					background:SetAtlas(nil)

					local text = modules.Header.Text
					text:SetFontObject(TrackerFont)
					text:SetFont(select(1, text:GetFont()), 15, select(3, text:GetFont()))
					text:SetParent(header)

					if not modules.IsSkinned then
						local headerPanel = _G.CreateFrame("Frame", nil, header)
						headerPanel:SetFrameLevel(header:GetFrameLevel() - 1)
						headerPanel:SetFrameStrata("BACKGROUND")
						headerPanel:SetPoint("TOPLEFT", 1, 1)
						headerPanel:SetPoint("BOTTOMRIGHT", 1, 1)

						local headerBar = headerPanel:CreateTexture(nil, "ARTWORK")
						headerBar:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
						headerBar:SetTexCoord(0, 0.6640625, 0, 0.3125)
						headerBar:SetVertexColor(K.Colors.class[K.Class][1], K.Colors.class[K.Class][2], K.Colors.class[K.Class][3], K.Colors.class[K.Class][4])
						headerBar:SetPoint("CENTER", headerPanel, -20, -4)
						headerBar:SetSize(232, 30)

						modules.IsSkinned = true
					end
				end
			end
		end
	end

	local MinimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	MinimizeButton:SetSize(22, 22)
	MinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	MinimizeButton:SetPushedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	MinimizeButton:SetHighlightTexture(false or "")
	MinimizeButton:SetDisabledTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButtonDisabled")
	MinimizeButton:HookScript("OnClick", function()
		if ObjectiveTrackerFrame.collapsed then
			MinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		else
			MinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		end
	end)

	local function SkinItemButton(_, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(24, 24)
			item:CreateShadow()
			item.highlight = item:CreateTexture(nil, "HIGHLIGHT")
			item.highlight:SetAllPoints()
			item.highlight:SetColorTexture(1, 1, 1, .25)
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			item.icon:SetAllPoints()
			item.Cooldown:SetAllPoints()
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFontObject(TrackerFont)
			item.Count:SetShadowOffset(5, -5)
			item.skinned = true
		end
	end

	local function SkinProgressBars(_, _, line)
		local progressBar = line and line.ProgressBar
		local bar = progressBar and progressBar.Bar
		if not bar then
			return
		end

		local r, g, b = K.r, K.g, K.b
		local icon = bar.Icon
		local label = bar.Label
		if not progressBar.isSkinned then
			if bar.BarFrame then
				bar.BarFrame:Hide()
			end

			if bar.BarFrame2 then
				bar.BarFrame2:Hide()
			end

			if bar.BarFrame3 then
				bar.BarFrame3:Hide()
			end

			if bar.BarGlow then
				bar.BarGlow:Hide()
			end

			if bar.Sheen then
				bar.Sheen:Hide()
			end

			if bar.IconBG then
				bar.IconBG:SetAlpha(0)
			end

			if bar.BorderLeft then
				bar.BorderLeft:SetAlpha(0)
			end

			if bar.BorderRight then
				bar.BorderRight:SetAlpha(0)
			end

			if bar.BorderMid then
				bar.BorderMid:SetAlpha(0)
			end

			bar:SetHeight(18)
			bar:StripTextures()
			bar:CreateShadow(true)
			bar:SetStatusBarTexture(TrackerTexture)
			bar:GetStatusBarTexture():SetGradient("VERTICAL", r * 0.9, g * 0.9, b * 0.9, r * 0.4, g * 0.4, b * 0.4)

			bar.spark = bar:CreateTexture(nil, "OVERLAY")
			bar.spark:SetTexture(C["Media"].Spark_16)
			bar.spark:SetHeight(bar:GetHeight() or 18)
			bar.spark:SetBlendMode("ADD")
			bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
			bar.spark:SetAlpha(0.5)

			if label then
				label:ClearAllPoints()
				label:SetPoint("CENTER", bar)
				label:SetFontObject(TrackerFont)
			end

			if icon then
				icon:ClearAllPoints()
				icon:SetSize(18, 18)
				icon:SetPoint("LEFT", bar, "RIGHT", 6, 0)
				icon:SetMask("")
				icon:SetTexCoord(unpack(K.TexCoords))

				if not progressBar.iconShadow then
					progressBar.iconShadow = CreateFrame("Frame", nil, progressBar)
					progressBar.iconShadow:SetAllPoints(icon)
					progressBar.iconShadow:CreateShadow(true)
					progressBar.iconShadow:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
				end
			end

			_G.BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop
			progressBar.isSkinned = true
		elseif icon and progressBar.iconShadow then
			progressBar.iconShadow:SetShown(icon:IsShown() and icon:GetTexture() ~= nil)
		end
	end

	local function SkinTimerBars(_, _, line)
		local timerBar = line and line.TimerBar
		local bar = timerBar and timerBar.Bar

		if not timerBar.isSkinned then
			bar:SetHeight(18)
			bar:StripTextures()
			bar:CreateShadow(true)
			bar:SetStatusBarTexture(TrackerTexture)

			timerBar.isSkinned = true
		end
	end

	local function PositionFindGroupButton(block, button)
		if button and button.GetPoint then
			local a, b, c, d, e = button:GetPoint()
			if block.groupFinderButton and b == block.groupFinderButton and block.itemButton and button == block.itemButton then
				-- this fires when there is a group button and a item button to the left of it
				-- we push the item button away from the group button (to the left)
				button:SetPoint(a, b, c, d - (4 and -1 or 1), e)
			elseif b == block and block.groupFinderButton and button == block.groupFinderButton then
				-- this fires when there is a group finder button
				-- we push the group finder button down slightly
				button:SetPoint(a, b, c, d, e - (4 and 2 or -1))
			end
		end
	end

	local function SkinFindGroupButton(block)
		if block.hasGroupFinderButton and block.groupFinderButton then
			if block.groupFinderButton and not block.groupFinderButton.skinned then
				block.groupFinderButton:SetNormalTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons")
				block.groupFinderButton:GetNormalTexture():ClearAllPoints()
				block.groupFinderButton:GetNormalTexture():SetPoint("CENTER", block.groupFinderButton:GetNormalTexture():GetParent(), -0.6, 0)
				block.groupFinderButton:GetNormalTexture():SetSize(32, 32)
				block.groupFinderButton:GetNormalTexture():SetTexCoord(0.500, 0.625, 0.375, 0.5)

				block.groupFinderButton:SetHighlightTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons")
				block.groupFinderButton:GetHighlightTexture():ClearAllPoints()
				block.groupFinderButton:GetHighlightTexture():SetPoint("CENTER", block.groupFinderButton:GetHighlightTexture():GetParent(), -0.6, 0)
				block.groupFinderButton:GetHighlightTexture():SetSize(32, 32)
				block.groupFinderButton:GetHighlightTexture():SetTexCoord(0.625, 0.750, 0.875, 1)

				block.groupFinderButton:SetPushedTexture("Interface/WorldMap/UI-QuestPoi-NumberIcons")
				block.groupFinderButton:GetPushedTexture():ClearAllPoints()
				block.groupFinderButton:GetPushedTexture():SetPoint("CENTER", block.groupFinderButton:GetPushedTexture():GetParent(), -0.6, 0)
				block.groupFinderButton:GetPushedTexture():SetSize(32, 32)
				block.groupFinderButton:GetPushedTexture():SetTexCoord(0.750, 0.875, 0.375, 0.5)
				block.groupFinderButton.skinned = true
			end
		end
	end

	local function QuestHook(id)
		local questLogIndex = _G.GetQuestLogIndexByID(id)
		if _G.IsControlKeyDown() and _G.CanAbandonQuest(id) then
			_G.QuestMapQuestOptions_AbandonQuest(id)
		elseif _G.IsAltKeyDown() and _G.GetQuestLogPushable(questLogIndex) then
			_G.QuestMapQuestOptions_ShareQuest(id)
		end
	end

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
				-- elseif C_QuestLog_IsQuestReplayable(questID) then -- PartySync
				-- 	title = "|cff00ff00"..title
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

	hooksecurefunc(_G.QUEST_TRACKER_MODULE, "OnBlockHeaderClick", function(_, block) QuestHook(block.id) end)
	hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self) QuestHook(self.questID) end)
	hooksecurefunc("QuestLogQuests_AddQuestButton", Showlevel)
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", PositionFindGroupButton)
	hooksecurefunc("ObjectiveTracker_Update", SkinOjectiveTrackerHeaders)
	hooksecurefunc("QuestObjectiveSetupBlockButton_FindGroup", SkinFindGroupButton)
	hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", SkinProgressBars)
	hooksecurefunc(_G.WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", SkinProgressBars)
	hooksecurefunc(_G.DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", SkinProgressBars)
	hooksecurefunc(_G.SCENARIO_TRACKER_MODULE, "AddProgressBar", SkinProgressBars)
	hooksecurefunc(_G.QUEST_TRACKER_MODULE, "AddTimerBar", SkinTimerBars)
	hooksecurefunc(_G.SCENARIO_TRACKER_MODULE, "AddTimerBar", SkinTimerBars)
	hooksecurefunc(_G.ACHIEVEMENT_TRACKER_MODULE, "AddTimerBar", SkinTimerBars)
	hooksecurefunc(_G.QUEST_TRACKER_MODULE, "SetBlockHeader", SkinItemButton)
	hooksecurefunc(_G.WORLD_QUEST_TRACKER_MODULE, "AddObjective", SkinItemButton)
end

table_insert(Module.NewSkin["KkthnxUI"], ReskinObjectiveTracker)