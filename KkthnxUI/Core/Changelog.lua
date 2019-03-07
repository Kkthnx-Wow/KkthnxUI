local K = unpack(select(2,...))
local Module = K:NewModule("Changelog", "AceEvent-3.0", "AceTimer-3.0")

local _G = _G
local format, gmatch, gsub, find, sub = string.format, string.gmatch, string.gsub, string.find, string.sub
local pairs, tostring = pairs, tostring

local CreateFrame = _G.CreateFrame
local SOUNDKIT = _G.SOUNDKIT
local PlaySound = _G.PlaySound
local CLOSE = _G.CLOSE

local ChangeLogData = {
	"Changes:",
	"• Bring in changes from @Rav99 and Updates to code and formatting.",
	"• Cleanup 3 Files in Modules.",
	"• Cleanup AFKCam.",
	"• Cleanup old leftover setting for actionbars",
	"• Fix Minimap always pining without it being left mouse button.",
	"• It is 2019 I think and little pimp for AfkCam.",
	"• Merge pull request #3 from Rav99/master.",
	"• Removed modules that I do not care to maintain anymore",
	"• This one is for you @Rav99.",
	"• Cleanup RaidBuffs",
	"• Merge translation fixes from @RoseFarts",
    -- Important Notes We Want The User To Know!
	" ",
	"Notes:",
	"• We changed our main font to support more font characters!",
}

local function ModifiedString(string)
	local count = find(string, ":")
	local newString = string

	if count then
		local prefix = sub(string, 0, count)
		local suffix = sub(string, count + 1)
		local subHeader = find(string, "•")

		if subHeader then
			newString = tostring("|cFFFFFF00"..prefix.."|r"..suffix)
		else
			newString = tostring("|cff4488ff"..prefix.."|r"..suffix)
		end
	end

	for pattern in gmatch(string, "('.*')") do
		newString = newString:gsub(pattern, "|cFFFF8800"..pattern:gsub("'", "").."|r")
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
	frame:SetSize(444, 300)
	frame:CreateBorder()

	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetClampedToScreen(true)

	local title = CreateFrame("Frame", nil, frame)
	title:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 6)
	title:SetSize(444, 20)
	title:CreateBorder()

	title.text = title:CreateFontString(nil, "OVERLAY")
	title.text:FontTemplate(nil, 15, "")
	title.text:SetPoint("CENTER", title, 0, -1)
	title.text:SetText(K.Title.." ChangeLog v"..format("|cff4488ff%s|r", K.Version))

	local close = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	close:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
	close:SetText(CLOSE)
	close:SetSize(100, 22)
	close:SetScript("OnClick", function()
		frame:Hide()
	end)
	close:StripTextures()
	close:SkinButton()
	close:Disable()
	frame.close = close

	local countdown = close:CreateFontString(nil, "OVERLAY")
	countdown:FontTemplate(nil, 12, "")
	countdown:SetPoint("LEFT", close.Text, "RIGHT", 3, 0)
	countdown:SetTextColor(DISABLED_FONT_COLOR:GetRGB())
	frame.countdown = countdown

	local offset = 4
	for i = 1, #ChangeLogData do
		local button = CreateFrame("Frame", "Button"..i, frame)
		button:SetSize(375, 16)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -offset)

		if i <= #ChangeLogData then
			local string = ModifiedString(GetChangeLogInfo(i))

			button.Text = button:CreateFontString(nil, "OVERLAY")
			button.Text:FontTemplate(nil, 12, "")
			button.Text:SetPoint("CENTER")
			button.Text:SetPoint("LEFT", 0, 0)
			button.Text:SetText(string)
			button.Text:SetWordWrap(true)
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

function Module:OnInitialize()
	K.Delay(6, function()
		Module:CheckVersion()
	end)
end