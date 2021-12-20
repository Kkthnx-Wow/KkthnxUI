local K, C, L = unpack(select(2, ...))

if IsAddOnLoaded("StatPriority") or IsAddOnLoaded("IcyVeinsStatPriority") or IsAddOnLoaded("ClassSpecStats") then
	return
end

local _G = _G
local string_trim = _G.string.trim

local GetSpecializationInfoForClassID = _G.GetSpecializationInfoForClassID
local UnitClass = _G.UnitClass
local CreateFrame = _G.CreateFrame
local GetSpecialization = _G.GetSpecialization

local currentSpecID
local items = {}
local addBtn
local customFrame

-- frame (button)
local frame = CreateFrame("Button", "KKUI_StatPriorityFrame", UIParent)
frame:SetPoint("BOTTOMRIGHT", PaperDollFrame, "TOPRIGHT", -2, 4)
frame:SetParent(PaperDollFrame)
frame:CreateBorder()
frame.title = "Stat Priority (Icy Veins - Patch 9.1)"
K.AddTooltip(frame, "ANCHOR_BOTTOMRIGHT", "Click for more stat priority options", "info")

-- function
local function SetFrame(show)
	frame:SetNormalFontObject("KkthnxUIFont")
	frame:SetHeight(12 + 7)

	if show then
		frame:Show()
	else
		frame:Hide()
	end
end

local function SetText(text)
	if not text then
		return
	end

	frame:SetText(text)
	frame:SetWidth(frame:GetFontString():GetStringWidth() + 20)
end

-- widgets
local function CreateButton(parent, width, height, text)
	local b = CreateFrame("Button", nil, parent)
	b:SkinButton()
	b:SetNormalFontObject(KkthnxUIFont)
	b:SetWidth(width)
	b:SetHeight(height)
	b:SetText(text)

	return b
end

-- custom editbox
local function ShowCustomFrame(sp, desc, k, isSelected)
	if not customFrame then
		customFrame = CreateFrame("Frame", nil, addBtn)
		customFrame:Hide()
		customFrame:SetSize(280, 50)
		customFrame:SetPoint("TOPLEFT", addBtn, "BOTTOMLEFT", 0, -1)
		customFrame:SetScript("OnHide", function()
			customFrame:Hide()
			for _, item in pairs(items) do
				if item.del then
					item.del:SetEnabled(true)
					item.del.KKUI_Background:SetVertexColor(0.6, 0.1, 0.1, 1)
				end
			end
		end)

		customFrame:SetScript("OnShow", function()
			for _, item in pairs(items) do
				if item.del then
					item.del:SetEnabled(false)
					item.del.KKUI_Background:SetVertexColor(0.4, 0.4, 0.4, 1)
				end
			end
		end)

		local height = select(2, KkthnxUIFont:GetFont()) + 7
		customFrame.eb1 = CreateFrame("EditBox", nil, customFrame)
		customFrame.eb1:CreateBorder()
		customFrame.eb1:SetFontObject(KkthnxUIFont)
		customFrame.eb1:SetMultiLine(false)
		customFrame.eb1:SetMaxLetters(0)
		customFrame.eb1:SetJustifyH("LEFT")
		customFrame.eb1:SetJustifyV("CENTER")
		customFrame.eb1:SetWidth(320)
		customFrame.eb1:SetHeight(height)
		customFrame.eb1:SetTextInsets(5, 5, 0, 0)
		customFrame.eb1:SetAutoFocus(false)
		customFrame.eb1:SetScript("OnEscapePressed", function()
			customFrame.eb1:ClearFocus()
		end)

		customFrame.eb1:SetScript("OnEnterPressed", function()
			customFrame.eb1:ClearFocus()
		end)

		customFrame.eb1:SetScript("OnEditFocusGained", function()
			customFrame.eb1:HighlightText()
		end)

		customFrame.eb1:SetScript("OnEditFocusLost", function()
			customFrame.eb1:HighlightText(0, 0)
		end)

		customFrame.eb2 = CreateFrame("EditBox", nil, customFrame)
		customFrame.eb2:CreateBorder()
		customFrame.eb2:SetFontObject(KkthnxUIFont)
		customFrame.eb2:SetMultiLine(false)
		customFrame.eb2:SetMaxLetters(0)
		customFrame.eb2:SetJustifyH("LEFT")
		customFrame.eb2:SetJustifyV("CENTER")
		customFrame.eb2:SetTextInsets(5, 5, 0, 0)
		customFrame.eb2:SetAutoFocus(false)
		customFrame.eb2:SetScript("OnEscapePressed", function()
			customFrame.eb2:ClearFocus()
		end)

		customFrame.eb2:SetScript("OnEnterPressed", function()
			customFrame.eb2:ClearFocus()
		end)

		customFrame.eb2:SetScript("OnEditFocusGained", function()
			customFrame.eb2:HighlightText()
		end)

		customFrame.eb2:SetScript("OnEditFocusLost", function()
			customFrame.eb2:HighlightText(0, 0)
		end)

		customFrame.eb2:SetPoint("TOPLEFT", customFrame.eb1, "BOTTOMLEFT", 0, -6)

		customFrame.cancelBtn = CreateButton(customFrame, height - 2, height - 2, "U+0078")
		customFrame.cancelBtn:SetPoint("TOPRIGHT", customFrame.eb1, "BOTTOMRIGHT", 0, -6)
		customFrame.cancelBtn:SetScript("OnClick", function() customFrame:Hide() end)

		customFrame.confirmBtn = CreateButton(customFrame, height - 2, height - 2, "√")
		customFrame.confirmBtn:SetPoint("RIGHT", customFrame.cancelBtn, "LEFT", -6, 0)

		customFrame.eb1:SetPoint("TOPLEFT", 0, -4)
		customFrame.eb2:SetPoint("BOTTOMRIGHT", customFrame.confirmBtn, "BOTTOMLEFT", -6, 0)

		customFrame.eb1:SetScript("OnTextChanged", function(self)
			-- if not userInput then return end
			if string_trim(self:GetText()) == "" then
				customFrame.eb1.valid = false

			else
				customFrame.eb1.valid = true
			end

			if customFrame.eb1.valid and customFrame.eb2.valid then
				customFrame.confirmBtn:SetEnabled(true)
				customFrame.confirmBtn.KKUI_Background:SetVertexColor(.1, .6, .1, 1)
			else
				customFrame.confirmBtn:SetEnabled(false)
				customFrame.confirmBtn.KKUI_Background:SetVertexColor(.4, .4, .4, 1)
			end
		end)

		customFrame.eb2:SetScript("OnTextChanged", function(self)
			-- if not userInput then return end
			if string_trim(self:GetText()) == "" then
				customFrame.eb2.valid = false

			else
				customFrame.eb2.valid = true
			end

			if customFrame.eb1.valid and customFrame.eb2.valid then
				customFrame.confirmBtn:SetEnabled(true)
				customFrame.confirmBtn.KKUI_Background:SetVertexColor(.1, .6, .1, 1)
			else
				customFrame.confirmBtn:SetEnabled(false)
				customFrame.confirmBtn.KKUI_Background:SetVertexColor(.4, .4, .4, 1)
			end
		end)
	end

	-- update db
	customFrame.confirmBtn:SetScript("OnClick", function()
		if k then -- edit
			KkthnxUIDB.StatPriority.Custom[currentSpecID][k] = {
				string_trim(customFrame.eb1:GetText()),
				string_trim(customFrame.eb2:GetText())
			}

			if isSelected then -- current shown
				SetText(KkthnxUIDB.StatPriority.Custom[currentSpecID][k][1])
			end
		else
			if type(KkthnxUIDB.StatPriority.Custom[currentSpecID]) ~= "table" then
				KkthnxUIDB.StatPriority.Custom[currentSpecID] = {}
			end

			table.insert(KkthnxUIDB.StatPriority.Custom[currentSpecID], {
				string_trim(customFrame.eb1:GetText()),
				string_trim(customFrame.eb2:GetText())
			})
		end

		customFrame:Hide()
		frame:LoadList()
		frame:Click()
	end)

	customFrame.eb1:SetText(sp or "Stat Priority")
	customFrame.eb1:ClearFocus()
	customFrame.eb2:SetText(desc or "Description")
	customFrame.eb2:ClearFocus()
	customFrame:Show()
end


-- list button functions
local textWidth = 0
local function AddItem(text, k)
	local item = CreateButton(frame, 200, select(2, KkthnxUIFont:GetFont()) + 7, text)
	item:Hide()
	textWidth = math.max(item:GetFontString():GetStringWidth(), textWidth)

	-- highlight texture
	item.highlight = item:CreateTexture()
	item.highlight:SetColorTexture(.5, 1, 0, 1)
	item.highlight:SetSize(5, item:GetHeight() - 2)
	item.highlight:SetPoint("LEFT", 1, 0)
	item.highlight:Hide()

	-- delete/edit button
	if k then
		item.edit = CreateButton(item, item:GetHeight(), item:GetHeight(), "e")
		item.edit:SetPoint("LEFT", item, "RIGHT", 6, 0)
		item.edit:SetScript("OnClick", function()
			ShowCustomFrame(KkthnxUIDB.StatPriority.Custom[currentSpecID][k][1], KkthnxUIDB.StatPriority.Custom[currentSpecID][k][2], k, KkthnxUIDB.StatPriority["selected"][currentSpecID] == item.n)
		end)

		item.del = CreateButton(item, item:GetHeight(), item:GetHeight(), "×")
		item.del:SetPoint("LEFT", item.edit, "RIGHT", 6, 0)
		item.del:SetScript("OnClick", function()
			if IsShiftKeyDown() then
				-- remove from custom table
				table.remove(KkthnxUIDB.StatPriority.Custom[currentSpecID], k)
				-- check whether custom table is empty
				if #KkthnxUIDB.StatPriority.Custom[currentSpecID] == 0 then
					KkthnxUIDB.StatPriority.Custom[currentSpecID] = nil
				end

				if KkthnxUIDB.StatPriority["selected"][currentSpecID] == item.n then -- current selected
					KkthnxUIDB.StatPriority["selected"][currentSpecID] = 1
				end
				SetText(K:GetSPText(currentSpecID))
				frame:LoadList()
				frame:Click()
			else
				K.Print("Shift + Left Click to delete it your custom stat")
			end
		end)
	end

	table.insert(items, item)
	item.n = #items

	item:SetScript("OnHide", function()
		item:Hide()
	end)

	item:SetScript("OnClick", function()
		addBtn:Hide()

		for _, i in pairs(items) do
			i.highlight:Hide()
			i:Hide()
		end

		item.highlight:Show()
		KkthnxUIDB.StatPriority["selected"][currentSpecID] = item.n
		SetText(K:GetSPText(currentSpecID))
	end)
end

-- load list
function frame:LoadList()
	textWidth = 0
	for _, i in pairs(items) do
		i:ClearAllPoints()
		i:Hide()
		i:SetParent(nil)
	end
	wipe(items)

	-- "+" button
	if not addBtn then
		addBtn = CreateButton(frame, select(2, KkthnxUIFont:GetFont()) + 7, select(2, KkthnxUIFont:GetFont()) + 7, "+")
	end
	addBtn:Hide()
	addBtn:ClearAllPoints()
	addBtn:SetPoint("TOPLEFT", frame, "TOPRIGHT", 6, 0)
	addBtn:SetScript("OnHide", function()
		addBtn:Hide()
	end)

	addBtn:SetScript("OnClick", function()
		ShowCustomFrame()
	end)

	local desc = K:GetSPDesc(currentSpecID)
	if not desc then
		return
	end

	for k, t in pairs(desc) do
		AddItem(t[1], t[2])
		if k == 1 then
			items[1]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 6, 0)
		else
			items[k]:SetPoint("TOP", items[k-1], "BOTTOM", 0, -6)
		end
	end

	-- re-set "+" buttona point
	addBtn:ClearAllPoints()
	addBtn:SetPoint("TOPLEFT", items[#items], "BOTTOMLEFT", 0, -6)

	-- update width
	for _, i in pairs(items) do
		i:SetWidth(textWidth + 20)
	end

	-- highlight selected
	if KkthnxUIDB.StatPriority["selected"][currentSpecID] then
		items[KkthnxUIDB.StatPriority["selected"][currentSpecID]].highlight:Show()
	else -- highlight first
		items[1].highlight:Show()
	end
end

-- frame OnClick
frame:SetScript("OnClick", function()
	for _, i in pairs(items) do
		if i:IsShown() then
			i:Hide()
		else
			i:Show()
		end
	end

	if addBtn:IsShown() then
		addBtn:Hide()
	else
		addBtn:Show()
	end
end)

-- event
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
frame:SetScript("OnEvent", function(self, event, ...)
	if not C["Misc"].PriorityStats then
		return
	end

	self[event](self, ...)
end)

function frame:ADDON_LOADED(arg1)
	if arg1 == "KkthnxUI" then
		if type(KkthnxUIDB.StatPriority.Custom) ~= "table" then
			KkthnxUIDB.StatPriority.Custom = {}
		end

		if type(KkthnxUIDB.StatPriority) ~= "table" then
			KkthnxUIDB.StatPriority = {}
		end

		if type(KkthnxUIDB.StatPriority["show"]) ~= "boolean" then
			KkthnxUIDB.StatPriority["show"] = true
		end

		if type(KkthnxUIDB.StatPriority["selected"]) ~= "table" then
			KkthnxUIDB.StatPriority["selected"] = {}
		end

		SetFrame(KkthnxUIDB.StatPriority["show"])
	end
end

function frame:PLAYER_LOGIN()
	currentSpecID = GetSpecializationInfoForClassID(select(3, UnitClass("player")), GetSpecialization())
	SetText(K:GetSPText(currentSpecID))
	self:LoadList()
end

function frame:ACTIVE_TALENT_GROUP_CHANGED()
	local specID = GetSpecializationInfoForClassID(select(3, UnitClass("player")), GetSpecialization())
	if specID ~= currentSpecID then
		currentSpecID = specID
		SetText(K:GetSPText(currentSpecID))
		self:LoadList()
	end
end