local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

-- Lua API
local pairs = pairs

-- Wow API
local UnitAffectingCombat = UnitAffectingCombat
local IsShiftKeyDown = IsShiftKeyDown

local oUFKkthnx = CreateFrame("Frame", "oUFKkthnx")
oUFKkthnx:RegisterEvent("ADDON_LOADED")
oUFKkthnx:SetScript("OnEvent", function(self, event, ...)
	return self[event] and self[event](self, event, ...)
end)

function oUFKkthnx:ADDON_LOADED(event, addon)
	if addon ~= "KkthnxUI" then return end

	self:UnregisterEvent(event)
	self.ADDON_LOADED = nil

	-- Sounds for target/focus changing and PVP flagging
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterUnitEvent("UNIT_FACTION", "player")

	-- Shift to temporarily show all buffs
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	if not UnitAffectingCombat("player") then
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
	end

	function oUFKkthnx:PLAYER_FOCUS_CHANGED(event)
		if UnitExists("focus") then
			if UnitIsEnemy("focus", "player") then
				PlaySound("igCreatureAggroSelect")
			elseif UnitIsFriend("player", "focus") then
				PlaySound("igCharacterNPCSelect")
			else
				PlaySound("igCreatureNeutralSelect")
			end
		else
			PlaySound("INTERFACESOUND_LOSTTARGETUNIT")
		end
	end

	function oUFKkthnx:PLAYER_TARGET_CHANGED(event)
		if UnitExists("target") then
			if UnitIsEnemy("target", "player") then
				PlaySound("igCreatureAggroSelect")
			elseif UnitIsFriend("player", "target") then
				PlaySound("igCharacterNPCSelect")
			else
				PlaySound("igCreatureNeutralSelect")
			end
		else
			PlaySound("INTERFACESOUND_LOSTTARGETUNIT")
		end
	end

	local announcedPVP
	function oUFKkthnx:UNIT_FACTION(event, unit)
		if UnitIsPVPFreeForAll("player") or UnitIsPVP("player") then
			if not announcedPVP then
				announcedPVP = true
				PlaySound("igPVPUpdate")
			end
		else
			announcedPVP = nil
		end
	end

	function oUFKkthnx:PLAYER_REGEN_DISABLED(event)
		self:UnregisterEvent("MODIFIER_STATE_CHANGED")
		self:MODIFIER_STATE_CHANGED(event, "LSHIFT", 0)
	end

	function oUFKkthnx:PLAYER_REGEN_ENABLED(event)
		self:RegisterEvent("MODIFIER_STATE_CHANGED")
		self:MODIFIER_STATE_CHANGED(event, "LSHIFT", IsShiftKeyDown() and 1 or 0)
	end

	-- View Auras
	function oUFKkthnx:MODIFIER_STATE_CHANGED(event, key, state)
		if key ~= "LSHIFT" and key ~= "RSHIFT" then
			return
		end

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
end

-- Remove irrelevant rightclick menu entries
for _, menu in pairs(UnitPopupMenus) do
	for i = #menu, 1, -1 do
		local name = menu[i]
		if name == "SET_FOCUS" or name == "CLEAR_FOCUS" or name:match("^LOCK_%u+_FRAME$") or name:match("^UNLOCK_%u+_FRAME$") or name:match("^MOVE_%u+_FRAME$") or name:match("^RESET_%u+_FRAME_POSITION") then
			tremove(menu, i)
		end
	end
end