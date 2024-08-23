local K, C = KkthnxUI[1], KkthnxUI[2]

local tinsert = table.insert
local pairs = pairs

-- Function to reskin headers
local function reskinHeader(header)
	header.Text:SetTextColor(K.r, K.g, K.b)
	header.Background:SetTexture(nil)

	local bg = header:CreateTexture(nil, "ARTWORK")
	bg:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
	bg:SetTexCoord(0, 0.66, 0, 0.31)
	bg:SetVertexColor(K.r, K.g, K.b, 0.8)
	bg:SetPoint("BOTTOMLEFT", 0, -4)
	bg:SetSize(250, 30)

	header.bg = bg
end

-- Handle collapse
local function UpdateCollapseIcon(texture, collapsed)
	local atlas = collapsed and "Soulbinds_Collection_CategoryHeader_Expand" or "Soulbinds_Collection_CategoryHeader_Collapse"
	texture:SetAtlas(atlas, true)
end

local function ResetCollapseIcon(self, texture)
	if self.settingTexture then
		return
	end
	self.settingTexture = true
	self:SetNormalTexture(0)

	if texture and texture ~= "" then
		if strfind(texture, "Plus") or strfind(texture, "[Cc]losed") then
			self.__texture:DoCollapse(true)
		elseif strfind(texture, "Minus") or strfind(texture, "[Oo]pen") then
			self.__texture:DoCollapse(false)
		end
		self.bg:Show()
	else
		self.bg:Hide()
	end
	self.settingTexture = nil
end

-- Handle close button
local function ReskinCollapseButton(self)
	self:SetNormalTexture(0)
	self:SetHighlightTexture(0)
	self:SetPushedTexture(0)

	local bg = CreateFrame("Frame", nil, self)
	bg:ClearAllPoints()
	bg:SetSize(13, 13)
	bg:SetPoint("LEFT", self:GetNormalTexture())
	self.bg = bg

	self.__texture = self:CreateTexture(nil, "OVERLAY")
	self.__texture:SetPoint("CENTER")
	self.__texture.DoCollapse = UpdateCollapseIcon

	hooksecurefunc(self, "SetNormalAtlas", ResetCollapseIcon)
end

local function UpdateMinimizeButtonState(button, collapsed)
	button = button.MinimizeButton
	button.__texture:DoCollapse(collapsed)
end

local function ReskinMinimizeButton(button, header)
	ReskinCollapseButton(button)
	button:GetNormalTexture():SetAlpha(0)
	button:GetPushedTexture():SetAlpha(0)
	button.__texture:DoCollapse(false)
	if button.SetCollapsed then
		hooksecurefunc(button, "SetCollapsed", UpdateMinimizeButtonState)
	end
end

-- Add the theme reskin to default themes
tinsert(C.defaultThemes, function()
	local mainHeader = ObjectiveTrackerFrame.Header
	mainHeader:StripTextures()

	-- Minimize Button
	local mainMinimizeButton = mainHeader.MinimizeButton
	ReskinMinimizeButton(mainMinimizeButton, mainHeader)

	local trackers = {
		ScenarioObjectiveTracker,
		UIWidgetObjectiveTracker,
		CampaignQuestObjectiveTracker,
		QuestObjectiveTracker,
		AdventureObjectiveTracker,
		AchievementObjectiveTracker,
		MonthlyActivitiesObjectiveTracker,
		ProfessionsRecipeTracker,
		BonusObjectiveTracker,
		WorldQuestObjectiveTracker,
	}

	-- Reskin each tracker header in the list
	for _, tracker in pairs(trackers) do
		reskinHeader(tracker.Header)
	end
end)
