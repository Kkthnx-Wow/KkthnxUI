local K, C = KkthnxUI[1], KkthnxUI[2]
local table_insert = table.insert
local hooksecurefunc = hooksecurefunc

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
	local FRIEND_TEXTURE = "UI-ChatIcon-App"
	local QUEUE_TEXTURE = "groupfinder-eye-frame"

	button:SetSize(28, 28)
	button:SetHighlightTexture(0)
	button.FriendsButton:SetAtlas(FRIEND_TEXTURE)
	button.QueueButton:SetAtlas(QUEUE_TEXTURE)
	button.FriendCount:ClearAllPoints()
	button.FriendCount:SetFontObject(K.UIFont)
	button.FriendCount:SetPoint("BOTTOM", 1, 2)
end

table_insert(C.defaultThemes, function()
	local FRIEND_TEXTURE = "UI-ChatIcon-App"
	local QUEUE_TEXTURE = "groupfinder-eye-frame"
	local HOME_TEXTURE = "Interface\\Buttons\\UI-HomeButton"

	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	BNToastFrame.TooltipFrame:HideBackdrop()
	BNToastFrame.TooltipFrame:CreateBorder()
	SkinCloseButton(BNToastFrame.CloseButton, 18)

	SkinQuickJoinToastButton(QuickJoinToastButton)

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

	SkinChatButton(ChatFrameChannelButton, 16)
	SkinChatButton(ChatFrameToggleVoiceDeafenButton, 16)
	SkinChatButton(ChatFrameToggleVoiceMuteButton, 16)
	SkinChatButton(ChatFrameMenuButton, 16)

	ChatFrameMenuButton:SetNormalTexture(HOME_TEXTURE)
	ChatFrameMenuButton:SetPushedTexture(HOME_TEXTURE)

	VoiceChatChannelActivatedNotification:SetBackdrop(nil)
	VoiceChatChannelActivatedNotification:CreateBorder()
	SkinCloseButton(VoiceChatChannelActivatedNotification.CloseButton, 32)
	VoiceChatChannelActivatedNotification.CloseButton:SetPoint("TOPRIGHT", 4, 4)
end)
