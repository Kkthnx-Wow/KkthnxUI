local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

local function SkinChatFrame()
	-- Battlenet toast frame
	BNToastFrame:SetClampedToScreen(true)
	BNToastFrame:SetBackdrop(nil)
	BNToastFrame:CreateBorder()
	BNToastFrame.TooltipFrame:SetBackdrop(nil)
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
		if not self.displayedToast then return end
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

	local bg = CreateFrame("Frame", nil, QuickJoinToastButton.Toast)
	bg:SetFrameLevel(QuickJoinToastButton.Toast:GetFrameLevel())
	bg:CreateBorder()
	bg:SetPoint("TOPLEFT", 10, -6)
	bg:SetPoint("BOTTOMRIGHT", 0, 6)
	bg:Hide()

	hooksecurefunc(QuickJoinToastButton, "ShowToast", function()
		bg:Show()
	end)

	hooksecurefunc(QuickJoinToastButton, "HideToast", function()
		bg:Hide()
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
end

table_insert(Module.NewSkin["KkthnxUI"], SkinChatFrame)