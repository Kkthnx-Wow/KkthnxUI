local K, C, L = unpack(select(2, ...))

local FONT_TITLE = { C.Media.Font, 15, C.Media.Font_Style }
local FONT_HEADLINE = { C.Media.Font, 14, C.Media.Font_Style }
local FONT_TEXT = { C.Media.Font, 12, C.Media.Font_Style }

local classcolor = ("|cff%.2x%.2x%.2x"):format(K.Color.r * 255, K.Color.g * 255, K.Color.b * 255)

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
FAQFrameTitle.Text:SetFont(C.Media.Font, 15, C.Media.Font_Style)
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

local FAQButtonsAttributes = {
	[1] = { "/faq 1" },
	[2] = { "/faq 2" },
	[3] = { "/faq 3" },
	[4] = { "/faq 4" },
	[5] = { "/faq 5" },
	[6] = { "/faq 6" },
	[7] = { "/faq 7" },
	[8] = { "/faq 8" },
	[9] = { "/faq 9" },
	[10] = { "/faq 10" },
	[11] = { "/faq 11" },
}

local FAQButtonsTexts = {
	[1] = {L_FAQ_BUTTON_01},
	[2] = {L_FAQ_BUTTON_02},
	[3] = {L_FAQ_BUTTON_03},
	[4] = {L_FAQ_BUTTON_04},
	[5] = {L_FAQ_BUTTON_05},
	[6] = {L_FAQ_BUTTON_06},
	[7] = {L_FAQ_BUTTON_07},
	[8] = {L_FAQ_BUTTON_08},
	[9] = {L_FAQ_BUTTON_09},
	[10] = {L_FAQ_BUTTON_10},
	[11] = {L_FAQ_BUTTON_11},
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
	FAQMainFrameNavigationButton[i]:SetAttribute("type", "macro")
	FAQMainFrameNavigationButton[i]:SetAttribute("macrotext", unpack(FAQButtonsAttributes[i]))
end

local FAQMainFrameCloseButton = CreateFrame("Button", nil, FAQFrameTitle, "UIPanelCloseButton")
FAQMainFrameCloseButton:SetPoint("RIGHT", FAQFrameTitle, "RIGHT")
FAQMainFrameCloseButton:SetScript("OnClick", function() FAQFrame:Hide() end)

local FAQMainFrameContentTitle = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentTitle:SetFont(unpack(FONT_TITLE))
FAQMainFrameContentTitle:SetPoint("TOP", FAQFrameContentScrollFrameBackground, "TOP", 0, -10)

local FAQMainFrameContentText1 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText1:SetJustifyH("LEFT")
FAQMainFrameContentText1:SetFont(unpack(FONT_TEXT))
FAQMainFrameContentText1:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 20)
FAQMainFrameContentText1:SetPoint("TOPLEFT", FAQFrameContentScrollFrameBackground, "TOPLEFT", 10, -45)

local FAQMainFrameContentText2 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText2:SetJustifyH("LEFT")
FAQMainFrameContentText2:SetFont(unpack(FONT_TEXT))
FAQMainFrameContentText2:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText2:SetPoint("TOPLEFT", FAQMainFrameContentText1, "BOTTOMLEFT", 0, -20)

local FAQMainFrameContentText3 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText3:SetJustifyH("LEFT")
FAQMainFrameContentText3:SetFont(unpack(FONT_TEXT))
FAQMainFrameContentText3:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText3:SetPoint("TOPLEFT", FAQMainFrameContentText2, "BOTTOMLEFT", 0, -20)

local FAQMainFrameContentText4 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText4:SetJustifyH("LEFT")
FAQMainFrameContentText4:SetFont(unpack(FONT_TEXT))
FAQMainFrameContentText4:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText4:SetPoint("TOPLEFT", FAQMainFrameContentText3, "BOTTOMLEFT", 0, -20)

local FAQMainFrameContentText5 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText5:SetJustifyH("LEFT")
FAQMainFrameContentText5:SetFont(unpack(FONT_TEXT))
FAQMainFrameContentText5:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText5:SetPoint("TOPLEFT", FAQMainFrameContentText4, "BOTTOMLEFT", 0, -20)

local FAQMainFrameContentText6 = FAQFrameContentScrollFrameBackground:CreateFontString(nil, "OVERLAY")
FAQMainFrameContentText6:SetJustifyH("LEFT")
FAQMainFrameContentText6:SetFont(unpack(FONT_TEXT))
FAQMainFrameContentText6:SetWidth(FAQFrameContentScrollFrameBackground:GetWidth() - 30)
FAQMainFrameContentText6:SetPoint("TOPLEFT", FAQMainFrameContentText5, "BOTTOMLEFT", 0, -20)

local function FAQMainFrameBuildDefault()
	FAQMainFrameContentTitle:SetText(L_FAQ_GENERALTITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_GENERALTEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_GENERALTEXT2)
end

local function FAQMainFrameContent1()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT1TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT1TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT1TEXT2)
end

local function FAQMainFrameContent2()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT2TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT2TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT2TEXT2)
end

local function FAQMainFrameContent3()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT3TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT3TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT3TEXT2)
end

local function FAQMainFrameContent4()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT4TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT4TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT4TEXT2)
end

local function FAQMainFrameContent5()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT5TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT5TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT5TEXT2)
end

local function FAQMainFrameContent6()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT6TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT6TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT6TEXT2)
end

local function FAQMainFrameContent7()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT7TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT7TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT7TEXT2)
end

local function FAQMainFrameContent8()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT8TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT8TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT8TEXT2)
end

local function FAQMainFrameContent9()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT9TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT9TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT9TEXT2)
end

local function FAQMainFrameContent10()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT10TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT10TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT10TEXT2)
end

local function FAQMainFrameContent11()
	FAQMainFrameContentTitle:SetText(L_FAQ_CONTENT11TITLE)
	FAQMainFrameContentText1:SetText(L_FAQ_CONTENT11TEXT1)
	FAQMainFrameContentText2:SetText(L_FAQ_CONTENT11TEXT2)
end

local dfaq = FAQMainFrameSlashcommand or function() end
FAQMainFrameSlashcommand = function(msg)
	if(InCombatLockdown()) then print(ERR_NOT_IN_COMBAT) return end

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
