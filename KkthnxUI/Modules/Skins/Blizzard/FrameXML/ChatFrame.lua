local K, C = unpack(KkthnxUI)

local table_insert = table.insert

local hooksecurefunc = hooksecurefunc

table_insert(C.defaultThemes, function()
	local friendTex = "UI-ChatIcon-App"
	local queueTex = "groupfinder-eye-frame"
	local homeTex = "Interface\\Buttons\\UI-HomeButton"

	-- Battlenet toast frame
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	BNToastFrame.TooltipFrame:HideBackdrop()
	BNToastFrame.TooltipFrame:CreateBorder()
	BNToastFrame.CloseButton:SkinCloseButton()

	QuickJoinToastButton:SetSize(28, 28)

	QuickJoinToastButton.FriendsButton:SetAtlas(friendTex)
	QuickJoinToastButton.QueueButton:SetAtlas(queueTex)

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
		self.FriendsButton:SetAtlas(friendTex)
		self.QueueButton:SetAtlas(queueTex)
		self.FlashingLayer:SetAtlas(queueTex)
		self.FriendsButton:SetShown(false)
		self.FriendCount:SetShown(false)
	end)

	QuickJoinToastButton:HookScript("OnMouseDown", function(self)
		self.FriendsButton:SetAtlas(friendTex)
	end)
	QuickJoinToastButton:HookScript("OnMouseUp", function(self)
		self.FriendsButton:SetAtlas(friendTex)
	end)

	QuickJoinToastButton.Toast:ClearAllPoints()
	QuickJoinToastButton.Toast:SetPoint("LEFT", QuickJoinToastButton, "RIGHT")

	ChatFrameChannelButton:SkinButton()
	ChatFrameChannelButton:SetSize(16, 16)
	ChatFrameChannelButton.Flash:Kill()

	ChatFrameToggleVoiceDeafenButton:SkinButton()
	ChatFrameToggleVoiceDeafenButton:SetSize(16, 16)

	ChatFrameToggleVoiceMuteButton:SkinButton()
	ChatFrameToggleVoiceMuteButton:SetSize(16, 16)

	ChatFrameMenuButton:SkinButton()
	ChatFrameMenuButton:SetSize(16, 16)
	ChatFrameMenuButton:SetNormalTexture(homeTex)
	ChatFrameMenuButton:SetPushedTexture(homeTex)

	VoiceChatChannelActivatedNotification:SetBackdrop(nil)
	VoiceChatChannelActivatedNotification:CreateBorder()
	VoiceChatChannelActivatedNotification.CloseButton:SkinCloseButton()
	VoiceChatChannelActivatedNotification.CloseButton:SetSize(32, 32)
	VoiceChatChannelActivatedNotification.CloseButton:SetPoint("TOPRIGHT", 4, 4)
end)
