local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert
local unpack = unpack

local BONUS_OBJECTIVE_TRACKER_MODULE = _G.BONUS_OBJECTIVE_TRACKER_MODULE
local DEFAULT_OBJECTIVE_TRACKER_MODULE = _G.DEFAULT_OBJECTIVE_TRACKER_MODULE
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
local SCENARIO_TRACKER_MODULE = _G.SCENARIO_TRACKER_MODULE
local WORLD_QUEST_TRACKER_MODULE = _G.WORLD_QUEST_TRACKER_MODULE

local function SetStatusBarColor(bar, value, max)
	local current = (not max and value) or (value and max and max ~= 0 and value / max)

	if not (bar and current) then
		return
	end

	local r, g, b = K.ColorGradient(current, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
	bar:SetStatusBarColor(r, g, b)
end

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
						headerBar:SetVertexColor(
							K.Colors.class[K.Class][1],
							K.Colors.class[K.Class][2],
							K.Colors.class[K.Class][3],
							K.Colors.class[K.Class][4]
						)
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
	MinimizeButton:HookScript(
		"OnClick",
		function()
			if ObjectiveTrackerFrame.collapsed then
				MinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
			else
				MinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
			end
		end
	)

	local function ColorProgressBars(self, value)
		if not (self.Bar and self.isSkinned and value) then
			return
		end

		SetStatusBarColor(self.Bar, value, 100)
	end

	local function SkinItemButton(_, block)
		local item = block.itemButton
		if item and not item.skinned then
			item:SetSize(25, 25)
			item:SetTemplate("Transparent")
			item:StyleButton()
			item:SetNormalTexture(nil)
			item.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			item.icon:SetInside()
			item.Cooldown:SetInside()
			item.Count:ClearAllPoints()
			item.Count:SetPoint("TOPLEFT", 1, -1)
			item.Count:SetFont(C["Media"].Font, 14, "OUTLINE")
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

		local icon = bar.Icon
		local label = bar.Label

		if not bar.isSkinned then
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
			bar:CreateBackdrop("Transparent")
			bar.Backdrop:SetFrameLevel(bar:GetFrameLevel())
			bar:SetStatusBarTexture(C["Media"].Texture)

			if label then
				label:ClearAllPoints()
				label:SetPoint("CENTER", bar, 0, 1)
				label:FontTemplate(C["Media"].Font, 12)
			end

			if icon then
				icon:SetSize(18, 18)
				icon:ClearAllPoints()
				icon:SetPoint("LEFT", bar, "RIGHT", 6, 0)
				icon:SetMask("")
				icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				icon:SetDrawLayer("BACKGROUND", 0)

				if not progressBar.Backdrop then
					progressBar:CreateBackdrop()
					progressBar.Backdrop:SetFrameLevel(6)
					progressBar.Backdrop:SetOutside(icon)
					progressBar.Backdrop:SetShown(icon:IsShown())
				end
			end

			_G.BonusObjectiveTrackerProgressBar_PlayFlareAnim = K.Noop

			bar.isSkinned = true
		elseif icon and progressBar.Backdrop then
			progressBar.Backdrop:SetShown(icon:IsShown())
		end
	end

	local function PositionFindGroupButton(block, button)
		if button and button.GetPoint then
			local a, b, c, d, e = button:GetPoint()
			if block.groupFinderButton and b == block.groupFinderButton and block.itemButton and button == block.itemButton then
				-- this fires when there is a group button and a item button to the left of it
				-- we push the item button away from the group button (to the left)
				button:SetPoint(a, b, c, d - (3 and -1 or 1), e)
			elseif b == block and block.groupFinderButton and button == block.groupFinderButton then
				-- this fires when there is a group finder button
				-- we push the group finder button down slightly
				button:SetPoint(a, b, c, d, e - (3 and 2 or -1))
			end
		end
	end

	local function SkinFindGroupButton(block)
		if block.hasGroupFinderButton and block.groupFinderButton then
			if block.groupFinderButton and not block.groupFinderButton.skinned then
				block.groupFinderButton:SkinButton()
				block.groupFinderButton:SetSize(20, 20)
				block.groupFinderButton.skinned = true
			end
		end
	end

	local function AddBlockDash()
		for i = 1, GetNumQuestWatches() do
			local questIndex = GetQuestIndexForWatch(i)

			if questIndex then
				local id = GetQuestWatchInfo(i)
				local block = QUEST_TRACKER_MODULE:GetBlock(id)
				local _, level, _, _, _, _, frequency = GetQuestLogTitle(questIndex)

				if block.lines then
					for _, line in pairs(block.lines) do
						if frequency == LE_QUEST_FREQUENCY_DAILY then
							local red, green, blue = 1 / 4, 6 / 9, 1

							line.Dash:SetText("- ")
							line.Dash:SetVertexColor(red, green, blue)
						elseif frequency == LE_QUEST_FREQUENCY_WEEKLY then
							local red, green, blue = 0, 252 / 255, 177 / 255

							line.Dash:SetText("- ")
							line.Dash:SetVertexColor(red, green, blue)
						else
							local col = GetQuestDifficultyColor(level)

							line.Dash:SetText("- ")
							line.Dash:SetVertexColor(col.r, col.g, col.b)
						end
					end
				end
			end
		end
	end

	local function ShowObjectiveTrackerLevel()
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
				local text = hex .. "[" .. level .. "]|r " .. title

				block.HeaderText:SetText(text)
			end
		end
	end

	hooksecurefunc("ObjectiveTracker_Update", SkinOjectiveTrackerHeaders)
	hooksecurefunc("BonusObjectiveTrackerProgressBar_SetValue", ColorProgressBars)
	hooksecurefunc("ObjectiveTrackerProgressBar_SetValue", ColorProgressBars)
	hooksecurefunc("ScenarioTrackerProgressBar_SetValue", ColorProgressBars)
	hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", PositionFindGroupButton)
	hooksecurefunc("QuestObjectiveSetupBlockButton_FindGroup", SkinFindGroupButton)
	hooksecurefunc(BONUS_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", SkinProgressBars)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddProgressBar", SkinProgressBars)
	hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddProgressBar", SkinProgressBars)
	hooksecurefunc(SCENARIO_TRACKER_MODULE, "AddProgressBar", SkinProgressBars)
	hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", SkinItemButton)
	hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", SkinItemButton)
	hooksecurefunc(QUEST_TRACKER_MODULE, "Update", AddBlockDash)
	hooksecurefunc(QUEST_TRACKER_MODULE, "Update", ShowObjectiveTrackerLevel)
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinObjectiveTracker)
