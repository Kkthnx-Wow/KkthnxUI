local K = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local C_Timer_After = _G.C_Timer.After
local StaticPopupSpecial_Hide = _G.StaticPopupSpecial_Hide
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopupDialogs = _G.StaticPopupDialogs
local hooksecurefunc = _G.hooksecurefunc
local HideUIPanel = _G.HideUIPanel

local pendingFrame

function Module:HookApplicationClick()
	if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
		LFGListFrame.SearchPanel.SignUpButton:Click()
	end

	if LFGListApplicationDialog:IsShown() and LFGListApplicationDialog.SignUpButton:IsEnabled() then
		LFGListApplicationDialog.SignUpButton:Click()
	end
end

function Module:DialogHideInSecond()
	if not pendingFrame then
		return
	end

	if pendingFrame.informational then
		StaticPopupSpecial_Hide(pendingFrame)
	elseif pendingFrame == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" then
		StaticPopup_Hide(pendingFrame)
	end
	pendingFrame = nil
end

function Module:HookDialogOnShow()
	pendingFrame = self
	C_Timer_After(1, Module.DialogHideInSecond)
end

function Module:CreateQuickJoin()
	if K.Client == "zhCN" then
		StaticPopupDialogs["LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS"].text = "针对此项活动，你的队伍人数已满，将被移出列表。"
	end

	for i = 1, 10 do
		local bu = _G["LFGListSearchPanelScrollFrameButton"..i]
		if bu then
			bu:HookScript("OnDoubleClick", Module.HookApplicationClick)
		end
	end

	hooksecurefunc("LFGListInviteDialog_Accept", function()
		if PVEFrame:IsShown() then
			HideUIPanel(PVEFrame)
		end
	end)

	hooksecurefunc("StaticPopup_Show", Module.HookDialogOnShow)
	hooksecurefunc("LFGListInviteDialog_Show", Module.HookDialogOnShow)
end