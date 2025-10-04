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
local math_min = math.min
local math_ceil = math.ceil
local cos = math.cos
local sin = math.sin

-- Debug flag for visual layout verification (set to true to enable)
local DEBUG_LAYOUT = false

function layouts.grid(self, columns, spacing, xOffset, yOffset)
	columns, spacing = columns or 8, spacing or 5
	xOffset, yOffset = xOffset or 0, yOffset or 0

	local width, height = 0, 0
	local visibleIndex = 0
	local lastRow = 0

	for _, button in ipairs(self.buttons) do
		if button:IsShown() then
			if width == 0 or height == 0 then
				width, height = button:GetSize()
			end

			visibleIndex = visibleIndex + 1
			local col = ((visibleIndex - 1) % columns) + 1
			local row = math_ceil(visibleIndex / columns)
			lastRow = row

			local xPos = (col - 1) * (width + spacing)
			local yPos = -1 * (row - 1) * (height + spacing)

			button:ClearAllPoints()
			button:SetPoint("TOPLEFT", self, "TOPLEFT", xPos + xOffset, yPos + yOffset)

			-- Optional visual debug overlay to verify spacing/alignment
			if DEBUG_LAYOUT then
				local overlay = button.DebugOverlay or button:CreateTexture(nil, "OVERLAY")
				button.DebugOverlay = overlay
				overlay:SetAllPoints()
				overlay:SetColorTexture(1, 0, 0, 0.18) -- subtle red
				overlay:Show()
			elseif button.DebugOverlay then
				button.DebugOverlay:Hide()
			end
		end
	end

	if visibleIndex == 0 then
		return 0, 0
	end

	local usedCols = math_min(columns, visibleIndex)
	local usedRows = lastRow
	return usedCols * (width + spacing) - spacing, usedRows * (height + spacing) - spacing
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
