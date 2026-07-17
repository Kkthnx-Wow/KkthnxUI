--[[-----------------------------------------------------------------------------
-- Registers all main GUI categories in sidebar order.
-- Individual category definitions live in Config/GUI/Categories/*.lua
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]
local B = K.GUIBuilder

if not B then
	print("|cffff0000KkthnxUI Error:|r GUIBuilder missing (Config/GUI/Common.lua did not load).")
	return
end

B.RefreshGUI()

if not B.Ready() then
	print("|cffff0000KkthnxUI Error:|r " .. (L["NewGUI not initialized yet!"]))
	return
end

-- Sidebar order: General first, frames cluster, then systems. Credits always last.
local CATEGORY_BUILDERS = {
	"CreateGeneralCategory",
	"CreateUnitframeCategory",
	"CreatePartyCategory",
	"CreateRaidCategory",
	"CreateBossCategory",
	"CreateArenaCategory",
	"CreateNameplateCategory",
	"CreateActionBarsCategory",
	"CreateAurasCategory",
	"CreateChatCategory",
	"CreateInventoryCategory",
	"CreateMinimapCategory",
	"CreateWorldMapCategory",
	"CreateDataTextCategory",
	"CreateTooltipCategory",
	"CreateLootCategory",
	"CreateAutomationCategory",
	"CreateAnnouncementsCategory",
	"CreateSkinsCategory",
	"CreateMiscCategory",
	"CreateCreditsCategory",
}

for i = 1, #CATEGORY_BUILDERS do
	local name = CATEGORY_BUILDERS[i]
	local builder = B[name]
	if type(builder) == "function" then
		builder()
	else
		print("|cffff0000KkthnxUI Error:|r Missing GUI category builder: " .. tostring(name))
	end
end
