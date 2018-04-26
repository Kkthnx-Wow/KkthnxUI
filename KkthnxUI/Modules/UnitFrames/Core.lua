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

local ActionBarAnchor = _G.ActionBarAnchor
local InCombatLockdown = _G.InCombatLockdown
local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES or 5
local UIParent = _G.UIParent

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
		"maxColumns", C["Raidframe"].RaidGroups or 5,
		"unitsPerColumn", C["Raidframe"].MaxUnitPerColumn or 1,
		"columnSpacing", 6,
		"columnAnchorPoint", "TOP")
		if i == 1 then
			RaidDamage:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -90)
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
		"maxColumns", C["Raidframe"].RaidGroups or 5,
		"unitsPerColumn", C["Raidframe"].MaxUnitPerColumn or 1,
		"columnSpacing", 6,
		"columnAnchorPoint", "LEFT")
		if i == 1 then
			RaidHealer:SetPoint("TOPLEFT", AnchorPlayer, "BOTTOMRIGHT", 11, -12)
			Movers:RegisterFrame(RaidHealer)
		else
			-- Changing this to use CENTER for its own anchoring point,
			-- to avoid headers with no units and zero width being positioned wrongly.
			RaidHealer:SetPoint("CENTER", Raid[i-1], "CENTER", 0, -(7 + 26))
		end
		Movers:RegisterFrame(RaidHealer, i > 1 and Raid[1])
		Raid[i] = RaidHealer
	end
end

function Module:GetMainTankAttributes()
	return
	"oUF_MainTank",
	nil,
	"raid",
	"oUF-initialConfigFunction", [[
	self:SetWidth(70)
	self:SetHeight(32)
	]],
	"showRaid", true,
	"yOffset", -8,
	"groupFilter", "MAINTANK, MAINASSIST",
	"groupBy", "ROLE",
	"groupingOrder", "MAINTANK, MAINASSIST",
	"template", "oUF_MainTank"
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
	elseif (unit == "maintank") then
		K.CreateRaid(self, "maintank")
	elseif (unit == "maintanktarget") then
		K.CreateRaid(self, "maintanktarget")
	end

	return self
end

function Module:CreateUnits()
	local Player = oUF:Spawn("player")
	Player:SetParent(K.PetBattleHider)
	Player:SetPoint("BOTTOMRIGHT", ActionBarAnchor, "TOPLEFT", -10, 200)
	Player:SetSize(190, 52)

	local Target = oUF:Spawn("target")
	Target:SetParent(K.PetBattleHider)
	Target:SetPoint("BOTTOMLEFT", ActionBarAnchor, "TOPRIGHT", 10, 200)
	Target:SetSize(190, 52)

	local TargetOfTarget = oUF:Spawn("targettarget")
	TargetOfTarget:SetParent(K.PetBattleHider)
	TargetOfTarget:SetPoint("TOPLEFT", Target, "BOTTOMRIGHT", -56, 2)
	TargetOfTarget:SetSize(116, 36)

	local Pet = oUF:Spawn("pet")
	if C["Unitframe"].CombatFade and Player and not InCombatLockdown() then
		Pet:SetParent(Player)
	else
		Pet:SetParent(K.PetBattleHider)
	end
	if (K.Class == "WARLOCK" or K.Class == "DEATHKNIGHT") then
		Pet:SetPoint("TOPRIGHT", Player, "BOTTOMLEFT", 56, -14)
	else
		Pet:SetPoint("TOPRIGHT", Player, "BOTTOMLEFT", 56, 2)
	end
	Pet:SetSize(116, 36)

	local Focus = oUF:Spawn("focus")
	Focus:SetParent(K.PetBattleHider)
	Focus:SetPoint("BOTTOMRIGHT", Player, "TOPLEFT", -60, 30)
	Focus:SetSize(190, 52)

	local FocusTarget = oUF:Spawn("focustarget")
	FocusTarget:SetParent(K.PetBattleHider)
	FocusTarget:SetPoint("TOPRIGHT", Focus, "BOTTOMLEFT", 56, 2)
	FocusTarget:SetSize(116, 36)

	if (C["Unitframe"].ShowArena) then
		local Arena = {}
		for i = 1, 5 do
			Arena[i] = oUF:Spawn("arena"..i)
			Arena[i]:SetSize(190, 52)
			if (i == 1) then
				Arena[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
			else
				Arena[i]:SetPoint("TOPLEFT", Arena[i-1], "BOTTOMLEFT", 0, -48)
			end
			Movers:RegisterFrame(Arena[i])
		end

		K.CreateArenaPrep()
	end

	if (C["Unitframe"].ShowBoss) then
		local Boss = {}
		for i = 1, MAX_BOSS_FRAMES do
			Boss[i] = oUF:Spawn("boss"..i)
			Boss[i]:SetParent(K.PetBattleHider)
			if (i == 1) then
				Boss[i]:SetPoint("BOTTOMRIGHT", UIParent, "RIGHT", -140, 140)
			else
				Boss[i]:SetPoint("TOPLEFT", Boss[i-1], "BOTTOMLEFT", 0, -48)
			end
			Boss[i]:SetSize(190, 52)
			Movers:RegisterFrame(Boss[i])
		end
	end

	if (C["Unitframe"].Party) then
		local Party = oUF:SpawnHeader(Module:GetPartyFramesAttributes())
		Party:SetParent(K.PetBattleHider)
		Party:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 12, -200)

		local PartyTarget = oUF:SpawnHeader(Module:GetPartyTargetFramesAttributes())
		PartyTarget:SetParent(K.PetBattleHider)
		PartyTarget:SetPoint("TOPLEFT", Party, "TOPRIGHT", 4, 16)

		Movers:RegisterFrame(Party)
	end

	if (C["Raidframe"].Enable) then
		if C["Raidframe"].RaidLayout.Value == "Healer" then
			Module:GetHealerRaidFramesAttributes()
		elseif C["Raidframe"].RaidLayout.Value == "Damage" then
			Module:GetDamageRaidFramesAttributes()
		else
			Module:GetDamageRaidFramesAttributes()
		end

		if C["Raidframe"].MainTankFrames then
			local MainTank = oUF:SpawnHeader(Module:GetMainTankAttributes())
			if C["Raidframe"].RaidLayout.Value == "Healer" then
				MainTank:SetPoint("BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", 6, 2)
			elseif C["Raidframe"].RaidLayout.Value == "Damage" then
				MainTank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
			else
				MainTank:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 6, -6)
			end
			Movers:RegisterFrame(MainTank)
		end
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

	oUF:RegisterStyle(" ", Module.CreateStyle)
	oUF:SetActiveStyle(" ")

	self:CreateUnits()
end