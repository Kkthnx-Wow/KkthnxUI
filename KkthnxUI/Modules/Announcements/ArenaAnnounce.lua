local K = unpack(select(2, ...))
local Module = K:NewModule("ArenaAnnounce", "AceEvent-3.0")

if not Module then
	return
end

local _G = _G
local mathfloor = math.floor
local strfind = string.find
local string = string

local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs
local GetNumGroupMembers = _G.GetNumGroupMembers
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local GetTime = _G.GetTime
local IsActiveBattlefieldArena = _G.IsActiveBattlefieldArena
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsArenaSkirmish = _G.IsArenaSkirmish
local IsInInstance = _G.IsInInstance
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local SendChatMessage = _G.SendChatMessage
local UnitClass = _G.UnitClass
local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsGroupAssistant = _G.UnitIsGroupAssistant
local UnitIsGroupLeader = _G.UnitIsGroupLeader
local UnitName = _G.UnitName
local UNKNOWN = _G.UNKNOWN

local announcements = {
	drinks = true,
	enemies = true,
	health = true,
	resurrect = true,
	spec = true,
	healthThreshold = 25,
	dest = "party"
}

function Module:OnEnable()
	if K.CheckAddOnState("Gladius") or IsAddOnLoaded("Gladius") then
		return
	end

	-- Register Events
	self:RegisterEvent("UNIT_HEALTH")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_SPELLCAST_START")
	self:RegisterEvent("UNIT_NAME_UPDATE")
	self:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	-- Table Holding Messages To Throttle
	self.throttled = { }
	-- Enemy Detected
	self.enemy = { }
end

function Module:OnDisable()
	self:UnregisterAllEvents()
end

-- Needed To Not Throw Lua Errors
function Module:GetAttachTo()
	return ""
end

-- Reset Throttled Messages
function Module:Reset()
	self.throttled = { }
	self.enemy = { }
end

-- New Enemy Announcement
function Module:Show(unit)
	self:UNIT_NAME_UPDATE(nil, unit)
end

function Module:UNIT_NAME_UPDATE(_, unit)
	local _, instanceType = IsInInstance()
	if instanceType ~= "arena" or not strfind(unit, "arena") or strfind(unit, "pet") then
		return
	end

	if not announcements.enemies or not UnitName(unit) then
		return
	end

	local name = UnitName(unit)
	if name == UNKNOWN or not name then
		return
	end

	if not self.enemy[unit] then
		self:Send(string.format("%s - %s", name, UnitClass(unit) or ""), 2, unit)
		self.enemy[unit] = true
	end
end

function Module:UNIT_HEALTH(_, unit)
	if not unit then
		return
	end

	local _, instanceType = IsInInstance()
	if instanceType ~= "arena" or not strfind(unit, "arena") or strfind(unit, "pet") or not announcements.health then
		return
	end

	local healthPercent = mathfloor((UnitHealth(unit) / UnitHealthMax(unit)) * 100)
	if healthPercent < announcements.healthThreshold then
		self:Send(string.format("LOW HEALTH: %s (%s)", UnitName(unit), UnitClass(unit)), 10, unit)
	end
end

function Module:UNIT_AURA(_, unit)
	local _, instanceType = IsInInstance()
	if instanceType ~= "arena" or not strfind(unit, "arena") or strfind(unit, "pet") or not announcements.drinks then
		return
	end

	local index
	for i = 1, 40 do
		local _, _, _, _, _, _, _, _, _, spellID = UnitBuff(unit, i, "HELPFUL")
		if spellID == 57073 then
			index = i
			break
		end
	end

	if index then
		self:Send(string.format("DRINKING: %s (%s)", UnitName(unit), UnitClass(unit)), 2, unit)
	end
end

function Module:ARENA_PREP_OPPONENT_SPECIALIZATIONS()
	if not announcements.spec then
		return
	end

	for i = 1, GetNumArenaOpponentSpecs() do
		local specID = GetArenaOpponentSpec(i)
		if specID > 0 then
			local _, name, _, _, _, class = GetSpecializationInfoByID(specID)
			self:Send("Enemy Spec: "..name.." "..class)
		end
	end
end

local RES_SPELLS = {
	[2008] = true, -- Ancestral Spirit
	[50769] = true, -- Revive
	[2006] = true, -- Resurrection
	[7328] = true, -- Redemption
	[50662] = true -- Resuscitate
}

function Module:UNIT_SPELLCAST_START(_, unit, _, spellID)
	local _, instanceType = IsInInstance()
	if instanceType ~= "arena" or not strfind(unit, "arena") or strfind(unit, "pet") or not announcements.resurrect then
		return
	end

	if RES_SPELLS[spellID] then
		self:Send(string.format("RESURRECTING: %s (%s)", UnitName(unit), UnitClass(unit)), 2, unit)
	end
end

-- Sends An Announcement
-- Param Unit Is Only Used For Class Coloring Of Messages
function Module:Send(msg, throttle, unit)
	local color = unit and RAID_CLASS_COLORS[UnitClass(unit)] or {r = 0, g = 1, b = 0}
	local dest = announcements.dest
	local skirmish = IsArenaSkirmish()
	local isRegistered = IsActiveBattlefieldArena()
	if skirmish or not isRegistered then
		dest = "instance"
	end

	if not self.throttled then
		self.throttled = { }
	end
	-- Throttling Of Messages
	if throttle and throttle > 0 then
		if not self.throttled[msg] then
			self.throttled[msg] = GetTime() + throttle
		elseif self.throttled[msg] < GetTime() then
			self.throttled[msg] = nil
		else
			return
		end
	end

	if dest == "self" then
		DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99KkthnxUI|r: "..msg)
	end
	-- Change Destination To Party If Not Raid Leader / Officer.
	if dest == "rw" and not UnitIsGroupLeader() and not UnitIsGroupAssistant() and GetNumGroupMembers() > 0 then
		dest = "party"
	end
	-- Party Chat
	if dest == "party" and (GetNumGroupMembers() > 0) then
		SendChatMessage(msg, "PARTY")
		-- Instance Chat
	elseif dest == "instance" and (GetNumGroupMembers() > 0) then
		SendChatMessage(msg, "INSTANCE_CHAT")
		-- Raid Chat
	elseif dest == "raid" and (GetNumGroupMembers() > 0) then
		SendChatMessage(msg, "RAID")
		-- Say
	elseif dest == "say" then
		SendChatMessage(msg, "SAY")
		-- Raid Warning
	elseif dest == "rw" then
		SendChatMessage(msg, "RAID_WARNING")
		-- Floating Combat Text
	elseif dest == "fct" and IsAddOnLoaded("Blizzard_CombatText") then
		CombatText_AddMessage(msg, COMBAT_TEXT_SCROLL_FUNCTION, color.r, color.g, color.b)
		-- MikScrollingBattleText
	elseif dest == "msbt" and IsAddOnLoaded("MikScrollingBattleText") then
		MikSBT.DisplayMessage(msg, MikSBT.DISPLAYTYPE_NOTIFICATION, false, color.r * 255, color.g * 255, color.b * 255)
		-- xCT
	elseif dest == "xct" and IsAddOnLoaded("xCT") then
		ct.frames[3]:AddMessage(msg, color.r * 255, color.g * 255, color.b * 255)
		-- xCT+
	elseif dest == "xctplus" and IsAddOnLoaded("xCT+") then
		xCT_Plus:AddMessage("general", msg, {color.r, color.g, color.b})
		-- Scrolling Combat Text
	elseif dest == "sct" and IsAddOnLoaded("sct") then
		SCT:DisplayText(msg, color, nil, "event", 1)
		-- Parrot
	elseif dest == "parrot" and IsAddOnLoaded("parrot") then
		Parrot:ShowMessage(msg, "Notification", false, color.r, color.g, color.b)
	end
end