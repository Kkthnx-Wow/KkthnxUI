local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("OpenMail", "AceEvent-3.0")
if K.Legion735 then
	return
end

local _G = _G

local C_Timer_After = _G.C_Timer.After
local CheckInbox = _G.CheckInbox
local GetInboxHeaderInfo = _G.GetInboxHeaderInfo
local GetInboxNumItems = _G.GetInboxNumItems
local MONEY = _G.MONEY

local lastReceipient
function Module:MAIL_SEND_SUCCESS()
	if (lastReceipient) then
		SendMailNameEditBox:SetText(lastReceipient)
		SendMailNameEditBox:ClearFocus()
	end
end

hooksecurefunc("SendMail", function(name)
	lastReceipient = name
end)

function Module:UI_ERROR_MESSAGE(msg)
	if (msg == ERR_MAIL_INVALID_ATTACHMENT_SLOT) then
		if (messageID == 610) then
			SendMailMailButton:Click()
		end
	end
end

local function OnTextChanged(self)
	if (self:GetText() ~= "" and SendMailSubjectEditBox:GetText() == "") then
		SendMailSubjectEditBox:SetText(MONEY)
	end
end

SendMailMoneyGold:HookScript("OnTextChanged", OnTextChanged)
SendMailMoneySilver:HookScript("OnTextChanged", OnTextChanged)
SendMailMoneyCopper:HookScript("OnTextChanged", OnTextChanged)

local totalElapsed = 0
InboxFrame:HookScript("OnUpdate", function(self, elapsed)
	if (totalElapsed < 10) then
		totalElapsed = totalElapsed + elapsed
	else
		totalElapsed = 0
		CheckInbox()
	end
end)

local Button = CreateFrame("Button", nil, InboxFrame, "UIPanelButtonTemplate")
Button:SetPoint("BOTTOM", -28, 102)
Button:SetSize(90, 25)
Button:SetText(QUICKBUTTON_NAME_EVERYTHING)

local lastIndex
local function GetMail()
	if (GetInboxNumItems() - lastIndex <= 0) then
		Button:GetScript("OnHide")(Button)
		return
	end

	local index = lastIndex + 1
	local _, _, sender, _, money, cod, _, numItems, isRead, _, _, _, numStacks = GetInboxHeaderInfo(index)

	if (money > 0) then
		TakeInboxMoney(index)
	end

	if (numItems or numStacks) then
		AutoLootMailItem(index)
	end

	if (sender == "The Postmaster" and not numItems and money == 0) then
		DeleteInboxItem(index)
	elseif (isRead or cod > 0) then
		lastIndex = index
	end

	C_Timer_After(1/2, GetMail)
end

Button:SetScript("OnClick", function(self)
	self:Disable()
	lastIndex = 0
	GetMail()
end)

Button:SetScript("OnHide", function(self)
	self:UnregisterEvent("MAIL_INBOX_UPDATE")
	self:Enable()
end)

function Module:OnEnable()
	self:RegisterEvent("MAIL_SEND_SUCCESS")
	self:RegisterEvent("UI_ERROR_MESSAGE")
end