local K = unpack(select(2, ...))
local Module = K:GetModule("Tooltip")

local _G = _G
local select = _G.select
local ipairs = _G.ipairs

local COLLECTED = _G.COLLECTED
local C_MountJournal_GetMountIDs = _G.C_MountJournal.GetMountIDs
local C_MountJournal_GetMountInfoByID = _G.C_MountJournal.GetMountInfoByID
local C_MountJournal_GetMountInfoExtraByID = _G.C_MountJournal.GetMountInfoExtraByID
local NOT_COLLECTED = _G.NOT_COLLECTED
local UnitAura = _G.UnitAura
local UnitIsPlayer = _G.UnitIsPlayer
local UnitIsUnit = _G.UnitIsUnit
local hooksecurefunc = _G.hooksecurefunc

local MountCache = {}
function Module:MountSourceSetup(...)
	if not UnitIsPlayer(...) or UnitIsUnit(..., "player") then
		return
	end

	local id = select(10, UnitAura(...))

	if id and MountCache[id] then
		local text = NOT_COLLECTED
		local r, g, b = 1, 0, 0
		local collected = select(11, C_MountJournal_GetMountInfoByID(MountCache[id]))

		if collected then
			text = COLLECTED
			r, g, b = 0, 1, 0
		end

		self:AddLine(" ")
		self:AddLine(text, r, g, b)

		local sourceText = select(3, C_MountJournal_GetMountInfoExtraByID(MountCache[id]))
		self:AddLine(sourceText, 1, 1, 1)

		self:Show()
	end
end

function Module:CreateMountSource()
	for _, mountID in ipairs(C_MountJournal_GetMountIDs()) do
		MountCache[select(2, C_MountJournal_GetMountInfoByID(mountID))] = mountID
	end

	hooksecurefunc(GameTooltip, "SetUnitAura", Module.MountSourceSetup)
end