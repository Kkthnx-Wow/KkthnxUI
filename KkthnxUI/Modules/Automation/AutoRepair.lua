local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("KkthnxUI_Repair", "AceEvent-3.0")

-- Lua WoW
local _G = _G
local math_floor = math.floor

-- Lua API
local IsShiftKeyDown = _G.IsShiftKeyDown
local CanMerchantRepair = _G.CanMerchantRepair
local GetRepairAllCost = _G.GetRepairAllCost
local IsInGuild = _G.IsInGuild
local CanGuildBankRepair = _G.CanGuildBankRepair
local RepairAllItems = _G.RepairAllItems

-- Repair when suitable merchant frame is shown
function Module:MERCHANT_SHOW()
	if IsShiftKeyDown() then return end

	if CanMerchantRepair() then -- If merchant is capable of repair
		-- Process repair
		local RepairCost, CanRepair = GetRepairAllCost()
		if CanRepair then -- If merchant is offering repair
			if C["Automation"].UseGuildRepairFunds and IsInGuild() then
				-- Guilded character and guild repair option is enabled
				if CanGuildBankRepair() then
					-- Character has permission to repair so try guild funds but fallback on character funds (if daily gold limit is reached)
					RepairAllItems(1)
					RepairAllItems()
				else
					-- Character does not have permission to repair so use character funds
					RepairAllItems()
				end
			else
				-- Unguilded character or guild repair option is disabled
				RepairAllItems()
			end
			-- Show cost summary
			local gold, silver, copper = math_floor(RepairCost / 10000) or 0, math_floor((RepairCost % 10000) / 100) or 0, RepairCost % 100
			K.Print("Repaired for:".." |cffffffff"..gold..L["Miscellaneous"].Gold_Short.." |cffffffff"..silver..L["Miscellaneous"].Silver_Short.." |cffffffff"..copper..L["Miscellaneous"].Copper_Short..".")
		end
	end
end

function Module:OnEnable()
	if C["Automation"].AutoRepair ~= true then return end
	self:RegisterEvent("MERCHANT_SHOW")
end

function Module:OnDisable()
	self:UnregisterEvent("MERCHANT_SHOW")
end