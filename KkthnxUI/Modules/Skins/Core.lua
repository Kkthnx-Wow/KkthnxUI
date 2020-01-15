local K, C = unpack(select(2, ...))
local Module = K:NewModule("Skins")

local _G = _G
local pairs = pairs
local type = type

local IsAddOnLoaded = _G.IsAddOnLoaded
local NO = _G.NO

Module.NewSkin = {}
Module.NewSkin["KkthnxUI"] = {}
local function LoadWithSkin(_, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") then
		Module:UnregisterEvent("ADDON_LOADED", LoadWithSkin)
		return
	end

	for _addon, skinfunc in pairs(Module.NewSkin) do
		if type(skinfunc) == "function" then
			if _addon == addon then
				if skinfunc then
					skinfunc()
				end
			end
		elseif type(skinfunc) == "table" then
			if _addon == addon then
				for _, skinfunc in pairs(Module.NewSkin[_addon]) do
					if skinfunc then
						skinfunc()
					end
				end
			end
		end
	end
end
K:RegisterEvent("ADDON_LOADED", LoadWithSkin)

function Module:AcceptFrame(MainText, Function)
	if not AcceptFrame then
		AcceptFrame = CreateFrame("Frame", "AcceptFrame", UIParent)

		AcceptFrame.Background = AcceptFrame:CreateTexture(nil, "BACKGROUND", -1)
		AcceptFrame.Background:SetAllPoints()
		AcceptFrame.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		K.CreateBorder(AcceptFrame)

		AcceptFrame:SetPoint("CENTER", UIParent, "CENTER")
		AcceptFrame:SetFrameStrata("DIALOG")
		AcceptFrame.Text = AcceptFrame:CreateFontString(nil, "OVERLAY")
		AcceptFrame.Text:SetFont(C["Media"].Font, 14)
		AcceptFrame.Text:SetPoint("TOP", AcceptFrame, "TOP", 0, -10)
		AcceptFrame.Accept = CreateFrame("Button", nil, AcceptFrame, "OptionsButtonTemplate")
		AcceptFrame.Accept:SkinButton()
		AcceptFrame.Accept:SetSize(70, 24)
		AcceptFrame.Accept:SetPoint("RIGHT", AcceptFrame, "BOTTOM", -10, 20)
		AcceptFrame.Accept:SetFormattedText("|cFFFFFFFF%s|r", YES)
		AcceptFrame.Close = CreateFrame("Button", nil, AcceptFrame, "OptionsButtonTemplate")
		AcceptFrame.Close:SkinButton()
		AcceptFrame.Close:SetSize(70, 24)
		AcceptFrame.Close:SetPoint("LEFT", AcceptFrame, "BOTTOM", 10, 20)
		AcceptFrame.Close:SetScript("OnClick", function(self) self:GetParent():Hide() end)
		AcceptFrame.Close:SetFormattedText("|cFFFFFFFF%s|r", NO)
	end

	AcceptFrame.Text:SetText(MainText)
	AcceptFrame:SetSize(AcceptFrame.Text:GetStringWidth() + 100, AcceptFrame.Text:GetStringHeight() + 60)
	AcceptFrame.Accept:SetScript("OnClick", Function)
	AcceptFrame:Show()
end

-- local GameMenuButtonList = {
-- 	{content = GameMenuFirestorm, label = function() return GameMenuFirestorm:GetText() end},
-- 	{content = GameMenuButtonHelp, label = GAMEMENU_HELP},
-- 	{content = GameMenuButtonStore, label = BLIZZARD_STORE},
-- 	{content = GameMenuButtonWhatsNew, label = GAMEMENU_NEW_BUTTON},
-- 	{content = GameMenuButtonOptions, label = SYSTEMOPTIONS_MENU},
-- 	{content = GameMenuButtonUIOptions, label = UIOPTIONS_MENU},
-- 	{content = GameMenuButtonKeybindings, label = KEY_BINDINGS},
-- 	{content = GameMenuButtonMacros, label = MACROS},
-- 	{content = GameMenuButtonAddons, label = ADDONS},
-- 	{content = GameMenuFrame.KkthnxUI, label = function() return GameMenuFrame.KkthnxUI:GetText() end},
-- 	{content = GameMenuButtonRatings, label = RATINGS_MENU},
-- 	{content = GameMenuButtonLogout, label = LOGOUT},
-- 	{content = GameMenuButtonQuit, label = EXIT_GAME},
-- 	{content = GameMenuButtonContinue, label = RETURN_TO_GAME, anchor = "BOTTOM"}
-- }

-- function Module.OnEvent(self, event, ...)
-- 	if (event == "PLAYER_REGEN_ENABLED") then
-- 		K:UnregisterEvent("PLAYER_REGEN_ENABLED", self.OnEvent)
-- 		Module:UpdateButtonLayout()
-- 	end
-- end

-- function Module.UpdateButtonLayout(self)
-- 	if InCombatLockdown() then
-- 		return K:RegisterEvent("PLAYER_REGEN_ENABLED", self.OnEvent)
-- 	end

-- 	local first, last, previous
-- 	for _, v in ipairs(GameMenuButtonList) do
-- 		local button = v.button
-- 		if button and button:IsShown() then
-- 			button:ClearAllPoints()
-- 			if previous then
-- 				button:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -10)
-- 			else
-- 				button:SetPoint("TOP", GameMenuFrame, "TOP", 0, -300) -- we'll change this later
-- 				first = button
-- 			end
-- 			previous = button
-- 			last = button
-- 		end
-- 	end

-- 	-- re-align first button so that the menu will be vertically centered
-- 	local top = first:GetTop()
-- 	local bottom = last:GetBottom()
-- 	local screen_height = K.ScreenHeight()
-- 	local height = top - bottom
-- 	local y_position = (screen_height - height) * 2 / 5

-- 	first:ClearAllPoints()
-- 	first:SetPoint("TOP", GameMenuFrame, "TOP", 0, -y_position)
-- end

function Module:OnEnable()
	self:ReskinBigWigs()
	self:ReskinDBM()
	self:ReskinDetails()
	self:ReskinSimulationcraft()
	self:ReskinSkada()
	self:ReskinSpy()
	self:ReskinTitanPanel()
	self:ReskinWeakAuras()
	self:ReskinWorldQuestTab()

	-- -- kill mac options button if not a mac client
	-- if GameMenuButtonMacOptions and (not IsMacClient()) then
	-- 	for i, v in ipairs(GameMenuButtonList) do
	-- 		if v.content == GameMenuButtonMacOptions then
	-- 			GameMenuButtonMacOptions:UnregisterAllEvents()
	-- 			GameMenuButtonMacOptions:SetParent(K.UIFrameHider)
	-- 			GameMenuButtonMacOptions.SetParent = function() end
	-- 			table.remove(GameMenuButtonList, i)
	-- 			break
	-- 		end
	-- 	end
	-- end

	-- local function DelayFuckStormButton()
	-- 	-- print("Quit Forcing Buttons On Your Client.")
	-- 	if GameMenuFirestorm then
	-- 		for i, v in ipairs(GameMenuButtonList) do
	-- 			if v.content == GameMenuFirestorm then
	-- 				GameMenuFirestorm:UnregisterAllEvents()
	-- 				GameMenuFirestorm:SetParent(K.UIFrameHider)
	-- 				GameMenuFirestorm.SetParent = function() end
	-- 				table.remove(GameMenuButtonList, i)
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- end
	-- K.Delay(5, DelayFuckStormButton)

	-- -- Remove store button if there's no store available,
	-- -- if we're currently using a trial account,
	-- -- or if the account is in limited (no paid gametime) mode.
	-- -- TODO: Hook a callback post-styling and post-showing this
	-- -- when the store becomes available mid-session.
	-- if GameMenuButtonStore and ((C_StorePublic and not C_StorePublic.IsEnabled()) or (IsTrialAccount and IsTrialAccount()) or (GameLimitedMode_IsActive and GameLimitedMode_IsActive())) then
	-- 	for i, v in ipairs(GameMenuButtonList) do
	-- 		if v.content == GameMenuButtonStore then
	-- 			GameMenuButtonStore:UnregisterAllEvents()
	-- 			GameMenuButtonStore:SetParent(K.UIFrameHider)
	-- 			GameMenuButtonStore.SetParent = function() end
	-- 			table.remove(GameMenuButtonList, i)
	-- 			break
	-- 		end
	-- 	end
	-- end

	-- if GameMenuFrame_UpdateVisibleButtons then
	-- 	hooksecurefunc("GameMenuFrame_UpdateVisibleButtons", function()
	-- 		Module:UpdateButtonLayout()
	-- 		-- DelayFuckStormButton()
	-- 	end)
	-- end

	-- K:RegisterEvent("UI_SCALE_CHANGED", Module.UpdateButtonLayout)
	-- K:RegisterEvent("DISPLAY_SIZE_CHANGED", Module.UpdateButtonLayout)

	-- if VideoOptionsFrameApply then
	-- 	VideoOptionsFrameApply:HookScript("OnClick", function()
	-- 		Module:UpdateButtonLayout()
	-- 	end)
	-- end

	-- if VideoOptionsFrameOkay then
	-- 	VideoOptionsFrameOkay:HookScript("OnClick", function()
	-- 		Module:UpdateButtonLayout()
	-- 	end)
	-- end
end