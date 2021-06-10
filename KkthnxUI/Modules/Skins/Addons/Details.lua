local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function ReskinDetails()
	if not C["Skins"].Details then
		return
	end

	local Details = _G.Details

	-- instance table can be nil sometimes
	Details.tabela_instancias = Details.tabela_instancias or {}
	Details.instances_amount = Details.instances_amount or 5

	-- toggle windows on init
	Details:ReabrirTodasInstancias()

	local function setupInstance(instance)
		if instance.styled then
			return
		end

		if not instance.baseframe then
			return
		end

		instance:ChangeSkin("Minimalistic")
		instance:InstanceWallpaper(false)
		instance:DesaturateMenu(true)
		instance:HideMainIcon(false)
		instance:SetBackdropTexture("Details Ground")
		instance:MenuAnchor(16, 3)
		instance:ToolbarMenuButtonsSize(1)
		instance:AttributeMenu(true, 0, 3, "KkthnxUIFont", 12, {1, 1, 1}, 1, false)
		instance:SetBarSettings(KkthnxUIDB.Variables["ResetDetails"] and 20 or nil, KkthnxUIDB.Variables["ResetDetails"] and "KkthnxUIStatusbar" or nil)
		instance:SetBarTextSettings(KkthnxUIDB.Variables["ResetDetails"] and 12 or nil, "KkthnxUIFont", nil, nil, nil, true, true, nil, nil, nil, nil, nil, nil, false, nil, false, nil)

		instance.baseframe:CreateBackdrop()
		instance.baseframe.Backdrop:SetPoint("TOPLEFT", -1, 18)
		instance.baseframe.Backdrop:SetPoint("TOPRIGHT", 1, 0)

		instance.styled = true
	end

	local index = 1
	local instance = Details:GetInstance(index)
	while instance do
		setupInstance(instance)
		index = index + 1
		instance = Details:GetInstance(index)
	end

	-- Reanchor
	local instance1 = Details:GetInstance(1)
	local instance2 = Details:GetInstance(2)

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

	if KkthnxUIDB.Variables["ResetDetails"] then
		local height = 126
		if instance1 then
			if instance2 then
				height = 112
				EmbedWindow(instance2, -3, 140, 260, height)
			end
			EmbedWindow(instance1, -370, 4, 260, height)
		end
	end

	local listener = Details:CreateEventListener()
	listener:RegisterEvent("DETAILS_INSTANCE_OPEN")
	function listener:OnDetailsEvent(event, instance)
		if event == "DETAILS_INSTANCE_OPEN" then
			if not instance.styled and instance:GetId() == 2 then
				instance1:SetSize(260, 112)
				EmbedWindow(instance, -3, 140, 250, 112)

			end
			setupInstance(instance)
		end
	end

	-- Numberize -- Throws an error currently.
	-- local current = C["General"].NumberPrefixStyle.Value
	-- if current and current < 3 then
	-- 	Details.numerical_system = current
	-- 	Details:SelectNumericalSystem()
	-- end

	Details.OpenWelcomeWindow = function()
		if instance1 then
			EmbedWindow(instance1, -370, 4, 260, 126)
			instance1:SetBarSettings(20, "KkthnxUIStatusbar")
			instance1:SetBarTextSettings(12, "KkthnxUIFont", nil, nil, nil, true, true, nil, nil, nil, nil, nil, nil, false, nil, false, nil)
		end
	end

	KkthnxUIDB.Variables["ResetDetails"] = false
end

Module:LoadWithAddOn("Details", "Details", ReskinDetails)