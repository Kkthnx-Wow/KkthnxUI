local K, C = unpack(select(2, ...))
local Module = K:NewModule("BlizzBugFixes", "AceEvent-3.0", "AceHook-3.0")

local _G = _G
local pairs = pairs
local string_match = string.match
local tonumber = tonumber

local blizzardCollectgarbage = _G.collectgarbage
local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local DELETE_ITEM_CONFIRM_STRING = _G.DELETE_ITEM_CONFIRM_STRING
local GetItemInfo = _G.GetItemInfo
local GetSpellInfo = _G.GetSpellInfo
local hooksecurefunc = _G.hooksecurefunc
local PanelTemplates_GetSelectedTab = _G.PanelTemplates_GetSelectedTab
local PVPReadyDialog = _G.PVPReadyDialog
local ShowUIPanel, HideUIPanel = _G.ShowUIPanel, _G.HideUIPanel
local StaticPopupDialogs = _G.StaticPopupDialogs

-- Garbage collection is being overused and misused,
-- and it's causing lag and performance drops.
if C["General"].FixGarbageCollect then
	blizzardCollectgarbage("setpause", 110)
	blizzardCollectgarbage("setstepmul", 200)

	_G.collectgarbage = function(opt, arg)
		if (opt == "collect") or (opt == nil) then
		elseif (opt == "count") then
			return blizzardCollectgarbage(opt, arg)
		elseif (opt == "setpause") then
			return blizzardCollectgarbage("setpause", 110)
		elseif opt == "setstepmul" then
			return blizzardCollectgarbage("setstepmul", 200)
		elseif (opt == "stop") then
		elseif (opt == "restart") then
		elseif (opt == "step") then
			if (arg ~= nil) then
				if (arg <= 10000) then
					return blizzardCollectgarbage(opt, arg)
				end
			else
				return blizzardCollectgarbage(opt, arg)
			end
		else
			return blizzardCollectgarbage(opt, arg)
		end
	end

	-- Memory usage is unrelated to performance, and tracking memory usage does not track "bad" addons.
	-- Developers can uncomment this line to enable the functionality when looking for memory leaks,
	-- but for the average end-user this is a completely pointless thing to track.
	_G.UpdateAddOnMemoryUsage = function() end
end

-- Misclicks for some popups
function Module:MisclickPopups()
	StaticPopupDialogs.RESURRECT.hideOnEscape = nil
	StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
	StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
	StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
	StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
	StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil

	_G.PetBattleQueueReadyFrame.hideOnEscape = nil

	if (PVPReadyDialog) then
		PVPReadyDialog.leaveButton:Hide()
		PVPReadyDialog.enterButton:ClearAllPoints()
		PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
	end
end

function Module:OnEnable()
	self:MisclickPopups()

	-- Fix spellbook taint
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)

	hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(self)
		self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
	end)

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	-- FixTradeSkillSearch
	hooksecurefunc("ChatEdit_InsertLink", function(text) -- shift-clicked
		-- change from SearchBox:HasFocus to :IsShown again
		if text and TradeSkillFrame and TradeSkillFrame:IsShown() then
			local spellId = string_match(text, "enchant:(%d+)")
			local spell = GetSpellInfo(spellId)
			local item = GetItemInfo(string_match(text, "item:(%d+)") or 0)
			local search = spell or item
			if not search then
				return
			end

			-- search needs to be lowercase for .SetRecipeItemNameFilter
			TradeSkillFrame.SearchBox:SetText(search)

			-- jump to the recipe
			if spell then -- can only select recipes on the learned tab
				if PanelTemplates_GetSelectedTab(TradeSkillFrame.RecipeList) == 1 then
					TradeSkillFrame:SelectRecipe(tonumber(spellId))
				end
			elseif item then
				C_Timer_After(.2, function() -- wait a bit or we cant select the recipe yet
					for _, v in pairs(TradeSkillFrame.RecipeList.dataList) do
						if v.name == item then
							--TradeSkillFrame.RecipeList:RefreshDisplay() -- didnt seem to help
							TradeSkillFrame:SelectRecipe(v.recipeID)
							return
						end
					end
				end)
			end
		end
	end)

	-- make it only split stacks with shift-rightclick if the TradeSkillFrame is open
	-- shift-leftclick should be reserved for the search box
	local function hideSplitFrame(_, button)
		if TradeSkillFrame and TradeSkillFrame:IsShown() then
			if button == "LeftButton" then
				StackSplitFrame:Hide()
			end
		end
	end
	hooksecurefunc("ContainerFrameItemButton_OnModifiedClick", hideSplitFrame)
	hooksecurefunc("MerchantItemButton_OnModifiedClick", hideSplitFrame)
end