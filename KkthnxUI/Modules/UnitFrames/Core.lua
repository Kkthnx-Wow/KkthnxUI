local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Unitframes", "AceEvent-3.0")

-- This file ended up looking fucking horrible. This looked way better in my head.

local _, ns = ...
local oUF = ns.oUF or oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Core.lua code!")
	return
end

local _G = _G
local tostring = tostring

local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES
local InCombatLockdown = _G.InCombatLockdown

local Movers = K["Movers"]

function Module:GetPartyFramesAttributes()
	local PartyProperties = C["Unitframe"].PartyAsRaid and "custom [group:party] hide" or "custom [group:party, nogroup:raid] show; hide"

	return
	"oUF_Party",
	nil,
	PartyProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"initial-width", 140,
	"initial-height", 38,
	"showSolo", false,
	"showParty", true,
	"showPlayer", C["Unitframe"].ShowPlayer,
	"showRaid", false,
	"groupFilter", "1, 2, 3, 4, 5, 6, 7, 8",
	"groupingOrder", "TANK, HEALER, DAMAGER, NONE",
	"groupBy", "ASSIGNEDROLE",
	"yOffset", -44
end

function Module:GetPartyTargetFramesAttributes()
	local PartyTargetProperties = C["Unitframe"].PartyAsRaid and "custom [group:party] hide" or "custom [group:party, nogroup:raid] show; hide"

	return
	"oUF_PartyTarget",
	nil,
	PartyTargetProperties,
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	self:SetAttribute("unitsuffix", "target")
	]],
	"initial-width", 74,
	"initial-height", 14,
	"showSolo", false,
	"showParty", true,
	"showPlayer", C["Unitframe"].ShowPlayer,
	"showRaid", false,
	"groupBy", "ASSIGNEDROLE",
	"groupingOrder", "TANK, HEALER, DAMAGER, NONE",
	"sortMethod", "NAME",
	"yOffset", -68
end

function Module:GetDamageRaidFramesAttributes()
	local Raid = {}
	for i = 1, C["Raidframe"].RaidGroups do
		local RaidDamage = oUF:SpawnHeader("oUF_RaidDamage"..i, nil, C["Unitframe"].PartyAsRaid and "custom [group:party] show" or "custom [group:raid] show; hide",
		"oUF-initialConfigFunction", [[
		local header = self:GetParent()
		self:SetWidth(header:GetAttribute("initial-width"))
		self:SetHeight(header:GetAttribute("initial-height"))
		]],
		"initial-width", 60,
		"initial-height", 30,
		"showParty", true,
		"showRaid", true,
		"showPlayer", true,
		"showSolo", false,
		"yOffset", -6,
		"point", "TOPLEFT",
		"groupFilter", tostring(i),
		"groupBy", C["Raidframe"].GroupBy.Value and "ASSIGNEDROLE",
		"groupingOrder", C["Raidframe"].GroupBy.Value and "TANK, HEALER, DAMAGER, NONE",
		"sortMethod", C["Raidframe"].GroupBy.Value and "NAME",
		"maxColumns", 5,
		"unitsPerColumn", 1,
		"columnSpacing", 6,
		"columnAnchorPoint", "TOP")
		if i == 1 then
			RaidDamage:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -24)
		elseif i == 5 then
			RaidDamage:SetPoint("TOPLEFT", Raid[1], "TOPRIGHT", 7, 0)
		else
			RaidDamage:SetPoint("TOPLEFT", Raid[i-1], "BOTTOMLEFT", 0, -7)
		end
		Movers:RegisterFrame(RaidDamage)
		Raid[i] = RaidDamage
	end
end

function Module:GetHealerRaidFramesAttributes()
	local Raid = {}
	for i = 1, C["Raidframe"].RaidGroups do
		local RaidHealer = oUF:SpawnHeader("oUF_RaidHealer"..i, nil, C["Unitframe"].PartyAsRaid and "custom [group:party] show" or "custom [group:raid] show; hide",
		"oUF-initialConfigFunction", [[
		local header = self:GetParent()
		self:SetWidth(header:GetAttribute("initial-width"))
		self:SetHeight(header:GetAttribute("initial-height"))
		]],
		"initial-width", 60,
		"initial-height", 26,
		"showParty", true,
		"showRaid", true,
		"showPlayer", true,
		"showSolo", false,
		"groupFilter", tostring(i),
		"groupBy", C["Raidframe"].GroupBy.Value and "ASSIGNEDROLE",
		"groupingOrder", C["Raidframe"].GroupBy.Value and "TANK, HEALER, DAMAGER, NONE",
		"sortMethod", C["Raidframe"].GroupBy.Value and "NAME",
		"point", "LEFT",
		"maxColumns", 5,
		"unitsPerColumn", 1,
		"columnSpacing", 6,
		"columnAnchorPoint", "LEFT")
		if i == 1 then
			RaidHealer:SetPoint("TOPLEFT", oUF_Player, "BOTTOMRIGHT", 86, -12)
		else
			RaidHealer:SetPoint("TOPLEFT", Raid[i-1], "BOTTOMLEFT", 0, -7)
		end
		Movers:RegisterFrame(RaidHealer)
		Raid[i] = RaidHealer
	end
end

function Module:GetMainTankAttributes()
	return
	"oUF_MainTank",
	nil,
	"solo, party, raid",
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"initial-width", 62,
	"initial-height", 34,
	"showParty", false,
	"showRaid", true,
	"showPlayer", false,
	"showSolo", false,
	"groupFilter", "MAINTANK",
	"yOffset", -8,
	"template", "oUF_MainTank"
end

function Module:GetMainTankTargetAttributes()
	return
	"oUF_MainTankTarget",
	nil,
	"solo, party, raid",
	"oUF-initialConfigFunction", [[
	local header = self:GetParent()
	self:SetWidth(header:GetAttribute("initial-width"))
	self:SetHeight(header:GetAttribute("initial-height"))
	]],
	"initial-width", 62,
	"initial-height", 34,
	"showParty", false,
	"showRaid", true,
	"showPlayer", false,
	"showSolo", false,
	"groupFilter", "MAINTANK",
	"yOffset", -8,
	"template", "oUF_MainTankTarget"
end

function Module:CreateStyle(unit)
	if (not unit) then
		return
	end

	unit = unit:match("^(%a-)%d+") or unit

	if (unit == "player") then
		K.CreatePlayer(self, "player")
	elseif (unit == "target") then
		K.CreateTarget(self, "target")
	elseif (unit == "targettarget") then
		K.CreateTargetOfTarget(self, "targettarget")
	elseif (unit == "pet") then
		K.CreatePet(self, "pet")
	elseif (unit == "focus") then
		K.CreateFocus(self, "focus")
	elseif (unit == "focustarget") then
		K.CreateFocusTarget(self, "focustarget")
	elseif (unit == "arena") then
		K.CreateArena(self, "arena")
	elseif (unit == "boss") then
		K.CreateBoss(self, "boss")
	elseif (unit == "party") then
		K.CreateParty(self, "party")
	elseif (unit == "raid") then
		K.CreateRaid(self, "raid")
	end

	return self
end

function Module:CreateUnits()
	local Player = oUF:Spawn("player", "oUF_Player")
	Player:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "TOPLEFT", -10, 200)
	Player:SetParent(K.PetBattleHider)
	Player:SetSize(190, 52)

	local Target = oUF:Spawn("target", "oUF_Target")
	Target:SetPoint("BOTTOMLEFT", ActionBarAnchor, "TOPRIGHT", 10, 200)
	Target:SetParent(K.PetBattleHider)
	Target:SetSize(190, 52)

	local TargetOfTarget = oUF:Spawn("targettarget", "oUF_TargetTarget")
	TargetOfTarget:SetPoint("TOPLEFT", oUF_Target, "BOTTOMRIGHT", -56, 2)
	TargetOfTarget:SetParent(K.PetBattleHider)
	TargetOfTarget:SetSize(116, 36)

	local Pet = oUF:Spawn("pet", "oUF_Pet")
	if C["Unitframe"].CombatFade and oUF_Player and not InCombatLockdown() then
		Pet:SetParent(oUF_Player)
	else
		Pet:SetParent(K.PetBattleHider)
	end
	if (K.Class == "WARLOCK" or K.Class == "DEATHKNIGHT") then
		Pet:SetPoint("TOPRIGHT", oUF_Player, "BOTTOMLEFT", 56, -14)
	else
		Pet:SetPoint("TOPRIGHT", oUF_Player, "BOTTOMLEFT", 56, 2)
	end
	Pet:SetSize(116, 36)

	local Focus = oUF:Spawn("focus", "oUF_Focus")
	Focus:SetPoint("BOTTOMRIGHT", oUF_Player, "TOPLEFT", -60, 30)
	Focus:SetParent(K.PetBattleHider)
	Focus:SetSize(190, 52)

	local FocusTarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
	FocusTarget:SetPoint("TOPRIGHT", oUF_Focus, "BOTTOMLEFT", 56, 2)
	FocusTarget:SetParent(K.PetBattleHider)
	FocusTarget:SetSize(116, 36)

	if (C["Unitframe"].ShowArena) then
		local Arena = {}
		for i = 1, 5 do
			Arena[i] = oUF:Spawn("arena"..i, "oUF_ArenaFrame"..i)
			Arena[i]:SetSize(190, 52)
			if (i == 1) then
				Arena[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
			else
				Arena[i]:SetPoint("TOPLEFT", Arena[i-1], "BOTTOMLEFT", 0, -48)
			end
			K.Movers:RegisterFrame(Arena[i])
		end

		K.CreateArenaPrep()
	end

	if (C["Unitframe"].ShowBoss) then
		local Boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			Boss[i] = oUF:Spawn("boss"..i, "oUF_BossFrame"..i)
			Boss[i]:SetParent(K.PetBattleHider)

			Boss[i]:SetSize(190, 52)
			if (i == 1) then
				Boss[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
			else
				Boss[i]:SetPoint("TOPLEFT", Boss[i-1], "BOTTOMLEFT", 0, -48)
			end
			K.Movers:RegisterFrame(Boss[i])
		end
	end

	if (C["Unitframe"].Party) then
		local Party = oUF:SpawnHeader(Module:GetPartyFramesAttributes())
		Party:SetParent(K.PetBattleHider)
		Party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -200)
		Movers:RegisterFrame(Party)

		local PartyTarget = oUF:SpawnHeader(Module:GetPartyTargetFramesAttributes())
		PartyTarget:SetParent(K.PetBattleHider)
		PartyTarget:SetPoint("TOPLEFT", oUF_Party, "TOPRIGHT", 4, 16)
	end

	if (C["Raidframe"].Enable) then
		if C["Raidframe"].RaidLayout.Value == "Healer" then
			Module:GetHealerRaidFramesAttributes()
		elseif C["Raidframe"].RaidLayout.Value == "Damage" then
			Module:GetDamageRaidFramesAttributes()
		else
			Module:GetDamageRaidFramesAttributes()
		end

		-- local MainTank = oUF:SpawnHeader(Module:GetMainTankAttributes())
		-- MainTank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
		-- Movers:RegisterFrame(MainTank)

		-- local MainTankTarget = oUF:SpawnHeader(Module:GetMainTankTargetAttributes())
	end

	Movers:RegisterFrame(Player)
	Movers:RegisterFrame(Target)
	Movers:RegisterFrame(TargetOfTarget)
	Movers:RegisterFrame(Pet)
	Movers:RegisterFrame(Focus)
	Movers:RegisterFrame(FocusTarget)
end

function Module:OnEnable()
	if C["Unitframe"].Enable ~= true then
		return
	end

	oUF:RegisterStyle("oUF_KkthnxUI", Module.CreateStyle)
	oUF:SetActiveStyle("oUF_KkthnxUI")

	self:CreateUnits()
end