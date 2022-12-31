local K, C = unpack(KkthnxUI)

local function reskinHeader(header)
	if not header then
		return
	end

	if header.Background then
		header.Background:SetAtlas(nil)
	end

	if header.Text then
		header.Text:SetTextColor(K.r, K.g, K.b, 0.8)
	end

	local bg = header:CreateTexture(nil, "BACKGROUND")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, 0.66, 0, 0.31)
	bg:SetVertexColor(K.r, K.g, K.b, 0.8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)
	header.bg = bg -- accessable for other addons
end

local function showHotkey(self)
	local item = self:GetParent()
	if item.rangeOverlay then
		item.rangeOverlay:Show()
	end
end

local function hideHotkey(self)
	local item = self:GetParent()
	if item.rangeOverlay then
		item.rangeOverlay:Hide()
	end
end

local function colorHotkey(self, r, g, b)
	local item = self:GetParent()
	if item.rangeOverlay then
		if r == 0.6 and g == 0.6 and b == 0.6 then
			item.rangeOverlay:SetVertexColor(0, 0, 0, 0)
		else
			item.rangeOverlay:SetVertexColor(0.8, 0.1, 0.1, 0.5)
		end
	end
end

local function reskinRangeOverlay(item)
	item:CreateBorder()
	item:SetNormalTexture(0)
	item.KKUI_Border:SetVertexColor(1, 0.82, 0.2)
	item.icon:SetTexCoord(unpack(K.TexCoords))
	item.icon:SetAllPoints()

	local rangeOverlay = item:CreateTexture(nil, "OVERLAY")
	rangeOverlay:SetTexture(C["Media"].Textures.White8x8Texture)
	rangeOverlay:SetAllPoints(item.icon)
	item.rangeOverlay = rangeOverlay

	hooksecurefunc(item.HotKey, "Show", showHotkey)
	hooksecurefunc(item.HotKey, "Hide", hideHotkey)
	hooksecurefunc(item.HotKey, "SetVertexColor", colorHotkey)
	colorHotkey(item.HotKey, item.HotKey:GetTextColor())
	item.HotKey:SetAlpha(0)
end

local function reskinItemButton(block)
	if InCombatLockdown() then
		return
	end -- will break quest item button

	local item = block and block.itemButton
	if not item then
		return
	end

	if not item.skinned then
		reskinRangeOverlay(item)
		item.skinned = true
	end
end

local function reskinProgressBars(_, _, line)
	local progressBar = line and line.ProgressBar
	local bar = progressBar and progressBar.Bar
	if not bar then
		return
	end

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

		if bar and bar:GetHeight() ~= 18 then
			bar:SetHeight(18)
		end
		bar:StripTextures()
		bar:CreateBorder()
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

		if label then
			label:ClearAllPoints()
			label:SetPoint("CENTER", bar)
			label:SetFontObject(K.UIFont)
		end

		if icon then
			if icon:GetHeight() ~= 24 then
				icon:SetSize(24, 24)
			end
			icon:ClearAllPoints()
			icon:SetPoint("LEFT", bar, "RIGHT", 6, 0)
			icon:SetMask("")
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			if not progressBar.KKUI_Backdrop then
				progressBar:CreateBackdrop()
				progressBar.KKUI_Backdrop:SetFrameLevel(7)
				progressBar.KKUI_Backdrop:SetAllPoints(icon)
				progressBar.KKUI_Backdrop:SetShown(icon:IsShown())
			end
		end

		_G.BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop
		progressBar.isSkinned = true
	elseif icon and progressBar.KKUI_Backdrop then
		progressBar.KKUI_Backdrop:SetShown(icon:IsShown())
	end
end

local function reskinTimerBars(_, _, line)
	local timerBar = line and line.TimerBar
	local bar = timerBar and timerBar.Bar

	if not timerBar.isSkinned then
		if bar and bar:GetHeight() ~= 18 then
			bar:SetHeight(18)
		end
		bar:StripTextures()
		bar:CreateBorder()
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

		timerBar.isSkinned = true
	end
end

local function repositionFindGroupButton(block, button)
	if InCombatLockdown() then
		return
	end -- will break quest item button

	if button and button.GetPoint then
		local a, b, c, d, e = button:GetPoint()
		if block.groupFinderButton and b == block.groupFinderButton and block.itemButton and button == block.itemButton then
			-- this fires when there is a group button and a item button to the left of it
			-- we push the item button away from the group button (to the left)
			button:SetPoint(a, b, c, d - 1, e)
		elseif b == block and block.groupFinderButton and button == block.groupFinderButton then
			-- this fires when there is a group finder button
			-- we push the group finder button down slightly
			button:SetPoint(a, b, c, d, e - 1)
		end
	end
end

local function reskinFindGroupButton(block)
	local button = block.hasGroupFinderButton and block.groupFinderButton
	if button then
		button:SkinButton()
		if button:GetHeight() ~= 22 then
			button:SetSize(22, 22)
		end

		local icon = button.icon or button.Icon
		if icon then
			icon:SetAtlas("groupfinder-eye-frame")
			icon:SetAllPoints()
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		end
	end
end

local function changedTrackerState()
	local minimizeButton = _G.ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	minimizeButton:SetNormalTexture(0)
	minimizeButton:SetPushedTexture(0)
	minimizeButton:SetSize(16, 16)
	if _G.ObjectiveTrackerFrame.collapsed then
		minimizeButton.tex:SetTexture(C["Media"].Textures.ArrowTexture)
		minimizeButton.tex:SetRotation(rad(180))
	else
		minimizeButton.tex:SetTexture(C["Media"].Textures.ArrowTexture)
		minimizeButton.tex:SetRotation(rad(0))
	end
end

local function updateMinimizeButton(button, collapsed)
	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	button:SetSize(16, 16)
	if collapsed then
		button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
		button.tex:SetRotation(rad(180))
	else
		button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
		button.tex:SetRotation(rad(0))
	end
end

tinsert(C.defaultThemes, function()
	if IsAddOnLoaded("!KalielsTracker") then
		return
	end

	local minimize = _G.ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	minimize:SetNormalTexture(0)
	minimize:SetPushedTexture(0)
	minimize:SetSize(16, 16)
	minimize:StripTextures()
	minimize:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]], "ADD")
	minimize.tex = minimize:CreateTexture(nil, "OVERLAY")
	minimize.tex:SetTexture(C["Media"].Textures.ArrowTexture)
	minimize.tex:SetDesaturated(true)
	minimize.tex:SetAllPoints()

	hooksecurefunc("ObjectiveTracker_Expand", changedTrackerState)
	hooksecurefunc("ObjectiveTracker_Collapse", changedTrackerState)
	hooksecurefunc("QuestObjectiveSetupBlockButton_Item", reskinItemButton)
	hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddObjective", reskinItemButton)
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", repositionFindGroupButton) --[Move]: The eye & quest item to the left of the eye
	hooksecurefunc("QuestObjectiveSetupBlockButton_FindGroup", reskinFindGroupButton) --[Skin]: The eye
	hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", reskinProgressBars) --[Skin]: Bonus Objective Progress Bar
	hooksecurefunc(_G.WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressBars) --[Skin]: World Quest Progress Bar
	hooksecurefunc(_G.DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", reskinProgressBars) --[Skin]: Quest Progress Bar
	hooksecurefunc(_G.SCENARIO_TRACKER_MODULE, "AddProgressBar", reskinProgressBars) --[Skin]: Scenario Progress Bar
	hooksecurefunc(_G.CAMPAIGN_QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressBars) --[Skin]: Campaign Progress Bar
	hooksecurefunc(_G.QUEST_TRACKER_MODULE, "AddProgressBar", reskinProgressBars) --[Skin]: Quest Progress Bar
	hooksecurefunc(_G.UI_WIDGET_TRACKER_MODULE, "AddProgressBar", reskinProgressBars) --[Skin]: New DF Quest Progress Bar
	hooksecurefunc(_G.QUEST_TRACKER_MODULE, "AddTimerBar", reskinTimerBars) --[Skin]: Quest Timer Bar
	hooksecurefunc(_G.SCENARIO_TRACKER_MODULE, "AddTimerBar", reskinTimerBars) --[Skin]: Scenario Timer Bar
	hooksecurefunc(_G.ACHIEVEMENT_TRACKER_MODULE, "AddTimerBar", reskinTimerBars) --[Skin]: Achievement Timer Bar

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

		local button = header.MinimizeButton
		if button then
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:SetSize(16, 16)
			button.tex = button:CreateTexture(nil, "OVERLAY")
			button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
			button.tex:SetRotation(rad(0))
			button.tex:SetAllPoints()

			hooksecurefunc(button, "SetCollapsed", updateMinimizeButton)
		end
	end
end)
