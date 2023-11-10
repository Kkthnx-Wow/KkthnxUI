local K, C = KkthnxUI[1], KkthnxUI[2]

local table_insert = table.insert

table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	GameMenuFrame.Header:StripTextures()
	GameMenuFrame.Header:ClearAllPoints()
	GameMenuFrame.Header:SetPoint("TOP", GameMenuFrame, 0, 7)
	GameMenuFrame:CreateBorder(nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32 or nil, nil, C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and -10 or nil)
	GameMenuFrame.Border:Hide()

	local buttons = {
		GameMenuButtonHelp,
		GameMenuButtonWhatsNew,
		GameMenuButtonStore,
		GameMenuButtonSettings,
		GameMenuButtonEditMode,
		GameMenuButtonMacros,
		GameMenuButtonAddons,
		GameMenuButtonLogout,
		GameMenuButtonQuit,
		GameMenuButtonContinue,
	}

	for _, button in ipairs(buttons) do
		button:SkinButton(true)
	end

	GameMenuButtonLogoutText:SetTextColor(1, 1, 0)
	GameMenuButtonQuitText:SetTextColor(1, 0, 0)
	GameMenuButtonContinueText:SetTextColor(0, 1, 0)

	-- ScriptErrorsFrame
	ScriptErrorsFrame:SetScale(UIParent:GetScale())

	-- TicketStatusFrame
	TicketStatusFrameButton:StripTextures()
	TicketStatusFrameButton:SkinButton()
end)
