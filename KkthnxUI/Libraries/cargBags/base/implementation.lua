--[[
	cargBags: An inventory framework addon for World of Warcraft

	Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

	cargBags is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	cargBags is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with cargBags; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
]]
local _, ns = ...
local B, C, L, DB = unpack(ns)
local cargBags = ns.cargBags

local GetContainerNumSlots = C_Container.GetContainerNumSlots
local GetContainerItemInfo = C_Container.GetContainerItemInfo
local GetContainerItemCooldown = C_Container.GetContainerItemCooldown
local GetContainerItemQuestInfo = C_Container.GetContainerItemQuestInfo
local GetItemInfo = C_Item.GetItemInfo
local tinsert = tinsert
local pairs = pairs
local ipairs = ipairs
local strmatch = strmatch
local next = next
local wipe = wipe
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local UIParent = UIParent
local C_Bank = C_Bank
local Enum = Enum
local tonumber = tonumber

--[[!
	@class Implementation
		The Implementation-class serves as the basis for your cargBags-instance, handling
		item-data-fetching and dispatching events for containers and items.
]]
local Implementation = cargBags:NewClass("Implementation", nil, "Button")
Implementation.instances = {}
Implementation.itemKeys = {}

local toBagSlot = cargBags.ToBagSlot
local PET_CAGE = 82800
local MYTHIC_KEYSTONES = {
	[180653] = true,
	[187786] = true, -- Timewarped
}

--[[!
	Creates a new instance of the class
	@param name <string>
	@return impl <Implementation>
]]
function Implementation:New(name)
	if self.instances[name] then
		return error(("cargBags: Implementation '%s' already exists!"):format(name))
	end
	if _G[name] then
		return error(("cargBags: Global '%s' for Implementation is already used!"):format(name))
	end

	local impl = setmetatable(CreateFrame("Button", name, UIParent), self.__index)
	impl.name = name

	impl:SetAllPoints()
	impl:EnableMouse(nil)
	impl:Hide()

	impl._dirtyBags = {}
	impl._dirtySlots = {}
	impl._fullDirty = nil
	impl._flushUpdater = nil

	cargBags.SetScriptHandlers(impl, "OnEvent", "OnShow", "OnHide")

	impl.contByID = {} --! @property contByID <table> Holds all child-Containers by index
	impl.contByName = {} --!@ property contByName <table> Holds all child-Containers by name
	impl.buttons = {} -- @property buttons <table> Holds all ItemButtons by bagSlot
	impl.bagSizes = {} -- @property bagSizes <table> Holds the size of all bags
	impl.events = {} -- @property events <table> Holds all event callbacks
	impl.notInited = true -- @property notInited <bool>

	tinsert(UISpecialFrames, name)

	self.instances[name] = impl

	return impl
end

--[[!
	Script handler, inits and updates the Implementation when shown
	@callback OnOpen
]]
function Implementation:OnShow()
	if self.notInited then
		if not (InCombatLockdown()) then -- initialization of bags in combat taints the itembuttons within - Lars Norberg
			self:Init()
		else
			return
		end
	end

	if self.OnOpen then
		self:OnOpen()
	end
	self:OnEvent("BAG_UPDATE")
end

--[[!
	Script handler, closes the Implementation when hidden
	@callback OnClose
]]
function Implementation:OnHide()
	if self.notInited then
		return
	end

	if self.OnClose then
		self:OnClose()
	end
	if self:AtBank() then
		C_Bank.CloseBankFrame()
	end
end

--[[!
	Toggles the implementation
	@param forceopen <bool> Only open it
]]
function Implementation:Toggle(forceopen)
	if not forceopen and self:IsShown() then
		self:Hide()
	else
		self:Show()
	end
end

--[[!
	Fetches an implementation by name
	@param name <string>
	@return impl <Implementation>
]]
function Implementation:Get(name)
	return self.instances[name]
end

--[[!
	Fetches a child-Container by name
	@param name <string>
	@return container <Container>
]]
function Implementation:GetContainer(name)
	return self.contByName[name]
end

--[[!
	Fetches a implementation-owned class by relative name

	The relative class names are prefixed by the name of the implementation
	e.g. :GetClass("Button") -> ImplementationButton
	It is just to prevent people from overwriting each others classes

	@param name <string> The relative class name
	@param create <bool> Creates it, if it doesn't exist
	@param ... Arguments to pass to cargBags:NewClass(name, ...) when creating
	@return class <table> The class prototype
]]
function Implementation:GetClass(name, create, ...)
	if not name then
		return
	end

	name = self.name .. name
	local class = cargBags.classes[name]
	if class or not create then
		return class
	end

	class = cargBags:NewClass(name, ...)
	class.implementation = self
	return class
end

--[[!
	Wrapper for :GetClass() using a Container
	@note Container-classes have the full name "ImplementationNameContainer"
	@param name <string> The relative container class name
	@return class <table> The class prototype
]]
function Implementation:GetContainerClass(name)
	return self:GetClass((name or "") .. "Container", true, "Container")
end

--[[!
	Wrapper for :GetClass() using an ItemButton
	@note ItemButton-Classes have the full name "ImplementationNameItemButton"
	@param name <string> The relative itembutton class name
	@return class <table> The class prototype
]]
function Implementation:GetItemButtonClass(name)
	return self:GetClass((name or "") .. "ItemButton", true, "ItemButton")
end

--[[!
	Sets the ItemButton class to use for spawning new buttons
	@param name <string> The relative itembutton class name
	@return class <table> The newly set class
]]
function Implementation:SetDefaultItemButtonClass(name)
	self.buttonClass = self:GetItemButtonClass(name)
	return self.buttonClass
end

--[[!
	Registers the implementation to overwrite Blizzards Bag-Toggle-Functions
	@note This function only works before PLAYER_LOGIN and can be overwritten by other Implementations
]]
function Implementation:RegisterBlizzard()
	cargBags:RegisterBlizzard(self)
end

local _registerEvent = UIParent.RegisterEvent
local _isEventRegistered = UIParent.IsEventRegistered

--[[!
	Registers an event callback - these are only called if the Implementation is currently shown
	The events do not have to be 'blizz events' - they can also be internal messages
	@param event <string> The event to register for
	@param key Something passed to the callback as arg #1, also serves as identification
	@param func <function> The function to call on the event
]]
function Implementation:RegisterEvent(event, key, func)
	local events = self.events

	if not events[event] then
		events[event] = {}
	end

	events[event][key] = func
	if event:upper() == event and not _isEventRegistered(self, event) then
		_registerEvent(self, event)
	end
end

--[[!
	Returns whether the Implementation has the specified event callback
	@param event <string> The event of the callback
	@param key The identification of the callback [optional]
]]
function Implementation:IsEventRegistered(event, key)
	return self.events[event] and (not key or self.events[event][key])
end

--[[!
	Script handler, dispatches the events
]]
function Implementation:OnEvent(event, ...)
	if not (self.events[event] and self:IsShown()) then
		return
	end

	for key, func in pairs(self.events[event]) do
		func(key, event, ...)
	end
end

--[[!
	Inits the implementation by registering events
	@callback OnInit
]]
function Implementation:Init()
	if not self.notInited then
		return
	end

	-- initialization of bags in combat taints the itembuttons within - Lars Norberg
	if InCombatLockdown() then
		return
	end

	self.notInited = nil

	if self.OnInit then
		self:OnInit()
	end

	if not self.buttonClass then
		self:SetDefaultItemButtonClass()
	end

	self:RegisterEvent("BAG_UPDATE", self, self.BAG_UPDATE)
	self:RegisterEvent("BAG_UPDATE_DELAYED", self, self.BAG_UPDATE)
	self:RegisterEvent("MERCHANT_SHOW", self, self.BAG_UPDATE)
	self:RegisterEvent("BAG_UPDATE_COOLDOWN", self, self.BAG_UPDATE_COOLDOWN)
	self:RegisterEvent("ITEM_LOCK_CHANGED", self, self.ITEM_LOCK_CHANGED)
	self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", self, self.PLAYERBANKSLOTS_CHANGED)
	self:RegisterEvent("UNIT_QUEST_LOG_CHANGED", self, self.UNIT_QUEST_LOG_CHANGED)
	self:RegisterEvent("BAG_CLOSED", self, self.BAG_CLOSED)
end

--[[!
	Returns whether the user is currently at the bank
	@return atBank <bool>
]]
function Implementation:AtBank()
	return cargBags.atBank
end

--[[
	Fetches a button by bagID-slotID-pair
	@param bagID <number>
	@param slotID <number>
	@return button <ItemButton>
]]
function Implementation:GetButton(bagID, slotID)
	return self.buttons[toBagSlot(bagID, slotID)]
end

--[[!
	Stores a button by bagID-slotID-pair
	@param bagID <number>
	@param slotID <number>
	@param button <ItemButton> [optional]
]]
function Implementation:SetButton(bagID, slotID, button)
	self.buttons[toBagSlot(bagID, slotID)] = button
end

local defaultItem = cargBags:NewItemTable()

--[[!
	Fetches the itemInfo of the item in bagID/slotID into the table
	@param bagID <number>
	@param slotID <number>
	@param i <table> [optional]
	@return i <table>
]]

local iLvlClassIDs = {
	[Enum.ItemClass.Gem] = Enum.ItemGemSubclass.Artifactrelic,
	[Enum.ItemClass.Armor] = 0,
	[Enum.ItemClass.Weapon] = 0,
}
local function isItemHasLevel(item)
	local index = iLvlClassIDs[item.classID]
	return index and (index == 0 or index == item.subClassID)
end

function Implementation:GetItemInfo(bagID, slotID, i)
	i = i or defaultItem
	for k in pairs(i) do
		i[k] = nil
	end

	i.bagId = bagID
	i.slotId = slotID

	local texture, count, locked, quality, itemLink, noValue, itemID
	local info = GetContainerItemInfo(bagID, slotID)
	if info then
		i.texture, i.count, i.locked, i.quality, i.link, i.id, i.hasPrice = info.iconFileID, info.stackCount, info.isLocked, (info.quality or 1), info.hyperlink, info.itemID, not info.hasNoValue

		i.isInSet, i.setName = C_Container.GetContainerItemEquipmentSetInfo(bagID, slotID) -- Still Broken!

		i.cdStart, i.cdFinish, i.cdEnable = GetContainerItemCooldown(bagID, slotID)

		local questInfo = GetContainerItemQuestInfo(bagID, slotID)
		if questInfo then
			i.isQuestItem, i.questID, i.questActive = questInfo.isQuestItem, questInfo.questID, questInfo.isActive
		end

		local name, _, _, _, _, typeText, subTypeText, _, equipLoc, _, _, classID, subClassID, bindType, expacID = GetItemInfo(i.link)
		i.name, i.type, i.subType, i.equipLoc, i.classID, i.subClassID, i.expacID, i.bindType = name, typeText, subTypeText, (equipLoc and _G[equipLoc]) or nil, classID, subClassID, expacID, bindType

		if isItemHasLevel(i) then
			i.ilvl = KkthnxUI and KkthnxUI[1].GetItemLevel(i.link, i.bagId ~= -1 and i.bagId, i.slotId)
		end

		if i.id == PET_CAGE then
			local petID, petLevel, petName = strmatch(i.link, "|H%w+:(%d+):(%d+):.-|h%[(.-)%]|h")
			i.name = petName
			i.id = tonumber(petID) or 0
			i.level = tonumber(petLevel) or 0
			i.classID = Enum.ItemClass.Miscellaneous
			i.subClassID = Enum.ItemMiscellaneousSubclass.CompanionPet
		elseif MYTHIC_KEYSTONES[i.id] then
			i.level, i.name = strmatch(i.link, "|H%w+:%d+:%d+:(%d+):.-|h%[(.-)%]|h")
			i.level = tonumber(i.level) or 0
		end
	end

	return i
end

--[[!
	Updates the defined slot, creating/removing buttons as necessary
	@param bagID <number>
	@param slotID <number>
]]
function Implementation:UpdateSlot(bagID, slotID)
	local item = self:GetItemInfo(bagID, slotID)
	local button = self:GetButton(bagID, slotID)
	local container = self:GetContainerForItem(item, button)

	if container then
		if button then
			if container ~= button.container then
				button.container:RemoveButton(button)
				container:AddButton(button)
			end
		else
			button = self.buttonClass:New(bagID, slotID)
			self:SetButton(bagID, slotID, button)
			container:AddButton(button)
		end

		button:ButtonUpdate(item)
	elseif button then
		button.container:RemoveButton(button)
		self:SetButton(bagID, slotID, nil)
		button:Free()
	end
end

local closed

--[[!
	Updates a bag and its containing slots
	@param bagID <number>
]]
function Implementation:UpdateBag(bagID)
	local numSlots
	if closed then
		numSlots, bagID = 0, closed
	else
		numSlots = GetContainerNumSlots(bagID)
	end
	local lastSlots = self.bagSizes[bagID] or 0
	self.bagSizes[bagID] = numSlots

	for slotID = 1, numSlots do
		self:UpdateSlot(bagID, slotID)
	end
	for slotID = numSlots + 1, lastSlots do
		local button = self:GetButton(bagID, slotID)
		if button then
			button.container:RemoveButton(button)
			self:SetButton(bagID, slotID, nil)
			button:Free()
		end
	end
end

--[[!
	Updates a set of items
	@param bagID <number> [optional]
	@param slotID <number> [optional]
	@callback Container:OnBagUpdate(bagID, slotID)
]]

local function flushDirty(self)
	-- Early-out if nothing to do
	if not self._fullDirty and not next(self._dirtyBags) and not next(self._dirtySlots) then
		return
	end

	if self._fullDirty then
		if next(self.bagSizes) then
			for bagKey in pairs(self.bagSizes) do
				self:UpdateBag(bagKey)
			end
		else
			for bagID = 0, 5 do
				self:UpdateBag(bagID)
			end
		end
	else
		for bagID in pairs(self._dirtyBags) do
			self:UpdateBag(bagID)
		end
		for bagID, slots in pairs(self._dirtySlots) do
			for slotID in pairs(slots) do
				self:UpdateSlot(bagID, slotID)
			end
		end
	end

	wipe(self._dirtyBags)
	wipe(self._dirtySlots)
	self._fullDirty = nil
end

function Implementation:BAG_UPDATE(event, bagID, slotID, ...)
	if self.isSorting then
		return
	end

	-- Coalesce updates: mark dirty on BAG_UPDATE, flush on next frame or when BAG_UPDATE_DELAYED fires
	if event == "BAG_UPDATE" then
		if bagID and slotID then
			self._dirtySlots[bagID] = self._dirtySlots[bagID] or {}
			self._dirtySlots[bagID][slotID] = true
		elseif bagID then
			self._dirtyBags[bagID] = true
		else
			self._fullDirty = true
		end

		if not self._flushUpdater then
			self._flushUpdater = CreateFrame("Frame")
			self._flushUpdater:Hide()
			self._flushUpdater:SetScript("OnUpdate", function(f)
				f:Hide()
				self._flushScheduled = false
				flushDirty(self)
			end)
		end
		if not self._flushScheduled then
			self._flushScheduled = true
			self._flushUpdater:Show()
		end
		return
	end

	-- Flush on delayed or other triggers
	if event == "BAG_UPDATE_DELAYED" then
		flushDirty(self)
	else
		-- Backward compatibility for direct calls from other handlers
		if bagID and slotID then
			self:UpdateSlot(bagID, slotID)
		elseif bagID then
			self:UpdateBag(bagID)
		else
			if next(self.bagSizes) then
				for bagKey in pairs(self.bagSizes) do
					self:UpdateBag(bagKey)
				end
			else
				for id = 0, 5 do
					self:UpdateBag(id)
				end

				local bankType = BankFrame.BankPanel.bankType
				if bankType == Enum.BankType.Character then
					for bagID = 6, 11 do
						self:UpdateBag(bagID)
					end
				elseif bankType == Enum.BankType.Account then
					for bagID = 12, 16 do
						self:UpdateBag(bagID)
					end
				end
			end
		end
	end
end

--[[!
	Updates a bag of the implementation (fired when it is removed)
	@param bagID <number>
]]
function Implementation:BAG_CLOSED(event, bagID)
	closed = bagID
	self:BAG_UPDATE(event, bagID)
end

--[[!
	Fired when the item cooldowns need to be updated
	@param bagID <number> [optional]
]]
function Implementation:BAG_UPDATE_COOLDOWN(_, bagID)
	if bagID then
		for slotID = 1, GetContainerNumSlots(bagID) do
			local button = self:GetButton(bagID, slotID)
			if button then
				local item = self:GetItemInfo(bagID, slotID)
				button:ButtonUpdateCooldown(item)
			end
		end
	else
		for _, container in pairs(self.contByID) do
			for _, button in pairs(container.buttons) do
				local item = self:GetItemInfo(button.bagId, button.slotId)
				button:ButtonUpdateCooldown(item)
			end
		end
	end
end

--[[!
	Fired when the item is picked up or released
	@param bagID <number>
	@param slotID <number> [optional]
]]
function Implementation:ITEM_LOCK_CHANGED(_, bagID, slotID)
	if self.isSorting then
		return
	end
	if not slotID then
		return
	end

	local button = self:GetButton(bagID, slotID)
	if button then
		local item = self:GetItemInfo(bagID, slotID)
		button:ButtonUpdateLock(item)
	end
end

--[[!
	Fired when bank bags or slots need to be updated
	@param bagID <number>
	@param slotID <number> [optional]
]]
function Implementation:PLAYERBANKSLOTS_CHANGED(event, bagID, slotID)
	self:BAG_UPDATE(event, bagID, slotID)
end

--[[
	Fired when the quest log of a unit changes
]]
function Implementation:UNIT_QUEST_LOG_CHANGED()
	for _, container in pairs(self.contByID) do
		for _, button in pairs(container.buttons) do
			local item = self:GetItemInfo(button.bagId, button.slotId)
			button:ButtonUpdateQuest(item)
		end
	end
end
