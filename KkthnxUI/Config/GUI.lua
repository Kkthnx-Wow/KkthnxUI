local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local GUI = K["GUI"]

local COLORS = COLORS
local FILTERS = FILTERS
local FOCUS = FOCUS
local INTERRUPT = INTERRUPT
local PET = PET
local PLAYER = PLAYER
local SlashCmdList = SlashCmdList
local TARGET = TARGET
local TUTORIAL_TITLE47 = TUTORIAL_TITLE47

local emojiExampleIcon = "|TInterface\\Addons\\KkthnxUI\\Media\\Chat\\Emojis\\StuckOutTongueClosedEyes:0:0:4|t"
local enableTextColor = "|cff00cc4c"
local newFeatureIcon = "|TInterface\\GossipFrame\\CampaignAvailableQuestIcon:16:16:-2|t"

local function updateBagSize()
	K:GetModule("Bags"):UpdateBagSize()
end

local function UpdateBagSortOrder()
	C_Container.SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
end

local function UpdateBagStatus()
	K:GetModule("Bags"):UpdateAllBags()
end

local function updateBagAnchor()
	K:GetModule("Bags"):UpdateAllAnchors()
end

local function refreshNameplates()
	K:GetModule("Unitframes"):RefreshAllPlates()
end

local function togglePlatePower()
	K:GetModule("Unitframes"):TogglePlatePower()
end

local function toggleMinimapIcon()
	K:GetModule("Miscellaneous"):ToggleMinimapIcon()
end

local function togglePlayerPlate()
	refreshNameplates()
	K:GetModule("Unitframes"):TogglePlayerPlate()
end

local function updateSmoothingAmount()
	K:SetSmoothingAmount(C["General"].SmoothAmount)
end

local function UpdatePlayerBuffs()
	local frame = oUF_Player
	if not frame then
		return
	end

	local element = frame.Buffs
	if not element then
		return
	end
	element.iconsPerRow = C["Unitframe"].PlayerBuffsPerRow

	local width = C["Unitframe"].PlayerHealthWidth
	local maxLines = element.iconsPerRow and K.Round(element.num / element.iconsPerRow)
	element.size = K:GetModule("Unitframes").auraIconSize(width, element.iconsPerRow, element.spacing)
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
	element:ForceUpdate()
end

local function UpdatePlayerDebuffs()
	local frame = oUF_Player
	if not frame then
		return
	end

	local element = frame.Debuffs
	if not element then
		return
	end
	element.iconsPerRow = C["Unitframe"].PlayerDebuffsPerRow

	local width = C["Unitframe"].PlayerHealthWidth
	local maxLines = element.iconsPerRow and K.Round(element.num / element.iconsPerRow)
	element.size = K:GetModule("Unitframes").auraIconSize(width, element.iconsPerRow, element.spacing)
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
	element:ForceUpdate()
end

local function UpdateTargetBuffs()
	local frame = oUF_Target
	if not frame then
		return
	end

	local element = frame.Buffs
	if not element then
		return
	end
	element.iconsPerRow = C["Unitframe"].TargetBuffsPerRow

	local width = C["Unitframe"].TargetHealthWidth
	local maxLines = element.iconsPerRow and K.Round(element.num / element.iconsPerRow)
	element.size = K:GetModule("Unitframes").auraIconSize(width, element.iconsPerRow, element.spacing)
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
	element:ForceUpdate()
end

local function UpdateTargetDebuffs()
	local frame = oUF_Target
	if not frame then
		return
	end

	local element = frame.Debuffs
	if not element then
		return
	end
	element.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

	local width = C["Unitframe"].TargetHealthWidth
	local maxLines = element.iconsPerRow and K.Round(element.num / element.iconsPerRow)
	element.size = K:GetModule("Unitframes").auraIconSize(width, element.iconsPerRow, element.spacing)
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
	element:ForceUpdate()
end

local function UpdateChatSticky()
	K:GetModule("Chat"):ChatWhisperSticky()
end

local function UpdateChatSize()
	K:GetModule("Chat"):UpdateChatSize()
end

local function ToggleChatBackground()
	K:GetModule("Chat"):ToggleChatBackground()
end

local function UpdateChatBubble()
	for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
		chatBubble.KKUI_Background:SetVertexColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Skins"].ChatBubbleAlpha)
	end
end

local function UpdateMarkerGrid()
	K:GetModule("Miscellaneous"):RaidTool_UpdateGrid()
end

function UpdateActionbar()
	K:GetModule("ActionBar"):UpdateBarVisibility()
end

local function SetABFaderState()
	local Module = K:GetModule("ActionBar")
	if not Module.fadeParent then
		return
	end

	Module.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
end

local function UpdateABFaderState()
	local Module = K:GetModule("ActionBar")
	if not Module.fadeParent then
		return
	end

	Module:UpdateFaderState()
	Module.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
end

local function UpdateActionbarHotkeys()
	K:GetModule("ActionBar"):UpdateBarConfig()
end

local function SetupAuraWatch()
	GUI:Toggle()
	SlashCmdList["KKUI_AWCONFIG"]() -- To Be Implemented
end

local function ResetDetails()
	K:GetModule("Skins"):ResetDetailsAnchor(true)
end

local function UpdateBlipTextures()
	K:GetModule("Minimap"):UpdateBlipTexture()
end

local function UpdateTotemBar()
	if not C["Auras"].Totems then
		return
	end

	K:GetModule("Auras"):TotemBar_Init()
end

local function UpdateQuestFontSize()
	K:GetModule("Miscellaneous"):CreateQuestSizeUpdate()
end

local function UpdateObjectiveFontSize()
	K:GetModule("Miscellaneous"):CreateObjectiveSizeUpdate()
end

local function UpdateCustomUnitList()
	K:GetModule("Unitframes"):CreateUnitTable()
end

local function UpdatePowerUnitList()
	K:GetModule("Unitframes"):CreatePowerUnitTable()
end

local function UpdateInterruptAlert()
	K:GetModule("Announcements"):CreateInterruptAnnounce()
end

local function UpdateUnitPlayerSize()
	local width = C["Unitframe"].PlayerHealthWidth
	local healthHeight = C["Unitframe"].PlayerHealthHeight
	local powerHeight = C["Unitframe"].PlayerPowerHeight
	local height = healthHeight + powerHeight + 6

	if not _G.oUF_Player then
		return
	end

	_G.oUF_Player:SetSize(width, height)
	_G.oUF_Player.Health:SetHeight(healthHeight)
	_G.oUF_Player.Power:SetHeight(powerHeight)

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if _G.KKUI_PlayerPortrait then
			_G.KKUI_PlayerPortrait:SetSize(healthHeight + powerHeight + 6, healthHeight + powerHeight + 6)
		end
	end
end

local function UpdateUnitTargetSize()
	local width = C["Unitframe"].TargetHealthWidth
	local healthHeight = C["Unitframe"].TargetHealthHeight
	local powerHeight = C["Unitframe"].TargetPowerHeight
	local height = healthHeight + powerHeight + 6

	if not _G.oUF_Target then
		return
	end

	_G.oUF_Target:SetSize(width, height)
	_G.oUF_Target.Health:SetHeight(healthHeight)
	_G.oUF_Target.Power:SetHeight(powerHeight)

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if _G.KKUI_TargetPortrait then
			_G.KKUI_TargetPortrait:SetSize(healthHeight + powerHeight + 6, healthHeight + powerHeight + 6)
		end
	end
end

local function UpdateUnitFocusSize()
	local width = C["Unitframe"].FocusHealthWidth
	local healthHeight = C["Unitframe"].FocusHealthHeight
	local powerHeight = C["Unitframe"].FocusPowerHeight
	local height = healthHeight + powerHeight + 6

	if not _G.oUF_Focus then
		return
	end

	_G.oUF_Focus:SetSize(width, height)
	_G.oUF_Focus.Health:SetHeight(healthHeight)
	_G.oUF_Focus.Power:SetHeight(powerHeight)

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if _G.KKUI_FocusPortrait then
			_G.KKUI_FocusPortrait:SetSize(healthHeight + powerHeight + 6, healthHeight + powerHeight + 6)
		end
	end
end

local function UpdateUnitPartySize()
	local width = C["Party"].HealthWidth
	local healthHeight = C["Party"].HealthHeight
	local powerHeight = C["Party"].PowerHeight
	local height = healthHeight + powerHeight + 6

	for i = 1, _G.MAX_PARTY_MEMBERS do
		local bu = _G["oUF_PartyUnitButton" .. i]
		if bu then
			bu:SetSize(width, height)
			bu.Health:SetHeight(healthHeight)
			bu.Power:SetHeight(powerHeight)

			if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
				if _G.KKUI_PartyPortrait then
					_G.KKUI_PartyPortrait:SetSize(healthHeight + powerHeight + 6, healthHeight + powerHeight + 6)
				end
			end
		end
	end
end

local function UpdateUnitRaidSize()
	local width = C["Raid"].Width
	local healthHeight = C["Raid"].Height
	local height = healthHeight

	for i = 1, _G.MAX_RAID_MEMBERS do
		if InCombatLockdown() then
			return
		end

		local bu = _G["oUF_Raid" .. i .. "UnitButton" .. i]
		if bu then
			bu:SetSize(width, height)
			bu.Health:SetHeight(healthHeight)
		end
	end
end

local function UpdateMaxZoomLevel()
	K:GetModule("Miscellaneous"):UpdateMaxCameraZoom()
end

local function UpdateActionBar1Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar1")
end

local function UpdateActionBar2Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar2")
end

local function UpdateActionBar3Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar3")
end

local function UpdateActionBar4Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar4")
end

local function UpdateActionBar5Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar5")
end

local function UpdateActionBar6Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar6")
end

local function UpdateActionBar7Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar7")
end

local function UpdateActionBar8Scale()
	K:GetModule("ActionBar"):UpdateActionSize("Bar8")
end

local function UpdateActionBarPetScale()
	K:GetModule("ActionBar"):UpdateActionSize("BarPet")
end

local function UpdateActionBarStance()
	K:GetModule("ActionBar"):UpdateStanceBar()
end

local function UpdateActionBarVehicleButton()
	K:GetModule("ActionBar"):UpdateVehicleButton()
end

local function UpdateGroupLoot()
	K:GetModule("Loot"):UpdateLootRollFrames()
end

-- Sliders > minvalue, maxvalue, stepvalue
local ActionBar = function(self)
	local Window = self:CreateWindow(L["ActionBar"])

	Window:CreateSection("ActionBar 1")
	Window:CreateSwitch("ActionBar", "Bar1", enableTextColor .. L["Enable ActionBar"] .. " 1", nil, UpdateActionbar)
	Window:CreateSlider("ActionBar", "Bar1Size", "Button Size", 20, 80, 1, nil, UpdateActionBar1Scale)
	Window:CreateSlider("ActionBar", "Bar1PerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBar1Scale)
	Window:CreateSlider("ActionBar", "Bar1Num", "Button Num", 1, 12, 1, nil, UpdateActionBar1Scale)
	Window:CreateSlider("ActionBar", "Bar1Font", "Button FontSize", 8, 20, 1, nil, UpdateActionBar1Scale)
	Window:CreateSwitch("ActionBar", "Bar1Fade", "Enable Fade for Bar 1", "Allows Bar 1 to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar 2")
	Window:CreateSwitch("ActionBar", "Bar2", enableTextColor .. L["Enable ActionBar"] .. " 2", nil, UpdateActionbar)
	Window:CreateSlider("ActionBar", "Bar2Size", "Button Size", 20, 80, 1, nil, UpdateActionBar2Scale)
	Window:CreateSlider("ActionBar", "Bar2PerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBar2Scale)
	Window:CreateSlider("ActionBar", "Bar2Num", "Button Num", 1, 12, 1, nil, UpdateActionBar2Scale)
	Window:CreateSlider("ActionBar", "Bar2Font", "Button FontSize", 8, 20, 1, nil, UpdateActionBar2Scale)
	Window:CreateSwitch("ActionBar", "Bar2Fade", "Enable Fade for Bar 2", "Allows Bar 2 to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar 3")
	Window:CreateSwitch("ActionBar", "Bar3", enableTextColor .. L["Enable ActionBar"] .. " 3", nil, UpdateActionbar)
	Window:CreateSlider("ActionBar", "Bar3Size", "Button Size", 20, 80, 1, nil, UpdateActionBar3Scale)
	Window:CreateSlider("ActionBar", "Bar3PerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBar3Scale)
	Window:CreateSlider("ActionBar", "Bar3Num", "Button Num", 1, 12, 1, nil, UpdateActionBar3Scale)
	Window:CreateSlider("ActionBar", "Bar3Font", "Button FontSize", 8, 20, 1, nil, UpdateActionBar3Scale)
	Window:CreateSwitch("ActionBar", "Bar3Fade", "Enable Fade for Bar 3", "Allows Bar 3 to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar 4")
	Window:CreateSwitch("ActionBar", "Bar4", enableTextColor .. L["Enable ActionBar"] .. " 4", nil, UpdateActionbar)
	Window:CreateSlider("ActionBar", "Bar4Size", "Button Size", 20, 80, 1, nil, UpdateActionBar4Scale)
	Window:CreateSlider("ActionBar", "Bar4PerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBar4Scale)
	Window:CreateSlider("ActionBar", "Bar4Num", "Button Num", 1, 12, 1, nil, UpdateActionBar4Scale)
	Window:CreateSlider("ActionBar", "Bar4Font", "Button FontSize", 8, 20, 1, nil, UpdateActionBar4Scale)
	Window:CreateSwitch("ActionBar", "Bar4Fade", "Enable Fade for Bar 4", "Allows Bar 4 to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar 5")
	Window:CreateSwitch("ActionBar", "Bar5", enableTextColor .. L["Enable ActionBar"] .. " 5", nil, UpdateActionbar)
	Window:CreateSlider("ActionBar", "Bar5Size", "Button Size", 20, 80, 1, nil, UpdateActionBar5Scale)
	Window:CreateSlider("ActionBar", "Bar5PerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBar5Scale)
	Window:CreateSlider("ActionBar", "Bar5Num", "Button Num", 1, 12, 1, nil, UpdateActionBar5Scale)
	Window:CreateSlider("ActionBar", "Bar5Font", "Button FontSize", 8, 20, 1, nil, UpdateActionBar5Scale)
	Window:CreateSwitch("ActionBar", "Bar5Fade", "Enable Fade for Bar 5", "Allows Bar 5 to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar 6")
	Window:CreateSwitch("ActionBar", "Bar6", enableTextColor .. L["Enable ActionBar"] .. " 6", nil, UpdateActionbar)
	Window:CreateSlider("ActionBar", "Bar6Size", "Button Size", 20, 80, 1, nil, UpdateActionBar6Scale)
	Window:CreateSlider("ActionBar", "Bar6PerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBar6Scale)
	Window:CreateSlider("ActionBar", "Bar6Num", "Button Num", 1, 12, 1, nil, UpdateActionBar6Scale)
	Window:CreateSlider("ActionBar", "Bar6Font", "Button FontSize", 8, 20, 1, nil, UpdateActionBar6Scale)
	Window:CreateSwitch("ActionBar", "Bar6Fade", "Enable Fade for Bar 6", "Allows Bar 6 to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar 7")
	Window:CreateSwitch("ActionBar", "Bar7", enableTextColor .. L["Enable ActionBar"] .. " 7", nil, UpdateActionbar)
	Window:CreateSlider("ActionBar", "Bar7Size", "Button Size", 20, 80, 1, nil, UpdateActionBar7Scale)
	Window:CreateSlider("ActionBar", "Bar7PerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBar7Scale)
	Window:CreateSlider("ActionBar", "Bar7Num", "Button Num", 1, 12, 1, nil, UpdateActionBar7Scale)
	Window:CreateSlider("ActionBar", "Bar7Font", "Button FontSize", 8, 20, 1, nil, UpdateActionBar7Scale)
	Window:CreateSwitch("ActionBar", "Bar7Fade", "Enable Fade for Bar 7", "Allows Bar 7 to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar 8")
	Window:CreateSwitch("ActionBar", "Bar8", enableTextColor .. L["Enable ActionBar"] .. " 8", nil, UpdateActionbar)
	Window:CreateSlider("ActionBar", "Bar8Size", "Button Size", 20, 80, 1, nil, UpdateActionBar8Scale)
	Window:CreateSlider("ActionBar", "Bar8PerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBar8Scale)
	Window:CreateSlider("ActionBar", "Bar8Num", "Button Num", 1, 12, 1, nil, UpdateActionBar8Scale)
	Window:CreateSlider("ActionBar", "Bar8Font", "Button FontSize", 8, 20, 1, nil, UpdateActionBar8Scale)
	Window:CreateSwitch("ActionBar", "Bar8Fade", "Enable Fade for Bar 8", "Allows Bar 8 to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar Pet")
	Window:CreateSlider("ActionBar", "BarPetSize", "Button Size", 20, 80, 1, nil, UpdateActionBarPetScale)
	Window:CreateSlider("ActionBar", "BarPetPerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBarPetScale)
	Window:CreateSlider("ActionBar", "BarPetFont", "Button FontSize", 8, 20, 1, nil, UpdateActionBarPetScale)
	Window:CreateSwitch("ActionBar", "BarPetFade", "Enable Fade for Pet Bar", "Allows the Pet Bar to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar Stance")
	Window:CreateSwitch("ActionBar", "ShowStance", enableTextColor .. "Enable StanceBar")
	Window:CreateSlider("ActionBar", "BarStanceSize", "Button Size", 20, 80, 1, nil, UpdateActionBarStance)
	Window:CreateSlider("ActionBar", "BarStancePerRow", "Button PerRow", 1, 12, 1, nil, UpdateActionBarStance)
	Window:CreateSlider("ActionBar", "BarStanceFont", "Button FontSize", 8, 20, 1, nil, UpdateActionBarStance)
	Window:CreateSwitch("ActionBar", "BarStanceFade", "Enable Fade for Stance Bar", "Allows the Stance Bar to fade based on the specified conditions", UpdateABFaderState)

	Window:CreateSection("ActionBar Vehicle")
	Window:CreateSlider("ActionBar", "VehButtonSize", "Button Size", 20, 80, 1, nil, UpdateActionBarVehicleButton)

	Window:CreateSection("Toggles")
	Window:CreateSwitch("ActionBar", "EquipColor", "Equip Color", nil, UpdateActionbarHotkeys)
	Window:CreateSwitch("ActionBar", "Grid", "Actionbar Grid", nil, UpdateActionbarHotkeys)
	Window:CreateSwitch("ActionBar", "Hotkeys", L["Enable Hotkey"], nil, UpdateActionbarHotkeys)
	Window:CreateSwitch("ActionBar", "Macro", L["Enable Macro"], nil, UpdateActionbarHotkeys)
	Window:CreateSwitch("ActionBar", "KeyDown", newFeatureIcon .. "Cast on Key Press", "Cast spells and abilities on key press, not key release", UpdateActionbarHotkeys)
	Window:CreateSwitch("ActionBar", "ButtonLock", newFeatureIcon .. "Lock Action Bars", "Keep your action bar layout locked in place to prevent accidental reordering. To move a spell or ability while locked, hold the Shift key.", UpdateActionbarHotkeys)
	Window:CreateSwitch("ActionBar", "Cooldown", L["Show Cooldowns"])
	Window:CreateSwitch("ActionBar", "MicroMenu", L["Enable MicroBar"])
	Window:CreateSwitch("ActionBar", "FadeMicroMenu", L["Mouseover MicroBar"])
	Window:CreateSwitch("ActionBar", "OverrideWA", L["Enable OverrideWA"])
	Window:CreateSlider("ActionBar", "MmssTH", L["MMSSThreshold"], 60, 600, 1, L["MMSSThresholdTip"])
	Window:CreateSlider("ActionBar", "TenthTH", L["TenthThreshold"], 0, 60, 1, L["TenthThresholdTip"])

	Window:CreateSection("Fader Options")
	Window:CreateSwitch("ActionBar", "BarFadeGlobal", "Enable Global Fade", "Enables fading on all action bars globally when certain conditions are met.")
	Window:CreateSlider("ActionBar", "BarFadeAlpha", "Fade Alpha", 0, 1, 0.1, "Set the transparency level of the bars when they are faded. 0 = fully transparent, 1 = fully visible.", SetABFaderState)
	Window:CreateSlider("ActionBar", "BarFadeDelay", "Fade Delay", 0, 3, 0.1, "The amount of time (in seconds) before the bars start to fade after the conditions are met.")
	Window:CreateSwitch("ActionBar", "BarFadeCombat", "Fade Out of Combat", "Fades the action bars when the player is out of combat.")
	Window:CreateSwitch("ActionBar", "BarFadeTarget", "Fade without Target", "Fades the bars when the player has no target selected.")
	Window:CreateSwitch("ActionBar", "BarFadeCasting", "Fade While Casting", "Keeps the bars visible while casting or channeling spells.")
	Window:CreateSwitch("ActionBar", "BarFadeHealth", "Fade on Full Health", "Fades the bars when the player is at full health.")
	Window:CreateSwitch("ActionBar", "BarFadeVehicle", "Fade in Vehicle", "Fades the bars while in a vehicle UI.")
end

local Announcements = function(self)
	local Window = self:CreateWindow(L["Announcements"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Announcements", "ItemAlert", L["Announce Spells And Items"], "Alerts the group when specific spells or items are used.")
	Window:CreateSwitch("Announcements", "PullCountdown", L["Announce Pull Countdown (/pc #)"], "Announces the pull countdown timer to your group or raid.")
	Window:CreateSwitch("Announcements", "ResetInstance", L["Alert Group After Instance Resetting"], "Notifies the group when the instance is reset.")

	Window:CreateSection(L["Combat"])
	Window:CreateSwitch("Announcements", "SaySapped", L["Announce When Sapped"], "Automatically announces in chat when you are sapped in PvP.")
	Window:CreateSwitch("Announcements", "KillingBlow", L["Show Your Killing Blow Info"], "Displays a notification when you land a killing blow.")
	Window:CreateSwitch("Announcements", "PvPEmote", L["Auto Emote On Your Killing Blow"], "Automatically performs an emote when you land a killing blow in PvP.")
	Window:CreateSwitch("Announcements", "HealthAlert", L["Announce When Low On Health"], "Alerts when your health drops below a critical threshold.")
	Window:CreateSwitch("Announcements", "KeystoneAlert", newFeatureIcon .. "Announce When New Mythic Key Is Obtained", "Notifies you and your group when you receive a new Mythic+ keystone.")

	Window:CreateSection(INTERRUPT)
	Window:CreateSwitch("Announcements", "InterruptAlert", enableTextColor .. L["Announce Interrupts"], "Announces when you successfully interrupt a spell.", UpdateInterruptAlert)
	Window:CreateSwitch("Announcements", "DispellAlert", enableTextColor .. L["Announce Dispels"], "Announces when you successfully dispel an effect.", UpdateInterruptAlert)
	Window:CreateSwitch("Announcements", "BrokenAlert", enableTextColor .. L["Announce Broken Spells"], "Alerts the group when a spell is broken (e.g., crowd control spells).", UpdateInterruptAlert)
	Window:CreateSwitch("Announcements", "OwnInterrupt", L["Only Announce Own Interrupts"], "Limits interrupt announcements to only those you perform.")
	Window:CreateSwitch("Announcements", "OwnDispell", L["Only Announce Own Dispels"], "Limits dispel announcements to only those you perform.")
	Window:CreateSwitch("Announcements", "InstAlertOnly", L["Announce Only In Instances"], "Restricts announcements to dungeons, raids, and other instances.", UpdateInterruptAlert)
	Window:CreateDropdown("Announcements", "AlertChannel", L["Announce Interrupts To Specified Chat Channel"], nil, "Select the chat channel where interrupt and dispel alerts will be sent.")

	Window:CreateSection(L["QuestNotifier"])
	Window:CreateSwitch("Announcements", "QuestNotifier", enableTextColor .. L["Enable QuestNotifier"], "Enables notifications related to quest progress and completion.")
	Window:CreateSwitch("Announcements", "OnlyCompleteRing", L["Only Play Complete Quest Sound"], "Plays a sound only when a quest is fully completed.")
	Window:CreateSwitch("Announcements", "QuestProgress", L["Alert QuestProgress In Chat"], "Sends quest progress updates to chat.")

	Window:CreateSection(L["Rare Alert"])
	Window:CreateSwitch("Announcements", "RareAlert", enableTextColor .. L["Enable Event & Rare Alerts"], "Enables alerts for nearby rare creatures and events.")
	Window:CreateSwitch("Announcements", "AlertInWild", L["Don't Alert In Instances"], "Prevents rare alerts from triggering inside instances.")
	Window:CreateSwitch("Announcements", "AlertInChat", L["Print Alerts In Chat"], "Prints alerts for rare events and creatures in the chat window.")
end

local Automation = function(self)
	local Window = self:CreateWindow(L["Automation"])

	Window:CreateSection("Invite Management")
	Window:CreateSwitch("Automation", "AutoInvite", L["Accept Invites From Friends & Guild Members"], "Automatically accepts group invitations from friends or guild members.")
	Window:CreateSwitch("Automation", "AutoDeclineDuels", L["Decline PvP Duels"], "Automatically declines all PvP duel requests.")
	Window:CreateSwitch("Automation", "AutoDeclinePetDuels", L["Decline Pet Duels"], "Automatically declines all pet battle duel requests.")
	Window:CreateSwitch("Automation", "AutoPartySync", L["Accept PartySync From Friends & Guild Members"], "Automatically accepts Party Sync requests from friends or guild members.")
	Window:CreateEditBox("Automation", "WhisperInvite", L["Auto Accept Invite Keyword"], "Enter a keyword that will trigger automatic acceptance of invites sent via whispers.")

	Window:CreateSection("Auto-Resurrect Options")
	Window:CreateSwitch("Automation", "AutoResurrect", L["Auto Accept Resurrect Requests"], "Automatically accepts resurrection requests during combat or in dungeons.")
	Window:CreateSwitch("Automation", "AutoResurrectThank", L["Say 'Thank You' When Resurrected"], "Sends a 'Thank you' message to the player who resurrects you.")

	Window:CreateSection("Auto-Reward Options")
	Window:CreateSwitch("Automation", "AutoReward", L["Auto Select Quest Rewards Best Value"], "Automatically selects the highest value quest reward.")

	Window:CreateSection("Miscellaneous Options")
	Window:CreateSwitch("Automation", "AutoCollapse", L["Auto Collapse Objective Tracker"], "Automatically collapses the objective tracker when entering an instance.")
	Window:CreateSwitch("Automation", "AutoGoodbye", L["Say Goodbye After Dungeon Completion"], "Automatically says 'Goodbye' to the group when the dungeon is completed.")
	Window:CreateSwitch("Automation", "AutoKeystone", newFeatureIcon .. L["Auto Place Mythic Keystones"], "Automatically places your highest available Mythic Keystone in the dungeon keystone slot.")
	Window:CreateSwitch("Automation", "AutoOpenItems", L["Auto Open Items In Your Inventory"], "Automatically opens items in your inventory that contain loot.")
	Window:CreateSwitch("Automation", "AutoRelease", L["Auto Release in Battlegrounds & Arenas"], "Automatically releases your spirit upon death in battlegrounds or arenas.")
	Window:CreateSwitch("Automation", "AutoScreenshot", L["Auto Screenshot Achievements"], "Automatically takes a screenshot when you earn an achievement.")
	Window:CreateSwitch("Automation", "AutoSetRole", L["Auto Set Your Role In Groups"], "Automatically sets your role based on your class and specialization.")
	Window:CreateSwitch("Automation", "AutoSkipCinematic", L["Auto Skip All Cinematics/Movies"], "Automatically skips cinematics and movies during gameplay.")
	Window:CreateSwitch("Automation", "AutoSummon", L["Auto Accept Summon Requests"], "Automatically accepts summon requests from your group or raid.")
	Window:CreateSwitch("Automation", "NoBadBuffs", L["Automatically Remove Annoying Buffs"], "Automatically removes unwanted or annoying buffs.")
end

local Inventory = function(self)
	local Window = self:CreateWindow(L["Inventory"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Inventory", "Enable", enableTextColor .. L["Enable Inventory"])
	Window:CreateSwitch("Inventory", "AutoSell", L["Auto Vendor Grays"])

	Window:CreateSection("Bags")
	Window:CreateSwitch("Inventory", "BagsBindOnEquip", newFeatureIcon .. L["Display Bind Status"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "BagsItemLevel", L["Display Item Level"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "DeleteButton", L["Bags Delete Button"])
	Window:CreateSwitch("Inventory", "ReverseSort", L["Reverse the Sorting"], nil, UpdateBagSortOrder)
	Window:CreateSwitch("Inventory", "ShowNewItem", L["Show New Item Glow"])
	Window:CreateSwitch("Inventory", "UpgradeIcon", L["Show Upgrade Icon"])
	Window:CreateSlider("Inventory", "BagsPerRow", L["Bags Per Row"], 1, 20, 1, nil, updateBagAnchor)
	Window:CreateSlider("Inventory", "iLvlToShow", newFeatureIcon .. "ItemLevel Threshold", 1, 800, 1, "Functions only when filtering items with a lower item level. Separates items based on a specified item level threshold..")

	Window:CreateSection(BANK)
	Window:CreateSlider("Inventory", "BankPerRow", L["Bank Bags Per Row"], 1, 20, 1, nil, updateBagAnchor)

	Window:CreateSection(OTHER)
	Window:CreateSwitch("Inventory", "PetTrash", L["Pet Trash Currencies"], "In patch 9.1, you can buy 3 battle pets by using specific trash items. Keep this enabled, will sort these items into Collection Filter, and won't be sold by auto junk")
	Window:CreateDropdown("Inventory", "AutoRepair", L["Auto Repair Gear"])

	Window:CreateSection(FILTERS)
	Window:CreateSwitch("Inventory", "ItemFilter", L["Filter Items Into Categories"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterAOE", newFeatureIcon .. "Filter Warband BOE", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterAnima", L["Filter Anima Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterAzerite", "Filter Azerite Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterCollection", L["Filter Collection Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterConsumable", L["Filter Consumable Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterCustom", L["Filter Custom Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterEquipSet", L["Filter EquipSet"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterEquipment", L["Filter Equipment Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterGoods", L["Filter Goods Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterJunk", L["Filter Junk Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterLegendary", L["Filter Legendary Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterLower", newFeatureIcon .. L["Filter Lower Itemlevel"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterQuest", L["Filter Quest Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterStone", "Filter Primordial Stones", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "GatherEmpty", L["Gather Empty Slots Into One Button"], nil, UpdateBagStatus)

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Inventory", "BagsWidth", L["Bags Width"], 8, 16, 1, nil, updateBagSize)
	Window:CreateSlider("Inventory", "BankWidth", L["Bank Width"], 10, 18, 1, nil, updateBagSize)
	Window:CreateSlider("Inventory", "IconSize", L["Slot Icon Size"], 28, 40, 1, nil, updateBagSize)

	Window:CreateSection("Bag Bar")
	Window:CreateSwitch("Inventory", "BagBar", enableTextColor .. L["Enable Bagbar"])
	Window:CreateSwitch("Inventory", "JustBackpack", "Just Show Main Backpack")
	Window:CreateSlider("Inventory", "BagBarSize", "BagBar Size", 20, 34, 1)
	Window:CreateDropdown("Inventory", "GrowthDirection", "Growth Direction")
	Window:CreateDropdown("Inventory", "SortDirection", "Sort Direction")
end

local Auras = function(self)
	local Window = self:CreateWindow(L["Auras"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Auras", "Enable", enableTextColor .. L["Enable Auras"])
	Window:CreateSwitch("Auras", "HideBlizBuff", "Hide The Default BuffFrame")
	Window:CreateSwitch("Auras", "Reminder", L["Auras Reminder (Shout/Intellect/Poison)"])
	Window:CreateSwitch("Auras", "ReverseBuffs", L["Buffs Grow Right"])
	Window:CreateSwitch("Auras", "ReverseDebuffs", L["Debuffs Grow Right"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Auras", "BuffSize", L["Buff Icon Size"], 20, 40, 1)
	Window:CreateSlider("Auras", "BuffsPerRow", L["Buffs per Row"], 10, 20, 1)
	Window:CreateSlider("Auras", "DebuffSize", L["DeBuff Icon Size"], 20, 40, 1)
	Window:CreateSlider("Auras", "DebuffsPerRow", L["DeBuffs per Row"], 10, 16, 1)

	Window:CreateSection(TUTORIAL_TITLE47)
	Window:CreateSwitch("Auras", "Totems", enableTextColor .. L["Enable TotemBar"])
	Window:CreateSwitch("Auras", "VerticalTotems", L["Vertical TotemBar"], nil, UpdateTotemBar)
	Window:CreateSlider("Auras", "TotemSize", L["Totems IconSize"], 24, 60, 1, nil, UpdateTotemBar)
end

local AuraWatch = function(self)
	local Window = self:CreateWindow(L["AuraWatch"])

	Window:CreateSection(GENERAL)
	Window:CreateButton(L["AuraWatch GUI"], nil, nil, SetupAuraWatch)
	Window:CreateSwitch("AuraWatch", "Enable", enableTextColor .. L["Enable AuraWatch"])
	Window:CreateSwitch("AuraWatch", "ClickThrough", L["Disable AuraWatch Tooltip (ClickThrough)"], "If enabled, the icon would be uninteractable, you can't select or mouseover them.")
	Window:CreateSwitch("AuraWatch", "DeprecatedAuras", L["Track Auras From Previous Expansions"])
	Window:CreateSwitch("AuraWatch", "QuakeRing", L["Alert On M+ Quake"])
	Window:CreateSlider("AuraWatch", "IconScale", L["AuraWatch IconScale"], 0.8, 2, 0.1)
end

local Chat = function(self)
	local Window = self:CreateWindow(L["Chat"])

	-- General chat settings
	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Chat", "Enable", enableTextColor .. L["Enable Chat"])
	Window:CreateSwitch("Chat", "Lock", L["Lock Chat"])
	Window:CreateSwitch("Chat", "Background", L["Show Chat Background"], nil, ToggleChatBackground)
	Window:CreateSwitch("Chat", "OldChatNames", L["Use Default Channel Names"])

	-- Chat appearance
	Window:CreateSection("Appearance")
	Window:CreateSwitch("Chat", "Emojis", L["Show Emojis In Chat"] .. emojiExampleIcon)
	Window:CreateSwitch("Chat", "ChatItemLevel", L["Show ItemLevel on ChatFrames"])
	Window:CreateDropdown("Chat", "TimestampFormat", L["Custom Chat Timestamps"])

	-- Chat behavior
	Window:CreateSection("Behavior")
	Window:CreateSwitch("Chat", "Freedom", L["Disable Chat Language Filter"])
	Window:CreateSwitch("Chat", "ChatMenu", L["Show Chat Menu Buttons"])
	Window:CreateSwitch("Chat", "Sticky", L["Stick On Channel If Whispering"], nil, UpdateChatSticky)
	Window:CreateSwitch("Chat", "WhisperColor", L["Differ Whisper Colors"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Chat", "Height", L["Lock Chat Height"], 100, 500, 1, nil, UpdateChatSize)
	Window:CreateSlider("Chat", "Width", L["Lock Chat Width"], 200, 600, 1, nil, UpdateChatSize)
	Window:CreateSlider("Chat", "LogMax", L["Chat History Lines To Save"], 0, 500, 10)

	Window:CreateSection(L["Fading"])
	Window:CreateSwitch("Chat", "Fading", L["Fade Chat Text"])
	Window:CreateSlider("Chat", "FadingTimeVisible", L["Fading Chat Visible Time"], 5, 120, 1)
end

local DataText = function(self)
	local Window = self:CreateWindow(L["DataText"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("DataText", "Coords", L["Enable Positon Coords"])
	Window:CreateSwitch("DataText", "Friends", L["Enable Friends Info"])
	Window:CreateSwitch("DataText", "Gold", L["Enable Currency Info"])
	Window:CreateSwitch("DataText", "Guild", L["Enable Guild Info"])
	Window:CreateSwitch("DataText", "Latency", L["Enable Latency Info"])
	Window:CreateSwitch("DataText", "Location", L["Enable Minimap Location"])
	Window:CreateSwitch("DataText", "Spec", "Enable Specialization Info")
	Window:CreateSwitch("DataText", "System", L["Enable System Info"])
	Window:CreateSwitch("DataText", "Time", L["Enable Minimap Time"])

	-- Section: Icon Colors
	Window:CreateSection("Icon Colors")
	Window:CreateColorSelection("DataText", "IconColor", L["Color The Icons"])

	-- Section: Text Toggles
	Window:CreateSection("Text Toggles")
	Window:CreateSwitch("DataText", "HideText", L["Hide Icon Text"])
end

local General = function(self)
	local Window = self:CreateWindow(L["General"], true)

	-- Profiles
	Window:CreateSection("Profiles")
	local AddProfile = Window:CreateDropdown("General", "Profiles", L["Import Profiles From Other Characters"])
	AddProfile.Menu:HookScript("OnHide", GUI.SetProfile)

	-- Toggles
	Window:CreateSection(GENERAL)
	Window:CreateSwitch("General", "MinimapIcon", "Enable Minimap Icon", nil, toggleMinimapIcon)
	Window:CreateSwitch("General", "MoveBlizzardFrames", L["Move Blizzard Frames"])
	Window:CreateSwitch("General", "NoErrorFrame", L["Disable Blizzard Error Frame Combat"])
	Window:CreateSwitch("General", "NoTutorialButtons", L["Disable 'Some' Blizzard Tutorials"])

	Window:CreateDropdown("General", "GlowMode", "Button Glow Mode")

	-- Border Style
	Window:CreateDropdown("General", "BorderStyle", L["Border Style"])

	-- Number Prefix Style
	Window:CreateDropdown("General", "NumberPrefixStyle", L["Number Prefix Style"])

	-- Smoothing Amount
	Window:CreateSlider("General", "SmoothAmount", "SmoothAmount", 0.1, 1, 0.01, "Setup healthbar smooth frequency for unitframes and nameplates. The lower the smoother.", updateSmoothingAmount)

	-- Scaling
	Window:CreateSection(L["Scaling"])
	Window:CreateSwitch("General", "AutoScale", L["Auto Scale"], L["AutoScaleTip"])
	Window:CreateSlider("General", "UIScale", L["Set UI scale"], 0.4, 1.15, 0.01, L["UIScaleTip"])

	-- Colors
	Window:CreateSection(COLORS)
	Window:CreateSwitch("General", "ColorTextures", L["Color 'Most' KkthnxUI Borders"])
	Window:CreateColorSelection("General", "TexturesColor", L["Textures Color"])

	-- Texture
	Window:CreateSection("Texture")
	Window:CreateDropdown("General", "Texture", L["Set General Texture"], "Texture")
end

local Loot = function(self)
	local Window = self:CreateWindow(L["Loot"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Loot", "Enable", enableTextColor .. L["Enable Loot"])
	Window:CreateSwitch("Loot", "GroupLoot", enableTextColor .. L["Enable Group Loot"], nil, UpdateGroupLoot)

	Window:CreateSection("Auto-Looting")
	Window:CreateSwitch("Loot", "FastLoot", L["Faster Auto-Looting"])

	Window:CreateSection("Auto-Confirm")
	Window:CreateSwitch("Loot", "AutoConfirm", L["Auto Confirm Loot Dialogs"])
	Window:CreateSwitch("Loot", "AutoGreed", L["Auto Greed Green Items"])
end

local Minimap = function(self)
	local Window = self:CreateWindow(L["Minimap"])

	-- General Section
	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Minimap", "Enable", enableTextColor .. L["Enable Minimap"])
	Window:CreateSwitch("Minimap", "Calendar", L["Show Minimap Calendar"], "If enabled, show minimap calendar icon on minimap.|nYou can simply click mouse middle button on minimap to toggle calendar even without this option.")

	-- Features Section
	Window:CreateSection("Features")
	Window:CreateSwitch("Minimap", "EasyVolume", newFeatureIcon .. L["EasyVolume"], L["EasyVolumeTip"])
	Window:CreateSwitch("Minimap", "MailPulse", newFeatureIcon .. L["Pulse Minimap Mail"])
	Window:CreateSwitch("Minimap", "QueueStatusText", newFeatureIcon .. L["QueueStatus"])
	Window:CreateSwitch("Minimap", "ShowRecycleBin", L["Show Minimap Button Collector"])

	-- Recycle Bin Section
	Window:CreateSection("Recycle Bin")
	Window:CreateDropdown("Minimap", "RecycleBinPosition", L["Set RecycleBin Positon"])

	-- Blip Section
	Window:CreateSection("Blip")
	Window:CreateDropdown("Minimap", "BlipTexture", L["Blip Icon Styles"], nil, nil, UpdateBlipTextures)

	-- Location Section
	Window:CreateSection("Location")
	Window:CreateDropdown("Minimap", "LocationText", L["Location Text Style"])

	-- Size Section
	Window:CreateSection("Size")
	Window:CreateSlider("Minimap", "Size", L["Minimap Size"], 120, 300, 1)
end

local Misc = function(self)
	local Window = self:CreateWindow(L["Misc"])

	-- General Section
	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Misc", "ColorPicker", L["Enhanced Color Picker"])
	Window:CreateSwitch("Misc", "EasyMarking", L["EasyMarking by Ctrl + LeftClick"])
	Window:CreateSwitch("Misc", "HideBanner", L["Hide RaidBoss EmoteFrame"])
	Window:CreateSwitch("Misc", "HideBossEmote", L["Hide BossBanner"])
	Window:CreateSwitch("Misc", "ImprovedStats", L["Display Character Frame Full Stats"])
	Window:CreateSwitch("Misc", "NoTalkingHead", L["Remove And Hide The TalkingHead Frame"])
	Window:CreateSwitch("Misc", "ShowWowHeadLinks", L["Show Wowhead Links Above Questlog Frame"])
	Window:CreateSwitch("Misc", "SlotDurability", L["Show Slot Durability %"])

	Window:CreateSection("Camera")
	Window:CreateSlider("Misc", "MaxCameraZoom", newFeatureIcon .. "Max Camera Zoom Level", 1, 2.6, 0.1, nil, UpdateMaxZoomLevel)

	Window:CreateSection("Trade Skill")
	Window:CreateSwitch("Misc", "TradeTabs", L["Add Spellbook-Like Tabs On TradeSkillFrame"])

	-- Social Section
	Window:CreateSection("Social")
	Window:CreateSwitch("Misc", "AFKCamera", L["AFK Camera"])
	Window:CreateSwitch("Misc", "EnhancedFriends", L["Enhanced Colors (Friends/Guild +)"])
	Window:CreateSwitch("Misc", "MuteSounds", "Mute Various Annoying Sounds In-Game")
	Window:CreateSwitch("Misc", "ParagonEnable", L["Add Paragon Info on ReputationFrame"], L["ParagonReputationTip"])

	-- Mail Section
	Window:CreateSection("Mail")
	Window:CreateSwitch("Misc", "EnhancedMail", "Add 'Postal' Like Feaures To The Mailbox")

	-- Questing Section
	Window:CreateSection("Questing")
	Window:CreateSwitch("Misc", "ExpRep", "Display Exp/Rep Bar (Minimap)")
	Window:CreateSwitch("Misc", "QuestTool", "Add Tips For Some Quests And World Quests")

	-- Mythic+ Section
	Window:CreateSection("Mythic+")
	Window:CreateSwitch("Misc", "MDGuildBest", L["Show Mythic+ GuildBest"])

	-- Raid Tool Section
	Window:CreateSection("Raid Tool")
	Window:CreateSwitch("Misc", "RaidTool", L["Show Raid Utility Frame"])
	Window:CreateSwitch("Misc", "RMRune", "RMRune - Add Info")
	Window:CreateEditBox("Misc", "DBMCount", "DBMCount - Add Info")
	Window:CreateSlider("Misc", "MarkerBarSize", "Marker Bar Size - Add Info", 20, 40, 1, nil, UpdateMarkerGrid)
	Window:CreateDropdown("Misc", "ShowMarkerBar", L["World Markers Bar"], nil, nil, UpdateMarkerGrid)

	-- Misc Section
	Window:CreateSection("Misc")
	if C["Misc"].ItemLevel then
		Window:CreateSwitch("Misc", "GemEnchantInfo", L["Character/Inspect Gem/Enchant Info"])
	end
	Window:CreateSwitch("Misc", "QuickJoin", newFeatureIcon .. L["QuickJoin"], L["QuickJoinTip"])
	Window:CreateSwitch("Misc", "ItemLevel", L["Show Character/Inspect ItemLevel Info"])
end

local Nameplate = function(self)
	local Window = self:CreateWindow(L["Nameplate"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Nameplate", "Enable", enableTextColor .. L["Enable Nameplates"])
	Window:CreateSwitch("Nameplate", "ClassIcon", L["Show Enemy Class Icons"])
	Window:CreateSwitch("Nameplate", "ColoredTarget", "Colored Targeted Nameplate", "If enabled, this will color your targeted nameplate|nIts priority is higher than custom/threat colors")
	Window:CreateSwitch("Nameplate", "CustomUnitColor", L["Colored Custom Units"])
	Window:CreateSwitch("Nameplate", "FriendlyCC", L["Show Friendly ClassColor"])
	Window:CreateSwitch("Nameplate", "FullHealth", L["Show Health Value"], nil, refreshNameplates)
	Window:CreateSwitch("Nameplate", "HostileCC", L["Show Hostile ClassColor"])
	Window:CreateSwitch("Nameplate", "InsideView", L["Interacted Nameplate Stay Inside"])
	Window:CreateSwitch("Nameplate", "NameOnly", L["Show Only Names For Friendly"])
	Window:CreateSwitch("Nameplate", "NameplateClassPower", "Show Nameplate Class Power")
	Window:CreateDropdown("Nameplate", "AuraFilter", L["Auras Filter Style"], nil, nil, refreshNameplates)
	Window:CreateDropdown("Nameplate", "TargetIndicator", L["TargetIndicator Style"], nil, nil, refreshNameplates)
	Window:CreateDropdown("Nameplate", "TargetIndicatorTexture", "TargetIndicator Texture") -- Needs Locale
	Window:CreateEditBox("Nameplate", "CustomUnitList", L["Custom UnitColor List"], L["CustomUnitTip"], UpdateCustomUnitList)
	Window:CreateEditBox("Nameplate", "PowerUnitList", L["Custom PowerUnit List"], L["CustomUnitTip"], UpdatePowerUnitList)

	Window:CreateSection("Castbar")
	Window:CreateSwitch("Nameplate", "CastTarget", "Show Nameplate Target Of Casting Spell")
	Window:CreateSwitch("Nameplate", "CastbarGlow", "Force Crucial Spells To Glow")

	Window:CreateSection("Threat")
	Window:CreateSwitch("Nameplate", "DPSRevertThreat", L["Revert Threat Color If Not Tank"])
	Window:CreateSwitch("Nameplate", "TankMode", L["Force TankMode Colored"])

	Window:CreateSection("Miscellaneous")
	Window:CreateSwitch("Nameplate", "AKSProgress", L["Show AngryKeystones Progress"])
	Window:CreateSwitch("Nameplate", "PlateAuras", "Target Nameplate Auras", nil, refreshNameplates)
	Window:CreateSwitch("Nameplate", "QuestIndicator", L["Quest Progress Indicator"])
	Window:CreateSwitch("Nameplate", "Smooth", L["Smooth Bars Transition"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Nameplate", "AuraSize", L["Auras Size"], 18, 40, 1, nil, refreshNameplates)
	-- Window:CreateSlider("Nameplate", "Distance", L["Nameplete MaxDistance"], 10, 100, 1)
	Window:CreateSlider("Nameplate", "ExecuteRatio", L["Unit Execute Ratio"], 0, 90, 1, L["ExecuteRatioTip"])
	Window:CreateSlider("Nameplate", "HealthTextSize", L["HealthText FontSize"], 8, 16, 1, nil, refreshNameplates)
	Window:CreateSlider("Nameplate", "MaxAuras", L["Max Auras"], 4, 8, 1, nil, refreshNameplates)
	Window:CreateSlider("Nameplate", "MinAlpha", L["Non-Target Nameplate Alpha"], 0.1, 1, 0.1)
	Window:CreateSlider("Nameplate", "MinScale", L["Non-Target Nameplate Scale"], 0.1, 3, 0.1)
	Window:CreateSlider("Nameplate", "NameTextSize", L["NameText FontSize"], 8, 16, 1, nil, refreshNameplates)
	Window:CreateSlider("Nameplate", "PlateHeight", L["Nameplate Height"], 6, 28, 1, nil, refreshNameplates)
	Window:CreateSlider("Nameplate", "PlateWidth", L["Nameplate Width"], 80, 240, 1, nil, refreshNameplates)
	Window:CreateSlider("Nameplate", "VerticalSpacing", L["Nameplate Vertical Spacing"], 0.5, 2.5, 0.1)
	Window:CreateSlider("Nameplate", "SelectedScale", "SelectedScale", 1, 1.4, 0.1)

	Window:CreateSection("Player Nameplate Toggles")
	Window:CreateSwitch("Nameplate", "ShowPlayerPlate", enableTextColor .. L["Enable Personal Resource"], nil, togglePlayerPlate)
	Window:CreateSwitch("Nameplate", "ClassAuras", L["Track Personal Class Auras"])
	Window:CreateSwitch("Nameplate", "PPGCDTicker", L["Enable GCD Ticker"])
	Window:CreateSwitch("Nameplate", "PPHideOOC", L["Only Visible in Combat"])
	Window:CreateSwitch("Nameplate", "PPPowerText", L["Show Power Value"], nil, togglePlatePower)

	Window:CreateSection("Player Nameplate Values")
	Window:CreateSlider("Nameplate", "PPHeight", L["Classpower/Healthbar Height"], 4, 10, 1, nil, refreshNameplates)
	Window:CreateSlider("Nameplate", "PPIconSize", L["PlayerPlate IconSize"], 20, 40, 1)
	Window:CreateSlider("Nameplate", "PPPHeight", L["PlayerPlate Powerbar Height"], 4, 10, 1, nil, refreshNameplates)

	Window:CreateSection(COLORS)
	Window:CreateColorSelection("Nameplate", "CustomColor", L["Custom Color"])
	Window:CreateColorSelection("Nameplate", "InsecureColor", L["Insecure Color"])
	Window:CreateColorSelection("Nameplate", "OffTankColor", L["Off-Tank Color"])
	Window:CreateColorSelection("Nameplate", "SecureColor", L["Secure Color"])
	Window:CreateColorSelection("Nameplate", "TargetColor", "Selected Target Coloring")
	Window:CreateColorSelection("Nameplate", "TargetIndicatorColor", L["TargetIndicator Color"])
	Window:CreateColorSelection("Nameplate", "TransColor", L["Transition Color"])
end

local Skins = function(self)
	local Window = self:CreateWindow(L["Skins"])

	Window:CreateSection("Blizzard Skins")
	Window:CreateSwitch("Skins", "BlizzardFrames", L["Skin Some Blizzard Frames & Objects"])
	Window:CreateSwitch("Skins", "TalkingHeadBackdrop", L["TalkingHead Skin"])
	Window:CreateSwitch("Skins", "ChatBubbles", L["ChatBubbles Skin"])
	Window:CreateSlider("Skins", "ChatBubbleAlpha", L["ChatBubbles Background Alpha"], 0, 1, 0.1, nil, UpdateChatBubble)

	Window:CreateSection("AddOn Skins")
	Window:CreateSwitch("Skins", "Bartender4", L["Bartender4 Skin"])
	Window:CreateSwitch("Skins", "BigWigs", L["BigWigs Skin"])
	Window:CreateSwitch("Skins", "ButtonForge", L["ButtonForge Skin"])
	Window:CreateSwitch("Skins", "ChocolateBar", L["ChocolateBar Skin"])
	Window:CreateSwitch("Skins", "DeadlyBossMods", L["Deadly Boss Mods Skin"])
	Window:CreateSwitch("Skins", "Details", L["Details Skin"])
	Window:CreateSwitch("Skins", "Dominos", L["Dominos Skin"])
	Window:CreateSwitch("Skins", "RareScanner", L["RareScanner Skin"])
	Window:CreateSwitch("Skins", "WeakAuras", L["WeakAuras Skin"])
	Window:CreateButton(L["Reset Details"], nil, nil, ResetDetails)

	Window:CreateSection("Font Tweaks")
	Window:CreateSlider("Skins", "QuestFontSize", L["Adjust QuestFont Size"], 10, 30, 1, nil, UpdateQuestFontSize)
	Window:CreateSlider("Skins", "ObjectiveFontSize", newFeatureIcon .. "Adjust ObjectiveFont Size", 10, 30, 1, nil, UpdateObjectiveFontSize)
end

local Tooltip = function(self)
	local Window = self:CreateWindow(L["Tooltip"])

	-- General section
	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Tooltip", "Enable", enableTextColor .. "Enable Tooltip")
	Window:CreateSwitch("Tooltip", "CombatHide", L["Hide Tooltip in Combat"])
	Window:CreateSwitch("Tooltip", "Icons", L["Item Icons"])
	Window:CreateSwitch("Tooltip", "ShowIDs", L["Show Tooltip IDs"])

	-- Appearance section
	Window:CreateSection("Appearance")
	Window:CreateSwitch("Tooltip", "ClassColor", L["Quality Color Border"])
	Window:CreateSwitch("Tooltip", "FactionIcon", L["Show Faction Icon"])
	Window:CreateSwitch("Tooltip", "HideJunkGuild", L["Abbreviate Guild Names"])
	Window:CreateSwitch("Tooltip", "HideRank", L["Hide Guild Rank"])
	Window:CreateSwitch("Tooltip", "HideRealm", L["Show realm name by SHIFT"])
	Window:CreateSwitch("Tooltip", "HideTitle", L["Hide Player Title"])
	Window:CreateDropdown("Tooltip", "TipAnchor", "Tooltip Anchor")

	-- Advanced section
	Window:CreateSection("Advanced")
	Window:CreateSwitch("Tooltip", "LFDRole", L["Show Roles Assigned Icon"])
	Window:CreateSwitch("Tooltip", "SpecLevelByShift", L["Show Spec/ItemLevel by SHIFT"])
	Window:CreateSwitch("Tooltip", "TargetBy", L["Show Player Targeted By"])
	Window:CreateDropdown("Tooltip", "CursorMode", L["Follow Cursor"])

	-- RaiderIO section (only shown if RaiderIO is not installed)
	if not K.CheckAddOnState("RaiderIO") then
		Window:CreateSection("RaiderIO")
		Window:CreateSwitch("Tooltip", "MDScore", "Show Mythic+ Rating")
	end
end

local function updateUFTextScale() -- WIP
	K:GetModule("Unitframes"):UpdateTextScale()
end

local Unitframe = function(self)
	local Window = self:CreateWindow(L["Unitframe"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Unitframe", "Enable", enableTextColor .. L["Enable Unitframes"])
	Window:CreateSwitch("Unitframe", "CastClassColor", L["Class Color Castbars"])
	Window:CreateSwitch("Unitframe", "CastReactionColor", L["Reaction Color Castbars"])
	Window:CreateSwitch("Unitframe", "ClassResources", L["Show Class Resources"])
	-- Window:CreateSwitch("Unitframe", "CombatFade", L["Fade Unitframes"]) -- Broken. Portraits do not obey? Blizzard issue?
	Window:CreateSwitch("Unitframe", "DebuffHighlight", L["Show Health Debuff Highlight"])
	Window:CreateSwitch("Unitframe", "PvPIndicator", L["Show PvP Indicator on Player / Target"])
	Window:CreateSwitch("Unitframe", "Range", "Fade Unitframes When NOT In Unit Range")
	Window:CreateSwitch("Unitframe", "ResurrectSound", L["Sound Played When You Are Resurrected"])
	Window:CreateSwitch("Unitframe", "ShowHealPrediction", L["Show HealPrediction Statusbars"])
	Window:CreateSwitch("Unitframe", "Smooth", L["Smooth Bars"])
	Window:CreateSwitch("Unitframe", "Stagger", L["Show |CFF00FF96Monk|r Stagger Bar"])

	Window:CreateSlider("Unitframe", "AllTextScale", "(TEST) Scale All Unitframe Texts", 0.8, 1.5, 0.05, nil, updateUFTextScale) -- WIP

	Window:CreateSection("Combat Text")
	Window:CreateSwitch("Unitframe", "CombatText", enableTextColor .. L["Enable Simple CombatText"])
	Window:CreateSwitch("Unitframe", "AutoAttack", L["Show AutoAttack Damage"])
	Window:CreateSwitch("Unitframe", "FCTOverHealing", L["Show Full OverHealing"])
	Window:CreateSwitch("Unitframe", "HotsDots", L["Show Hots and Dots"])
	Window:CreateSwitch("Unitframe", "PetCombatText", L["Pet's Healing/Damage"])

	Window:CreateSection(PLAYER)
	Window:CreateSwitch("Unitframe", "AdditionalPower", L["Show Additional Mana Power (|CFFFF7D0ADruid|r, |CFFFFFFFFPriest|r, |CFF0070DEShaman|r)"])
	Window:CreateSwitch("Unitframe", "CastbarLatency", L["Show Castbar Latency"])
	Window:CreateSwitch("Unitframe", "GlobalCooldown", "Show Global Cooldown Spark")
	Window:CreateSwitch("Unitframe", "PlayerBuffs", L["Show Player Frame Buffs"])
	Window:CreateSwitch("Unitframe", "PlayerCastbar", L["Enable Player CastBar"])
	Window:CreateSwitch("Unitframe", "PlayerCastbarIcon", L["Enable Player CastBar"] .. " Icon")
	Window:CreateSwitch("Unitframe", "PlayerDebuffs", L["Show Player Frame Debuffs"])
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		Window:CreateSwitch("Unitframe", "ShowPlayerLevel", L["Show Player Frame Level"])
	end
	Window:CreateSwitch("Unitframe", "SwingBar", L["Unitframe Swingbar"])
	Window:CreateSwitch("Unitframe", "SwingTimer", L["Unitframe Swingbar Timer"])
	Window:CreateSwitch("Unitframe", "OffOnTop", "Offhand timer on top")
	Window:CreateSlider("Unitframe", "SwingWidth", "Unitframe SwingBar Width", 50, 1000, 1)
	Window:CreateSlider("Unitframe", "SwingHeight", "Unitframe SwingBar Height", 1, 50, 1)

	Window:CreateSlider("Unitframe", "PlayerBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, nil, UpdatePlayerBuffs)
	Window:CreateSlider("Unitframe", "PlayerDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, nil, UpdatePlayerDebuffs)
	Window:CreateSlider("Unitframe", "PlayerPowerHeight", "Player Power Bar Height", 10, 40, 1, nil, UpdateUnitPlayerSize)
	Window:CreateSlider("Unitframe", "PlayerHealthHeight", L["Player Frame Height"], 20, 75, 1, nil, UpdateUnitPlayerSize)
	Window:CreateSlider("Unitframe", "PlayerHealthWidth", L["Player Frame Width"], 100, 300, 1, nil, UpdateUnitPlayerSize)
	Window:CreateSlider("Unitframe", "PlayerCastbarHeight", L["Player Castbar Height"], 20, 40, 1)
	Window:CreateSlider("Unitframe", "PlayerCastbarWidth", L["Player Castbar Width"], 100, 800, 1)

	Window:CreateSection(TARGET)
	Window:CreateSwitch("Unitframe", "OnlyShowPlayerDebuff", L["Only Show Your Debuffs"])
	Window:CreateSwitch("Unitframe", "TargetBuffs", L["Show Target Frame Buffs"])
	Window:CreateSwitch("Unitframe", "TargetCastbar", L["Enable Target CastBar"])
	Window:CreateSwitch("Unitframe", "TargetCastbarIcon", L["Enable Target CastBar"] .. " Icon")
	Window:CreateSwitch("Unitframe", "TargetDebuffs", L["Show Target Frame Debuffs"])
	Window:CreateSlider("Unitframe", "TargetBuffsPerRow", newFeatureIcon .. L["Number of Buffs Per Row"], 4, 10, 1, nil, UpdateTargetBuffs)
	Window:CreateSlider("Unitframe", "TargetDebuffsPerRow", newFeatureIcon .. L["Number of Debuffs Per Row"], 4, 10, 1, nil, UpdateTargetDebuffs)
	Window:CreateSlider("Unitframe", "TargetPowerHeight", "Target Power Bar Height", 10, 40, 1, nil, UpdateUnitTargetSize)
	Window:CreateSlider("Unitframe", "TargetHealthHeight", L["Target Frame Height"], 20, 75, 1, nil, UpdateUnitTargetSize)
	Window:CreateSlider("Unitframe", "TargetHealthWidth", L["Target Frame Width"], 100, 300, 1, nil, UpdateUnitTargetSize)
	Window:CreateSlider("Unitframe", "TargetCastbarHeight", L["Target Castbar Height"], 20, 40, 1)
	Window:CreateSlider("Unitframe", "TargetCastbarWidth", L["Target Castbar Width"], 100, 800, 1)

	Window:CreateSection(PET)
	Window:CreateSwitch("Unitframe", "HidePet", "Hide Pet Frame")
	Window:CreateSwitch("Unitframe", "HidePetLevel", L["Hide Pet Level"])
	Window:CreateSwitch("Unitframe", "HidePetName", L["Hide Pet Name"])
	Window:CreateSlider("Unitframe", "PetHealthHeight", L["Pet Frame Height"], 10, 50, 1)
	Window:CreateSlider("Unitframe", "PetHealthWidth", L["Pet Frame Width"], 80, 300, 1)
	Window:CreateSlider("Unitframe", "PetPowerHeight", L["Pet Power Bar"], 10, 50, 1)

	Window:CreateSection("Target Of Target")
	Window:CreateSwitch("Unitframe", "HideTargetofTarget", L["Hide TargetofTarget Frame"])
	Window:CreateSwitch("Unitframe", "HideTargetOfTargetLevel", L["Hide TargetofTarget Level"])
	Window:CreateSwitch("Unitframe", "HideTargetOfTargetName", L["Hide TargetofTarget Name"])
	Window:CreateSlider("Unitframe", "TargetTargetHealthHeight", L["Target of Target Frame Height"], 10, 50, 1)
	Window:CreateSlider("Unitframe", "TargetTargetHealthWidth", L["Target of Target Frame Width"], 80, 300, 1)
	Window:CreateSlider("Unitframe", "TargetTargetPowerHeight", "Target of Target Power Height", 10, 50, 1)

	Window:CreateSection(FOCUS)
	Window:CreateSlider("Unitframe", "FocusPowerHeight", "Focus Power Bar Height", 10, 40, 1, nil, UpdateUnitFocusSize)
	Window:CreateSlider("Unitframe", "FocusHealthHeight", L["Focus Frame Height"], 20, 75, 1, nil, UpdateUnitFocusSize)
	Window:CreateSlider("Unitframe", "FocusHealthWidth", L["Focus Frame Width"], 100, 300, 1, nil, UpdateUnitFocusSize)
	Window:CreateSwitch("Unitframe", "FocusBuffs", "Show Focus Frame Buffs")
	Window:CreateSwitch("Unitframe", "FocusCastbar", "Enable Focus CastBar")
	Window:CreateSwitch("Unitframe", "FocusCastbarIcon", "Enable Focus CastBar" .. " Icon")
	Window:CreateSwitch("Unitframe", "FocusDebuffs", "Show Focus Frame Debuffs")

	Window:CreateSection("Focus Target")
	Window:CreateSwitch("Unitframe", "HideFocusTarget", "Hide Focus Target Frame")
	Window:CreateSwitch("Unitframe", "HideFocusTargetLevel", "Hide Focus Target Level")
	Window:CreateSwitch("Unitframe", "HideFocusTargetName", "Hide Focus Target Name")
	Window:CreateSlider("Unitframe", "FocusTargetHealthHeight", "Focus Target Frame Height", 10, 50, 1)
	Window:CreateSlider("Unitframe", "FocusTargetHealthWidth", "Focus Target Frame Width", 80, 300, 1)
	Window:CreateSlider("Unitframe", "FocusTargetPowerHeight", "Focus Target Power Height", 10, 50, 1)

	Window:CreateSection("Unitframe Misc")
	Window:CreateDropdown("Unitframe", "HealthbarColor", L["Health Color Format"])
	Window:CreateDropdown("Unitframe", "PortraitStyle", L["Unitframe Portrait Style"], nil, "It is highly recommanded to NOT use 3D portraits as you could see a drop in FPS")
end

local Party = function(self)
	local Window = self:CreateWindow(L["Party"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Party", "Enable", enableTextColor .. L["Enable Party"])
	Window:CreateSwitch("Party", "ShowBuffs", L["Show Party Buffs"])
	Window:CreateSwitch("Party", "ShowHealPrediction", L["Show HealPrediction Statusbars"])
	Window:CreateSwitch("Party", "ShowPartySolo", "Show Party Frames While Solo")
	Window:CreateSwitch("Party", "ShowPet", L["Show Party Pets"])
	Window:CreateSwitch("Party", "ShowPlayer", L["Show Player In Party"])
	Window:CreateSwitch("Party", "Smooth", L["Smooth Bar Transition"])
	Window:CreateSwitch("Party", "TargetHighlight", L["Show Highlighted Target"])

	Window:CreateSection("Party Castbars")
	Window:CreateSwitch("Party", "Castbars", L["Show Castbars"])
	Window:CreateSwitch("Party", "CastbarIcon", L["Show Castbars"] .. " Icon")

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Party", "HealthHeight", "Party Frame Health Height", 20, 50, 1, nil, UpdateUnitPartySize)
	Window:CreateSlider("Party", "HealthWidth", "Party Frame Health Width", 120, 180, 1, nil, UpdateUnitPartySize)
	Window:CreateSlider("Party", "PowerHeight", "Party Frame Power Height", 10, 30, 1, nil, UpdateUnitPartySize)

	Window:CreateSection(COLORS)
	Window:CreateDropdown("Party", "HealthbarColor", L["Health Color Format"])
end

local Boss = function(self)
	local Window = self:CreateWindow(L["Boss"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Boss", "Enable", enableTextColor .. L["Enable Boss"], "Toggle Boss Module On/Off")
	Window:CreateSwitch("Boss", "Castbars", L["Show Castbars"])
	Window:CreateSwitch("Boss", "CastbarIcon", "Show Castbars Icon")
	Window:CreateSwitch("Boss", "Smooth", L["Smooth Bar Transition"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Boss", "HealthHeight", "Health Height", 20, 50, 1)
	Window:CreateSlider("Boss", "HealthWidth", "Health Width", 120, 180, 1)
	Window:CreateSlider("Boss", "PowerHeight", "Power Height", 10, 30, 1)
	Window:CreateSlider("Boss", "YOffset", "Vertical Offset From One Another" .. K.GreyColor .. "(54)|r", 40, 60, 1)

	Window:CreateSection(COLORS)
	Window:CreateDropdown("Boss", "HealthbarColor", L["Health Color Format"])
end

local Arena = function(self)
	local Window = self:CreateWindow(L["Arena"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Arena", "Enable", enableTextColor .. L["Enable Arena"], "Toggle Arena Module On/Off")
	Window:CreateSwitch("Arena", "Castbars", L["Show Castbars"])
	Window:CreateSwitch("Arena", "CastbarIcon", "Show Castbars Icon")
	Window:CreateSwitch("Arena", "Smooth", L["Smooth Bar Transition"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Arena", "HealthHeight", "Health Height", 20, 50, 1)
	Window:CreateSlider("Arena", "HealthWidth", "Health Width", 120, 180, 1)
	Window:CreateSlider("Arena", "PowerHeight", "Power Height", 10, 30, 1)
	Window:CreateSlider("Arena", "YOffset", "Vertical Offset From One Another" .. K.GreyColor .. "(54)|r", 40, 60, 1)

	Window:CreateSection(COLORS)
	Window:CreateDropdown("Arena", "HealthbarColor", L["Health Color Format"])
end

local Raid = function(self)
	local Window = self:CreateWindow(L["Raid"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("Raid", "Enable", enableTextColor .. L["Enable Raidframes"])
	Window:CreateSwitch("Raid", "HorizonRaid", L["Horizontal Raid Frames"])
	Window:CreateSwitch("Raid", "MainTankFrames", L["Show MainTank Frames"])
	Window:CreateSwitch("Raid", "PowerBarShow", "Toggle The visibility Of All Power Bars")
	Window:CreateSwitch("Raid", "ManabarShow", L["Show Manabars"])
	Window:CreateSwitch("Raid", "ReverseRaid", L["Reverse Raid Frame Growth"])
	Window:CreateSwitch("Raid", "ShowHealPrediction", L["Show HealPrediction Statusbars"])
	Window:CreateSwitch("Raid", "ShowNotHereTimer", L["Show Away/DND Status"])
	Window:CreateSwitch("Raid", "ShowRaidSolo", "Show Raid Frames While Solo")
	Window:CreateSwitch("Raid", "ShowTeamIndex", L["Show Group Number Team Index"])
	Window:CreateSwitch("Raid", "Smooth", L["Smooth Bar Transition"])
	Window:CreateSwitch("Raid", "TargetHighlight", L["Show Highlighted Target"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Raid", "Height", L["Raidframe Height"], 20, 100, 1, nil, UpdateUnitRaidSize)
	Window:CreateSlider("Raid", "NumGroups", L["Number Of Groups to Show"], 1, 8, 1)
	Window:CreateSlider("Raid", "Width", L["Raidframe Width"], 20, 100, 1, nil, UpdateUnitRaidSize)

	Window:CreateSection(COLORS)
	Window:CreateDropdown("Raid", "HealthbarColor", L["Health Color Format"])
	Window:CreateDropdown("Raid", "HealthFormat", L["Health Format"])

	Window:CreateSection("Raid Buffs")
	Window:CreateDropdown("Raid", "RaidBuffsStyle", "Select the buff style you want to use") -- Needs Locale

	if C["Raid"].RaidBuffsStyle.Value == "Standard" then
		Window:CreateDropdown("Raid", "RaidBuffs", "Enable buffs display & filtering") -- Needs Locale
		Window:CreateSwitch("Raid", "DesaturateBuffs", "Desaturate buffs that are not by me") -- Needs Locale
	elseif C["Raid"].RaidBuffsStyle.Value == "Aura Track" then
		Window:CreateSwitch("Raid", "AuraTrack", "Enable auras tracking module for healer (replace buffs)") -- Needs Locale
		Window:CreateSwitch("Raid", "AuraTrackIcons", "Use squared icons instead of status bars") -- Needs Locale
		Window:CreateSwitch("Raid", "AuraTrackSpellTextures", "Display icons texture on aura squares instead of colored squares") -- Needs Locale
		Window:CreateSlider("Raid", "AuraTrackThickness", "Thickness size of status bars in pixel", 2, 10, 1) -- Needs Locale
	end

	Window:CreateSection("Raid Debuffs")
	Window:CreateSwitch("Raid", "DebuffWatch", "Enable debuffs tracking (filtered auto by current gameplay (pvp or pve)") -- Needs Locale
	Window:CreateSwitch("Raid", "DebuffWatchDefault", "We have already a debuff tracking list for pve and pvp, use it?") -- Needs Locale
end

local WorldMap = function(self)
	local Window = self:CreateWindow(L["WorldMap"])

	Window:CreateSection(GENERAL)
	Window:CreateSwitch("WorldMap", "Coordinates", L["Show Player/Mouse Coordinates"])
	Window:CreateSwitch("WorldMap", "FadeWhenMoving", L["Fade Worldmap When Moving"])
	Window:CreateSwitch("WorldMap", "SmallWorldMap", L["Show Smaller Worldmap"])

	Window:CreateSection("WorldMap Reveal")
	Window:CreateSwitch("WorldMap", "MapRevealGlow", L["Map Reveal Shadow"], L["MapRevealTip"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("WorldMap", "AlphaWhenMoving", L["Alpha When Moving"], 0.1, 1, 0.01)
end

GUI:AddWidgets(ActionBar)
GUI:AddWidgets(Announcements)
GUI:AddWidgets(Arena)
GUI:AddWidgets(AuraWatch)
GUI:AddWidgets(Auras)
GUI:AddWidgets(Automation)
GUI:AddWidgets(Boss)
GUI:AddWidgets(Chat)
GUI:AddWidgets(DataText)
GUI:AddWidgets(General)
GUI:AddWidgets(Inventory)
GUI:AddWidgets(Loot)
GUI:AddWidgets(Minimap)
GUI:AddWidgets(Misc)
GUI:AddWidgets(Nameplate)
GUI:AddWidgets(Party)
GUI:AddWidgets(Raid)
GUI:AddWidgets(Skins)
GUI:AddWidgets(Tooltip)
GUI:AddWidgets(Unitframe)
GUI:AddWidgets(WorldMap)
