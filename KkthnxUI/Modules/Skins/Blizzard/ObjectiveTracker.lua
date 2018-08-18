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

	hooksecurefunc("ObjectiveTracker_Update", SkinOjectiveTrackerHeaders)
	hooksecurefunc(QUEST_TRACKER_MODULE, "Update", AddBlockDash)
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinObjectiveTracker)