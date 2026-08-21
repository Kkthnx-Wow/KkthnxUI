--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/MicroMenu.lua
	Purpose:
		A compact, movable micro menu. The Blizzard micro buttons (character,
		spellbook, collections, and so on) are reparented onto our own bar, sized
		to a row, and given our border. An optional mouseover fade keeps it out of
		the way. Retail only for now.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("MicroMenu")

local _G = _G
local pcall = pcall
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown

-- Stable global names for the retail micro buttons, in display order. Missing ones
-- are skipped, so this stays safe as Blizzard adds or removes buttons.
local BUTTONS = {
	"CharacterMicroButton",
	"PlayerSpellsMicroButton",
	"ProfessionMicroButton",
	"AchievementMicroButton",
	"QuestLogMicroButton",
	"GuildMicroButton",
	"LFDMicroButton",
	"CollectionsMicroButton",
	"EJMicroButton",
	"HousingMicroButton",
	"MainMenuMicroButton",
	"StoreMicroButton",
	"HelpMicroButton",
}

local bar

-- Keep the hover highlight a subtle wash. Blizzard re-sets an opaque highlight
-- atlas on mouseover (which is what blanked the icon), so this is re-applied from
-- a SetHighlightAtlas hook.
local function FixHighlight(btn)
	local hl = btn:GetHighlightTexture()
	if hl then
		hl:SetColorTexture(1, 1, 1, 0.15)
		hl:SetAllPoints(btn)
	end
end

-- Micro button art is an atlas with transparent padding, so it sits small inside
-- our box. Stretch each state texture to fill and crop the padding. The character
-- button draws a separate portrait, handled on its own. Blizzard resets these on
-- UpdateMicroButtons, so this is re-applied from the hook.
local function CropButton(btn, name)
	local function fill(tex)
		if tex then
			tex:ClearAllPoints()
			tex:SetAllPoints(btn)
			tex:SetTexCoord(0.18, 0.82, 0.2, 0.8)
		end
	end
	fill(btn:GetNormalTexture())
	fill(btn:GetPushedTexture())
	if btn.GetDisabledTexture then
		fill(btn:GetDisabledTexture())
	end

	if name == "CharacterMicroButton" then
		local portrait = _G.MicroButtonPortrait or btn.Portrait
		if portrait then
			portrait:ClearAllPoints()
			portrait:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
			portrait:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)
			portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		end
		if btn.PortraitMask then
			btn.PortraitMask:Hide()
		end
	end

	FixHighlight(btn)
end

local function ReapplyIcons()
	for _, name in ipairs(BUTTONS) do
		local btn = _G[name]
		if btn and btn.__kkuiMicro then
			CropButton(btn, name)
		end
	end
end

-- Lay the reparented buttons into a single row and size the bar to fit.
local function Layout()
	if not bar then
		return
	end
	local cfg = C.MicroMenu
	local h = cfg.ButtonSize
	-- Micro buttons keep their portrait aspect so the icons do not distort.
	local w = K.Round(h * 0.82)
	local space = cfg.Spacing
	local x, count = 0, 0

	for _, name in ipairs(BUTTONS) do
		local btn = _G[name]
		-- Skip buttons the client currently hides, so they leave no blank gap.
		if btn and btn.__kkuiMicro and btn:IsShown() then
			btn:ClearAllPoints()
			btn:SetSize(w, h)
			btn:SetPoint("LEFT", bar, "LEFT", x, 0)
			x = x + w + space
			count = count + 1
		end
	end

	bar:SetSize(math.max(1, x - space), h)
	return count
end

local function Skin(btn, name)
	if btn.__kkuiMicro then
		return
	end
	btn.__kkuiMicro = true

	-- Reparent out of the Blizzard container so its layout no longer moves them.
	btn:SetParent(bar)
	btn:SetHitRectInsets(0, 0, 0, 0)

	-- Clear the loud background / flash art so only the icon and our border show.
	if btn.Background then
		btn.Background:SetTexture()
	end
	if btn.PushedBackground then
		btn.PushedBackground:SetTexture()
	end
	if btn.FlashContent then
		btn.FlashContent:SetTexture()
	end
	if btn.Flash then
		btn.Flash:SetTexture()
	end
	if btn.FlashBorder then
		btn.FlashBorder:SetAlpha(0)
	end

	K.CreateBackground(btn, 0.06, 0.06, 0.06, 0.9)
	CropButton(btn, name)

	-- Blizzard re-applies an opaque highlight atlas on hover, override it so the
	-- icon is not blanked out.
	if btn.SetHighlightAtlas then
		hooksecurefunc(btn, "SetHighlightAtlas", function(self)
			FixHighlight(self)
		end)
	end

	if not btn.KKUI_Border then
		K.CreateBorder(btn)
	end
end

function Module:Setup()
	if self.setupDone then
		return
	end
	self.setupDone = true

	bar = CreateFrame("Frame", "KKUI_MicroMenu", UIParent)
	bar:SetSize(200, C.MicroMenu.ButtonSize)

	for _, name in ipairs(BUTTONS) do
		local btn = _G[name]
		if btn then
			pcall(Skin, btn, name)
		end
	end

	Layout()
	K.CreateMover(bar, "MicroMenu", L["Micro Menu"], { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 4 }, bar:GetWidth(), bar:GetHeight())

	-- Blizzard relays out the micro menu on many events. Reparenting takes the
	-- buttons out of that flow, but re-apply on its update just in case.
	if _G.UpdateMicroButtons then
		hooksecurefunc("UpdateMicroButtons", function()
			ReapplyIcons()
			if not InCombatLockdown() then
				Layout()
			end
		end)
	end

	-- Late-set atlases (some buttons finish their art after login) get one more pass.
	self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
		ReapplyIcons()
		Layout()
	end)
end

function Module:OnEnable()
	if not C.MicroMenu.Enable then
		return
	end
	self:Setup()
end
