local K = unpack(select(2,...))

local _G = _G
local string_gmatch = _G.string.gmatch

local CreateFrame = _G.CreateFrame

local UI_QUESTIONS = {
    "• Q' How do I use Raid as Party?",
    "• A' Disable the Party frames in config.",
    " ",
    "• Q' How do I add/remove Actionbars?",
    "• A' ESC > Interface > ActionBars.",
    " ",
    "• Q' Where are my Minimap buttons?",
    "• A' Click the blue icon bottomleft of the minimap.",
    " ",
    "• Q' How do I move spells on my bars?",
    "• A' Hold Shift + Left-Click and drag.",
    " ",
    "• Q' Why are my Nameplates different in Instances/Raids?",
    "• A' Blame Blizzard for this. Call Them and complain 1-800-592-5499",
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

		local offset = 36

		local titleText = self:CreateFontString(nil, "OVERLAY")
		titleText:FontTemplate(nil, 20, "")
		titleText:SetPoint("CENTER", self, "TOP", 0, -16)
		titleText:SetText(K.Title.." Frequently Answered Questions")

		local headerBar = self:CreateTexture(nil, "ARTWORK")
		headerBar:SetTexture("Interface\\LFGFrame\\UI-LFG-SEPARATOR")
		headerBar:SetTexCoord(0, 0.6640625, 0, 0.3125)
		headerBar:SetVertexColor(1, 1, 1)
		headerBar:SetPoint("CENTER", titleText)
		headerBar:SetSize(titleText:GetWidth() + 4, 30)

        for i = 1, #UI_QUESTIONS do
            local button = CreateFrame("Frame", "Button"..i, self)
            button:SetSize(375, 16)
            button:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -offset)

            if i <= #UI_QUESTIONS then
                local string = ModifiedString(GetUIQuestionsInfo(i))

                button.Text = button:CreateFontString(nil, "OVERLAY")
                button.Text:FontTemplate(nil, 12, "")
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