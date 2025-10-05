--[[
Copyright 2011-2025 João Cardoso
Unfit is distributed under the terms of the GNU General Public License (Version 3).
As a special exception, the copyright holders of this library give you permission to embed it
with independent modules to produce an addon, regardless of the license terms of these
independent modules, and to copy and distribute the resulting software under terms of your
choice, provided that you also meet, for each embedded independent module, the terms and
conditions of the license of that module. Permission is not granted to modify this library.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

This file is part of Unfit.
--]]

local LibStub = assert(rawget(_G, "LibStub"), "LibStub not found")
local Lib = LibStub:NewLibrary("LibUnfit-1.0-KkthnxUI", 15)
if not Lib then
	return
end

--[[ Data ]]
--

-- Locals for faster access (Lua 5.1 best practices)
local C_Item = rawget(_G, "C_Item")
local GetItemInfoInstant = rawget(_G, "GetItemInfoInstant") or (C_Item and rawget(C_Item, "GetItemInfoInstant"))
local UnitClassBase = rawget(_G, "UnitClassBase")
local Enum = rawget(_G, "Enum")
local CreateFrame = rawget(_G, "CreateFrame")
local debugprofilestop = rawget(_G, "debugprofilestop") or function()
	return 0
end
local tostring = tostring
local setmetatable = setmetatable

-- Constants
local ITEM_CLASS_WEAPON = Enum and Enum.ItemClass and Enum.ItemClass.Weapon
local ITEM_CLASS_ARMOR = Enum and Enum.ItemClass and Enum.ItemClass.Armor
local INVTYPE_WEAPONOFFHAND = "INVTYPE_WEAPONOFFHAND"
do
	local class = UnitClassBase("player")
	local unusable

	if class == "DEATHKNIGHT" then
		unusable = { -- weapon, armor, dual-wield
			{
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Staff,
				Enum.ItemWeaponSubclass.Unarmed,
				Enum.ItemWeaponSubclass.Dagger,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
				Enum.ItemWeaponSubclass.Wand,
			},
			{ Enum.ItemArmorSubclass.Shield },
		}
	elseif class == "DEMONHUNTER" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Axe2H,
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Mace1H,
				Enum.ItemWeaponSubclass.Mace2H,
				Enum.ItemWeaponSubclass.Polearm,
				Enum.ItemWeaponSubclass.Sword2H,
				Enum.ItemWeaponSubclass.Staff,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
				Enum.ItemWeaponSubclass.Wand,
			},
			{ Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
		}
	elseif class == "DRUID" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Axe1H,
				Enum.ItemWeaponSubclass.Axe2H,
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Sword1H,
				Enum.ItemWeaponSubclass.Sword2H,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
				Enum.ItemWeaponSubclass.Wand,
			},
			{ Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
			true,
		}
	elseif class == "EVOKER" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Polearm,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
				Enum.ItemWeaponSubclass.Wand,
			},
			{ Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
			true,
		}
	elseif class == "HUNTER" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Mace1H,
				Enum.ItemWeaponSubclass.Mace2H,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Wand,
			},
			{ Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
		}
	elseif class == "MAGE" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Axe1H,
				Enum.ItemWeaponSubclass.Axe2H,
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Mace1H,
				Enum.ItemWeaponSubclass.Mace2H,
				Enum.ItemWeaponSubclass.Polearm,
				Enum.ItemWeaponSubclass.Sword2H,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Unarmed,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
			},
			{
				Enum.ItemArmorSubclass.Leather,
				Enum.ItemArmorSubclass.Mail,
				Enum.ItemArmorSubclass.Plate,
				Enum.ItemArmorSubclass.Shield,
			},
			true,
		}
	elseif class == "MONK" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Axe2H,
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Mace2H,
				Enum.ItemWeaponSubclass.Sword2H,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Dagger,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
				Enum.ItemWeaponSubclass.Wand,
			},
			{ Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
		}
	elseif class == "PALADIN" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Staff,
				Enum.ItemWeaponSubclass.Unarmed,
				Enum.ItemWeaponSubclass.Dagger,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
				Enum.ItemWeaponSubclass.Wand,
			},
			{},
			true,
		}
	elseif class == "PRIEST" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Axe1H,
				Enum.ItemWeaponSubclass.Axe2H,
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Mace2H,
				Enum.ItemWeaponSubclass.Polearm,
				Enum.ItemWeaponSubclass.Sword1H,
				Enum.ItemWeaponSubclass.Sword2H,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Unarmed,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
			},
			{
				Enum.ItemArmorSubclass.Leather,
				Enum.ItemArmorSubclass.Mail,
				Enum.ItemArmorSubclass.Plate,
				Enum.ItemArmorSubclass.Shield,
			},
			true,
		}
	elseif class == "ROGUE" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Axe2H,
				Enum.ItemWeaponSubclass.Mace2H,
				Enum.ItemWeaponSubclass.Polearm,
				Enum.ItemWeaponSubclass.Sword2H,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Staff,
				Enum.ItemWeaponSubclass.Wand,
			},
			{ Enum.ItemArmorSubclass.Mail, Enum.ItemArmorSubclass.Plate, Enum.ItemArmorSubclass.Shield },
		}
	elseif class == "SHAMAN" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Polearm,
				Enum.ItemWeaponSubclass.Sword1H,
				Enum.ItemWeaponSubclass.Sword2H,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
				Enum.ItemWeaponSubclass.Wand,
			},
			{ Enum.ItemArmorSubclass.Plate },
		}
	elseif class == "WARLOCK" then
		unusable = {
			{
				Enum.ItemWeaponSubclass.Axe1H,
				Enum.ItemWeaponSubclass.Axe2H,
				Enum.ItemWeaponSubclass.Bows,
				Enum.ItemWeaponSubclass.Guns,
				Enum.ItemWeaponSubclass.Mace1H,
				Enum.ItemWeaponSubclass.Mace2H,
				Enum.ItemWeaponSubclass.Polearm,
				Enum.ItemWeaponSubclass.Sword2H,
				Enum.ItemWeaponSubclass.Warglaive,
				Enum.ItemWeaponSubclass.Unarmed,
				Enum.ItemWeaponSubclass.Thrown,
				Enum.ItemWeaponSubclass.Crossbow,
			},
			{
				Enum.ItemArmorSubclass.Leather,
				Enum.ItemArmorSubclass.Mail,
				Enum.ItemArmorSubclass.Plate,
				Enum.ItemArmorSubclass.Shield,
			},
			true,
		}
	elseif class == "WARRIOR" then
		unusable = { { Enum.ItemWeaponSubclass.Warglaive, Enum.ItemWeaponSubclass.Wand }, {} }
	else
		unusable = { {}, {} }
	end

	Lib.unusable = {}
	Lib.cannotDual = unusable[3] and true or false

	-- Build lookup tables (prefer numeric for-loops over ipairs for speed)
	local itemClasses = { Enum.ItemClass.Weapon, Enum.ItemClass.Armor }
	for i = 1, 2 do
		local classId = itemClasses[i]
		local classList = unusable[i]
		local lookup = {}
		for j = 1, #classList do
			lookup[classList[j]] = true
		end
		Lib.unusable[classId] = lookup
	end
end

--[[ API ]]
--

-- Simple per-item memoization cache with weak keys/values to limit memory growth
Lib._itemUnusableCache = Lib._itemUnusableCache or setmetatable({}, { __mode = "kv" })

-- Profiling helpers (use in /script while developing)
Lib._profileMarks = Lib._profileMarks or {}
function Lib:ProfileStart(mark)
	self._profileMarks[mark or "default"] = debugprofilestop()
end
function Lib:ProfileEnd(mark)
	local key = mark or "default"
	local start = self._profileMarks[key]
	if start then
		local elapsed = debugprofilestop() - start
		self._profileMarks[key] = nil
		self._lastProfile = elapsed
		return elapsed
	end
end

-- Public API: check if a given item is unusable by the player's class
function Lib:IsItemUnusable(item)
	if not item then
		return
	end
	local cached = self._itemUnusableCache[item]
	if cached ~= nil then
		return cached
	end

	local _, _, _, slot, _, class, subclass = GetItemInfoInstant(item)
	local result = self:IsClassUnusable(class, subclass, slot) and true or false
	self._itemUnusableCache[item] = result
	return result
end

-- Public API: class/subclass/slot based check (fast-path lookups, explicit returns)
function Lib:IsClassUnusable(class, subclass, slot)
	local classMap = class and subclass and self.unusable[class]
	if not classMap then
		return false
	end

	-- Match original logic: require a non-empty slot for subclass gating
	if slot ~= "" and classMap[subclass] then
		return true
	end

	-- Offhand weapon restriction (dual-wield)
	if slot == INVTYPE_WEAPONOFFHAND and self.cannotDual then
		return true
	end

	return false
end

function Lib:Embed(object)
	object.IsItemUnusable = Lib.IsItemUnusable
	object.IsClassUnusable = Lib.IsClassUnusable
end

-- Cache management: clear memoized answers on login (safe, cheap)
do
	local frame = Lib._evFrame or CreateFrame("Frame")
	Lib._evFrame = frame
	frame:UnregisterAllEvents()
	frame:RegisterEvent("PLAYER_LOGIN")
	frame:SetScript("OnEvent", function()
		for k in pairs(Lib._itemUnusableCache) do
			Lib._itemUnusableCache[k] = nil
		end
	end)
end
