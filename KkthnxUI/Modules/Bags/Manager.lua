--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Manager.lua
	Purpose:
		A small panel, opened from a button on the bag window, for making category
		groups and choosing which group each category folds into. It keeps the group
		workflow out in the open instead of buried in right-click menus. Groups are
		still renamed and deleted from the group header's own menu.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Bags")
if not Module then
	return
end

local ipairs = ipairs
local pairs = pairs
local type = type
local tonumber = tonumber
local tsort = table.sort
local strtrim = strtrim
local CreateFrame = CreateFrame
local StaticPopup_Show = StaticPopup_Show
local MenuUtil = MenuUtil
local GetCursorInfo = GetCursorInfo
local CursorHasItem = CursorHasItem
local ClearCursor = ClearCursor

-- Assign whatever item sits on the cursor to a category, then drop it back into
-- its slot. The rows are plain frames, so reading the cursor here cannot taint.
local function AssignCursorTo(catKey)
	if not catKey or not CursorHasItem() then
		return
	end
	local kind, a, b = GetCursorInfo()
	if kind ~= "item" then
		return
	end
	local itemID = (type(a) == "number" and a) or (b and tonumber(b:match("item:(%d+)")))
	if itemID then
		Module:AssignItem(itemID, catKey)
		ClearCursor()
		Module:RefreshManager()
	end
end

local ROW_H = 20
local GAP = 6
local PAD = 10

-- Base categories plus any custom ones, ignoring the gear-by-slot expansion so the
-- manager lists the real, assignable categories.
local function ManagedCategories()
	local list = {}
	for _, cat in ipairs(Module.Categories) do
		list[#list + 1] = cat
	end
	local custom = C.Bags.CustomCategories
	if custom then
		local keys = {}
		for key in pairs(custom) do
			keys[#keys + 1] = key
		end
		tsort(keys, function(a, b)
			return custom[a] < custom[b]
		end)
		for _, key in ipairs(keys) do
			list[#list + 1] = { key = key, name = custom[key] }
		end
	end
	return list
end

function Module:BuildManager()
	if self.Manager then
		return self.Manager
	end
	local f = CreateFrame("Frame", "KKUI_BagManager", UIParent)
	f:SetSize(280, 400)
	f:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	f:SetFrameStrata("DIALOG")
	f:SetClampedToScreen(true)
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	K.CreateGradientBackground(f, 0.95)
	K.CreateBorder(f)
	f:Hide()

	local title = f:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 15, K.FontOutlineStyle())
	title:SetPoint("TOPLEFT", f, "TOPLEFT", PAD, -10)
	title:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])
	title:SetText(L["Category Groups"])

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
	K.SkinCloseButton(close)

	local newGroup = CreateFrame("Button", nil, f)
	newGroup:SetSize(110, 20)
	newGroup:SetPoint("TOPLEFT", f, "TOPLEFT", PAD, -34)
	newGroup.Text = newGroup:CreateFontString(nil, "OVERLAY")
	K.SetFont(newGroup.Text, 12, K.FontOutlineStyle())
	newGroup.Text:SetPoint("CENTER")
	newGroup.Text:SetText(L["New Group"])
	K.SkinButton(newGroup)
	newGroup:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_BAGS_GROUPNAME", L["New Group"], nil, {
			default = "",
			callback = function(text)
				local name = strtrim(text or "")
				if name ~= "" then
					Module:CreateGroup(name)
					Module:RefreshManager()
				end
			end,
		})
	end)

	local newCat = CreateFrame("Button", nil, f)
	newCat:SetSize(110, 20)
	newCat:SetPoint("LEFT", newGroup, "RIGHT", GAP, 0)
	newCat.Text = newCat:CreateFontString(nil, "OVERLAY")
	K.SetFont(newCat.Text, 12, K.FontOutlineStyle())
	newCat.Text:SetPoint("CENTER")
	newCat.Text:SetText(L["New Category"])
	K.SkinButton(newCat)
	newCat:SetScript("OnClick", function()
		StaticPopup_Show("KKUI_BAGS_GROUPNAME", L["New Category"], nil, {
			default = "",
			callback = function(text)
				if Module:CreateCustomCategory(text) then
					Module:UpdateAll()
					Module:RefreshManager()
				end
			end,
		})
	end)

	local hint = f:CreateFontString(nil, "OVERLAY")
	K.SetFont(hint, 11, "")
	hint:SetPoint("TOPLEFT", newGroup, "BOTTOMLEFT", 0, -6)
	hint:SetTextColor(0.6, 0.6, 0.6)
	hint:SetText(L["Drag an item onto a category to add it."])

	f.rows = {}
	self.Manager = f
	return f
end

-- Fill the panel with a row per category, each showing the group it folds into.
function Module:RefreshManager()
	local f = self.Manager
	if not f then
		return
	end
	for _, row in ipairs(f.rows) do
		row:Hide()
	end

	local list = ManagedCategories()
	-- Start below the New Group / New Category row (-34, 20 tall) and the hint line.
	local y = -(34 + 20 + 16 + GAP)
	for i, cat in ipairs(list) do
		local row = f.rows[i]
		if not row then
			row = CreateFrame("Frame", nil, f)
			row:SetSize(260, ROW_H)
			-- Drag an item from the bags onto the row (or click-drop it) to file that
			-- item under this category.
			row:EnableMouse(true)
			row:SetScript("OnReceiveDrag", function(self)
				AssignCursorTo(self.catKey)
			end)
			row:SetScript("OnMouseUp", function(self)
				if CursorHasItem() then
					AssignCursorTo(self.catKey)
				end
			end)
			row.Name = row:CreateFontString(nil, "OVERLAY")
			K.SetFont(row.Name, 12, K.FontOutlineStyle())
			row.Name:SetPoint("LEFT", row, "LEFT", 2, 0)
			row.Group = CreateFrame("Button", nil, row)
			row.Group:SetSize(120, ROW_H)
			row.Group:SetPoint("RIGHT", row, "RIGHT", 0, 0)
			row.Group.Text = row.Group:CreateFontString(nil, "OVERLAY")
			K.SetFont(row.Group.Text, 12, "")
			row.Group.Text:SetPoint("CENTER")
			K.SkinButton(row.Group)
			f.rows[i] = row
		end

		local catKey = cat.key
		row.catKey = catKey
		row.Name:SetText(cat.name)
		local group = C.Bags.CategoryGroup and C.Bags.CategoryGroup[catKey]
		row.Group.Text:SetText(group or L["No Group"])
		row.Group:SetScript("OnClick", function(self)
			if not (MenuUtil and MenuUtil.CreateContextMenu) then
				return
			end
			MenuUtil.CreateContextMenu(self, function(_, root)
				root:CreateTitle(cat.name)
				root:CreateButton(L["New Group"], function()
					StaticPopup_Show("KKUI_BAGS_GROUPNAME", L["New Group"], nil, {
						default = "",
						callback = function(text)
							local name = strtrim(text or "")
							if name ~= "" then
								Module:CreateGroup(name)
								Module:AssignCategoryGroup(catKey, name)
								Module:RefreshManager()
							end
						end,
					})
				end)
				root:CreateDivider()
				root:CreateButton(L["No Group"], function()
					Module:AssignCategoryGroup(catKey, nil)
					Module:RefreshManager()
				end)
				for _, name in ipairs(Module:GroupOrder()) do
					root:CreateButton(name, function()
						Module:AssignCategoryGroup(catKey, name)
						Module:RefreshManager()
					end)
				end
				-- Send every item filed under this category back to auto sorting.
				root:CreateDivider()
				root:CreateButton(L["Clear Assigned Items"], function()
					Module:ClearCategoryItems(catKey)
					Module:RefreshManager()
				end)
				-- A custom category can be removed from here as well.
				if C.Bags.CustomCategories and C.Bags.CustomCategories[catKey] and Module.DeleteCustomCategory then
					root:CreateButton(L["Delete Category"], function()
						Module:DeleteCustomCategory(catKey)
						Module:RefreshManager()
					end)
				end
			end)
		end)

		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", f, "TOPLEFT", PAD, y)
		row:Show()
		y = y - (ROW_H + GAP)
	end

	-- Size the panel to its rows. The last row leaves a trailing gap, so the bottom
	-- padding is just the panel margin.
	f:SetHeight(-y - GAP + PAD)
end

function Module:ToggleManager()
	local f = self:BuildManager()
	if f:IsShown() then
		f:Hide()
	else
		self:RefreshManager()
		f:Show()
	end
end
