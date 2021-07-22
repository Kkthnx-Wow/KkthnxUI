local K, C = unpack(select(2,...))

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

local _G = _G
local string_split = _G.string.split
local pairs = _G.pairs

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local CLOSE = _G.CLOSE

-- Starting words used in changelog.
-- Updated, Fixed, Added, Removed, Various.

local changelogData = {
	"Added back tank and healer icons for party/raid frames",
	"Added button forge addon skin",
	"Added check to ignore pixel border option if we are sizing the border",
	"Added code to scale the script errors frame",
	"Added default loot frame skin (people love the default loot frame i guess)",
	"Added domination rank module for tooltips",
	"Added maw buffs mover in raid, blizz loves this BelowMinimap shit",
	"Added new actionbar layout 4",
	"Added no portaits support for party frames",
	"Added options to turn off castbar icons",
	"Added safety checks with portaits function in unitframes",
	"Added wider transmog frame code, it loooooooooks so good",
	"Fixed and updated talking head frame skin",
	"Fixed chat ebitbox inset so it will not overlap character count",
	"Fixed checkquest slash command",
	"Fixed gold datatext throwing nil error for tooltip on bags",
	"Fixed left over code in actionbar code that was causing an error in hardmode",
	"Fixed nil error with raid index group numbers",
	"Removed font template api",
	"Removed map pin code as there are so many damn addons to handle it if needed",
	"Update announcements for interrupts, dispells and more",
	"Update pulse cooldown code to prevent error if trying to use it when it is off",
	"Updated all actionbar code and added global scaling for them",
	"Updated aurawatch auras list",
	"Updated cargbags library code",
	"Updated extra quest button lists and fixed ignore list",
	"Updated gui headers names to better flow",
	"Updated minimap ping code to not be in the middle of minimap",
	"Updated quest icon code for nameplates",
	"Updated quest notifier to be less intrusive when announcing",
	"Updated sim craft addon skin code and renabled it",
	"Updated skip cinematic code to be less intrusive (spacebar)",
	"Updated sort minimap button code",
	"Updated unitframe code for sizing health/power properly",
}

local changelogFrame
local function changelog()
	if changelogFrame then
		changelogFrame:Show()
		return
	end

	changelogFrame = CreateFrame("Frame", "KKUI_ChangeLog", UIParent)
	changelogFrame:SetPoint("CENTER")
	changelogFrame:SetFrameStrata("HIGH")
	changelogFrame:CreateBorder()

	K.CreateFontString(changelogFrame, 30, K.Title, "", true, "TOPLEFT", 10, 28)
	K.CreateFontString(changelogFrame, 14, K.Version, "", true, "TOPLEFT", 146, 16)
	K.CreateFontString(changelogFrame, 16, "Changelog", "", true, "TOP", 0, -10)
	K.CreateMoverFrame(changelogFrame)

	local kkthnxLogo = changelogFrame:CreateTexture(nil, "OVERLAY")
	kkthnxLogo:SetSize(512, 256)
	kkthnxLogo:SetBlendMode("ADD")
	kkthnxLogo:SetAlpha(0.06)
	kkthnxLogo:SetTexture(C["Media"].Textures.LogoTexture)
	kkthnxLogo:SetPoint("CENTER", changelogFrame, "CENTER", 0, 0)

	local leftLine = CreateFrame("Frame", nil, changelogFrame)
	leftLine:SetPoint("TOP", -50, -35)
	K.CreateGF(leftLine, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	leftLine:SetFrameStrata("HIGH")

	local rightLine = CreateFrame("Frame", nil, changelogFrame)
	rightLine:SetPoint("TOP", 50, -35)
	K.CreateGF(rightLine, 100, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	rightLine:SetFrameStrata("HIGH")

	local offset = 0
	for _, t in pairs(changelogData) do
		K.CreateFontString(changelogFrame, 12, K.InfoColor.."• |r"..t, "", false, "TOPLEFT", 14, -(50 + offset))
		offset = offset + 20
	end
	changelogFrame:SetSize(520, 60 + offset)

	local close = CreateFrame("Button", nil, changelogFrame)
	close:SkinButton()
	close:SetSize(changelogFrame:GetWidth(), 24)
	close:SetScript("OnClick", function()
		changelogFrame:Hide()
	end)
	close:SetFrameLevel(changelogFrame:GetFrameLevel() + 1)
	close:SetPoint("TOPLEFT", changelogFrame, "BOTTOMLEFT", 0, -6)

	close.Text = close:CreateFontString(nil, "OVERLAY")
	close.Text:SetFontObject(KkthnxUIFont)
	close.Text:SetFont(select(1, close.Text:GetFont()), 14, select(3, close.Text:GetFont()))
	close.Text:SetPoint("CENTER", close, 0, -1)
	close.Text:SetTextColor(1, 0, 0)
	close.Text:SetText(CLOSE)
end

local function compareToShow(event)
	if _G.KKUI_Tutorial then
		return
	end

	local old1, old2 = string_split(".", KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog.Version or "")
	local cur1, cur2 = string_split(".", K.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		KkthnxUIDB.Variables[K.Realm][K.Name].ChangeLog.Version = K.Version
	end
	K:UnregisterEvent(event, compareToShow)
end
K:RegisterEvent("PLAYER_ENTERING_WORLD", compareToShow)

_G.SlashCmdList["KKUI_CHANGELOG"] = changelog
SLASH_KKUI_CHANGELOG1 = "/kcl"