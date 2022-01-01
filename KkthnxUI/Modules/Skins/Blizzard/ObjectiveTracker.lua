local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Skins")

local _G = _G
local pairs = _G.pairs
local string_find = _G.string.find
local table_insert = _G.table.insert
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

-- Handle collapse
local function updateCollapseTexture(texture, collapsed)
	local atlas = collapsed and "Soulbinds_Collection_CategoryHeader_Expand" or "Soulbinds_Collection_CategoryHeader_Collapse"
	texture:SetAtlas(atlas, true)
end

local function resetCollapseTexture(self, texture)
	if self.settingTexture then
		return
	end

	self.settingTexture = true
	self:SetNormalTexture("")

	if texture and texture ~= "" then
		if string_find(texture, "Plus") or string_find(texture, "Closed") then
			self.__texture:DoCollapse(true)
		elseif string_find(texture, "Minus") or string_find(texture, "Open") then
			self.__texture:DoCollapse(false)
		end
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

function Module:ReskinCollapse(isAtlas)
	self:SetHighlightTexture("")
	self:SetPushedTexture("")

	local bg = CreateFrame("Frame", nil, self, "BackdropTemplate")
	bg:SetAllPoints(self)
	bg:SetFrameLevel(self:GetFrameLevel())
	bg:CreateBorder()

	bg:ClearAllPoints()
	bg:SetSize(13, 13)
	bg:SetPoint("TOPLEFT", self:GetNormalTexture())
	self.bg = bg

	self.__texture = bg:CreateTexture(nil, "OVERLAY")
	self.__texture:SetPoint("CENTER")
	self.__texture.DoCollapse = updateCollapseTexture

	if isAtlas then
		hooksecurefunc(self, "SetNormalAtlas", resetCollapseTexture)
	else
		hooksecurefunc(self, "SetNormalTexture", resetCollapseTexture)
	end
end

local function reskinQuestIcon(button)
	if not button then
		return
	end

	if not button.SetNormalTexture then -- https://github.com/siweia/NDui/issues/113
		return
	end

	if not button.styled then
		--button:SetSize(28, 28)
		button:SetNormalTexture("")
		button:SetPushedTexture("")

		local icon = button.icon or button.Icon
		if icon then
			icon:SetTexCoord(unpack(K.TexCoords))
			icon:SetAllPoints(button)

			button.bg = CreateFrame("Frame", nil, button)
			button.bg:SetAllPoints(button)
			button.bg:CreateBorder()
		end

		button.styled = true
	end

	if button.bg then
		button.bg:SetFrameLevel(button:GetFrameLevel())
	end
end

local function reskinQuestIcons(_, block)
	reskinQuestIcon(block.itemButton)
	reskinQuestIcon(block.groupFinderButton)
end

local function reskinHeader(header)
	header.Background:SetTexture(nil)
	header.Text:SetTextColor(255/255, 204/255, 102/255)
	header.Text:SetFontObject(K.GetFont(C["UIFonts"].QuestTrackerFonts))
	header.Text:SetFont(select(1, header.Text:GetFont()), 15, select(3, header.Text:GetFont()))
end

local function reskinBarTemplate(bar)
	if bar.bg then
		return
	end

	bar:StripTextures()
	bar:SetSize(182, 18)
	bar:SetStatusBarTexture(K.GetTexture(C["UITextures"].QuestTrackerTexture))

	if bar.Label then
		bar.Label:SetPoint("CENTER", 0, 0)
		bar.Label:SetFontObject(K.GetFont(C["UIFonts"].QuestTrackerFonts))
	end

	if not bar.Spark then
		bar.Spark = bar:CreateTexture(nil, "OVERLAY")
		bar.Spark:SetWidth(128)
		bar.Spark:SetHeight(bar:GetHeight())
		bar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		bar.Spark:SetBlendMode("ADD")
		bar.Spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
		bar.Spark:SetAlpha(0.5)
	end

	bar.bg = CreateFrame("Frame", nil, bar)
	bar.bg:SetAllPoints(bar)
	bar.bg:SetFrameLevel(bar:GetFrameLevel())
	bar.bg:CreateBorder()
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

		icon:SetMask(nil)

		icon.bg = CreateFrame("Frame", nil, bar)
		icon.bg:SetAllPoints(icon)
		icon.bg:SetFrameLevel(bar:GetFrameLevel())
		icon.bg:CreateBorder()

		icon:SetTexCoord(unpack(K.TexCoords))
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 6, 0)
		icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 24, 0)
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

local function updateMinimizeButton(button, collapsed)
	button.__texture:DoCollapse(collapsed)
end

local function reskinMinimizeButton(button)
	Module.ReskinCollapse(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)

	button.__texture:DoCollapse(false)

	hooksecurefunc(button, "SetCollapsed", updateMinimizeButton)
end

local function AddQuestNumString()
	local questNum = 0
	local q, o
	local block = _G.ObjectiveTrackerBlocksFrame
	local frame = _G.ObjectiveTrackerFrame

	if not InCombatLockdown() then
		for questLogIndex = 1, C_QuestLog.GetNumQuestLogEntries() do
			local info = C_QuestLog.GetInfo(questLogIndex)
			if info and not info.isHeader and not info.isHidden then
				questNum = questNum + 1
			end
		end

		if questNum >= (MAX_QUESTS - 5) then -- go red
			q = string.format("|cffff0000%d/%d|r %s", questNum, MAX_QUESTS, TRACKER_HEADER_QUESTS)
			o = string.format("|cffff0000%d/%d|r %s", questNum, MAX_QUESTS, OBJECTIVES_TRACKER_LABEL)
		else
			q = string.format("%d/%d %s", questNum, MAX_QUESTS, TRACKER_HEADER_QUESTS)
			o = string.format("%d/%d %s", questNum, MAX_QUESTS, OBJECTIVES_TRACKER_LABEL)
		end

		block.QuestHeader.Text:SetText(q)
		frame.HeaderMenu.Title:SetText(o)
	end
end

table_insert(C.defaultThemes, function()
	-- QuestIcons
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", reskinQuestIcons)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", reskinQuestIcons)
	hooksecurefunc(CAMPAIGN_QUEST_TRACKER_MODULE, "AddObjective", reskinQuestIcons)
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddObjective", reskinQuestIcons)

	-- Reskin Progressbars
	BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop

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

	-- Minimize Button
	local mainMinimize = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	reskinMinimizeButton(mainMinimize)
	mainMinimize.bg.KKUI_Border:SetVertexColor(1, .8, 0)

	for _, header in pairs(headers) do
		local minimize = header.MinimizeButton
		if minimize then
			reskinMinimizeButton(minimize)
		end
	end

	hooksecurefunc("ObjectiveTracker_Update", AddQuestNumString)
end)