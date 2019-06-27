local K, C, L = unpack(select(2, ...))
local AFK = K:GetModule("AFKCam")

if not AFK then
	return
end

-- Cache global variables
-- Lua Variables
local tonumber = tonumber
local format = string.format
local date = date
-- WoW API / Variables
local CreateFrame = CreateFrame
local GetGameTime = GetGameTime
local GetScreenWidth, GetScreenHeight = GetScreenWidth, GetScreenHeight
local GetGuildInfo = GetGuildInfo
local IsInGuild = IsInGuild
local TIMEMANAGER_TOOLTIP_LOCALTIME = TIMEMANAGER_TOOLTIP_LOCALTIME

local function Player_Model(self)
	self:ClearModel()
	self:SetUnit("player")
	self:SetFacing(1)
	self:SetCamDistanceScale(8)
	self:SetAlpha(1)
	self:SetAnimation(71)
end

-- Create Time
local function createTime()
	local hour, hour24, minute, ampm = tonumber(date("%I")), tonumber(date("%H")), tonumber(date("%M")), date("%p"):lower()
	local sHour, sMinute = GetGameTime()

	local localTime = format("|cffb3b3b3%s|r %d|cFF00c0fa:|r%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_LOCALTIME, hour, minute, ampm)
	local localTime24 = format("|cffb3b3b3%s|r %02d|cFF00c0fa:|r%02d", TIMEMANAGER_TOOLTIP_LOCALTIME, hour24, minute)
	local realmTime = format("|cffb3b3b3%s|r %d|cFF00c0fa:|r%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute, ampm)
	local realmTime24 = format("|cffb3b3b3%s|r %02d|cFF00c0fa:|r%02d", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute)

	if C["DataText"].LocalTime then
		if C["DataText"].Time24Hr then
			return localTime24
		else
			return localTime
		end
	else
		if C["DataText"].Time24Hr then
			return realmTime24
		else
			return realmTime
		end
	end
end

function AFK:UpdateLogOff()
	local timePassed = GetTime() - self.startTime
	local minutes = floor(timePassed/60)
	local neg_seconds = -timePassed % 60

	if minutes - 29 == 0 and floor(neg_seconds) == 0 then
		self:CancelTimer(self.logoffTimer)
		self.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff0000:00|r", "Logout Timer")
	else
		self.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00%02d:%02d|r", "Logout Timer", minutes -29, neg_seconds)
	end
end

local function SetAFK(status)
	if C["Misc"].AFKCamera ~= true then return end

	local guildName = GetGuildInfo("player") or ""
	if(status) then
		if(IsInGuild()) then
			AFK.AFKMode.bottomPanel.guild:SetText("|cFF00c0fa<".. guildName ..">|r")
		else
			AFK.AFKMode.bottomPanel.guild:SetText("No Guild")
		end
		AFK.startTime = GetTime()
		AFK.logoffTimer = AFK:ScheduleRepeatingTimer("UpdateLogOff", 1)

		AFK.isAFK = true
	elseif(AFK.isAFK) then
		AFK:CancelTimer(AFK.logoffTimer)
		AFK.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00-30:00|r", "Logout Timer")

		AFK.isAFK = false
	end
end
hooksecurefunc(AFK, "SetAFK", SetAFK)

local function UpdateTimer()
	if C["Misc"].AFKCamera ~= true then return end
	local createdTime = createTime()

	-- Set time
	AFK.AFKMode.topPanel.time:SetFormattedText(createdTime)
end
hooksecurefunc(AFK, "UpdateTimer", UpdateTimer)

local function Initialize()
	if C["Misc"].AFKCamera ~= true then return end

	-- Hide ElvUI Elements
	AFK.AFKMode.bottom:Hide() -- Bottom panel

	-- Bottom Panel
	AFK.AFKMode.bottomPanel = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.bottomPanel:SetFrameLevel(0)
	AFK.AFKMode.bottomPanel:SetPoint("BOTTOM", AFK.AFKMode, "BOTTOM", 0, -2)
	AFK.AFKMode.bottomPanel:SetWidth(GetScreenWidth() + (2*2))
	AFK.AFKMode.bottomPanel:SetHeight(GetScreenHeight() * (1 / 10))
	AFK.AFKMode.bottomPanel:CreateBorder()

	-- Bottom Panel Style
	AFK.AFKMode.bottomPanel.topLeftStyle = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.bottomPanel.topLeftStyle:SetFrameLevel(2)
	AFK.AFKMode.bottomPanel.topLeftStyle:SetPoint("TOPLEFT", AFK.AFKMode.bottomPanel, "TOPLEFT", 10, 2)
	AFK.AFKMode.bottomPanel.topLeftStyle:SetSize(K.ScreenWidth*2/9, 4)
	--MERS:SkinPanel(AFK.AFKMode.bottomPanel.topLeftStyle)

	AFK.AFKMode.bottomPanel.topRightStyle = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.bottomPanel.topRightStyle:SetFrameLevel(2)
	AFK.AFKMode.bottomPanel.topRightStyle:SetPoint("TOPRIGHT", AFK.AFKMode.bottomPanel, "TOPRIGHT", -10, 2)
	AFK.AFKMode.bottomPanel.topRightStyle:SetSize(K.ScreenWidth*2/9, 4)
	--MERS:SkinPanel(AFK.AFKMode.bottomPanel.topRightStyle)

	-- Bottom AFK Title
	AFK.AFKMode.bottomPanel.AFKtitle = AFK.AFKMode.bottomPanel:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.bottomPanel.AFKtitle:FontTemplate(nil, 20)
	AFK.AFKMode.bottomPanel.AFKtitle:SetText("|cFF00c0fa".."Are you still there? ... Hello?".."|r")
	AFK.AFKMode.bottomPanel.AFKtitle:SetPoint("BOTTOM", AFK.AFKMode.bottomPanel, "BOTTOM", 0, 10)

	local className = K.Class
	AFK.AFKMode.bottomPanel.faction = AFK.AFKMode.bottomPanel:CreateTexture(nil, "OVERLAY")
	AFK.AFKMode.bottomPanel.faction:SetPoint("RIGHT", AFK.AFKMode.bottomPanel, "LEFT", 90, 10)
	AFK.AFKMode.bottomPanel.faction:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\classIcons\\CLASS-"..className)
	AFK.AFKMode.bottomPanel.faction:SetSize(80, 80)

	-- Bottom Player Name
	AFK.AFKMode.bottomPanel.name = AFK.AFKMode.bottomPanel:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.bottomPanel.name:FontTemplate(nil, 22)
	AFK.AFKMode.bottomPanel.name:SetFormattedText("%s", K.Name)
	AFK.AFKMode.bottomPanel.name:SetPoint("LEFT", AFK.AFKMode.bottomPanel.faction, "RIGHT", 0, 10)
	AFK.AFKMode.bottomPanel.name:SetTextColor(0.7, 0.7, 0.7)
	AFK.AFKMode.bottomPanel.name:SetShadowOffset(2, -2)

	-- Bottom Guild Name
	AFK.AFKMode.bottomPanel.guild = AFK.AFKMode.bottomPanel:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.bottomPanel.guild:FontTemplate(nil, 16)
	AFK.AFKMode.bottomPanel.guild:SetPoint("TOPLEFT", AFK.AFKMode.bottomPanel.name, "BOTTOMLEFT", -5, -6)
	AFK.AFKMode.bottomPanel.guild:SetText("No Guild")

	-- Top Panel
	AFK.AFKMode.topPanel = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.topPanel:SetFrameLevel(0)
	AFK.AFKMode.topPanel:SetPoint("TOP", AFK.AFKMode, "TOP", 0, 2)
	AFK.AFKMode.topPanel:SetWidth(GetScreenWidth() + (2*2))
	AFK.AFKMode.topPanel:SetHeight(GetScreenHeight() * (1 / 10))
	AFK.AFKMode.topPanel:CreateBorder()

	-- Top Panel Style
	AFK.AFKMode.topPanel.topLeftStyle = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.topPanel.topLeftStyle:SetFrameLevel(2)
	AFK.AFKMode.topPanel.topLeftStyle:SetPoint("BOTTOMLEFT", AFK.AFKMode.topPanel, "BOTTOMLEFT", 10, -2)
	AFK.AFKMode.topPanel.topLeftStyle:SetSize(K.ScreenWidth*2/9, 4)
	--MERS:SkinPanel(AFK.AFKMode.topPanel.topLeftStyle)

	AFK.AFKMode.topPanel.topRightStyle = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.topPanel.topRightStyle:SetFrameLevel(2)
	AFK.AFKMode.topPanel.topRightStyle:SetPoint("BOTTOMRIGHT", AFK.AFKMode.topPanel, "BOTTOMRIGHT", -10, -2)
	AFK.AFKMode.topPanel.topRightStyle:SetSize(K.ScreenWidth*2/9, 4)
	--MERS:SkinPanel(AFK.AFKMode.topPanel.topRightStyle)

	-- ElvUI Logo
	AFK.AFKMode.bottom.logo:ClearAllPoints()
	AFK.AFKMode.bottom.logo:SetParent(AFK.AFKMode.topPanel)
	AFK.AFKMode.bottom.logo:SetPoint("LEFT", AFK.AFKMode.topPanel, "LEFT", 25, 8)
	AFK.AFKMode.bottom.logo:SetSize(120, 55)

	-- ElvUI Version
	AFK.AFKMode.topPanel.eversion = AFK.AFKMode.topPanel:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.topPanel.eversion:FontTemplate(nil, 10)
	AFK.AFKMode.topPanel.eversion:SetText("|cFF00c0fa"..K.Version.."|r")
	AFK.AFKMode.topPanel.eversion:SetPoint("TOP", AFK.AFKMode.bottom.logo, "BOTTOM")
	AFK.AFKMode.topPanel.eversion:SetTextColor(0.7, 0.7, 0.7)

	-- Time
	AFK.AFKMode.topPanel.time = AFK.AFKMode.topPanel:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.topPanel.time:FontTemplate(nil, 16)
	AFK.AFKMode.topPanel.time:SetText("")
	AFK.AFKMode.topPanel.time:SetPoint("CENTER", AFK.AFKMode.topPanel, "CENTER", 0, 0)
	AFK.AFKMode.topPanel.time:SetJustifyH("CENTER")
	AFK.AFKMode.topPanel.time:SetTextColor(0.7, 0.7, 0.7)

	-- Logout Count
	AFK.AFKMode.countd = CreateFrame("Frame", nil, AFK.AFKMode)
	AFK.AFKMode.countd:SetSize(418, 36)
	AFK.AFKMode.countd:SetPoint("CENTER", AFK.AFKMode, "CENTER", 0, 100)

	AFK.AFKMode.countd.bg = AFK.AFKMode.countd:CreateTexture(nil, "BACKGROUND")
	AFK.AFKMode.countd.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.countd.bg:SetPoint("BOTTOM")
	AFK.AFKMode.countd.bg:SetSize(326, 56)
	AFK.AFKMode.countd.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	AFK.AFKMode.countd.bg:SetVertexColor(1, 1, 1, 0.7)

	AFK.AFKMode.countd.lineTop = AFK.AFKMode.countd:CreateTexture(nil, "BACKGROUND")
	AFK.AFKMode.countd.lineTop:SetDrawLayer("BACKGROUND", 2)
	AFK.AFKMode.countd.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.countd.lineTop:SetPoint("TOP")
	AFK.AFKMode.countd.lineTop:SetSize(418, 7)
	AFK.AFKMode.countd.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	AFK.AFKMode.countd.lineBottom = AFK.AFKMode.countd:CreateTexture(nil, "BACKGROUND")
	AFK.AFKMode.countd.lineBottom:SetDrawLayer("BACKGROUND", 2)
	AFK.AFKMode.countd.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	AFK.AFKMode.countd.lineBottom:SetPoint("BOTTOM")
	AFK.AFKMode.countd.lineBottom:SetSize(418, 7)
	AFK.AFKMode.countd.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	-- 30 mins countdown text
	AFK.AFKMode.countd.text = AFK.AFKMode.countd:CreateFontString(nil, "OVERLAY")
	AFK.AFKMode.countd.text:FontTemplate(nil, 12)
	AFK.AFKMode.countd.text:SetPoint("CENTER", AFK.AFKMode.countd, "CENTER", 0, -2)
	AFK.AFKMode.countd.text:SetJustifyH("CENTER")
	AFK.AFKMode.countd.text:SetJustifyV("CENTER")
	AFK.AFKMode.countd.text:SetFormattedText("%s: |cfff0ff00-30:00|r", "Logout Timer")
	AFK.AFKMode.countd.text:SetTextColor(0.7, 0.7, 0.7)

	-- Player Model
	if not modelHolder then
		local modelHolder = CreateFrame("Frame", nil, AFK.AFKMode.bottomPanel)
		modelHolder:SetSize(150, 150)
		modelHolder:SetPoint("BOTTOMRIGHT", AFK.AFKMode.bottomPanel, "BOTTOMRIGHT", -200, 180)

		playerModel = CreateFrame("PlayerModel", nil, modelHolder)
		playerModel:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2) --YES, double screen size. This prevents clipping of models.
		playerModel:SetPoint("CENTER", modelHolder, "CENTER")
		playerModel:SetScript("OnShow", Player_Model)
		playerModel:SetFrameLevel(3)
		playerModel.isIdle = nil

		-- Speech Bubble
		playerModel.tex = playerModel:CreateTexture(nil, "BACKGROUND")
		playerModel.tex:SetPoint("TOP", modelHolder, "TOP", 30, 80)
		playerModel.tex:SetTexture("Interface\\AddOns\\ElvUI_MerathilisUI\\media\\textures\\bubble.blp")

		playerModel.tex.text = playerModel:CreateFontString(nil, "OVERLAY")
		playerModel.tex.text:FontTemplate(nil, 20)
		playerModel.tex.text:SetText("AFK ... maybe!?")
		playerModel.tex.text:SetPoint("CENTER", playerModel.tex, "CENTER", 0, 10)
		playerModel.tex.text:SetJustifyH("CENTER")
		playerModel.tex.text:SetJustifyV("CENTER")
		playerModel.tex.text:SetTextColor(0.7, 0.7, 0.7)
		playerModel.tex.text:SetShadowOffset(2, -2)
	end
end

hooksecurefunc(AFK, "OnInitialize", Initialize)