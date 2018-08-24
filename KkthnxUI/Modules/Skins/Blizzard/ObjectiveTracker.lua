local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert

local GetNumQuestWatches = _G.GetNumQuestWatches
local GetQuestDifficultyColor = _G.GetQuestDifficultyColor
local GetQuestIndexForWatch = _G.GetQuestIndexForWatch
local GetQuestLogTitle = _G.GetQuestLogTitle
local GetQuestWatchInfo = _G.GetQuestWatchInfo
local hooksecurefunc = _G.hooksecurefunc
local LE_QUEST_FREQUENCY_DAILY = _G.LE_QUEST_FREQUENCY_DAILY
local LE_QUEST_FREQUENCY_WEEKLY = _G.LE_QUEST_FREQUENCY_WEEKLY
local OBJECTIVE_TRACKER_COLOR = _G.OBJECTIVE_TRACKER_COLOR
local QUEST_TRACKER_MODULE = _G.QUEST_TRACKER_MODULE

local function SkinObjectiveTracker()
	local ObjectiveTrackerFrame = _G["ObjectiveTrackerFrame"]

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
					text:FontTemplate(nil, 14)
					text:SetParent(header)

					if not (modules.IsSkinned) then
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

	local function ColorProgressBars(self, value)
		if not (self.Bar and value) then
			return
		end

		Module:StatusBarColorGradient(self.Bar, value, 100)
	end

	local function SkinItemButton(self, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(25, 25)
			item:CreateBorder()
			item:StyleButton()
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(unpack(K.TexCoords))
			item.icon:SetInside()
			item.Cooldown:SetInside()
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(C.Media.Font, 14, "OUTLINE")
			item.Count:SetShadowOffset(5, -5)
			item.skinned = true
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

	hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", ColorProgressBars)				--[Color]: Bonus Objective Progress Bar
	hooksecurefunc("ObjectiveTrackerProgressBar_SetValue", ColorProgressBars)					--[Color]: Quest Progress Bar
	hooksecurefunc("ScenarioTrackerProgressBar_SetValue", ColorProgressBars)					--[Color]: Scenario Progress Bar
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", PositionFindGroupButton)	--[Move]: The eye & quest item to the left of the eye
	hooksecurefunc("ObjectiveTracker_Update", SkinOjectiveTrackerHeaders)						--[Skin]: Module Headers
	hooksecurefunc("QuestObjectiveSetupBlockButton_FindGroup", SkinFindGroupButton)				--[Skin]: The eye
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", SkinItemButton)						--[Skin]: Quest Item Buttons
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", SkinItemButton)					--[Skin]: World Quest Item Buttons
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinObjectiveTracker)