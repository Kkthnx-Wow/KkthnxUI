local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local GetInventorySlotInfo = _G.GetInventorySlotInfo
local GetInventoryItemDurability = _G.GetInventoryItemDurability

local SLOTIDS = {}
for _, slot in pairs({"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand"}) do
	SLOTIDS[slot] = GetInventorySlotInfo(slot.."Slot")
end

local function RYGColorGradient(perc)
	local relperc = perc * 2 % 1
	if perc <= 0 then
		return 1, 0, 0
	elseif perc < 0.5 then
		return 1, relperc, 0
	elseif perc == 0.5 then
		return 1, 1, 0
	elseif perc < 1.0 then
		return 1 - relperc, 1, 0
	else
		return 0, 1, 0
	end
end

	local fontstrings = setmetatable({}, {
	__index = function(t, i)
		local gslot = _G["Character"..i.."Slot"]
		local fstr = K.CreateFontString(gslot, 12, "", "OUTLINE")
		fstr:SetPoint("TOPRIGHT", gslot, 1, -1)
		t[i] = fstr
		return fstr
	end,
})

function Module:SetupSlotDurability()
	local min = 1
	for slot, id in pairs(SLOTIDS) do
		local v1, v2 = GetInventoryItemDurability(id)

		if v1 and v2 and v2 ~= 0 then
			min = math.min(v1 / v2, min)
			local str = fontstrings[slot]
			str:SetTextColor(RYGColorGradient(v1 / v2))
			if v1 < v2 then
				str:SetText(string.format("%d%%", v1 / v2 * 100))
			else
				str:SetText(nil)
			end
		else
			local str = rawget(fontstrings, slot)
			if str then str:SetText(nil) end
		end
	end
end

function Module:CreateSlotDurability()
	if not C["Misc"].SlotDurability then
		return
	end

	Module:SetupSlotDurability()
	K:RegisterEvent("ADDON_LOADED", Module.SetupSlotDurability)
	K:RegisterEvent("UPDATE_INVENTORY_DURABILITY", Module.SetupSlotDurability)
end