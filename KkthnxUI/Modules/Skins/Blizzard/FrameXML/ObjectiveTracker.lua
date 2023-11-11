local K, C = KkthnxUI[1], KkthnxUI[2]

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
			item.rangeOverlay:SetVertexColor(1, 1, 1)
		else
			item.rangeOverlay:SetVertexColor(1, 0, 0)
		end
	end
end

local function reskinRangeOverlay(item)
	item:CreateBorder()
	item:SetNormalTexture(0)
	item.KKUI_Border:SetVertexColor(1, 0.82, 0.2)
	item.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	item.icon:SetAllPoints()

	local rangeOverlay = item:CreateTexture(nil, "OVERLAY")
	rangeOverlay:SetTexture(C["Media"].Textures.White8x8Texture)
	rangeOverlay:SetAllPoints(item.icon)
	rangeOverlay:SetBlendMode("MOD")
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

		bar:StripTextures()
		bar:CreateBorder()
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

		if label then
			label:ClearAllPoints()
			label:SetPoint("CENTER", bar)
			label:SetFontObject(K.UIFont)
		end

		if icon then
			icon:SetSize(26, 26)
			icon:SetMask("")
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			if not progressBar.KKUI_Backdrop then
				progressBar:CreateBackdrop()
				progressBar.KKUI_Backdrop:SetFrameLevel(6)
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
		bar:SetHeight(18)
		bar:StripTextures()
		bar:CreateBorder()
		bar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

		timerBar.isSkinned = true
	end
end

-- Repositions the Find Group button and/or the item button for a given block.
local function repositionFindGroupButton(block, button)
	-- Check if we are currently in combat lockdown, which could break the quest item button.
	if InCombatLockdown() then
		return -- Return early if we are in combat lockdown.
	end

	-- Check if a button was passed in and has a valid point.
	if not button or not button.GetPoint then
		return -- Return early if no valid button was passed in.
	end

	-- Get the current point of the button.
	local point, relativeTo, relativePoint, xOffset, yOffset = button:GetPoint()

	-- Reposition the item button if it is to the left of the group finder button.
	if block.groupFinderButton and relativeTo == block.groupFinderButton and block.itemButton and button == block.itemButton then
		xOffset = xOffset - 1 -- Move the item button one pixel to the left of the group finder button.
		button:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
	end

	-- Reposition the group finder button if it is a child of the block frame.
	if relativeTo == block and block.groupFinderButton and button == block.groupFinderButton then
		yOffset = yOffset - 1 -- Move the group finder button one pixel down.
		button:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
	end
end

-- Reskins the Find Group button for a given block.
local function reskinFindGroupButton(block)
	-- Check if the block has a Find Group button.
	local findGroupButton = block.hasGroupFinderButton and block.groupFinderButton
	if not findGroupButton then
		return -- No Find Group button found, so return early.
	end

	-- Apply a custom skin to the Find Group button.
	findGroupButton:SkinButton()

	-- Set the size of the Find Group button to 22x22 pixels.
	findGroupButton:SetSize(22, 22)

	-- Set the texture and texture coordinates for the Find Group button icon.
	local findGroupButtonIcon = findGroupButton.icon or findGroupButton.Icon
	if findGroupButtonIcon then
		findGroupButtonIcon:SetAtlas("groupfinder-eye-frame")
		findGroupButtonIcon:SetAllPoints()
		local texCoords = K.TexCoords
		findGroupButtonIcon:SetTexCoord(texCoords[1], texCoords[2], texCoords[3], texCoords[4])
	end
end

local function changedTrackerState()
	local minimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
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

	local minimize = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
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
		_G.BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		-- _G.MONTHLY_ACTIVITIES_TRACKER_MODULE,
		_G.ObjectiveTrackerBlocksFrame.AchievementHeader,
		_G.ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		_G.ObjectiveTrackerBlocksFrame.ProfessionHeader,
		_G.ObjectiveTrackerBlocksFrame.QuestHeader,
		_G.ObjectiveTrackerBlocksFrame.ScenarioHeader,
		_G.ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader,
		_G.WORLD_QUEST_TRACKER_MODULE.Header,
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
