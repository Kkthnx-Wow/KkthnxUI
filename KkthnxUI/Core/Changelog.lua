local K = unpack(select(2,...))
local Module = K:NewModule("Changelog")

local ChangeLogData = {
	"Changes:",
	"• Refactored Raidframes",
	"• Fixed taint in actionbars",
	"• Refactored Nameplates",
	"• Various code cleanups",
	"• Performance improvements",
	"• Various libraries updated",
	"• Stack splitter added to bags",

	" ",
	--"• This update consists of 34 commits, 71,060 additions and 6,656 deletions",

    -- Important Notes We Want The User To Know!
    " ",
    "Notes:",
    "• If you are enjoying the UI do not forget to drop by our DISCORD!",
    " ",
    "Social URLs:",
    "• |cff7289DADiscord:|r https://discord.gg/YUmxqQm",
    "• |cff3b5998Facebook:|r https://www.facebook.com/kkthnxui",
    "• |cff1da1f2Twitter:|r https://twitter.com/kkthnxui",
}

local URL_PATTERNS = {
	"^(%a[%w+.-]+://%S+)",
	"%f[%S](%a[%w+.-]+://%S+)",
	"^(www%.[-%w_%%]+%.(%a%a+))",
	"%f[%S](www%.[-%w_%%]+%.(%a%a+))",
	"(%S+@[%w_.-%%]+%.(%a%a+))",
}

local function formatURL(url)
	url = "|cFFFFFFFF[|Hurl:"..url.."|h"..url.."|h]|r "
	return url
end

local function ModifiedString(string)
	local count = string.find(string, ":")
	local newString = string

	if count then
		local prefix = string.sub(string, 0, count)
		local suffix = string.sub(string, count + 1)
		local subHeader = string.find(string, "•")

		if subHeader then
			newString = tostring("|cFFFFFF00"..prefix.."|r"..suffix)
		else
			newString = tostring("|cff4488ff"..prefix.."|r"..suffix)
		end
	end

	for pattern in gmatch(string, "('.*')") do
		newString = newString:gsub(pattern, "|cff4488ff"..pattern:gsub("'", "").."|r")
	end

	-- Find URLs
	for _, v in pairs(URL_PATTERNS) do
		if string.find(string, v) then
			newString = gsub(string, v, formatURL("%1"))
		end
	end

	return newString
end

local function GetChangeLogInfo(i)
	for line, info in pairs(ChangeLogData) do
		if line == i then
			return info
		end
	end
end

function Module:CreateChangelog()
	local frame = CreateFrame("Frame", "KkthnxUIChangeLog", UIParent)
	frame:SetPoint("TOP", UIParent, "TOP", 0, -108)
	frame:SetSize(480, 420)
	frame:CreateBorder()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetClampedToScreen(true)

	local title = CreateFrame("Button", nil, frame)
	title:SkinButton()
	title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 6)
	title:SetSize(480, 26)
	title:SetScript("OnClick", function()
		PlaySound(11803)
	end)
	title.title = "I dare you to click me!!!"
	K.AddTooltip(title, "ANCHOR_TOP")

	title.text = title:CreateFontString(nil, "OVERLAY")
	title.text:FontTemplate(nil, 20, "")
	title.text:SetPoint("CENTER", title, 0, 0)
	title.text:SetText(K.Title.." ChangeLog v"..string.format("|cff4488ff%s|r", K.Version))

	frame.close = CreateFrame("Button", nil, frame)
	frame.close:SkinButton()
	frame.close:SetSize(480, 24)
	frame.close:SetScript("OnClick", function()
		frame:Hide()
	end)
	frame.close:SetFrameLevel(frame:GetFrameLevel() + 1)
	frame.close:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -6)

	frame.close.Text = frame.close:CreateFontString(nil, "OVERLAY")
	frame.close.Text:FontTemplate(nil, 16, "")
	frame.close.Text:SetPoint("CENTER", frame.close)
	frame.close.Text:SetTextColor(1, 0, 0)
	frame.close.Text:SetText("|cffFF0000"..CLOSE.."|r")

	local offset = 4
	for i = 1, #ChangeLogData do
		local button = CreateFrame("Frame", "Button"..i, frame)
		button:SetSize(375, 16)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -offset)

		if i <= #ChangeLogData then
			local string, isURL = ModifiedString(GetChangeLogInfo(i))

			button.Text = button:CreateFontString(nil, "OVERLAY")
			button.Text:FontTemplate(nil, 12, "")
			button.Text:SetPoint("CENTER")
			button.Text:SetPoint("LEFT", 0, 0)
			button.Text:SetText(string)
			button.Text:SetWordWrap(false)
		end

		offset = offset + 16
	end
end

function Module:ToggleChangeLog()
	if not KkthnxUIChangeLog then
		self:CreateChangelog()
	end
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF or 857)

	local fadeInfo = {}
	fadeInfo.mode = "IN"
	fadeInfo.timeToFade = 0.5
	fadeInfo.startAlpha = 0
	fadeInfo.endAlpha = 1
	K.UIFrameFade(KkthnxUIChangeLog, fadeInfo)
end

function Module:CheckVersion()
	if not KkthnxUIData[K.Realm][K.Name]["Version"] or (KkthnxUIData[K.Realm][K.Name]["Version"] and KkthnxUIData[K.Realm][K.Name]["Version"] ~= K.Version) then
		KkthnxUIData[K.Realm][K.Name]["Version"] = K.Version
		Module:ToggleChangeLog()
	end
end

function Module:OnEnable()
	K.Delay(6, function()
		Module:CheckVersion()
	end)
end