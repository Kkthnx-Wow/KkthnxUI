--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Installer/Core.lua
	Purpose:
		A first-run setup wizard. Five steps walk a new user through the addon,
		apply the chat and frame layout, and opt into a few system tweaks, then
		reload. Nothing is changed until the user clicks an apply button, so the
		defaults stay non-destructive. Completion is stored per install version in
		KkthnxUIDB, so it only pops up once. Re-run any time with /kk install.
		Built with our own border, gradient, and palette. Retail-safe.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:NewModule("Installer")

local ipairs = ipairs
local pairs = pairs
local pcall = pcall
local max = math.max
local min = math.min
local tinsert = table.insert
local C_Timer = C_Timer
local CreateFrame = CreateFrame

-- Ready-check tick used for the "Applied" confirmations.
local CHECK = "|TInterface\\RaidFrame\\ReadyCheck-Ready:14:14|t"
local SetCVar = SetCVar
local InCombatLockdown = InCombatLockdown
local ReloadUI = ReloadUI

local accent = K.Colors.accent
local gold = K.Colors.gold
local silver = K.Colors.silver

-- System tweaks offered on the CVars step. Each is opt-in via its checkbox.
local CVAR_TWEAKS = {
	{ key = "autoloot", cvar = "autoLootDefault", value = 1, label = L["Fast Auto-Loot"] },
	{ key = "nameplateColors", cvar = "ShowClassColorInNameplate", value = 1, label = L["Class Colors on Nameplates"] },
	{ key = "camera", cvar = "cameraDistanceMaxZoomFactor", value = 2.6, label = L["Max Camera Distance"] },
	{ key = "combatText", cvar = "floatingCombatTextCombatDamage", value = 1, label = L["Floating Combat Text"] },
	{ key = "questObjectives", cvar = "autoQuestProgress", value = 1, label = L["Auto Quest Tracking"] },
}

-- ---------------------------------------------------------------------------
-- Small skinned widgets
-- ---------------------------------------------------------------------------

local function Header(parent, size, text, color)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(fs, size, K.FontOutlineStyle())
	fs:SetText(text)
	if color then
		fs:SetTextColor(color[1], color[2], color[3])
	end
	return fs
end

local function Body(parent, text)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(fs, 12, K.FontOutlineStyle())
	fs:SetJustifyH("LEFT")
	fs:SetJustifyV("TOP")
	fs:SetTextColor(silver[1], silver[2], silver[3])
	fs:SetText(text)
	return fs
end

local function Button(parent, width, text, onClick)
	local b = CreateFrame("Button", nil, parent)
	b:SetSize(width, 24)
	b.Text = b:CreateFontString(nil, "OVERLAY")
	K.SetFont(b.Text, 13, K.FontOutlineStyle())
	b.Text:SetPoint("CENTER")
	b.Text:SetText(text)
	b:SetScript("OnClick", onClick)
	K.SkinButton(b)
	return b
end

local function Check(parent, text, checked, size)
	local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
	cb:SetSize(size or 24, size or 24)
	cb:SetChecked(checked)
	K.SkinCheckBox(cb)
	local label = cb:CreateFontString(nil, "OVERLAY")
	K.SetFont(label, 12, K.FontOutlineStyle())
	label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
	label:SetTextColor(silver[1], silver[2], silver[3])
	label:SetText(text)
	return cb
end

-- ---------------------------------------------------------------------------
-- Steps
-- ---------------------------------------------------------------------------

local STEPS = {
	{
		name = L["Welcome"],
		build = function(_, panel)
			local logo = panel:CreateTexture(nil, "ARTWORK")
			logo:SetSize(48, 48)
			logo:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)
			logo:SetTexture(K.MediaFolder .. "KkthnxUI_Spell_Icon.blp")
			logo:SetTexCoord(0.08, 0.92, 0.08, 0.92)

			local title = Header(panel, 18, "KkthnxUI", accent)
			title:SetPoint("LEFT", logo, "RIGHT", 10, 8)
			local ver = Header(panel, 11, K.Version, silver)
			ver:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -2)

			local body = Body(panel, L["Welcome, adventurer! KkthnxUI streamlines your interface with clean unit frames, action bars, bags, nameplates, and more. This short setup applies the layout and a few tweaks. Nothing changes until you click an apply button, so take your time."])
			body:SetPoint("TOPLEFT", logo, "BOTTOMLEFT", 0, -16)
			body:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
		end,
	},
	{
		name = L["Features"],
		build = function(_, panel)
			local title = Header(panel, 15, L["What You Get"], accent)
			title:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

			local body = Body(panel, L["|cffF3B043Unit Frames & Nameplates|r  Clean, class-coloured frames with threat, auras, and class resources.\n\n|cffF3B043Action Bars|r  Eight paged bars, pet, stance, and possess bars, all movable.\n\n|cffF3B043Bags|r  An all-in-one, auto-categorised bag and bank.\n\n|cffF3B043Automation & Tools|r  Auto-quest, decline duels, a movable minimap, and a full options panel."])
			body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
			body:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
		end,
	},
	{
		name = L["Chat & Layout"],
		build = function(module, panel)
			local title = Header(panel, 15, L["Chat & Layout"], accent)
			title:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

			local body = Body(panel, L["Apply the chat setup and move every frame to its default position. You can always adjust things later with the options panel and the mover."])
			body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
			body:SetPoint("RIGHT", panel, "RIGHT", 0, 0)

			local chatDone = Header(panel, 12, "", gold)
			local chat = Button(panel, 150, L["Apply Chat Setup"], function()
				K:SetConfig({ "Chat", "Enable" }, true)
				if K.InstallChat then
					K.InstallChat()
				end
				chatDone:SetText(CHECK .. " |cff4EBD87" .. L["Applied"] .. "|r")
			end)
			chat:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, -20)
			chatDone:SetPoint("LEFT", chat, "RIGHT", 10, 0)

			local layoutDone = Header(panel, 12, "", gold)
			local layout = Button(panel, 150, L["Apply UI Layout"], function()
				K.ResetMovers()
				layoutDone:SetText(CHECK .. " |cff4EBD87" .. L["Applied"] .. "|r")
			end)
			layout:SetPoint("TOPLEFT", chat, "BOTTOMLEFT", 0, -12)
			layoutDone:SetPoint("LEFT", layout, "RIGHT", 10, 0)
		end,
	},
	{
		name = L["System Tweaks"],
		build = function(module, panel)
			local title = Header(panel, 15, L["System Tweaks"], accent)
			title:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

			local body = Body(panel, L["Tick the console tweaks you want, then apply. These are standard settings, safe to change."])
			body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
			body:SetPoint("RIGHT", panel, "RIGHT", 0, 0)

			-- Rows are one checkbox tall with the UI's standard 6px gap between them.
			panel.checks = {}
			local BOX = 24
			local GAP = 6
			local top = -14
			for i, tweak in ipairs(CVAR_TWEAKS) do
				local cb = Check(panel, tweak.label, true, BOX)
				cb:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, top - (i - 1) * (BOX + GAP))
				cb.tweak = tweak
				panel.checks[i] = cb
			end

			local done = Header(panel, 12, "", gold)
			local apply = Button(panel, 170, L["Apply Selected Tweaks"], function()
				if InCombatLockdown() then
					return
				end
				for _, cb in ipairs(panel.checks) do
					if cb:GetChecked() then
						pcall(SetCVar, cb.tweak.cvar, cb.tweak.value)
					end
				end
				done:SetText(CHECK .. " |cff4EBD87" .. L["Applied"] .. "|r")
			end)
			apply:SetPoint("TOPLEFT", body, "BOTTOMLEFT", 0, top - #CVAR_TWEAKS * (BOX + GAP) - 8)
			done:SetPoint("LEFT", apply, "RIGHT", 10, 0)
		end,
	},
	{
		name = L["Finish"],
		build = function(_, panel)
			local title = Header(panel, 15, L["All Set!"], accent)
			title:SetPoint("TOPLEFT", panel, "TOPLEFT", 0, 0)

			local body = Body(panel, L["You are ready to go. Reload the UI to finish. Type |cff5C8BCF/kk|r any time to open the options, |cff5C8BCF/kk move|r to reposition frames, and |cff5C8BCF/kk install|r to run this wizard again."])
			body:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -12)
			body:SetPoint("RIGHT", panel, "RIGHT", 0, 0)
		end,
	},
}

-- ---------------------------------------------------------------------------
-- Frame + navigation
-- ---------------------------------------------------------------------------

local MARGIN = 16
local SIDEBAR_W = 150
local NAV_H = 60

function Module:GetPanel(index)
	if self.panels[index] then
		return self.panels[index]
	end
	local panel = CreateFrame("Frame", nil, self.content)
	panel:SetPoint("TOPLEFT", self.content, "TOPLEFT", MARGIN, -MARGIN)
	panel:SetPoint("BOTTOMRIGHT", self.content, "BOTTOMRIGHT", -MARGIN, MARGIN)
	STEPS[index].build(self, panel)
	self.panels[index] = panel
	return panel
end

function Module:ShowStep(index)
	index = max(1, min(#STEPS, index))
	self.current = index

	for i in pairs(self.panels) do
		self.panels[i]:Hide()
	end
	self:GetPanel(index):Show()

	-- Sidebar highlight.
	for i, tab in ipairs(self.frame.tabs) do
		local on = i == index
		tab.Text:SetTextColor(on and accent[1] or silver[1], on and accent[2] or silver[2], on and accent[3] or silver[3])
		tab.Active:SetShown(on)
	end

	-- Progress bar.
	self.frame.progress:SetValue(index)
	self.frame.progress.Label:SetFormattedText("%d / %d", index, #STEPS)

	-- Nav buttons.
	self.frame.back:SetEnabled(index > 1)
	self.frame.back:SetAlpha(index > 1 and 1 or 0.4)
	self.frame.next.Text:SetText(index == #STEPS and L["Finish & Reload"] or L["Next"])
end

function Module:Open()
	if not self.frame then
		self:BuildFrame()
	end
	self.frame:Show()
	self:ShowStep(self.current or 1)
end

function Module:Close()
	if self.frame then
		self.frame:Hide()
	end
end

function Module:Finish()
	self:MarkInstalled()
	ReloadUI()
end

function Module:BuildFrame()
	local f = CreateFrame("Frame", "KKUI_Installer", UIParent)
	f:SetSize(600, 440)
	f:SetPoint("CENTER")
	f:SetFrameStrata("HIGH")
	f:EnableMouse(true)
	f:SetMovable(true)
	f:RegisterForDrag("LeftButton")
	f:SetScript("OnDragStart", f.StartMoving)
	f:SetScript("OnDragStop", f.StopMovingOrSizing)
	K.CreateGradientBackground(f)
	K.CreateBorder(f)
	self.frame = f
	self.panels = {}

	local title = Header(f, 17, "|cff5C8BCFKkthnxUI|r  " .. L["Setup"], nil)
	title:SetPoint("TOP", f, "TOP", 0, -14)

	local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", f, "TOPRIGHT", -6, -6)
	close:SetScript("OnClick", function()
		Module:Close()
	end)
	K.SkinCloseButton(close)

	-- Sidebar with the five steps.
	local nav = CreateFrame("Frame", nil, f)
	nav:SetPoint("TOPLEFT", f, "TOPLEFT", 12, -44)
	nav:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 12, NAV_H)
	nav:SetWidth(SIDEBAR_W)
	K.CreateBackground(nav, K.Colors.panel[1], K.Colors.panel[2], K.Colors.panel[3], 0.85)
	K.CreateBorder(nav)

	f.tabs = {}
	local y = -10
	for i, step in ipairs(STEPS) do
		local tab = CreateFrame("Button", nil, nav)
		tab:SetSize(SIDEBAR_W - 12, 30)
		tab:SetPoint("TOPLEFT", nav, "TOPLEFT", 6, y)
		tab.Active = tab:CreateTexture(nil, "BACKGROUND")
		tab.Active:SetAllPoints()
		tab.Active:SetColorTexture(accent[1], accent[2], accent[3], 0.18)
		tab.Active:Hide()
		tab.Text = tab:CreateFontString(nil, "OVERLAY")
		K.SetFont(tab.Text, 12, K.FontOutlineStyle())
		tab.Text:SetPoint("LEFT", tab, "LEFT", 8, 0)
		tab.Text:SetText(i .. ".  " .. step.name)
		tab:SetScript("OnClick", function()
			Module:ShowStep(i)
		end)
		f.tabs[i] = tab
		y = y - 34
	end

	-- Content area to the right of the sidebar.
	local content = CreateFrame("Frame", nil, f)
	content:SetPoint("TOPLEFT", nav, "TOPRIGHT", 10, 0)
	content:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -12, NAV_H)
	K.CreateBackground(content, K.Colors.panel[1], K.Colors.panel[2], K.Colors.panel[3], 0.85)
	K.CreateBorder(content)
	self.content = content

	-- Back / Next along the bottom right (built first so the progress bar can
	-- anchor to their left edge and never overlap them).
	f.next = Button(f, 130, L["Next"], function()
		if Module.current >= #STEPS then
			Module:Finish()
		else
			Module:ShowStep(Module.current + 1)
		end
	end)
	f.next:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -16, 16)

	f.back = Button(f, 90, L["Back"], function()
		Module:ShowStep(Module.current - 1)
	end)
	f.back:SetPoint("RIGHT", f.next, "LEFT", -6, 0)

	-- Progress bar along the bottom, using the UI's configured statusbar texture.
	local progress = CreateFrame("StatusBar", nil, f)
	progress:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 16, 20)
	progress:SetPoint("RIGHT", f.back, "LEFT", -10, 0)
	progress:SetHeight(20)
	progress:SetStatusBarTexture(K.GetTexture(C.Unitframe and C.Unitframe.Texture or "KkthnxUI"))
	progress:SetStatusBarColor(accent[1], accent[2], accent[3], 0.9)
	progress:SetMinMaxValues(0, #STEPS)
	progress:SetValue(1)
	K.CreateBackground(progress, 0.1, 0.1, 0.1, 0.8)
	K.CreateBorder(progress)
	progress.Label = progress:CreateFontString(nil, "OVERLAY")
	K.SetFont(progress.Label, 11, K.FontOutlineStyle())
	progress.Label:SetPoint("CENTER")
	f.progress = progress

	tinsert(UISpecialFrames, "KKUI_Installer")
end

-- ---------------------------------------------------------------------------
-- Completion state + lifecycle
-- ---------------------------------------------------------------------------

function Module:IsInstalled()
	return KkthnxUIDB and KkthnxUIDB.installedVersion == K.Version
end

function Module:MarkInstalled()
	KkthnxUIDB = KkthnxUIDB or {}
	KkthnxUIDB.installedVersion = K.Version
end

function Module:OnEnable()
	-- Expose for the slash command.
	K.OpenInstaller = function()
		Module:Open()
	end

	if not self:IsInstalled() then
		-- Let the login settle, then greet a first-time user.
		C_Timer.After(3, function()
			if not Module:IsInstalled() then
				Module:Open()
			end
		end)
	end
end
