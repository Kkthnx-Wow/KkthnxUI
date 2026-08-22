--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/Strip.lua
	Purpose:
		A row of the character's equipped bag slots that lives on the bag window and
		folds out from the toolbar toggle. Each slot shows the bag icon, its free
		count, and a quality border, and takes a bag dropped onto it to swap it in.
		Swapping goes through the cursor and is blocked in combat, so it stays clean
		of the secure action path.
-----------------------------------------------------------------------------]]

local K, _, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Bags")
if not Module then
	return
end

local ipairs = ipairs
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local CursorHasItem = CursorHasItem
local PickupInventoryItem = PickupInventoryItem
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemQuality = GetInventoryItemQuality
local GetInventoryItemLink = GetInventoryItemLink
local C_Container = C_Container

-- The border draws a few px outside each button, so the gap has to clear it or
-- the slots read as one stuck-together block.
local SLOT = 24
local GAP = 8
local PAD = 6
-- The default pack icon, used for the backpack and any empty slot.
local DEFAULT_ICON = "Interface\\Buttons\\Button-Backpack-Up"

-- Height the strip adds above the item grid when it is shown.
Module.BagStripHeight = SLOT + PAD * 2

-- Backpack, then the four carried bags, and the reagent pouch on retail only.
local function StripBags()
	local bags = { 0, 1, 2, 3, 4 }
	if K.Client and K.Client.IsRetail then
		bags[#bags + 1] = 5
	end
	return bags
end

local function SwapBag(self)
	if InCombatLockdown() or not CursorHasItem() then
		return
	end
	local bag = self.bagID
	-- The backpack itself cannot be replaced.
	if not bag or bag == 0 then
		return
	end
	local inv = C_Container.ContainerIDToInventoryID(bag)
	if inv then
		PickupInventoryItem(inv)
	end
end

local function OnEnter(self)
	self.KKUI_Border:SetVertexColor(1, 1, 1, 1)
	local bag = self.bagID
	local name = L["Backpack"]
	if bag ~= 0 then
		local inv = C_Container.ContainerIDToInventoryID(bag)
		local link = inv and GetInventoryItemLink("player", inv)
		name = (link and C_Item and C_Item.GetItemInfo and C_Item.GetItemInfo(link)) or (L["Bag"] .. " " .. bag)
	end
	local total = C_Container.GetContainerNumSlots(bag) or 0
	local free = C_Container.GetContainerNumFreeSlots(bag) or 0
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText(name, 1, 1, 1)
	if total > 0 then
		GameTooltip:AddLine((total - free) .. " / " .. total, 0.8, 0.8, 0.8)
	end
	GameTooltip:Show()
end

local function OnLeave(self)
	if self.__q then
		self.KKUI_Border:SetVertexColor(self.__q.r, self.__q.g, self.__q.b, 1)
	else
		K.ResetBorderColor(self.KKUI_Border)
	end
	GameTooltip:Hide()
end

-- Build the strip and its slot buttons once per container.
function Module:CreateBagStrip(f)
	if f.BagStrip then
		return f.BagStrip
	end
	local strip = CreateFrame("Frame", nil, f)
	strip:SetHeight(Module.BagStripHeight)
	strip:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -34)
	strip:SetPoint("TOPRIGHT", f, "TOPRIGHT", -12, -34)
	strip:Hide()

	strip.buttons = {}
	local x = 0
	for _, bag in ipairs(StripBags()) do
		local button = CreateFrame("Button", nil, strip)
		button:SetSize(SLOT, SLOT)
		button:SetPoint("LEFT", strip, "LEFT", x, 0)
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		button.bagID = bag
		K.CreateGradientBackground(button, 0.9)
		K.CreateBorder(button)

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetPoint("TOPLEFT", 2, -2)
		icon:SetPoint("BOTTOMRIGHT", -2, 2)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.Icon = icon

		local count = button:CreateFontString(nil, "OVERLAY")
		K.SetFont(count, 11, K.FontOutlineStyle())
		count:SetPoint("BOTTOMRIGHT", -2, 2)
		button.Count = count

		button:SetScript("OnEnter", OnEnter)
		button:SetScript("OnLeave", OnLeave)
		button:SetScript("OnReceiveDrag", SwapBag)
		button:HookScript("OnClick", SwapBag)

		strip.buttons[#strip.buttons + 1] = button
		x = x + SLOT + GAP
	end

	f.BagStrip = strip
	return strip
end

-- Refresh every slot's icon, free count, and quality border.
function Module:UpdateBagStrip(f)
	local strip = f.BagStrip
	if not strip or not strip:IsShown() then
		return
	end
	for _, button in ipairs(strip.buttons) do
		local bag = button.bagID
		local total = C_Container.GetContainerNumSlots(bag) or 0
		local free = C_Container.GetContainerNumFreeSlots(bag) or 0

		if bag == 0 then
			button.Icon:SetTexture(DEFAULT_ICON)
			button.__q = nil
			K.ResetBorderColor(button.KKUI_Border)
		else
			local inv = C_Container.ContainerIDToInventoryID(bag)
			local tex = inv and GetInventoryItemTexture("player", inv)
			button.Icon:SetTexture(tex or DEFAULT_ICON)
			local quality = inv and GetInventoryItemQuality("player", inv)
			local color = quality and quality > 1 and C_Item and C_Item.GetItemQualityColor and { C_Item.GetItemQualityColor(quality) }
			if color and color[1] then
				button.__q = { r = color[1], g = color[2], b = color[3] }
				button.KKUI_Border:SetVertexColor(color[1], color[2], color[3], 1)
			else
				button.__q = nil
				K.ResetBorderColor(button.KKUI_Border)
			end
		end

		button.Count:SetText(total > 0 and free or "")
	end
end

-- Fold the strip in or out and relayout so the grid makes room for it.
function Module:ToggleBagStrip(f, show)
	if not f or not f.BagStrip then
		return
	end
	f.BagStrip:SetShown(show)
	if show then
		self:UpdateBagStrip(f)
	end
	self:LayoutContainer(f)
end
