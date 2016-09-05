local K, C, L, _ = select(2, ...):unpack()

local ACCEPT, CANCEL = ACCEPT, CANCEL
local ChatFontNormal = ChatFontNormal

K.CreatePopup = {}
local Frame = {}
local Total = 4

local function Hide(self)
	local Popup = self:GetParent()
	Popup:Hide()
end

for i = 1, Total do
	Frame[i] = CreateFrame("Frame", "KkthnxUIPopupDialog" .. i, UIParent)
	Frame[i]:SetSize(300, 120)
	Frame[i]:SetFrameLevel(3)
	Frame[i]:SetTemplate("Transparent")
	Frame[i]:SetPoint("TOP", UIParent, "TOP", 0, -150)
	Frame[i]:Hide()

	Frame[i].Text = CreateFrame("MessageFrame", nil, Frame[i])
	Frame[i].Text:SetPoint("CENTER", 0, 10)
	Frame[i].Text:SetSize(230, 60)
	Frame[i].Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	Frame[i].Text:SetInsertMode("TOP")
	Frame[i].Text:SetFading(false)
	Frame[i].Text:AddMessage("")

	Frame[i].Button1 = CreateFrame("Button", "KkthnxUIPopupDialogButtonAccept" .. i, Frame[i])
	Frame[i].Button1:SetPoint("BOTTOMLEFT", Frame[i], "BOTTOMLEFT", 6, 7)
	Frame[i].Button1:SetSize(100, 26)
	Frame[i].Button1:SetTemplate("Default")
	Frame[i].Button1:FontString("Text", C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	Frame[i].Button1.Text:SetPoint("CENTER")
	Frame[i].Button1.Text:SetText(ACCEPT)
	Frame[i].Button1:SetScript("OnClick", Hide)
	Frame[i].Button1:HookScript("OnClick", Hide)
	Frame[i].Button1:SkinButton()

	Frame[i].Button2 = CreateFrame("Button", "KkthnxUIPopupDialogButtonCancel" .. i, Frame[i])
	Frame[i].Button2:SetPoint("BOTTOMRIGHT", Frame[i], "BOTTOMRIGHT", -6, 7)
	Frame[i].Button2:SetSize(100, 26)
	Frame[i].Button2:SetTemplate("Default")
	Frame[i].Button2:FontString("Text", C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	Frame[i].Button2.Text:SetPoint("CENTER")
	Frame[i].Button2.Text:SetText(CANCEL)
	Frame[i].Button2:SetScript("OnClick", Hide)
	Frame[i].Button2:HookScript("OnClick", Hide)
	Frame[i].Button2:SkinButton()

	Frame[i].EditBox = CreateFrame("EditBox", "KkthnxUIPopupDialogEditBox" .. i, Frame[i])
	Frame[i].EditBox:SetMultiLine(false)
	Frame[i].EditBox:EnableMouse(true)
	Frame[i].EditBox:SetAutoFocus(true)
	Frame[i].EditBox:SetFontObject(ChatFontNormal)
	Frame[i].EditBox:SetWidth(230)
	Frame[i].EditBox:SetHeight(16)
	Frame[i].EditBox:SetPoint("BOTTOM", Frame[i], 0, 35)
	Frame[i].EditBox:SetScript("OnEscapePressed", function() Frame[i]:Hide() end)
	Frame[i].EditBox:CreateBackdrop()
	Frame[i].EditBox.backdrop:SetPoint("TOPLEFT", -4, 4)
	Frame[i].EditBox.backdrop:SetPoint("BOTTOMRIGHT", 4, -4)
	Frame[i].EditBox:Hide()
end

K.ShowPopup = function(self)
	local Info = K.CreatePopup[self]
	if not Info then return end

	local Selection = _G["KkthnxUIPopupDialog1"]
	for i = 1, Total - 1 do
		if Frame[i]:IsShown() then Selection = _G["KkthnxUIPopupDialog" .. i + 1] end
	end

	local Popup = Selection
	local Question = Popup.Text
	local Button1 = Popup.Button1
	local Button2 = Popup.Button2
	local EditBox = Popup.EditBox

	Question:Clear()

	EditBox:SetText("")

	if Info.Question then Question:AddMessage(Info.Question) end

	if Info.Answer1 then Button1.Text:SetText(Info.Answer1) else Button1.Text:SetText(ACCEPT) end

	if Info.Answer2 then Button2.Text:SetText(Info.Answer2) else Button2.Text:SetText(CANCEL) end

	if Info.Function1 then Button1:SetScript("OnClick", Info.Function1) else Button1:SetScript("OnClick", Hide) end

	if Info.Function2 then Button2:SetScript("OnClick", Info.Function2) else Button2:SetScript("OnClick", Hide) end

	if Info.EditBox then EditBox:Show() else EditBox:Hide() end

	Button1:HookScript("OnClick", Hide)
	Button2:HookScript("OnClick", Hide)

	Popup:Show()
end