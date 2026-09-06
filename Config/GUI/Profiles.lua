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

local function MakeButton(parent, text, width)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width or 90, 22)
	button:SetText(text)
	K.SkinButton(button)
	return button
end

GUI.CustomPanels = GUI.CustomPanels or {}

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
		current:SetText(L["Active profile"] .. ": |cff5C8BCF" .. K:GetActiveProfileName() .. "|r")
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
			label:SetText(name)

			local use = MakeButton(row, L["Use"], 70)
			use:SetPoint("RIGHT", -8, 0)
			use:SetScript("OnClick", function()
				K:SetProfile(name)
				Refresh()
			end)

			local del = MakeButton(row, L["Delete"], 70)
			del:SetPoint("RIGHT", use, "LEFT", -6, 0)
			del:SetScript("OnClick", function()
				if K:DeleteProfile(name) then
					Refresh()
				else
					K.Print(L["Cannot delete the active profile."])
				end
			end)

			rows[#rows + 1] = row
		end
		listHolder:SetHeight(-y + 4)
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
	K.SkinEditBox(edit)

	local create = MakeButton(parent, L["Create"], 90)
	create:SetPoint("LEFT", edit, "RIGHT", 8, 0)
	create:SetScript("OnClick", function()
		local name = edit:GetText()
		if K:CreateProfile(name) then
			edit:SetText("")
			edit:ClearFocus()
			Refresh()
		end
	end)

	-- Reset the active profile.
	local reset = MakeButton(parent, L["Reset Active Profile"], 180)
	reset:SetPoint("TOPLEFT", edit, "BOTTOMLEFT", -6, -16)
	reset:SetScript("OnClick", function()
		K:ResetProfile()
		Refresh()
	end)

	Refresh()

	-- Size the scroll child to fit.
	parent:SetHeight(520)
end
