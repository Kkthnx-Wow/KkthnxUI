local K, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

local _G = _G
local string_format = string.format

local ActionButton_ShowGrid = _G.ActionButton_ShowGrid
local CreateFrame = _G.CreateFrame
local GetActionBarToggles = _G.GetActionBarToggles
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local SetActionBarToggles = _G.SetActionBarToggles
local SetCVar = _G.SetCVar

local FixBarToggle = CreateFrame("Frame")
FixBarToggle:RegisterEvent("PLAYER_ENTERING_WORLD")
FixBarToggle:SetScript("OnEvent", function(self)
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")

	local IsInstalled = KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete

	if IsInstalled then
		local b1, b2, b3, b4 = GetActionBarToggles()
		if (not b1 or not b2 or not b3 or not b4) then
			SetActionBarToggles(1, 1, 1, 1, 0)
			K.StaticPopup_Show("FIX_ACTIONBARS")
		end
	end

	if C["ActionBar"].ShowGrid == true then
		SetCVar("alwaysShowActionBars", 1)
		for i = 1, 12 do
			local button = _G[string_format("ActionButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarRightButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarBottomRightButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarLeftButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)

			button = _G[string_format("MultiBarBottomLeftButton%d", i)]
			button.noGrid = nil
			button:SetAttribute("showgrid", 1)
			ActionButton_ShowGrid(button)
		end
	else
		SetCVar("alwaysShowActionBars", 0)
	end
end)