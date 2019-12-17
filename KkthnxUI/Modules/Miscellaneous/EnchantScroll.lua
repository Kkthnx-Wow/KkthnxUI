local K, C = unpack(select(2, ...))

-- Sourced: OneClickEnchantScroll (Sara.Festung)

local _G = _G

local C_TradeSkillUI_CraftRecipe = _G.C_TradeSkillUI.CraftRecipe
local C_TradeSkillUI_GetRecipeInfo = _G.C_TradeSkillUI.GetRecipeInfo
local C_TradeSkillUI_GetTradeSkillLine = _G.C_TradeSkillUI.GetTradeSkillLine
local C_TradeSkillUI_IsNPCCrafting = _G.C_TradeSkillUI.IsNPCCrafting
local C_TradeSkillUI_IsTradeSkillGuild = _G.C_TradeSkillUI.IsTradeSkillGuild
local C_TradeSkillUI_IsTradeSkillLinked = _G.C_TradeSkillUI.IsTradeSkillLinked
local GetItemCount = _G.GetItemCount
local IsAddOnLoaded = _G.IsAddOnLoaded
local UseItemByName = _G.UseItemByName
local hooksecurefunc = _G.hooksecurefunc

local function CreateEnchantScroll(event, addon)
	if C["Misc"].EnchantmentScroll ~= true then
		return
	end

	if event == "ADDON_LOADED" and addon == "Blizzard_TradeSkillUI" and not IsAddOnLoaded("OneClickEnchantScroll") then
		local enchantScrollButton = CreateFrame("Button", "TradeSkillCreateScrollButton", TradeSkillFrame, "MagicButtonTemplate")
		enchantScrollButton:SetPoint("TOPRIGHT", TradeSkillFrame.DetailsFrame.CreateButton, "TOPLEFT")
		enchantScrollButton:SetScript("OnClick", function()
			C_TradeSkillUI_CraftRecipe(TradeSkillFrame.DetailsFrame.selectedRecipeID)
			UseItemByName(38682)
		end)

		hooksecurefunc(TradeSkillFrame.DetailsFrame, "RefreshButtons", function(self)
			if C_TradeSkillUI_IsTradeSkillGuild() or C_TradeSkillUI_IsNPCCrafting() or C_TradeSkillUI_IsTradeSkillLinked() then
				enchantScrollButton:Hide()
			else
				local recipeInfo = self.selectedRecipeID and C_TradeSkillUI_GetRecipeInfo(self.selectedRecipeID)
				if recipeInfo and recipeInfo.alternateVerb then
					local _, _, _, _, _, parentSkillLineID = C_TradeSkillUI_GetTradeSkillLine()
					if parentSkillLineID == 333 then
						enchantScrollButton:Show()
						local numCreateable = recipeInfo.numAvailable
						local numScrollsAvailable = GetItemCount(38682)
						enchantScrollButton:SetText("Scroll".." ("..numScrollsAvailable..")")
						if numScrollsAvailable == 0 then
							numCreateable = 0
						end

						if numCreateable > 0 then
							enchantScrollButton:Enable()
						else
							enchantScrollButton:Disable()
						end
					else
						enchantScrollButton:Hide()
					end
				else
					enchantScrollButton:Hide()
				end
			end
		end)

		K:UnregisterEvent(event, CreateEnchantScroll)
	end
end

K:RegisterEvent("ADDON_LOADED", CreateEnchantScroll)