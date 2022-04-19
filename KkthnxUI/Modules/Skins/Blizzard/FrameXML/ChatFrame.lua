local K, C = unpack(KkthnxUI)

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	-- Battlenet toast frame
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	BNToastFrame.TooltipFrame:HideBackdrop()
	BNToastFrame.TooltipFrame:CreateBorder()
	BNToastFrame.CloseButton:SkinCloseButton()
	BNToastFrame.CloseButton:SetSize(32, 32)
	BNToastFrame.CloseButton:SetPoint("TOPRIGHT", 4, 4)

	local friendTex = "Interface\\HELPFRAME\\ReportLagIcon-Chat"
	local queueTex = "Interface\\HELPFRAME\\HelpIcon-ItemRestoration"
	local homeTex = "Interface\\Buttons\\UI-HomeButton"

	QuickJoinToastButton.FriendsButton:SetTexture(friendTex)
	QuickJoinToastButton.QueueButton:SetTexture(queueTex)
	QuickJoinToastButton:SetHighlightTexture("")

	hooksecurefunc(QuickJoinToastButton, "ToastToFriendFinished", function(self)
		self.FriendsButton:SetShown(not self.displayedToast)
	end)

	hooksecurefunc(QuickJoinToastButton, "UpdateQueueIcon", function(self)
		if not self.displayedToast then
			return
		end
		self.QueueButton:SetTexture(queueTex)
		self.FlashingLayer:SetTexture(queueTex)
		self.FriendsButton:SetShown(false)
	end)

	QuickJoinToastButton:HookScript("OnMouseDown", function(self)
		self.FriendsButton:SetTexture(friendTex)
	end)

	QuickJoinToastButton:HookScript("OnMouseUp", function(self)
		self.FriendsButton:SetTexture(friendTex)
	end)

	QuickJoinToastButton.Toast.Background:SetTexture("")

	local QuickJoinToastButton_Toast_Border = CreateFrame("Frame", nil, QuickJoinToastButton.Toast)
	QuickJoinToastButton_Toast_Border:SetFrameLevel(QuickJoinToastButton.Toast:GetFrameLevel())
	QuickJoinToastButton_Toast_Border:CreateBorder()
	QuickJoinToastButton_Toast_Border:SetPoint("TOPLEFT", 10, -6)
	QuickJoinToastButton_Toast_Border:SetPoint("BOTTOMRIGHT", 0, 6)
	QuickJoinToastButton_Toast_Border:Hide()

	hooksecurefunc(QuickJoinToastButton, "ShowToast", function()
		QuickJoinToastButton_Toast_Border:Show()
	end)

	hooksecurefunc(QuickJoinToastButton, "HideToast", function()
		QuickJoinToastButton_Toast_Border:Hide()
	end)

	ChatFrameChannelButton:SkinButton()
	ChatFrameChannelButton:SetSize(16, 16)

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
