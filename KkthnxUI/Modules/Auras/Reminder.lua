local K, C = unpack(select(2, ...))
local Module = K:GetModule("Auras")

local _G = _G
local pairs, tinsert, next = pairs, table.insert, next

local GetSpecialization, InCombatLockdown, GetZonePVPInfo, UnitInVehicle = _G.GetSpecialization, _G.InCombatLockdown, _G.GetZonePVPInfo, _G.UnitInVehicle
local IsInInstance, IsPlayerSpell, UnitBuff, GetSpellTexture = _G.IsInInstance, _G.IsPlayerSpell, _G.UnitBuff, _G.GetSpellTexture

local groups = K.ReminderBuffs[K.Class]
local iconSize = 36
local frames, parentFrame = {}
function Module:Reminder_Update(cfg)
	local frame = cfg.frame
	local depend = cfg.depend
	local spec = cfg.spec
	local combat = cfg.combat
	local instance = cfg.instance
	local level = cfg.level
	local pvp = cfg.pvp
	local isPlayerSpell, isRightSpec, isRightLevel, isInCombat, isInInst, isInPVP = true, true, true
	local inInst, instType = IsInInstance()

	if depend and not IsPlayerSpell(depend) then
		isPlayerSpell = false
	end

	if spec and spec ~= GetSpecialization() then
		isRightSpec = false
	end

	if level and K.Level < level then
		print("You are not the correct level to be notified about spell your spell")
		isRightLevel = false
	end

	if combat and InCombatLockdown() then
		isInCombat = true
	end

	if instance and inInst and (instType == "scenario" or instType == "party" or instType == "raid") then
		isInInst = true
	end

	if pvp and (instType == "arena" or instType == "pvp" or GetZonePVPInfo() == "combat") then
		isInPVP = true
	end

	if not combat and not instance and not pvp then
		isInCombat, isInInst, isInPVP = true, true, true
	end

	frame:Hide()
	if isPlayerSpell and isRightSpec and isRightLevel and (isInCombat or isInInst or isInPVP) and not UnitInVehicle("player") then
		for i = 1, 32 do
			local name, _, _, _, _, _, _, _, _, spellID = UnitBuff("player", i)
			if not name then
				break
			end

			if name and cfg.spells[spellID] then
				frame:Hide()
				return
			end
		end
		frame:Show()
	end
end

function Module:Reminder_Create(cfg)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)

	frame.Icon = frame:CreateTexture(nil, "ARTWORK")
	frame.Icon:SetAllPoints()
	frame.Icon:SetTexCoord(unpack(K.TexCoords))

	frame:CreateBorder()

	for spell in pairs(cfg.spells) do
		frame.Icon:SetTexture(GetSpellTexture(spell))
		break
	end

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFont(C["Media"].Font, 12, "OUTLINE")
	frame.text:SetText("??")
	frame.text:SetPoint("TOP", frame, "TOP", 1, 15)

	frame:Hide()
	cfg.frame = frame

	tinsert(frames, frame)
end

function Module:Reminder_UpdateAnchor()
	local index = 0
	local offset = iconSize + 5
	for _, frame in next, frames do
		if frame:IsShown() then
			frame:SetPoint("LEFT", offset * index, 0)
			index = index + 1
		end
	end
	parentFrame:SetWidth(offset * index)
end

function Module:Reminder_OnEvent()
	for _, cfg in pairs(groups) do
		if not cfg.frame then
			Module:Reminder_Create(cfg)
		end
		Module:Reminder_Update(cfg)
	end
	Module:Reminder_UpdateAnchor()
end

function Module:CreateReminder()
	if not groups then
		return
	end

	if not C["Auras"].Reminder then
		return
	end

	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetPoint("CENTER", -220, 130)
	parentFrame:SetSize(iconSize, iconSize)

	K:RegisterEvent("UNIT_AURA", Module.Reminder_OnEvent, "player")
	K:RegisterEvent("UNIT_EXITED_VEHICLE", Module.Reminder_OnEvent)
	K:RegisterEvent("UNIT_ENTERED_VEHICLE", Module.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
end