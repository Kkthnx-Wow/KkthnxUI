local K = unpack(select(2, ...))

local _G = _G
local pairs = _G.pairs
local string_format = string.format
local table_wipe = table.wipe
local tonumber = tonumber
local tostring = tostring
local type = type

local COOLDOWN_TYPE_LOSS_OF_CONTROL = _G.COOLDOWN_TYPE_LOSS_OF_CONTROL
local CreateFrame = _G.CreateFrame
local debugprofilestop = _G.debugprofilestop
local GetAddOnCPUUsage = _G.GetAddOnCPUUsage
local GetCVarBool = _G.GetCVarBool
local GetFunctionCPUUsage = _G.GetFunctionCPUUsage
local hooksecurefunc = _G.hooksecurefunc
local ResetCPUUsage = _G.ResetCPUUsage
local UpdateAddOnCPUUsage = _G.UpdateAddOnCPUUsage

hooksecurefunc(
	"CooldownFrame_Set",
	function(self)
		if self.currentCooldownType == COOLDOWN_TYPE_LOSS_OF_CONTROL then
			self:SetCooldown(0, 0)
		end
	end
)

-- CPU Stuff
local CPU_USAGE = {}
local function CompareCPUDiff(showall, minCalls)
	local greatestUsage, greatestCalls, greatestName, newName, newFunc
	local greatestDiff, lastModule, mod, newUsage, calls, differance = 0

	for name, oldUsage in pairs(CPU_USAGE) do
		newName, newFunc = name:match("^([^:]+):(.+)$")
		if not newFunc then
			K.Print("CPU_USAGE:", name, newFunc)
		else
			if newName ~= lastModule then
				mod = K:GetModule(newName, true) or K
				lastModule = newName
			end
			newUsage, calls = GetFunctionCPUUsage(mod[newFunc], true)
			differance = newUsage - oldUsage
			if showall and (calls > minCalls) then
				K.Print(
					"Name(" ..
						name .. ") Calls(" .. calls .. ") Diff(" .. (differance > 0 and string_format("%.3f", differance) or 0) .. ")"
				)
			end
			if (differance > greatestDiff) and calls > minCalls then
				greatestName, greatestUsage, greatestCalls, greatestDiff = name, newUsage, calls, differance
			end
		end
	end

	if greatestName then
		K.Print(
			greatestName ..
				" had the CPU usage difference of: " ..
					(greatestUsage > 0 and string_format("%.3f", greatestUsage) or 0) ..
						"ms. And has been called " .. greatestCalls .. " times."
		)
	else
		K.Print("CPU Usage: No CPU Usage differences found.")
	end

	table_wipe(CPU_USAGE)
end

function K:GetTopCPUFunc(msg)
	if not GetCVarBool("scriptProfile") then
		K.Print(
			"For `/cpuusage` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0."
		)
		return
	end

	local module, showall, delay, minCalls = msg:match("^([^%s]+)%s*([^%s]*)%s*([^%s]*)%s*(.*)$")
	local checkCore, mod = (not module or module == "") and "K"

	showall = (showall == "true" and true) or false
	delay = (delay == "nil" and nil) or tonumber(delay) or 5
	minCalls = (minCalls == "nil" and nil) or tonumber(minCalls) or 15

	table_wipe(CPU_USAGE)
	if module == "all" then
		for moduName, modu in pairs(self.modules) do
			for funcName, func in pairs(modu) do
				if (funcName ~= "GetModule") and (type(func) == "function") then
					CPU_USAGE[moduName .. ":" .. funcName] = GetFunctionCPUUsage(func, true)
				end
			end
		end
	else
		if not checkCore then
			mod = self:GetModule(module, true)
			if not mod then
				self:Print(module .. " not found, falling back to checking core.")
				mod, checkCore = self, "K"
			end
		else
			mod = self
		end
		for name, func in pairs(mod) do
			if (name ~= "GetModule") and type(func) == "function" then
				CPU_USAGE[(checkCore or module) .. ":" .. name] = GetFunctionCPUUsage(func, true)
			end
		end
	end

	self:Delay(delay, CompareCPUDiff, showall, minCalls)
	self:Print(
		"Calculating CPU Usage differences (module: " ..
			(checkCore or module) ..
				", showall: " .. tostring(showall) .. ", minCalls: " .. tostring(minCalls) .. ", delay: " .. tostring(delay) .. ")"
	)
end

local num_frames = 0
local function OnUpdate()
	num_frames = num_frames + 1
end

local f = CreateFrame("Frame")
f:Hide()
f:SetScript("OnUpdate", OnUpdate)

local toggleMode, debugTimer = false, 0
function K:GetCPUImpact()
	if not GetCVarBool("scriptProfile") then
		K.Print(
			"For `/cpuimpact` to work, you need to enable script profiling via: `/console scriptProfile 1` then reload. Disable after testing by setting it back to 0."
		)
		return
	end

	if (not toggleMode) then
		ResetCPUUsage()
		toggleMode, num_frames, debugTimer = true, 0, debugprofilestop()
		self:Print("CPU Impact being calculated, type /cpuimpact to get results when you are ready.")
		f:Show()
	else
		f:Hide()
		local ms_passed = debugprofilestop() - debugTimer
		UpdateAddOnCPUUsage()

		local per, passed =
			((num_frames == 0 and 0) or (GetAddOnCPUUsage("KkthnxUI") / num_frames)),
			((num_frames == 0 and 0) or (ms_passed / num_frames))
		self:Print(
			"Consumed " ..
				(per and per > 0 and string_format("%.3f", per) or 0) ..
					"ms per frame. Each frame took " ..
						(passed and passed > 0 and string_format("%.3f", passed) or 0) .. "ms to render."
		)
		toggleMode = false
	end
end

K:RegisterChatCommand("cpuimpact", "GetCPUImpact")
K:RegisterChatCommand("cpuusage", "GetTopCPUFunc")
