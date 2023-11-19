local K = KkthnxUI[1]
local Module = K:GetModule("Tooltip")

local MountTable = {}

local function IsCollected(spell)
	local index = MountTable[spell].index
	return select(11, C_MountJournal.GetMountInfoByID(index))
end

local function GetOrCreateMountTable(spell)
	if not MountTable[spell] then
		local index = C_MountJournal.GetMountFromSpell(spell)
		if index then
			local _, mSpell, _, _, _, sourceType = C_MountJournal.GetMountInfoByID(index)
			if spell == mSpell then
				local _, _, source = C_MountJournal.GetMountInfoExtraByID(index)
				MountTable[spell] = { source = source, index = index }
			end
			return MountTable[spell]
		end
		return nil
	end
	return MountTable[spell]
end

local function AddLine(self, source, isCollectedText, type, noadd)
	for i = 1, self:NumLines() do
		local line = _G[self:GetName() .. "TextLeft" .. i]
		if not line then
			break
		end
		local text = line:GetText()
		if text and text == type then
			return
		end
	end
	if not noadd then
		self:AddLine(" ")
	end
	self:AddDoubleLine(type, isCollectedText)
	self:AddLine(source, 1, 1, 1)
	self:Show()
end

local function HandleAura(self, id)
	if IsShiftKeyDown() and UnitIsPlayer("target") then
		local table = id and GetOrCreateMountTable(id)
		if table then
			AddLine(self, table.source, IsCollected(id) and COLLECTED or NOT_COLLECTED, SOURCE)
		end
	end
end

function Module:CreateMountSource()
	if C_AddOns.IsAddOnLoaded("MountsSource") then
		return
	end

	hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
		HandleAura(self, select(10, UnitAura(...)))
	end)

	hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", function(self, unit, auraInstanceID)
		local data = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
		if data then
			HandleAura(self, data.spellId)
		end
	end)

	-- K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.MountsSource)
end

-- function Module:CreateMountSource()
-- 	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.MountsSource)
-- end
