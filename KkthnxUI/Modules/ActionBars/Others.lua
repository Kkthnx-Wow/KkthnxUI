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

local Name = UnitName("player")
local Realm = GetRealmName()

local FixActionBarToggles = CreateFrame("Frame")
FixActionBarToggles:RegisterEvent("PLAYER_ENTERING_WORLD")
FixActionBarToggles:SetScript("OnEvent", function(self, event)
	local IsInstalled = KkthnxUIData[Realm][Name].InstallComplete
	if IsInstalled then
		local b1, b2, b3, b4 = GetActionBarToggles()
		if (not b1 or not b2 or not b3 or not b4) then
			self:UnregisterEvent("PLAYER_ENTERING_WORLD")
			SetActionBarToggles(1, 1, 1, 1, 0)
			K.StaticPopup_Show("FIX_ACTIONBARS")
		end
	end
	
	SetCVar("alwaysShowActionBars", 1)
	
	for i = 1, 12 do
		local button = _G[format("ActionButton%d", i)]
		button.noGrid = nil
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
		
		button = _G[format("MultiBarRightButton%d", i)]
		button.noGrid = nil
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
		
		button = _G[format("MultiBarBottomRightButton%d", i)]
		button.noGrid = nil
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
		
		button = _G[format("MultiBarLeftButton%d", i)]
		button.noGrid = nil
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
		
		button = _G[format("MultiBarBottomLeftButton%d", i)]
		button.noGrid = nil
		button:SetAttribute("showgrid", 1)
		ActionButton_ShowGrid(button)
	end
end)