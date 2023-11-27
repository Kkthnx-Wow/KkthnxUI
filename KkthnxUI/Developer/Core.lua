local K = KkthnxUI[1]

K.Devs = {
	["Kkthnx-Area 52"] = true,
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

local CommandsModule = K:NewModule("CommandWindow")

local CommandFrame
function CommandsModule:CreateCommandFrame()
	CommandFrame = CreateFrame("Frame", "KkthnxUICommandFrame", UIParent, "BackdropTemplate")
	CommandFrame:SetSize(600, 400) -- Width, Height
	CommandFrame:SetPoint("CENTER") -- Position it at the center of the screen
	CommandFrame:CreateBorder()
	CommandFrame:SetMovable(true)
	CommandFrame:EnableMouse(true)
	CommandFrame:RegisterForDrag("LeftButton")
	CommandFrame:SetScript("OnDragStart", CommandFrame.StartMoving)
	CommandFrame:SetScript("OnDragStop", CommandFrame.StopMovingOrSizing)
	CommandFrame:Hide() -- Initially hidden

	-- Create Close Button
	local CloseButton = CreateFrame("Button", nil, CommandFrame, "UIPanelCloseButton")
	CloseButton:SetPoint("TOPRIGHT", -5, -5)
	CloseButton:SetSize(32, 32)
	CloseButton:SetScript("OnClick", function()
		CommandFrame:Hide()
	end)

	local TitleBar = CommandFrame:CreateTexture(nil, "OVERLAY")
	TitleBar:SetColorTexture(0, 0, 0, 0.5) -- RGBA
	TitleBar:SetSize(580, 30) -- Width, Height
	TitleBar:SetPoint("TOP", 0, -10)

	local TitleText = CommandFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	TitleText:SetPoint("CENTER", TitleBar)
	TitleText:SetText("KkthnxUI Commands")

	local ScrollFrame = CreateFrame("ScrollFrame", nil, CommandFrame, "UIPanelScrollFrameTemplate")
	ScrollFrame:SetSize(560, 340) -- Width, Height
	ScrollFrame:SetPoint("TOP", 0, -50)

	local ScrollContent = CreateFrame("Frame", nil, ScrollFrame)
	ScrollContent:SetSize(560, 340) -- This should be dynamic based on content
	ScrollFrame:SetScrollChild(ScrollContent)

	-- Create CommandText as a FontString within ScrollContent
	local CommandText = ScrollContent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	CommandText:SetJustifyH("LEFT")
	CommandText:SetJustifyV("TOP")
	CommandText:SetSize(540, 320) -- Width, Height
	CommandText:SetPoint("TOPLEFT")

	-- Adjust ScrollContent to dynamically size based on content
	ScrollContent:SetSize(560, 0) -- Initial height set to 0
	ScrollContent:SetHeight(CommandText:GetStringHeight()) -- Adjust height based on text

	-- Store CommandText in CommandFrame for later access
	CommandFrame.ScrollContent = ScrollContent
	-- Store CommandText for later access and initial population
	CommandFrame.ScrollContent.CommandText = CommandText
	self:PopulateCommands()
end

function CommandsModule:ToggleCommandFrame()
	if CommandFrame and CommandFrame:IsShown() then
		CommandFrame:Hide()
	else
		if not CommandFrame then
			self:CreateCommandFrame()
		end
		self:PopulateCommands() -- Populate the commands each time the frame is shown
		CommandFrame:Show()
	end
end

local function CreateColoredText(text, colorCode)
	return "|c" .. colorCode .. text .. "|r"
end

function CommandsModule:PopulateCommands()
	local commands = {}
	local function AddCommand(command, description, colorCode)
		table.insert(commands, CreateColoredText(command, colorCode or "ffffffff") .. " - " .. description)
	end

	AddCommand("/kkevent, /kkevents", "Toggle event tracing on and off.", "ff00ff00")
	AddCommand("/kkgui, /kkconfig", "Toggle the KkthnxUI configuration GUI.", "ff00ff00")
	AddCommand("/kkvol, /kkvolume, /vol, /volume", "Set or display the master volume. Usage: /kkvol [0-1]", "ff00ff00")
	AddCommand("/kkrc", "Perform a ready check.", "ff00ff00")
	AddCommand("/kkqc, /kkcq, /kkcheckquest, /kkquestcheck", "Check the completion status of a quest. Usage: /kkqc [questID]", "ff00ff00")
	AddCommand("/gm, /ticket", "Toggle the help frame.", "ff00ff00")
	AddCommand("/deletequestitems, /dqi", "Delete all quest items from your bags.", "ff00ff00")
	AddCommand("/deleteheirlooms, /deletelooms", "Delete all heirlooms from your bags.", "ff00ff00")
	AddCommand("/ri, /instancereset, /resetinstance", "Reset all instances.", "ff00ff00")
	AddCommand("/binds", "Open the key binding interface.", "ff00ff00")
	AddCommand("/clearcombat, /clfix", "Clear the combat log entries.", "ff00ff00")
	AddCommand("/clearchat, /chatclear", "Clear the current chat frame or all chat frames. Usage: /clearchat [all]", "ff00ff00")

	local commandText = table.concat(commands, "\n\n")
	CommandFrame.ScrollContent.CommandText:SetText(commandText)

	-- Adjust ScrollContent height based on new content
	CommandFrame.ScrollContent:SetHeight(CommandFrame.ScrollContent.CommandText:GetStringHeight())
end

function CommandsModule:RegisterSlashCommands()
	SLASH_KKTHNXUICOMMANDS1 = "/kkc"
	SlashCmdList["KKTHNXUICOMMANDS"] = function()
		self:ToggleCommandFrame()
	end
end

function CommandsModule:OnEnable()
	self:RegisterSlashCommands()
	-- You can also call self:CreateCommandFrame() here if you want to create the frame immediately
end

local Module = K:NewModule("OneClickMPD")

local button

local enchantingItems = {
	[137195] = true, -- Highmountain Armor
	[137221] = true, -- Enchanted Raven Sigil
	[137286] = true, -- Fel-Crusted Rune
	[181991] = true, -- Antique Stalker's Bow
	[182021] = true, -- Antique Kyrian Javelin
	[182043] = true, -- Antique Necromancer's Staff
	[182067] = true, -- Antique Duelist's Rapier
	[198675] = true, -- Lava-Infused Seed
	[198689] = true, -- Stormbound Horn
	[198694] = true, -- Enriched Earthen Shard
	[198798] = true, -- Flashfrozen Scroll
	[198799] = true, -- Forgotten Arcane Tome
	[198800] = true, -- Fractured Titanic Sphere
	[200479] = true, -- Sophic Amalgamation
	[200939] = true, -- Chromatic Pocketwatch
	[200940] = true, -- Everflowing Inkwell
	[200941] = true, -- Seal of Order
	[200942] = true, -- Vibrant Emulsion
	[200943] = true, -- Whispering Band
	[200945] = true, -- Valiant Hammer
	[200946] = true, -- Thunderous Blade
	[200947] = true, -- Carving of Awakening
	[201356] = true, -- Glimmer of Fire
	[201357] = true, -- Glimmer of Frost
	[201358] = true, -- Glimmer of Air
	[201359] = true, -- Glimmer of Earth
	[201360] = true, -- Glimmer of Order
	[204990] = true, -- Lava-Drenched Shadow Crystal
	[204999] = true, -- Shimmering Aqueous Orb
	[205001] = true, -- Resonating Arcane Crystal
}

function Module:PLAYER_LOGIN()
	local disenchanter, rogue

	if IsSpellKnown(13262) then
		disenchanter = true
	end

	if IsSpellKnown(1804) then
		rogue = ITEM_MIN_SKILL:gsub("%%s", (K.Client == "ruRU" and "Взлом замков" or GetSpellInfo(1809))):gsub("%%d", "%(.*%)")
	end

	local function OnTooltipSetUnit(self)
		-- Exit early if not the GameTooltip or if the tooltip is forbidden
		if self ~= GameTooltip or self:IsForbidden() then
			return
		end

		-- Exit early if in combat, Alt key is not held down, or Auction House frame is shown
		if InCombatLockdown() or not IsAltKeyDown() or (AuctionHouseFrame and AuctionHouseFrame:IsShown()) then
			return
		end

		local _, link = TooltipUtil.GetDisplayedItem(self)
		if link then
			local itemID = GetItemInfoFromHyperlink(link)
			if not itemID then
				return
			end
			local spell, r, g, b
			if disenchanter then
				if enchantingItems[itemID] then
					spell, r, g, b = GetSpellInfo(13262), 0.5, 0.5, 1
				else
					local _, _, quality, _, _, _, _, _, _, _, _, class, subClass = GetItemInfo(link)
					if quality and ((quality >= Enum.ItemQuality.Uncommon and quality <= Enum.ItemQuality.Epic) and C_Item.GetItemInventoryTypeByID(itemID) ~= Enum.InventoryType.IndexBodyType and (class == Enum.ItemClass.Weapon or (class == Enum.ItemClass.Armor and subClass ~= Enum.ItemClass.Cosmetic) or (class == Enum.ItemClass.Gem and subClass == 11) or class == Enum.ItemClass.Profession)) then
						spell, r, g, b = GetSpellInfo(13262), 0.5, 0.5, 1
					end
				end
			elseif rogue then
				for index = 1, self:NumLines() do
					if string.match(_G["GameTooltipTextLeft" .. index]:GetText() or "", rogue) then
						spell, r, g, b = GetSpellInfo(1804), 0, 1, 1
					end
				end
			end

			local bag, slot = GetMouseFocus():GetParent(), GetMouseFocus()
			if spell and C_Container.GetContainerItemLink(bag:GetID(), slot:GetID()) == link then
				button:SetAttribute("macrotext", string.format("/cast %s\n/use %s %s", spell, bag:GetID(), slot:GetID()))
				button:SetAllPoints(slot)
				button:Show()
				AutoCastShine_AutoCastStart(button, r, g, b)
			end
		end
	end

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetUnit)

	button:SetFrameStrata("TOOLTIP")
	button:SetAttribute("*type1", "macro")
	button:SetScript("OnLeave", Module.MODIFIER_STATE_CHANGED)

	button:RegisterEvent("MODIFIER_STATE_CHANGED", Module.MODIFIER_STATE_CHANGED)
	button:Hide()

	for _, sparks in pairs(button.sparkles) do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end

function Module:MODIFIER_STATE_CHANGED(key)
	if not button:IsShown() and not key and key ~= "LALT" and key ~= "RALT" then
		return
	end

	if InCombatLockdown() then
		button:SetAlpha(0)
		button:RegisterEvent("PLAYER_REGEN_ENABLED", Module.PLAYER_REGEN_ENABLED)
	else
		button:ClearAllPoints()
		button:SetAlpha(1)
		button:Hide()
		AutoCastShine_AutoCastStop(button)
	end
end

function Module:PLAYER_REGEN_ENABLED()
	button:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.PLAYER_REGEN_ENABLED)
	button:MODIFIER_STATE_CHANGED()
end

function Module:OnEnable()
	button = CreateFrame("Button", "OneClickMPD", UIParent, "SecureActionButtonTemplate, AutoCastShineTemplate")
	button:RegisterForClicks("AnyUp", "AnyDown")
	button:SetScript("OnEvent", function(self, event, ...)
		Module[event](button, ...)
	end)
	Module:PLAYER_LOGIN()
end
