local K, C = KkthnxUI[1], KkthnxUI[2]
local tinsert = table.insert
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

-- Reskin header function
local function ReskinObjectiveHeader(header)
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
	header.bg = bg -- Accessible for other addons
end

-- Show hotkey function
local function ShowHotkey(self)
	local item = self:GetParent()
	if item.rangeOverlay then
		item.rangeOverlay:Show()
	end
end

-- Hide hotkey function
local function HideHotkey(self)
	local item = self:GetParent()
	if item.rangeOverlay then
		item.rangeOverlay:Hide()
	end
end

-- Color hotkey function
local function ColorHotkey(self, r, g, b)
	local item = self:GetParent()
	if item.rangeOverlay then
		if r == 0.6 and g == 0.6 and b == 0.6 then
			item.rangeOverlay:SetVertexColor(1, 1, 1)
		else
			item.rangeOverlay:SetVertexColor(1, 0, 0)
		end
	end
end

-- Reskin range overlay function
local function ReskinRangeOverlay(item)
	item:CreateBorder()
	item:SetNormalTexture(0)
	item.KKUI_Border:SetVertexColor(1, 0.82, 0.2)
	item.icon:SetTexCoord(unpack(K.TexCoords))
	item.icon:SetAllPoints()

	local rangeOverlay = item:CreateTexture(nil, "OVERLAY")
	rangeOverlay:SetTexture(C["Media"].Textures.White8x8Texture)
	rangeOverlay:SetAllPoints(item.icon)
	rangeOverlay:SetBlendMode("MOD")
	item.rangeOverlay = rangeOverlay

	hooksecurefunc(item.HotKey, "Show", ShowHotkey)
	hooksecurefunc(item.HotKey, "Hide", HideHotkey)
	hooksecurefunc(item.HotKey, "SetVertexColor", ColorHotkey)
	ColorHotkey(item.HotKey, item.HotKey:GetTextColor())
	item.HotKey:SetAlpha(0)
end

-- Reskin item button function
local function ReskinItemButton(block)
	if InCombatLockdown() then
		return
	end

	local item = block and block.itemButton
	if not item then
		return
	end

	if not item.skinned then
		ReskinRangeOverlay(item)
		item.skinned = true
	end
end

-- Reskin progress bars function
local function ReskinProgressBars(_, _, line)
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
			icon:SetTexCoord(unpack(K.TexCoords))
			if not progressBar.KKUI_Backdrop then
				progressBar:CreateBackdrop()
				progressBar.KKUI_Backdrop:SetFrameLevel(6)
				progressBar.KKUI_Backdrop:SetAllPoints(icon)
				progressBar.KKUI_Backdrop:SetShown(icon:IsShown())
			end
		end

		progressBar.PlayFlareAnim = K.Noop

		progressBar.isSkinned = true
	elseif icon and progressBar.KKUI_Backdrop then
		progressBar.KKUI_Backdrop:SetShown(icon:IsShown())
	end
end

-- Reskin timer bars function
local function ReskinTimerBars(_, _, line)
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

-- Reposition find group button function
local function RepositionFindGroupButton(block, button)
	if InCombatLockdown() then
		return
	end

	if not button or not button.GetPoint then
		return
	end

	local point, relativeTo, relativePoint, xOffset, yOffset = button:GetPoint()

	if block.groupFinderButton and relativeTo == block.groupFinderButton and block.itemButton and button == block.itemButton then
		xOffset = xOffset - 1
		button:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
	end

	if relativeTo == block and block.groupFinderButton and button == block.groupFinderButton then
		yOffset = yOffset - 1
		button:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset)
	end
end

-- Reskin find group button function
local function ReskinFindGroupButton(block)
	local findGroupButton = block.hasGroupFinderButton and block.groupFinderButton
	if not findGroupButton then
		return
	end

	findGroupButton:SkinButton()
	findGroupButton:SetSize(22, 22)

	local findGroupButtonIcon = findGroupButton.icon or findGroupButton.Icon
	if findGroupButtonIcon then
		findGroupButtonIcon:SetAtlas("groupfinder-eye-frame")
		findGroupButtonIcon:SetAllPoints()
		local texCoords = K.TexCoords
		findGroupButtonIcon:SetTexCoord(unpack(texCoords))
	end
end

-- Update minimize button function
local function UpdateMinimizeButton(button, collapsed)
	button:SetNormalTexture(0)
	button:SetPushedTexture(0)
	button:SetSize(16, 16)
	if collapsed then
		button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
		button.tex:SetRotation(math.rad(180))
	else
		button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
		button.tex:SetRotation(math.rad(0))
	end
end

-- Change tracker state function
local function ChangeTrackerState()
	local minimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	UpdateMinimizeButton(minimizeButton, _G.ObjectiveTrackerFrame.collapsed)
end

-- Register skinning functions
tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if C_AddOns.IsAddOnLoaded("!KalielsTracker") then
		return
	end

	local minimizeButton = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	minimizeButton:SetNormalTexture(0)
	minimizeButton:SetPushedTexture(0)
	minimizeButton:SetSize(16, 16)
	minimizeButton:StripTextures()
	minimizeButton:SetHighlightTexture([[Interface\Buttons\UI-PlusButton-Hilight]], "ADD")
	minimizeButton.tex = minimizeButton:CreateTexture(nil, "OVERLAY")
	minimizeButton.tex:SetTexture(C["Media"].Textures.ArrowTexture)
	minimizeButton.tex:SetDesaturated(true)
	minimizeButton.tex:SetAllPoints()

	hooksecurefunc("ObjectiveTracker_Expand", ChangeTrackerState)
	hooksecurefunc("ObjectiveTracker_Collapse", ChangeTrackerState)
	hooksecurefunc("QuestObjectiveSetupBlockButton_Item", ReskinItemButton)
	hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddObjective", ReskinItemButton)
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", RepositionFindGroupButton)
	hooksecurefunc("QuestObjectiveSetupBlockButton_FindGroup", ReskinFindGroupButton)
	hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", ReskinProgressBars)
	hooksecurefunc(_G.WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", ReskinProgressBars)
	hooksecurefunc(_G.DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", ReskinProgressBars)
	hooksecurefunc(_G.SCENARIO_TRACKER_MODULE, "AddProgressBar", ReskinProgressBars)
	hooksecurefunc(_G.CAMPAIGN_QUEST_TRACKER_MODULE, "AddProgressBar", ReskinProgressBars)
	hooksecurefunc(_G.QUEST_TRACKER_MODULE, "AddProgressBar", ReskinProgressBars)
	hooksecurefunc(_G.UI_WIDGET_TRACKER_MODULE, "AddProgressBar", ReskinProgressBars)
	hooksecurefunc(_G.QUEST_TRACKER_MODULE, "AddTimerBar", ReskinTimerBars)
	hooksecurefunc(_G.SCENARIO_TRACKER_MODULE, "AddTimerBar", ReskinTimerBars)
	hooksecurefunc(_G.ACHIEVEMENT_TRACKER_MODULE, "AddTimerBar", ReskinTimerBars)

	-- Reskin Headers
	local headers = {
		_G.BONUS_OBJECTIVE_TRACKER_MODULE.Header,
		_G.ObjectiveTrackerBlocksFrame.AchievementHeader,
		_G.ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
		_G.ObjectiveTrackerBlocksFrame.ProfessionHeader,
		_G.ObjectiveTrackerBlocksFrame.QuestHeader,
		_G.ObjectiveTrackerBlocksFrame.ScenarioHeader,
		_G.ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader,
		_G.WORLD_QUEST_TRACKER_MODULE.Header,
	}
	for _, header in pairs(headers) do
		ReskinObjectiveHeader(header)

		local button = header.MinimizeButton
		if button then
			button:SetNormalTexture(0)
			button:SetPushedTexture(0)
			button:SetSize(16, 16)
			button.tex = button:CreateTexture(nil, "OVERLAY")
			button.tex:SetTexture(C["Media"].Textures.ArrowTexture)
			button.tex:SetRotation(math.rad(0))
			button.tex:SetAllPoints()

			hooksecurefunc(button, "SetCollapsed", UpdateMinimizeButton)
		end
	end
end)
