--[[
# Element: Range Fader

Changes the opacity of a unit frame based on whether the frame's unit is in the player's range.

## Widget

Range - A table containing opacity values.

## Notes

Offline units are handled as if they are in range.

## Options

.outsideAlpha - Opacity when the unit is out of range. Defaults to 0.55 (number)[0-1].
.insideAlpha  - Opacity when the unit is within range. Defaults to 1 (number)[0-1].

## Examples

    -- Register with oUF
    self.Range = {
        insideAlpha = 1,
        outsideAlpha = 1/2,
    }
--]]

local _, ns = ...
local oUF = ns.oUF

local _FRAMES = {}
local OnRangeFrame

local next, tinsert, tremove = next, tinsert, tremove

local CreateFrame = CreateFrame
local UnitInRange = UnitInRange
local UnitIsConnected = UnitIsConnected

local function Update(self, event)
	local element = self.Range
	local unit = self.unit

	--[[ Callback: Range:PreUpdate()
	Called before the element has been updated.

	* self - the Range element
	--]]
	if element.PreUpdate then
		element:PreUpdate()
	end

	local inRange, checkedRange
	local connected = UnitIsConnected(unit)
	if connected then
		inRange, checkedRange = UnitInRange(unit)
		if checkedRange and not inRange then
			self:SetAlpha(element.outsideAlpha)
		else
			self:SetAlpha(element.insideAlpha)
		end
	else
		self:SetAlpha(element.insideAlpha)
	end

	--[[ Callback: Range:PostUpdate(object, inRange, checkedRange, isConnected)
	Called after the element has been updated.

	* self         - the Range element
	* object       - the parent object
	* inRange      - indicates if the unit was within 40 yards of the player (boolean)
	* checkedRange - indicates if the range check was actually performed (boolean)
	* isConnected  - indicates if the unit is online (boolean)
	--]]
	if element.PostUpdate then
		return element:PostUpdate(self, inRange, checkedRange, connected)
	end
end

local function Path(self, ...)
	--[[ Override: Range.Override(self, event)
	Used to completely override the internal update function.

	* self  - the parent object
	* event - the event triggering the update (string)
	--]]
	return (self.Range.Override or Update)(self, ...)
end

-- Internal updating method
local timer = 0
local function OnRangeUpdate(_, elapsed)
	timer = timer + elapsed

	if timer >= 0.20 then
		for _, object in next, _FRAMES do
			if object:IsShown() then
				Path(object, "OnUpdate")
			end
		end

		timer = 0
	end
end

local function Enable(self)
	local element = self.Range
	if element then
		element.__owner = self
		element.insideAlpha = element.insideAlpha or 1
		element.outsideAlpha = element.outsideAlpha or 0.35

		-- Ensure that KkthnxUI[2]["Unitframe"] exists before checking Range
		if KkthnxUI and KkthnxUI[2] and KkthnxUI[2]["Unitframe"] then
			if not KkthnxUI[2]["Unitframe"].Range then
				-- Register the event if Range is not enabled
				self:RegisterEvent("UNIT_IN_RANGE_UPDATE", Path)
			else
				-- Set up OnRangeFrame if Range is enabled
				if not OnRangeFrame then
					OnRangeFrame = CreateFrame("Frame")
					OnRangeFrame:SetScript("OnUpdate", OnRangeUpdate)
				end

				tinsert(_FRAMES, self)
				OnRangeFrame:Show()
			end
		end

		return true
	end
end

local function Disable(self)
	local element = self.Range
	if element then
		self:SetAlpha(element.insideAlpha)

		if KkthnxUI and KkthnxUI[2] and KkthnxUI[2]["Unitframe"] then
			if not KkthnxUI[2]["Unitframe"].Range then
				-- Unregister the event if KkthnxUI[2]["Unitframe"] exists
				self:UnregisterEvent("UNIT_IN_RANGE_UPDATE", Path)
			else
				-- Remove self from _FRAMES and hide OnRangeFrame if _FRAMES is empty
				for index, frame in ipairs(_FRAMES) do
					if frame == self then
						tremove(_FRAMES, index)
						break
					end
				end

				if #_FRAMES == 0 and OnRangeFrame then
					OnRangeFrame:Hide()
				end
			end
		end
	end
end

oUF:AddElement("Range", nil, Enable, Disable)
