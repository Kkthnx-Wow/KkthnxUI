local K, C, L = unpack(select(2, ...))

local Levels = UIDROPDOWNMENU_MAXLEVELS
local UIDropDownMenu_CreateFrames = UIDropDownMenu_CreateFrames
local DropDown = CreateFrame("Frame")

DropDown.ChatMenus = {
	"ChatMenu",
	"EmoteMenu",
	"LanguageMenu",
	"VoiceMacroMenu",
}

function DropDown:Skin()
	for i = 1, Levels do
		local Backdrop

		Backdrop = _G["DropDownList"..i.."MenuBackdrop"]
		if Backdrop and not Backdrop.IsSkinned then
			Backdrop:SetTemplate("Default")
			Backdrop.IsSkinned = true
		end

		Backdrop = _G["DropDownList"..i.."Backdrop"]
		if Backdrop and not Backdrop.IsSkinned then
			Backdrop:SetTemplate("Default")
			Backdrop.IsSkinned = true
		end

		Backdrop = _G["Lib_DropDownList"..i.."MenuBackdrop"]
		if Backdrop and not Backdrop.IsSkinned then
			Backdrop:SetTemplate("Default")
			Backdrop.IsSkinned = true
		end

		Backdrop = _G["Lib_DropDownList"..i.."Backdrop"]
		if Backdrop and not Backdrop.IsSkinned then
			Backdrop:SetTemplate("Default")
			Backdrop.IsSkinned = true
		end
	end
end

function DropDown:Enable()
	local Menu

	for i = 1, getn(self.ChatMenus) do
		Menu = _G[self.ChatMenus[i]]
		Menu:SetTemplate()
		Menu.SetBackdropColor = K.Noop
	end

	hooksecurefunc("UIDropDownMenu_CreateFrames", self.Skin)

	-- Use dropdown lib
	self.Open = Lib_EasyMenu or EasyMenu
end

DropDown:RegisterEvent("PLAYER_LOGIN")
DropDown:SetScript("OnEvent", DropDown.Enable)