local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
-- local Module = K:NewModule("Developer")

K.Devs = {
	["Kkthnx-Area 52"] = true,
	["Chithick-Area 52"] = true,
	["Kkthnxbye-Area 52"] = true,
	["Kkthnx-Valdrakken"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

function K.AddToDevTool(data, name)
	if DevTool then
		DevTool:AddData(data, name)
	end
end

do
	local _G = _G
	local ShowUIPanel = ShowUIPanel
	local GetInstanceInfo = GetInstanceInfo
	local InCombatLockdown = InCombatLockdown
	local C_TalkingHead_SetConversationsDeferred = C_TalkingHead.SetConversationsDeferred

	local testConfig = {
		objectiveFrameAutoHideInKeystone = true,
		objectiveFrameAutoHide = true,
	}

	local AutoHider

	local function IsQuestTrackerLoaded()
		return K.IsAddOnEnabled("!KalielsTracker") or K.IsAddOnEnabled("DugisGuideViewerZ")
	end

	local function IsObjectiveTrackerCollapsed(frame)
		return frame:GetParent() == K.UIFrameHider
	end

	local function CollapseObjectiveTracker(frame)
		frame:SetParent(K.UIFrameHider)
	end

	local function ExpandObjectiveTracker(frame)
		frame:SetParent(_G.UIParent)
	end

	local function AutoHideObjectiveTrackerOnShow()
		local tracker = _G.ObjectiveTrackerFrame
		if tracker and IsObjectiveTrackerCollapsed(tracker) then
			ExpandObjectiveTracker(tracker)
		end
	end

	local function AutoHideObjectiveTrackerOnHide()
		local tracker = _G.ObjectiveTrackerFrame
		if not tracker or IsObjectiveTrackerCollapsed(tracker) then
			return
		end

		if testConfig.objectiveFrameAutoHideInKeystone then
			CollapseObjectiveTracker(tracker)
		else
			local _, _, difficultyID = GetInstanceInfo()
			if difficultyID ~= 8 then -- ignore hide in keystone runs
				CollapseObjectiveTracker(tracker)
			end
		end
	end

	local function SetupAutoHideObjectiveTracker()
		local tracker = _G.ObjectiveTrackerFrame
		if not tracker then
			return
		end

		if not AutoHider then
			AutoHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
			AutoHider:SetAttribute("_onstate-objectiveHider", "if newstate == 1 then self:Hide() else self:Show() end")
			AutoHider:SetScript("OnHide", AutoHideObjectiveTrackerOnHide)
			AutoHider:SetScript("OnShow", AutoHideObjectiveTrackerOnShow)
		end

		if testConfig.objectiveFrameAutoHide then
			RegisterStateDriver(AutoHider, "objectiveHider", "[@arena1,exists][@arena2,exists][@arena3,exists][@arena4,exists][@arena5,exists][@boss1,exists][@boss2,exists][@boss3,exists][@boss4,exists][@boss5,exists] 1;0")
		else
			UnregisterStateDriver(AutoHider, "objectiveHider")
			AutoHideObjectiveTrackerOnShow() -- reshow it when needed
		end
	end

	-- Clone of SplashFrameMixin:OnHide() to remove Objective Update to prevent taint on the Quest Button
	local function OnSplashFrameHide(frame)
		local fromGameMenu = frame.screenInfo and frame.screenInfo.gameMenuRequest
		frame.screenInfo = nil

		C_TalkingHead_SetConversationsDeferred(false)
		_G.AlertFrame:SetAlertsEnabled(true, "splashFrame")
		-- ObjectiveTrackerFrame:Update()

		if fromGameMenu and not frame.showingQuestDialog and not InCombatLockdown() then
			ShowUIPanel(_G.GameMenuFrame)
		end

		frame.showingQuestDialog = nil
	end

	local function SetupObjectiveTracker()
		SetupAutoHideObjectiveTracker()

		local splash = _G.SplashFrame
		if splash then
			splash:SetScript("OnHide", OnSplashFrameHide)
		end
	end

	K:RegisterEvent("PLAYER_LOGIN", function()
		if not IsQuestTrackerLoaded() then
			SetupObjectiveTracker()
		end
	end)
end

--[[ ============================================================
    SECTION: Chat Message Blocker
    Filters out specific phrases or patterns in chat messages 
    (e.g., monster emotes) based on a configurable list of patterns.
=============================================================== ]]

do
	-- Cache global references for performance
	local string_match = string.match
	local string_gsub = string.gsub
	local ipairs = ipairs
	local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter

	-- Create the ChatFilter object
	local ChatFilter = {}
	ChatFilter.blockedPatterns = {
		"^%s goes into a frenzy!$",
		"^%s attempts to run away in fear!$",
		"^%s collapses but the broken body rises again!$",
		"^%s becomes enraged!$",
	}

	-- Check if a message matches any of the blocked patterns
	function ChatFilter:IsBlockedMessage(message)
		for _, pattern in ipairs(self.blockedPatterns) do
			if string_match(message, string_gsub(pattern, "%%s", ".+")) then
				return true
			end
		end
		return false
	end

	-- Custom chat message filter function
	local function MyChatFilter(self, event, msg, sender, ...)
		if ChatFilter:IsBlockedMessage(msg) then
			return true
		end
		return false
	end

	-- Add the filter for specific chat message events
	ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_EMOTE", MyChatFilter)
end

do
	-- Define the keyword to trigger a guild invite
	local keyword = "ginv"
	local pendingInvites = {} -- Table to store pending invites

	-- Function to update the button's visibility and count
	local function UpdateInviteButtonVisibility(button)
		if #pendingInvites > 0 and CanGuildInvite() then
			button:Show()
		else
			button:Hide()
		end
		button:SetText(#pendingInvites > 0 and tostring(#pendingInvites) or "")
	end

	-- Function to create a tooltip for pending invites
	local function CreateInviteButtonTooltip(button)
		button:SetScript("OnEnter", function(self)
			if #pendingInvites > 0 then
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:ClearLines()
				GameTooltip:AddLine("Pending Invites:")
				for _, name in ipairs(pendingInvites) do
					GameTooltip:AddLine(name, 1, 1, 1)
				end
				GameTooltip:AddLine(" ")
				GameTooltip:AddDoubleLine("Left Click", ACCEPT, nil, nil, nil, 0, 1, 0)
				GameTooltip:AddDoubleLine("Right Click", DECLINE, nil, nil, nil, 1, 0, 0)
				GameTooltip:Show()
			end
		end)

		button:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
	end

	-- Function to set the guild tabard textures on the button
	local function SetGuildTabardFilesTexture(button, width, height)
		if not IsInGuild() then
			-- print("You are not in a guild with a tabard or can't inv players to the guild.")
			return
		end

		local tabardBackgroundUpper, tabardBackgroundLower, tabardEmblemUpper, tabardEmblemLower, tabardBorderUpper, tabardBorderLower = GetGuildTabardFiles()
		if tabardBackgroundUpper and tabardBackgroundLower and tabardEmblemUpper and tabardEmblemLower and tabardBorderUpper and tabardBorderLower then
			local upperLeft = button:CreateTexture("$parentBackgroundUL", "BACKGROUND", nil, -1)
			upperLeft:SetSize(width, height)
			upperLeft:SetPoint("TOPLEFT", button, 0, 0)
			upperLeft:SetTexCoord(0.5, 1, 0, 1)
			upperLeft:SetTexture(tabardBackgroundUpper)

			local upperRight = button:CreateTexture("$parentBackgroundUR", "BACKGROUND", nil, -1)
			upperRight:SetSize(width, height)
			upperRight:SetPoint("LEFT", upperLeft, "RIGHT", 0, 0)
			upperRight:SetTexCoord(1, 0.5, 0, 1)
			upperRight:SetTexture(tabardBackgroundUpper)

			local bottomLeft = button:CreateTexture("$parentBackgroundBL", "BACKGROUND", nil, -1)
			bottomLeft:SetSize(width, height)
			bottomLeft:SetPoint("TOP", upperLeft, "BOTTOM", 0, 0)
			bottomLeft:SetTexCoord(0.5, 1, 0, 1)
			bottomLeft:SetTexture(tabardBackgroundLower)

			local bottomRight = button:CreateTexture("$parentBackgroundBR", "BACKGROUND", nil, -1)
			bottomRight:SetSize(width, height)
			bottomRight:SetPoint("LEFT", bottomLeft, "RIGHT", 0, 0)
			bottomRight:SetTexCoord(1, 0.5, 0, 1)
			bottomRight:SetTexture(tabardBackgroundLower)

			local upperLeftBorder = button:CreateTexture("$parentBorderUL", "BORDER", nil, -1)
			upperLeftBorder:SetSize(width, height)
			upperLeftBorder:SetPoint("TOPLEFT", upperLeft, 0, 0)
			upperLeftBorder:SetTexCoord(0.5, 1, 0, 1)
			upperLeftBorder:SetTexture(tabardBorderUpper)

			local upperRightBorder = button:CreateTexture("$parentBorderUR", "BORDER", nil, -1)
			upperRightBorder:SetSize(width, height)
			upperRightBorder:SetPoint("LEFT", upperLeftBorder, "RIGHT", 0, 0)
			upperRightBorder:SetTexCoord(1, 0.5, 0, 1)
			upperRightBorder:SetTexture(tabardBorderUpper)

			local bottomLeftBorder = button:CreateTexture("$parentBorderBL", "BORDER", nil, -1)
			bottomLeftBorder:SetSize(width, height)
			bottomLeftBorder:SetPoint("TOP", upperLeftBorder, "BOTTOM", 0, 0)
			bottomLeftBorder:SetTexCoord(0.5, 1, 0, 1)
			bottomLeftBorder:SetTexture(tabardBorderLower)

			local bottomRightBorder = button:CreateTexture("$parentBorderBR", "BORDER", nil, -1)
			bottomRightBorder:SetSize(width, height)
			bottomRightBorder:SetPoint("LEFT", bottomLeftBorder, "RIGHT", 0, 0)
			bottomRightBorder:SetTexCoord(1, 0.5, 0, 1)
			bottomRightBorder:SetTexture(tabardBorderLower)

			local upperLeftEmblem = button:CreateTexture("$parentEmblemUL", "BORDER", nil, -1)
			upperLeftEmblem:SetSize(width, height)
			upperLeftEmblem:SetPoint("TOPLEFT", upperLeft, 0, 0)
			upperLeftEmblem:SetTexCoord(0.5, 1, 0, 1)
			upperLeftEmblem:SetTexture(tabardEmblemUpper)

			local upperRightEmblem = button:CreateTexture("$parentEmblemUR", "BORDER", nil, -1)
			upperRightEmblem:SetSize(width, height)
			upperRightEmblem:SetPoint("LEFT", upperLeftBorder, "RIGHT", 0, 0)
			upperRightEmblem:SetTexCoord(1, 0.5, 0, 1)
			upperRightEmblem:SetTexture(tabardEmblemUpper)

			local bottomLeftEmblem = button:CreateTexture("$parentEmblemBL", "BORDER", nil, -1)
			bottomLeftEmblem:SetSize(width, height)
			bottomLeftEmblem:SetPoint("TOP", upperLeftEmblem, "BOTTOM", 0, 0)
			bottomLeftEmblem:SetTexCoord(0.5, 1, 0, 1)
			bottomLeftEmblem:SetTexture(tabardEmblemLower)

			local bottomRightEmblem = button:CreateTexture("$parentEmblemBR", "BORDER", nil, -1)
			bottomRightEmblem:SetSize(width, height)
			bottomRightEmblem:SetPoint("LEFT", bottomLeftEmblem, "RIGHT", 0, 0)
			bottomRightEmblem:SetTexCoord(1, 0.5, 0, 1)
			bottomRightEmblem:SetTexture(tabardEmblemLower)
		else
			print("Unable to retrieve guild tabard textures.")
		end
	end

	-- Create the invite button
	local inviteButton = CreateFrame("Button", "InviteButton", UIParent)
	inviteButton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
	inviteButton:CreateBorder()
	inviteButton:SetSize(70, 70) -- Adjust size for the tabard logo
	inviteButton:SetPoint("CENTER")
	inviteButton:Hide() -- Initially hidden

	-- Make the button movable
	inviteButton:SetMovable(true)
	inviteButton:EnableMouse(true)
	inviteButton:RegisterForDrag("LeftButton")
	inviteButton:SetScript("OnDragStart", function(self)
		self:StartMoving()
	end)
	inviteButton:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
	end)

	-- Function to handle whisper events
	local function OnEvent(self, event, message, sender)
		if event == "CHAT_MSG_WHISPER" then
			local senderName = Ambiguate(sender, "none") -- Strip realm info from sender name
			if string.lower(message) == keyword then
				-- Add sender to pending invites if not already added
				if not tContains(pendingInvites, senderName) then
					table.insert(pendingInvites, senderName)
					print("Pending guild invite for " .. senderName .. ". Press the 'Invite' button to confirm.")
				end
				UpdateInviteButtonVisibility(inviteButton)
			end
		end
	end

	-- Add text for the count
	local buttonText = inviteButton:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	buttonText:SetPoint("BOTTOMRIGHT", inviteButton, "BOTTOMRIGHT", -5, 5)
	inviteButton:SetFontString(buttonText)

	-- Add the guild tabard texture to the button
	SetGuildTabardFilesTexture(inviteButton, 35, 35)

	-- Add the tooltip for pending invites
	CreateInviteButtonTooltip(inviteButton)

	-- OnClick handler for sending invites
	inviteButton:SetScript("OnClick", function(_, btn)
		if #pendingInvites > 0 then
			local target = table.remove(pendingInvites, 1)
			if btn == "LeftButton" then
				C_GuildInfo.Invite(target)
				SendChatMessage("You have been invited to the guild!", "WHISPER", nil, target)
			elseif btn == "RightButton" then
				SendChatMessage("You have been decliend to join the guild!", "WHISPER", nil, target)
			end
			UpdateInviteButtonVisibility(inviteButton)
		else
			print("No pending invites.")
		end
	end)

	-- Frame for handling whispers
	local AutoGuildInviteFrame = CreateFrame("Frame", "AutoGuildInviteFrame")
	AutoGuildInviteFrame:RegisterEvent("CHAT_MSG_WHISPER")
	AutoGuildInviteFrame:SetScript("OnEvent", OnEvent)
end
