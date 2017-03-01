local parent, ns = ...
local oUF = ns.oUF

local hiddenParent = CreateFrame('Frame', nil, UIParent)
hiddenParent:SetAllPoints()
hiddenParent:Hide()

local HandleFrame = function(baseName)
	local frame
	if(type(baseName) == 'string') then
		frame = _G[baseName]
	else
		frame = baseName
	end

	if(frame) then
		frame:UnregisterAllEvents()
		frame:Hide()

		-- Keep frame hidden without causing taint
		frame:SetParent(hiddenParent)

		local health = frame.healthBar or frame.healthbar
		if(health) then
			health:UnregisterAllEvents()
		end

		local power = frame.manabar
		if(power) then
			power:UnregisterAllEvents()
		end

		local spell = frame.castBar or frame.spellbar
		if(spell) then
			spell:UnregisterAllEvents()
		end

		local altpowerbar = frame.powerBarAlt
		if(altpowerbar) then
			altpowerbar:UnregisterAllEvents()
		end
	end
end

function oUF:DisableBlizzard(unit)
	if(not unit) then return end

	if(unit == 'player') then
		HandleFrame(PlayerFrame)

		-- For the damn vehicle support:
		PlayerFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
		PlayerFrame:RegisterEvent('UNIT_ENTERING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_ENTERED_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITING_VEHICLE')
		PlayerFrame:RegisterEvent('UNIT_EXITED_VEHICLE')

		-- User placed frames don't animate
		PlayerFrame:SetUserPlaced(true)
		PlayerFrame:SetDontSavePosition(true)
		RuneFrame:SetParent(PlayerFrame)
	elseif(unit == 'pet') then
		HandleFrame(PetFrame)
	elseif(unit == 'target') then
		HandleFrame(TargetFrame)
		HandleFrame(ComboFrame)
	elseif(unit == 'focus') then
		HandleFrame(FocusFrame)
		HandleFrame(TargetofFocusFrame)
	elseif(unit == 'targettarget') then
		HandleFrame(TargetFrameToT)
	elseif(unit:match'(boss)%d?$' == 'boss') then
		local id = unit:match'boss(%d)'
		if(id) then
			HandleFrame('Boss' .. id .. 'TargetFrame')
		else
			for i=1, MAX_BOSS_FRAMES do
				HandleFrame(string.format('Boss%dTargetFrame', i))
			end
		end
	elseif(unit:match'(party)%d?$' == 'party') then
		local id = unit:match'party(%d)'
		if(id) then
			HandleFrame('PartyMemberFrame' .. id)
		else
			for i=1, 4 do
				HandleFrame(string.format('PartyMemberFrame%d', i))
			end
		end
		HandleFrame(PartyMemberBackground)
	elseif(unit:match'(arena)%d?$' == 'arena') then
		local id = unit:match'arena(%d)'

		if(id) then
			HandleFrame('ArenaEnemyFrame' .. id)
			HandleFrame('ArenaPrepFrame'..id)
			HandleFrame('ArenaEnemyFrame'..id..'PetFrame')
		else
			for i=1, 5 do
				HandleFrame(string.format('ArenaEnemyFrame%d', i))
				HandleFrame(string.format('ArenaPrepFrame%d', i))
				HandleFrame(string.format('ArenaEnemyFrame%dPetFrame', i))
			end
		end

		-- Blizzard_ArenaUI should not be loaded
		Arena_LoadUI = function() end
		SetCVar('showArenaEnemyFrames', '0', 'SHOW_ARENA_ENEMY_FRAMES_TEXT')
	elseif(unit:match('nameplate%d+$')) then
		local frame = C_NamePlate.GetNamePlateForUnit(unit)
		if(frame and frame.UnitFrame) then
			HandleFrame(frame.UnitFrame)
		end
	end
end