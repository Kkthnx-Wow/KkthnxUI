--[[
LICENSE
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
DESCRIPTION:
	Item keys which require tooltip parsing to work
]]
local _, ns = ...
local cargBags = ns.cargBags

local _G = _G

local ITEM_ACCOUNTBOUND = _G.ITEM_ACCOUNTBOUND
local ITEM_BIND_ON_EQUIP = _G.ITEM_BIND_ON_EQUIP
local ITEM_BIND_ON_PICKUP = _G.ITEM_BIND_ON_PICKUP
local ITEM_BIND_ON_USE = _G.ITEM_BIND_ON_USE
local ITEM_BIND_QUEST = _G.ITEM_BIND_QUEST
local ITEM_BIND_TO_ACCOUNT = _G.ITEM_BIND_TO_ACCOUNT
local ITEM_BNETACCOUNTBOUND = _G.ITEM_BNETACCOUNTBOUND
local ITEM_SOULBOUND = _G.ITEM_SOULBOUND

local bindTypeToString = {
	[ITEM_BIND_ON_USE] = "equip",
	[ITEM_BIND_ON_EQUIP] = "equip",
	[ITEM_BIND_ON_PICKUP] = "pickup",
	[ITEM_SOULBOUND] = "soul",
	[ITEM_BIND_QUEST] = "quest",
	[ITEM_ACCOUNTBOUND] = "account",
	[ITEM_BIND_TO_ACCOUNT] = "account",
	[ITEM_BNETACCOUNTBOUND] = "account",
}

cargBags.itemKeys["bindOn"] = function(i)
	if not i.link then
		return
	end

	local K = unpack(KkthnxUI)
	local tip = K.ScanTooltip
	if not tip then
		return
	end

	tip:SetOwner(UIParent, "ANCHOR_NONE")
	tip:SetBagItem(i.bagID, i.slotID)

	for j = 2, 4 do
		local line = _G["KKUI_ScanTooltipTextLeft" .. j]
		local lineText = line and line:GetText()
		local bindOn = lineText and bindTypeToString[lineText]
		if bindOn then
			i.bindOn = bindOn
			return bindOn
		end
	end
end
