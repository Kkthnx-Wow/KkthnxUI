-- KkthnxUI Namespace
local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("WorldMap")

-- WoW API Functions
local GameTooltip = GameTooltip
local GetAchievementLink = GetAchievementLink
local GetQuestLink = GetQuestLink
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local GetSuperTrackedQuestID = C_SuperTrack.GetSuperTrackedQuestID
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local setmetatable = setmetatable

-- Wowhead URL Components
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
	__index = function()
		return "www"
	end,
}))[K.Locale]
local wowheadLoc = subDomain .. ".wowhead.com"
local urlQuestIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:0|t"

-- Achievement Frame Functionality
local function InitializeAchievementLink()
	local achievementEditBox = CreateFrame("EditBox", nil, AchievementFrame)
	achievementEditBox:ClearAllPoints()
	achievementEditBox:SetPoint("BOTTOMRIGHT", -50, 1)
	achievementEditBox:SetHeight(16)
	achievementEditBox:SetFontObject("GameFontNormalSmall")
	achievementEditBox:SetBlinkSpeed(0)
	achievementEditBox:SetJustifyH("RIGHT")
	achievementEditBox:SetAutoFocus(false)
	achievementEditBox:EnableKeyboard(false)
	achievementEditBox:SetHitRectInsets(90, 0, 0, 0)
	achievementEditBox:SetScript("OnKeyDown", function() end)
	achievementEditBox:SetScript("OnMouseUp", function()
		if achievementEditBox:IsMouseOver() then
			achievementEditBox:HighlightText()
		else
			achievementEditBox:HighlightText(0, 0)
		end
	end)

	-- Create hidden font string (used for setting width of editbox)
	achievementEditBox.hiddenText = achievementEditBox:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	achievementEditBox.hiddenText:Hide()

	local lastAchievementLink

	local function SetAchievementLink(self, achievementID)
		if achievementID then
			local achievementURL = urlQuestIcon .. "https://" .. wowheadLoc .. "/achievement=" .. achievementID
			achievementEditBox:SetText(achievementURL)
			achievementEditBox.hiddenText:SetText(achievementURL)
			achievementEditBox:SetWidth(achievementEditBox.hiddenText:GetStringWidth() + 90)

			local achievementTitle = GetAchievementLink(achievementID)
			if achievementTitle then
				achievementEditBox.tooltipText = achievementTitle:match("%[(.-)%]") .. "|n" .. L["Press To Copy"]
			end

			achievementEditBox:Show()
			lastAchievementLink = achievementEditBox:GetText()
		end
	end

	hooksecurefunc(AchievementTemplateMixin, "DisplayObjectives", SetAchievementLink)
	hooksecurefunc("AchievementFrameComparisonTab_OnClick", function(self)
		achievementEditBox:Hide()
	end)

	achievementEditBox:SetScript("OnEnter", function()
		achievementEditBox:HighlightText()
		achievementEditBox:SetFocus()
		GameTooltip:SetOwner(achievementEditBox, "ANCHOR_TOP", 0, 10)
		GameTooltip:SetText(achievementEditBox.tooltipText, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	achievementEditBox:SetScript("OnLeave", function()
		if achievementEditBox:GetText() ~= lastAchievementLink then
			achievementEditBox:SetText(lastAchievementLink)
		end
		achievementEditBox:HighlightText(0, 0)
		achievementEditBox:ClearFocus()
		GameTooltip:Hide()
	end)
end

-- World Map Functionality
local function InitializeQuestLink()
	local questEditBox = CreateFrame("EditBox", nil, WorldMapFrame.BorderFrame)
	questEditBox:SetFrameLevel(501)
	questEditBox:ClearAllPoints()
	questEditBox:SetPoint("TOPLEFT", 100, -4)
	questEditBox:SetHeight(16)
	questEditBox:SetFontObject("GameFontNormal")
	questEditBox:SetBlinkSpeed(0)
	questEditBox:SetAutoFocus(false)
	questEditBox:EnableKeyboard(false)
	questEditBox:SetHitRectInsets(0, 90, 0, 0)
	questEditBox:SetScript("OnKeyDown", function() end)
	questEditBox:SetScript("OnMouseUp", function()
		if questEditBox:IsMouseOver() then
			questEditBox:HighlightText()
		else
			questEditBox:HighlightText(0, 0)
		end
	end)

	-- Create hidden font string (used for setting width of editbox)
	questEditBox.hiddenText = questEditBox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	questEditBox.hiddenText:Hide()

	local function SetQuestLink()
		local questID
		if QuestMapFrame.DetailsFrame:IsShown() then
			questID = QuestMapFrame_GetDetailQuestID()
		else
			questID = GetSuperTrackedQuestID()
		end

		if questID then
			if questID == 0 then
				questEditBox:Hide()
			else
				questEditBox:Show()
			end

			local questURL = urlQuestIcon .. "https://" .. wowheadLoc .. "/quest=" .. questID
			questEditBox:SetText(questURL)
			questEditBox.hiddenText:SetText(questURL)
			questEditBox:SetWidth(questEditBox.hiddenText:GetStringWidth() + 90)

			local questTitle = GetQuestLink(questID)
			if questTitle then
				questEditBox.tooltipText = questTitle:match("%[(.-)%]") .. "|n" .. L["Press To Copy"]
			else
				questEditBox.tooltipText = ""
				if questEditBox:IsMouseOver() and GameTooltip:IsShown() then
					GameTooltip:Hide()
				end
			end
		end
	end

	questEditBox:RegisterEvent("SUPER_TRACKING_CHANGED")
	questEditBox:SetScript("OnEvent", SetQuestLink)
	SetQuestLink()

	hooksecurefunc("QuestMapFrame_ShowQuestDetails", SetQuestLink)
	hooksecurefunc("QuestMapFrame_CloseQuestDetails", SetQuestLink)

	questEditBox:SetScript("OnEnter", function()
		questEditBox:HighlightText()
		questEditBox:SetFocus()
		GameTooltip:SetOwner(questEditBox, "ANCHOR_BOTTOM", 0, -10)
		GameTooltip:SetText(questEditBox.tooltipText, nil, nil, nil, nil, true)
		GameTooltip:Show()
	end)

	questEditBox:SetScript("OnLeave", function()
		questEditBox:HighlightText(0, 0)
		questEditBox:ClearFocus()
		GameTooltip:Hide()
		SetQuestLink()
	end)
end

-- Main Function
function Module:CreateWowHeadLinks()
	if not C["Misc"].ShowWowHeadLinks or IsAddOnLoaded("Leatrix_Maps") then
		return
	end

	if C_AddOns.IsAddOnLoaded("Blizzard_AchievementUI") then
		InitializeAchievementLink()
	else
		local waitAchievementsFrame = CreateFrame("FRAME")
		waitAchievementsFrame:RegisterEvent("ADDON_LOADED")
		waitAchievementsFrame:SetScript("OnEvent", function(self, _, addon)
			if addon == "Blizzard_AchievementUI" then
				InitializeAchievementLink()
				self:UnregisterAllEvents()
			end
		end)
	end

	InitializeQuestLink()

	-- Hide the title text
	if WorldMapFrameTitleText then
		WorldMapFrameTitleText:Hide()
	end
end
