local K, C, L, _ = select(2, ...):unpack()
if C.Misc.Armory ~= true then return end

-- ADD ARMORY LINK IN UNITPOPUPMENUS (IT BREAKS SET FOCUS)
-- FIND THE REALM AND LOCAL
local realmName = string.lower(GetRealmName())
local realmLocal = string.lower(GetCVar("portal"))
local link

if realmLocal == "ru" then realmLocal = "eu" end

local function urlencode(obj)
	local currentIndex = 1
	local charArray = {}
	while currentIndex <= #obj do
		local char = string.byte(obj, currentIndex)
		charArray[currentIndex] = char
		currentIndex = currentIndex + 1
	end
	local converchar = ""
	for _, char in ipairs(charArray) do
		converchar = converchar..string.format("%%%X", char)
	end
	return converchar
end

realmName = realmName:gsub("'", "")
realmName = realmName:gsub("-", "")
realmName = realmName:gsub(" ", "-")
local myserver = realmName:gsub("-", "")

if K.Client == "ruRU" then
	link = "ru"
elseif K.Client == "frFR" then
	link = "fr"
elseif K.Client == "deDE" then
	link = "de"
elseif K.Client == "esES" or K.Client == "esMX" then
	link = "es"
elseif K.Client == "ptBR" or K.Client == "ptPT" then
	link = "pt"
elseif K.Client == "itIT" then
	link = "it"
elseif K.Client == "zhTW" then
	link = "zh"
elseif K.Client == "koKR" then
	link = "ko"
else
	link = "en"
end

StaticPopupDialogs.LINK_COPY_DIALOG = {
	text = L_POPUP_ARMORY,
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self, ...) self.editBox:SetFocus() end,
	EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	preferredIndex = 3,
}

-- DROPDOWN MENU LINK
hooksecurefunc("UnitPopup_OnClick", function(self)
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
	local name = dropdownFrame.name
	local server = dropdownFrame.server
	if not server then
		server = myserver
	else
		server = string.lower(server:gsub("'", ""))
		server = server:gsub(" ", "-")
	end

	if name and self.value == "ARMORYLINK" then
		local inputBox = StaticPopup_Show("LINK_COPY_DIALOG")
		if realmLocal == "us" or realmLocal == "eu" or realmLocal == "tw" or realmLocal == "kr" then
			if server == myserver then
				linkurl = "http://"..realmLocal..".battle.net/wow/"..link.."/character/"..realmName.."/"..name.."/advanced"
			else
				linkurl = "http://"..realmLocal..".battle.net/wow/"..link.."/search?q="..name.."&f=wowcharacter"
			end
			inputBox.editBox:SetText(linkurl)
			inputBox.editBox:HighlightText()
			return
		elseif realmLocal == "cn" then
			local n, r = name:match"(.*)-(.*)"
			n = n or name
			r = r or GetRealmName()

			linkurl = "http://www.battlenet.com.cn/wow/zh/character/"..urlencode(r).."/"..urlencode(n).."/advanced"
			inputBox.editBox:SetText(linkurl)
			inputBox.editBox:HighlightText()
			return
		else
			print("|cFFFFFF00Unsupported realm location.|r")
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

-- DELETE SOME LINES FROM UNIT DROPDOWN MENU (BROKE SOME LINE)
for _, menu in pairs(UnitPopupMenus) do
	for index = #menu, 1, -1 do
		if menu[index] == "SET_FOCUS" or menu[index] == "CLEAR_FOCUS" or menu[index] == "MOVE_PLAYER_FRAME" or menu[index] == "MOVE_TARGET_FRAME" or menu[index] == "LARGE_FOCUS" or menu[index] == "MOVE_FOCUS_FRAME" or (menu[index] == "PET_DISMISS" and T.class == "HUNTER") then
			table.remove(menu, index)
		end
	end
end