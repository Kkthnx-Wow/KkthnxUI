local K, C, L = select(2, ...):unpack()

local FontTitle = {C.Media.Font, 15, C.Media.Font_Style}
local FontHeadline = {C.Media.Font, 14, C.Media.Font_Style}
local FontText = {C.Media.Font, 12, C.Media.Font_Style}

local ClassColor = ("|cff%.2x%.2x%.2x"):format(K.Color.r * 255, K.Color.g * 255, K.Color.b * 255)

-- Main Frame
local FAQFrame = CreateFrame("Frame", nil, UIParent)
FAQFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
FAQFrame:SetSize(650, 350)
FAQFrame:SetTemplate()
FAQFrame:SetFrameLevel(10)
FAQFrame:SetFrameStrata("BACKGROUND")
FAQFrame:Hide()
FAQFrame:EnableMouse(true)
FAQFrame:SetMovable(true)
FAQFrame:SetClampedToScreen(true)
FAQFrame:SetScript("OnMouseDown", function() FAQFrame:ClearAllPoints() FAQFrame:StartMoving() end)
FAQFrame:SetScript("OnMouseUp", function() FAQFrame:StopMovingOrSizing() end)

local FAQFrameTitle = CreateFrame("Frame", nil, FAQFrame)
FAQFrameTitle:SetPoint("BOTTOM", FAQFrame, "TOP", 0, 0)
FAQFrameTitle:SetSize(FAQFrame:GetWidth(), 28)
FAQFrameTitle:SetTemplate()

FAQFrameTitle.Text = FAQFrameTitle:CreateFontString(nil, "OVERLAY")
FAQFrameTitle.Text:SetPoint("CENTER", FAQFrameTitle, "CENTER", 0, 0)
FAQFrameTitle.Text:SetFont(unpack(FontTitle))
FAQFrameTitle.Text:SetText("|cff3c9bedKkthnxUI " .. GetAddOnMetadata("KkthnxUI", "Version") .. " - Frequently Asked Question(s).|r")

local FAQFrameNavigation = CreateFrame("Frame", nil, FAQFrame)
FAQFrameNavigation:SetPoint("LEFT", 4, 0)
FAQFrameNavigation:SetSize(180, 342)
FAQFrameNavigation:SetTemplate()

local FAQFrameContent = CreateFrame("Frame", nil, FAQFrame)
FAQFrameContent:SetPoint("RIGHT", -4, 0)
FAQFrameContent:SetSize(458, 342)
FAQFrameContent:SetTemplate()

local FAQFrameContentScrollFrame = CreateFrame("ScrollFrame", "FAQFrameContentScrollFrame", FAQFrameContent, "UIPanelScrollFrameTemplate")
FAQFrameContentScrollFrame:SetPoint("TOPLEFT", FAQFrameContent, "TOPLEFT", 4, -4)
FAQFrameContentScrollFrame:SetPoint("BOTTOMRIGHT", FAQFrameContent, "BOTTOMRIGHT", -27, 4)

local FAQFrameContentScrollFrameBackground = CreateFrame("Frame", "FAQMainFrameContentScrollFrameBackground", FAQFrameContentScrollFrame)
FAQFrameContentScrollFrameBackground:SetPoint("TOPLEFT")
FAQFrameContentScrollFrameBackground:SetWidth(FAQFrameContentScrollFrame:GetWidth())
FAQFrameContentScrollFrameBackground:SetHeight(FAQFrameContentScrollFrame:GetHeight())
FAQFrameContentScrollFrame:SetScrollChild(FAQFrameContentScrollFrameBackground)

local FAQButtonsTexts = {
	[1] = {L.FAQ.Button01},
	[2] = {L.FAQ.Button02},
	[3] = {L.FAQ.Button03},
	[4] = {L.FAQ.Button04},
	[5] = {L.FAQ.Button05},
	[6] = {L.FAQ.Button06},
	[7] = {L.FAQ.Button07},
	[8] = {L.FAQ.Button08},
	[9] = {L.FAQ.Button09},
	[10] = {L.FAQ.Button10},
	[11] = {L.FAQ.Button11},
}

local FAQMainFrameNavigationButton = CreateFrame("Button", nil, FAQFrameNavigation)
for i = 1, 11 do
	FAQMainFrameNavigationButton[i] = CreateFrame("Button", "KkthnxUIFAQMainFrameNavigationButton" .. i, FAQFrameNavigation, "SecureActionButtonTemplate")
	FAQMainFrameNavigationButton[i]:SetSize(160, 20)
	FAQMainFrameNavigationButton[i]:SkinButton()

	FAQMainFrameNavigationButton[i].Text = K.SetFontString(FAQMainFrameNavigationButton[i], C.Media.Font, 11)
	FAQMainFrameNavigationButton[i]:SetFrameLevel(FAQFrameNavigation:GetFrameLevel() +1)
	FAQMainFrameNavigationButton[i].Text:SetPoint("CENTER", FAQMainFrameNavigationButton[i], "CENTER", 0, 0)
	FAQMainFrameNavigationButton[i].Text:SetText(unpack(FAQButtonsTexts[i]))

	if(i == 1) then
		FAQMainFrameNavigationButton[i]:SetPoint("TOP", FAQFrameNavigation, "TOP", 0, -8)
	else
		FAQMainFrameNavigationButton[i]:SetPoint("TOP", FAQMainFrameNavigationButton[i -1], "BOTTOM", 0, -6)
	end
end

local FAQMainFrameCloseButton = CreateFrame("Button", nil, FAQFrameTitle, "UIPanelCloseButton")
FAQMainFrameCloseButton:SetPoint("RIGHT", FAQFrameTitle, "RIGHT")
FAQMainFrameCloseButton:SetScript("OnClick", function() FAQFrame:Hide() end)

local FAQMainFrameContentTitle = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentTitle:SetFont(unpack(FontTitle))
FAQMainFrameContentTitle:SetPoint("TOP", FAQFrameContentScrollFrameBackground, "TOP", 0, -10)

local FAQMainFrameContentText1 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText1:SetJustifyH("LEFT")
FAQMainFrameContentText1:SetFont(unpack(FontText))
FAQMainFrameContentText1:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 20)
FAQMainFrameContentText1:SetPoint("TOPLEFT", FAQFrameContentScrollFrameBackground, "TOPLEFT", 10, -45)

local FAQMainFrameContentText2 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText2:SetJustifyH("LEFT")
FAQMainFrameContentText2:SetFont(unpack(FontText))
FAQMainFrameContentText2:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText2:SetPoint("TOPLEFT", FAQMainFrameContentText1, "BOTTOMLEFT", 0, -20)

local FAQMainFrameContentText3 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText3:SetJustifyH("LEFT")
FAQMainFrameContentText3:SetFont(unpack(FontText))
FAQMainFrameContentText3:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText3:SetPoint("TOPLEFT", FAQMainFrameContentText2, "BOTTOMLEFT", 0, -20)

local FAQMainFrameContentText4 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText4:SetJustifyH("LEFT")
FAQMainFrameContentText4:SetFont(unpack(FontText))
FAQMainFrameContentText4:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText4:SetPoint("TOPLEFT", FAQMainFrameContentText3, "BOTTOMLEFT", 0, -20)

local FAQMainFrameContentText5 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText5:SetJustifyH("LEFT")
FAQMainFrameContentText5:SetFont(unpack(FontText))
FAQMainFrameContentText5:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText5:SetPoint("TOPLEFT", FAQMainFrameContentText4, "BOTTOMLEFT", 0, -20)

local FAQMainFrameContentText6 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText6:SetJustifyH("LEFT")
FAQMainFrameContentText6:SetFont(unpack(FontText))
FAQMainFrameContentText6:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText6:SetPoint("TOPLEFT", FAQMainFrameContentText5, "BOTTOMLEFT", 0, -20)

local function FAQMainFrameBuildDefault()
	FAQMainFrameContentTitle:SetText(L.FAQ.GeneralTitle)
	FAQMainFrameContentText1:SetText(L.FAQ.GeneralText1)
	FAQMainFrameContentText2:SetText(L.FAQ.GeneralText2)
end

local function FAQMainFrameContent1()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content1Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content1Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content1Text2)
end

local function FAQMainFrameContent2()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content2Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content2Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content2Text2)
end

local function FAQMainFrameContent3()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content3Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content3Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content3Text2)
end

local function FAQMainFrameContent4()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content4Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content4Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content4Text2)
end

local function FAQMainFrameContent5()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content5Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content5Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content5Text2)
end

local function FAQMainFrameContent6()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content6Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content6Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content6Text2)
end

local function FAQMainFrameContent7()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content7Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content7Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content7Text2)
end

local function FAQMainFrameContent8()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content8Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content8Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content8Text2)
end

local function FAQMainFrameContent9()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content9Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content9Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content9Text2)
end

local function FAQMainFrameContent10()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content10Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content10Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content10Text2)
end

local function FAQMainFrameContent11()
	FAQMainFrameContentTitle:SetText(L.FAQ.Content11Title)
	FAQMainFrameContentText1:SetText(L.FAQ.Content11Text1)
	FAQMainFrameContentText2:SetText(L.FAQ.Content11Text2)
end

local dfaq = FAQMainFrameSlashcommand or function() end
FAQMainFrameSlashcommand = function(msg)
	if(InCombatLockdown()) then K.Print(ERR_NOT_IN_COMBAT) return end

	if(msg == "1") then
		FAQMainFrameContent1()
	elseif(msg == "2") then
		FAQMainFrameContent2()
	elseif(msg == "3") then
		FAQMainFrameContent3()
	elseif(msg == "4") then
		FAQMainFrameContent4()
	elseif(msg == "5") then
		FAQMainFrameContent5()
	elseif(msg == "6") then
		FAQMainFrameContent6()
	elseif(msg == "7") then
		FAQMainFrameContent7()
	elseif(msg == "8") then
		FAQMainFrameContent8()
	elseif(msg == "9") then
		FAQMainFrameContent9()
	elseif(msg == "10") then
		FAQMainFrameContent10()
	elseif(msg == "11") then
		FAQMainFrameContent11()
	else
		if(FAQFrame:IsVisible()) then
			FAQFrame:Hide()
		else
			FAQFrame:Show()
			FAQMainFrameBuildDefault()
		end
	end
end

SlashCmdList.FAQMainFrameSlashcommand = FAQMainFrameSlashcommand
SLASH_FAQMainFrameSlashcommand1 = "/faq"