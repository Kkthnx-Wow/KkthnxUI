local K, C, L, _ = select(2, ...):unpack()

local ObjectiveTracker = CreateFrame("Frame", "ObjectiveTracker", UIParent)
local Noop = function() end

function ObjectiveTracker:SetQuestItemButton(block)
	local Button = block.itemButton

	if (Button and not Button.IsSkinned) then
		local Icon = Button.icon

		Button:SetNormalTexture("")
		Button:CreateBackdrop()
		Button.backdrop:SetOutside(Button, 2, 2)
		Button:StyleButton()

		Icon:SetTexCoord(.1, .9, .1, .9)
		Icon:SetInside()

		Button.isSkinned = true
	end
end

function ObjectiveTracker:UpdatePopup()
	for i = 1, GetNumAutoQuestPopUps() do
		local questID, popUpType = GetAutoQuestPopUp(i)
		local questTitle, level, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily, _ = GetQuestLogTitle(GetQuestLogIndexByID(questID))

		if (questTitle and questTitle ~= "") then
			local Block = AUTO_QUEST_POPUP_TRACKER_MODULE:GetBlock(questID)
			local ScrollChild = Block.ScrollChild

			if not ScrollChild.IsSkinned then
				ScrollChild:StripTextures()
				ScrollChild:CreateBackdrop("Transparent")
				ScrollChild.backdrop:SetPoint("TOPLEFT", ScrollChild, "TOPLEFT", 48, -2)
				ScrollChild.backdrop:SetPoint("BOTTOMRIGHT", ScrollChild, "BOTTOMRIGHT", -1, 2)
				ScrollChild.FlashFrame.IconFlash:Kill()
				ScrollChild.IsSkinned = true
			end
		end
	end
end

function ObjectiveTracker:SetTrackerPosition()
	ObjectiveTrackerFrame:SetPoint("TOPRIGHT", ObjectiveTracker)
end

function ObjectiveTracker:AddHooks()
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", self.SetQuestItemButton) -- TAINTING?!?
	hooksecurefunc(AUTO_QUEST_POPUP_TRACKER_MODULE, "Update", self.UpdatePopup)
end

function ObjectiveTracker:Minimize()
	local Button = self
	local Text = self.Text
	local Value = Text:GetText()

	if (Value and Value == "X") then
		Text:SetText("V")
	else
		Text:SetText("X")
	end
end

function ObjectiveTracker:Enable()
	if select(4, GetAddOnInfo("DugisGuideViewerZ")) then
		return
	end

	local Movers = K["Movers"]
	local Frame = ObjectiveTrackerFrame
	local Minimize = ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
	local ScenarioStageBlock = ScenarioStageBlock
	local Data = SavedPositions
	local Anchor1, Parent, Anchor2, X, Y = "TOPRIGHT", UIParent, "TOPRIGHT", -K.ScreenHeight / 5, -K.ScreenHeight / 4

	self:SetSize(235, 23)
	self:SetPoint(Anchor1, Parent, Anchor2, X, Y)
	self:AddHooks()
	self.SetTrackerPosition(Frame)

	Movers:RegisterFrame(self)
	Movers:SaveDefaults(self, Anchor1, Parent, Anchor2, X, Y)

	if Data and Data.Move and Data.Move.ObjectiveTracker then
		self:ClearAllPoints()
		self:SetPoint(unpack(Data.Move.ObjectiveTracker))
	end

	for i = 1, 5 do
		local Module = ObjectiveTrackerFrame.MODULES[i]

		if Module then
			local Header = Module.Header

			Header:StripTextures()
			Header:Show()
		end
	end

	ScenarioStageBlock:StripTextures()
	ScenarioStageBlock:SetHeight(50)

	Minimize:StripTextures()
	Minimize:FontString("Text", C.Media.Font, 12, "OUTLINE")
	Minimize.Text:SetPoint("CENTER", Minimize)
	Minimize.Text:SetText("X")
	Minimize:HookScript("OnClick", ObjectiveTracker.Minimize)

	Frame.ClearAllPoints = function() end
	Frame.SetPoint = function() end
end

function ObjectiveTracker:OnEvent(event)
	if (event == "PLAYER_ENTERING_WORLD") then
		ObjectiveTracker:Enable()
	end
end

ObjectiveTracker:RegisterEvent("PLAYER_ENTERING_WORLD")
ObjectiveTracker:SetScript("OnEvent", ObjectiveTracker.OnEvent)