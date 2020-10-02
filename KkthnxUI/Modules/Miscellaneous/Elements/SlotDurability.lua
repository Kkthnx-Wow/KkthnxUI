local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local math_ceil = _G.math.ceil
local tonumber = _G.tonumber

local GetInventorySlotInfo = _G.GetInventorySlotInfo
local GetInventoryItemDurability = _G.GetInventoryItemDurability

local SlotDurStrs = {}
local Slots = {
	"Head",
	"Shoulder",
	"Chest",
	"Waist",
	"Legs",
	"Feet",
	"Wrist",
	"Hands",
	"MainHand",
	"SecondaryHand"
}

local function GetDurStrings(name)
	if (not SlotDurStrs[name]) then
		local slot = _G["Character"..name.."Slot"]
		SlotDurStrs[name] = slot:CreateFontString("OVERLAY")
		SlotDurStrs[name]:FontTemplate(nil, 11, "OUTLINE")
		SlotDurStrs[name]:SetPoint("TOPRIGHT", 1, -1)
	end

	return SlotDurStrs[name]
end

local function GetThresholdColour(percent)
	if percent < 0 then
		return 1, 0, 0
	elseif percent <= 0.5 then
		return 1, percent * 2, 0
	elseif percent >= 1 then
		return 0, 1, 0
	else
		return 2 - percent * 2, 1, 0
	end
end

function Module.UpdateDurability()
	for _, item in ipairs(Slots) do
		local id, _ = GetInventorySlotInfo(item.."Slot")
		local v1, v2 = GetInventoryItemDurability(id)
		v1, v2 = tonumber(v1) or 0, tonumber(v2) or 0
		local percent = v1 / v2
		local SlotDurStr = GetDurStrings(item)

		if ((v2 ~= 0) and (percent ~= 1)) then
			SlotDurStr:SetText("")
			if (math_ceil(percent * 100) < 100) then
				SlotDurStr:SetTextColor(GetThresholdColour(percent))
				SlotDurStr:SetText(math_ceil(percent * 100).."%")
			end
		else
			SlotDurStr:SetText("")
		end
	end
end

function Module:CreateSlotDurability()
	if not C["Misc"].SlotDurability then
		return
	end

	CharacterFrame:HookScript("OnShow", Module.CharacterFrame_OnShow)
	CharacterFrame:HookScript("OnHide", Module.CharacterFrame_OnHide)
end

function Module.CharacterFrame_OnShow()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.UpdateDurability)
	K:RegisterEvent("UNIT_INVENTORY_CHANGED", Module.UpdateDurability)
	K:RegisterEvent("UPDATE_INVENTORY_DURABILITY", Module.UpdateDurability)
	Module.UpdateDurability()
end

function Module.CharacterFrame_OnHide()
	K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.UpdateDurability)
	K:UnregisterEvent("UNIT_INVENTORY_CHANGED", Module.UpdateDurability)
	K:UnregisterEvent("UPDATE_INVENTORY_DURABILITY", Module.UpdateDurability)
end