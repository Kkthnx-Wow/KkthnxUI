local K = unpack(select(2, ...))
local Module = K:NewModule("ChatLinkHover", "AceHook-3.0")

local string_match = string.match

local linkTypes = {
	item = true,
	enchant = true,
	spell = true,
	quest = true,
	-- player = true
}

Module.TempChatFrames = {}

function Module:Decorate(frame)
	self:HookScript(frame, "OnHyperlinkEnter", OnHyperlinkEnter)
	self:HookScript(frame, "OnHyperlinkLeave", OnHyperlinkLeave)
end

function Module:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		self:HookScript(frame, "OnHyperlinkEnter", OnHyperlinkEnter)
		self:HookScript(frame, "OnHyperlinkLeave", OnHyperlinkLeave)
	end

	for _, name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			self:HookScript(cf, "OnHyperlinkEnter", OnHyperlinkEnter)
			self:HookScript(cf, "OnHyperlinkLeave", OnHyperlinkLeave)
		end
	end
end

function Module:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		self:Unhook(frame, "OnHyperlinkEnter")
		self:Unhook(frame, "OnHyperlinkLeave")
	end

	for _, name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			self:Unhook(cf, "OnHyperlinkEnter")
			self:Unhook(cf, "OnHyperlinkLeave")
		end
	end
end

local showingTooltip = false
function Module:OnHyperlinkEnter(_, link)
	local t = string_match(link, "^(.-):")
	if linkTypes[t] then
		showingTooltip = true
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end
end

function Module:OnHyperlinkLeave()
	if showingTooltip then
		showingTooltip = false
		HideUIPanel(GameTooltip)
	end
end