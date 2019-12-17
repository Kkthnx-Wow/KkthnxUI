local K = unpack(select(2,...))

local _G = _G
local string_gmatch = _G.string.gmatch

local CreateFrame = _G.CreateFrame

local UI_QUESTIONS = {
    "• Q': How do I use Raid as Party?",
    "• A': Disable the Party frames in config.",
    " ",
    "• Q': How do I add/remove Actionbars?",
    "• A': ESC > Interface > ActionBars.",
    " ",
    "• Q': Where are my Minimap buttons?",
    "• A': Click the pink icon BOTTOMLEFT of the minimap.",
    " ",
    "• Q': How do I move spells on my bars?",
    "• A': Hold Shift + Left-Click and drag.",
    " ",
    "• Q': How do I move stuff?",
    "• A': Use the command |cFFFFFF00/moveui|r.",
    " ",
    "• Q': How do I scale the UI?",
    "• A': ESC > KkthnxUI > General > Uncheck AutoScale > Input UIScale.",
    " ",
    "• Q': Why are my Nameplates not skinned in Instances/Raids?",
    "• A': Blame Blizzard for this. Call them and complain 1-800-592-5499",
    " ",
    "• Q': Why are chat bubbles not skinned in Instances/Raids?",
    "• A': Blame Blizzard for this. Call them and complain 1-800-592-5499",
}

local function ModifiedString(string)
    local count = string.find(string, ":")
    local newString = string

    if count then
        local prefix = string.sub(string, 0, count)
        local suffix = string.sub(string, count + 1)
        local subHeader = string.find(string, "•")

        if subHeader then
            newString = tostring("|cFFFFFF00"..prefix.."|r"..suffix)
        else
            newString = tostring("|cff4488ff"..prefix.."|r"..suffix)
        end
    end

    for pattern in string_gmatch(string, "(Q.*')") do
        newString = newString:gsub(pattern, "|cff4488ff"..pattern:gsub("'", "").."|r")
    end

    for pattern in string_gmatch(string, "(A.*')") do
        newString = newString:gsub(pattern, "|cffc0c0c0"..pattern:gsub("'", "").."|r")
    end

    return newString
end

local function GetUIQuestionsInfo(i)
    for line, info in pairs(UI_QUESTIONS) do
        if line == i then
            return info
        end
    end
end

local function CreateUIQuestions()
	if not K.AboutPanel.Questions then return end
    K.AboutPanel.Questions:SetScript("OnShow", function(self)
        if self.show then
            return
		end

		local offset = 10

		local titleText = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        titleText:FontTemplate(nil, 20, "")
        titleText:SetShadowColor(0, 0, 0)
        titleText:SetShadowOffset(1, -1)
		titleText:SetPoint("TOPLEFT", 16, -16)
		titleText:SetText("Frequently Answered Questions")

        for i = 1, #UI_QUESTIONS do
            local button = CreateFrame("Frame", "Button"..i, self)
            button:SetSize(375, 16)
            button:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -offset)

            if i <= #UI_QUESTIONS then
                local string = ModifiedString(GetUIQuestionsInfo(i))

                button.Text = button:CreateFontString(nil, "OVERLAY")
                button.Text:FontTemplate(nil, 12, "")
                button.Text:SetShadowColor(0, 0, 0)
                button.Text:SetShadowOffset(1, -1)
                button.Text:SetPoint("CENTER")
                button.Text:SetPoint("LEFT", 0, 0)
                button.Text:SetText(string)
                button.Text:SetWordWrap(false)
            end
            offset = offset + 16
		end

		self.show = true
    end)
end

CreateUIQuestions()