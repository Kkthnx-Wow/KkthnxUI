local _, C = unpack(KkthnxUI)

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
	local rangeOverlay = item:CreateTexture(nil, "OVERLAY")
	rangeOverlay:SetTexture(C["Media"].Textures.White8x8Texture)
	rangeOverlay:SetAllPoints()
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
	minimize.tex:SetVertexColor(1, 0.6, 0)
	minimize.tex:SetAllPoints()

	hooksecurefunc("ObjectiveTracker_Expand", changedTrackerState)
	hooksecurefunc("ObjectiveTracker_Collapse", changedTrackerState)
	hooksecurefunc("QuestObjectiveSetupBlockButton_Item", reskinItemButton)
	hooksecurefunc(_G.BONUS_OBJECTIVE_TRACKER_MODULE, "AddObjective", reskinItemButton)

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
		header.Background:SetTexture(nil)

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
