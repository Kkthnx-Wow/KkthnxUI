--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Groups.lua
	Purpose:
		Let categories be folded together under a named group header. A right-click
		on any category header opens a menu to start a new group, add the category to
		an existing group, or take it back out. Group headers themselves can be
		renamed or deleted. Everything persists in the profile.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Bags")
if not Module then
	return
end

local _G = _G
local ipairs = ipairs
local pairs = pairs
local tsort = table.sort
local strtrim = strtrim
local StaticPopup_Show = StaticPopup_Show
local MenuUtil = MenuUtil

-- Groups live as a name -> order map so a leaf write persists each one, and the
-- render order falls out of the order value. CategoryGroup maps a category key to
-- its group name.
local function GroupsTable()
	C.Bags.Groups = C.Bags.Groups or {}
	return C.Bags.Groups
end

local function CategoryGroupTable()
	C.Bags.CategoryGroup = C.Bags.CategoryGroup or {}
	return C.Bags.CategoryGroup
end

local function NextOrder()
	local highest = 0
	for _, order in pairs(GroupsTable()) do
		if order > highest then
			highest = order
		end
	end
	return highest + 1
end

-- Ordered list of group names for the layout and the menu.
function Module:GroupOrder()
	local list = {}
	for name in pairs(GroupsTable()) do
		list[#list + 1] = name
	end
	tsort(list, function(a, b)
		return GroupsTable()[a] < GroupsTable()[b]
	end)
	return list
end

function Module:CreateGroup(name)
	name = name and strtrim(name)
	if not name or name == "" or GroupsTable()[name] then
		return
	end
	K:SetConfig({ "Bags", "Groups", name }, NextOrder())
end

function Module:AssignCategoryGroup(catKey, groupName)
	K:SetConfig({ "Bags", "CategoryGroup", catKey }, groupName)
	self:UpdateAll()
end

function Module:DeleteGroup(name)
	for cat, group in pairs(CategoryGroupTable()) do
		if group == name then
			K:SetConfig({ "Bags", "CategoryGroup", cat }, nil)
		end
	end
	K:SetConfig({ "Bags", "Groups", name }, nil)
	K:SetConfig({ "Bags", "Collapsed", "group:" .. name }, nil)
	self:UpdateAll()
end

function Module:RenameGroup(old, new)
	new = new and strtrim(new)
	if not new or new == "" or GroupsTable()[new] then
		return
	end
	K:SetConfig({ "Bags", "Groups", new }, GroupsTable()[old])
	K:SetConfig({ "Bags", "Groups", old }, nil)
	for cat, group in pairs(CategoryGroupTable()) do
		if group == old then
			K:SetConfig({ "Bags", "CategoryGroup", cat }, new)
		end
	end
	self:UpdateAll()
end

-- ---------------------------------------------------------------------------
-- Name prompt
-- ---------------------------------------------------------------------------

_G.StaticPopupDialogs = _G.StaticPopupDialogs or {}
_G.StaticPopupDialogs["KKUI_BAGS_GROUPNAME"] = {
	text = "%s",
	button1 = _G.ACCEPT,
	button2 = _G.CANCEL,
	hasEditBox = true,
	OnShow = function(self, data)
		local editBox = self.EditBox or self.editBox
		if editBox then
			editBox:SetText(data and data.default or "")
			editBox:SetFocus()
			editBox:HighlightText()
		end
	end,
	OnAccept = function(self, data)
		local editBox = self.EditBox or self.editBox
		if data and data.callback and editBox then
			data.callback(editBox:GetText())
		end
	end,
	EditBoxOnEnterPressed = function(self, data)
		if data and data.callback then
			data.callback(self:GetText())
		end
		self:GetParent():Hide()
	end,
	EditBoxOnEscapePressed = function(self)
		self:GetParent():Hide()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
}

local function PromptName(title, default, callback)
	StaticPopup_Show("KKUI_BAGS_GROUPNAME", title, nil, { default = default, callback = callback })
end

-- ---------------------------------------------------------------------------
-- Header right-click menu
-- ---------------------------------------------------------------------------

function Module:ShowGroupMenu(header)
	if not (MenuUtil and MenuUtil.CreateContextMenu) then
		return
	end
	local groupName = header.groupName
	local catKey = header.catKey

	MenuUtil.CreateContextMenu(header, function(_, root)
		if groupName then
			root:CreateTitle(groupName)
			root:CreateButton(L["Rename Group"], function()
				PromptName(L["Rename Group"], groupName, function(text)
					Module:RenameGroup(groupName, text)
				end)
			end)
			root:CreateButton(L["Delete Group"], function()
				Module:DeleteGroup(groupName)
			end)
			return
		end

		if not catKey then
			return
		end
		root:CreateTitle(header.Text and header.Text:GetText() or L["Category"])

		-- A custom category the player made can be removed outright.
		if C.Bags.CustomCategories and C.Bags.CustomCategories[catKey] and Module.DeleteCustomCategory then
			root:CreateButton(L["Delete Category"], function()
				Module:DeleteCustomCategory(catKey)
			end)
		end
		-- Make an empty group. It stays invisible until categories are added to it
		-- through Add to Group, so a new group never looks like a rename of this one.
		root:CreateButton(L["New Group"], function()
			PromptName(L["New Group"], "", function(text)
				local groupName = strtrim(text or "")
				if groupName == "" then
					return
				end
				Module:CreateGroup(groupName)
			end)
		end)

		local groups = Module:GroupOrder()
		if #groups > 0 then
			local add = root:CreateButton(L["Add to Group"])
			for _, name in ipairs(groups) do
				add:CreateButton(name, function()
					Module:AssignCategoryGroup(catKey, name)
				end)
			end
		end

		if CategoryGroupTable()[catKey] then
			root:CreateButton(L["Remove from Group"], function()
				Module:AssignCategoryGroup(catKey, nil)
			end)
		end
	end)
end
