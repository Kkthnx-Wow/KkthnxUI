local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Installer")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local table_wipe = _G.table.wipe

local APPLY = _G.APPLY
local CHAT = _G.CHAT
local ChangeChatColor = _G.ChangeChatColor
local ChatFrame_AddChannel = _G.ChatFrame_AddChannel
local ChatFrame_AddMessageGroup = _G.ChatFrame_AddMessageGroup
local ChatFrame_RemoveAllMessageGroups = _G.ChatFrame_RemoveAllMessageGroups
local ChatFrame_RemoveChannel = _G.ChatFrame_RemoveChannel
local CreateFrame = _G.CreateFrame
local DEFAULT = _G.DEFAULT
local FCF_DockFrame = _G.FCF_DockFrame
local FCF_OpenNewWindow = _G.FCF_OpenNewWindow
local FCF_ResetChatWindows = _G.FCF_ResetChatWindows
local FCF_SetChatWindowFontSize = _G.FCF_SetChatWindowFontSize
local FCF_SetLocked = _G.FCF_SetLocked
local FCF_SetWindowName = _G.FCF_SetWindowName
local GENERAL = _G.GENERAL
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local PlaySound = _G.PlaySound
local SETTINGS = _G.SETTINGS
local SetCVar = _G.SetCVar
local TRADE = _G.TRADE
local ToggleChatColorNamesByClassGroup = _G.ToggleChatColorNamesByClassGroup
local UIErrorsFrame = _G.UIErrorsFrame
local UIParent = _G.UIParent
local UI_SCALE = _G.UI_SCALE

function Module:ResetSettings()
	KkthnxUIDB.Settings[K.Realm][K.Name] = {}
end

function Module:ResetData()
	KkthnxUIDB.Variables[K.Realm][K.Name] = {}

	FCF_ResetChatWindows()

	if ChatConfigFrame:IsShown() then
		ChatConfig_UpdateChatSettings()
	end

	Module:ForceDefaultCVars()

	ReloadUI()
end

-- Tuitorial
function Module:ForceDefaultCVars()
	SetCVar("autoLootDefault", 1)
	SetCVar("alwaysCompareItems", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("lootUnderMouse", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("showTutorials", 0)
	SetCVar("ActionButtonUseKeyDown", 1)
	SetCVar("lockActionBars", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("overrideArchive", 0)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetActionBarToggles(1, 1, 1, 1)

	if not InCombatLockdown() then
		SetCVar("nameplateMotion", 1)
		SetCVar("nameplateShowAll", 1)
		SetCVar("nameplateShowEnemies", 1)
		SetCVar("alwaysShowActionBars", 1)
	end

	if K.isDeveloper then
		SetCVar("ffxGlow", 0)
		SetCVar("SpellQueueWindow", 17)
	end
end

local function ForceRaidFrame()
	if InCombatLockdown() then
		return
	end

	if not _G.CompactUnitFrameProfiles then
		return
	end

	SetCVar("useCompactPartyFrames", 1)

	_G.SetRaidProfileOption(_G.CompactUnitFrameProfiles.selectedProfile, "useClassColors", true)
	_G.SetRaidProfileOption(_G.CompactUnitFrameProfiles.selectedProfile, "displayPowerBar", true)
	_G.SetRaidProfileOption(_G.CompactUnitFrameProfiles.selectedProfile, "displayBorder", false)
	_G.CompactUnitFrameProfiles_ApplyCurrentSettings()
	_G.CompactUnitFrameProfiles_UpdateCurrentPanel()
end

function Module:ForceChatSettings()
	if KkthnxUIDB.Settings[K.Realm][K.Name].Chat then
		if KkthnxUIDB.Settings[K.Realm][K.Name].Chat.Width ~= C["Chat"].Width then
			KkthnxUIDB.Settings[K.Realm][K.Name].Chat.Width = C["Chat"].Width
		end

		if KkthnxUIDB.Settings[K.Realm][K.Name].Chat.Height ~= C["Chat"].Height then
			KkthnxUIDB.Settings[K.Realm][K.Name].Chat.Height = C["Chat"].Height
		end
	end

	K:GetModule("Chat"):UpdateChatSize()

	-- General
	FCF_ResetChatWindows()
	FCF_SetLocked(ChatFrame1, 1)
	FCF_SetWindowName(ChatFrame1, L["General"])
	ChatFrame1:Show()

	-- Combat Log
	FCF_DockFrame(ChatFrame2)
	FCF_SetLocked(ChatFrame2, 1)
	FCF_SetWindowName(ChatFrame2, L["CombatLog"])
	ChatFrame2:Show()

	-- Whispers
	FCF_OpenNewWindow(L["Whisper"])
	FCF_SetLocked(ChatFrame3, 1)
	FCF_DockFrame(ChatFrame3)
	ChatFrame3:Show()

	-- Trade
	FCF_OpenNewWindow(L["Trade"])
	FCF_SetLocked(ChatFrame4, 1)
	FCF_DockFrame(ChatFrame4)
	ChatFrame4:Show()

	-- Loot
	FCF_OpenNewWindow(L["Loot"])
	FCF_SetLocked(ChatFrame5, 1)
	FCF_DockFrame(ChatFrame5)
	ChatFrame5:Show()

	for _, name in ipairs(_G.CHAT_FRAMES) do
		local frame = _G[name]
		FCF_SetChatWindowFontSize(nil, frame, 12)
	end

	-- ChatFrame1
	ChatFrame_RemoveChannel(ChatFrame1, TRADE)
	ChatFrame_RemoveChannel(ChatFrame1, GENERAL)
	ChatFrame_RemoveChannel(ChatFrame1, "GuildRecruitment")
	ChatFrame_RemoveChannel(ChatFrame1, "LookingForGroup")
	local chatGroup = {"SAY", "EMOTE", "YELL", "GUILD", "OFFICER", "GUILD_ACHIEVEMENT", "MONSTER_SAY", "MONSTER_EMOTE", "MONSTER_YELL", "MONSTER_WHISPER", "MONSTER_BOSS_EMOTE", "MONSTER_BOSS_WHISPER", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "INSTANCE_CHAT", "INSTANCE_CHAT_LEADER", "BG_HORDE", "BG_ALLIANCE", "BG_NEUTRAL", "SYSTEM", "ERRORS", "AFK", "DND", "IGNORED", "ACHIEVEMENT"}
	ChatFrame_RemoveAllMessageGroups(ChatFrame1)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame1, v)
	end

	-- ChatFrame3
	chatGroup = {"WHISPER", "BN_WHISPER", "BN_CONVERSATION"}
	ChatFrame_RemoveAllMessageGroups(ChatFrame3)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame3, v)
	end

	-- ChatFrame4
	ChatFrame_RemoveAllMessageGroups(ChatFrame4)
	ChatFrame_AddChannel(ChatFrame4, TRADE)
	ChatFrame_AddChannel(ChatFrame4, GENERAL)
	ChatFrame_AddChannel(ChatFrame4, "LookingForGroup")

	chatGroup = {"COMBAT_XP_GAIN", "COMBAT_HONOR_GAIN", "COMBAT_FACTION_CHANGE", "LOOT", "MONEY", "SKILL"}
	ChatFrame_RemoveAllMessageGroups(ChatFrame5)
	for _, v in ipairs(chatGroup) do
		ChatFrame_AddMessageGroup(_G.ChatFrame5, v)
	end

	-- set the chat groups names in class color to enabled for all chat groups which players names appear
	chatGroup = {"SAY", "YELL", "GUILD", "OFFICER", "WHISPER", "WHISPER_INFORM", "PARTY", "PARTY_LEADER", "RAID", "RAID_LEADER", "RAID_WARNING", "EMOTE", "CHANNEL1", "CHANNEL2", "CHANNEL3", "CHANNEL4", "CHANNEL5", "CHANNEL6", "CHANNEL7", "CHANNEL8", "CHANNEL9", "CHANNEL10", "CHANNEL11", "CHANNEL12", "CHANNEL13", "CHANNEL14", "CHANNEL15", "CHANNEL16", "CHANNEL17", "CHANNEL18", "CHANNEL19", "CHANNEL20"}
	for i = 1, _G.MAX_WOW_CHAT_CHANNELS do
		table.insert(chatGroup, 'CHANNEL'..i)
	end

	for _, v in ipairs(chatGroup) do
		ToggleChatColorNamesByClassGroup(true, v)
	end

	-- Adjust Chat Colors
	ChangeChatColor("CHANNEL1", 195/255, 230/255, 232/255) -- General
	ChangeChatColor("CHANNEL2", 232/255, 158/255, 121/255) -- Trade
	ChangeChatColor("CHANNEL3", 232/255, 228/255, 121/255) -- Local Defense
end

local function ForceHekiliOptions()
	if not IsAddOnLoaded("Hekili") then
		return
	end

	local isWiped = false
	if HekiliDB and not isWiped then
		table.wipe(HekiliDB)
		isWiped = true
	end

	if isWiped then
		HekiliDB = {
			["profiles"] = {
				["KkthnxUI"] = {
					["toggles"] = {
						["potions"] = {
							["value"] = true,
						},
						["interrupts"] = {
							["value"] = true,
							["separate"] = true,
						},
						["cooldowns"] = {
							["value"] = true,
							["override"] = true,
						},
						["mode"] = {
							["aoe"] = true,
						},
						["defensives"] = {
							["value"] = true,
							["separate"] = true,
						},
					},
					["displays"] = {
						["AOE"] = {
							["rel"] = "CENTER",
							["delays"] = {
								["font"] = "KkthnxUIFont",
								["fontSize"] = 16,
							},
							["captions"] = {
								["fontSize"] = 16,
								["font"] = "KkthnxUIFont",
							},
							["y"] = -231,
							["targets"] = {
								["font"] = "KkthnxUIFont",
								["fontSize"] = 16,
							},
							["keybindings"] = {
								["fontSize"] = 16,
								["font"] = "KkthnxUIFont",
							},
						},
						["Primary"] = {
							["rel"] = "CENTER",
							["delays"] = {
								["font"] = "KkthnxUIFont",
								["fontSize"] = 16,
							},
							["captions"] = {
								["fontSize"] = 16,
								["font"] = "KkthnxUIFont",
							},
							["y"] = -286,
							["targets"] = {
								["font"] = "KkthnxUIFont",
								["fontSize"] = 16,
							},
							["keybindings"] = {
								["fontSize"] = 16,
								["font"] = "KkthnxUIFont",
							},
						},
						["Defensives"] = {
							["rel"] = "CENTER",
							["delays"] = {
								["font"] = "KkthnxUIFont",
								["fontSize"] = 16,
							},
							["captions"] = {
								["fontSize"] = 16,
								["font"] = "KkthnxUIFont",
							},
							["y"] = -48,
							["x"] = -244,
							["targets"] = {
								["font"] = "KkthnxUIFont",
								["fontSize"] = 16,
							},
							["keybindings"] = {
								["fontSize"] = 16,
								["font"] = "KkthnxUIFont",
							},
						},
						["Interrupts"] = {
							["rel"] = "CENTER",
							["delays"] = {
								["font"] = "KkthnxUIFont",
								["fontSize"] = 16,
							},
							["captions"] = {
								["fontSize"] = 16,
								["font"] = "KkthnxUIFont",
							},
							["y"] = -48,
							["x"] = 244,
							["targets"] = {
								["font"] = "KkthnxUIFont",
								["fontSize"] = 16,
							},
							["keybindings"] = {
								["fontSize"] = 16,
								["font"] = "KkthnxUIFont",
							},
						},
					},
				},
			},
		}
	end

	KkthnxUIDB.Variables["HekiliRequest"] = false
end

local function ForceMaxDPSOptions()
	if not IsAddOnLoaded("MaxDps") then
		return
	end

	if MaxDpsOptions then
		table_wipe(MaxDpsOptions)
	end

	MaxDpsOptions = {
		["global"] = {
			["texture"] = "Interface\\Cooldown\\star4",
			["customRotations"] = {
			},
			["disabledInfo"] = true,
		},
	}

	KkthnxUIDB.Variables["MaxDpsRequest"] = false
end

-- DBM bars
local function ForceDBMOptions()
	if not IsAddOnLoaded("DBM-Core") then
		return
	end

	if DBT_AllPersistentOptions then
		table_wipe(DBT_AllPersistentOptions)
	end

	DBT_AllPersistentOptions = {
		["Default"] = {
			["DBM"] = {
				["Scale"] = 1,
				["HugeScale"] = 1,
				["ExpandUpwards"] = true,
				["ExpandUpwardsLarge"] = true,
				["BarXOffset"] = 0,
				["BarYOffset"] = 15,
				["TimerPoint"] = "LEFT",
				["TimerX"] = 122,
				["TimerY"] = -300,
				["Width"] = 174,
				["Height"] = 20,
				["HugeWidth"] = 210,
				["HugeBarXOffset"] = 0,
				["HugeBarYOffset"] = 15,
				["HugeTimerPoint"] = "CENTER",
				["HugeTimerX"] = 330,
				["HugeTimerY"] = -42,
				["FontSize"] = 10,
				["StartColorR"] = 1,
				["StartColorG"] = .7,
				["StartColorB"] = 0,
				["EndColorR"] = 1,
				["EndColorG"] = 0,
				["EndColorB"] = 0,
				["Texture"] = C["Media"].Statusbars.KkthnxUIStatusbar,
			},
		},
	}

	if not _G.DBM_AllSavedOptions["Default"] then
		_G.DBM_AllSavedOptions["Default"] = {}
	end
	_G.DBM_AllSavedOptions["Default"]["WarningY"] = -170
	_G.DBM_AllSavedOptions["Default"]["WarningX"] = 0
	_G.DBM_AllSavedOptions["Default"]["WarningFontStyle"] = "OUTLINE"
	_G.DBM_AllSavedOptions["Default"]["SpecialWarningX"] = 0
	_G.DBM_AllSavedOptions["Default"]["SpecialWarningY"] = -260
	_G.DBM_AllSavedOptions["Default"]["SpecialWarningFontStyle"] = "OUTLINE"
	_G.DBM_AllSavedOptions["Default"]["HideObjectivesFrame"] = false
	_G.DBM_AllSavedOptions["Default"]["WarningFontSize"] = 18
	_G.DBM_AllSavedOptions["Default"]["SpecialWarningFontSize2"] = 24

	KkthnxUIDB.Variables["DBMRequest"] = false
end

-- Skada
local function ForceSkadaOptions()
	if not IsAddOnLoaded("Skada") then
		return
	end

	if SkadaDB then
		table_wipe(SkadaDB)
	end

	SkadaDB = {
		["hasUpgraded"] = true,
		["profiles"] = {
			["Default"] = {
				["windows"] = {
					{	["barheight"] = 18,
						["classicons"] = false,
						["barslocked"] = true,
						["y"] = 28,
						["x"] = -3,
						["title"] = {
							["color"] = {
								["a"] = 0.3,
								["b"] = 0,
								["g"] = 0,
								["r"] = 0,
							},
							["font"] = "",
							["borderthickness"] = 0,
							["fontflags"] = "OUTLINE",
							["fontsize"] = 14,
							["texture"] = "normTex",
						},
						["barfontflags"] = "OUTLINE",
						["point"] = "BOTTOMRIGHT",
						["mode"] = "",
						["barwidth"] = 300,
						["barbgcolor"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["barfontsize"] = 14,
						["background"] = {
							["height"] = 180,
							["texture"] = "None",
							["bordercolor"] = {
								["a"] = 0,
							},
						},
						["bartexture"] = "KKUI_Statusbar",
					}, -- [1]
				},
				["tooltiprows"] = 10,
				["setstokeep"] = 30,
				["tooltippos"] = "topleft",
				["reset"] = {
					["instance"] = 3,
					["join"] = 1,
				},
			},
		},
	}

	KkthnxUIDB.Variables["SkadaRequest"] = false
end

local function ForceCursorTrail()
	if not IsAddOnLoaded("CursorTrail") then
		return
	end

	if CursorTrail_PlayerConfig then
		table_wipe(CursorTrail_PlayerConfig)
	end

	CursorTrail_PlayerConfig = {
		["FadeOut"] = false,
		["UserOfsY"] = 0,
		["UserShowMouseLook"] = false,
		["ModelID"] = 166492,
		["UserAlpha"] = 0.9,
		["UserOfsX"] = 0.1,
		["UserScale"] = 0.4,
		["UserShadowAlpha"] = 0,
		["UserShowOnlyInCombat"] = false,
		["Strata"] = "HIGH",
	}

	KkthnxUIDB.Variables["CursorTrailRequest"] = false
end

-- BigWigs
local function ForceBigwigs()
	if not IsAddOnLoaded("BigWigs") then
		return
	end

	if BigWigs3DB then
		table_wipe(BigWigs3DB)
	end

	BigWigs3DB = {
		["namespaces"] = {
			["BigWigs_Plugins_Bars"] = {
				["profiles"] = {
					["Default"] = {
						["outline"] = "OUTLINE",
						["fontSize"] = 12,
						["BigWigsAnchor_y"] = 336,
						["BigWigsAnchor_x"] = 16,
						["BigWigsAnchor_width"] = 175,
						["growup"] = true,
						["interceptMouse"] = false,
						["barStyle"] = "KKUI_Statusbar",
						["LeftButton"] = {
							["emphasize"] = false,
						},
						["font"] = "KKUI_Normal",
						["onlyInterceptOnKeypress"] = true,
						["emphasizeMultiplier"] = 1,
						["BigWigsEmphasizeAnchor_x"] = 810,
						["BigWigsEmphasizeAnchor_y"] = 350,
						["BigWigsEmphasizeAnchor_width"] = 220,
						["emphasizeGrowup"] = true,
					},
				},
			},
			["BigWigs_Plugins_Super Emphasize"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 28,
						["font"] = "KKUI_Normal",
					},
				},
			},
			["BigWigs_Plugins_Messages"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 18,
						["font"] = "KKUI_Normal",
						["BWEmphasizeCountdownMessageAnchor_x"] = 665,
						["BWMessageAnchor_x"] = 616,
						["BWEmphasizeCountdownMessageAnchor_y"] = 530,
						["BWMessageAnchor_y"] = 305,
					},
				},
			},
			["BigWigs_Plugins_Proximity"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 18,
						["font"] = "KKUI_Normal",
						["posy"] = 346,
						["width"] = 140,
						["posx"] = 1024,
						["height"] = 120,
					},
				},
			},
			["BigWigs_Plugins_Alt Power"] = {
				["profiles"] = {
					["Default"] = {
						["posx"] = 1002,
						["fontSize"] = 14,
						["font"] = "KKUI_Normal",
						["fontOutline"] = "OUTLINE",
						["posy"] = 490,
					},
				},
			},
		},
		["profiles"] = {
			["Default"] = {
				["fakeDBMVersion"] = true,
			},
		},
	}

	KkthnxUIDB.Variables["BWRequest"] = false
end

local function ForceAddonSkins()
	if KkthnxUIDB.Variables["DBMRequest"] then
		ForceDBMOptions()
	end

	if KkthnxUIDB.Variables["SkadaRequest"] then
		ForceSkadaOptions()
	end

	if KkthnxUIDB.Variables["BWRequest"] then
		ForceBigwigs()
	end

	if KkthnxUIDB.Variables["MaxDpsRequest"] then
		ForceMaxDPSOptions()
	end

	if KkthnxUIDB.Variables["CursorTrailRequest"] then
		ForceCursorTrail()
	end

	if KkthnxUIDB.Variables["HekiliRequest"] then
		ForceHekiliOptions()
	end
end

-- Tutorial
local tutor
local function YesTutor()
	if tutor then
		tutor:Show()
		return
	end

	tutor = CreateFrame("Frame", nil, UIParent)
	tutor:SetPoint("CENTER")
	tutor:SetSize(480, 240)
	tutor:SetFrameStrata("HIGH")
	K.CreateMoverFrame(tutor)
	tutor:CreateBorder()

	local tutorLogo = tutor:CreateTexture(nil, "OVERLAY")
	tutorLogo:SetSize(512, 256)
	tutorLogo:SetBlendMode("ADD")
	tutorLogo:SetAlpha(0.07)
	tutorLogo:SetTexture(C["Media"].Textures.LogoTexture)
	tutorLogo:SetPoint("CENTER", tutor, "CENTER", 0, 0)

	K.CreateFontString(tutor, 30, K.Title, "", true, "TOPLEFT", 10, 25)
	local ll = CreateFrame("Frame", nil, tutor)
	ll:SetPoint("TOP", -40, -32)
	K.CreateGF(ll, 80, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, tutor)
	lr:SetPoint("TOP", 40, -32)
	K.CreateGF(lr, 80, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")

	local title = K.CreateFontString(tutor, 13, "", "", true, "TOP", 0, -10)
	local body = K.CreateFontString(tutor, 13, "", "", false, "TOPLEFT", 20, -50)

	body:SetPoint("BOTTOMRIGHT", -20, 50)
	body:SetJustifyV("TOP")
	body:SetJustifyH("LEFT")
	body:SetWordWrap(true)

	local progressBar = CreateFrame('StatusBar', nil, tutor)
	progressBar:SetMinMaxValues(0, 500)
	progressBar:SetValue(0)
	progressBar:CreateBorder()
	progressBar:SetPoint('TOP', tutor, 'BOTTOM', 0, -6)
	progressBar:SetSize(480, 22)
	progressBar:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)

	progressBar.text = K.CreateFontString(progressBar, 13, "", "", false, "CENTER", 0, -1)

	progressBar.spark = progressBar:CreateTexture(nil, "OVERLAY")
	progressBar.spark:SetWidth(64)
	progressBar.spark:SetHeight(progressBar:GetHeight())
	progressBar.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	progressBar.spark:SetBlendMode("ADD")
	progressBar.spark:SetPoint("CENTER", progressBar:GetStatusBarTexture(), "RIGHT", 0, 0)
	progressBar.spark:SetAlpha(0.6)

	local pass = CreateFrame("Button", nil, tutor)
	pass:SetPoint("BOTTOMLEFT", 10, 10)
	pass:SetSize(90, 24)
	pass:SkinButton()

	pass.text = pass:CreateFontString(nil, "OVERLAY")
	pass.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	pass.text:SetPoint("CENTER")
	pass.text:SetText(DECLINE)
	pass.text:SetTextColor(1, 0, 0)

	local apply = CreateFrame("Button", nil, tutor)
	apply:SetPoint("BOTTOMRIGHT", -10, 10)
	apply:SetSize(90, 24)
	apply:SkinButton()

	apply.text = apply:CreateFontString(nil, "OVERLAY")
	apply.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	apply.text:SetPoint("CENTER")
	apply.text:SetText(APPLY)
	apply.text:SetTextColor(0, 1, 0)

	local titles = {
		DEFAULT.." "..SETTINGS,
		CHAT,
		UI_SCALE,
		"Skins",
		"Tips"
	}

	local function RefreshText(page)
		title:SetText(titles[page])
		body:SetText(L["Tutorial Page"..page])

		if progressBar then
			progressBar:SetValue(page.."00")
			progressBar:SetStatusBarColor(K.r, K.g, K.b)
			progressBar.text:SetText(page.."/5")
		end
	end
	RefreshText(1)

	local currentPage = 1
	pass:SetScript("OnClick", function()
		if currentPage > 3 then
			pass:Hide()
		end

		currentPage = currentPage + 1
		RefreshText(currentPage)
		StopSound(21968)
		StopSound(140268)
		PlaySound(140268)
	end)

	apply:SetScript("OnClick", function()
		pass:Show()
		if currentPage == 1 then
			Module:ForceDefaultCVars()
			ForceRaidFrame()
			UIErrorsFrame:AddMessage(K.InfoColor.."Default CVars Loaded.")
			PlaySound(21968)
		elseif currentPage == 2 then
			StopSound(21968)
			Module:ForceChatSettings()
			UIErrorsFrame:AddMessage(K.InfoColor.."Chat Frame Settings Loaded")
			PlaySound(21968)
		elseif currentPage == 3 then
			StopSound(21968)
			C["General"].AutoScale = true
			K.SetupUIScale()
			UIErrorsFrame:AddMessage(K.InfoColor.."UI Scale Loaded")
			PlaySound(21968)
		elseif currentPage == 4 then
			StopSound(21968)
			KkthnxUIDB.Variables["DBMRequest"] = true
			KkthnxUIDB.Variables["SkadaRequest"] = true
			KkthnxUIDB.Variables["BWRequest"] = true
			KkthnxUIDB.Variables["MaxDpsRequest"] = true
			KkthnxUIDB.Variables["CursorTrailRequest"] = true
			KkthnxUIDB.Variables["HekiliRequest"] = true
			ForceAddonSkins()
			KkthnxUIDB.Variables["ResetDetails"] = true
			UIErrorsFrame:AddMessage(K.InfoColor.."Relevant AddOns Settings Loaded, You need to ReloadUI.")
			pass:Hide()
			PlaySound(21968)
		elseif currentPage == 5 then
			StopSound(21968)
			StopSound(140268)
			KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete = true
			tutor:Hide()
			progressBar:Hide()
			StaticPopup_Show("KKUI_CHANGES_RELOAD")
			currentPage = 0
			PlaySound(11466)
		end

		currentPage = currentPage + 1
		RefreshText(currentPage)
	end)
end

local welcome
local function HelloWorld()
	if welcome then
		welcome:Show()
		return
	end

	welcome = CreateFrame("Frame", "KKUI_Tutorial", UIParent)
	welcome:SetPoint("CENTER")
	welcome:SetSize(400, 500)
	welcome:SetFrameStrata("HIGH")
	K.CreateMoverFrame(welcome)
	welcome:CreateBorder()
	K.CreateFontString(welcome, 30, K.Title, "", true, "TOPLEFT", 10, 28)
	K.CreateFontString(welcome, 14, K.Version, "", true, "TOPLEFT", 140, 16)
	K.CreateFontString(welcome, 16, "Help Info", "", true, "TOP", 0, -10)

	local welcomeLogo = welcome:CreateTexture(nil, "OVERLAY")
	welcomeLogo:SetSize(512, 256)
	welcomeLogo:SetBlendMode("ADD")
	welcomeLogo:SetAlpha(0.04)
	welcomeLogo:SetTexture(C["Media"].Textures.LogoTexture)
	welcomeLogo:SetPoint("CENTER", welcome, "CENTER", 0, 0)

	local welcomeBoss = welcome:CreateTexture(nil, "OVERLAY")
	welcomeBoss:SetSize(128, 64)
	welcomeBoss:SetTexture("Interface\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-Illidan Stormrage")
	welcomeBoss:SetPoint("TOPRIGHT", welcome, "TOPRIGHT", 10, 64)

	local ll = CreateFrame("Frame", nil, welcome)
	ll:SetPoint("TOP", -50, -35)
	K.CreateGF(ll, 100, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")

	local lr = CreateFrame("Frame", nil, welcome)
	lr:SetPoint("TOP", 50, -35)
	K.CreateGF(lr, 100, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")
	K.CreateFontString(welcome, 14, "Thank you for choosing |cff669dffKkthnxUI|r, v"..K.SystemColor..K.Version.."|r!", "", false, "TOP", 0, -50)
	K.CreateFontString(welcome, 13, "|cff669dffKkthnxUI|r is a simplistic user interface that holds", "", false, "TOP", 0, -86)
	K.CreateFontString(welcome, 13, "onto the information and functionality, while still keeping", "", false, "TOP", 0, -106)
	K.CreateFontString(welcome, 13, "most of the good looks. It can be used for any class or role.", "", false, "TOP", 0, -126)

	K.CreateFontString(welcome, 16, "|cff669dffJoin The Community!|r", "", false, "TOP", 0, -160)
	K.CreateFontString(welcome, 13, "There are thousands of users, but most are content", "", false, "TOP", 0, -180)
	K.CreateFontString(welcome, 13, "to simply download and use the interface without further", "", false, "TOP", 0, -200)
	K.CreateFontString(welcome, 13, "ado. If you wish to get more involved though,", "", false, "TOP", 0, -220)
	K.CreateFontString(welcome, 13, "have some questions you can't find answers to", "", false, "TOP", 0, -240)
	K.CreateFontString(welcome, 13, "anywhere else or simply just wish to stop by,", "", false, "TOP", 0, -260)
	K.CreateFontString(welcome, 13, "we have both a discord server and a facebook page.", "", false, "TOP", 0, -280)

	local ll = CreateFrame("Frame", nil, welcome)
	ll:SetPoint("TOP", welcome, -90, -326)
	K.CreateGF(ll, 180, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, welcome)
	lr:SetPoint("TOP", welcome, 90, -326)
	K.CreateGF(lr, 180, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")

	K.CreateFontString(welcome, 13, "If this is your first time using |cff669dffKkthnxUI|r,", "", false, "BOTTOM", 0, 130)
	K.CreateFontString(welcome, 13, "please take a minute to go through the turtoral!", "", false, "BOTTOM", 0, 110)
	K.CreateFontString(welcome, 13, "if you need help for commands type /khelp", "", false, "BOTTOM", 0, 90)

	if KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete then
		local close = CreateFrame("Button", nil, welcome)
		close:SetPoint("TOPRIGHT", 4, 4)
		close:SetSize(32, 32)
		close:SkinCloseButton()
		close:SetScript("OnClick", function()
			welcome:Hide()
		end)
	end

	local goTutor = CreateFrame("Button", nil, welcome)
	goTutor:SetPoint("BOTTOM", 0, 10)
	goTutor:SetSize(110, 20)
	goTutor:SkinButton()

	goTutor.text = goTutor:CreateFontString(nil, "OVERLAY")
	goTutor.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	goTutor.text:SetPoint("CENTER")
	goTutor.text:SetText("Tutorial")

	goTutor.glowFrame = CreateFrame("Frame", nil, goTutor, "BackdropTemplate")
	goTutor.glowFrame:SetBackdrop({edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12})
	goTutor.glowFrame:SetPoint("TOPLEFT", goTutor, -5, 5)
	goTutor.glowFrame:SetPoint("BOTTOMRIGHT", goTutor, 5, -5)
	goTutor.glowFrame:SetBackdropBorderColor(K.r, K.g, K.b)
	goTutor.glowFrame:Hide()

	goTutor.glowFrame.Animation = goTutor.glowFrame:CreateAnimationGroup()
	goTutor.glowFrame.Animation:SetLooping("BOUNCE")
	goTutor.glowFrame.Animation.Fader = goTutor.glowFrame.Animation:CreateAnimation("Alpha")
	goTutor.glowFrame.Animation.Fader:SetFromAlpha(0.8)
	goTutor.glowFrame.Animation.Fader:SetToAlpha(0.2)
	goTutor.glowFrame.Animation.Fader:SetDuration(1)
	goTutor.glowFrame.Animation.Fader:SetSmoothing("OUT")

	if not goTutor.glowFrame.Animation:IsPlaying() then
		goTutor.glowFrame.Animation:Play()
		goTutor.glowFrame:Show()
	end

	goTutor:SetScript("OnClick", function()
		if goTutor.glowFrame.Animation and goTutor.glowFrame.Animation:IsPlaying() then
			goTutor.glowFrame.Animation:Stop()
			goTutor.glowFrame:Hide()
		end
		welcome:Hide()
		YesTutor()
	end)

	local goSteam = CreateFrame("Button", nil, welcome)
	goSteam:SetPoint("BOTTOM", 0, 50)
	goSteam:SetSize(110, 20)
	goSteam:SkinButton()

	goSteam.text = goSteam:CreateFontString(nil, "OVERLAY")
	goSteam.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	goSteam.text:SetPoint("CENTER")
	goSteam.text:SetText(K.SystemColor.."Steam Wishlist|r")

	goSteam:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://store.steampowered.com/wishlist/id/Kkthnx")
	end)

	local goPaypal = CreateFrame("Button", nil, welcome)
	goPaypal:SetPoint("BOTTOM", -120, 50)
	goPaypal:SetSize(110, 20)
	goPaypal:SkinButton()

	goPaypal.text = goPaypal:CreateFontString(nil, "OVERLAY")
	goPaypal.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	goPaypal.text:SetPoint("CENTER")
	goPaypal.text:SetText("|CFF0079C1Paypal|r")

	goPaypal:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "http://paypal.me/kkthnx")
	end)

	local goPatreon = CreateFrame("Button", nil, welcome)
	goPatreon:SetPoint("BOTTOM", 120, 50)
	goPatreon:SetSize(110, 20)
	goPatreon:SkinButton()

	goPatreon.text = goPatreon:CreateFontString(nil, "OVERLAY")
	goPatreon.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	goPatreon.text:SetPoint("CENTER")
	goPatreon.text:SetText("|CFFf96854Patreon|r")

	goPatreon:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_POPUP_LINK", nil, nil, "https://www.patreon.com/kkthnx")
	end)
end

_G.SlashCmdList["KKUI_INSTALLER"] = HelloWorld
_G.SLASH_KKUI_INSTALLER1 = "/install"

function Module:OnEnable()
	-- Hide options
	K.HideInterfaceOption(_G.Display_UseUIScale)
	K.HideInterfaceOption(_G.Display_UIScaleSlider)

	-- Tutorial and settings
	ForceAddonSkins()
	if not KkthnxUIDB.Variables[K.Realm][K.Name].InstallComplete then
		HelloWorld()
	end
end