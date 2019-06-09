local K, C = unpack(select(2, ...))
if not (C["Skins"].Details and K.CheckAddOnState("Details")) then
	return
end

local ReskinDetails = CreateFrame("Frame")
ReskinDetails:RegisterEvent("ADDON_LOADED")
ReskinDetails:RegisterEvent("PLAYER_ENTERING_WORLD")
ReskinDetails:SetScript("OnEvent", function()
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
		instance:SetBackdropTexture("None")
		instance:MenuAnchor(16, 3)
		instance:ToolbarMenuButtonsSize(1)
		instance:AttributeMenu(true, 0, 3, "KkthnxUI_Normal", 12, {1, 1, 1}, 1, false)
		instance:SetBarSettings(20, C["Skins"].ResetDetails and "KkthnxUI_Statusbar")
		instance:SetBarTextSettings(12, "KkthnxUI_Normal", nil, nil, nil, true, true, nil, nil, nil, nil, nil, nil, false, nil, false, nil)

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
		if not instance.baseframe then return end
		instance.baseframe:ClearAllPoints()
		instance.baseframe:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", x, y)
		instance:SetSize(width, height)
		instance:SaveMainWindowPosition()
		instance:RestoreMainWindowPosition()
		instance:LockInstance(true)
	end

	if C["Skins"].ResetDetails then
		local height = 105
		if instance1 then
			if instance2 then
				height = 96
				EmbedWindow(instance2, -3, 140, 250, height)
			end
			EmbedWindow(instance1, -350, 4, 250, height)
		end
	end

	local listener = Details:CreateEventListener()
	listener:RegisterEvent("DETAILS_INSTANCE_OPEN")
	function listener:OnDetailsEvent(event, instance)
		if event == "DETAILS_INSTANCE_OPEN" then
			setupInstance(instance)

			if instance:GetId() == 2 then
				instance1:SetSize(250, 95)
				EmbedWindow(instance, -3, 140, 250, 95)
			end
		end
	end

	KkthnxUIConfigShared[GetRealmName()][UnitName("player")].Skins.ResetDetails = false
end)