local K, C, L, _ = select(2, ...):unpack()
if C.Misc.Armory ~= true then return end

-- Add Armory link in UnitPopupMenus (It breaks set focus)
-- Find the Realm and Local
local byte = string.byte
local ipairs = ipairs
local format = string.format
local gsub = string.gsub
local lower = string.lower
local remove = table.remove
local GetRealmName = GetRealmName
local hooksecurefunc = hooksecurefunc

local realmName = (GetRealmName())
local realmLocal = lower(GetCVar("portal"))
local link

if realmLocal == "ru" then realmLocal = "eu" end

local function urlencode(obj)
	local currentIndex = 1
	local charArray = {}
	while currentIndex <= #obj do
		local char = byte(obj, currentIndex)
		charArray[currentIndex] = char
		currentIndex = currentIndex + 1
	end
	local converchar = ""
	for _, char in ipairs(charArray) do
		converchar = converchar..format("%%%X", char)
	end
	return converchar
end

realmName = realmName:gsub("'", "")
realmName = realmName:gsub("-", "")
realmName = realmName:gsub(" ", "-")
local myserver = realmName:gsub("-", "")

StaticPopupDialogs.LINK_COPY_DIALOG = {
	text = L_POPUP_ARMORY,
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	hasWideEditBox = 1,
	OnShow = function(self, ...) self.wideEditBox:SetFocus() end,
	EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	preferredIndex = 3,
}

-- Dropdown menu link
hooksecurefunc("UnitPopup_OnClick", function(self)
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
	local name = dropdownFrame.name
	local server = dropdownFrame.server
	if not server then
		server = myserver
	else
		server = lower(server:gsub("'", ""))
		server = server:gsub(" ", "-")
	end

	if name and self.value == "ARMORYLINK" then
		local inputBox = StaticPopup_Show("LINK_COPY_DIALOG")
		if K.Realm == "Icecrown" or K.Realm == "Lordaeron" then
			if server == myserver then
				linkurl = "http://armory.warmane.com/character/"..name.."/"..realmName.."/summary"
			else
				linkurl = "http://armory.warmane.com/character/"..name.."/"..realmName.."/summary"
			end
			inputBox.wideEditBox:SetText(linkurl)
			inputBox.wideEditBox:HighlightText()
			return
		else
			K.Print("|cffffe02eThis realm is not currently supported|r")
			StaticPopup_Hide("LINK_COPY_DIALOG")
			return
		end
	end
end)

UnitPopupButtons["ARMORYLINK"] = {text = L_POPUP_ARMORY, dist = 0, func = UnitPopup_OnClick}
tinsert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["RAID"], #UnitPopupMenus["RAID"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"] - 1, "ARMORYLINK")

-- Delete some lines from unit dropdown menu (Broke some line)
for _, menu in pairs(UnitPopupMenus) do
	for index = #menu, 1, -1 do
		if menu[index] == "SET_FOCUS" or menu[index] == "CLEAR_FOCUS" or menu[index] == "MOVE_PLAYER_FRAME" or menu[index] == "MOVE_TARGET_FRAME" or menu[index] == "LARGE_FOCUS" or menu[index] == "MOVE_FOCUS_FRAME" or (menu[index] == "PET_DISMISS" and K.Class == "HUNTER") then
			remove(menu, index)
		end
	end
end