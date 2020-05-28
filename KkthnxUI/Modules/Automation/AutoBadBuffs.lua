local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G
local next = _G.next

local UnitBuff = _G.UnitBuff
local InCombatLockdown = _G.InCombatLockdown

local BadBuffMessage = "Removed \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r!"
local function CheckPlayerBuffs(spell)
	for i = 1, 40 do
		local name, _, _, _, _, _, unitCaster = UnitBuff("player", i)
		if not name then
			break
		end

		if name == spell then
			return i, unitCaster
		end
	end

	return nil
end

local function SetupAutoBadBuffs(_, unit)
	if unit ~= "player" then
		return
	end

	if not InCombatLockdown() then
		for buff, enabled in next, K.CheckBadBuffs do
			local icon = CheckPlayerBuffs(buff)
			if icon and enabled then
				CancelUnitBuff(unit, icon)
				K.Print(string.format(BadBuffMessage, _, buff, buff))
			end
		end
	end
end

function Module:CreateAutoBadBuffs()
	if not C["Automation"].NoBadBuffs then
		return
	end

	K:RegisterEvent("UNIT_AURA", SetupAutoBadBuffs)
end