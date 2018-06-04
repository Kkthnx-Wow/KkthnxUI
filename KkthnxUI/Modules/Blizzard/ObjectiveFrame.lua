local K, C = unpack(select(2, ...))
local Module = K:NewModule("ObjectiveFrame", "AceEvent-3.0", "AceHook-3.0")

local Movers = K["Movers"]

local _G = _G
local math_min = math.min
local select = select
local unpack = unpack

local AUTO_QUEST_POPUP_TRACKER_MODULE = _G.AUTO_QUEST_POPUP_TRACKER_MODULE
local BONUS_OBJECTIVE_TRACKER_MODULE = _G.BONUS_OBJECTIVE_TRACKER_MODULE
local CreateFrame = _G.CreateFrame
local DEFAULT_OBJECTIVE_TRACKER_MODULE = _G.DEFAULT_OBJECTIVE_TRACKER_MODULE
local GetAutoQuestPopUp = _G.GetAutoQuestPopUp
local GetNumAutoQuestPopUps = _G.GetNumAutoQuestPopUps
local GetNumQuestWatches = _G.GetNumQuestWatches
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetQuestIndexForWatch = _G.GetQuestIndexForWatch
local GetQuestLogIndexByID = _G.GetQuestLogIndexByID
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestWatchInfo = _G.GetQuestWatchInfo
local GetRealmName = _G.GetRealmName
local GetScreenHeight = _G.GetScreenHeight
local hooksecurefunc = _G.hooksecurefunc
local LE_QUEST_FREQUENCY_DAILY = _G.LE_QUEST_FREQUENCY_DAILY
local LE_QUEST_FREQUENCY_WEEKLY = _G.LE_QUEST_FREQUENCY_WEEKLY
local OBJECTIVE_TRACKER_COLOR = _G.OBJECTIVE_TRACKER_COLOR
local ObjectiveTrackerFrame = _G.ObjectiveTrackerFrame
local ObjectiveTrackerFrameHeaderMenuMinimizeButton = _G.ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
local QUEST_TRACKER_MODULE = _G.QUEST_TRACKER_MODULE
local SCENARIO_CONTENT_TRACKER_MODULE = _G.SCENARIO_CONTENT_TRACKER_MODULE
local SCENARIO_TRACKER_MODULE = _G.SCENARIO_TRACKER_MODULE
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitName = _G.UnitName
local WORLD_QUEST_TRACKER_MODULE = _G.WORLD_QUEST_TRACKER_MODULE

local Class = select(2, UnitClass("player"))
local CustomClassColor = K.Colors.class[Class]
local PreviousPOI

function Module:Disable()
	ObjectiveTrackerFrameHeaderMenuMinimizeButton:Hide()
end

function Module:OnEnter()
	K.UIFrameFadeIn(self, 0.25, self:GetAlpha(), 1)
end

function Module:OnLeave()
	K.UIFrameFadeOut(self, 1, self:GetAlpha(), 0.25)
end

function Module:OnClick()
	if (ObjectiveTrackerFrame:IsVisible()) then
		ObjectiveTrackerFrame:Hide()

		self.Toggle:SetText("+")
	else
		ObjectiveTrackerFrame:Show()

		self.Toggle:SetText("-")
	end
end

function Module:CreateToggleButtons()
	local Button = CreateFrame("Button", nil, UIParent)
	Button:SetSize(32, 32)
	Button:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, -6, 20)
	Button:SetAlpha(0.25)
	Button:RegisterForClicks("AnyUp")
	Button:SetScript("OnClick", self.OnClick)
	Button:SetScript("OnEnter", self.OnEnter)
	Button:SetScript("OnLeave", self.OnLeave)

	Button.Toggle = Button:CreateFontString(nil, "OVERLAY")
	Button.Toggle:FontTemplate(C["Media"].Font, 32)
	Button.Toggle:SetSize(32, 32)
	Button.Toggle:SetPoint("CENTER")
	Button.Toggle:SetText("-")
end

function Module:SetDefaultPosition()
	local GetTop = ObjectiveTrackerFrame:GetTop() or 0
	local ScreenHeight = GetScreenHeight()
	local GapFromTop = ScreenHeight - GetTop
	local MaxHeight = ScreenHeight - GapFromTop
	local SetObjectiveFrameHeight = math_min(MaxHeight, 480)
	local Anchor1, Parent, Anchor2, X, Y = "TOPRIGHT", UIParent, "TOPRIGHT", -200, -270
	local Data = KkthnxUIData[GetRealmName()][UnitName("Player")]

	local ObjectiveFrameHolder = CreateFrame("Frame", "UIObjectiveTracker", UIParent)
	ObjectiveFrameHolder:SetSize(130, 22)
	ObjectiveFrameHolder:SetPoint(Anchor1, Parent, Anchor2, X, Y)

	ObjectiveTrackerFrame:ClearAllPoints()
	ObjectiveTrackerFrame:SetPoint("TOP", ObjectiveFrameHolder)
	ObjectiveTrackerFrame:SetHeight(SetObjectiveFrameHeight)

	-- Force IsUserPlaced to always be true, which will avoid tracker to move
	-- https://git.tukui.org/Blazeflack/BlizzardUserInterface/blob/master/Interface/FrameXML/UIParent.lua#L2939
	ObjectiveTrackerFrame.IsUserPlaced = function()
		return true
	end

	Movers:RegisterFrame(ObjectiveFrameHolder)
	Movers:SaveDefaults(self, Anchor1, Parent, Anchor2, X, Y)

	if Data and Data.Move and Data.Move.UIObjectiveTracker then
		ObjectiveFrameHolder:ClearAllPoints()
		ObjectiveFrameHolder:SetPoint(unpack(Data.Move.UIObjectiveTracker))
	end
end

function Module:SkinTracker()
	local Frame = ObjectiveTrackerFrame.MODULES

	if (Frame) then
		for i = 1, #Frame do

			local Modules = Frame[i]
			if (Modules) then
				local Header = Modules.Header
				Header:SetFrameStrata("HIGH")
				Header:SetFrameLevel(10)

				local Background = Modules.Header.Background
				Background:SetAtlas(nil)

				local Text = Modules.Header.Text
				Text:SetFont(C["Media"].Font, 16)
				Text:SetDrawLayer("OVERLAY", 7)
				Text:SetParent(Header)

				if not (Modules.IsSkinned) then
					local HeaderPanel = CreateFrame("Frame", nil, Header)
					HeaderPanel:SetFrameLevel(Header:GetFrameLevel() - 1)
					HeaderPanel:SetFrameStrata("BACKGROUND")
					HeaderPanel:SetPoint("TOPLEFT", 1, 1)
					HeaderPanel:SetPoint("BOTTOMRIGHT", 1, 1)

					local HeaderBar = HeaderPanel:CreateTexture(nil, "ARTWORK")
					HeaderBar:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
					HeaderBar:SetTexCoord(0, 0.6640625, 0, 0.3125)
					HeaderBar:SetVertexColor(unpack(CustomClassColor))
					HeaderBar:SetPoint("CENTER", HeaderPanel, -20, -4)
					HeaderBar:SetSize(232, 30)

					Modules.IsSkinned = true
				end
			end
		end
	end
end

function Module:SkinScenario()
	local StageBlock = _G["ScenarioStageBlock"]

	StageBlock.NormalBG:SetTexture("")
	StageBlock.FinalBG:SetTexture("")
	StageBlock.Stage:SetFont(C["Media"].Font, 17)
	StageBlock.GlowTexture:SetTexture("")
end

function Module:UpdateQuestItem(block)
	local QuestItemButton = block.itemButton

	if (QuestItemButton) then
		local Icon = QuestItemButton.icon
		local Count = QuestItemButton.Count

		if not (QuestItemButton.IsSkinned) then
			QuestItemButton:SetSize(26, 26)
			QuestItemButton:SetTemplate("Transparent")
			QuestItemButton:SetNormalTexture(nil)

			if (Icon) then
				Icon:SetInside()
				Icon:SetTexCoord(.08, .92, .08, .92)
			end

			if (Count) then
				Count:ClearAllPoints()
				Count:SetPoint("BOTTOMRIGHT", QuestItemButton, 0, 3)
				Count:SetFont(C["Media"].Font, 12)
			end

			QuestItemButton.IsSkinned = true
		end
	end
end

function Module:UpdateProgressBar(_, line)
	local Progress = line.ProgressBar
	local Bar = Progress.Bar

	if (Bar) then
		local Label = Bar.Label
		local Icon = Bar.Icon
		local IconBG = Bar.IconBG
		local Backdrop = Bar.BarBG
		local Glow = Bar.BarGlow
		local Sheen = Bar.Sheen
		local Frame = Bar.BarFrame
		local Frame2 = Bar.BarFrame2
		local Frame3 = Bar.BarFrame3
		local BorderLeft = Bar.BorderLeft
		local BorderRight = Bar.BorderRight
		local BorderMid = Bar.BorderMid

		if not (Bar.IsSkinned) then
			if (Backdrop) then
				Backdrop:Hide() Backdrop:SetAlpha(0)
			end

			if (IconBG) then
				IconBG:Hide() IconBG:SetAlpha(0)
			end

			if (Glow) then
				Glow:Hide()
			end

			if (Sheen) then
				Sheen:Hide()
			end

			if (Frame) then
				Frame:Hide()
			end

			if (Frame2) then
				Frame2:Hide()
			end

			if (Frame3) then
				Frame3:Hide()
			end

			if (BorderLeft) then
				BorderLeft:SetAlpha(0)
			end

			if (BorderRight) then
				BorderRight:SetAlpha(0)
			end

			if (BorderMid) then
				BorderMid:SetAlpha(0)
			end

			Bar:SetHeight(18)
			Bar:SetStatusBarTexture(C["Media"].Texture)
			Bar:CreateBackdrop()
			Bar.Backdrop:SetFrameStrata("BACKGROUND")
			Bar.Backdrop:SetFrameLevel(1)
			Bar.Backdrop:SetOutside(Bar)

			if (Label) then
				Label:ClearAllPoints()
				Label:SetPoint("CENTER", Bar, 0, 0)
				Label:SetFont(C["Media"].Font, 12)
			end

			if (Icon) then
				Icon:SetSize(20, 20)
				Icon:SetMask("")
				Icon:SetTexCoord(.08, .92, .08, .92)
				Icon:ClearAllPoints()
				Icon:SetPoint("RIGHT", Bar, 26, 0)

				if not (Bar.NewBorder) then
					Bar.NewBorder = CreateFrame("Frame", nil, Bar)
					Bar.NewBorder:SetTemplate()
					Bar.NewBorder:SetOutside(Icon)
					Bar.NewBorder:SetShown(Icon:IsShown())
				end
			end

			Bar.IsSkinned = true
		elseif (Icon and Bar.NewBorder) then
			Bar.NewBorder:SetShown(Icon:IsShown())
		end
	end
end

function Module:UpdateProgressBarColors(Min)
	if (self.Bar and Min) then
		local R, G, B = K.ColorGradient(Min, 100, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
		self.Bar:SetStatusBarColor(R, G, B)
	end
end

function Module:UpdatePopup()
	for i = 1, GetNumAutoQuestPopUps() do
		local ID, type = GetAutoQuestPopUp(i)
		local Title = GetQuestLogTitle(GetQuestLogIndexByID(ID))

		if Title and Title ~= "" then
			local Block = AUTO_QUEST_POPUP_TRACKER_MODULE:GetBlock(ID)

			if Block then
				local Frame = Block.ScrollChild

				if not Frame.Backdrop then
					Frame:CreateBackdrop()

					Frame.Backdrop:SetPoint("TOPLEFT", Frame, 40, -4)
					Frame.Backdrop:SetPoint("BOTTOMRIGHT", Frame, 0, 4)
					Frame.Backdrop:SetFrameLevel(0)
					Frame.Backdrop:SetTemplate("Transparent")

					Frame.FlashFrame.IconFlash:Hide()
				end

				if type == "COMPLETE" then
					Frame.QuestIconBg:SetAlpha(0)
					Frame.QuestIconBadgeBorder:SetAlpha(0)
					Frame.QuestionMark:ClearAllPoints()
					Frame.QuestionMark:SetPoint("CENTER", Frame.Backdrop, "LEFT", 10, 0)
					Frame.QuestionMark:SetParent(Frame.Backdrop)
					Frame.QuestionMark:SetDrawLayer("OVERLAY", 7)
					Frame.IconShine:Hide()
				elseif type == "OFFER" then
					Frame.QuestIconBg:SetAlpha(0)
					Frame.QuestIconBadgeBorder:SetAlpha(0)
					Frame.Exclamation:ClearAllPoints()
					Frame.Exclamation:SetPoint("CENTER", Frame.Backdrop, "LEFT", 10, 0)
					Frame.Exclamation:SetParent(Frame.Backdrop)
					Frame.Exclamation:SetDrawLayer("OVERLAY", 7)
				end

				Frame.FlashFrame:Hide()
				Frame.Bg:Hide()

				for _, v in pairs({
					Frame.BorderTopLeft,
					Frame.BorderTopRight,
					Frame.BorderBotLeft,
					Frame.BorderBotRight,
					Frame.BorderLeft,
					Frame.BorderRight,
					Frame.BorderTop,
					Frame.BorderBottom
				}) do
					v:Hide()
				end
			end
		end
	end
end

local function SkinGroupFindButton(block)
	local HasGroupFinderButton = block.hasGroupFinderButton
	local GroupFinderButton = block.groupFinderButton

	if (HasGroupFinderButton and GroupFinderButton) then
		if not (GroupFinderButton.IsSkinned) then
			GroupFinderButton:SkinButton()
			GroupFinderButton:SetSize(18, 18)

			GroupFinderButton.IsSkinned = true
		end
	end
end

local function UpdatePositions(block)
	local GroupFinderButton = block.groupFinderButton
	local ItemButton = block.itemButton

	if (ItemButton) then
		local PointA, PointB, PointC = ItemButton:GetPoint()
		ItemButton:SetPoint(PointA, PointB, PointC, -6, -1)
	end

	if (GroupFinderButton) then
		local GPointA, GPointB, GPointC = GroupFinderButton:GetPoint()
		GroupFinderButton:SetPoint(GPointA, GPointB, GPointC, -262, -4)
	end
end

function Module:AddDash()
	for i = 1, GetNumQuestWatches() do
		local questIndex = GetQuestIndexForWatch(i)

		if questIndex then
			local id = GetQuestWatchInfo(i)
			local block = QUEST_TRACKER_MODULE:GetBlock(id)
			local _, level, _, _, _, _, frequency = GetQuestLogTitle(questIndex)

			if block.lines then
				for _, line in pairs(block.lines) do
					if frequency == LE_QUEST_FREQUENCY_DAILY then
						local red, green, blue = 1/4, 6/9, 1

						line.Dash:SetText("— ")
						line.Dash:SetVertexColor(red, green, blue)
					elseif frequency == LE_QUEST_FREQUENCY_WEEKLY then
						local red, green, blue = 0, 252/255, 177/255

						line.Dash:SetText("— ")
						line.Dash:SetVertexColor(red, green, blue)
					else
						local col = GetQuestDifficultyColor(level)

						line.Dash:SetText("— ")
						line.Dash:SetVertexColor(col.r, col.g, col.b)
					end
				end
			end
		end
	end
end

function Module:SkinPOI()
	local Incomplete = self.poiTable["numeric"]
	local Complete = self.poiTable["completed"]

	for i = 1, #Incomplete do
		local Button = ObjectiveTrackerBlocksFrame.poiTable["numeric"][i]

		if Button and not Button.IsSkinned then
			Button.NormalTexture:SetTexture("")
			Button.PushedTexture:SetTexture("")
			Button.HighlightTexture:SetTexture("")
			Button.Glow:SetAlpha(0)
			Button:SetTemplate("Transparent")

			Button.IsSkinned = true
		end
	end

	for i = 1, #Complete do
		local Button = ObjectiveTrackerBlocksFrame.poiTable["completed"][i]

		if Button and not Button.IsSkinned then
			Button.NormalTexture:SetTexture("")
			Button.PushedTexture:SetTexture("")
			Button.FullHighlightTexture:SetTexture("")
			Button.Glow:SetAlpha(0)
			Button:SetTemplate("Transparent")

			Button.IsSkinned = true
		end
	end
end

function Module:SelectPOI()
	local ID = GetQuestLogIndexByID(self.questID)
	local Level = select(2, GetQuestLogTitle(ID))
	local Color = GetQuestDifficultyColor(Level) or {r = 1, g = 1, b = 0, a = 1}

	if (PreviousPOI) then
		PreviousPOI:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
		PreviousPOI:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
	end

	self:SetBackdropBorderColor(Color.r, Color.g, Color.b)
	self:SetBackdropColor(0/255, 152/255, 34/255, 1)

	PreviousPOI = self
end

function Module:ShowObjectiveTrackerLevel()
	for i = 1, GetNumQuestWatches() do
		local questID, _, questLogIndex = GetQuestWatchInfo(i)

		if (not questID) then
			break
		end

		local block = QUEST_TRACKER_MODULE:GetExistingBlock(questID)

		if block then
			local title, level = GetQuestLogTitle(questLogIndex)
			local color = GetQuestDifficultyColor(level)
			local hex = K.RGBToHex(color.r, color.g, color.b) or OBJECTIVE_TRACKER_COLOR["Header"]
			local text = hex.."["..level.."]|r "..title

			block.HeaderText:SetText(text)
		end
	end
end

function Module:AddHooks()
	hooksecurefunc("ObjectiveTracker_Update", self.SkinTracker)
	hooksecurefunc("ScenarioBlocksFrame_OnLoad", self.SkinScenario)
	hooksecurefunc(SCENARIO_CONTENT_TRACKER_MODULE, "Update", self.SkinScenario)
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", self.UpdateQuestItem)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", self.UpdateQuestItem)
	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", self.UpdateProgressBar)
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", self.UpdateProgressBar)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", self.UpdateProgressBar)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", self.UpdateProgressBar)
	hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", self.UpdateProgressBarColors)
	hooksecurefunc("ObjectiveTrackerProgressBar_SetValue", self.UpdateProgressBarColors)
	hooksecurefunc("ScenarioTrackerProgressBar_SetValue", self.UpdateProgressBarColors)
	hooksecurefunc("QuestObjectiveSetupBlockButton_FindGroup", SkinGroupFindButton)
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", UpdatePositions)
	hooksecurefunc(AUTO_QUEST_POPUP_TRACKER_MODULE, "Update", self.UpdatePopup)
	hooksecurefunc(QUEST_TRACKER_MODULE, "Update", self.AddDash)
	hooksecurefunc("QuestPOI_GetButton", self.SkinPOI)
	hooksecurefunc("QuestPOI_SelectButton", self.SelectPOI)
	hooksecurefunc(QUEST_TRACKER_MODULE, "Update", self.ShowObjectiveTrackerLevel)
end

function Module:OnEnable()
	OBJECTIVE_TRACKER_COLOR["Header"] = {r = CustomClassColor[1], g = CustomClassColor[2], b = CustomClassColor[3]}
	OBJECTIVE_TRACKER_COLOR["HeaderHighlight"] = {r = CustomClassColor[1] * 1.2, g = CustomClassColor[2] * 1.2, b = CustomClassColor[3] * 1.2}
	OBJECTIVE_TRACKER_COLOR["Complete"] = {r = 0, g = 1, b = 0}
	OBJECTIVE_TRACKER_COLOR["Normal"] = {r = 1, g = 1, b = 1}

	self:AddHooks()
	self:Disable()
	self:CreateToggleButtons()
	self:SetDefaultPosition()
	self:SkinScenario()
end