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

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

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

local SLOT = 28
local PAD = 6
-- The default pack icon, used for the backpack and any empty slot.
local DEFAULT_ICON = 133633

-- Outer height of the attached strip panel.
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
		GameTooltip:AddLine((total - free) .. " / " .. total, K.Colors.silver[1], K.Colors.silver[2], K.Colors.silver[3])
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
	-- Its own panel below the frame, wearing the same gradient and border so it
	-- reads as one piece flush against the bottom of the bags.
	local strip = CreateFrame("Frame", nil, f)
	strip:SetHeight(Module.BagStripHeight)
	K.CreateGradientBackground(strip, 0.95)
	K.CreateBorder(strip)
	strip:Hide()

	local gap = C.Bags.Spacing
	strip.buttons = {}
	local x = PAD
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
		x = x + SLOT + gap
	end

	-- Panel wide enough for the buttons plus padding, right-aligned under the frame
	-- and hanging just below its bottom edge.
	strip:SetWidth(x - gap + PAD)
	strip:SetPoint("TOPRIGHT", f, "BOTTOMRIGHT", 0, -6)

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

-- Fold the strip in or out and relayout so the grid makes room for it. Handles the
-- carried-bag strip on the bags and the tab bar on the bank, whichever this window
-- carries.
function Module:ToggleBagStrip(f, show)
	local strip = f and (f.BagStrip or f.BankBar)
	if not strip then
		return
	end
	strip:SetShown(show)
	if show then
		if f.BagStrip then
			self:UpdateBagStrip(f)
		end
		if f.BankBar and self.UpdateBankBar then
			self:UpdateBankBar(f)
		end
	end
	self:LayoutContainer(f)
end
