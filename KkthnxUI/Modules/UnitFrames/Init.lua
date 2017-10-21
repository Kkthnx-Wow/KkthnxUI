local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

-- Lua API
local _G = _G
local pairs = pairs

-- Wow API
local IsShiftKeyDown = _G.IsShiftKeyDown
local PlaySound = _G.PlaySound
local PlaySoundKitID = _G.PlaySoundKitID
local SOUNDKIT = _G.SOUNDKIT
local UnitAffectingCombat = _G.UnitAffectingCombat
local UnitExists = _G.UnitExists
local UnitIsEnemy = _G.UnitIsEnemy
local UnitIsFriend = _G.UnitIsFriend
local UnitIsPVP = _G.UnitIsPVP
local UnitIsPVPFreeForAll = _G.UnitIsPVPFreeForAll

local oUFKkthnx = CreateFrame("Frame", "oUFKkthnxModifiers")
oUFKkthnx:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

-- Sounds for target/focus changing and PVP flagging
oUFKkthnx:RegisterEvent("PLAYER_TARGET_CHANGED")
oUFKkthnx:RegisterEvent("PLAYER_FOCUS_CHANGED")
oUFKkthnx:RegisterUnitEvent("UNIT_FACTION", "player")

-- Shift to temporarily show all buffs
oUFKkthnx:RegisterEvent("PLAYER_REGEN_DISABLED")
oUFKkthnx:RegisterEvent("PLAYER_REGEN_ENABLED")
oUFKkthnx:RegisterEvent("MODIFIER_STATE_CHANGED")

function oUFKkthnx:PLAYER_FOCUS_CHANGED()
	if UnitExists("focus") then
		if UnitIsEnemy("focus", "player") then
			PlaySound(PlaySoundKitID and "igCreatureAggroSelect" or SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend("player", "focus") then
			PlaySound(PlaySoundKitID and "igCharacterNPCSelect" or SOUNDKIT.IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(PlaySoundKitID and "igCreatureNeutralSelect" or SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		end
	else
		PlaySound(PlaySoundKitID and "INTERFACESOUND_LOSTTARGETUNIT" or SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

function oUFKkthnx:PLAYER_TARGET_CHANGED()
	if UnitExists("target") then
		if UnitIsEnemy("target", "player") then
			PlaySound(PlaySoundKitID and "igCreatureAggroSelect" or SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		elseif UnitIsFriend("player", "target") then
			PlaySound(PlaySoundKitID and "igCharacterNPCSelect" or SOUNDKIT.IG_CHARACTER_NPC_SELECT)
		else
			PlaySound(PlaySoundKitID and "igCreatureNeutralSelect" or SOUNDKIT.IG_CREATURE_AGGRO_SELECT)
		end
	else
		PlaySound(PlaySoundKitID and "INTERFACESOUND_LOSTTARGETUNIT" or SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

local announcedPVP
function oUFKkthnx:UNIT_FACTION()
	if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
		if not announcedPVP then
			announcedPVP = true
			PlaySound(PlaySoundKitID and "igPVPUpdate" or SOUNDKIT.IG_PVP_UPDATE)
		end
	else
		announcedPVP = nil
	end
end

function oUFKkthnx:PLAYER_REGEN_DISABLED()
	oUFKkthnx:UnregisterEvent("MODIFIER_STATE_CHANGED")
	oUFKkthnx:MODIFIER_STATE_CHANGED("LSHIFT", 0)
end

function oUFKkthnx:PLAYER_REGEN_ENABLED()
	oUFKkthnx:RegisterEvent("MODIFIER_STATE_CHANGED")
	oUFKkthnx:MODIFIER_STATE_CHANGED("LSHIFT", IsShiftKeyDown() and 1 or 0)
end

-- View Auras
function oUFKkthnx:MODIFIER_STATE_CHANGED(key, state)
	if (key ~= "LSHIFT" and key ~= "RSHIFT") then return end

	local a, b
	if state == 1 then
		a, b = "CustomFilter", "__CustomFilter"
	else
		a, b = "__CustomFilter", "CustomFilter"
	end
	for i = 1, #oUF.objects do
		local object = oUF.objects[i]

		local buffs = object.Auras or object.Buffs
		if buffs and buffs[a] then
			buffs[b] = buffs[a]
			buffs[a] = nil
			buffs:ForceUpdate()
		end

		local debuffs = object.Debuffs
		if debuffs and debuffs[a] then
			debuffs[b] = debuffs[a]
			debuffs[a] = nil
			debuffs:ForceUpdate()
		end
	end
end

K["oUFKkthnx"] = oUFKkthnx