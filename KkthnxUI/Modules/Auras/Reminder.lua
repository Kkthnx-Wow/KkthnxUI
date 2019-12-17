local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Auras")

local _G = _G
local next = next
local pairs = pairs
local table_insert = table.insert
local unpack = unpack

local CreateFrame = _G.CreateFrame
local GetSpecialization = _G.GetSpecialization
local GetSpellTexture = _G.GetSpellTexture
local GetZonePVPInfo = _G.GetZonePVPInfo
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local IsPlayerSpell = _G.IsPlayerSpell
local UIParent = _G.UIParent
local UnitBuff = _G.UnitBuff
local UnitInVehicle = _G.UnitInVehicle

local groups = K.ReminderBuffs[K.Class]
local iconSize = C["Auras"].DebuffSize + 4
local frames, parentFrame = {}
function Module:Reminder_Update(cfg)
	local frame = cfg.frame
	local depend = cfg.depend
	local spec = cfg.spec
	local combat = cfg.combat
	local instance = cfg.instance
	local pvp = cfg.pvp
	local isPlayerSpell, isRightSpec, isInCombat, isInInst, isInPVP = true, true
	local inInst, instType = IsInInstance()

	if depend and not IsPlayerSpell(depend) then
		isPlayerSpell = false
	end

	if spec and spec ~= GetSpecialization() then
		isRightSpec = false
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
	if isPlayerSpell and isRightSpec and (isInCombat or isInInst or isInPVP) and not UnitInVehicle("player") then
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
	frame:CreateInnerShadow()

	for spell in pairs(cfg.spells) do
		frame.Icon:SetTexture(GetSpellTexture(spell))
		break
	end

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFontObject(K.GetFont(C["UIFonts"].AuraFonts))
	frame.text:SetText(L["Lack"])
	frame.text:SetPoint("TOP", frame, "TOP", 1, 15)

	frame:Hide()
	cfg.frame = frame

	table_insert(frames, frame)
end

function Module:Reminder_UpdateAnchor()
	local index = 0
	local offset = iconSize + 6
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

	K:RegisterEvent("UNIT_AURA", self.Reminder_OnEvent, "player")
	K:RegisterEvent("UNIT_EXITED_VEHICLE", self.Reminder_OnEvent)
	K:RegisterEvent("UNIT_ENTERED_VEHICLE", self.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", self.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", self.Reminder_OnEvent)
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", self.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.Reminder_OnEvent)
end