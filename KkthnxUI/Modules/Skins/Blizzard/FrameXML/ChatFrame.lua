--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Chat Frame buttons and notifications.
-- - Design: Applies custom buttons, borders, and textures for chat-related UI elements.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local table_insert = _G.table.insert
local hooksecurefunc = _G.hooksecurefunc

local BNToastFrame = _G.BNToastFrame
local QuickJoinToastButton = _G.QuickJoinToastButton
local ChatFrameChannelButton = _G.ChatFrameChannelButton
local ChatFrameToggleVoiceDeafenButton = _G.ChatFrameToggleVoiceDeafenButton
local ChatFrameToggleVoiceMuteButton = _G.ChatFrameToggleVoiceMuteButton
local ChatFrameMenuButton = _G.ChatFrameMenuButton
local VoiceChatChannelActivatedNotification = _G.VoiceChatChannelActivatedNotification

local FRIEND_TEXTURE = "Battlenet-ClientIcon-App"
local QUEUE_TEXTURE = "groupfinder-eye-frame"
local HOME_TEXTURE = "Interface\\Buttons\\UI-HomeButton"

-- Skinning Functions
local function SkinChatButton(button, size)
	button:SkinButton()
	button:SetSize(size, size)
	if button.Flash then
		button.Flash:Hide()
	end
end

local function SkinCloseButton(button, size)
	button:SkinCloseButton()
	button:SetSize(size, size)
end

local function SkinQuickJoinToastButton(button)
	button:SetSize(32, 32)
	--button:SetHighlightTexture(0)
	button.FriendsButton:SetAtlas(FRIEND_TEXTURE)
	button.QueueButton:SetAtlas(QUEUE_TEXTURE)
	button.FriendCount:ClearAllPoints()
	button.FriendCount:SetFontObject(K.UIFont)
	button.FriendCount:SetPoint("BOTTOM", 1, 2)
end

-- Theme Application
-- REASON: Main entry point for Blizzard Chat Frame skinning.
table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- BNToastFrame
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	BNToastFrame.TooltipFrame:HideBackdrop()
	BNToastFrame.TooltipFrame:CreateBorder()
	SkinCloseButton(BNToastFrame.CloseButton, 18)

	-- QuickJoinToastButton
	SkinQuickJoinToastButton(QuickJoinToastButton)
	QuickJoinToastButton:HookScript("OnMouseDown", function(self)
		self.FriendsButton:SetAtlas(FRIEND_TEXTURE)
	end)
	QuickJoinToastButton:HookScript("OnMouseUp", function(self)
		self.FriendsButton:SetAtlas(FRIEND_TEXTURE)
	end)
	QuickJoinToastButton.Toast:ClearAllPoints()
	QuickJoinToastButton.Toast:SetPoint("LEFT", QuickJoinToastButton, "RIGHT")

	hooksecurefunc(QuickJoinToastButton, "ToastToFriendFinished", function(self)
		self.FriendsButton:SetShown(not self.displayedToast)
		self.FriendCount:SetShown(not self.displayedToast)
	end)
	hooksecurefunc(QuickJoinToastButton, "UpdateQueueIcon", function(self)
		if not self.displayedToast then
			return
		end
		self.FriendsButton:SetAtlas(FRIEND_TEXTURE)
		self.QueueButton:SetAtlas(QUEUE_TEXTURE)
		self.FlashingLayer:SetAtlas(QUEUE_TEXTURE)
		self.FriendsButton:SetShown(false)
		self.FriendCount:SetShown(false)
	end)

	-- ChatFrame Buttons
	SkinChatButton(ChatFrameChannelButton, 16)
	SkinChatButton(ChatFrameToggleVoiceDeafenButton, 16)
	SkinChatButton(ChatFrameToggleVoiceMuteButton, 16)
	SkinChatButton(ChatFrameMenuButton, 16)
	ChatFrameMenuButton:SetNormalTexture(HOME_TEXTURE)
	ChatFrameMenuButton:SetPushedTexture(HOME_TEXTURE)

	-- VoiceChatChannelActivatedNotification
	VoiceChatChannelActivatedNotification:SetBackdrop(nil)
	VoiceChatChannelActivatedNotification:CreateBorder()
	SkinCloseButton(VoiceChatChannelActivatedNotification.CloseButton, 32)
	VoiceChatChannelActivatedNotification.CloseButton:SetPoint("TOPRIGHT", 4, 4)
end)
