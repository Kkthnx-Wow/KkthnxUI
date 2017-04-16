local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local string_find = string.find
local string_format = string.format
local string_gsub = string.gsub
local table_insert = table.insert

-- Wow API
local CreateFrame, UIParent = _G.CreateFrame, _G.UIParent
local GetSpellInfo = _G.GetSpellInfo
local ToggleFrame = _G.ToggleFrame

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CopyScroll, C_Timer, RandomRoll, UISpecialFrames, ChatFontNormal, ChatMenu, GameTooltip

-- COPY CHAT
local lines = {}
local frame = nil
local editBox = nil
local font = nil
local isf = nil
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
	frame:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3])
	frame:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
	frame:SetSize(540, 300)
	frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
	frame:SetFrameStrata("DIALOG")
	table_insert(UISpecialFrames, "CopyFrame")
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
			if string_find(text, size) and not string_find(text, size.."]") then
				self:SetText(string_gsub(text, size, ":12:12"))
			end
		end
	end)

	local close = CreateFrame("Button", "CopyCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

	font = frame:CreateFontString(nil, nil, "GameFontNormal")
	font:Hide()

	isf = true
end

local scrollDown = function()
	CopyScroll:SetVerticalScroll((CopyScroll:GetVerticalScrollRange()) or 0)
end

local function Copy(cf)
	if not isf then CreatCopyFrame() end
	local text = ""
	for i = 1, cf:GetNumMessages() do
		local line = cf:GetMessageInfo(i)
		font:SetFormattedText("%s\n", line)
		local cleanLine = font:GetText() or ""
		text = text..cleanLine
	end
	text = text:gsub("|T[^\\]+\\[^\\]+\\[Uu][Ii]%-[Rr][Aa][Ii][Dd][Tt][Aa][Rr][Gg][Ee][Tt][Ii][Nn][Gg][Ii][Cc][Oo][Nn]_(%d)[^|]+|t", "{rt%1}")
	text = text:gsub("|T13700([1-8])[^|]+|t", "{rt%1}")
	text = text:gsub("|T[^|]+|t", "")
	if frame:IsShown() then frame:Hide() return end
	frame:Show()
	editBox:SetText(text)
	C_Timer.After(0.25, scrollDown)
end

for i = 1, NUM_CHAT_WINDOWS do
	local cf = _G[string_format("ChatFrame%d", i)]
	local button = CreateFrame("Button", string_format("ButtonCF%d", i), cf)
	button:SetPoint("BOTTOMRIGHT", 10, 2)
	button:SetSize(20, 20)
	button:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Copy")
	button:SetAlpha(0)
	K.CreateBorder(button)
	button:SetBackdrop(K.BorderBackdrop)
	button:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3], C.Media.Border_Color[4])
	button:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

	button:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			ToggleFrame(ChatMenu)
		elseif btn == "MiddleButton" then
			RandomRoll(1, 100)
		else
			Copy(cf)
		end
	end)
	button:SetScript("OnEnter", function()
		button:FadeIn()
		GameTooltip:SetOwner(button, "ANCHOR_NONE")
		GameTooltip:SetPoint(K.GetAnchors(button))
		GameTooltip:ClearLines()
		GameTooltip:AddLine("Copy Chat")
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Copy text from the chat frame.", 0.2, 1, 0.2, 1)
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		button:FadeOut()
		GameTooltip:Hide()
	end)

	SlashCmdList.COPY_CHAT = function()
		Copy(_G["ChatFrame1"])
	end
end