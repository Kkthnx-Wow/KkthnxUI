--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Assign.lua
	Purpose:
		Let the player pin an item to a category of their choosing, and make their
		own categories to pin into. Middle-click an item to open the assign menu.
		Assignments and custom categories both persist in the profile, and an
		assignment overrides the automatic sorting for that item.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Bags")
if not Module then
	return
end

local ipairs = ipairs
local pairs = pairs
local strtrim = strtrim
local StaticPopup_Show = StaticPopup_Show
local MenuUtil = MenuUtil
local IsSecret = K.IsSecret
local C_Container = C_Container

function Module:CreateCustomCategory(name)
	name = name and strtrim(name)
	if not name or name == "" then
		return nil
	end
	local key = "custom:" .. name
	K:SetConfig({ "Bags", "CustomCategories", key }, name)
	return key
end

function Module:DeleteCustomCategory(key)
	for itemID, cat in pairs(C.Bags.ItemAssignments or {}) do
		if cat == key then
			K:SetConfig({ "Bags", "ItemAssignments", itemID }, nil)
		end
	end
	K:SetConfig({ "Bags", "CustomCategories", key }, nil)
	K:SetConfig({ "Bags", "Collapsed", key }, nil)
	self:UpdateAll()
end

function Module:AssignItem(itemID, catKey)
	K:SetConfig({ "Bags", "ItemAssignments", itemID }, catKey)
	self:UpdateAll()
end

function Module:UnassignItem(itemID)
	K:SetConfig({ "Bags", "ItemAssignments", itemID }, nil)
	self:UpdateAll()
end

-- Flag or unflag an item as junk. Flagged items sort into Junk, fade like grey
-- trash, and sell with the rest at a merchant.
function Module:ToggleJunk(itemID)
	local flagged = C.Bags.JunkList and C.Bags.JunkList[itemID]
	K:SetConfig({ "Bags", "JunkList", itemID }, not flagged or nil)
	self:UpdateAll()
end

-- Send every item filed under a category back to automatic sorting.
function Module:ClearCategoryItems(catKey)
	if C.Bags.ItemAssignments then
		for itemID, key in pairs(C.Bags.ItemAssignments) do
			if key == catKey then
				K:SetConfig({ "Bags", "ItemAssignments", itemID }, nil)
			end
		end
	end
	self:UpdateAll()
end

-- Wipe every custom item assignment and junk flag back to defaults.
function Module:ResetItemAssignments()
	K:SetConfig({ "Bags", "ItemAssignments" }, {})
	K:SetConfig({ "Bags", "JunkList" }, {})
	self:UpdateAll()
end

-- Middle-click assign menu, driven off whatever item is under the button.
function Module:ShowAssignMenu(button)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	local bag = button:GetParent():GetID()
	local slot = button:GetID()
	local info = C_Container.GetContainerItemInfo(bag, slot)
	local itemID = info and info.itemID
	if not itemID or IsSecret(itemID) then
		return
	end

	MenuUtil.CreateContextMenu(button, function(_, root)
		root:CreateTitle(L["Assign To Category"])
		local ordered = Module.OrderedCategories and Module:OrderedCategories() or Module.Categories
		for _, cat in ipairs(ordered) do
			root:CreateButton(cat.name, function()
				Module:AssignItem(itemID, cat.key)
			end)
		end
		root:CreateButton(L["New Category"], function()
			StaticPopup_Show("KKUI_BAGS_GROUPNAME", L["New Category"], nil, {
				default = "",
				callback = function(text)
					local key = Module:CreateCustomCategory(text)
					if key then
						Module:AssignItem(itemID, key)
					end
				end,
			})
		end)
		if C.Bags.ItemAssignments and C.Bags.ItemAssignments[itemID] then
			root:CreateButton(L["Unassign"], function()
				Module:UnassignItem(itemID)
			end)
		end
		root:CreateDivider()
		local flagged = C.Bags.JunkList and C.Bags.JunkList[itemID]
		root:CreateButton(flagged and L["Unmark Junk"] or L["Mark As Junk"], function()
			Module:ToggleJunk(itemID)
		end)
	end)
end
