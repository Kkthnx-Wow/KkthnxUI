--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/BugReport.lua
	Purpose:
		A friendly in-game bug report form. Fill in what happened, press Generate,
		and it writes a tidy report already stamped with your version, build, and
		client details, then hands it back selected for copying. Paste it straight
		into a new GitHub issue. The build stamp lets a report be pinned to the exact
		build it came from.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local Module = K:NewModule("BugReport")

local _G = _G
local format = string.format
local tconcat = table.concat

local CreateFrame = CreateFrame
local UIParent = UIParent
local GetBuildInfo = GetBuildInfo
local GetLocale = GetLocale

local ISSUES_URL = "https://github.com/Kkthnx-Wow/KkthnxUI/issues/new"

-- One labelled input row. Single-line boxes for short answers, a taller scrolling
-- box for the longer ones, both skinned to match the rest of the UI. The hint is
-- greyed placeholder text that shows what to write and clears the moment you type.
local function CreateField(parent, label, hint, multiline, height)
	local title = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 12, K.FontOutlineStyle())
	title:SetText(label)
	title:SetTextColor(1, 0.82, 0)

	local box = CreateFrame("Frame", nil, parent)
	box:SetHeight(height or 22)
	K.CreateBackground(box, 0.05, 0.05, 0.05, 0.85)
	K.CreateBorder(box)

	local edit = CreateFrame("EditBox", nil, box)
	edit:SetFontObject(ChatFontNormal)
	edit:SetTextColor(1, 1, 1)
	edit:SetAutoFocus(false)
	edit:SetTextInsets(6, 6, 4, 4)
	edit:SetScript("OnEscapePressed", edit.ClearFocus)

	if multiline then
		edit:SetMultiLine(true)
		edit:SetPoint("TOPLEFT", 0, 0)
		edit:SetPoint("BOTTOMRIGHT", 0, 0)
		edit:SetScript("OnEnterPressed", nil)
	else
		edit:SetAllPoints(box)
		edit:SetScript("OnEnterPressed", edit.ClearFocus)
	end

	-- Placeholder: a soft grey example that hides while the box has text or focus.
	if hint then
		local ghost = box:CreateFontString(nil, "ARTWORK")
		K.SetFont(ghost, 12, K.FontOutlineStyle())
		ghost:SetPoint("TOPLEFT", 8, -5)
		ghost:SetPoint("BOTTOMRIGHT", -8, 5)
		ghost:SetJustifyH("LEFT")
		ghost:SetJustifyV(multiline and "TOP" or "MIDDLE")
		ghost:SetTextColor(0.5, 0.5, 0.5)
		ghost:SetText(hint)

		local function Refresh()
			ghost:SetShown(edit:GetText() == "" and not edit:HasFocus())
		end
		edit:HookScript("OnEditFocusGained", function()
			ghost:Hide()
		end)
		edit:HookScript("OnEditFocusLost", Refresh)
		edit:HookScript("OnTextChanged", Refresh)
		Refresh()
	end

	box.edit = edit
	box.title = title
	return box
end

function Module:BuildReport()
	local frame = CreateFrame("Frame", "KKUI_BugReport", UIParent)
	frame:SetSize(520, 660)
	frame:SetPoint("CENTER")
	frame:SetFrameStrata("DIALOG")
	frame:EnableMouse(true)
	frame:SetMovable(true)
	frame:SetClampedToScreen(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	K.CreateGradientBackground(frame, 0.96)
	K.CreateBorder(frame)
	frame:Hide()
	tinsert(_G.UISpecialFrames, "KKUI_BugReport")

	local title = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 16, K.FontOutlineStyle())
	title:SetPoint("TOP", 0, -12)
	title:SetText(L["Bug Report"] or "Bug Report")

	local sub = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(sub, 11, K.FontOutlineStyle())
	sub:SetPoint("TOP", title, "BOTTOM", 0, -2)
	sub:SetTextColor(0.7, 0.7, 0.7)
	sub:SetText(L["Fill in what you can, Generate, copy with Ctrl+C, paste into a new GitHub issue."] or "Fill in what you can, Generate, copy with Ctrl+C, paste into a new GitHub issue.")

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -4, -4)
	K.SkinCloseButton(close)

	-- The fields, named to match the GitHub bug template headings exactly, each with
	-- a plain example so people know the kind of detail that helps.
	local happened = CreateField(frame, L["What happened"] or "What happened",
		L["Describe the problem in a sentence or two. Example: the minimap clock sits on top of the tracking button."] or "Describe the problem in a sentence or two. Example: the minimap clock sits on top of the tracking button.", true, 60)
	local steps = CreateField(frame, L["Steps to reproduce"] or "Steps to reproduce",
		L["List the steps that lead to it, one per line. Example:\n1. Log in\n2. Open the world map\n3. Hover a quest pin"] or "List the steps that lead to it, one per line. Example:\n1. Log in\n2. Open the world map\n3. Hover a quest pin", true, 70)
	local expected = CreateField(frame, L["What you expected"] or "What you expected",
		L["What should have happened instead."] or "What should have happened instead.", true, 46)
	local errorText = CreateField(frame, L["Error text (turn on with /console scriptErrors 1)"] or "Error text (turn on with /console scriptErrors 1)",
		L["Paste any red Lua error here. Turn errors on first with /console scriptErrors 1, then reproduce the bug."] or "Paste any red Lua error here. Turn errors on first with /console scriptErrors 1, then reproduce the bug.", true, 60)
	local extra = CreateField(frame, L["Anything else"] or "Anything else",
		L["Other addons involved, when it started, anything unusual. Optional."] or "Other addons involved, when it started, anything unusual. Optional.", true, 46)

	frame.fields = { happened, steps, expected, errorText, extra }

	local y = -52
	for _, box in ipairs(frame.fields) do
		box.title:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, y)
		box:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, y - 16)
		box:SetPoint("RIGHT", frame, "RIGHT", -14, 0)
		y = y - 16 - box:GetHeight() - 10
	end

	-- Does it still happen on a clean KkthnxUI-only setup? A tick instead of typing.
	local clean = CreateFrame("CheckButton", nil, frame, "UICheckButtonTemplate")
	clean:SetSize(22, 22)
	clean:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, y)
	if K.SkinCheckBox then
		K.SkinCheckBox(clean)
	end
	local cleanLabel = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(cleanLabel, 12, K.FontOutlineStyle())
	cleanLabel:SetPoint("LEFT", clean, "RIGHT", 4, 0)
	cleanLabel:SetText(L["Bug still happens with only KkthnxUI enabled"] or "Bug still happens with only KkthnxUI enabled")
	frame.cleanCheck = clean
	y = y - 28

	-- The generated report, selected and ready to copy.
	local outLabel = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(outLabel, 12, K.FontOutlineStyle())
	outLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, y)
	outLabel:SetTextColor(1, 0.82, 0)
	outLabel:SetText(L["Generated report (copy this)"] or "Generated report (copy this)")

	local outBox = CreateFrame("Frame", nil, frame)
	outBox:SetPoint("TOPLEFT", frame, "TOPLEFT", 14, y - 16)
	outBox:SetPoint("RIGHT", frame, "RIGHT", -14, 0)
	outBox:SetPoint("BOTTOM", frame, "BOTTOM", 0, 48)
	K.CreateBackground(outBox, 0.05, 0.05, 0.05, 0.85)
	K.CreateBorder(outBox)

	local scroll = CreateFrame("ScrollFrame", "KKUI_BugReportScroll", outBox, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 6, -6)
	scroll:SetPoint("BOTTOMRIGHT", -26, 6)
	K.SkinScrollBar(scroll.ScrollBar)

	local out = CreateFrame("EditBox", nil, outBox)
	out:SetMultiLine(true)
	out:SetMaxLetters(0)
	out:SetAutoFocus(false)
	out:SetFontObject(ChatFontNormal)
	out:SetTextColor(1, 1, 1)
	out:SetWidth(458)
	out:SetHeight(120)
	out:SetScript("OnEscapePressed", out.ClearFocus)
	scroll:SetScrollChild(out)

	-- Placeholder so the empty box reads as intentional before you generate.
	local outHint = outBox:CreateFontString(nil, "ARTWORK")
	K.SetFont(outHint, 12, K.FontOutlineStyle())
	outHint:SetPoint("TOPLEFT", 10, -8)
	outHint:SetTextColor(0.5, 0.5, 0.5)
	outHint:SetText(L["Your report appears here after you press Generate."] or "Your report appears here after you press Generate.")
	out:HookScript("OnTextChanged", function(self)
		outHint:SetShown(self:GetText() == "")
	end)

	-- Buttons along the bottom.
	local generate = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	generate:SetSize(140, 24)
	generate:SetPoint("BOTTOMLEFT", 14, 14)
	generate:SetText(L["Generate"] or "Generate")
	K.SkinButton(generate)

	local link = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	link:SetSize(180, 24)
	link:SetPoint("BOTTOMRIGHT", -14, 14)
	link:SetText(L["Show GitHub link"] or "Show GitHub link")
	K.SkinButton(link)

	generate:SetScript("OnClick", function()
		out:SetText(Module:Compose(happened.edit:GetText(), steps.edit:GetText(), expected.edit:GetText(), errorText.edit:GetText(), extra.edit:GetText(), clean:GetChecked()))
		out:SetHeight(240)
		out:HighlightText()
		out:SetFocus()
		outLabel:SetText(L["Report ready. Press Ctrl+C to copy, then Show GitHub link to open a new issue."] or "Report ready. Press Ctrl+C to copy, then Show GitHub link to open a new issue.")
		outLabel:SetTextColor(0.4, 0.85, 0.4)
	end)

	link:SetScript("OnClick", function()
		out:SetText(ISSUES_URL)
		out:HighlightText()
		out:SetFocus()
		outLabel:SetText(L["Link ready. Press Ctrl+C to copy it, then open it in your browser."] or "Link ready. Press Ctrl+C to copy it, then open it in your browser.")
		outLabel:SetTextColor(0.4, 0.85, 0.4)
	end)

	self.frame = frame
	return frame
end

-- Turn the answers into a report that mirrors the GitHub bug template heading for
-- heading, with the setup block stamped for you. Blank answers get a gentle
-- placeholder so the shape of the report always reads the same.
function Module:Compose(happened, steps, expected, errorText, extra, cleanOnly)
	local function orBlank(text)
		text = text and text:gsub("^%s+", ""):gsub("%s+$", "")
		return (text and text ~= "") and text or "_(not provided)_"
	end

	local version, _, _, tocversion = GetBuildInfo()
	local flavor = (K.Client and K.Client.IsRetail and "Retail") or (K.Client and K.Client.IsTBC and "TBC") or "Classic"

	local lines = {
		"**What happened**",
		orBlank(happened),
		"",
		"**Steps to reproduce**",
		orBlank(steps),
		"",
		"**What you expected**",
		orBlank(expected),
		"",
		"**Error text**",
		orBlank(errorText),
		"",
		"**Screenshots**",
		"_(attach on GitHub if you have any)_",
		"",
		"**Your setup**",
		format("- KkthnxUI: %s (build %s)", K.Version or "?", K.Build or "?"),
		format("- Game: %s (patch %s) %s", version or "?", tocversion or "?", flavor),
		format("- Locale: %s", GetLocale() or "?"),
		format("- Bug still happens with only KkthnxUI enabled: %s", cleanOnly and "yes" or "no"),
		"",
		"**Anything else**",
		orBlank(extra),
	}
	return tconcat(lines, "\n")
end

function Module:Toggle()
	if not self.frame then
		self:BuildReport()
	end
	self.frame:SetShown(not self.frame:IsShown())
end

function Module:OnEnable()
	_G.SLASH_KKUI_BUG1 = "/kkbug"
	_G.SLASH_KKUI_BUG2 = "/bug"
	_G.SlashCmdList.KKUI_BUG = function()
		Module:Toggle()
	end
end

-- Let other panels open it.
K.ToggleBugReport = function()
	Module:Toggle()
end
