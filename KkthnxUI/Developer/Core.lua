local K, L = KkthnxUI[1], KkthnxUI[3]

K.Devs = {
	["Kkthnx-Valdrakken"] = true,
	["Informant-Valdrakken"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

-- Your taintLog module
local taintLogModule = K:NewModule("TaintLog")

-- Function to toggle taintLog setting
function taintLogModule.ToggleTaintLog()
	local currentSetting = GetCVar("taintLog")

	if currentSetting == "0" then
		SetCVar("taintLog", "1")
		print("Taint log is now |cFF00FF00ON.|r") -- Green color for "ON"
	else
		SetCVar("taintLog", "0")
		print("Taint log is now |cFFFF0000OFF.|r") -- Red color for "OFF"
	end
end

-- Function to check and print taintLog status on login/reload
function taintLogModule.CheckTaintLogStatus()
	local currentSetting = GetCVar("taintLog")

	if currentSetting == "0" then
		print("Taint log is currently |cFFFF0000OFF.|r") -- Red color for "OFF"
	else
		print("Taint log is currently |cFF00FF00ON.|r") -- Green color for "ON"
	end

	-- Unregister the event after checking
	K:UnregisterEvent("PLAYER_ENTERING_WORLD", taintLogModule.CheckTaintLogStatus)
end

-- Add an OnEnable function
function taintLogModule:OnEnable()
	-- Register events for taintLog
	K:RegisterEvent("PLAYER_ENTERING_WORLD", taintLogModule.CheckTaintLogStatus)
	SLASH_TOGGLETAINTLOG1 = "/ttl"
	SlashCmdList["TOGGLETAINTLOG"] = taintLogModule.ToggleTaintLog
end

--------------------------------------------------------------------------------------
-- AutoDismount Me
--------------------------------------------------------------------------------------
local AutoDismount = K:NewModule("AutoDismount")

local ErrorsToCheckFor = {
	[SPELL_FAILED_NOT_SHAPESHIFT] = true,
	[SPELL_FAILED_NO_ITEMS_WHILE_SHAPESHIFTED] = true,
	[SPELL_NOT_SHAPESHIFTED] = true,
	[SPELL_NOT_SHAPESHIFTED_NOSPACE] = true,
	[ERR_CANT_INTERACT_SHAPESHIFTED] = true,
	[ERR_NOT_WHILE_SHAPESHIFTED] = true,
	[ERR_NO_ITEMS_WHILE_SHAPESHIFTED] = true,
	[ERR_TAXIPLAYERSHAPESHIFTED] = true,
	[ERR_MOUNT_SHAPESHIFTED] = true,
	[ERR_EMBLEMERROR_NOTABARDGEOSET] = true,
	[SPELL_FAILED_NOT_MOUNTED] = true,
	[ERR_ATTACK_MOUNTED] = true,
	[ERR_NOT_WHILE_MOUNTED] = true,
	-- Add any other error codes as needed
}

local function HandleDismountError()
	local ok, err = pcall(Dismount)
	if not ok then
		-- Handle or log the error
	end
end

local function OnErrorMessage(_, _, messageType)
	if ErrorsToCheckFor[messageType] and IsMounted() and not UnitAffectingCombat("player") then
		HandleDismountError()
	end
end

function AutoDismount:OnEnable()
	K:RegisterEvent("UI_ERROR_MESSAGE", OnErrorMessage)
end

-- CHAT FILTERS
local function ChatFilter(_, _, msg)
	-- Pattern to specifically match the format "[Announce by Name]:"
	-- This pattern ignores WoW's color codes and other non-text elements.
	local announcePattern = "%[Announce by .-%]:"

	-- Check for pet ability message
	if msg:find("Your pet has learned a new ability") then
		-- DEFAULT_CHAT_FRAME:AddMessage("Firestorm Fix: Filtered pet ability message: " .. msg)
		return true
	end

	-- Check for announcement message
	if msg:find(announcePattern) then
		DEFAULT_CHAT_FRAME:AddMessage("Firestorm Fix: Filtered announcement: " .. msg)
		return true
	end
end

-- Register the chat filter for both system and channel messages
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", ChatFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", ChatFilter)

-----------------------------------------------------------------------------
-- Class Pet Reminder
-- CPR (Class Pet Reminder) module for reminding players to summon their pets
-----------------------------------------------------------------------------
local CPR = K:NewModule("CPR")

local reminderTimer = nil
local REMINDER_INTERVAL = 10 -- seconds

-- Function to handle pet summoned event
local function OnPetSummoned()
	if reminderTimer then
		reminderTimer:Cancel()
		reminderTimer = nil
	end
end

-- Function to handle a pet that is not summoned
local function NotifyNotSummonedPet()
	local icon = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:20|t" -- Example pet icon (Skull)
	UIErrorsFrame:AddMessage(icon .. " Warning: Your pet is not summoned! Remember to summon it.", 1.0, 0.5, 0.5, 1.0)
end

-- Function to handle a dead pet
local function NotifyDeadPet()
	local icon = "|TInterface\\TargetingFrame\\UI-TargetingFrame-Skull:20|t" -- Example pet icon (Skull)
	UIErrorsFrame:AddMessage(icon .. " Warning: Your pet has died! Resummon or revive it.", 1.0, 0.5, 0.5, 1.0)
end

-- Function to create class pet reminder
local function CreateClassPetReminder(event)
	-- Function to check if pet is not summoned
	local function CheckNotSummonedPet()
		if K.Class == "HUNTER" or K.Class == "WARLOCK" then
			if not UnitExists("pet") then
				NotifyNotSummonedPet()
			end
		end
	end

	-- Function to check if pet is dead
	local function CheckDeadPet()
		if K.Class == "HUNTER" or K.Class == "WARLOCK" then
			if UnitIsDead("pet") then
				NotifyDeadPet()
			end
		end
	end

	-- Event handling based on event type
	if event == "PLAYER_REGEN_DISABLED" then
		CheckNotSummonedPet()
		CheckDeadPet()
		reminderTimer = C_Timer.NewTicker(REMINDER_INTERVAL, function()
			CheckNotSummonedPet()
			CheckDeadPet()
		end)
	elseif event == "PLAYER_REGEN_ENABLED" or event == "UNIT_PET" then
		OnPetSummoned()
	end
end

-- Function called when the module is enabled
function CPR:OnEnable()
	-- Registering events to trigger class pet reminder
	K:RegisterEvent("PLAYER_REGEN_DISABLED", CreateClassPetReminder)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", CreateClassPetReminder)
	K:RegisterEvent("UNIT_PET", CreateClassPetReminder, "player")
end

--------------------------------------------------------------------------------------
-- StatPriorityAdvisor
-- Displays the stat priority for your current specialization on the character frame.
--------------------------------------------------------------------------------------
local function getPlayerClassAndSpec()
	local class, _, classID = UnitClass("player")
	local specIndex = GetSpecialization()
	if classID and specIndex then
		return class, specIndex
	end
end

local statPriority = {
	["Hunter"] = {
		[1] = { "Beast Mastery", "AGILITY", L["Crit"], "HASTE", "MASTERY", "VERSATILITY" },
		[2] = { "Marksmanship", "AGILITY", L["Crit"], "HASTE", "MASTERY", "VERSATILITY" },
		[3] = { "Survival", "AGILITY", L["Crit"], "HASTE", "VERSATILITY", "MASTERY" },
	},
	["Demon Hunter"] = {
		[1] = { "Havoc", "AGILITY", L["Crit"], "HASTE", "MASTERY", "VERSATILITY" },
		[2] = { "Vengeance", "AGILITY", "VERSATILITY", "HASTE", "MASTERY", L["Crit"] },
	},
	-- Add stat priorities for other classes here
}

local function createStatPriorityFrame()
	local characterFrame = CharacterFrame
	local frame = CreateFrame("Frame", "StatPriorityFrame", characterFrame)
	frame:SetHeight(30)

	local backdrop = frame:CreateTexture(nil, "BACKGROUND")
	backdrop:SetColorTexture(0, 0, 0, 0.5)
	frame.backdrop = backdrop

	local specIcon = frame:CreateTexture(nil, "ARTWORK")
	specIcon:SetSize(24, 24)
	specIcon:SetPoint("LEFT", frame, "LEFT", 4, 0)
	frame.specIcon = specIcon

	frame.statPriorityText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	frame.statPriorityText:SetPoint("LEFT", specIcon, "RIGHT", 6, 0)

	local function updateStatPriorityFrame(iconPath, statText)
		specIcon:SetTexture(iconPath)
		frame.statPriorityText:SetText(statText)

		local totalWidth = specIcon:GetWidth() + frame.statPriorityText:GetStringWidth() + 10
		frame:SetWidth(totalWidth)
		backdrop:SetAllPoints(frame)
	end

	local function onPlayerLogin()
		local class, specID = getPlayerClassAndSpec()
		if class and specID then
			local _, _, _, icon = GetSpecializationInfo(specID)
			local specPriority = statPriority[class] and statPriority[class][specID]
			if specPriority then
				local statText = table.concat(specPriority, " > ", 2)
				updateStatPriorityFrame(icon, statText)
			else
				print("Spec not found for class " .. class)
			end
		end
	end

	frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	frame:SetScript("OnEvent", onPlayerLogin)

	onPlayerLogin()

	frame:SetPoint("TOP", CharacterFrameTitleText, "TOP", 0, 40)

	frame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
		GameTooltip:SetText("Stat Priority", 1, 1, 1)
		GameTooltip:AddLine("This stat priority is based on current theorycrafting for your specialization.", nil, nil, nil, true)
		GameTooltip:AddLine("Last updated: [Insert Last Updated Date]", nil, nil, nil, true)
		GameTooltip:Show()
	end)
	frame:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	return frame
end

local function onPlayerEnteringWorld()
	local class, specID = getPlayerClassAndSpec()
	if class and specID then
		createStatPriorityFrame()
	end
end

local addon = CreateFrame("Frame")
addon:RegisterEvent("PLAYER_LOGIN")
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
addon:SetScript("OnEvent", onPlayerEnteringWorld)
