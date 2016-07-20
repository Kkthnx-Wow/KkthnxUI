local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local format = string.format
local gsub = string.gsub
local pairs = pairs
local unpack = unpack
local find = string.find
local select = select
local tinsert = tinsert
local CreateFrame, UIParent = CreateFrame, UIParent
local ToggleFrame = ToggleFrame
local GetSpellInfo = GetSpellInfo

-- Copy Chat
local lines = {}
local frame = nil
local editBox = nil
local isf = nil
local tex = select(3, GetSpellInfo(6310))
local sizes = {
	":14:14",
	":15:15",
	":16:16",
	":12:20",
	":14"
}

local function CreatCopyFrame()
	frame = CreateFrame("Frame", "CopyFrame", UIParent)
	frame:SetBackdrop(K.Backdrop)
	frame:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	frame:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	frame:SetSize(540, 300)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
	frame:SetFrameStrata("DIALOG")
	tinsert(UISpecialFrames, "CopyFrame")
	frame:Hide()

	local scrollArea = CreateFrame("ScrollFrame", "CopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

	editBox = CreateFrame("EditBox", "CopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetSize(500, 300)
	editBox:SetScript("OnEscapePressed", function() frame:Hide() end)

	scrollArea:SetScrollChild(editBox)

	editBox:SetScript("OnTextSet", function(self)
		local text = self:GetText()

		for _, size in pairs(sizes) do
			if find(text, size) and not find(text, size.."]") then
				self:SetText(gsub(text, size, ":12:12"))
			end
		end
	end)

	local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

	isf = true
end

local scrollDown = function()
	CopyScroll:SetVerticalScroll((CopyScroll:GetVerticalScrollRange()) or 0)
end

local function Copy(cf)
	local text = ""
	for i = 1, cf:GetNumMessages() do
		text = text..cf:GetMessageInfo(i).."\n"
	end
	text = text:gsub("|[Tt]Interface\\TargetingFrame\\UI%-RaidTargetingIcon_(%d):0|[Tt]", "{rt%1}")
	text = text:gsub("|[Tt][^|]+|[Tt]", "")
	if not isf then CreatCopyFrame() end
	if frame:IsShown() then frame:Hide() return end
	frame:Show()
	editBox:SetText(text)
	K.Delay(0.25, scrollDown)
end

for i = 1, NUM_CHAT_WINDOWS do
	local cf = _G[format("ChatFrame%d", i)]
	local button = CreateFrame("Button", format("ButtonCF%d", i), cf)
	button:SetPoint("BOTTOMRIGHT", 0, -4)
	button:SetSize(16, 16)
	button:SetNormalTexture("Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up")
	button:SetAlpha(0)

	button:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			ToggleFrame(ChatMenu)
		elseif btn == "MiddleButton" then
			RandomRoll(1, 100)
		else
			Copy(cf)
		end
	end)
	button:HookScript("OnEnter", function()
		K:UIFrameFadeIn(button, 0.4, button:GetAlpha(), 1)
	end)
	button:HookScript("OnLeave", function()
		K:UIFrameFadeOut(button, 1, button:GetAlpha(), 0)
	end)

	SlashCmdList.COPY_CHAT = function()
		Copy(_G["ChatFrame1"])
	end
end