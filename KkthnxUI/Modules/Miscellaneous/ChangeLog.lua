local K, C, L = unpack(select(2, ...))

local ChangeLog = CreateFrame("frame")
local ChangeLogData = {
	"- Could be some undocumented changes that are not listed!",
	"",
	"Added:",
	"- ",
	"Changed:",
	"- ",
	"Removed:",
	"- ",
	"Fixed:",
	"- ",
}

local NormalButton = function(text, parent)

	local result = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	local label = result:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	label:SetJustifyH("LEFT")
	label:SetText(text)
	result:SetSize(100, 20)
	result:SetFontString(label)
	if IsAddOnLoaded("Aurora") then
		local F = unpack(Aurora)
		F.Reskin(result)
	else
		result:SkinButton()
	end

	return result
end

local function ModifiedString(string)
	local count = string.find(string,":")
	local newString = string

	if count then
		local prefix = string.sub(string, 0, count)
		local suffix = string.sub(string, count + 1)
		local subHeader = string.find(string,"-")

		if subHeader then newString = tostring("|cff3c9bed".. prefix .. "|r" .. suffix) else newString = tostring("|cff3c9bed" .. prefix .. "|r" .. suffix) end
	end

	for pattern in gmatch(string,"('.*')") do
		newString = newString:gsub(pattern, "|cFFFF8800"..pattern:gsub("'","").."|r")
	end

	return newString
end

local function GetChangeLogInfo(i)
	for line, info in pairs(ChangeLogData) do
		if line == i then return info end
	end
end

_G.StaticPopupDialogs["BUGREPORT"] = {
	text = "KkthnxUI - Bug report",
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	editBoxWidth = 325,
	OnShow = function(self, ...)
		self.editBox:SetFocus()
		self.editBox:SetText("https://github.com/Kkthnx/KkthnxUI_Legion/issues")
		self.editBox:HighlightText()
	end,
	EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
}

function ChangeLog:CreateChangelog()
	local frame = CreateFrame("Frame", "KkthnxUIChangeLog", UIParent)
	frame:SetPoint("CENTER")
	frame:SetSize(400, 300)
	frame:SetTemplate()

	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", function() frame:StartMoving() end)
	frame:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
	frame:SetClampedToScreen(true)
	frame:SetMovable(true)

	local icon = CreateFrame("Frame", nil, frame)
	icon:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 0)
	icon:SetSize(28, 28)
	icon:SetTemplate()
	icon.bg = icon:CreateTexture(nil, "ARTWORK")
	icon.bg:SetPoint("TOPLEFT", 2, -2)
	icon.bg:SetPoint("BOTTOMRIGHT", -2, 2)
	icon.bg:SetTexture(nil)

	local title = CreateFrame("Frame", nil, frame)
	title:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	title:SetSize(372, 28)
	title:SetTemplate()
	title.text = title:CreateFontString(nil, "OVERLAY")
	title.text:SetPoint("CENTER", title, 0, -1)
	title.text:SetFont(C.Media.Font, 14, "OUTLINE")
	title.text:SetText("|cff3c9bedKkthnxUI|r - Changelog " .. K.Version)

	local close = NormalButton("Close", frame)
	close:SetPoint("BOTTOMRIGHT", frame, -8, 8)
	close:SetScript("OnClick", function(self) frame:Hide() end)

	local bReport = NormalButton("Bug report", frame)
	bReport:SetPoint("BOTTOMLEFT", frame, 8, 8)
	bReport:SetScript("OnClick", function(self) StaticPopup_Show("BUGREPORT") end)

	local offset = 4
	for i = 1, #ChangeLogData do
		local button = CreateFrame("Frame", "Button"..i, frame)
		button:SetSize(375, 16)
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", 5, -offset)

		if i <= #ChangeLogData then
			local string = ModifiedString(GetChangeLogInfo(i))

			button.Text = button:CreateFontString(nil, "OVERLAY")
			button.Text:SetFont(C.Media.Font, 12, "OUTLINE")
			button.Text:SetText(string)
			button.Text:SetPoint("LEFT", 0, 0)
		end
		offset = offset + 19 --16
	end
end

function KkthnxUI_ToggleChangeLog() -- /script KkthnxUI_ToggleChangeLog()
	ChangeLog:CreateChangelog()
end

function ChangeLog:OnCheckVersion(self)
	if not KkthnxUIData["Version"] or (KkthnxUIData["Version"] and KkthnxUIData["Version"] ~= K.Version) then
		KkthnxUIData["Version"] = K.Version
		ChangeLog:CreateChangelog()
	end
end

ChangeLog:RegisterEvent("ADDON_LOADED")
ChangeLog:RegisterEvent("PLAYER_ENTERING_WORLD")
ChangeLog:SetScript("OnEvent", function(self, event, ...)
if KkthnxUIData == nil then KkthnxUIData = {} end
	ChangeLog:OnCheckVersion()
end)
