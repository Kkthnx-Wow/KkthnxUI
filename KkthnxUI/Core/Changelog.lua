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
	"Added focus size and power options, no portrait support"..K.SystemColor.." @AmiraVera",
	"Added focustarget size and power options, no portrait support"..K.SystemColor.." @AmiraVera",
	"Added lockui slash command"..K.SystemColor.." @krevan88",
	"Added new maw threat bar instead of the ugly texture",
	"Added no portrait option for player/target"..K.SystemColor.." @AmiraVera",
	"Added pet/tot size and powerbar options + no portrait support"..K.SystemColor.." @AmiraVera",
	"Added player/target power bar option"..K.SystemColor.." @AmiraVera",
	"Added player/target unitframe size options"..K.SystemColor.." @AmiraVera",
	"Added shorter enchant strings. Thanks (ElvUI)",
	"Fixed GuildBest nil value",
	"Fixed debuffs too big on unitframes issue #48",
	"Fixed disenchant module blocking clicks"..K.SystemColor.." @AmiraVera",
	"Fixed error with having swingbar enabled and castbars disabled",
	"Fixed gcd health overlay"..K.SystemColor.." @AmiraVera",
	"Fixed nil error with coords",
	"Fixed outdated currency values on characters with module disabled"..K.SystemColor.." @AmiraVera",
	"Fixed player/target auras not being visible when power bar disabled"..K.SystemColor.." @AmiraVera",
	"Fixed start nil value for PCD",
	"Fixed tooltip nil value with other addons",
	"Updated aurawatch auras",
	"Updated azerite border style thickness"..K.SystemColor.." @AmiraVera",
	"Updated durability frame position to be more visible.",
	"Updated french locales"..K.SystemColor.." @Lionceaudor",
	"Updated mapreveal locations to inclue torgast",
	"Updated nameplate auras",
	"Updated player/target nametag with no portraits",
	"Updated raid debuffs",
	K.SystemColor.." @AmiraVera|r thinks spiders are cute??? KILL IT WITH FIRE!",
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
	K.CreateFontString(changelogFrame, 14, K.Version, "", true, "TOPLEFT", 140, 16)
	K.CreateFontString(changelogFrame, 16, "Changelog", "", true, "TOP", 0, -10)
	K.CreateMoverFrame(changelogFrame)

	local kkthnxLogo = changelogFrame:CreateTexture(nil, "OVERLAY")
	kkthnxLogo:SetSize(512, 256)
	kkthnxLogo:SetBlendMode("ADD")
	kkthnxLogo:SetAlpha(0.06)
	kkthnxLogo:SetTexture(C["Media"].Logo)
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
	for n, t in pairs(changelogData) do
		K.CreateFontString(changelogFrame, 12, K.InfoColor..n..": |r"..t, "", false, "TOPLEFT", 15, -(50 + offset))
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
	close.Text:FontTemplate(nil, 14, "")
	close.Text:SetPoint("CENTER", close)
	close.Text:SetTextColor(1, 0, 0)
	close.Text:SetText(CLOSE)
end

local function compareToShow(event)
	if _G.KKUI_Tutorial then
		return
	end

	local old1, old2 = string_split(".", KkthnxUIData[K.Realm][K.Name].ChangeLog.Version or "")
	local cur1, cur2 = string_split(".", K.Version)
	if old1 ~= cur1 or old2 ~= cur2 then
		changelog()
		KkthnxUIData[K.Realm][K.Name].ChangeLog.Version = K.Version
	end
	K:UnregisterEvent(event, compareToShow)
end
K:RegisterEvent("PLAYER_ENTERING_WORLD", compareToShow)

_G.SlashCmdList["KKUI_CHANGELOG"] = changelog
SLASH_KKUI_CHANGELOG1 = "/kcl"