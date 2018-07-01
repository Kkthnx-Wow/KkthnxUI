local K = unpack(select(2, ...))
if K.CheckAddOnState("OneClickEnchantScroll") or (not C_TradeSkillUI) then
	return
end

local Module = K:NewModule("EnchantScroll", "AceEvent-3.0", "AceHook-3.0")

local _G = _G
local setmetatable = setmetatable

local CraftRecipe = _G.C_TradeSkillUI.CraftRecipe
local GetItemCount = _G.GetItemCount
local GetLocale = _G.GetLocale
local GetRecipeInfo = _G.C_TradeSkillUI.GetRecipeInfo
local GetSpellInfo = _G.GetSpellInfo
local GetTradeSkillLine = _G.C_TradeSkillUI.GetTradeSkillLine
local hooksecurefunc = _G.hooksecurefunc
local IsNPCCrafting = _G.C_TradeSkillUI.IsNPCCrafting
local IsTradeSkillGuild = _G.C_TradeSkillUI.IsTradeSkillGuild
local IsTradeSkillLinked = _G.C_TradeSkillUI.IsTradeSkillLinked
local UseItemByName = _G.UseItemByName

-- ItemID of enchanter vellums
local ENCHANTING_TEXT = GetSpellInfo(7411)
local SCROLL_ID = 38682
local SCROLL_TEXT =
	(setmetatable(
	{
		deDE = "Rolle",
		frFR = "Parchemin",
		itIT = "Pergamene",
		esES = "Pergamino",
		esMX = "Pergamino",
		ptBR = "Pergaminho",
		ptPT = "Pergaminho",
		ruRU = "Свиток",
		koKR = "두루마리",
		zhCN = "卷轴",
		zhTW = "卷軸"
	},
	{
		__index = function(t, v)
			return "Scroll"
		end
	}
))[(GetLocale())]

function Module:EnableScrollButton()
	local TradeSkillFrame = _G.TradeSkillFrame

	local enchantScrollButton =
		CreateFrame("Button", "TradeSkillCreateScrollButton", TradeSkillFrame, "MagicButtonTemplate")
	enchantScrollButton:SetPoint("TOPRIGHT", TradeSkillFrame.DetailsFrame.CreateButton, "TOPLEFT")
	enchantScrollButton:SetPoint("LEFT", TradeSkillFrame.DetailsFrame, "LEFT") -- make the button as big as we can
	enchantScrollButton:SetScript(
		"OnClick",
		function()
			CraftRecipe(TradeSkillFrame.DetailsFrame.selectedRecipeID)
			UseItemByName(SCROLL_ID)
		end
	)
	enchantScrollButton:SetMotionScriptsWhileDisabled(true)
	enchantScrollButton:Hide()

	hooksecurefunc(
		TradeSkillFrame.DetailsFrame,
		"RefreshButtons",
		function(self)
			if (IsTradeSkillGuild() or IsNPCCrafting() or IsTradeSkillLinked()) then
				enchantScrollButton:Hide()
			else
				local recipeInfo = self.selectedRecipeID and GetRecipeInfo(self.selectedRecipeID)
				if (recipeInfo and recipeInfo.alternateVerb) then
					local _, tradeSkillName = GetTradeSkillLine()
					if (tradeSkillName == ENCHANTING_TEXT) then
						enchantScrollButton:Show()

						local numCreateable = recipeInfo.numAvailable
						local numScrollsAvailable = GetItemCount(SCROLL_ID)

						enchantScrollButton:SetFormattedText("%s (%d)", SCROLL_TEXT, numScrollsAvailable)

						if (numScrollsAvailable == 0) then
							numCreateable = 0
						end

						if (numCreateable > 0) then
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
		end
	)
end

function Module:OnEvent(event, ...)
	if (event == "ADDON_LOADED") then
		local arg = ...
		if (arg == "Blizzard_TradeSkillUI") then
			self:EnableScrollButton()
			self:UnregisterEvent("ADDON_LOADED", "OnEvent")
		end
	end
end

function Module:OnInitialize()
	if IsAddOnLoaded("Blizzard_TradeSkillUI") then
		self:EnableScrollButton()
	else
		self:RegisterEvent("ADDON_LOADED", "OnEvent")
	end
end
