local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

if not Module then
	return
end

local _G = _G
local pairs = _G.pairs
local string_match = _G.string.match
local tonumber = _G.tonumber

local C_Timer_After = _G.C_Timer.After
local CreateFrame = _G.CreateFrame
local GetItemInfo = _G.GetItemInfo
local GetLocale = _G.GetLocale
local GetSpellInfo = _G.GetSpellInfo
local PanelTemplates_GetSelectedTab = _G.PanelTemplates_GetSelectedTab
local blizzardCollectgarbage = _G.collectgarbage
local hooksecurefunc = _G.hooksecurefunc

-- Garbage Collection Is Being Overused And Misused,
-- And It's Causing Lag And Performance Drops.
do
	if C["General"].FixGarbageCollect then
		blizzardCollectgarbage("setpause", 110)
		blizzardCollectgarbage("setstepmul", 200)

		_G.collectgarbage = function(opt, arg)
			if (opt == "collect") or (opt == nil) then
			elseif (opt == "count") then
				return blizzardCollectgarbage(opt, arg)
			elseif (opt == "setpause") then
				return blizzardCollectgarbage("setpause", 110)
			elseif opt == "setstepmul" then
				return blizzardCollectgarbage("setstepmul", 200)
			elseif (opt == "stop") then
			elseif (opt == "restart") then
			elseif (opt == "step") then
				if (arg ~= nil) then
					if (arg <= 10000) then
						return blizzardCollectgarbage(opt, arg)
					end
				else
					return blizzardCollectgarbage(opt, arg)
				end
			else
				return blizzardCollectgarbage(opt, arg)
			end
		end

		-- Memory Usage Is Unrelated To Performance, And Tracking Memory Usage Does Not Track "BAD" Addons.
		-- Developers Can Uncomment This Line To Enable The Functionality When Looking For Memory Leaks,
		-- But For The Average End-user This Is A Completely Pointless Thing To Track.
		_G.UpdateAddOnMemoryUsage = function() end
	end
end

do
	_G.FriendsFrameBattlenetFrame:SetScript("OnShow", function(self)
		local GameLocale = GetLocale()
		local uLText = "Never share your password"

		if GameLocale == "zhCN" then
			uLText = "永不分享您的密码"
		elseif GameLocale == "zhTW" then
			uLText = "永不分享您的密碼"
		elseif GameLocale == "ruRU" then
			uLText = "Никогда не сообщайте свой пароль"
		elseif GameLocale == "koKR" then
			uLText = "암호 공유 안 함"
		elseif GameLocale == "esMX" then
			uLText = "Dela aldrig ditt lösenord"
		elseif GameLocale == "ptBR" then
			uLText = "Nunca compartilhe sua senha"
		elseif GameLocale == "deDE" then
			uLText = "Teilen Sie niemals Ihr Passwort"
		elseif GameLocale == "esES" then
			uLText = "Nunca comparta su contraseña"
		elseif GameLocale == "frFR" then
			uLText = "Ne partagez jamais votre mot de passe"
		elseif GameLocale == "itIT" then
			uLText = "Mai condividere la tua password"
		end

		self.UnavailableLabel:SetText(uLText)
		if self.UnavailableLabel:GetWidth() <= self:GetWidth() or 190 then
			return
		end
		self:SetWidth(self.UnavailableLabel:GetWidth() + 5)
	end)
end

-- Temporary taint fix
do
	_G.InterfaceOptionsFrameCancel:SetScript("OnClick", function()
		_G.InterfaceOptionsFrameOkay:Click()
	end)

	-- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeCommunitiesTaint
	if (_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then
		_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1
		hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
			if _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION ~= 1 then return end

			if _G.UIDROPDOWNMENU_OPEN_MENU and _G.UIDROPDOWNMENU_OPEN_MENU ~= frame and not _G.issecurevariable(_G.UIDROPDOWNMENU_OPEN_MENU, "displayMode") then
				_G.UIDROPDOWNMENU_OPEN_MENU = nil
				local t, f, prefix, i = _G, _G.issecurevariable, " \0", 1
				repeat
					i, t[prefix..i] = i + 1
				until f("UIDROPDOWNMENU_OPEN_MENU")
			end
		end)
	end
end

-- Fix blizz guild news hyperlink error
do
	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then return end

		local _GuildNewsButton_OnEnter = _G.GuildNewsButton_OnEnter
		function GuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end
			_GuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixGuildNews)
	end

	local function fixCommunitiesNews(event, addon)
		if addon ~= "Blizzard_Communities" then
			return
		end

		local _CommunitiesGuildNewsButton_OnEnter = _G.CommunitiesGuildNewsButton_OnEnter
		function CommunitiesGuildNewsButton_OnEnter(self)
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end
			_CommunitiesGuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixCommunitiesNews)
	end

	K:RegisterEvent("ADDON_LOADED", fixGuildNews)
	K:RegisterEvent("ADDON_LOADED", fixCommunitiesNews)
end

-- Fix TradeSkill Search
do
	hooksecurefunc("ChatEdit_InsertLink", function(text) -- Shift-Clicked
		-- Change From SearchBox:HasFocus to :IsShown Again
		if text and _G.TradeSkillFrame and _G.TradeSkillFrame:IsShown() then
			local spellId = string_match(text, "enchant:(%d+)")
			local spell = GetSpellInfo(spellId)
			local item = GetItemInfo(string_match(text, "item:(%d+)") or 0)
			local search = spell or item
			if not search then
				return
			end

			-- Search Needs To Be Lowercase For .SetRecipeItemNameFilter
			_G.TradeSkillFrame.SearchBox:SetText(search)

			-- Jump To The Recipe
			if spell then -- Can Only Select Recipes On The Learned Tab
				if PanelTemplates_GetSelectedTab(_G.TradeSkillFrame.RecipeList) == 1 then
					_G.TradeSkillFrame:SelectRecipe(tonumber(spellId))
				end
			elseif item then
				C_Timer_After(.2, function() -- Wait A Bit Or We Cant Select The Recipe Yet
					for _, v in pairs(_G.TradeSkillFrame.RecipeList.dataList) do
						if v.name == item then
							-- TradeSkillFrame.RecipeList:RefreshDisplay() -- Didnt Seem To Help
							_G.TradeSkillFrame:SelectRecipe(v.recipeID)
							return
						end
					end
				end)
			end
		end
	end)
end

do
	hooksecurefunc("ItemAnim_OnLoad", function(self)
		self:UnregisterEvent("ITEM_PUSH")
	end)

	local BlizzardBags = {
		_G.MainMenuBarBackpackButton,
		_G.CharacterBag0Slot,
		_G.CharacterBag1Slot,
		_G.CharacterBag2Slot,
		_G.CharacterBag3Slot,

		_G.StuffingFBag0Slot,
		_G.StuffingFBag1Slot,
		_G.StuffingFBag2Slot,
		_G.StuffingFBag3Slot,
	}

	for _, Button in pairs(BlizzardBags) do
		Button:UnregisterEvent("ITEM_PUSH") -- Gets Rid Of The Animation
	end
end

function Module:CreateBlizzBugFixes()
	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if _G.LFRBrowseFrame.timeToClear then
			_G.LFRBrowseFrame.timeToClear = nil
		end
	end)
end