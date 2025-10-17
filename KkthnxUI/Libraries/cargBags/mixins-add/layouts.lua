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

DESCRIPTION
	This file holds a list of default layouts

DEPENDENCIES
	mixins/api-common.lua
]]
local _, ns = ...
local layouts = ns.cargBags.classes.Container.layouts
local ipairs = ipairs
local math_floor = math.floor
local cos = math.cos
local sin = math.sin

--[[!
	Grid layout (refactored)
	Refactored by Kkthnx to enhance efficiency, robustness, and maintainability:
		Replaced the 'i == 1' size probe with a visibility-based counter to handle hidden buttons correctly
		Rounded cached button size and total dimensions to integers to prevent sub-pixel artifacts
		Localized lookups and precomputed step sizes to reduce per-button overhead
	@param columns <number> number of columns [default: 8]
	@param spacing <number> spacing between buttons [default: 5]
	@param xOffset <number> x-offset of the whole layout [default: 0]
	@param yOffset <number> y-offset of the whole layout [default: 0]
]]
function layouts.grid(self, columns, spacing, xOffset, yOffset)
	columns, spacing = columns or 8, spacing or 5
	xOffset, yOffset = xOffset or 0, yOffset or 0

	local buttons = self.buttons
	local width, height = 0, 0
	local stepX, stepY = 0, 0
	local visibleIndex = 0
	local rows = 0

	for i = 1, #buttons do
		local button = buttons[i]
		if button:IsShown() then
			visibleIndex = visibleIndex + 1

			if visibleIndex == 1 then
				width, height = button:GetSize()
				width = math_floor(width + 0.5)
				height = math_floor(height + 0.5)
				stepX = width + spacing
				stepY = height + spacing
			end

			local col = (visibleIndex - 1) % columns + 1
			rows = math_floor((visibleIndex - 1) / columns) + 1

			local xPos = (col - 1) * stepX
			local yPos = -(rows - 1) * stepY

			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", self, "TOPLEFT", xPos + xOffset, yPos + yOffset)
		end
	end

	if visibleIndex == 0 then
		return 0, 0
	end

	local rawTotalWidth = columns * stepX - spacing
	local rawTotalHeight = rows * stepY - spacing
	local totalWidth = math_floor(rawTotalWidth + 0.5)
	local totalHeight = math_floor(rawTotalHeight + 0.5)

	return totalWidth, totalHeight
end

--[[!
	Places the buttons in a circle [experimental]
	@param radius <number> radius of the circle [optional]
	@param xOffset <number> x-offset of the whole layout [default: 0]
	@param yOffset <number> y-offset of the whole layout [default: 0]
]]
function layouts.circle(self, radius, xOffset, yOffset)
	radius = radius or (#self.buttons * 50) / math.pi / 2
	xOffset, yOffset = xOffset or 0, yOffset or 0

	local a = 360 / #self.buttons

	for i, button in ipairs(self.buttons) do
		local x = radius * cos(a * i)
		local y = -radius * sin(a * i)

		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", self, "TOPLEFT", radius + x + xOffset, y - radius + yOffset)
	end
	return radius * 2, radius * 2
end
