local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CanExitVehicle = _G.CanExitVehicle
local CreateFrame = _G.CreateFrame
local MainMenuBarVehicleLeaveButton_OnEnter = _G.MainMenuBarVehicleLeaveButton_OnEnter
local RegisterStateDriver = _G.RegisterStateDriver
local TaxiRequestEarlyLanding = _G.TaxiRequestEarlyLanding
local UIParent = _G.UIParent
local UnitOnTaxi = _G.UnitOnTaxi
local VehicleExit = _G.VehicleExit

local cfg = C.Bars.BarVehicle
local margin, padding = C.Bars.BarMargin, C.Bars.BarPadding

function Module:UpdateVehicleButton()
	local frame = _G["KKUI_ActionBarExit"]
	if not frame then
		return
	end

	local size = C["ActionBar"].VehButtonSize
	local framSize = size + 2 * padding
	frame.buttons[1]:SetSize(size, size)
	frame:SetSize(framSize, framSize)
	frame.mover:SetSize(framSize, framSize)
end

function Module:CreateLeaveVehicle()
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBarExit", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Leave Vehicle Button", "LeaveVehicle", { "BOTTOM", UIParent, "BOTTOM", 260, 4 })
	-- stylua: ignore
	local button = CreateFrame("CheckButton", "KKUI_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
	table_insert(buttonList, button)
	button:SetPoint("BOTTOMLEFT", frame, padding, padding)
	button:RegisterForClicks("AnyUp")
	button.icon:SetTexture("INTERFACE\\VEHICLES\\UI-Vehicles-Button-Exit-Up")
	button.icon:SetTexCoord(0.216, 0.784, 0.216, 0.784)
	button.icon:SetDrawLayer("ARTWORK")
	button.icon.__lockdown = true

	button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
	button:SetScript("OnLeave", K.HideTooltip)
	button:SetScript("OnClick", function(self)
		if UnitOnTaxi("player") then
			TaxiRequestEarlyLanding()
		else
			VehicleExit()
		end
		self:SetChecked(true)
	end)

	button:SetScript("OnShow", function(self)
		self:SetChecked(false)
	end)

	frame.buttons = buttonList

	frame.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
	RegisterStateDriver(frame, "exit", frame.frameVisibility)

	frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
	if not CanExitVehicle() then
		frame:Hide()
	end

	if cfg.fader then
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end
