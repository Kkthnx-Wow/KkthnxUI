local K, C = unpack(select(2, ...))
local Module = K:NewModule("BlizzBugFixes", "AceEvent-3.0", "AceHook-3.0")

if not Module then
	return
end

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

-- Fix Blank Tooltip
local bug = nil
local FixTooltip = CreateFrame("Frame")
FixTooltip:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
FixTooltip:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
FixTooltip:SetScript("OnEvent", function()
	if GameTooltip:IsShown() then
		bug = true
	end
end)

local FixTooltipBags = CreateFrame("Frame")
FixTooltipBags:RegisterEvent("BAG_UPDATE_DELAYED")
FixTooltipBags:SetScript("OnEvent", function()
	if StuffingFrameBags and StuffingFrameBags:IsShown() then
		if GameTooltip:IsShown() then
			bug = true
		end
	end
end)

GameTooltip:HookScript("OnTooltipCleared", function(self)
	if self:IsForbidden() then
		return
	end
	if bug and self:NumLines() == 0 then
		self:Hide()
		bug = false
	end
end)

-- Garbage Collection Is Being Overused And Misused,
-- And It's Causing Lag And Performance Drops.
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

	-- Memory Usage Is Unrelated To Performance, And Tracking Memory Usage Does Not Track "BAD" Addons.
	-- Developers Can Uncomment This Line To Enable The Functionality When Looking For Memory Leaks,
	-- But For The Average End-user This Is A Completely Pointless Thing To Track.
	_G.UpdateAddOnMemoryUsage = function() end
end

-- Misclicks For Some Popups
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

-- ALT+RightClick to buy a stack
function Module:BuyMaxStacks()
	local old_MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
	local cache = {}
	function MerchantItemButton_OnModifiedClick(self, ...)
		if IsAltKeyDown() then
			local id = self:GetID()
			local itemLink = GetMerchantItemLink(id)
			if not itemLink then return end
			local name, _, quality, _, _, _, _, maxStack, _, texture = GetItemInfo(itemLink)
			if maxStack and maxStack > 1 then
				if not cache[itemLink] then
					StaticPopupDialogs["BUY_STACK"] = {
						text = "Stack Buying Check",
						button1 = YES,
						button2 = NO,
						OnAccept = function()
							BuyMerchantItem(id, GetMerchantItemMaxStack(id))
							cache[itemLink] = true
						end,
						hideOnEscape = 1,
						hasItemFrame = 1,
					}

					local r, g, b = GetItemQualityColor(quality or 1)
					StaticPopup_Show("BUY_STACK", " ", " ", {["texture"] = texture, ["name"] = name, ["color"] = {r, g, b, 1}, ["link"] = itemLink, ["index"] = id, ["count"] = maxStack})
				else
					BuyMerchantItem(id, GetMerchantItemMaxStack(id))
				end
			end
		end

		old_MerchantItemButton_OnModifiedClick(self, ...)
	end
end

--	FrameStackGlobalizer(by Gethe)
function Module:FrameStackFix(self, event, addon)
	if addon == "Blizzard_DebugTools" then
		local EnumerateFrames = _G.EnumerateFrames
		local tostring = _G.tostring

		local ignore = {}
		local frames = {}
		local function FindFrame(hash)
			if ignore[hash] then
				return
			end

			if frames[hash] then
				return frames[hash]
			else
				local frame = EnumerateFrames()
				while frame do
					local frameHash = tostring(frame)
					if frameHash:find(hash) then
						frames[hash] = frame
						return frame
					end
					frame = EnumerateFrames(frame)
				end
			end

			ignore[hash] = true
		end

		local matchPattern, subPattern = "%s%%.(%%x*)%%.?", "(%s%%.%%x*)"
		local function TransformText(text)
			local parent = text:match("%s+([%w_]+)%.")
			if parent then
				local hash = text:match(matchPattern:format(parent))
				if hash and #hash > 5 then
					local frame = FindFrame(hash:upper())
					if frame and frame:GetName() then
						text = text:gsub(subPattern:format(parent), frame:GetName())
						return TransformText(text)
					end
				end
			end

			return text
		end

		_G.hooksecurefunc(_G.FrameStackTooltip, "SetFrameStack", function(self)
			for i = 1, self:NumLines() do
				local line = _G["FrameStackTooltipTextLeft"..i]
				local text = line:GetText()
				if text and text:find("<%d+>") then
					line:SetText(TransformText(text))
				end
			end
		end)
	end
end

function Module:OnEnable()
	-- Fix Spellbook Taint
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)

	self:MisclickPopups()
	self:BuyMaxStacks()
	self:RegisterEvent("ADDON_LOADED", "FrameStackFix")

	hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(self)
		self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
	end)

	for i = 0, 3 do
		local bagSlot = _G["CharacterBag"..i.."Slot"]
		bagSlot:UnregisterEvent("ITEM_PUSH") -- Gets Rid Of The Animation
	end

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)

	-- FixTradeSkillSearch
	hooksecurefunc("ChatEdit_InsertLink", function(text) -- Shift-Clicked
		-- Change From SearchBox:HasFocus to :IsShown Again
		if text and TradeSkillFrame and TradeSkillFrame:IsShown() then
			local spellId = string_match(text, "enchant:(%d+)")
			local spell = GetSpellInfo(spellId)
			local item = GetItemInfo(string_match(text, "item:(%d+)") or 0)
			local search = spell or item
			if not search then
				return
			end

			-- Search Needs To Be Lowercase For .SetRecipeItemNameFilter
			TradeSkillFrame.SearchBox:SetText(search)

			-- Jump To The Recipe
			if spell then -- Can Only Select Recipes On The Learned Tab
				if PanelTemplates_GetSelectedTab(TradeSkillFrame.RecipeList) == 1 then
					TradeSkillFrame:SelectRecipe(tonumber(spellId))
				end
			elseif item then
				C_Timer_After(.2, function() -- Wait A Bit Or We Cant Select The Recipe Yet
					for _, v in pairs(TradeSkillFrame.RecipeList.dataList) do
						if v.name == item then
							-- TradeSkillFrame.RecipeList:RefreshDisplay() -- Didnt Seem To Help
							TradeSkillFrame:SelectRecipe(v.recipeID)
							return
						end
					end
				end)
			end
		end
	end)

	-- Make It Only Split Stacks With Shift-RightClick If The Tradeskillframe Is Open
	-- Shift-LeftClick Should Be Reserved For The Search Box
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