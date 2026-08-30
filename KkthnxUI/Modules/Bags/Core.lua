--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Core.lua
	Purpose:
		An all-in-one, auto categorised bag and bank replacement built on the
		C_Container API. This file owns the module, the shared container window
		(backdrop, border, title, toolbar, item grid), the categorised layout,
		the refresh pipeline, and the hooks that hand the bag keys to us instead
		of Blizzard's ContainerFrame. Item buttons live in Slots.lua, the section
		rules in Categories.lua, and the bank window in Bank.lua. Retail only.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- The bag window is built on C_Container, which exists on retail and the modern
-- classic flavours (TBC Anniversary included) but not on ancient clients. Gate on
-- the API itself rather than the flavour so the main bags come up anywhere it is
-- present. The bank window (Bank.lua) stays retail only, and Core guards every
-- call into it, so an absent bank degrades to Blizzard's on those flavours.
if not (C_Container and C_Container.GetContainerNumSlots) then
	return
end

local Module = K:NewModule("Bags")

local _G = _G
local ceil = math.ceil
local floor = math.floor
local max = math.max
local ipairs = ipairs
local select = select
local tinsert = table.insert
local tsort = table.sort
local Enum = Enum
local IsSecret = K.IsSecret

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local GetMoney = GetMoney
local GetCoinTextureString = GetCoinTextureString
local C_Container = C_Container
local C_Item = C_Item
local SetItemButtonCount = SetItemButtonCount
local C_Timer = C_Timer
local C_MerchantFrame = C_MerchantFrame
local C_CurrencyInfo = C_CurrencyInfo
local BreakUpLargeNumbers = BreakUpLargeNumbers

-- Bags carried on the character: backpack, the four bags, and the reagent bag.
Module.BagIDs = { 0, 1, 2, 3, 4, 5 }

-- Window geometry. The top band holds the title and search, the bottom band the
-- money and free-slot readouts, and the item grid sits between them.
local MARGIN = 12
local TOP_BAND = 40
local BOTTOM_BAND = 44 -- money / free slots on one line, currencies above them
Module.BOTTOM_BAND = BOTTOM_BAND -- exposed so the bag strip can sit above it
local HEADER_H = 16
local GROUP_GAP = 8

-- The dedicated reagent pouch, so its free slots can sit under its own shelf.
local REAGENT_BAG = Enum.BagIndex and Enum.BagIndex.ReagentBag or 5

-- Within a section: higher quality first, then group identical item ids. The
-- keys are captured secret-safe when the bucket is built (see LayoutContainer),
-- so this comparison never touches a tainted value.
local function SortEntry(a, b)
	if a[3] ~= b[3] then
		return a[3] > b[3]
	end
	return a[4] < b[4]
end

-- Whether an item id stacks, cached so a relayout does not re-query the client.
local mergeableCache = {}
local function Mergeable(itemID)
	if itemID == 0 then
		return false
	end
	local cached = mergeableCache[itemID]
	if cached == nil then
		local maxStack = select(8, C_Item.GetItemInfo(itemID))
		-- nil while the item is still loading. Treat as not mergeable for now, the
		-- next relayout re-checks once the data is in.
		cached = (maxStack and maxStack > 1) or false
		if maxStack then
			mergeableCache[itemID] = cached
		end
	end
	return cached
end

-- Fold entries for the same stackable item into one, summing their counts. The
-- kept entry gains a mergeCount so its button shows the combined total. Gear and
-- other unstackable items are left as separate buttons.
local function MergeList(list)
	local out, seen = {}, {}
	for _, entry in ipairs(list) do
		local id = entry[4]
		local mergeKey = (id ~= 0 and Mergeable(id)) and id or nil
		if mergeKey and seen[mergeKey] then
			local rep = seen[mergeKey]
			rep.mergeCount = (rep.mergeCount or rep[5] or 1) + (entry[5] or 1)
		else
			out[#out + 1] = entry
			if mergeKey then
				seen[mergeKey] = entry
			end
		end
	end
	return out
end

-- ---------------------------------------------------------------------------
-- Section headers (pooled per container)
-- ---------------------------------------------------------------------------

local function AcquireHeader(container)
	container.headers = container.headers or {}
	container.headerUsed = (container.headerUsed or 0) + 1
	local header = container.headers[container.headerUsed]
	if not header then
		header = CreateFrame("Button", nil, container)
		header:SetHeight(HEADER_H)
		header.Toggle = header:CreateFontString(nil, "OVERLAY")
		K.SetFont(header.Toggle, 13, K.FontOutlineStyle())
		header.Toggle:SetPoint("LEFT", header, "LEFT", 0, 0)
		header.Toggle:SetTextColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])
		header.Text = header:CreateFontString(nil, "OVERLAY")
		K.SetFont(header.Text, 13, K.FontOutlineStyle())
		header.Text:SetPoint("LEFT", header.Toggle, "RIGHT", 4, 0)
		header.Text:SetTextColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])
		header:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		header:SetScript("OnClick", function(self, button)
			if button == "RightButton" then
				if Module.ShowGroupMenu then
					Module:ShowGroupMenu(self)
				end
			else
				Module:ToggleCategory(self.catKey)
			end
		end)
		container.headers[container.headerUsed] = header
	end
	-- Clear any identity a previous layout left on this pooled header, so a stale
	-- group name can never drive the right-click menu onto the wrong action.
	header.catKey = nil
	header.groupName = nil
	header:Show()
	return header
end

local function ReleaseHeaders(container)
	if container.headers then
		for i = 1, #container.headers do
			container.headers[i]:Hide()
		end
	end
	container.headerUsed = 0
end

-- Fold or unfold a section and remember the choice across sessions.
function Module:ToggleCategory(key)
	if not key then
		return
	end
	local collapsed = C.Bags.Collapsed
	K:SetConfig({ "Bags", "Collapsed", key }, not collapsed[key] or nil)
	self:UpdateAll()
end

-- ---------------------------------------------------------------------------
-- Categorised layout
-- ---------------------------------------------------------------------------

-- Rebuild one container's grid from the current contents of its bags. Empty
-- slots are gathered into a trailing block so items can still be dragged in.
function Module:LayoutContainer(f)
	if not f or not f:IsShown() then
		return
	end
	local cfg = C.Bags
	local size = cfg.ButtonSize
	local space = cfg.Spacing
	local perRow = f.perRow or cfg.BagsPerRow
	local step = size + space
	local rowWidth = perRow * step - space

	self:ReleaseSlots(f)
	ReleaseHeaders(f)

	-- The bag slot strip is its own panel attached below the frame, so it needs no
	-- room reserved inside. Just keep its icons current while it is shown.
	if f.BagStrip and f.BagStrip:IsShown() then
		self:UpdateBagStrip(f)
	end

	-- Sort every occupied slot into buckets, and pool the empties. When the reagent
	-- shelf is its own section, its empties pool apart so the free reagent slots can
	-- show under that shelf instead of vanishing into the general free-slot count.
	-- Reagent empties only get their own trailing button when the reagent shelf is
	-- shown as its own ungrouped section. Folded into a group, they join the pool.
	-- A single-pouch window (detached reagent bag) renders flat, so it opts out of
	-- categories for both the bucketing and the render below.
	local useCategories = cfg.Categories and not f.noCategories
	local splitReagent = useCategories and cfg.ReagentBagSection and not (cfg.CategoryGroup and cfg.CategoryGroup.ReagentBag)
	local buckets, empties, reagentEmpties = {}, {}, {}
	for _, bag in ipairs(f.bags) do
		local numSlots = C_Container.GetContainerNumSlots(bag) or 0
		for slot = 1, numSlots do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info then
				local key = useCategories and self:GetCategory(bag, slot, info) or "All"
				buckets[key] = buckets[key] or {}
				-- Capture secret-safe sort keys now: rarer first, then by item id so
				-- identical items sit together. Secret fields drop to a low value so
				-- they never enter a tainted comparison.
				local quality = info.quality
				local itemID = info.itemID
				local stack = info.stackCount
				tinsert(buckets[key], {
					bag,
					slot,
					(quality and not IsSecret(quality)) and quality or -1,
					(itemID and not IsSecret(itemID)) and itemID or 0,
					(stack and not IsSecret(stack)) and stack or 1,
				})
			elseif splitReagent and bag == REAGENT_BAG then
				tinsert(reagentEmpties, { bag, slot })
			else
				tinsert(empties, { bag, slot })
			end
		end
	end

	local topBand = TOP_BAND + (f.extraTop or 0)
	local y = -topBand

	-- free (optional): a list of empty slots for this group. They collapse to one
	-- trailing button, in the grid flow after the items, showing how many are free.
	-- groupName (optional): set on the header so its menu offers group actions.
	local function placeGroup(list, label, key, free, groupName)
		list = list or {}
		if cfg.MergeStacks then
			list = MergeList(list)
		end
		local freeCount = free and #free or 0
		if #list == 0 and freeCount == 0 then
			return
		end
		local collapsed = key and cfg.Collapsed[key]
		if label then
			local header = AcquireHeader(f)
			header.catKey = key
			header.groupName = groupName
			header:ClearAllPoints()
			header:SetPoint("TOPLEFT", f, "TOPLEFT", MARGIN, y)
			header:SetWidth(rowWidth)
			header.Toggle:SetText(collapsed and "+" or "-")
			header.Text:SetText(label .. "  (" .. #list .. ")")
			header:SetEnabled(key ~= nil)
			y = y - HEADER_H
		end
		if collapsed then
			y = y - GROUP_GAP
			return
		end
		-- Breathing room between a header and the row it labels.
		if label then
			y = y - 4
		end
		for i, entry in ipairs(list) do
			local col = (i - 1) % perRow
			local row = floor((i - 1) / perRow)
			-- Nil while in combat when the pool is exhausted, the regen refresh fills it.
			local button = self:AcquireSlot(f)
			if button then
				local holder = button:GetParent()
				holder:ClearAllPoints()
				holder:SetPoint("TOPLEFT", f, "TOPLEFT", MARGIN + col * step, y - row * step)
				self:UpdateSlot(button, entry[1], entry[2])
				-- Merged stacks show the combined total, not the one slot's count.
				if entry.mergeCount then
					SetItemButtonCount(button, entry.mergeCount)
				end
			end
		end
		local total = #list
		if freeCount > 0 then
			total = total + 1
			local col = #list % perRow
			local row = floor(#list / perRow)
			local button = self:AcquireSlot(f)
			if button then
				local holder = button:GetParent()
				holder:ClearAllPoints()
				holder:SetPoint("TOPLEFT", f, "TOPLEFT", MARGIN + col * step, y - row * step)
				self:UpdateSlot(button, free[1][1], free[1][2])
				SetItemButtonCount(button, freeCount)
			end
		end
		local rows = ceil(total / perRow)
		y = y - rows * step - GROUP_GAP
	end

	-- Order each section so the rarest items lead and duplicates group up, giving
	-- a tidy read that does not depend on which physical slot an item sits in.
	for _, bucket in pairs(buckets) do
		tsort(bucket, SortEntry)
	end

	if useCategories then
		local groupMap = cfg.CategoryGroup or {}
		local groups = cfg.Groups or {}
		local rendered = {}
		local ordered = self.OrderedCategories and self:OrderedCategories() or self.Categories
		for _, cat in ipairs(ordered) do
			local group = groupMap[cat.key]
			if group and groups[group] then
				-- Render each group once, at its first member. Combine every member
				-- category's items into one section under the group name.
				if not rendered[group] then
					rendered[group] = true
					local combined = {}
					for _, member in ipairs(ordered) do
						if groupMap[member.key] == group and buckets[member.key] then
							for _, entry in ipairs(buckets[member.key]) do
								combined[#combined + 1] = entry
							end
						end
					end
					tsort(combined, SortEntry)
					placeGroup(combined, group, "group:" .. group, nil, group)
				end
			else
				placeGroup(buckets[cat.key], cat.name, cat.key, cat.key == "ReagentBag" and reagentEmpties or nil)
			end
		end
	else
		placeGroup(buckets["All"], nil, nil)
	end

	-- Rather than pad the window with dozens of blank squares, the empty slots
	-- collapse to a single button that shows how many are free and still takes a
	-- dropped item (it is bound to the first empty slot).
	if #empties > 0 then
		local first = empties[1]
		local button = self:AcquireSlot(f)
		if button then
			local holder = button:GetParent()
			holder:ClearAllPoints()
			holder:SetPoint("TOPLEFT", f, "TOPLEFT", MARGIN, y)
			self:UpdateSlot(button, first[1], first[2])
			SetItemButtonCount(button, #empties)
			y = y - step - GROUP_GAP
		end
	end

	-- Size the window to the content, with a sane minimum width.
	local contentH = -y - topBand + GROUP_GAP
	f:SetWidth(max(rowWidth, 160) + MARGIN * 2)
	f:SetHeight(topBand + contentH + BOTTOM_BAND)

	self:UpdateInfoText(f)
end

-- ---------------------------------------------------------------------------
-- Toolbar / info readouts
-- ---------------------------------------------------------------------------

-- Refresh the money and free-slot readouts on a container.
function Module:UpdateInfoText(f)
	if f.Money then
		f.Money:SetText(GetCoinTextureString(GetMoney()))
	end
	if f.WarbandMoney and self.UpdateWarbandMoney then
		self:UpdateWarbandMoney(f)
	end
	if f.FreeSlots then
		local free, total = 0, 0
		for _, bag in ipairs(f.bags) do
			free = free + (C_Container.GetContainerNumFreeSlots(bag) or 0)
			total = total + (C_Container.GetContainerNumSlots(bag) or 0)
		end
		f.FreeSlots:SetText(free .. " / " .. total)
	end
	self:UpdateCurrencies(f)
end

-- Lay the tracked backpack currencies along the bottom, centred between the
-- free-slot and money readouts. Icons and counts come from the pinned currency
-- list, so what shows here matches what the player chose to watch.
function Module:UpdateCurrencies(f)
	f.currencyPool = f.currencyPool or {}
	local shown = 0

	if C.Bags.ShowCurrencies and C_CurrencyInfo and C_CurrencyInfo.GetBackpackCurrencyInfo then
		for i = 1, 6 do
			local info = C_CurrencyInfo.GetBackpackCurrencyInfo(i)
			if not info then
				break
			end
			shown = shown + 1
			local element = f.currencyPool[shown]
			if not element then
				element = CreateFrame("Frame", nil, f)
				element:SetSize(16, 16)
				element:EnableMouse(true)
				element.Icon = element:CreateTexture(nil, "ARTWORK")
				element.Icon:SetPoint("LEFT")
				element.Icon:SetSize(14, 14)
				element.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				element.Text = element:CreateFontString(nil, "OVERLAY")
				K.SetFont(element.Text, 12, K.FontOutlineStyle())
				element.Text:SetPoint("LEFT", element.Icon, "RIGHT", 2, 0)
				element:SetScript("OnEnter", function(self)
					if not self.currencyID then
						return
					end
					GameTooltip:SetOwner(self, "ANCHOR_TOP")
					GameTooltip:SetCurrencyByID(self.currencyID)
					GameTooltip:Show()
				end)
				element:SetScript("OnLeave", GameTooltip_Hide)
				f.currencyPool[shown] = element
			end
			element.currencyID = info.currencyTypesID
			element.Icon:SetTexture(info.iconFileID)
			element.Text:SetText(BreakUpLargeNumbers(info.quantity or 0))
			element:SetWidth(16 + 4 + element.Text:GetStringWidth())
			element:Show()
		end
	end

	for i = shown + 1, #f.currencyPool do
		f.currencyPool[i]:Hide()
	end

	-- Lay the currencies left to right on their own line, above the money and
	-- free-slot readouts, so nothing overlaps.
	local x = MARGIN
	for i = 1, shown do
		local element = f.currencyPool[i]
		element:ClearAllPoints()
		element:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", x, 24)
		x = x + element:GetWidth() + 12
	end
end

-- Build the lower-case haystack a search matches against: name, item type and
-- subtype, quality word (epic, rare), and a bind tag (boe, bou). So "epic",
-- "armor", or "boe" all filter as you would expect, not just item names.
local function SearchText(info)
	local parts = info.itemName and info.itemName:lower() or ""
	local link = info.hyperlink
	if link then
		local _, _, quality, _, _, itemType, itemSubType, _, _, _, _, _, _, bindType = C_Item.GetItemInfo(link)
		if itemType then
			parts = parts .. " " .. itemType:lower()
		end
		if itemSubType then
			parts = parts .. " " .. itemSubType:lower()
		end
		if quality then
			local q = _G["ITEM_QUALITY" .. quality .. "_DESC"]
			if q then
				parts = parts .. " " .. q:lower()
			end
		end
		if bindType == 2 then
			parts = parts .. " boe"
		elseif bindType == 3 then
			parts = parts .. " bou"
		end
	end
	return parts
end

-- Dim buttons that do not match the search text. An empty search clears it.
function Module:ApplySearch(f, text)
	text = (text or ""):lower()
	for i = 1, (f.poolUsed or 0) do
		local button = f.pool[i]
		local match = true
		if text ~= "" then
			local info = C_Container.GetContainerItemInfo(button:GetBagID(), button:GetID())
			match = info and SearchText(info):find(text, 1, true) and true or false
		end
		button:SetAlpha(match and 1 or 0.25)
	end
end

-- ---------------------------------------------------------------------------
-- Container window
-- ---------------------------------------------------------------------------

-- Build one bordered window: backdrop, title, close, search, sort, and the
-- money / free-slot bar. The grid is filled by LayoutContainer.
function Module:CreateContainer(name, title, bags, perRow)
	local f = CreateFrame("Frame", name, UIParent)
	f:SetFrameStrata("HIGH")
	f:SetClampedToScreen(true)
	f:EnableMouse(true)
	f.bags = bags
	f.perRow = perRow
	f.slotPrefix = name .. "Item"
	f:SetSize(360, 200)

	K.CreateGradientBackground(f, 0.95)
	K.CreateBorder(f)

	local close = CreateFrame("Button", name .. "Close", f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4)
	close:SetScript("OnClick", function()
		Module:CloseAll()
	end)
	K.SkinCloseButton(close)

	-- A square icon button sized to match the close button, for the top band.
	local function IconButton(suffix, atlas, texture, tip, onClick)
		local button = CreateFrame("Button", name .. suffix, f)
		button:SetSize(22, 22)
		K.SkinButton(button)
		local icon = button:CreateTexture(nil, "ARTWORK")
		-- Fill the button, leaving 1px for the border. An atlas carries its own
		-- coords, so only trim the transparent edge off a plain texture.
		icon:SetPoint("TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", -1, 1)
		if atlas and C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(atlas) then
			icon:SetAtlas(atlas)
		else
			icon:SetTexture(texture)
			icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		end
		button.icon = icon
		button:SetScript("OnClick", onClick)
		button:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(tip, 1, 1, 1)
			GameTooltip:Show()
		end)
		button:SetScript("OnLeave", GameTooltip_Hide or function() GameTooltip:Hide() end)
		return button
	end

	-- Sort, top band, right before the close button. A broom for cleanup.
	local sort = IconButton("Sort", nil, 655994, L["Sort"], function()
		Module:SortContainer(f)
	end)
	sort:SetPoint("RIGHT", close, "LEFT", -6, 0)
	f.Sort = sort

	-- Bag bar toggle, folding the bag slot strip (bags) or the tab bar (bank) in and
	-- out of this window.
	local bagToggle = IconButton("BagToggle", nil, 133633, L["Toggle Bag Bar"], function()
		local strip = f.BagStrip or f.BankBar
		if strip then
			K:SetConfig({ "Bags", "ShowBagBar" }, not strip:IsShown())
			Module:ToggleBagStrip(f, C.Bags.ShowBagBar)
		end
	end)
	bagToggle:SetPoint("RIGHT", sort, "LEFT", -6, 0)
	f.BagToggle = bagToggle

	-- Category group manager and delete-cheapest, main bag window only.
	if name == "KKUI_BagFrame" then
		local manager = IconButton("Manager", nil, "Interface\\ICONS\\INV_Misc_Book_09", L["Category Groups"], function()
			if Module.ToggleManager then
				Module:ToggleManager()
			end
		end)
		manager:SetPoint("RIGHT", bagToggle, "LEFT", -6, 0)
		f.ManagerButton = manager

		if C.Bags.DeleteButton then
			local delete = IconButton("Delete", nil, "Interface\\ICONS\\INV_Misc_Head_Goblin_01", L["Delete Cheapest Junk"], function()
				if Module.DeleteCheapestJunk then
					Module:DeleteCheapestJunk()
				end
			end)
			delete:SetPoint("RIGHT", manager, "LEFT", -6, 0)
			f.DeleteButton = delete
		end
	end

	-- Search box, top band, pinned to the top-left where the title used to sit.
	local search = CreateFrame("EditBox", name .. "Search", f)
	search:SetSize(140, 20)
	search:SetPoint("TOPLEFT", f, "TOPLEFT", MARGIN, -10)
	search:SetAutoFocus(false)
	K.SetFont(search, 12, "")
	search:SetTextInsets(4, 4, 0, 0)
	search:SetScript("OnEscapePressed", search.ClearFocus)
	search:SetScript("OnEnterPressed", search.ClearFocus)
	search:SetScript("OnTextChanged", function(self)
		Module:ApplySearch(f, self:GetText())
		if self.Placeholder then
			self.Placeholder:SetShown(self:GetText() == "")
		end
	end)
	K.SkinEditBox(search)
	-- Faint prompt shown while the box is empty.
	local placeholder = search:CreateFontString(nil, "ARTWORK")
	K.SetFont(placeholder, 12, "")
	placeholder:SetPoint("LEFT", search, "LEFT", 4, 0)
	placeholder:SetTextColor(0.5, 0.5, 0.5)
	placeholder:SetText(L["Search"])
	search.Placeholder = placeholder
	f.Search = search

	-- Sell-junk button, shown only while a merchant is open, right of the search
	-- box. Its label carries the running junk value so you know what you get.
	local sell = CreateFrame("Button", name .. "Sell", f)
	sell:SetSize(110, 20)
	sell:SetPoint("LEFT", search, "RIGHT", 8, 0)
	sell.Text = sell:CreateFontString(nil, "OVERLAY")
	K.SetFont(sell.Text, 12, K.FontOutlineStyle())
	sell.Text:SetPoint("CENTER")
	sell:SetScript("OnClick", function()
		Module:SellJunk()
		Module:UpdateSellButton(f)
	end)
	K.SkinButton(sell)
	sell:Hide()
	f.SellButton = sell

	-- Bottom bar: free slots on the left, money on the right.
	local freeSlots = f:CreateFontString(nil, "OVERLAY")
	K.SetFont(freeSlots, 12, K.FontOutlineStyle())
	freeSlots:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", MARGIN, 6)
	freeSlots:SetTextColor(K.Colors.silver[1], K.Colors.silver[2], K.Colors.silver[3])
	f.FreeSlots = freeSlots

	local money = f:CreateFontString(nil, "OVERLAY")
	K.SetFont(money, 12, K.FontOutlineStyle())
	money:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 6)
	f.Money = money

	-- Thin rule between the item grid and the info bar.
	local divider = f:CreateTexture(nil, "ARTWORK")
	divider:SetColorTexture(K.Colors.borderSubtle[1], K.Colors.borderSubtle[2], K.Colors.borderSubtle[3], 0.8)
	divider:SetHeight(1)
	divider:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", MARGIN, BOTTOM_BAND)
	divider:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -MARGIN, BOTTOM_BAND)
	f.Divider = divider

	f:Hide()
	return f
end

-- Sort a container's bags, honouring the reverse-fill preference.
function Module:SortContainer(f)
	if InCombatLockdown() then
		return
	end
	local reverse = C.Bags.ReverseSort
	if C_Container.SetSortBagsRightToLeft then
		C_Container.SetSortBagsRightToLeft(reverse)
	end
	if C_Container.SetInsertItemsLeftToRight then
		C_Container.SetInsertItemsLeftToRight(not reverse)
	end
	if f.isBank and C_Container.SortBankBags then
		C_Container.SortBankBags()
	elseif C_Container.SortBags then
		C_Container.SortBags()
	end
end

-- ---------------------------------------------------------------------------
-- Refresh pipeline
-- ---------------------------------------------------------------------------

-- Mark the open windows for a relayout, coalescing a burst of events into one
-- pass on the next frame. Deferred out of combat.
function Module:MarkDirty()
	if self.dirty then
		return
	end
	self.dirty = true
	C_Timer.After(0, function()
		self.dirty = false
		if InCombatLockdown() then
			self.combatPending = true
			return
		end
		self:UpdateAll()
	end)
end

-- Top up both windows' button pools while out of combat so nothing has to be
-- created mid-fight, where it would be tainted and lose item use.
function Module:PrewarmAll()
	if not self.PrewarmSlots then
		return
	end
	if self.BagFrame then
		self:PrewarmSlots(self.BagFrame)
	end
	if self.ReagentFrame then
		self:PrewarmSlots(self.ReagentFrame)
	end
	if self.BankFrame then
		self:PrewarmSlots(self.BankFrame)
	end
end

function Module:UpdateAll()
	self:PrewarmAll()
	if self.BagFrame and self.BagFrame:IsShown() then
		self:LayoutContainer(self.BagFrame)
	end
	if self.ReagentFrame and self.ReagentFrame:IsShown() then
		self:LayoutContainer(self.ReagentFrame)
	end
	if self.BankFrame and self.BankFrame:IsShown() then
		self:LayoutContainer(self.BankFrame)
	end
	self:UpdateSellButton(self.BagFrame)
end

-- ---------------------------------------------------------------------------
-- Merchant helpers
-- ---------------------------------------------------------------------------

-- Is this an item we should vendor: grey, or one the player flagged as junk.
local function IsSellable(info)
	if not info or not info.hyperlink or info.hasNoValue then
		return false
	end
	local poor = Enum.ItemQuality and Enum.ItemQuality.Poor or 0
	if not IsSecret(info.quality) and info.quality == poor then
		return true
	end
	return info.itemID and not IsSecret(info.itemID) and C.Bags.JunkList and C.Bags.JunkList[info.itemID] and true or false
end

function Module:SellJunk()
	-- Grey items go through Blizzard's own bulk sell, then any player-flagged items
	-- are sold one by one, both only while a merchant is open.
	if C_MerchantFrame and C_MerchantFrame.SellAllJunkItems then
		C_MerchantFrame.SellAllJunkItems()
	end
	if not (_G.MerchantFrame and _G.MerchantFrame:IsShown()) or InCombatLockdown() then
		return
	end
	for _, bag in ipairs(self.BagIDs) do
		local numSlots = C_Container.GetContainerNumSlots(bag) or 0
		for slot = 1, numSlots do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			local flagged = info and info.itemID and not IsSecret(info.itemID) and C.Bags.JunkList and C.Bags.JunkList[info.itemID]
			if flagged and not info.hasNoValue then
				C_Container.UseContainerItem(bag, slot)
			end
		end
	end
end

-- Total vendor value of the sellable items sitting in the bags.
function Module:GetJunkValue()
	local total = 0
	for _, bag in ipairs(self.BagIDs) do
		local numSlots = C_Container.GetContainerNumSlots(bag) or 0
		for slot = 1, numSlots do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if IsSellable(info) then
				local price = select(11, C_Item.GetItemInfo(info.hyperlink))
				if price and price > 0 then
					total = total + price * (info.stackCount or 1)
				end
			end
		end
	end
	return total
end

-- Show the sell button with its value while a merchant is open and there is
-- something to sell, otherwise keep it hidden.
function Module:UpdateSellButton(f)
	if not f or not f.SellButton then
		return
	end
	local open = _G.MerchantFrame and _G.MerchantFrame:IsShown()
	local value = open and self:GetJunkValue() or 0
	if not open or value <= 0 then
		f.SellButton:Hide()
		return
	end
	f.SellButton.Text:SetText(L["Sell Junk"] .. "  " .. GetCoinTextureString(value))
	f.SellButton:SetWidth(f.SellButton.Text:GetStringWidth() + 16)
	f.SellButton:Show()
end

-- ---------------------------------------------------------------------------
-- Open / close, and the hooks that replace Blizzard's bags
-- ---------------------------------------------------------------------------

function Module:OpenBags()
	if not self.BagFrame then
		return
	end
	self.BagFrame:Show()
	self:LayoutContainer(self.BagFrame)
	if self.ReagentFrame then
		self.ReagentFrame:Show()
		self:LayoutContainer(self.ReagentFrame)
	end
end

function Module:CloseBags()
	if self.BagFrame then
		self.BagFrame:Hide()
	end
	if self.ReagentFrame then
		self.ReagentFrame:Hide()
	end
end

function Module:ToggleBags()
	if self.BagFrame and self.BagFrame:IsShown() then
		self:CloseBags()
	else
		self:OpenBags()
	end
end

function Module:CloseAll()
	self:CloseBags()
	if self.CloseBank then
		self:CloseBank()
	end
end

-- Route Blizzard's global bag entry points to our window. Nothing calls the
-- stock ContainerFrame show path once these are replaced, so it stays hidden.
function Module:HookBlizzard()
	local function open()
		self:OpenBags()
	end
	local function close()
		self:CloseBags()
	end
	local function toggle()
		self:ToggleBags()
	end

	_G.OpenAllBags = open
	_G.OpenBackpack = open
	_G.CloseAllBags = close
	_G.CloseBackpack = close
	_G.ToggleAllBags = toggle
	_G.ToggleBackpack = toggle
	_G.ToggleBag = toggle
	_G.OpenBag = open
	_G.CloseBag = close
end

function Module:OnEnable()
	if not C.Bags.Enable then
		return
	end

	-- The reagent pouch can live in its own window. When detached, the main bag
	-- window drops the reagent bag and a small reagent window takes it, flat and
	-- uncategorised since it is a single pouch. Retail only, where a reagent bag
	-- exists at all.
	local detach = C.Bags.DetachReagentBag and K.Client and K.Client.IsRetail
	local mainBags = detach and { 0, 1, 2, 3, 4 } or self.BagIDs

	self.BagFrame = self:CreateContainer("KKUI_BagFrame", L["Inventory"], mainBags, C.Bags.BagsPerRow)
	K.CreateMover(self.BagFrame, "Bags", L["Inventory"], { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -60, 60 }, self.BagFrame:GetWidth(), self.BagFrame:GetHeight())
	K.EnableFrameDrag(self.BagFrame)

	if detach then
		local reagent = self:CreateContainer("KKUI_ReagentFrame", L["Reagent Bag"], { REAGENT_BAG }, C.Bags.BagsPerRow)
		reagent.noCategories = true
		self.ReagentFrame = reagent
		K.CreateMover(reagent, "ReagentBags", L["Reagent Bag"], { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -60, 320 }, reagent:GetWidth(), reagent:GetHeight())
		K.EnableFrameDrag(reagent)
	end

	-- The bag slot strip lives on the bag window and starts at its saved state.
	if self.CreateBagStrip then
		self:CreateBagStrip(self.BagFrame)
		self.BagFrame.BagStrip:SetShown(C.Bags.ShowBagBar)
	end

	-- Gold tracking: record this character now and hang the account total tooltip
	-- off the money text.
	if self.CaptureGold then
		self:CaptureGold()
		self:AttachGoldTooltip(self.BagFrame)
	end

	if self.SetupBank then
		self:SetupBank()
	end

	self:HookBlizzard()

	-- Keep the grid current as items move, and auto-sell junk at a merchant.
	self:RegisterEvent("BAG_UPDATE_DELAYED", "MarkDirty")
	self:RegisterEvent("BAG_UPDATE_COOLDOWN", "MarkDirty")
	self:RegisterEvent("ITEM_LOCK_CHANGED", "MarkDirty")
	self:RegisterEvent("QUEST_ACCEPTED", "MarkDirty")
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED", "MarkDirty")
	self:RegisterEvent("PLAYER_MONEY", function()
		if self.CaptureGold then
			self:CaptureGold()
		end
		self:UpdateAll()
	end)
	-- Auto-sell on merchant open lives in Automation now (SellJunk.lua) so it works
	-- with the bags disabled. This only updates the manual Sell Junk button.
	self:RegisterEvent("MERCHANT_SHOW", function()
		self:UpdateSellButton(self.BagFrame)
	end)
	self:RegisterEvent("MERCHANT_CLOSED", function()
		self:UpdateSellButton(self.BagFrame)
	end)
	-- Combat is over, so top the pools back up and reapply anything that was held
	-- off or skipped while locked down.
	self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
		self:PrewarmAll()
		if self.combatPending then
			self.combatPending = false
		end
		self:UpdateAll()
	end)

	-- Build the pools up front while safely out of combat.
	self:PrewarmAll()
end
