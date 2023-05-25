local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local currentLevel
local playerDeaths = 0
local levelDeaths = {}

local function CreateDeathCounterDB()
	-- Create or initialize the death counter database for the current character
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter.Level = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter.Level or {}
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter.Player = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter.Player or 0
end

local function UpdateDeathCounts()
	-- Update the local death counts with the values from the database
	playerDeaths = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter.Player or 0
	levelDeaths = KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter.Level or {}
end

local function SaveDeathCounts()
	-- Save the death counts to the database
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter.Player = playerDeaths
	KkthnxUIDB.Variables[K.Realm][K.Name].DeathCounter.Level = levelDeaths
end

local function OnPlayerDead()
	-- print("DEBUG: Player has died.")

	-- Increment the player's total death count and level-specific death count
	playerDeaths = playerDeaths + 1
	levelDeaths[currentLevel] = (levelDeaths[currentLevel] or 0) + 1

	-- Save the death counts to the database
	SaveDeathCounts()

	-- Print the updated death counts
	print("Total Deaths: " .. playerDeaths)
	print("Level Deaths: " .. levelDeaths[currentLevel])
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
	panel:SetSize(220, 200)
	panel:SetPoint("CENTER")
	panel:CreateBorder()
	panel:Hide()

	panel.title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	panel.title:SetPoint("TOP", 0, -10)
	panel.title:SetText("Death Counter")

	-- Create the scroll frame for the panel
	panel.scrollFrame = CreateFrame("ScrollFrame", "DeathCounterPanelScrollFrame", panel, "UIPanelScrollFrameTemplate")
	panel.scrollFrame:SetPoint("TOP", panel.title, "BOTTOM", -8, -10)
	panel.scrollFrame:SetPoint("BOTTOM", panel, "BOTTOM", 8, 10)
	panel.scrollFrame:SetWidth(180)
	panel.scrollFrame.ScrollBar:SkinScrollBar()

	-- Create the scroll child frame
	panel.scrollChild = CreateFrame("Frame", nil, panel.scrollFrame)
	panel.scrollChild:SetSize(180, 180)

	-- Create the font strings for displaying death counts
	panel.totalDeaths = panel.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	panel.totalDeaths:SetPoint("TOPLEFT", 5, -5)

	panel.levelDeaths = panel.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	panel.levelDeaths:SetPoint("TOPLEFT", panel.totalDeaths, "BOTTOMLEFT", 0, -10)

	panel.note = panel.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	panel.note:SetPoint("BOTTOMLEFT", 5, 5)
	panel.note:SetText("Note: Deaths are recorded|nto track your progress.")

	-- Set the scroll child as the content of the scroll frame
	panel.scrollFrame:SetScrollChild(panel.scrollChild)

	-- Create the reset button for the panel
	panel.resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	panel.resetButton:SetPoint("TOP", panel, "BOTTOM", -0, -6)
	panel.resetButton:SetSize(220, 22)
	panel.resetButton:SetText("Reset Death Counters")
	panel.resetButton:SkinButton()
	panel.resetButton:SetScript("OnClick", function()
		-- Reset the death counts and save to the database
		playerDeaths = 0
		levelDeaths = {}
		SaveDeathCounts()

		-- Update the death count information in the panel
		panel.totalDeaths:SetText("Total Deaths: " .. playerDeaths)
		panel.levelDeaths:SetText("Level Deaths:\n0")
	end)

	-- Create the close button for the panel
	panel.closeButton = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
	panel.closeButton:SetPoint("TOPRIGHT", 2, 2)
	panel.closeButton:SkinCloseButton()
	panel.closeButton:SetScript("OnClick", function()
		panel:Hide()
	end)

	panel:SetScript("OnShow", function()
		-- Update the death count information when the panel is shown
		panel.totalDeaths:SetText("Total Deaths: " .. playerDeaths)
		local levelDeathsText = "Level Deaths:\n"
		if next(levelDeaths) == nil then
			levelDeathsText = levelDeathsText .. "0"
		else
			for level, deaths in pairs(levelDeaths) do
				levelDeathsText = levelDeathsText .. "Level " .. level .. ": " .. deaths .. "\n"
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
