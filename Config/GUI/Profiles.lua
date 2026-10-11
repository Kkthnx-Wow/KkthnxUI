--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/GUI/Profiles.lua
	Purpose:
		The Profiles panel. Create, switch, copy, delete, and reset profiles.
		Registered as a custom panel so the window renders it in place of a
		schema driven layout. Most actions prompt a reload to apply cleanly.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local GUI = K.GUI

local format = string.format
local strtrim = strtrim

local function MakeButton(parent, text, width)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width or 90, 22)
	button:SetText(text)
	K.SkinButton(button)
	return button
end

GUI.CustomPanels = GUI.CustomPanels or {}

local function AskReload()
	K.Confirm(L["Reload the UI now to apply this?"], ReloadUI)
end

function GUI.CustomPanels.Profiles(parent)
	local title = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 14, "OUTLINE")
	title:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])
	title:SetPoint("TOPLEFT", 12, -8)
	title:SetText(L["Profiles"])

	local current = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(current, 12)
	current:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)

	-- The list of profile rows is rebuilt whenever profiles change.
	local listHolder = CreateFrame("Frame", nil, parent)
	listHolder:SetPoint("TOPLEFT", current, "BOTTOMLEFT", 0, -12)
	listHolder:SetSize(460, 10)
	local rows = {}

	local Refresh

	local function ClearRows()
		for _, row in ipairs(rows) do
			row:Hide()
		end
		wipe(rows)
	end

	Refresh = function()
		local active = K:GetActiveProfileName()
		local pending = K:GetPendingProfileName()
		local text = L["Active profile"] .. ": |cff5C8BCF" .. active .. "|r"
		if pending ~= active then
			text = text .. "   " .. L["After reload"] .. ": |cff5C8BCF" .. pending .. "|r"
		end
		current:SetText(text)
		ClearRows()

		local names = K:ListProfiles()
		table.sort(names)

		local y = 0
		for _, name in ipairs(names) do
			local row = CreateFrame("Frame", nil, listHolder)
			row:SetSize(460, 28)
			row:SetPoint("TOPLEFT", 0, y)
			y = y - 36
			K.CreateBackground(row, 0.15, 0.15, 0.15, 0.5)
			K.CreateBorder(row)

			local label = row:CreateFontString(nil, "OVERLAY")
			K.SetFont(label, 12)
			label:SetPoint("LEFT", 8, 0)
			label:SetWidth(120)
			label:SetJustifyH("LEFT")
			label:SetWordWrap(false)
			label:SetText(name)

			local del = MakeButton(row, L["Delete"], 60)
			del:SetPoint("RIGHT", -8, 0)
			del:SetScript("OnClick", function()
				K.Confirm(format(L["Delete the profile %s?"], name), function()
					if K:DeleteProfile(name) then
						Refresh()
					else
						K.Print(L["Cannot delete the active profile."])
					end
				end)
			end)

			del:SetEnabled(name ~= active)

			local export = MakeButton(row, L["Export"], 60)
			export:SetPoint("RIGHT", del, "LEFT", -4, 0)
			export:SetScript("OnClick", function()
				local str, err = K:ExportProfile(name)
				if str then
					K.ShowCopyText(format(L["Export: %s"], name), str)
				else
					K.Print(L[err])
				end
			end)

			local copy = MakeButton(row, L["Copy"], 60)
			copy:SetPoint("RIGHT", export, "LEFT", -4, 0)
			copy:SetScript("OnClick", function()
				K.Confirm(format(L["Replace the active profile with a copy of %s?"], name), function()
					if K:CopyProfile(name) then
						Refresh()
						AskReload()
					end
				end)
			end)
			copy:SetEnabled(name ~= active)

			local use = MakeButton(row, L["Use"], 60)
			use:SetPoint("RIGHT", copy, "LEFT", -4, 0)
			use:SetScript("OnClick", function()
				K:SetProfile(name)
				Refresh()
				AskReload()
			end)
			use:SetEnabled(name ~= pending)

			rows[#rows + 1] = row
		end
		listHolder:SetHeight(-y + 4)
		parent:SetHeight(math.max(520, 330 - y))
	end

	-- Create a new profile from a text box.
	local createLabel = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(createLabel, 12)
	createLabel:SetPoint("TOPLEFT", listHolder, "BOTTOMLEFT", 0, -20)
	createLabel:SetText(L["New profile name"])

	local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	edit:SetSize(200, 22)
	edit:SetPoint("TOPLEFT", createLabel, "BOTTOMLEFT", 6, -6)
	edit:SetAutoFocus(false)
	edit:SetMaxLetters(32)
	K.SkinEditBox(edit)

	local create = MakeButton(parent, L["Create"], 90)
	create:SetPoint("LEFT", edit, "RIGHT", 8, 0)
	create:SetScript("OnClick", function()
		local name = strtrim(edit:GetText())
		if K:CreateProfile(name) then
			edit:SetText("")
			edit:ClearFocus()
			Refresh()
		else
			K.Print(L["Pick a profile name that is not already used."])
		end
	end)

	-- Bring a profile in from text. Two steps: the pasted string, then a name.
	local import = MakeButton(parent, L["Import Profile"], 180)
	import:SetPoint("TOPLEFT", edit, "BOTTOMLEFT", -6, -16)
	import:SetScript("OnClick", function()
		K.ShowImportBox(L["Import Profile"], function(text)
			K.Prompt(L["Name for the imported profile"], L["Imported"], function(name)
				local imported, err = K:ImportProfile(text, strtrim(name or ""))
				if imported then
					K.Print(L["Profile imported. Press Use on it to switch."])
					Refresh()
				else
					K.Print(L[err])
				end
			end)
		end)
	end)

	-- Reset the active profile.
	local reset = MakeButton(parent, L["Reset Active Profile"], 180)
	reset:SetPoint("TOPLEFT", import, "BOTTOMLEFT", 0, -10)
	reset:SetScript("OnClick", function()
		K.Confirm(L["Put every setting of the active profile back to its default?"], function()
			K:ResetProfile()
			Refresh()
			AskReload()
		end)
	end)

	Refresh()
end
