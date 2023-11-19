local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("DataText")

local string_format, table_insert, table_sort, table_wipe = string.format, table.insert, table.sort, table.wipe
local GetAddOnCPUUsage, C_AddOns_GetAddOnInfo, GetAddOnMemoryUsage, GetCVarBool, GetFramerate, C_AddOns_GetNumAddOns, GetTime, C_AddOns_IsAddOnLoaded, IsShiftKeyDown = GetAddOnCPUUsage, C_AddOns.GetAddOnInfo, GetAddOnMemoryUsage, GetCVarBool, GetFramerate, C_AddOns.GetNumAddOns, GetTime, C_AddOns.IsAddOnLoaded, IsShiftKeyDown
local ResetCPUUsage, SetCVar, UpdateAddOnCPUUsage, UpdateAddOnMemoryUsage = ResetCPUUsage, SetCVar, UpdateAddOnCPUUsage, UpdateAddOnMemoryUsage
local collectgarbage, gcinfo = collectgarbage, gcinfo

local disableString, enableString = "|cffff5555" .. VIDEO_OPTIONS_DISABLED, "|cff55ff55" .. VIDEO_OPTIONS_ENABLED
local scriptProfileStatus = GetCVarBool("scriptProfile")
local showMoreString, usageColor, usageString = "%d %s (%s)", { 0, 1, 0, 1, 1, 0, 1, 0, 0 }, "%.3f ms"
local maxAddOns, infoTable = 12, {}

local SystemDataText, SystemDataTextEntered

local function formatMemory(value)
	return value > 1024 and string_format("%.1f mb", value / 1024) or string_format("%.0f kb", value)
end

local function sortByMemory(a, b)
	return (a and b and ((a[3] == b[3] and a[2] < b[2]) or a[3] > b[3])) or false
end

local function sortByCPU(a, b)
	return (a and b and ((a[4] == b[4] and a[2] < b[2]) or a[4] > b[4])) or false
end

local function smoothColor(cur, max)
	return K.oUF:RGBColorGradient(cur, max, unpack(usageColor))
end

local function BuildAddonList()
	local numAddons = C_AddOns_GetNumAddOns()
	if numAddons == #infoTable then
		return
	end

	table_wipe(infoTable)
	for i = 1, numAddons do
		local _, title, _, loadable = C_AddOns_GetAddOnInfo(i)
		if loadable then
			table_insert(infoTable, { i, title, 0, 0 })
		end
	end
end

local function UpdateMemory()
	UpdateAddOnMemoryUsage()

	local total = 0
	for _, data in ipairs(infoTable) do
		if C_AddOns_IsAddOnLoaded(data[1]) then
			local mem = GetAddOnMemoryUsage(data[1])
			data[3] = mem
			total = total + mem
		end
	end
	table_sort(infoTable, sortByMemory)

	return total
end

local function UpdateCPU()
	UpdateAddOnCPUUsage()

	local total = 0
	for _, data in ipairs(infoTable) do
		if C_AddOns.IsAddOnLoaded(data[1]) then
			local addonCPU = GetAddOnCPUUsage(data[1])
			data[4] = addonCPU
			total = total + addonCPU
		end
	end
	table_sort(infoTable, sortByCPU)

	return total
end

local function colorFPS(fps)
	fps = fps and floor(fps) or 0
	local color = fps < 15 and "|cffD80909" or (fps < 30 and "|cffE8DA0F" or "|cff0CD809")
	return color .. fps
end

local function setFrameRate()
	local fps = floor(GetFramerate())
	SystemDataText.Text:SetText(format("%s: %s", L["FPS"], colorFPS(fps)))
end

local function OnEnter()
	SystemDataTextEntered = true

	if not next(infoTable) then
		BuildAddonList()
	end
	local isShiftKeyDown = IsShiftKeyDown()
	local maxShown = isShiftKeyDown and #infoTable or math.min(maxAddOns, #infoTable)

	GameTooltip:SetOwner(SystemDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(SystemDataText))
	GameTooltip:ClearLines()

	if Module.ShowMemory or not scriptProfileStatus then
		local totalMemory = UpdateMemory()
		GameTooltip:AddDoubleLine("System", formatMemory(totalMemory), 0.4, 0.6, 1, 0.5, 0.7, 1)
		GameTooltip:AddLine(" ")

		local numEnabled = 0
		for _, data in ipairs(infoTable) do
			if C_AddOns.IsAddOnLoaded(data[1]) then
				numEnabled = numEnabled + 1
				if numEnabled <= maxShown then
					local r, g, b = smoothColor(data[3], totalMemory)
					GameTooltip:AddDoubleLine(data[2], formatMemory(data[3]), 1, 1, 1, r, g, b)
				end
			end
		end

		if not isShiftKeyDown and (numEnabled > maxAddOns) then
			local hiddenMemory = 0
			for i = (maxAddOns + 1), numEnabled do
				hiddenMemory = hiddenMemory + infoTable[i][3]
			end
			GameTooltip:AddDoubleLine(string_format(showMoreString, numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), formatMemory(hiddenMemory), 0.5, 0.7, 1, 0.5, 0.7, 1)
		end
	else
		local totalCPU = UpdateCPU()
		local passedTime = math.max(1, GetTime() - Module.CheckLoginTime)
		GameTooltip:AddDoubleLine(L["System"], string_format(usageString, totalCPU / passedTime, 0.4, 0.6, 1, 0.5, 0.7, 1))
		GameTooltip:AddLine(" ")

		local numEnabled = 0
		for _, data in ipairs(infoTable) do
			if C_AddOns.IsAddOnLoaded(data[1]) then
				numEnabled = numEnabled + 1
				if numEnabled <= maxShown then
					local r, g, b = smoothColor(data[4], totalCPU)
					GameTooltip:AddDoubleLine(data[2], string_format(usageString, data[4] / passedTime), 1, 1, 1, r, g, b)
				end
			end
		end

		if not isShiftKeyDown and (numEnabled > maxAddOns) then
			local hiddenUsage = 0
			for i = (maxAddOns + 1), numEnabled do
				hiddenUsage = hiddenUsage + infoTable[i][4]
			end
			GameTooltip:AddDoubleLine(string_format(showMoreString, numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), string_format(usageString, hiddenUsage / passedTime), 0.5, 0.7, 1, 0.5, 0.7, 1)
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:230:307|t " .. L["Collect Memory"] .. " ", 1, 1, 1, 0.5, 0.7, 1)
	if scriptProfileStatus then
		GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:333:411|t " .. L["SwitchMode"] .. " ", 1, 1, 1, 0.5, 0.7, 1)
	end
	GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t " .. L["CPU Usage"] .. ": " .. (GetCVarBool("scriptProfile") and enableString or disableString) .. " ", 1, 1, 1, 0.5, 0.7, 1)
	GameTooltip:Show()
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		setFrameRate()
		if SystemDataTextEntered then
			OnEnter()
		end

		self.timer = 0
	end
end

local function OnLeave()
	SystemDataTextEntered = false
	GameTooltip:Hide()
end

StaticPopupDialogs["CPUUSAGE"] = {
	text = "ReloadUI Required",
	button1 = APPLY,
	button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function()
		ReloadUI()
	end,
	whileDead = 1,
}

local function OnMouseUp(_, btn)
	if btn == "LeftButton" then
		if scriptProfileStatus then
			ResetCPUUsage()
			Module.CheckLoginTime = GetTime()
		end
		local before = gcinfo()
		collectgarbage("collect")
		K.Print(string_format("|cff66C6FF%s:|r %s", L["Memory Collected"], formatMemory(before - gcinfo())))
		OnEnter()
	elseif btn == "RightButton" and scriptProfileStatus then
		Module.ShowMemory = not Module.ShowMemory
		OnEnter()
	elseif btn == "MiddleButton" then
		if GetCVarBool("scriptProfile") then
			SetCVar("scriptProfile", 0)
		else
			SetCVar("scriptProfile", 1)
		end

		if GetCVarBool("scriptProfile") == scriptProfileStatus then
			StaticPopup_Hide("CPUUSAGE")
		else
			StaticPopup_Show("CPUUSAGE")
		end

		OnEnter()
	end
end

function Module:CreateSystemDataText()
	if not C["DataText"].System then
		return
	end

	SystemDataText = SystemDataText or CreateFrame("Frame", "KKUI_SystemDataText", UIParent)
	SystemDataText:SetSize(24, 24)

	SystemDataText.Texture = SystemDataText:CreateTexture(nil, "BACKGROUND")
	SystemDataText.Texture:SetPoint("LEFT", SystemDataText, "LEFT", 4, 0)
	SystemDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\fps.blp")
	SystemDataText.Texture:SetSize(15, 15)
	SystemDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	SystemDataText.Text = SystemDataText:CreateFontString("OVERLAY")
	SystemDataText.Text:SetFontObject(K.UIFont)
	SystemDataText.Text:SetPoint("LEFT", SystemDataText.Texture, "RIGHT", 4, 0)

	SystemDataText:SetScript("OnUpdate", OnUpdate)
	SystemDataText:SetScript("OnEnter", OnEnter)
	SystemDataText:SetScript("OnLeave", OnLeave)
	SystemDataText:SetScript("OnMouseUp", OnMouseUp)

	K.Mover(SystemDataText, "KKUI_SystemDataText", "KKUI_SystemDataText", { "TOPLEFT", UIParent, "TOPLEFT", 0, 0 })
end
