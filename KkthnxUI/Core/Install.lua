local K, C, L = unpack(select(2, ...))

local _G = _G
local tonumber = _G.tonumber
local max = _G.max
local min = _G.min
local format = _G.format

local APPLY = _G.APPLY
local CLOSE = _G.CLOSE
local COMPLETE = _G.COMPLETE
local CreateAnimationGroup = _G.CreateAnimationGroup
local CreateFrame = _G.CreateFrame
local GetRealmName = _G.GetRealmName
local NEXT = _G.NEXT
local PREVIOUS = _G.PREVIOUS
local ReloadUI = _G.ReloadUI
local RESET_TO_DEFAULT = _G.RESET_TO_DEFAULT
local SetCVar = _G.SetCVar
local UIParent = _G.UIParent
local UnitName = _G.UnitName
local SlashCmdList = _G.SlashCmdList
local UIErrorsFrame = _G.UIErrorsFrame

local Install = CreateFrame("Frame", "KkthnxUIInstaller", UIParent)
Install.CreateUIScale = CreateFrame("Frame")

local InstallFont = K.GetFont(C["UIFonts"].GeneralFonts)
local InstallTexture = K.GetTexture(C["UITextures"].GeneralTextures)

Install.MaxStepNumber = 4
Install.CurrentStep = 0
Install.Width = 500
Install.Height = 200

local function clipScale(scale)
	return tonumber(format("%.5f", scale))
end

local function GetPerfectScale()
	local scale = _G.KkthnxUIData[GetRealmName()][UnitName("player")].UIScale
	local bestScale = max(0.4, min(1.15, 768 / K.ScreenHeight))
	local pixelScale = 768 / K.ScreenHeight
	if _G.KkthnxUIData[GetRealmName()][UnitName("player")].LockUIScale then
		scale = clipScale(bestScale)
	end
	K.Mult = (bestScale / scale) - ((bestScale - pixelScale) / scale)

	return scale
end

local isScaling = false
local function SetupUIScale()
	if isScaling then
		return
	end
	isScaling = true

	local scale = GetPerfectScale()
	local parentScale = UIParent:GetScale()
	if scale ~= parentScale then
		UIParent:SetScale(scale)
	end

	_G.KkthnxUIData[GetRealmName()][UnitName("player")].UIScale = clipScale(scale)

	isScaling = false
end

function Install:ResetData()
	_G.KkthnxUIData[GetRealmName()][UnitName("player")] = {}
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].UIScale = 0.71111
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].LockUIScale = false
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].AutoInvite = false
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].RevealWorldMap = false
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].AutoQuest = false
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].BindType = 1
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].WatchedMovies = {}
	_G.KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"] = {}

	if (_G.KkthnxUIConfigPerAccount) then
		_G.KkthnxUIConfigShared.Account = {}
	else
		_G.KkthnxUIConfigShared[GetRealmName()][UnitName("player")] = {}
	end

	ReloadUI()
end

function Install:Step1()
	_G.SetActionBarToggles(1, 1, 1, 1)
	SetCVar("overrideArchive", 0)
	SetCVar("ActionButtonUseKeyDown", 1)
	SetCVar("alwaysShowActionBars", 1)
	SetCVar("autoOpenLootHistory", 0)
	SetCVar("autoQuestProgress", 1)
	SetCVar("autoQuestWatch", 1)
	SetCVar("buffDurations", 1)
	SetCVar("cameraDistanceMaxZoomFactor", 2.6)
	SetCVar("chatMouseScroll", 1)
	SetCVar("chatStyle", "classic")
	SetCVar("countdownForCooldowns", 0)
	SetCVar("lockActionBars", 1)
	SetCVar("lossOfControl", 1)
	SetCVar("nameplateMotion", 1)
	SetCVar("nameplateShowFriendlyNPCs", 1)
	SetCVar("nameplateShowSelf", 0)
	SetCVar("removeChatDelay", 1)
	SetCVar("screenshotQuality", 10)
	SetCVar("showArenaEnemyFrames", 0)
	SetCVar("ShowClassColorInNameplate", 1)
	SetCVar("showQuestTrackingTooltips", 1)
	SetCVar("showTutorials", 0)
	SetCVar("showVKeyCastbar", 1)
	SetCVar("spamFilter", 0)
	SetCVar("threatWarning", 3)
	SetCVar("UberTooltips", 1)
	SetCVar("violenceLevel", 5)
	SetCVar("wholeChatWindowClickable", 0)
	SetCVar("worldPreloadNonCritical", 0)

	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:SetValue("SHIFT")
	_G.InterfaceOptionsActionBarsPanelPickupActionKeyDropDown:RefreshValue()

	UIErrorsFrame:AddMessage(L["CVars Installed"], K.Color.r, K.Color.g, K.Color.b, 53, 2)

	self:Hide()
end

function Install:Step2()
	local Chat = K:GetModule("Chat")

	if (not Chat) then
		return
	end

	Chat:Install()
	Chat:SetDefaultChatFramesPositions()

	UIErrorsFrame:AddMessage(L["Chat Installed"], K.Color.r, K.Color.g, K.Color.b, 53, 2)

	self:Hide()
end

function Install:Step3()
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete = true
	_G.KkthnxUIData[GetRealmName()][UnitName("player")].LockUIScale = true
	SetupUIScale()

	UIErrorsFrame:AddMessage("UI Scale Applied", K.Color.r, K.Color.g, K.Color.b, 53, 2)

	self:Hide()
end

function Install:PrintStep(PageNum)
	self.CurrentStep = PageNum

	local ExecuteScript = self["Step"..PageNum]
	local Text = L["Step "..PageNum]
	local r, g, b = K.ColorGradient(PageNum / self.MaxStepNumber, 1, 0, 0, 1, 1, 0, 0, 1, 0)

	if (not Text) then
		self:Hide()
		if (PageNum > self.MaxStepNumber) then
			PlaySound(11466) -- A_BLCKTMPLE_Illidan_04
			ReloadUI()
		end
		return
	end

	if (PageNum == 0) then
		self.LeftButton.Text:SetText("|cffff2020"..CLOSE.."|r")
		self.LeftButton:SetScript("OnClick", function() self:Hide() end)
		self.RightButton.Text:SetText("|cffffd200"..NEXT.."|r")
		self.RightButton:SetScript("OnClick", function()
			self.PrintStep(self, self.CurrentStep + 1)
		end)
		self.MiddleButton.Text:SetText("|cffFF0000"..RESET_TO_DEFAULT.."|r")
		self.MiddleButton:SetScript("OnClick", self.ResetData)
		self.CloseButton:Show()
		self.SkipButton:Show()

		if (_G.KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete) then
			self.MiddleButton:Show()
		else
			self.MiddleButton:Hide()
		end
	else
		self.LeftButton:SetScript("OnClick", function()
			self.PrintStep(self, self.CurrentStep - 1)
		end)

		self.LeftButton.Text:SetText("|cffffd200"..PREVIOUS.."|r")
		self.MiddleButton.Text:SetText("|cff20ff20"..APPLY.."|r")
		self.RightButton:SetScript("OnClick", function()
			self.PrintStep(self, self.CurrentStep + 1)
		end)

		if (PageNum == Install.MaxStepNumber) then
			self.RightButton.Text:SetText("|cff20ff20"..COMPLETE.."|r")
			self.CloseButton:Hide()
			self.MiddleButton:Hide()
			self.DiscordButton:Show()
			self.SkipButton:Hide()
		else
			self.RightButton.Text:SetText("|cffffd200"..NEXT.."|r")
			self.CloseButton:Show()
			self.MiddleButton:Show()
			self.DiscordButton:Hide()
			self.SkipButton:Hide()
		end

		if (self.MiddleButton:IsVisible()) then
			self.MiddleButton:Show()
		end

		if (ExecuteScript) then
			self.MiddleButton:SetScript("OnClick", ExecuteScript)
		end
	end

	self.Text:SetText(Text)

	self.StatusBar.Anim:SetChange(PageNum)
	self.StatusBar.Anim:Play()

	self.StatusBar.Anim2:SetChange(r, g, b)
	self.StatusBar.Anim2:Play()

	self.StatusBar.text:SetText(self.CurrentStep.." / "..self.MaxStepNumber)
end

function Install:Launch()
	if (self.Description) then
		self:Show()
		return
	end

	local r, g, b = K.ColorGradient(0, self.MaxStepNumber, 1, 0, 0, 1, 1, 0, 0, 1, 0)
	self.Description = CreateFrame("Frame", nil, self)
	self.Description:SetSize(self.Width, self.Height)
	self.Description:SetPoint("CENTER", self, "CENTER")
	self.Description:CreateBorder()

	self.Description:SetClampedToScreen(true)
	self.Description:SetMovable(true)
	self.Description:EnableMouse(true)
	self.Description:RegisterForDrag("LeftButton")
	self.Description:SetScript("OnDragStart", self.Description.StartMoving)
	self.Description:SetScript("OnDragStop", self.Description.StopMovingOrSizing)

	self.Description:RegisterEvent("PLAYER_REGEN_DISABLED")
	self.Description:RegisterEvent("PLAYER_REGEN_ENABLED")
	self.Description:SetScript("OnEvent", function(_, event)
		if (event == "PLAYER_REGEN_DISABLED") then
			Install:Hide()
		else
			if (not _G.KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete) then
				Install:Show()
			end
		end
	end)

	self.StatusBar = CreateFrame("StatusBar", nil, self)
	self.StatusBar:SetStatusBarTexture(InstallTexture)
	self.StatusBar:SetPoint("BOTTOM", self.Description, "TOP", 0, 6)
	self.StatusBar:SetHeight(20)
	self.StatusBar:SetWidth(self.Description:GetWidth())
	self.StatusBar:SetStatusBarColor(r, g, b)
	self.StatusBar:SetMinMaxValues(0, self.MaxStepNumber)
	self.StatusBar:SetValue(0)
	self.StatusBar:CreateBorder()

	self.StatusBar.Anim = CreateAnimationGroup(self.StatusBar):CreateAnimation("Progress")
	self.StatusBar.Anim:SetDuration(0.3)
	self.StatusBar.Anim:SetSmoothing("InOut")

	self.StatusBar.Anim2 = CreateAnimationGroup(self.StatusBar):CreateAnimation("Color")
	self.StatusBar.Anim2:SetDuration(0.3)
	self.StatusBar.Anim2:SetSmoothing("InOut")
	self.StatusBar.Anim2:SetColorType("StatusBar")

	self.StatusBar.text = self.StatusBar:CreateFontString(nil, "OVERLAY")
	self.StatusBar.text:SetFontObject(InstallFont)
	self.StatusBar.text:SetPoint("CENTER")
	self.StatusBar.text:SetText(self.CurrentStep.." / "..self.MaxStepNumber)

	self.Logo = self.StatusBar:CreateTexture(nil, "OVERLAY")
	self.Logo:SetSize(512, 256)
	self.Logo:SetBlendMode("ADD")
	self.Logo:SetAlpha(0.07)
	self.Logo:SetTexture(C["Media"].Logo)
	self.Logo:SetPoint("CENTER", self.Description, "CENTER", 0, 0)

	self.LeftButton = CreateFrame("Button", nil, self)
	self.LeftButton:SetPoint("TOPLEFT", self.Description, "BOTTOMLEFT", 0, -6)
	self.LeftButton:SetSize(128, 25)
	self.LeftButton:SkinButton()
	self.LeftButton.Text = self.LeftButton:CreateFontString(nil, "OVERLAY")
	self.LeftButton.Text:SetFontObject(InstallFont)
	self.LeftButton.Text:SetPoint("CENTER")
	self.LeftButton.Text:SetText("|cffff2020"..CLOSE.."|r")
	self.LeftButton:SetScript("OnClick", function() self:Hide() end)

	self.RightButton = CreateFrame("Button", nil, self)
	self.RightButton:SetPoint("TOPRIGHT", self.Description, "BOTTOMRIGHT", 0, -6)
	self.RightButton:SetSize(128, 25)
	self.RightButton:SkinButton()
	self.RightButton.Text = self.RightButton:CreateFontString(nil, "OVERLAY")
	self.RightButton.Text:SetFontObject(InstallFont)
	self.RightButton.Text:SetPoint("CENTER")
	self.RightButton.Text:SetText("|cffffd200"..NEXT.."|r")
	self.RightButton:SetScript("OnClick", function()
		self.PrintStep(self, self.CurrentStep + 1)
	end)

	self.DiscordButton = CreateFrame("Button", nil, self)
	self.DiscordButton:SetPoint("TOPLEFT", self.LeftButton, "TOPRIGHT", 6, 0)
	self.DiscordButton:SetPoint("BOTTOMRIGHT", self.RightButton, "BOTTOMLEFT", -6, 0)
	self.DiscordButton:SkinButton()
	self.DiscordButton.Text = self.DiscordButton:CreateFontString(nil, "OVERLAY")
	self.DiscordButton.Text:SetFontObject(InstallFont)
	self.DiscordButton.Text:SetPoint("CENTER")
	self.DiscordButton.Text:SetText(L["Discord"])
	self.DiscordButton:SetScript("OnClick", function()
		K.StaticPopup_Show("DISCORD_EDITBOX", nil, nil, L["Discord URL"])
	end)
	self.DiscordButton:Hide()

	self.MiddleButton = CreateFrame("Button", nil, self)
	self.MiddleButton:SetPoint("TOPLEFT", self.LeftButton, "TOPRIGHT", 6, 0)
	self.MiddleButton:SetPoint("BOTTOMRIGHT", self.RightButton, "BOTTOMLEFT", -6, 0)
	self.MiddleButton:SkinButton()
	self.MiddleButton.Text = self.MiddleButton:CreateFontString(nil, "OVERLAY")
	self.MiddleButton.Text:SetFontObject(InstallFont)
	self.MiddleButton.Text:SetPoint("CENTER")
	self.MiddleButton.Text:SetText("|cffFF0000"..RESET_TO_DEFAULT.."|r")
	self.MiddleButton:SetScript("OnClick", self.ResetData)
	if (_G.KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete) then
		self.MiddleButton:Show()
	else
		self.MiddleButton:Hide()
	end

	self.SkipButton = CreateFrame("Button", nil, self)
	self.SkipButton:SetPoint("TOPLEFT", self.LeftButton, "TOPRIGHT", 6, 0)
	self.SkipButton:SetPoint("BOTTOMRIGHT", self.RightButton, "BOTTOMLEFT", -6, 0)
	self.SkipButton:SkinButton()
	self.SkipButton.Text = self.SkipButton:CreateFontString(nil, "OVERLAY")
	self.SkipButton.Text:SetFontObject(InstallFont)
	self.SkipButton.Text:SetPoint("CENTER")
	self.SkipButton.Text:SetText(format("|cff%02x%02x%02x%s|r", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255, L["Skip Install"]))
	self.SkipButton:SetScript("OnClick", function()
		_G.KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete = true
		PlaySound(19092) -- VO_PCGoblinMale_Cry
		ReloadUI()
	end)

	if (not _G.KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete) then
		self.SkipButton:Show()
	else
		self.SkipButton:Hide()
	end

	self.CloseButton = CreateFrame("Button", nil, self, "UIPanelCloseButton")
	self.CloseButton:SetPoint("TOPRIGHT", self.Description, "TOPRIGHT")
	self.CloseButton:SetScript("OnClick", function() self:Hide() end)
	self.CloseButton:SetFrameLevel(self:GetFrameLevel() + 2) -- Fix The Close Button Falling Behind Install Frame
	self.CloseButton:SkinCloseButton()

	self.Text = self.Description:CreateFontString(nil, "OVERLAY")
	self.Text:SetSize(self.Description:GetWidth() - 40, self.Description:GetHeight() - 60)
	self.Text:SetJustifyH("LEFT")
	self.Text:SetJustifyV("TOP")
	self.Text:SetFontObject(InstallFont)
	self.Text:SetFont(select(1, self.Text:GetFont()), 14, select(3, self.Text:GetFont()))
	self.Text:SetPoint("TOPLEFT", 20, -40)
	self.Text:SetText(L["Step 0"])

	self:SetAllPoints(UIParent)
end

function Install:WelcomeMessageDelay()
	UIErrorsFrame:AddMessage(K.Welcome)
end

-- On login function
Install:RegisterEvent("ADDON_LOADED")
Install:SetScript("OnEvent", function(self, _, name)
	if (name ~= "KkthnxUI") then
		return
	end

	local playerName = UnitName("player")
	local playerRealm = GetRealmName()

	-- Define the saved variables first. This is important
	if (not _G.KkthnxUIData) then
		_G.KkthnxUIData = _G.KkthnxUIData or {}
	end

	-- Create missing entries in the saved vars if they don"t exist.
	if (not _G.KkthnxUIData[playerRealm]) then
		_G.KkthnxUIData[playerRealm] = _G.KkthnxUIData[playerRealm] or {}
	end

	if (not _G.KkthnxUIData[playerRealm][playerName]) then
		_G.KkthnxUIData[playerRealm][playerName] = _G.KkthnxUIData[playerRealm][playerName] or {}
	end

	if (_G.KkthnxUIDataPerChar) then
		_G.KkthnxUIData[playerRealm][playerName] = _G.KkthnxUIDataPerChar
		_G.KkthnxUIDataPerChar = nil
	end

	if (not _G.KkthnxUIData[playerRealm][playerName].UIScale) then
		_G.KkthnxUIData[playerRealm][playerName].UIScale = _G.KkthnxUIData[playerRealm][playerName].UIScale or 0.71111
	end

	if (not _G.KkthnxUIData[playerRealm][playerName].LockUIScale) then
		_G.KkthnxUIData[playerRealm][playerName].LockUIScale = _G.KkthnxUIData[playerRealm][playerName].LockUIScale or false
	end

	if (not _G.KkthnxUIData[playerRealm][playerName].RevealWorldMap) then
		_G.KkthnxUIData[playerRealm][playerName].RevealWorldMap = _G.KkthnxUIData[playerRealm][playerName].RevealWorldMap or false
	end

	if (not _G.KkthnxUIData[playerRealm][playerName].AutoInvite) then
		_G.KkthnxUIData[playerRealm][playerName].AutoInvite = _G.KkthnxUIData[playerRealm][playerName].AutoInvite or false
	end

	if (not _G.KkthnxUIData[playerRealm][playerName].AutoQuest) then
		_G.KkthnxUIData[playerRealm][playerName].AutoQuest = _G.KkthnxUIData[playerRealm][playerName].AutoQuest or false
	end

	if (not _G.KkthnxUIData[playerRealm][playerName].BindType) then
		_G.KkthnxUIData[playerRealm][playerName].BindType = _G.KkthnxUIData[playerRealm][playerName].BindType or 1
	end

	if (not _G.KkthnxUIData[playerRealm][playerName].WatchedMovies) then
		_G.KkthnxUIData[playerRealm][playerName].WatchedMovies = _G.KkthnxUIData[playerRealm][playerName].WatchedMovies or {}
	end

	if (not _G.KkthnxUIData[playerRealm][playerName]["Mover"]) then
		_G.KkthnxUIData[playerRealm][playerName]["Mover"] = _G.KkthnxUIData[playerRealm][playerName]["Mover"] or {}
	end

	if (_G.KkthnxUIData and _G.KkthnxUIData[playerRealm] and _G.KkthnxUIData[playerRealm][playerName] and _G.KkthnxUIData[playerRealm][playerName].Movers) then
		_G.KkthnxUIData[playerRealm][playerName]["Mover"] = _G.KkthnxUIData[playerRealm][playerName].Movers
		_G.KkthnxUIData[playerRealm][playerName].Movers = nil
	end

	-- Install default if we never ran KkthnxUI on this character.
	local IsInstalled = _G.KkthnxUIData[playerRealm][playerName].InstallComplete
	if (not IsInstalled) then
		self:Launch()
	end

	-- Welcome message
	if (not _G.KkthnxUIData[playerRealm][playerName].InstallComplete) then
		K.Delay(8, Install.WelcomeMessageDelay)
	end

	self:UnregisterEvent("ADDON_LOADED")
end)

Install.CreateUIScale:RegisterEvent("PLAYER_LOGIN")
Install.CreateUIScale:SetScript("OnEvent", function(self)
	SetupUIScale()
	self:RegisterEvent("UI_SCALE_CHANGED", SetupUIScale)
end)

_G.SLASH_INSTALLUI1 = "/install"
SlashCmdList["INSTALLUI"] = function()
	Install:Launch()
end

_G.SLASH_RESETUI1 = "/reset"
SlashCmdList["RESETUI"] = function()
	K.StaticPopup_Show("RESET_UI")
end

_G.SLASH_DISABLEUI1 = "/disable"
SlashCmdList["DISABLEUI"] = function()
	K.StaticPopup_Show("DISABLE_UI")
end

K["Install"] = Install