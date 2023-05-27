local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local TOTAL = TOTAL
local DEATHS = DEATHS

local currentLevel
local playerDeaths = 0
local levelDeaths = {}
local milestoneDeaths = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000 }

local function CreateDeathCounterDB()
	-- Create or initialize the death counter database for the current character
	local deathCounter = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter
	deathCounter.Level = deathCounter.Level or {}
	deathCounter.Player = deathCounter.Player or 0
end

local function UpdateDeathCounts()
	-- Update the local death counts and milestone deaths with the values from the database
	local deathCounter = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter
	playerDeaths = deathCounter.Player or 0
	levelDeaths = deathCounter.Level or {}
end

local function SaveDeathCounts()
	-- Save the death counts and milestone deaths to the database
	local deathCounter = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter
	deathCounter.Player = playerDeaths
	deathCounter.Level = levelDeaths
end

local function CheckMilestoneDeaths()
	for _, milestone in ipairs(milestoneDeaths) do
		if playerDeaths == milestone then
			print("Congrats! You have reached a milestone of " .. milestone .. " deaths. You can thank Kkthnx for letting you know this very lame and useless statistic.")
		end
	end
end

local function OnPlayerDead()
	-- Increment the player's total death count and level-specific death count
	playerDeaths = playerDeaths + 1
	levelDeaths[currentLevel] = (levelDeaths[currentLevel] or 0) + 1

	-- Save the death counts to the database
	SaveDeathCounts()

	-- Print the updated death counts
	print(TOTAL .. " " .. DEATHS .. ": " .. playerDeaths)
	print(LEVEL .. " " .. DEATHS .. ": " .. levelDeaths[currentLevel])

	-- Check for milestone deaths
	CheckMilestoneDeaths()
end

local function OnLevelChange()
	-- Update the current level and reset the level-specific death count when the player levels up
	local newLevel = K.Level
	if newLevel > currentLevel then
		levelDeaths[newLevel] = 0
		currentLevel = newLevel

		-- Save the death counts to the database
		SaveDeathCounts()

		-- You can update the UI here to reflect the level change and reset the level death count
	end
end

local function CreateDeathCounterPanel()
	-- Create and configure the death counter panel frame
	local panel = CreateFrame("Frame", "DeathCounterPanel", UIParent)
	panel:SetSize(280, 260)
	panel:SetPoint("CENTER")
	panel:CreateBorder()
	panel:Hide()

	panel.title = CreateFrame("Frame", "DeathCounterPanelTitle", panel)
	panel.title:SetSize(280, 22)
	panel.title:SetPoint("BOTTOM", panel, "TOP", 0, 6)
	panel.title:CreateBorder()

	panel.title.text = panel.title:CreateFontString(nil, "OVERLAY", "GameFontNormalMed1")
	panel.title.text:SetPoint("CENTER", panel.title)
	panel.title.text:SetText("Death Counter")

	-- Create the scroll frame for the panel
	panel.scrollFrame = CreateFrame("ScrollFrame", "DeathCounterPanelScrollFrame", panel, "UIPanelScrollFrameTemplate")
	panel.scrollFrame:SetPoint("TOPLEFT", 6, -6)
	panel.scrollFrame:SetPoint("BOTTOMRIGHT", -28, 6)
	panel.scrollFrame:SetWidth(260)
	panel.scrollFrame.ScrollBar:SkinScrollBar()

	-- Create the scroll child frame
	panel.scrollChild = CreateFrame("Frame", nil, panel.scrollFrame)
	panel.scrollChild:SetSize(260, 200)

	-- Create the font strings for displaying death counts
	panel.totalDeaths = panel.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	panel.totalDeaths:SetPoint("TOPLEFT", 6, -6)
	panel.totalDeaths:SetText(TOTAL .. " " .. DEATHS .. ": " .. playerDeaths)

	panel.levelDeaths = panel.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	panel.levelDeaths:SetPoint("TOPLEFT", panel.totalDeaths, "BOTTOMLEFT", 0, -15)
	panel.levelDeaths:SetText(LEVEL .. " " .. DEATHS .. ":")

	-- Set the scroll child as the content of the scroll frame
	panel.scrollFrame:SetScrollChild(panel.scrollChild)

	-- Create the reset button for the panel
	panel.resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	panel.resetButton:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, -6)
	panel.resetButton:SetSize(136, 22)
	panel.resetButton:SetText(RESET)
	panel.resetButton:SkinButton()
	panel.resetButton:SetScript("OnClick", function()
		-- Reset the death counts and save to the database
		playerDeaths = 0
		levelDeaths = {}
		SaveDeathCounts()

		-- Update the death count information in the panel
		panel.totalDeaths:SetText(TOTAL .. " " .. DEATHS .. ": " .. playerDeaths)
		panel.levelDeaths:SetText(LEVEL .. " " .. DEATHS .. ":")
	end)

	-- Create the close button for the panel
	panel.closeButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	panel.closeButton:SetPoint("TOPRIGHT", panel, "BOTTOMRIGHT", 0, -6)
	panel.closeButton:SetSize(136, 22)
	panel.closeButton:SetText(CLOSE)
	panel.closeButton:SkinButton()
	panel.closeButton:SetScript("OnClick", function()
		panel:Hide()
	end)

	panel:SetScript("OnShow", function()
		-- Update the death count information when the panel is shown
		panel.totalDeaths:SetText(TOTAL .. " " .. DEATHS .. ": " .. playerDeaths)
		local levelDeathsText = LEVEL .. " " .. DEATHS .. ":\n"
		if next(levelDeaths) == nil then
			levelDeathsText = levelDeathsText .. NONE
		else
			for level, deaths in pairs(levelDeaths) do
				levelDeathsText = levelDeathsText .. "- " .. LEVEL .. " " .. level .. ": " .. deaths .. "\n"
			end
		end
		panel.levelDeaths:SetText(levelDeathsText)
	end)

	return panel
end

function Module:CreateDeathCounter()
	-- Check if the DeathCounter module is enabled in the configuration
	if C["Misc"].DeathCounter then
		-- Register necessary events when DeathCounter is enabled
		K:RegisterEvent("PLAYER_DEAD", OnPlayerDead)
		K:RegisterEvent("PLAYER_LEVEL_UP", OnLevelChange)
	else
		-- Unregister events when DeathCounter is disabled
		K:UnregisterEvent("PLAYER_DEAD", OnPlayerDead)
		K:UnregisterEvent("PLAYER_LEVEL_UP", OnLevelChange)
	end

	currentLevel = K.Level

	-- Create or initialize the death counter database and update the death counts
	CreateDeathCounterDB()
	UpdateDeathCounts()

	-- Create the death counter panel frame
	local panel = CreateDeathCounterPanel()

	-- Register the slash command for showing/hiding the death counter panel
	SLASH_DEATHCOUNTERPANEL1 = "/deathcounterpanel"
	SLASH_DEATHCOUNTERPANEL2 = "/dcp"
	SlashCmdList["DEATHCOUNTERPANEL"] = function()
		if panel:IsShown() then
			panel:Hide()
		else
			panel:Show()
		end
	end
end
