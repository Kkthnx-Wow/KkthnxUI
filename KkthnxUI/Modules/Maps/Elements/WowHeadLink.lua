--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Adds copyable Wowhead links to the Achievement and World Map frames.
-- - Design: Creates small edit boxes that automatically populate with Wowhead URLs.
-- - Events: ADDON_LOADED (for Blizzard_AchievementUI), SUPER_TRACKING_CHANGED
-----------------------------------------------------------------------------]]

local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("WorldMap")

-- PERF: Localize global functions and environment for faster lookups.
local setmetatable = _G.setmetatable
local string_match = _G.string.match
local unpack = _G.unpack

local _G = _G
local C_AddOns = _G.C_AddOns
local C_SuperTrack = _G.C_SuperTrack
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetAchievementLink = _G.GetAchievementLink
local GetQuestLink = _G.GetQuestLink
local WorldMapFrame = _G.WorldMapFrame
local hooksecurefunc = _G.hooksecurefunc

-- REASON: Internal singletons to avoid duplicate frames/hooks across sessions.
local achievementEditBoxGlobal
local questEditBoxGlobal

-- REASON: Map locales to Wowhead subdomains for localized links.
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

-- PERF: Helper to create copyable link editboxes with consistent behavior.
local function createLinkEditBox(parent, point, x, y, fontObject)
	local eb = CreateFrame("EditBox", nil, parent)
	eb:SetHeight(16)
	eb:SetPoint(point, x, y)
	eb:SetFontObject(fontObject)
	eb:SetBlinkSpeed(0)
	eb:SetAutoFocus(false)
	eb:EnableKeyboard(false)
	eb:SetScript("OnKeyDown", K.Noop)

	eb.hiddenText = eb:CreateFontString(nil, "ARTWORK", fontObject)
	eb.hiddenText:Hide()

	eb:SetScript("OnMouseUp", function()
		if eb:IsMouseOver() then
			eb:HighlightText()
		else
			eb:HighlightText(0, 0)
		end
	end)

	return eb
end

local function formatWowheadLink(id, type)
	return urlQuestIcon .. "https://" .. wowheadLoc .. "/" .. type .. "=" .. id
end

-- REASON: Achievement Frame Interface. Adds an edit box to the Achievement Frame for easy link copying.
local function initializeAchievementLink()
	if achievementEditBoxGlobal then
		return
	end

	local achievementEditBox = createLinkEditBox(_G.AchievementFrame, "BOTTOMRIGHT", -50, 1, "GameFontNormalSmall")
	achievementEditBox:SetJustifyH("RIGHT")
	achievementEditBox:SetHitRectInsets(90, 0, 0, 0)

	local lastAchievementLink

	local function setAchievementLink(_, achievementID)
		if achievementID then
			local achievementURL = formatWowheadLink(achievementID, "achievement")
			achievementEditBox:SetText(achievementURL)
			achievementEditBox.hiddenText:SetText(achievementURL)
			achievementEditBox:SetWidth(achievementEditBox.hiddenText:GetStringWidth() + 90)

			local achievementLink = GetAchievementLink(achievementID)
			achievementEditBox.tooltipText = achievementLink and (string_match(achievementLink, "%[(.-)%]") .. "|n" .. L["Press To Copy"]) or ""

			achievementEditBox:Show()
			lastAchievementLink = achievementEditBox:GetText()
		end
	end

	hooksecurefunc(_G.AchievementTemplateMixin, "DisplayObjectives", setAchievementLink)
	hooksecurefunc("AchievementFrameComparisonTab_OnClick", function()
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

	achievementEditBoxGlobal = achievementEditBox
end

-- REASON: World Map Interface. Adds an edit box to the World Map for quest links.
local function initializeQuestLink()
	if questEditBoxGlobal then
		return
	end

	local questEditBox = createLinkEditBox(WorldMapFrame.BorderFrame, "TOPLEFT", 100, -4, "GameFontNormal")
	questEditBox:SetFrameLevel(501)
	questEditBox:SetHitRectInsets(0, 90, 0, 0)

	local function updateQuestURL()
		local questID = _G.QuestMapFrame.DetailsFrame:IsShown() and _G.QuestMapFrame_GetDetailQuestID() or C_SuperTrack.GetSuperTrackedQuestID()
		if questID and questID ~= 0 then
			local questURL = formatWowheadLink(questID, "quest")
			questEditBox:SetText(questURL)
			questEditBox.hiddenText:SetText(questURL)
			questEditBox:SetWidth(questEditBox.hiddenText:GetStringWidth() + 90)

			local questLink = GetQuestLink(questID)
			questEditBox.tooltipText = questLink and (string_match(questLink, "%[(.-)%]") .. "|n" .. L["Press To Copy"]) or ""
			if not questLink and questEditBox:IsMouseOver() then
				GameTooltip:Hide()
			end
			questEditBox:Show()
		else
			questEditBox:Hide()
		end
	end

	questEditBox:RegisterEvent("SUPER_TRACKING_CHANGED")
	questEditBox:SetScript("OnEvent", updateQuestURL)
	updateQuestURL()

	hooksecurefunc("QuestMapFrame_ShowQuestDetails", updateQuestURL)
	hooksecurefunc("QuestMapFrame_CloseQuestDetails", updateQuestURL)

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
		updateQuestURL()
	end)

	questEditBoxGlobal = questEditBox
end

function Module:CreateWowHeadLinks()
	if not C["Misc"].ShowWowHeadLinks or C_AddOns.IsAddOnLoaded("Leatrix_Maps") then
		-- REASON: Features disabled or Leatrix Maps conflict: unregister events and hide frames.
		if questEditBoxGlobal then
			questEditBoxGlobal:UnregisterEvent("SUPER_TRACKING_CHANGED")
			questEditBoxGlobal:SetScript("OnEvent", nil)
			questEditBoxGlobal:Hide()
		end
		if achievementEditBoxGlobal then
			achievementEditBoxGlobal:Hide()
		end
		return
	end

	-- REASON: Achievements UI is lod, so we wait for its loading event.
	if C_AddOns.IsAddOnLoaded("Blizzard_AchievementUI") then
		initializeAchievementLink()
	else
		local achievementsWaiter = CreateFrame("Frame")
		achievementsWaiter:RegisterEvent("ADDON_LOADED")
		achievementsWaiter:SetScript("OnEvent", function(self, _, addon)
			if addon == "Blizzard_AchievementUI" then
				initializeAchievementLink()
				self:UnregisterAllEvents()
			end
		end)
	end

	initializeQuestLink()

	-- REASON: Hide the default WorldMap title text to make room for our Wowhead link editbox.
	if _G.WorldMapFrameTitleText then
		_G.WorldMapFrameTitleText:Hide()
	end
end
