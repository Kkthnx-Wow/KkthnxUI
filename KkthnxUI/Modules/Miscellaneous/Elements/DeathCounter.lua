local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local DEATHS = DEATHS

local playerDeaths = 0
local milestoneDeaths = { 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000 }

local function getClassIcon(class)
	local c1, c2, c3, c4 = unpack(CLASS_ICON_TCOORDS[class])
	c1, c2, c3, c4 = (c1 + 0.03) * 50, (c2 - 0.03) * 50, (c3 + 0.03) * 50, (c4 - 0.03) * 50
	local classStr = "|TInterface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes:12:12:0:0:50:50:" .. c1 .. ":" .. c2 .. ":" .. c3 .. ":" .. c4 .. "|t "
	return classStr or ""
end

local function UpdateDeathCounts()
	-- Update the local death count with the value from the death counter variable
	if not KkthnxUIDB.Deaths[K.Realm] then
		KkthnxUIDB.Deaths[K.Realm] = {}
	end

	if not KkthnxUIDB.Deaths[K.Realm][K.Name] then
		KkthnxUIDB.Deaths[K.Realm][K.Name] = {}
	end

	KkthnxUIDB.Deaths[K.Realm][K.Name][1] = playerDeaths
	KkthnxUIDB.Deaths[K.Realm][K.Name][2] = K.Class
end

local function SaveDeathCounts()
	-- Save the death count to the death counter variable
	KkthnxUIDB.Deaths[K.Realm][K.Name][1] = playerDeaths
end

local function CheckMilestoneDeaths()
	for _, milestone in ipairs(milestoneDeaths) do
		if playerDeaths == milestone then
			print("Congrats! You have reached a milestone of " .. milestone .. " deaths. You can thank Kkthnx for letting you know this very lame and useless statistic.")
		end
	end
end

local function OnPlayerDead()
	-- Increment the player's total death count
	playerDeaths = playerDeaths + 1

	-- Save the death count
	SaveDeathCounts()

	-- Check for milestone deaths
	CheckMilestoneDeaths()
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
	panel.deathCountTexts = {}

	-- Function to check if a character's death count exists
	local function CharacterDeathCountExists(realm, name)
		return KkthnxUIDB.Deaths[realm] and KkthnxUIDB.Deaths[realm][name]
	end

	-- Function to create a death count text
	local function CreateDeathCountText()
		local deathCountText = panel.scrollChild:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		deathCountText:SetHeight(14) -- Set the height of the death count text
		return deathCountText
	end

	-- Set the scroll child as the content of the scroll frame
	panel.scrollFrame:SetScrollChild(panel.scrollChild)

	-- Create the reset button for the panel
	panel.resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
	panel.resetButton:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 0, -6)
	panel.resetButton:SetSize(136, 22)
	panel.resetButton:SetText(RESET)
	panel.resetButton:SkinButton()
	panel.resetButton:SetScript("OnClick", function()
		-- Reset the death count and save to the death counter variable
		playerDeaths = 0
		SaveDeathCounts()

		-- Update the death count information in the panel
		for _, deathCountText in ipairs(panel.deathCountTexts) do
			deathCountText:SetText("")
		end
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
		-- Clear the existing death count texts
		for _, deathCountText in ipairs(panel.deathCountTexts) do
			deathCountText:SetText("")
		end

		-- Create and position the death count texts for existing characters
		local yOffset = -6
		for realm, realmData in pairs(KkthnxUIDB.Deaths) do
			for name, data in pairs(realmData) do
				local playerName = Ambiguate(name .. " - " .. realm, "none")
				local class = data[2]
				local deaths = data[1]
				local classColor = K.RGBToHex(K.ColorClass(class))
				local classIcon = getClassIcon(class)

				-- Check if the character's death count already exists
				if CharacterDeathCountExists(realm, name) then
					local deathCountText = CreateDeathCountText()
					deathCountText:SetParent(panel.scrollChild)
					deathCountText:SetPoint("TOPLEFT", 6, yOffset)
					deathCountText:SetFormattedText("%s%s%s|r | |TInterface\\TARGETINGFRAME\\UI-RaidTargetingIcon_8:12|t%s: %d", classIcon, classColor, playerName, DEATHS, deaths)
					deathCountText:SetTextColor(1, 1, 1) -- Set deaths text color to white
					table.insert(panel.deathCountTexts, deathCountText)
					yOffset = yOffset - 15
				end
			end
		end
	end)

	K.CreateMoverFrame(panel)

	return panel
end

function Module:CreateDeathCounter()
	-- Check if the DeathCounter module is enabled in the configuration
	if C["Misc"].DeathCounter then
		-- Register necessary events when DeathCounter is enabled
		K:RegisterEvent("PLAYER_DEAD", OnPlayerDead)
	else
		-- Unregister events when DeathCounter is disabled
		K:UnregisterEvent("PLAYER_DEAD", OnPlayerDead)
	end

	-- Update the death count
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
