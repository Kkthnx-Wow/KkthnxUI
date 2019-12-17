local K = unpack(select(2,...))

local _G = _G
local string_gmatch = _G.string.gmatch

local CreateFrame = _G.CreateFrame

local UI_COMMANDS = {
    "• '/align' - Bring up a grid system to align things",
    "• '/cfg' - Bring up KkthnxUI config",
    "• '/checkquest' - Easy way to check if you completed a quest with the questID",
    "• '/clearchat' - Clear your chat windows of any text",
    "• '/clearcombat' - Clear your combatlog window of any text",
    "• '/convert' - Switch from party to raid or raid to party",
    "• '/dbmtest' - Run a dummy test with DeadlyBossMods if enabled",
    "• '/deletequestitems' - Deletes all questitems in your inventory",
    "• '/fixplates' - Could help fix buggy nameplates or just to reset them to default",
    "• '/install' - Brings up the installer again",
    "• '/kb' - Allows for quick keybinding",
    "• '/killquests' - Deletes/Removes all quests in your objective tracker",
    "• '/luaerror' - Enable/Disables Lua errors in your game -> on/off",
    "• '/moveui' - Allows you to move most the UI elements",
    "• '/profile list /profile #' - See current profiles, selecting a profile number",
    "• '/rc' - Quick way to do a ready check",
    "• '/rd' - Disbands your raid group",
    "• '/resetinstance' - Reset your instances",
    "• '/kstatus' - Show a window with info to help with bug reports if needed",
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

    for pattern in string_gmatch(string, "('.*')") do
        newString = newString:gsub(pattern, "|cff4488ff"..pattern:gsub("'", "").."|r")
    end

    return newString
end

local function GetUICommandsInfo(i)
    for line, info in pairs(UI_COMMANDS) do
        if line == i then
            return info
        end
    end
end

local function CreateUICommands()
	if not K.AboutPanel.Commands then return end
    K.AboutPanel.Commands:SetScript("OnShow", function(self)
        if self.show then
            return
		end

        local offset = 10

		local titleText = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
        titleText:FontTemplate(nil, 20, "")
        titleText:SetShadowColor(0, 0, 0)
        titleText:SetShadowOffset(1, -1)
		titleText:SetPoint("TOPLEFT", 16, -16)
		titleText:SetText("Commands")

        for i = 1, #UI_COMMANDS do
            local button = CreateFrame("Frame", "Button"..i, self)
            button:SetSize(375, 16)
            button:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -offset)

            if i <= #UI_COMMANDS then
                local string = ModifiedString(GetUICommandsInfo(i))

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

CreateUICommands()