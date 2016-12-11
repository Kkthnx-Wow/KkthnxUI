local K, C, L = unpack(select(2, ...))

local ipairs = ipairs
local format, sub, split = string.format, string.sub, string.split
local MAX_WATCHED_TOKENS = MAX_WATCHED_TOKENS
local GetBackpackCurrencyInfo = GetBackpackCurrencyInfo
local InCombatLockdown = InCombatLockdown
local GetProfessions = GetProfessions

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local Data

local OnMouseDown = function()
	ToggleCharacter("TokenFrame")
end

local OnEvent = function(self)
	local Text = NameColor .. CURRENCY .. '|r'
	self.Text:SetFormattedText(NameColor .. CURRENCY .. "|r")
end

local Update = function(self)
	local Text = NameColor .. CURRENCY .. '|r'
	self.Text:SetFormattedText(NameColor .. CURRENCY .. "|r")
end

local OnEnter = function(self)
	if (InCombatLockdown()) then
		return
	end

	local prof1, prof2, archaeology, _, cooking = GetProfessions()

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine(CURRENCY .. ": ")

	if archaeology then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(PROFESSIONS_ARCHAEOLOGY .. ": ")
		K.Currency(384) -- Dwarf
		K.Currency(385) -- Troll
		K.Currency(393) -- Fossil
		K.Currency(394) -- Night Elf
		K.Currency(397) -- Orc
		K.Currency(398) -- Draenei
		K.Currency(399) -- Vyrkul
		K.Currency(400) -- Nerubian
		K.Currency(401) -- Tol'vir
		K.Currency(676) -- Pandaren
		K.Currency(677) -- Mogu
		K.Currency(754) -- Mantid
		K.Currency(821) -- Draenor Clans
		K.Currency(828) -- Ogre
		K.Currency(829) -- Arakkoa
		K.Currency(1172) -- Highborne
		K.Currency(1173) -- Highmountain
		K.Currency(1174) -- Demonic
	end

	if cooking then
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(PROFESSIONS_COOKING .. ": ")
		K.Currency(81)
		K.Currency(402)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Professions")
	K.Currency(61)
	K.Currency(361)
	K.Currency(910)
	K.Currency(980)
	K.Currency(999)
	K.Currency(1008)
	K.Currency(1017)
	K.Currency(1020)

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Garrison")
	K.Currency(824)
	K.Currency(1101)
	K.Currency(1220)

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Raid: ")
	K.Currency(1191, false, true)
	K.Currency(1129, false, true)
	K.Currency(994, false, true)
	K.Currency(776, false, true)
	K.Currency(752, false, true)
	K.Currency(697, false, true)
	K.Currency(738)
	K.Currency(615)
	K.Currency(614)
	K.Currency(823)
	K.Currency(1166)
	K.Currency(1155, false, true)
	K.Currency(1273, false, true)

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(PVP_FLAG)
	K.Currency(390, true)
	K.Currency(391)
	K.Currency(392, false, true)
	K.Currency(944)
	K.Currency(1268)

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(MISCELLANEOUS)
	K.Currency(241)
	K.Currency(416)
	K.Currency(515)
	K.Currency(777)
	K.Currency(1149, false, true)
	K.Currency(1154, false, true)
	K.Currency(1226)
	K.Currency(1275)

	GameTooltip:Show()
end

local Enable = function(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", OnUpdate)
	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnMouseDown", nil)
end

DataText:Register(CURRENCY, Enable, Disable, OnEvent, OnEnter)
