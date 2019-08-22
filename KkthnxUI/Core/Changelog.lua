local K = unpack(select(2,...))
local Module = K:NewModule("Changelog", "AceTimer-3.0")

local ChangeLogData = {
	"Changes:",
	"• Released v9.03.",
	"• Rewrote a lot of parts of the UI.",
	"• Changed how Modules are loaded.",
	"• Add chat tab color and fix movers with align/grid command.",
	"• More style to key binds frame and add a check too it.",
	"• I just like my code and files like this.",
	"• Features and fixes and updates.",
	"• Add in some checks for nameplate elements.",
	"• Typo from `e2d8eab`",
	"• You just can't make your mind up Mr. Kkthnx.",
	"• Revert part of `1decf5e`",
	"• I was forced to add these 3 random guys as a SPECIAL THANKS.",
	"• This should fix shit falling behind our awesome borders.",
	"• We will have justice!",
    -- Important Notes We Want The User To Know!
	" ",
	"Notes:",
	"• If you are enjoying the UI do not forget to drop by our DISCORD!",
	" ",
	"Social URLs:",
	"• |cff7289DADiscord:|r https://discordapp.com/invite/mKKySTY",
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
	frame:ClearAllPoints() -- Do we need this?
	if KkthnxUIData and KkthnxUIData[_G.GetRealmName()][_G.UnitName("player")].InstallComplete then
		frame:SetPoint("CENTER", UIParent, "CENTER")
	elseif K.Install and K.Install.Description then
		frame:SetPoint("BOTTOM", K.Install.Description , "TOP", 0, 32)
	else
		frame:SetPoint("TOP", UIParent, "TOP", 0, -108)
	end
	frame:SetSize(480, 420)
	frame:CreateBorder()
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetClampedToScreen(true)

	local title = CreateFrame("Frame", nil, frame)
	title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 6)
	title:SetSize(480, 30)
	title:CreateBorder()

	title.text = title:CreateFontString(nil, "OVERLAY")
	title.text:FontTemplate(nil, 20, "")
	title.text:SetPoint("CENTER", title, 0, 0)
	title.text:SetText(K.Title.." ChangeLog v"..string.format("|cff4488ff%s|r", K.Version))

	frame.close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	frame.close:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
	frame.close:SetText(CLOSE)
	frame.close:SetSize(100, 22)
	frame.close:SetScript("OnClick", function()
		frame:Hide()
	end)
	frame.close:StripTextures()
	frame.close:SkinButton()
	frame.close:Disable()

	frame.countdown = frame.close:CreateFontString(nil, "OVERLAY")
	frame.countdown:FontTemplate(nil, 12, "")
	frame.countdown:SetPoint("LEFT", frame.close.Text, "RIGHT", 3, 0)
	frame.countdown:SetTextColor(DISABLED_FONT_COLOR:GetRGB())

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

function Module:CountDown()
	self.time = self.time - 1
	if self.time == 0 then
		KkthnxUIChangeLog.countdown:SetText("")
		KkthnxUIChangeLog.close:Enable()
		self:CancelAllTimers()
	else
		KkthnxUIChangeLog.countdown:SetText(format("(%s)", self.time))
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

	self.time = 6
	self:CancelAllTimers()
	Module:CountDown()
	self:ScheduleRepeatingTimer("CountDown", 1)
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