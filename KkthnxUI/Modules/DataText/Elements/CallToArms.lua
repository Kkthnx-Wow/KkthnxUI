local K, C, L = select(2, ...):unpack()

local format = string.format
local GetNumRandomDungeons = GetNumRandomDungeons
local GetLFGRandomDungeonInfo = GetLFGRandomDungeonInfo
local LFG_ROLE_NUM_SHORTAGE_TYPES = LFG_ROLE_NUM_SHORTAGE_TYPES
local GetLFGRoleShortageRewards = GetLFGRoleShortageRewards
local InCombatLockdown = InCombatLockdown

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local Result = " %s %s %s"

local TANK_ICON = "|TInterface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp:14:14:0:0:64:64:0:18:22:40|t"
local HEALER_ICON = "|TInterface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp:14:14:0:0:64:64:20:38:1:19|t"
local DPS_ICON = "|TInterface\\LFGFRAME\\UI-LFG-ICON-PORTRAITROLES.blp:14:14:0:0:64:64:20:38:22:40|t"

local MakeString = function(tank, healer, damage)
	local strtank = ""
	local strheal = ""
	local strdps = ""

	if (tank) then
		strtank = TANK_ICON
	end

	if (healer) then
		strheal = HEALER_ICON
	end

	if (damage) then
		strdps = DPS_ICON
	end

	return format(Result, strtank, strheal, strdps)
end

local Update = function(self)
	local TankReward = false
	local HealerReward = false
	local DPSReward = false
	local Unavailable = true

	for i = 1, GetNumRandomDungeons() do
		local ID = GetLFGRandomDungeonInfo(i)

		for x = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local Eligible, ForTank, ForHealer, ForDamage, ItemCount = GetLFGRoleShortageRewards(ID, x)

			if (Eligible) then
				Unavailable = false
			end

			if (Eligible and ForTank and ItemCount > 0) then
				TankReward = true
			end

			if (Eligible and ForHealer and ItemCount > 0) then
				HealerReward = true
			end

			if (Eligible and ForDamage and ItemCount > 0) then
				DPSReward = true
			end
		end
	end

	if (Unavailable) then
		self.Text:SetText(NameColor .. QUEUE_TIME_UNAVAILABLE .. "|r")
	else
		if (TankReward or HealerReward or DPSReward) then
			self.Text:SetText(NameColor .. BATTLEGROUND_HOLIDAY .. ":|r" .. ValueColor .. MakeString(TankReward, HealerReward, DPSReward) .. "|r")
		else
			self.Text:SetText(NameColor .. LOOKING_FOR_DUNGEON .. "|r")
		end
	end
end

local OnEnter = function(self)
	if (InCombatLockdown()) then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine(BATTLEGROUND_HOLIDAY)
	GameTooltip:AddLine(" ")

	local AllUnavailable = true
	local NumCTA = 0

	for i = 1, GetNumRandomDungeons() do
		local ID, Name = GetLFGRandomDungeonInfo(i)
		local TankReward = false
		local HealerReward = false
		local DPSReward = false
		local Unavailable = true

		for x = 1, LFG_ROLE_NUM_SHORTAGE_TYPES do
			local Eligible, ForTank, ForHealer, ForDamage, ItemCount = GetLFGRoleShortageRewards(ID, x)

			if (Eligible) then
				Unavailable = false
			end

			if (Eligible and ForTank and ItemCount > 0) then
				TankReward = true
			end

			if (Eligible and ForHealer and ItemCount > 0) then
				HealerReward = true
			end

			if (Eligible and ForDamage and ItemCount > 0) then
				DPSReward = true
			end
		end

		if (not Unavailable) then
			AllUnavailable = false
			local RolesString = MakeString(TankReward, HealerReward, DPSReward)

			if (RolesString ~= " ") then
				GameTooltip:AddDoubleLine(Name .. ":", RolesString, 1, 1, 1)
			end

			if (TankReward or HealerReward or DPSReward) then
				NumCTA = NumCTA + 1
			end
		end
	end

	if (AllUnavailable) then
		GameTooltip:AddLine(L_DATATEXT_ARMERROR)
	elseif (NumCTA == 0) then
		GameTooltip:AddLine(L_DATATEXT_NODUNGEONARM)
	end

	GameTooltip:Show()
end

local OnMouseDown = function(self, btn)
	if (btn ~= "LeftButton") then
		return
	end

	PVEFrame_ToggleFrame()
end

local Enable = function(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("LFG_UPDATE_RANDOM_INFO")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
end

DataText:Register(BATTLEGROUND_HOLIDAY, Enable, Disable, Update)
