local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Installer")

local _G = _G

local SetCVar = _G.SetCVar
local CreateFrame = _G.CreateFrame
local IsAddOnLoaded = _G.IsAddOnLoaded

function Module:ResetInstallData()
	KkthnxUIData[K.Realm][K.Name] = {}

	if (KkthnxUIConfigPerAccount) then
		KkthnxUIConfigShared.Account = {}
	else
		KkthnxUIConfigShared[K.Realm][K.Name] = {}
	end

	ReloadUI()
end

-- Tuitorial
function Module:ForceDefaultCVars()
	SetActionBarToggles(1, 1, 1, 1)
	SetCVar("ActionButtonUseKeyDown", 1)
	SetCVar("alwaysCompareItems", 1)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoLootDefault", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("autoSelfCast", 1)
	SetCVar("ffxGlow", 0)
	SetCVar("lockActionBars", 1)
	SetCVar("lootUnderMouse", 1)
	SetCVar("nameplateMotion", 1)
	SetCVar("nameplateShowAll", 1)
	SetCVar("nameplateShowEnemies", 1)
	SetCVar("overrideArchive", 0)
	SetCVar("screenshotQuality", 10)
	SetCVar("showTutorials", 0)
	SetCVar("useCompactPartyFrames", 1)
end

local function ForceRaidFrame()
	if InCombatLockdown() then
		return
	end

	if not CompactUnitFrameProfiles then
		return
	end

	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "useClassColors", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayPowerBar", true)
	SetRaidProfileOption(CompactUnitFrameProfiles.selectedProfile, "displayBorder", false)
	CompactUnitFrameProfiles_ApplyCurrentSettings()
	CompactUnitFrameProfiles_UpdateCurrentPanel()
end

function Module:ForceChatSettings()
	local Chat = K:GetModule("Chat")

	if (Chat) then
		Chat:Install()
	end
end

-- DBM bars
local function ForceDBMOptions()
	if not IsAddOnLoaded("DBM-Core") then
		return
	end

	if DBT_AllPersistentOptions then
		wipe(DBT_AllPersistentOptions)
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
				["TimerX"] = 118,
				["TimerY"] = -105,
				["Width"] = 175,
				["Heigh"] = 20,
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
				["Texture"] = C["Media"].Texture,
			},
		},
	}

	if not DBM_AllSavedOptions["Default"] then
		DBM_AllSavedOptions["Default"] = {}
	end
	DBM_AllSavedOptions["Default"]["WarningY"] = -170
	DBM_AllSavedOptions["Default"]["WarningX"] = 0
	DBM_AllSavedOptions["Default"]["WarningFontStyle"] = "OUTLINE"
	DBM_AllSavedOptions["Default"]["SpecialWarningX"] = 0
	DBM_AllSavedOptions["Default"]["SpecialWarningY"] = -260
	DBM_AllSavedOptions["Default"]["SpecialWarningFontStyle"] = "OUTLINE"
	DBM_AllSavedOptions["Default"]["HideObjectivesFrame"] = false
	DBM_AllSavedOptions["Default"]["WarningFontSize"] = 18
	DBM_AllSavedOptions["Default"]["SpecialWarningFontSize2"] = 24

	KkthnxUIData["DBMRequest"] = false
end

-- Skada
local function ForceSkadaOptions()
	if not IsAddOnLoaded("Skada") then
		return
	end

	if SkadaDB then
		wipe(SkadaDB)
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
						["bartexture"] = "KkthnxUI",
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
	KkthnxUIData["SkadaRequest"] = false
end

-- BigWigs
local function ForceBigwigs()
	if not IsAddOnLoaded("BigWigs") then
		return
	end

	if BigWigs3DB then
		wipe(BigWigs3DB)
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
						["barStyle"] = "KkthnxUI",
						["LeftButton"] = {
							["emphasize"] = false,
						},
						["font"] = "KkthnxUIFont",
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
						["font"] = "KkthnxUIFont",
					},
				},
			},
			["BigWigs_Plugins_Messages"] = {
				["profiles"] = {
					["Default"] = {
						["fontSize"] = 18,
						["font"] = "KkthnxUIFont",
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
						["font"] = "KkthnxUIFont",
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
						["font"] = "KkthnxUIFont",
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
	KkthnxUIData["BWRequest"] = false
end

local function ForceAddonSkins()
	if KkthnxUIData["DBMRequest"] then
		ForceDBMOptions()
	end

	if KkthnxUIData["SkadaRequest"] then
		ForceSkadaOptions()
	end

	if KkthnxUIData["BWRequest"] then
		ForceBigwigs()
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
	tutor:SetSize(480, 300)
	tutor:SetFrameStrata("HIGH")
	K.CreateMoverFrame(tutor)
	tutor:CreateBorder()

	local tutorLogo = tutor:CreateTexture(nil, "OVERLAY")
	tutorLogo:SetSize(512, 256)
	tutorLogo:SetBlendMode("ADD")
	tutorLogo:SetAlpha(0.07)
	tutorLogo:SetTexture(C["Media"].Logo)
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

	local foot = K.CreateFontString(tutor, 13, "", "", false, "BOTTOM", 0, 10)

	local pass = CreateFrame("Button", nil, tutor)
	pass:SetPoint("BOTTOMLEFT", 10, 10)
	pass:SetSize(50, 20)
	pass:SkinButton()

	pass.text = pass:CreateFontString(nil, "OVERLAY")
	pass.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	pass.text:SetPoint("CENTER")
	pass.text:SetText("Skip")

	local apply = CreateFrame("Button", nil, tutor)
	apply:SetPoint("BOTTOMRIGHT", -10, 10)
	apply:SetSize(50, 20)
	apply:SkinButton()

	apply.text = apply:CreateFontString(nil, "OVERLAY")
	apply.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	apply.text:SetPoint("CENTER")
	apply.text:SetText(APPLY)

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
		foot:SetText(page.."/5")
	end
	RefreshText(1)

	local currentPage = 1
	pass:SetScript("OnClick", function()
		if currentPage > 3 then
			pass:Hide()
		end

		currentPage = currentPage + 1
		RefreshText(currentPage)
		PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
	end)

	apply:SetScript("OnClick", function()
		pass:Show()
		if currentPage == 1 then
			Module:ForceDefaultCVars()
			ForceRaidFrame()
			UIErrorsFrame:AddMessage(K.InfoColor.."Default CVars Loaded.")
		elseif currentPage == 2 then
			Module:ForceChatSettings()
			UIErrorsFrame:AddMessage(K.InfoColor.."Chat Frame Settings Loaded")
		elseif currentPage == 3 then
			KkthnxUIData[K.Realm][K.Name].AutoScale = true
			K:SetupUIScale()
			UIErrorsFrame:AddMessage(K.InfoColor.."UI Scale Loaded")
		elseif currentPage == 4 then
			KkthnxUIData["DBMRequest"] = true
			KkthnxUIData["SkadaRequest"] = true
			KkthnxUIData["BWRequest"] = true
			ForceAddonSkins()
			KkthnxUIData["ResetDetails"] = true
			UIErrorsFrame:AddMessage(K.InfoColor.."Relevant AddOns Settings Loaded, You need to ReloadUI.")
			pass:Hide()
		elseif currentPage == 5 then
			KkthnxUIData[K.Realm][K.Name].InstallComplete = true
			tutor:Hide()
			K.StaticPopup_Show("CHANGES_RL")
			currentPage = 0
			PlaySound(11466)
			K.Print(K.SystemColor.."Thank you for installing "..K.InfoColor.."v"..K.Version.." "..K.MyClassColor..K.Name.."|r"..K.SystemColor.."! Enjoy your|r "..K.MyClassColor..K.Class.."|r |cffa83f39<3|r")
		end

		currentPage = currentPage + 1
		RefreshText(currentPage)
		PlaySound(SOUNDKIT.IG_QUEST_LOG_OPEN)
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
	welcome:SetSize(420, 480)
	welcome:SetFrameStrata("HIGH")
	K.CreateMoverFrame(welcome)
	welcome:CreateBorder()
	K.CreateFontString(welcome, 30, K.Title, "", true, "TOPLEFT", 10, 28)
	K.CreateFontString(welcome, 14, K.Version, "", true, "TOPLEFT", 140, 16)
	K.CreateFontString(welcome, 16, "Help Info", "", true, "TOP", 0, -10)

	local welcomeLogo = welcome:CreateTexture(nil, "OVERLAY")
	welcomeLogo:SetSize(512, 256)
	welcomeLogo:SetBlendMode("ADD")
	welcomeLogo:SetAlpha(0.07)
	welcomeLogo:SetTexture(C["Media"].Logo)
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
	K.CreateFontString(welcome, 13, "Thank you for choosing |cff669dffKkthnxUI|r, v"..K.SystemColor..K.Version.."|r,", "", false, "TOPLEFT", 20, -50)
	K.CreateFontString(welcome, 13, "Below you will find a couple useful slash commands: ", "", false, "TOPLEFT", 20, -70)

	local c1, c2 = K.InfoColor, K.SystemColor -- YELLOW -- GREEN ??
	local lines = {
		c1.."/kb "..c2.."Easy Key-Bindings;",
		c1.."/moveui "..c2.."Unlock Most UI Elements;",
		c1.."/rl "..c2.."Reload all The AddOns;",
		c1.."/kcl "..c2.."Show KkthnxUI Changelog.",
		c1.."/kstatus "..c2.."Show KkthnxUI Status Report.",
		c1.."/profile list "..c2.."Show KkthnxUI Profiles List.",
	}

	for index, line in pairs(lines) do
		K.CreateFontString(welcome, 13, line, "", false, "TOPLEFT", 20, -120 - index * 20)
	end

	K.CreateFontString(welcome, 13, "If this is your first time using |cff669dffKkthnxUI|r,", "", false, "TOPLEFT", 20, -310)
	K.CreateFontString(welcome, 13, "Please take a minute to go through the turtoral!", "", false, "TOPLEFT", 20, -330)

	if KkthnxUIData[K.Realm][K.Name].InstallComplete then
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
	goTutor:SetSize(100, 20)
	goTutor:SkinButton()

	goTutor.text = goTutor:CreateFontString(nil, "OVERLAY")
	goTutor.text:SetFontObject(K.GetFont(C["UIFonts"].GeneralFonts))
	goTutor.text:SetPoint("CENTER")
	goTutor.text:SetText("Tutorial")

	goTutor:SetScript("OnClick", function()
		welcome:Hide()
		YesTutor()
	end)
end

SlashCmdList["KKTHNXUI"] = HelloWorld
SLASH_KKTHNXUI1 = "/install"

function Module:OnEnable()
	-- Hide options
	K.HideInterfaceOption(Advanced_UseUIScale)
	K.HideInterfaceOption(Advanced_UIScaleSlider)

	-- Tutorial and settings
	ForceAddonSkins()
	if not KkthnxUIData[K.Realm][K.Name].InstallComplete then
		HelloWorld()
	end
end