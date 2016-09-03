local K, C, L, _ = select(2, ...):unpack()

local _G = _G

do
	local WorldMapFrame = _G.WorldMapFrame
	local InCombatLockdown = _G.InCombatLockdown

	local WorldMapBountyBoardMixin = _G.WorldMapBountyBoardMixin
	function WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation(self)
		if InCombatLockdown() then
			return
		end

		return WorldMapBountyBoardMixin.GetDisplayLocation(self)
	end

	local WorldMapActionButtonMixin = _G.WorldMapActionButtonMixin
	function WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation(self, useAlternateLocation)
		if InCombatLockdown() then
			return
		end

		return WorldMapActionButtonMixin.GetDisplayLocation(self, useAlternateLocation)
	end

	function WorldMapFrame.UIElementsFrame.ActionButton.Refresh(self)
		if InCombatLockdown() then
			return
		end

		WorldMapActionButtonMixin.Refresh(self)
	end
end

local function skin()
	if not _G.WorldMapFrame.skinned then
		_G.WorldMapFrame:SetUserPlaced(true)
		local trackingBtn = _G.WorldMapFrame.UIElementsFrame.TrackingOptionsButton

		-- BUTTONS
		_G.WorldMapLevelDropDown:ClearAllPoints()
		_G.WorldMapLevelDropDown:SetPoint("TOPLEFT", _G.WorldMapFrame.UIElementsFrame, -15, 3)
		trackingBtn:ClearAllPoints()
		trackingBtn:SetPoint("TOPRIGHT", _G.WorldMapFrame.UIElementsFrame, 3, 3)

		_G.WorldMapFrame.skinned = true
	end
end

-- SIZE ADJUST
local function SetLargeWorldMap()
	if _G.InCombatLockdown() then return end

	-- REPARENT
	_G.WorldMapFrame:SetParent(_G.UIParent)
	_G.WorldMapFrame:SetFrameStrata("HIGH")
	_G.WorldMapFrame:EnableKeyboard(true)

	-- REPOSITION
	_G.WorldMapFrame:ClearAllPoints()
	_G.WorldMapFrame:SetPoint(unpack(C.Position.WorldMap))
	_G.SetUIPanelAttribute(_G.WorldMapFrame, "area", "center")
	_G.SetUIPanelAttribute(_G.WorldMapFrame, "allowOtherPanels", true)
	_G.WorldMapFrame:SetSize(1022, 766)
end

if _G.InCombatLockdown() then return end

_G.BlackoutWorld:SetTexture(nil)

_G.QuestMapFrame_Hide()
if _G.GetCVar("questLogOpen") == 1 then
	_G.QuestMapFrame_Show()
end

_G.hooksecurefunc("WorldMap_ToggleSizeUp", SetLargeWorldMap)

if _G.WORLDMAP_SETTINGS.size == _G.WORLDMAP_FULLMAP_SIZE then
	_G.WorldMap_ToggleSizeUp()
elseif _G.WORLDMAP_SETTINGS.size == _G.WORLDMAP_WINDOWED_SIZE then
	_G.WorldMap_ToggleSizeDown()
end

_G.DropDownList1:HookScript("OnShow", function(self)
	if _G.DropDownList1:GetScale() ~= _G.UIParent:GetScale() then
		_G.DropDownList1:SetScale(_G.UIParent:GetScale())
	end
end)

-- KEEP IT CENTERED
hooksecurefunc("WorldMap_ToggleSizeDown", function()
	WorldMapFrame:ClearAllPoints()
	WorldMapFrame:SetPoint(unpack(C.Position.WorldMap))
end)