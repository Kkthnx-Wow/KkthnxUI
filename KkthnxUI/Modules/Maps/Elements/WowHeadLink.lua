local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("WorldMap")

local GameTooltip = GameTooltip
local GetAchievementLink = GetAchievementLink
local GetQuestLink = GetQuestLink
local IsAddOnLoaded = IsAddOnLoaded
local QuestMapFrame_GetDetailQuestID = QuestMapFrame_GetDetailQuestID
local hooksecurefunc = hooksecurefunc
local setmetatable = setmetatable

-- Wowhead Links
function Module:CreateWowHeadLinks()
	if not C["Misc"].ShowWowHeadLinks or IsAddOnLoaded("Leatrix_Maps") then
		return
	end

	-- Add wowhead link by Goldpaw "Lars" Norberg
	local subDomain = (setmetatable({
		ruRU = "ru",
		frFR = "fr",
		deDE = "de",
		esES = "es",
		esMX = "es",
		ptBR = "pt",
		ptPT = "pt",
		itIT = "it",
		koKR = "ko",
		zhTW = "cn",
		zhCN = "cn",
	}, {
		__index = function(t, v)
			return "www"
		end,
	}))[K.Locale]

	local wowheadLoc = subDomain .. ".wowhead.com"
	local urlQuestIcon = [[|TInterface\OptionsFrame\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t]]

	-- Achievements frame
	-- Achievement link function
	local function DoWowheadAchievementFunc()
		-- Create editbox
		local AchievementEditBox = CreateFrame("EditBox", nil, _G.AchievementFrame)
		AchievementEditBox:ClearAllPoints()
		AchievementEditBox:SetPoint("BOTTOMRIGHT", -50, 1)
		AchievementEditBox:SetHeight(16)
		AchievementEditBox:SetFontObject("GameFontNormalSmall")
		AchievementEditBox:SetBlinkSpeed(0)
		AchievementEditBox:SetJustifyH("RIGHT")
		AchievementEditBox:SetAutoFocus(false)
		AchievementEditBox:EnableKeyboard(false)
		AchievementEditBox:SetHitRectInsets(90, 0, 0, 0)
		AchievementEditBox:SetScript("OnKeyDown", function() end)
		AchievementEditBox:SetScript("OnMouseUp", function()
			if AchievementEditBox:IsMouseOver() then
				AchievementEditBox:HighlightText()
			else
				AchievementEditBox:HighlightText(0, 0)
			end
		end)

		-- Create hidden font string (used for setting width of editbox)
		AchievementEditBox.FakeText = AchievementEditBox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		AchievementEditBox.FakeText:Hide()

		-- Store last link in case editbox is cleared
		local lastAchievementLink

		-- Function to set editbox value
		local function SetAchievementFunc(self, achievementID)
			if achievementID then
				-- Set editbox text
				AchievementEditBox:SetText(urlQuestIcon .. "https://" .. wowheadLoc .. "/achievement=" .. achievementID)
				lastAchievementLink = AchievementEditBox:GetText()
				-- Set hidden fontstring then resize editbox to match
				AchievementEditBox.FakeText:SetText(AchievementEditBox:GetText())
				AchievementEditBox:SetWidth(AchievementEditBox.FakeText:GetStringWidth() + 90)
				-- Get achievement title for tooltip
				local achievementLink = GetAchievementLink(self.id)
				if achievementLink then
					AchievementEditBox.tiptext = achievementLink:match("%[(.-)%]") .. "|n" .. L["Press To Copy"]
				end
				-- Show the editbox
				AchievementEditBox:Show()
			end
		end
		hooksecurefunc(AchievementTemplateMixin, "DisplayObjectives", SetAchievementFunc)
		hooksecurefunc("AchievementFrameComparisonTab_OnClick", function(self)
			AchievementEditBox:Hide()
		end)

		-- Create tooltip
		AchievementEditBox:HookScript("OnEnter", function()
			AchievementEditBox:HighlightText()
			AchievementEditBox:SetFocus()
			GameTooltip:SetOwner(AchievementEditBox, "ANCHOR_TOP", 0, 10)
			GameTooltip:SetText(AchievementEditBox.tiptext, nil, nil, nil, nil, true)
			GameTooltip:Show()
		end)

		AchievementEditBox:HookScript("OnLeave", function()
			-- Set link text again if it"s changed since it was set
			if AchievementEditBox:GetText() ~= lastAchievementLink then
				AchievementEditBox:SetText(lastAchievementLink)
			end
			AchievementEditBox:HighlightText(0, 0)
			AchievementEditBox:ClearFocus()
			GameTooltip:Hide()
		end)

		-- Hide editbox when achievement is deselected
		-- hooksecurefunc("AchievementFrameAchievements_ClearSelection", function(self)
		-- 	AchievementEditBox:Hide()
		-- end)

		-- hooksecurefunc("AchievementCategoryButton_OnClick", function(self)
		-- 	AchievementEditBox:Hide()
		-- end)
	end

	-- Run function when achievement UI is loaded
	if IsAddOnLoaded("Blizzard_AchievementUI") then
		DoWowheadAchievementFunc()
	else
		local waitAchievementsFrame = CreateFrame("FRAME")
		waitAchievementsFrame:RegisterEvent("ADDON_LOADED")
		waitAchievementsFrame:SetScript("OnEvent", function(self, event, arg1)
			if arg1 == "Blizzard_AchievementUI" then
				DoWowheadAchievementFunc()
				waitAchievementsFrame:UnregisterAllEvents()
			end
		end)
	end

	-- World map frame
	-- Hide the title text
	WorldMapFrameTitleText:Hide()

	-- Create editbox
	local WorldMapEditBox = CreateFrame("EditBox", nil, WorldMapFrame.BorderFrame)
	WorldMapEditBox:SetFrameLevel(999)
	WorldMapEditBox:ClearAllPoints()
	WorldMapEditBox:SetPoint("TOPLEFT", 60, -4)
	WorldMapEditBox:SetHeight(16)
	WorldMapEditBox:SetFontObject("GameFontNormal")
	WorldMapEditBox:SetBlinkSpeed(0)
	WorldMapEditBox:SetAutoFocus(false)
	WorldMapEditBox:EnableKeyboard(false)
	WorldMapEditBox:SetHitRectInsets(0, 90, 0, 0)
	WorldMapEditBox:SetScript("OnKeyDown", function() end)
	WorldMapEditBox:SetScript("OnMouseUp", function()
		if WorldMapEditBox:IsMouseOver() then
			WorldMapEditBox:HighlightText()
		else
			WorldMapEditBox:HighlightText(0, 0)
		end
	end)

	-- Create hidden font string (used for setting width of editbox)
	WorldMapEditBox.FakeText = WorldMapEditBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	WorldMapEditBox.FakeText:Hide()

	-- Function to set editbox value
	local function SetQuestInBox()
		local questID
		if QuestMapFrame.DetailsFrame:IsShown() then
			-- Get quest ID from currently showing quest in details panel
			questID = QuestMapFrame_GetDetailQuestID()
		else
			-- Get quest ID from currently selected quest on world map
			questID = C_SuperTrack.GetSuperTrackedQuestID()
		end
		if questID then
			-- Hide editbox if quest ID is invalid
			if questID == 0 then
				WorldMapEditBox:Hide()
			else
				WorldMapEditBox:Show()
			end
			-- Set editbox text
			WorldMapEditBox:SetText("https://" .. wowheadLoc .. "/quest=" .. questID)
			-- Set hidden fontstring then resize editbox to match
			WorldMapEditBox.FakeText:SetText(WorldMapEditBox:GetText())
			WorldMapEditBox:SetWidth(WorldMapEditBox.FakeText:GetStringWidth() + 90)
			-- Get quest title for tooltip
			local questLink = GetQuestLink(questID) or nil
			if questLink then
				WorldMapEditBox.tiptext = questLink:match("%[(.-)%]") .. "|n" .. L["Press To Copy"]
			else
				WorldMapEditBox.tiptext = ""
				if WorldMapEditBox:IsMouseOver() and GameTooltip:IsShown() then
					GameTooltip:Hide()
				end
			end
		end
	end

	-- Set URL when super tracked quest changes and on startup
	WorldMapEditBox:RegisterEvent("SUPER_TRACKING_CHANGED")
	WorldMapEditBox:SetScript("OnEvent", SetQuestInBox)
	SetQuestInBox()

	-- Set URL when quest details frame is shown or hidden
	hooksecurefunc("QuestMapFrame_ShowQuestDetails", SetQuestInBox)
	hooksecurefunc("QuestMapFrame_CloseQuestDetails", SetQuestInBox)

	-- Create tooltip
	WorldMapEditBox:HookScript("OnEnter", function()
		WorldMapEditBox:HighlightText()
		WorldMapEditBox:SetFocus()
		GameTooltip:SetOwner(WorldMapEditBox, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:SetText(WorldMapEditBox.tiptext, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	WorldMapEditBox:HookScript("OnLeave", function()
		WorldMapEditBox:HighlightText(0, 0)
		WorldMapEditBox:ClearFocus()
		GameTooltip:Hide()
		SetQuestInBox()
	end)
end
