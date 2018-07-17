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

local AB_ShowGrid = CreateFrame("Frame")
AB_ShowGrid:RegisterEvent("PLAYER_LOGIN")
AB_ShowGrid:RegisterEvent("ADDON_LOADED")
AB_ShowGrid:SetScript("OnEvent", function()
	local IsInstalled = KkthnxUIData[Realm][Name].InstallComplete
	if IsInstalled then
		local b1, b2, b3, b4 = GetActionBarToggles()
		if (not b1 or not b2 or not b3 or not b4) then
			SetActionBarToggles(1, 1, 1, 1)
			K.StaticPopup_Show("FIX_ACTIONBARS")
		end
	end

	for i = 1, NUM_ACTIONBAR_BUTTONS do
		local Button

		Button = _G[string_format("ActionButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button.noGrid = false
		Button:Show()
		ActionButton_ShowGrid(Button)

		Button = _G[string_format("MultiBarRightButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button.noGrid = false
		Button:Show()
		ActionButton_ShowGrid(Button)

		Button = _G[string_format("MultiBarBottomRightButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button.noGrid = false
		Button:Show()
		ActionButton_ShowGrid(Button)

		Button = _G[string_format("MultiBarLeftButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button.noGrid = false
		Button:Show()
		ActionButton_ShowGrid(Button)

		Button = _G[string_format("MultiBarBottomLeftButton%d", i)]
		Button:SetAttribute("showgrid", 1)
		Button:SetAttribute("statehidden", true)
		Button.noGrid = false
		Button:Show()
		ActionButton_ShowGrid(Button)
	end
end)