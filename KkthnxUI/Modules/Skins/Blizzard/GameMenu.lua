local K, C = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert

table_insert(C.defaultThemes, function()
	GameMenuFrame.Header:StripTextures()
	GameMenuFrame.Header:ClearAllPoints()
	GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)
	GameMenuFrame:CreateBorder(nil, nil, 32, nil, -10)
	GameMenuFrame.Border:Hide()

	local buttons = {
		GameMenuButtonHelp,
		GameMenuButtonWhatsNew,
		GameMenuButtonStore,
		GameMenuButtonOptions,
		GameMenuButtonUIOptions,
		GameMenuButtonKeybindings,
		GameMenuButtonMacros,
		GameMenuButtonAddons,
		GameMenuButtonLogout,
		GameMenuButtonQuit,
		GameMenuButtonContinue
	}

	for _, button in next, buttons do
		button:SkinButton()
	end

	GameMenuButtonLogoutText:SetTextColor(1, 1, 0)
	GameMenuButtonQuitText:SetTextColor(1, 0, 0)
	GameMenuButtonContinueText:SetTextColor(0, 1, 0)
end)