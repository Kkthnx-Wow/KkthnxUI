local K, C = KkthnxUI[1], KkthnxUI[2]

local table_insert = table.insert
local hooksecurefunc = hooksecurefunc

table_insert(C.defaultThemes, function()
	-- Constants for textures
	local FRIEND_TEXTURE = "UI-ChatIcon-App"
	local QUEUE_TEXTURE = "groupfinder-eye-frame"
	local HOME_TEXTURE = "Interface\\Buttons\\UI-HomeButton"

	-- Skin the Battle.net toast frame
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	BNToastFrame.TooltipFrame:HideBackdrop()
	BNToastFrame.TooltipFrame:CreateBorder()
	BNToastFrame.CloseButton:SkinCloseButton()

	-- Skin the Quick Join toast button
	QuickJoinToastButton:SetSize(28, 28)
	QuickJoinToastButton.FriendsButton:SetAtlas(FRIEND_TEXTURE)
	QuickJoinToastButton.QueueButton:SetAtlas(QUEUE_TEXTURE)
	QuickJoinToastButton:SetHighlightTexture(0)

	QuickJoinToastButton.FriendCount:ClearAllPoints()
	QuickJoinToastButton.FriendCount:SetFontObject(K.UIFont)
	QuickJoinToastButton.FriendCount:SetPoint("BOTTOM", 1, 2)

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

	QuickJoinToastButton:HookScript("OnMouseDown", function(self)
		self.FriendsButton:SetAtlas(FRIEND_TEXTURE)
	end)

	QuickJoinToastButton:HookScript("OnMouseUp", function(self)
		self.FriendsButton:SetAtlas(FRIEND_TEXTURE)
	end)

	QuickJoinToastButton.Toast:ClearAllPoints()
	QuickJoinToastButton.Toast:SetPoint("LEFT", QuickJoinToastButton, "RIGHT")

	-- Skin the chat frame buttons
	ChatFrameChannelButton:SkinButton()
	ChatFrameChannelButton:SetSize(16, 16)
	ChatFrameChannelButton.Flash:Hide()

	ChatFrameToggleVoiceDeafenButton:SkinButton()
	ChatFrameToggleVoiceDeafenButton:SetSize(16, 16)

	ChatFrameToggleVoiceMuteButton:SkinButton()
	ChatFrameToggleVoiceMuteButton:SetSize(16, 16)

	ChatFrameMenuButton:SkinButton()
	ChatFrameMenuButton:SetSize(16, 16)
	ChatFrameMenuButton:SetNormalTexture(HOME_TEXTURE)
	ChatFrameMenuButton:SetPushedTexture(HOME_TEXTURE)

	-- Skin the voice chat channel activated notification
	VoiceChatChannelActivatedNotification:SetBackdrop(nil)
	VoiceChatChannelActivatedNotification:CreateBorder()
	VoiceChatChannelActivatedNotification.CloseButton:SkinCloseButton()
	VoiceChatChannelActivatedNotification.CloseButton:SetSize(32, 32)
	VoiceChatChannelActivatedNotification.CloseButton:SetPoint("TOPRIGHT", 4, 4)
end)
