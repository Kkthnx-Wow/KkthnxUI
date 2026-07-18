--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Browser-style Back button on the Achievement frame.
-- - Design: hooksecurefunc only — hooks can't be removed, so disable hides the
--   button and gates RememberLastState/GoBack. goingBack latch prevents restore
--   from re-recording the view we just left.
-- - Events: Blizzard_AchievementUI ADDON_LOADED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local _G = _G
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local GetTime = GetTime
local tinsert, tremove = table.insert, table.remove
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local history = {}
local goingBack = false
local enabled = false
local hooked = false
local waiting = false
local curCategory, curAchievement
local curCategoryScroll, curAchievementScroll
local categoryChangeTime, achievementChangeTime = 0, 0
local backButton

local function GetScroll(container)
	local frame = _G[container]
	local box = frame and frame.ScrollBox
	return box and box.GetScrollPercentage and box:GetScrollPercentage()
end

local function SetScroll(container, percentage)
	if percentage == nil then
		return
	end
	local frame = _G[container]
	local box = frame and frame.ScrollBox
	if box and box.SetScrollPercentage then
		box:SetScrollPercentage(percentage)
	end
end

local function RememberLastState()
	if not enabled or goingBack or not curCategory then
		return
	end
	-- The click + select hooks can both fire on one frame; only store once.
	local top = history[#history]
	if top and top.time == GetTime() then
		return
	end

	tinsert(history, {
		time = GetTime(),
		categoryID = curCategory,
		achievementID = curAchievement,
		categoryScroll = curCategoryScroll,
		achievementScroll = curAchievementScroll,
	})

	if backButton then
		backButton:Enable()
	end
end

local function GoBack()
	if not enabled then
		return
	end

	local entry = tremove(history)
	if not entry then
		return
	end

	goingBack = true

	_G.AchievementFrame_UpdateAndSelectCategory(entry.categoryID)
	if entry.achievementID then
		_G.AchievementFrame_SelectAchievement(entry.achievementID)
	end

	SetScroll("AchievementFrameCategories", entry.categoryScroll)
	SetScroll("AchievementFrameAchievements", entry.achievementScroll)

	curCategory = entry.categoryID
	curAchievement = entry.achievementID
	curCategoryScroll = entry.categoryScroll
	curAchievementScroll = entry.achievementScroll

	if #history == 0 and backButton then
		backButton:Disable()
	end

	goingBack = false
end

local function OnEnter(self)
	_G.GameTooltip:SetOwner(self, "ANCHOR_TOP")
	_G.GameTooltip:SetText(_G.BACK)
end

local function OnLeave()
	_G.GameTooltip:Hide()
end

local function CreateButton()
	local header = _G.AchievementFrame and _G.AchievementFrame.Header
	if not header or backButton then
		return
	end

	local button = CreateFrame("Button", nil, header)
	button:SetSize(29, 29)
	button:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
	button:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
	button:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
	button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	-- Tuck it just right of the achievement-points plaque on the header.
	button:SetPoint("LEFT", header.PointBorder or header, "RIGHT", 10, 1)
	button:SetScript("OnClick", GoBack)
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)
	button:Disable()

	backButton = button
end

local function SetupHooks()
	if hooked then
		return
	end
	if not (_G.AchievementFrame and _G.AchievementFrame_UpdateAndSelectCategory and _G.AchievementTemplateMixin) then
		return
	end
	hooked = true

	hooksecurefunc("AchievementFrameCategories_OnCategoryChanged", function(categoryID)
		if curCategory ~= categoryID then
			RememberLastState()
			categoryChangeTime = GetTime()
			curCategory = categoryID
			curCategoryScroll = GetScroll("AchievementFrameCategories")
			curAchievement = nil
		end
	end)

	hooksecurefunc("AchievementFrame_SelectAchievement", function(achievementID)
		if achievementID and achievementID ~= curAchievement then
			RememberLastState()
			achievementChangeTime = GetTime()
			curAchievement = achievementID
			curAchievementScroll = GetScroll("AchievementFrameAchievements")
			curCategoryScroll = GetScroll("AchievementFrameCategories")
		end
	end)

	hooksecurefunc(_G.AchievementTemplateMixin, "ProcessClick", function()
		local achievementID = _G.AchievementFrameAchievements_GetSelectedAchievementId()
		if achievementID and achievementID ~= 0 and achievementID ~= curAchievement then
			if curCategory ~= _G.GetAchievementCategory(achievementID) or curAchievement then
				RememberLastState()
			end
			achievementChangeTime = GetTime()
			curAchievement = achievementID
			curAchievementScroll = GetScroll("AchievementFrameAchievements")
			curCategoryScroll = GetScroll("AchievementFrameCategories")
		end
	end)

	-- Capture the scroll offset that settles on the same frame as a nav change.
	local catBar = _G.AchievementFrameCategories and _G.AchievementFrameCategories.ScrollBar
	if catBar and catBar.RegisterCallback then
		catBar:RegisterCallback(catBar.Event.OnScroll, function(_, percentage)
			if (categoryChangeTime == GetTime() or achievementChangeTime == GetTime()) and curCategoryScroll ~= percentage then
				curCategoryScroll = percentage
			end
		end, Module)
	end

	local achBar = _G.AchievementFrameAchievements and _G.AchievementFrameAchievements.ScrollBar
	if achBar and achBar.RegisterCallback then
		achBar:RegisterCallback(achBar.Event.OnScroll, function(_, percentage)
			if achievementChangeTime == GetTime() and curAchievementScroll ~= percentage then
				curAchievementScroll = percentage
			end
		end, Module)
	end

	CreateButton()
end

local function OnAddonLoaded(_, addon)
	if addon == "Blizzard_AchievementUI" then
		waiting = false
		SetupHooks()
		K:UnregisterEvent("ADDON_LOADED", OnAddonLoaded)
	end
end

function Module:CreateAchievementBackButton()
	enabled = C["Misc"].AchievementBackButton

	if enabled then
		if _G.AchievementFrame or (C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_AchievementUI")) then
			SetupHooks()
		elseif not waiting then
			waiting = true
			K:RegisterEvent("ADDON_LOADED", OnAddonLoaded)
		end
		if backButton then
			backButton:Show()
		end
	elseif backButton then
		-- Hooks can't be removed; hiding + enabled gate makes the feature dormant.
		backButton:Hide()
	end
end
