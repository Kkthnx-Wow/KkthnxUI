local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local ipairs = _G.ipairs
local math_floor = _G.math.floor
local math_max = _G.math.max
local math_min = _G.math.min
local string_format = _G.string.format
local table_insert = _G.table.insert
local table_sort = _G.table.sort
local table_wipe = _G.table.wipe

local GetAddOnCPUUsage = _G.GetAddOnCPUUsage
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local GetCVarBool = _G.GetCVarBool
local GetFramerate = _G.GetFramerate
local GetNumAddOns = _G.GetNumAddOns
local GetTime = _G.GetTime
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsShiftKeyDown = _G.IsShiftKeyDown
local ResetCPUUsage = _G.ResetCPUUsage
local SetCVar = _G.SetCVar
local UpdateAddOnCPUUsage = _G.UpdateAddOnCPUUsage
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage
local VIDEO_OPTIONS_DISABLED = _G.VIDEO_OPTIONS_DISABLED
local VIDEO_OPTIONS_ENABLED = _G.VIDEO_OPTIONS_ENABLED
local collectgarbage = _G.collectgarbage
local gcinfo = _G.gcinfo

local disableString = "|cffff5555"..VIDEO_OPTIONS_DISABLED
local enableString = "|cff55ff55"..VIDEO_OPTIONS_ENABLED
local scriptProfileStatus = GetCVarBool("scriptProfile")
local showMoreString = "%d %s (%s)"
local usageColor = {0, 1, 0, 1, 1, 0, 1, 0, 0}
local usageString = "%.3f ms"

local maxAddOns = 12
local infoTable = {}
local entered

local function formatMemory(value)
	if value > 1024 then
		return string_format("%.1f mb", value / 1024)
	else
		return string_format("%.0f kb", value)
	end
end

local function sortByMemory(a, b)
	if a and b then
		return (a[3] == b[3] and a[2] < b[2]) or a[3] > b[3]
	end
end

local function sortByCPU(a, b)
	if a and b then
		return (a[4] == b[4] and a[2] < b[2]) or a[4] > b[4]
	end
end

local function smoothColor(cur, max)
	local r, g, b = K.oUF:RGBColorGradient(cur, max, unpack(usageColor))
	return r, g, b
end

local function BuildAddonList()
	local numAddons = GetNumAddOns()
	if numAddons == #infoTable then
		return
	end

	table_wipe(infoTable)
	for i = 1, numAddons do
		local _, title, _, loadable = GetAddOnInfo(i)
		if loadable then
			table_insert(infoTable, {i, title, 0, 0})
		end
	end
end

local function UpdateMemory()
	UpdateAddOnMemoryUsage()

	local total = 0
	for _, data in ipairs(infoTable) do
		if IsAddOnLoaded(data[1]) then
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
		if IsAddOnLoaded(data[1]) then
			local addonCPU = GetAddOnCPUUsage(data[1])
			data[4] = addonCPU
			total = total + addonCPU
		end
	end
	table_sort(infoTable, sortByCPU)

	return total
end

local function colorFPS(fps)
	if fps < 15 then
		return "|cffD80909"..fps
	elseif fps < 30 then
		return "|cffE8DA0F"..fps
	else
		return "|cff0CD809"..fps
	end
end

local function setFrameRate()
	local fps = math_floor(GetFramerate())
	Module.SystemDataTextFrame.Text:SetText(L["FPS"]..": "..colorFPS(fps))
end

local function OnEnter()
	entered = true

	if not next(infoTable) then
		BuildAddonList()
	end
	local isShiftKeyDown = IsShiftKeyDown()
	local maxShown = isShiftKeyDown and #infoTable or math_min(maxAddOns, #infoTable)

	GameTooltip:SetOwner(Module.SystemDataTextFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.SystemDataTextFrame))
	GameTooltip:ClearLines()

	if Module.ShowMemory or not scriptProfileStatus then
		local totalMemory = UpdateMemory()
		GameTooltip:AddDoubleLine("System", formatMemory(totalMemory), 0, 0.6, 1, 0.6, 0.8, 1)
		GameTooltip:AddLine(" ")

		local numEnabled = 0
		for _, data in ipairs(infoTable) do
			if IsAddOnLoaded(data[1]) then
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
			GameTooltip:AddDoubleLine(string_format(showMoreString, numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), formatMemory(hiddenMemory), 0.6, 0.8, 1, 0.6, 0.8, 1)
		end
	else
		local totalCPU = UpdateCPU()
		local passedTime = math_max(1, GetTime() - Module.CheckLoginTime)
		GameTooltip:AddDoubleLine(L["System"], string_format(usageString, totalCPU / passedTime, 0, 0.6, 1, 0.6, 0.8, 1))
		GameTooltip:AddLine(" ")

		local numEnabled = 0
		for _, data in ipairs(infoTable) do
			if IsAddOnLoaded(data[1]) then
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
			GameTooltip:AddDoubleLine(string_format(showMoreString, numEnabled - maxAddOns, L["Hidden"], L["Hold Shift"]), string_format(usageString, hiddenUsage / passedTime), 0.6, 0.8, 1, 0.6, 0.8, 1)
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:230:307|t "..L["Collect Memory"].." ", 1, 1, 1, 0.6, 0.8, 1)
	if scriptProfileStatus then
		GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:333:411|t "..L["SwitchMode"].." ", 1, 1, 1, 0.6, 0.8, 1)
	end
	GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t "..L["CPU Usage"]..": "..(GetCVarBool("scriptProfile") and enableString or disableString).." ", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:Show()
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		setFrameRate()
		if entered then
			OnEnter()
		end

		self.timer = 0
	end
end

local function OnLeave()
	entered = false
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

	Module.CheckLoginTime = GetTime()

	Module.SystemDataTextFrame = CreateFrame("Frame", "KKUI_SystemDataText", UIParent)
	Module.SystemDataTextFrame:SetSize(24, 24)

	Module.SystemDataTextFrame.Texture = Module.SystemDataTextFrame:CreateTexture(nil, "BACKGROUND")
	Module.SystemDataTextFrame.Texture:SetPoint("LEFT", Module.SystemDataTextFrame, "LEFT", 0, 0)
	Module.SystemDataTextFrame.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\help.blp")
	Module.SystemDataTextFrame.Texture:SetSize(24, 24)
	Module.SystemDataTextFrame.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	Module.SystemDataTextFrame.Text = Module.SystemDataTextFrame:CreateFontString("OVERLAY")
	Module.SystemDataTextFrame.Text:SetFontObject(K.GetFont(C["UIFonts"].DataTextFonts))
	Module.SystemDataTextFrame.Text:SetPoint("LEFT", Module.SystemDataTextFrame.Texture, "RIGHT", 0, 0)

	Module.SystemDataTextFrame:SetScript("OnUpdate", OnUpdate)
	Module.SystemDataTextFrame:SetScript("OnEnter", OnEnter)
	Module.SystemDataTextFrame:SetScript("OnLeave", OnLeave)
	Module.SystemDataTextFrame:SetScript("OnMouseUp", OnMouseUp)

	K.Mover(Module.SystemDataTextFrame, "KKUI_SystemDataText", "KKUI_SystemDataText", {"TOPLEFT", UIParent, "TOPLEFT", 0, 0})
end