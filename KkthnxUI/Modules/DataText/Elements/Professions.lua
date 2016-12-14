local K, C, L = unpack(select(2, ...))

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local format = string.format

local function OnMouseDown(self, btn)
	if(btn ~= "LeftButton") then
		return
	end

	securecall(ToggleSpellBook, BOOKTYPE_PROFESSION)
end

local function OnEnter(self)
	if(InCombatLockdown()) then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine(TRADE_SKILLS)
	GameTooltip:AddLine(" ")

	for _, v in pairs({GetProfessions() }) do
		if(v ~= nil) then
			local Name, Texture, Rank, MaxRank = GetProfessionInfo(v)
			GameTooltip:AddDoubleLine("\124T" .. Texture .. ":12\124t " .. NameColor .. Name .. "|r", ValueColor .. Rank .. " / " .. MaxRank .. "|r")
		end
	end

	GameTooltip:Show()
end

local function Update(self)
	for _, v in pairs({GetProfessions() }) do
		if(v ~= nil) then
			local name, texture, rank, maxRank = GetProfessionInfo(v)
			self.Text:SetText(NameColor .. TRADE_SKILLS .."|r")
		end
	end
end

local function Enable(self)
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_STATS")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
end

DataText:Register(TRADE_SKILLS, Enable, Disable, Update)