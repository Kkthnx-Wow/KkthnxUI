local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Skins")

local _G = _G

local function SetupInstance(instance)
	if instance.styled then
		return
	end

	-- if window is hidden on init, show it and hide later
	if not instance.baseframe then
		instance:ShowWindow()
		instance.wasHidden = true
	end

	-- reset texture if using Details default texture
	local needReset = instance.row_info.texture == "BantoBar"
	instance:ChangeSkin("Minimalistic")
	instance:InstanceWallpaper(false)
	instance:DesaturateMenu(true)
	instance:HideMainIcon(false)
	instance:SetBackdropTexture("None") -- if block window from resizing, then back to "Details Ground", needs review
	instance:MenuAnchor(16, 3)
	instance:ToolbarMenuButtonsSize(1)
	instance:AttributeMenu(true, 0, 3, K.UIFont, 12, { 1, 1, 1 }, 1, false)
	instance:SetBarSettings(needReset and 20, needReset and "KkthnxUIStatusbar")
	instance:SetBarTextSettings(needReset and 12, K.UIFont, nil, nil, nil, false, false, nil, nil, nil, nil, nil, nil, true, { 0, 0, 0, 1 }, true, { 0, 0, 0, 1 })
	instance.baseframe:CreateBackdrop()
	instance.baseframe.Backdrop:SetPoint("TOPLEFT", -1, 18)
	instance.baseframe.Backdrop:SetPoint("TOPRIGHT", 1, 0)

	instance.styled = true
end

local function EmbedWindow(instance, x, y, width, height)
	if not instance.baseframe then
		return
	end

	instance.baseframe:ClearAllPoints()
	instance.baseframe:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", x, y)
	instance:SetSize(width, height)
	instance:SaveMainWindowPosition()
	instance:RestoreMainWindowPosition()
	instance:LockInstance(true)
end

local function isDefaultOffset(offset)
	return offset and abs(offset) < 10
end

local function IsDefaultAnchor(instance)
	local frame = instance and instance.baseframe
	if not frame then
		return
	end

	local relF, _, relT, x, y = frame:GetPoint()
	return (relF == "CENTER" and relT == "CENTER" and isDefaultOffset(x) and isDefaultOffset(y))
end

function Module:ResetDetailsAnchor(force)
	local Details = _G.Details
	if not Details then
		return
	end

	local height = 126
	local instance1 = Details:GetInstance(1)
	local instance2 = Details:GetInstance(2)
	if instance1 and (force or IsDefaultAnchor(instance1)) then
		if instance2 then
			height = 112
			EmbedWindow(instance2, -3, 140, 260, height)
		end
		EmbedWindow(instance1, -370, 4, 260, height)
	end

	return instance1
end

local function ReskinDetails()
	if not C["Skins"].Details then
		return
	end

	local Details = _G.Details
	-- instance table can be nil sometimes
	Details.tabela_instancias = Details.tabela_instancias or {}
	Details.instances_amount = Details.instances_amount or 5

	local index = 1
	local instance = Details:GetInstance(index)
	while instance do
		SetupInstance(instance)
		index = index + 1
		instance = Details:GetInstance(index)
	end

	-- Reanchor
	local instance1 = Module:ResetDetailsAnchor()

	local listener = Details:CreateEventListener()
	listener:RegisterEvent("DETAILS_INSTANCE_OPEN")
	function listener:OnDetailsEvent(event, instance)
		if event == "DETAILS_INSTANCE_OPEN" then
			if not instance.styled and instance:GetId() == 2 then
				instance1:SetSize(260, 112)
				EmbedWindow(instance, -3, 140, 250, 112)
			end
			SetupInstance(instance)
		end
	end

	-- Numberize
	local current = C["General"].NumberPrefixStyle.Value
	if current < 3 then
		Details.numerical_system = current
		Details:SelectNumericalSystem()
	end

	-- Reset to one window
	Details.OpenWelcomeWindow = function()
		if instance1 then
			EmbedWindow(instance1, -370, 4, 260, 126)
			instance1:SetBarSettings(20, "KkthnxUIStatusbar")
			instance1:SetBarTextSettings(12, K.UIFont, nil, nil, nil, false, false, nil, nil, nil, nil, nil, nil, true, { 0.04, 0.04, 0.04, 0.9 }, true, { 0.04, 0.04, 0.04, 0.9 })
		end
	end
end

Module:RegisterSkin("Details", ReskinDetails)
