--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/Mail.lua
	Purpose:
		The mailbox jobs Blizzard leaves you to do one click at a time.

		Open All Mail already exists and is good, so this does not reimplement it.
		What is missing is taking only the gold and leaving the items, emptying a
		single opened mail in one click, and seeing what is attached without
		opening anything.

		Retrieval is paced the way Blizzard paces its own: the server processes one
		mail command at a time, so each step waits on C_Mail.IsCommandPending
		rather than firing on a fixed schedule. OPEN_ALL_MAIL_MIN_DELAY is 0.15 in
		MailFrame.lua and the same floor is used here, so a slow server stretches
		the gap instead of dropping requests on the floor.

		C_Mail.SetOpeningAll is set for the duration, which is what stops the
		inbox re-sorting under the loop while it runs.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:NewModule("Mail")

local CreateFrame = CreateFrame
local GetInboxNumItems = GetInboxNumItems
local GetInboxHeaderInfo = GetInboxHeaderInfo
local GetInboxItem = GetInboxItem
local TakeInboxMoney = TakeInboxMoney
local TakeInboxItem = TakeInboxItem
local HasInboxItem = HasInboxItem
local C_Mail = C_Mail
local C_Item = C_Item
local GetCoinTextureString = GetCoinTextureString
local wipe, pairs, format = wipe, pairs, string.format

-- Matches OPEN_ALL_MAIL_MIN_DELAY in Blizzard's mail frame. Anything shorter
-- just queues requests the server will not answer any faster.
local STEP_DELAY = 0.15

local goldRunner, inboxIndex, collecting

-- Scratch table for the attachment tooltip, reused so hovering a full inbox does
-- not churn a table per row.
local attachments = {}

-- ---------------------------------------------------------------------------
-- Collect gold
-- ---------------------------------------------------------------------------

local function StopCollecting()
	collecting = false
	goldRunner:SetScript("OnUpdate", nil)
	goldRunner.wait = nil
	C_Mail.SetOpeningAll(false)
	if Module.GoldButton then
		Module.GoldButton:Enable()
		Module.GoldButton:SetText(L["Collect Gold"])
	end
end

local function TakeNextGold()
	while inboxIndex >= 1 do
		-- COD mail wants a payment confirmation, so it is never taken silently.
		local _, _, _, _, money, codAmount = GetInboxHeaderInfo(inboxIndex)
		local skip = (codAmount and codAmount > 0) or not money or money <= 0
		if not skip and C_Mail.HasInboxMoney(inboxIndex) then
			TakeInboxMoney(inboxIndex)
			inboxIndex = inboxIndex - 1
			return true
		end
		inboxIndex = inboxIndex - 1
	end
	return false
end

local function OnGoldUpdate(self, elapsed)
	self.wait = (self.wait or 0) - elapsed
	if self.wait > 0 then
		return
	end
	-- One command at a time. Until the server answers the last one, waiting is
	-- the only correct thing to do.
	if C_Mail.IsCommandPending() then
		self.wait = STEP_DELAY
		return
	end
	if TakeNextGold() then
		self.wait = STEP_DELAY
	else
		StopCollecting()
	end
end

local function StartCollecting()
	if collecting then
		return
	end
	local count = GetInboxNumItems()
	if count == 0 then
		return
	end

	collecting = true
	inboxIndex = count
	C_Mail.SetOpeningAll(true)

	Module.GoldButton:Disable()
	Module.GoldButton:SetText(L["Collecting"])

	goldRunner.wait = 0
	goldRunner:SetScript("OnUpdate", OnGoldUpdate)
end

-- What is sitting in the inbox, so the button says whether it is worth clicking.
local function TotalGold()
	local total = 0
	for i = 1, GetInboxNumItems() do
		local _, _, _, _, money, codAmount = GetInboxHeaderInfo(i)
		if money and money > 0 and not (codAmount and codAmount > 0) then
			total = total + money
		end
	end
	return total
end

-- ---------------------------------------------------------------------------
-- Take every attachment on the open mail
-- ---------------------------------------------------------------------------

local function TakeNextAttachment()
	local mailID = _G.InboxFrame and _G.InboxFrame.openMailID
	if not mailID then
		return false
	end
	for i = 1, _G.ATTACHMENTS_MAX_RECEIVE do
		if HasInboxItem(mailID, i) then
			TakeInboxItem(mailID, i)
			return true
		end
	end
	if C_Mail.HasInboxMoney(mailID) then
		TakeInboxMoney(mailID)
		return true
	end
	return false
end

local function OnTakeUpdate(self, elapsed)
	self.wait = (self.wait or 0) - elapsed
	if self.wait > 0 then
		return
	end
	if C_Mail.IsCommandPending() then
		self.wait = STEP_DELAY
		return
	end
	if TakeNextAttachment() then
		self.wait = STEP_DELAY
	else
		self:SetScript("OnUpdate", nil)
		self.wait = nil
	end
end

-- ---------------------------------------------------------------------------
-- Attachment tooltip
-- ---------------------------------------------------------------------------

-- Blizzard shows only the first attachment icon on a row. This lists the rest,
-- stacked by item, so a mail can be judged without opening it.
local function ShowAttachments(self)
	local index = self.index
	if not index then
		return
	end

	local _, _, _, _, money, _, _, itemCount = GetInboxHeaderInfo(index)
	if not itemCount or itemCount < 2 then
		return
	end

	wipe(attachments)
	for slot = 1, _G.ATTACHMENTS_MAX_RECEIVE do
		local _, itemID, _, count = GetInboxItem(index, slot)
		if itemID and count and count > 0 then
			attachments[itemID] = (attachments[itemID] or 0) + count
		end
	end

	local tooltip = _G.GameTooltip
	tooltip:AddLine(" ")
	tooltip:AddLine(L["Attached"])
	for itemID, count in pairs(attachments) do
		local name, _, quality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(itemID)
		if name then
			local r, g, b = C_Item.GetItemQualityColor(quality)
			tooltip:AddDoubleLine(format("|T%s:12:12:0:0:64:64:5:59:5:59|t %s", texture, name), count, r, g, b, r, g, b)
		end
	end
	if money and money > 0 then
		tooltip:AddDoubleLine(L["Gold"], GetCoinTextureString(money), 1, 1, 1, 1, 1, 1)
	end
	tooltip:Show()
end

-- ---------------------------------------------------------------------------
-- Setup
-- ---------------------------------------------------------------------------

local function BuildButtons()
	local inbox = _G.InboxFrame
	local openAll = _G.OpenAllMail
	if not (inbox and openAll) then
		return
	end

	-- Sit beside Blizzard's own button rather than replacing it, since Open All
	-- Mail already handles the full sweep well.
	local gold = CreateFrame("Button", "KKUI_MailCollectGold", inbox, "UIPanelButtonTemplate")
	gold:SetSize(118, 24)
	gold:SetPoint("LEFT", openAll, "RIGHT", 4, 0)
	gold:SetText(L["Collect Gold"])
	K.SkinButton(gold)
	K.SetFont(gold:GetFontString(), 12, "")
	gold:SetScript("OnClick", StartCollecting)
	gold:SetScript("OnEnter", function(self)
		local total = TotalGold()
		_G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		_G.GameTooltip:AddLine(L["Collect Gold"])
		_G.GameTooltip:AddLine(L["Take the money from every mail and leave the items alone."], K.Colors.muted[1], K.Colors.muted[2], K.Colors.muted[3], true)
		if total > 0 then
			_G.GameTooltip:AddLine(" ")
			_G.GameTooltip:AddDoubleLine(L["Waiting"], GetCoinTextureString(total), 1, 1, 1, 1, 1, 1)
		end
		_G.GameTooltip:Show()
	end)
	gold:SetScript("OnLeave", _G.GameTooltip_Hide)
	Module.GoldButton = gold

	local openMail = _G.OpenMailFrame
	if openMail then
		local takeAll = CreateFrame("Button", "KKUI_MailTakeAll", openMail, "UIPanelButtonTemplate")
		takeAll:SetSize(118, 24)
		takeAll:SetPoint("BOTTOMLEFT", openMail, "BOTTOMLEFT", 62, 82)
		takeAll:SetText(L["Take All"])
		K.SkinButton(takeAll)
		K.SetFont(takeAll:GetFontString(), 12, "")
		takeAll:SetScript("OnClick", function(self)
			self.wait = 0
			self:SetScript("OnUpdate", OnTakeUpdate)
		end)
		Module.TakeAllButton = takeAll
	end
end

function Module:MAIL_CLOSED()
	if collecting then
		StopCollecting()
	end
	if Module.TakeAllButton then
		Module.TakeAllButton:SetScript("OnUpdate", nil)
	end
end

function Module:OnEnable()
	if not C.Misc.EnhancedMail then
		return
	end

	goldRunner = CreateFrame("Frame")

	-- The mail frame is load on demand, so wait for it rather than assuming it is
	-- already there.
	if _G.InboxFrame then
		BuildButtons()
	else
		self:RegisterEventOnce("MAIL_SHOW", BuildButtons)
	end

	self:RegisterEvent("MAIL_CLOSED", "MAIL_CLOSED")

	-- Inbox rows are recycled, so hook the shared handler once rather than each
	-- row. InboxFrameItem_OnEnter is what the XML calls and it carries self.index.
	if _G.InboxFrameItem_OnEnter then
		hooksecurefunc("InboxFrameItem_OnEnter", ShowAttachments)
	else
		self:RegisterEventOnce("MAIL_SHOW", function()
			if _G.InboxFrameItem_OnEnter then
				hooksecurefunc("InboxFrameItem_OnEnter", ShowAttachments)
			end
		end)
	end
end
