--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Slots.lua
	Purpose:
		The item buttons. They are built from Blizzard's container item button
		template so click, drag, use, split, and the tooltip keep working with
		no reimplementation, then reskinned to our border and squared icon. Each
		button carries its own bag id, so a category can mix items from every bag
		in one grid. Buttons live in a pool and are reused across relayouts.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- Match Core.lua: load wherever C_Container is present, not only on retail.
if not (C_Container and C_Container.GetContainerNumSlots) then
	return
end

local Module = K:GetModule("Bags")

local _G = _G
local select = select
local ipairs = ipairs
local IsAltKeyDown = IsAltKeyDown
local InCombatLockdown = InCombatLockdown
local CreateFrame = CreateFrame
local IsSecret = K.IsSecret
local ItemLocation = ItemLocation
local C_Container = C_Container
local C_Item = C_Item
local SetItemButtonTexture = SetItemButtonTexture
local SetItemButtonCount = SetItemButtonCount
local SetItemButtonDesaturated = SetItemButtonDesaturated
local CooldownFrame_Set = CooldownFrame_Set

local Enum = Enum
local C_NewItems = C_NewItems
local POOR = Enum.ItemQuality and Enum.ItemQuality.Poor or 0

-- Quest border colour (classic quest yellow). The bang itself is our own "!"
-- fontstring so it lines up on our button size.
local QUEST_COLOR = { 1, 0.82, 0 }

-- Border colour for an item quality, falling back to our own border colour for
-- common or unknown items so the grid never shows a black edge.
local function QualityColor(quality)
	-- Enum.ItemQuality.Common is 1 but the enum key is absent on some flavours (TBC
	-- Anniversary), so fall back to the literal to avoid comparing against nil.
	local common = Enum.ItemQuality and Enum.ItemQuality.Common or 1
	if quality and not IsSecret(quality) and quality > common then
		local r, g, b = C_Item.GetItemQualityColor(quality)
		if r then
			return r, g, b, true
		end
	end
	local c = C.General.BorderColor
	return c[1], c[2], c[3], false
end

-- Colour a button border. A quality tint marks itself custom so the GUI colour
-- refresh leaves it alone, while common items track the configured border.
local function SetBorder(button, r, g, b, custom)
	local border = button.KKUI_Border
	if not border then
		return
	end
	border.__customColor = custom or nil
	border:SetVertexColor(r, g, b, 1)
end

-- One-time skin: strip Blizzard's slot art and give the button our look. The
-- template's own regions (Count, Cooldown, JunkIcon, quest, glow) are kept and
-- reused, only repositioned to sit inside our border.
local function Skin(button)
	if button.__kkuiSkinned then
		return
	end
	button.__kkuiSkinned = true

	local nt = button.GetNormalTexture and button:GetNormalTexture()
	if nt then
		nt:SetAlpha(0)
	end
	if button.SetNormalTexture then
		button:SetNormalTexture(0)
	end
	if button.IconBorder then
		button.IconBorder:SetAlpha(0)
	end
	if button.SlotArt then
		button.SlotArt:SetAlpha(0)
	end
	if button.SlotBackground then
		button.SlotBackground:SetAlpha(0)
	end
	if button.BattlepayItemTexture then
		button.BattlepayItemTexture:SetAlpha(0)
	end

	local icon = button.icon or _G[button:GetName() .. "IconTexture"]
	if icon then
		button.KKUI_Icon = icon
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:ClearAllPoints()
		icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	end

	K.CreateBackground(button, 0.06, 0.06, 0.06, 0.9)
	K.CreateBorder(button)

	if button.Count then
		button.Count:ClearAllPoints()
		button.Count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	end

	if button.Cooldown then
		button.Cooldown:ClearAllPoints()
		button.Cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		button.Cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		K.StyleCooldownSwipe(button.Cooldown)
	end

	-- Item level, top-left, for equippable gear.
	local ilvl = button:CreateFontString(nil, "OVERLAY")
	K.SetFont(ilvl, 12, K.FontOutlineStyle())
	ilvl:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	button.KKUI_ItemLevel = ilvl

	-- Bind status, bottom-left, so it clears the stack count on the right.
	local bind = button:CreateFontString(nil, "OVERLAY")
	K.SetFont(bind, 11, K.FontOutlineStyle())
	bind:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 2, 2)
	bind:SetTextColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])
	button.KKUI_Bind = bind

	-- Upgrade track progress (cur/max) for gear, bottom-right where the stack
	-- count would sit. Gear never stacks, so the corner is free.
	local upgrade = button:CreateFontString(nil, "OVERLAY")
	K.SetFont(upgrade, 11, K.FontOutlineStyle())
	upgrade:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
	button.KKUI_Upgrade = upgrade

	-- Our own quest bang, a crisp "!" we place ourselves. Blizzard's quest-bang
	-- texture carries padding sized for the default bag button, so it never lines
	-- up on ours. Top-left is free on quest items (they carry no item level).
	local questBang = button:CreateTexture(nil, "OVERLAY", nil, 2)
	questBang:SetAtlas("QuestNormal")
	questBang:SetSize(22, 22)
	questBang:SetPoint("LEFT", button, "LEFT", -4, 0)
	questBang:Hide()
	button.KKUI_QuestBang = questBang

	-- Pawn upgrade arrow, left edge, shown when Pawn flags the item as an upgrade.
	-- Uses Blizzard's own upgrade-arrow atlas so it needs nothing from Pawn but the
	-- verdict. Left-centre keeps it clear of the four corner overlays.
	local pawn = button:CreateTexture(nil, "OVERLAY", nil, 2)
	pawn:SetAtlas("bags-greenarrow")
	pawn:SetSize(20, 20)
	pawn:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", -2, -2)
	pawn:Hide()
	button.KKUI_Pawn = pawn

	-- Favourite star, top-right, hidden until the item is pinned.
	local star = button:CreateTexture(nil, "OVERLAY", nil, 2)
	star:SetAtlas("auctionhouse-icon-favorite")
	star:SetSize(12, 12)
	star:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1, 1)
	star:Hide()
	button.KKUI_Fav = star

	-- Alt-click pins or unpins the item. This hooks alongside the template's own
	-- click handler rather than replacing it, so use, pickup, and split keep
	-- working through Blizzard's secure path. Alt-click has no default bag action,
	-- so nothing needs suppressing.
	if not button.__kkuiFavHook then
		button.__kkuiFavHook = true
		button:HookScript("OnClick", function(self)
			if IsAltKeyDown() then
				Module:ToggleFavorite(self)
			end
		end)
		-- Middle-click opens the assign menu. Hooked, never a script write on the
		-- secure button, so the item use path stays clean.
		button:HookScript("OnMouseUp", function(self, mouseButton)
			if mouseButton == "MiddleButton" and Module.ShowAssignMenu then
				Module:ShowAssignMenu(self)
			end
		end)
	end
end

-- Pawn's own verdict on whether an item is an upgrade. Blizzard has no equivalent
-- API, so this only lights up when Pawn is installed. Pawn can answer nil while it
-- is still loading the item's data, so we retry once shortly after until it
-- returns a real yes or no.
function Module:UpdatePawn(button, link)
	local arrow = button.KKUI_Pawn
	if not arrow then
		return
	end
	link = link or button.__pawnLink
	button.__pawnLink = link

	if not C.Bags.PawnArrows or not link or not _G.PawnShouldItemLinkHaveUpgradeArrowUnbudgeted then
		arrow:Hide()
		return
	end

	local isUpgrade = _G.PawnShouldItemLinkHaveUpgradeArrowUnbudgeted(link, true)
	if isUpgrade == nil then
		-- Data not ready yet, so ask again in a moment (guarded so a burst of
		-- relayouts does not stack timers on the same button).
		if not button.__pawnPending then
			button.__pawnPending = true
			C_Timer.After(0.5, function()
				button.__pawnPending = nil
				Module:UpdatePawn(button)
			end)
		end
	else
		arrow:SetShown(isUpgrade)
	end
end

-- Pin or unpin the item in a slot, then relayout so it jumps to (or leaves) the
-- Favourites section.
function Module:ToggleFavorite(button)
	local info = C_Container.GetContainerItemInfo(button:GetBagID(), button:GetID())
	local itemID = info and info.itemID
	if not itemID or IsSecret(itemID) then
		return
	end
	K:SetConfig({ "Bags", "Favorites", itemID }, not C.Bags.Favorites[itemID] or nil)
	self:UpdateAll()
end

-- Pull the next free button from a container's own pool, creating one the first
-- time it is needed. Each container keeps its own pool so the bag and bank grids
-- do not fight over the same buttons while both are open. Buttons keep a stable
-- name so their template sub-frames resolve.
-- Each item button lives inside its own plain holder frame. The holder carries the
-- bag id through SetID, so the secure template reads the bag as GetParent():GetID()
-- and we never write a field on the button itself. Writing the bag onto the button
-- taints the secure click and the client then forbids the protected UseContainerItem.
local function BuildSlot(container, index)
	local holder = CreateFrame("Frame", nil, container)
	local button = CreateFrame("ItemButton", container.slotPrefix .. index, holder, "ContainerFrameItemButtonTemplate")
	button:SetAllPoints(holder)
	Skin(button)
	container.pool[index] = button
	return button
end

function Module:AcquireSlot(container)
	container.pool = container.pool or {}
	container.poolUsed = (container.poolUsed or 0) + 1
	local index = container.poolUsed
	local button = container.pool[index]
	if not button then
		-- A secure item button created in combat is tainted for good, and the client
		-- then forbids the protected UseContainerItem on it, so right-click use dies
		-- in delves and M+. Never build one in combat. The pool is pre-warmed out of
		-- combat, and the combat-end refresh fills anything that was skipped.
		if InCombatLockdown() then
			container.poolUsed = container.poolUsed - 1
			return nil
		end
		button = BuildSlot(container, index)
	end
	local holder = button:GetParent()
	holder:Show()
	button:Show()
	return button
end

-- Build every item button a container could need while out of combat, so opening
-- the bags mid-fight only reuses clean buttons and never has to create a tainted
-- one. Tops the pool up to the container's current total slot count.
function Module:PrewarmSlots(container)
	if InCombatLockdown() or not container or not container.bags then
		return
	end
	local total = 0
	for _, bag in ipairs(container.bags) do
		total = total + (C_Container.GetContainerNumSlots(bag) or 0)
	end
	container.pool = container.pool or {}
	for index = #container.pool + 1, total do
		BuildSlot(container, index):GetParent():Hide()
	end
end

-- Hide every pooled slot on a container and reset its cursor for the next layout.
function Module:ReleaseSlots(container)
	if container.pool then
		for i = 1, #container.pool do
			container.pool[i]:GetParent():Hide()
		end
	end
	container.poolUsed = 0
end

-- Bind a button to a bag slot and refresh all of its visuals from the client.
function Module:UpdateSlot(button, bag, slot)
	-- The bag rides on the holder frame (GetParent), never on the button. Writing a
	-- bag field or the secure bagid attribute onto the button taints the click, and
	-- the client then forbids the protected UseContainerItem, killing right-click
	-- use. The template reads the bag through GetParent():GetID(), so the holder id
	-- is all that is needed and none of it touches the secure button.
	local holder = button:GetParent()
	holder:SetID(bag)
	button:SetID(slot)

	local info = C_Container.GetContainerItemInfo(bag, slot)
	local size = C.Bags.ButtonSize
	holder:SetSize(size, size)

	if not info then
		-- Empty slot: clear everything, keep it as a drop target.
		SetItemButtonTexture(button, nil)
		SetItemButtonCount(button, 0)
		SetItemButtonDesaturated(button, false)
		if button.KKUI_ItemLevel then
			button.KKUI_ItemLevel:SetText("")
		end
		if button.KKUI_Bind then
			button.KKUI_Bind:SetText("")
		end
		if button.KKUI_Upgrade then
			button.KKUI_Upgrade:SetText("")
		end
		if button.KKUI_Pawn then
			button.__pawnLink = nil
			button.KKUI_Pawn:Hide()
		end
		if button.JunkIcon then
			button.JunkIcon:Hide()
		end
		if button.IconQuestTexture then
			button.IconQuestTexture:Hide()
		end
		if button.KKUI_QuestBang then
			button.KKUI_QuestBang:Hide()
		end
		if button.NewItemTexture then
			button.NewItemTexture:Hide()
		end
		if button.KKUI_Fav then
			button.KKUI_Fav:Hide()
		end
		local c = C.General.BorderColor
		SetBorder(button, c[1], c[2], c[3], false)
		if button.Cooldown then
			CooldownFrame_Set(button.Cooldown, 0, 0, 0)
		end
		return
	end

	SetItemButtonTexture(button, info.iconFileID)
	SetItemButtonCount(button, info.stackCount)

	local quality = info.quality
	-- Grey out the icon while locked, and optionally for junk so the vendor trash
	-- fades back and the good items lead the eye. Player-flagged items count too.
	local flaggedJunk = info.itemID and not IsSecret(info.itemID) and C.Bags.JunkList and C.Bags.JunkList[info.itemID]
	local isJunk = (not IsSecret(quality) and quality == POOR or flaggedJunk) and not info.hasNoValue
	SetItemButtonDesaturated(button, info.isLocked or (C.Bags.DesaturateJunk and isJunk) or false)

	SetBorder(button, QualityColor(quality))

	-- Favourite star.
	if button.KKUI_Fav then
		button.KKUI_Fav:SetShown(info.itemID and not IsSecret(info.itemID) and C.Bags.Favorites[info.itemID] and true or false)
	end

	-- Junk coin on grey items.
	if button.JunkIcon then
		button.JunkIcon:SetShown(C.Bags.JunkIcon and isJunk or false)
	end

	-- Quest items: a quest-coloured border, plus our own ! bang on items that
	-- start a quest (a quest id that is not yet an active objective).
	local quest = C_Container.GetContainerItemQuestInfo(bag, slot)
	local isStarter = quest and quest.questID and not quest.isActive
	if button.IconQuestTexture then
		button.IconQuestTexture:Hide() -- Blizzard's misaligned bang, ours replaces it
	end
	if button.KKUI_QuestBang then
		button.KKUI_QuestBang:SetShown(C.Bags.QuestColor and isStarter and true or false)
	end
	if C.Bags.QuestColor and quest and (quest.isQuestItem or quest.questID) then
		SetBorder(button, QUEST_COLOR[1], QUEST_COLOR[2], QUEST_COLOR[3], true)
	end

	-- New-item glow, but never on junk.
	if button.NewItemTexture then
		local isNew = C.Bags.ShowNewItems and C_NewItems and C_NewItems.IsNewItem and C_NewItems.IsNewItem(bag, slot)
		button.NewItemTexture:SetShown(isNew and quality ~= POOR)
	end

	-- Cooldown swipe.
	if button.Cooldown then
		local start, duration, enable = C_Container.GetContainerItemCooldown(bag, slot)
		if not (IsSecret(start) or IsSecret(duration)) then
			CooldownFrame_Set(button.Cooldown, start, duration, enable)
		end
	end

	-- Item level for gear.
	if button.KKUI_ItemLevel then
		local text = ""
		if C.Bags.ShowItemLevel and info.itemID and not IsSecret(info.itemID) then
			-- Only true gear carries a meaningful item level. Gate on the Weapon and
			-- Armor item classes (the approach the item level display addons use) so
			-- consumables, reagents, quest items, and containers stay clean. Cosmetic
			-- shirts and tabards are Armor but have no level worth showing.
			local _, _, _, equipLoc, _, classID = C_Item.GetItemInfoInstant(info.itemID)
			local weaponClass = Enum.ItemClass and Enum.ItemClass.Weapon or 2
			local armorClass = Enum.ItemClass and Enum.ItemClass.Armor or 4
			local isGear = (classID == weaponClass or classID == armorClass) and equipLoc ~= "INVTYPE_BODY" and equipLoc ~= "INVTYPE_TABARD"
			if isGear then
				local loc = ItemLocation:CreateFromBagAndSlot(bag, slot)
				if C_Item.DoesItemExist(loc) then
					local level = C_Item.GetCurrentItemLevel(loc)
					if level and level > 1 then
						local r, g, b = QualityColor(quality)
						text = level
						button.KKUI_ItemLevel:SetTextColor(r, g, b)
					end
				end
			end
		end
		button.KKUI_ItemLevel:SetText(text)
	end

	-- Upgrade track (cur/max), green once the piece is fully upgraded so finished
	-- gear stands out from pieces that still have crests to spend.
	if button.KKUI_Upgrade then
		local text = ""
		if C.Bags.ShowUpgradeTrack and info.hyperlink and C_Item.GetItemUpgradeInfo then
			local up = C_Item.GetItemUpgradeInfo(info.hyperlink)
			local cur, maxLevel = up and up.currentLevel, up and up.maxLevel
			if cur and maxLevel and not IsSecret(cur) and not IsSecret(maxLevel) and maxLevel > 0 then
				text = cur .. "/" .. maxLevel
				if cur >= maxLevel then
					button.KKUI_Upgrade:SetTextColor(0.1, 1, 0.1)
				else
					button.KKUI_Upgrade:SetTextColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])
				end
			end
		end
		button.KKUI_Upgrade:SetText(text)
	end

	-- Pawn upgrade arrow (only when Pawn is installed).
	self:UpdatePawn(button, info.hyperlink)

	-- Bind-on-equip / bind-to-account marker on gear that has not bound yet.
	if button.KKUI_Bind then
		local text = ""
		if C.Bags.ShowItemBind and info.hyperlink and not info.isBound and not IsSecret(info.itemID) then
			local bindType = select(14, C_Item.GetItemInfo(info.hyperlink))
			if bindType == 2 then
				text = "BoE"
			elseif bindType == 3 then
				text = "BoU"
			end
		end
		button.KKUI_Bind:SetText(text)
	end
end
