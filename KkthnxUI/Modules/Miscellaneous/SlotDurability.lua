local K, C = unpack(select(2, ...))
local Module = K:NewModule("SlotDurability", "AceEvent-3.0", "AceHook-3.0")

local _G = _G

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
		SlotDurStrs[name]:FontTemplate(nil, 13, "OUTLINE")
		SlotDurStrs[name]:SetPoint("CENTER", 1, 0)

		SlotDurStrs[name].Shade = slot:CreateTexture()
		SlotDurStrs[name].Shade:SetDrawLayer("ARTWORK")
		SlotDurStrs[name].Shade:SetTexture([[Interface\AddOns\KkthnxUI\Media\Textures\Shader.tga]])
		SlotDurStrs[name].Shade:SetPoint("TOPLEFT", SlotDurStrs[name], "TOPLEFT", -6, 6)
		SlotDurStrs[name].Shade:SetPoint("BOTTOMRIGHT", SlotDurStrs[name], "BOTTOMRIGHT", 6, -6)
		SlotDurStrs[name].Shade:SetAlpha(1)
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

function Module:UpdateDurability()
	for _, item in ipairs(Slots) do
		local id, _ = GetInventorySlotInfo(item.."Slot")
		local v1, v2 = GetInventoryItemDurability(id)
		v1, v2 = tonumber(v1) or 0, tonumber(v2) or 0
		local percent = v1 / v2
		local SlotDurStr = GetDurStrings(item)

		if ((v2 ~= 0) and (percent ~= 1)) then

			SlotDurStr:SetText("")
			SlotDurStr.Shade:Hide()
			if (math.ceil(percent * 100) < 100)then
				SlotDurStr:SetTextColor(GetThresholdColour(percent))
				SlotDurStr.Shade:SetVertexColor(GetThresholdColour(percent))
				SlotDurStr.Shade:Show()
				SlotDurStr:SetText(math.ceil(percent * 100).."%")
			end
		else
			SlotDurStr:SetText("")
			SlotDurStr.Shade:Hide()
		end
	end
end

function Module:OnEnable()
	if not C["Misc"].SlotDurability then
		return
	end

	self:SecureHookScript(CharacterFrame, "OnShow", "CharacterFrame_OnShow")
	self:SecureHookScript(CharacterFrame, "OnHide", "CharacterFrame_OnHide")
end

function Module:CharacterFrame_OnShow()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateDurability")
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", "UpdateDurability")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY", "UpdateDurability")
	self:UpdateDurability()
end

function Module:CharacterFrame_OnHide()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UNIT_INVENTORY_CHANGED")
	self:UnregisterEvent("UPDATE_INVENTORY_DURABILITY")
end