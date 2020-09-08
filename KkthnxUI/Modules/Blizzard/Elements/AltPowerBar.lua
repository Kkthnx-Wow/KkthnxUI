local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local floor = _G.math.floor
local format = _G.string.format

local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetUnitPowerBarInfo = _G.GetUnitPowerBarInfo
local GetUnitPowerBarStrings = _G.GetUnitPowerBarStrings
local UnitPower = _G.UnitPower
local UnitPowerMax = _G.UnitPowerMax

local statusBarColor = {r = 0.2, g = 0.4, b = 0.8}
local statusWidth = 250
local statusHeight = 20
local statusBar = K.GetTexture(C["UITextures"].GeneralTextures)
local font = K.GetFont(C["UIFonts"].GeneralFonts)

local function updateTooltip(self)
	if GameTooltip:IsForbidden() then
		return
	end

	if self.powerName and self.powerTooltip then
		GameTooltip:SetText(self.powerName, 1, 1, 1)
		GameTooltip:AddLine(self.powerTooltip, nil, nil, nil, 1)
		GameTooltip:Show()
	end
end

local function onEnter(self)
	if (not self:IsVisible()) or _G.GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:ClearAllPoints()
	GameTooltip_SetDefaultAnchor(_G.GameTooltip, self)
	updateTooltip(self)
end

local function onLeave()
	GameTooltip:Hide()
end

function Module:SetAltPowerBarText(text, name, value, max)
	text:SetText(format("%s: %s / %s", name, value, max))
end

function Module:PositionAltPowerBar()
	local holder = CreateFrame("Frame", "AltPowerBarHolder", UIParent)
	holder:SetPoint("TOP", UIParent, "TOP", 0, -46)
	holder:SetSize(128, 50)

	_G.PlayerPowerBarAlt:ClearAllPoints()
	_G.PlayerPowerBarAlt:SetPoint("CENTER", holder, "CENTER")
	_G.PlayerPowerBarAlt:SetParent(holder)
	_G.PlayerPowerBarAlt:SetMovable(true)
	_G.PlayerPowerBarAlt:SetUserPlaced(true)
	_G.UIPARENT_MANAGED_FRAME_POSITIONS.PlayerPowerBarAlt = nil

	K.Mover(holder, "PlayerPowerBarAlt", "Alternative Power", {"TOP", UIParent, "TOP", 0, -46}, statusWidth or 250, statusHeight or 20)
end

function Module:UpdateAltPowerBarColors()
	_G.KKUI_AltPowerBar:SetStatusBarColor(statusBarColor.r, statusBarColor.g, statusBarColor.b)
end

function Module:UpdateAltPowerBarSettings()
	local bar = _G.KKUI_AltPowerBar

	bar:SetSize(statusWidth or 250, statusHeight or 20)
	bar:SetStatusBarTexture(statusBar)
	bar.text:SetFontObject(font)
	AltPowerBarHolder:SetSize(bar.Backdrop:GetSize())

	Module:SetAltPowerBarText(bar.text, bar.powerName or "", bar.powerValue or 0, bar.powerMaxValue or 0, bar.powerPercent or 0)
end

function Module:UpdateAltPowerBar()
	_G.PlayerPowerBarAlt:UnregisterAllEvents()
	_G.PlayerPowerBarAlt:Hide()

	local barInfo = GetUnitPowerBarInfo("player");
	local powerName, powerTooltip = GetUnitPowerBarStrings("player");
	if barInfo then
		local power = UnitPower("player", _G.ALTERNATE_POWER_INDEX)
		local maxPower = UnitPowerMax("player", _G.ALTERNATE_POWER_INDEX) or 0
		local perc = (maxPower > 0 and floor(power / maxPower * 100)) or 0

		self.powerMaxValue = maxPower
		self.powerName = powerName
		self.powerPercent = perc
		self.powerTooltip = powerTooltip
		self.powerValue = power

		self:Show()
		self:SetMinMaxValues(barInfo.minPower, maxPower)
		self:SetValue(power)

		if barInfo.ID == 554 then -- Sanity 8.3: N"Zoth Eye
			self.textures:Show()
		else
			self.textures:Hide()
		end

		Module:SetAltPowerBarText(self.text, powerName or "", power or 0, maxPower, perc)
	else
		self.powerMaxValue = nil
		self.powerName = nil
		self.powerPercent = nil
		self.powerTooltip = nil
		self.powerValue = nil

		self.textures:Hide()
		self:Hide()
	end
end

function Module:SkinAltPowerBar()
	local powerbar = CreateFrame("StatusBar", "KKUI_AltPowerBar", UIParent)
	powerbar:CreateBackdrop()
	powerbar.Backdrop:SetFrameLevel(1)
	powerbar:SetMinMaxValues(0, 200)
	powerbar:SetPoint("CENTER", AltPowerBarHolder)
	powerbar:Hide()

	powerbar:SetScript("OnEnter", onEnter)
	powerbar:SetScript("OnLeave", onLeave)

	powerbar.text = powerbar:CreateFontString(nil, "OVERLAY")
	powerbar.text:SetPoint("CENTER", powerbar, "CENTER")
	powerbar.text:SetJustifyH("CENTER")

	do -- NZoth textures
		local texTop = powerbar:CreateTexture(nil, "OVERLAY")
		local texBotomLeft = powerbar:CreateTexture(nil, "OVERLAY")
		local texBottomRight = powerbar:CreateTexture(nil, "OVERLAY")

		powerbar.textures = {
			TOP = texTop, BOTTOMLEFT = texBotomLeft, BOTTOMRIGHT = texBottomRight,
			Show = function()
				texTop:Show()
				texBotomLeft:Show()
				texBottomRight:Show()
			end,
			Hide = function()
				texTop:Hide()
				texBotomLeft:Hide()
				texBottomRight:Hide()
			end,
		}

		texTop:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\NZothTop]])
		texTop:SetPoint("CENTER", powerbar, "TOP", 0, -19)
		texBotomLeft:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\NZothBottomLeft]])
		texBotomLeft:SetPoint("BOTTOMLEFT", powerbar, "BOTTOMLEFT", -7, -10)
		texBottomRight:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\NZothBottomRight]])
		texBottomRight:SetPoint("BOTTOMRIGHT", powerbar, "BOTTOMRIGHT", 7, -10)
	end

	Module:UpdateAltPowerBarSettings()
	Module:UpdateAltPowerBarColors()

	-- Event handling
	powerbar:RegisterEvent("UNIT_POWER_UPDATE")
	powerbar:RegisterEvent("UNIT_POWER_BAR_SHOW")
	powerbar:RegisterEvent("UNIT_POWER_BAR_HIDE")
	powerbar:RegisterEvent("PLAYER_ENTERING_WORLD")
	powerbar:SetScript("OnEvent", Module.UpdateAltPowerBar)
end

function Module:CreateAltPowerbar()
	if not IsAddOnLoaded("SimplePowerBar") then
		self:PositionAltPowerBar()
		self:SkinAltPowerBar()
	end
end