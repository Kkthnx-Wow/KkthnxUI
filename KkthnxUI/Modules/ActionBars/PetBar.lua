local K, C, L = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local hooksecurefunc = _G.hooksecurefunc
local PetActionBar_HideGrid = _G.PetActionBar_HideGrid
local PetActionBar_ShowGrid = _G.PetActionBar_ShowGrid
local PetActionBar_UpdateCooldowns = _G.PetActionBar_UpdateCooldowns
local RegisterStateDriver = _G.RegisterStateDriver

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: PetActionBarFrame, PetHolder, RightBarMouseOver, HoverBind, PetBarMouseOver

if C["ActionBar"].PetBarHide then
	PetActionBarAnchor:Hide()
	return
end

-- Create bar
local PetBar = CreateFrame("Frame", "PetHolder", UIParent, "SecureHandlerStateTemplate")
PetBar:SetAllPoints(PetActionBarAnchor)

PetBar:RegisterEvent("PLAYER_LOGIN")
PetBar:RegisterEvent("PLAYER_CONTROL_LOST")
PetBar:RegisterEvent("PLAYER_CONTROL_GAINED")
PetBar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
PetBar:RegisterEvent("PET_BAR_UPDATE")
PetBar:RegisterEvent("PET_BAR_UPDATE_USABLE")
PetBar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
PetBar:RegisterEvent("PET_BAR_HIDE")
PetBar:RegisterEvent("UNIT_PET")
PetBar:RegisterEvent("UNIT_FLAGS")
PetBar:RegisterEvent("UNIT_AURA")
PetBar:SetScript("OnEvent", function(self, event, arg1)
	if event == "PLAYER_LOGIN" then
		K.StylePet()
		PetActionBar_ShowGrid = K.Noop
		PetActionBar_HideGrid = K.Noop
		PetActionBarFrame.showgrid = nil
		for i = 1, 10 do
			local button = _G["PetActionButton"..i]
			button:ClearAllPoints()
			button:SetParent(PetHolder)
			button:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
			if i == 1 then
				if C["ActionBar"].PetBarHorizontal == true then
					button:SetPoint("BOTTOMLEFT", 0, 0)
				else
					button:SetPoint("TOPLEFT", 0, 0)
				end
			else
				if C["ActionBar"].PetBarHorizontal == true then
					button:SetPoint("LEFT", _G["PetActionButton"..i - 1], "RIGHT", C["ActionBar"].ButtonSpace, 0)
				else
					button:SetPoint("TOP", _G["PetActionButton"..i - 1], "BOTTOM", 0, -C["ActionBar"].ButtonSpace)
				end
			end
			button:Show()
			self:SetAttribute("addchild", button)
		end
		RegisterStateDriver(self, "visibility", "[pet,novehicleui,nopossessbar,nopetbattle] show; hide")
		hooksecurefunc("PetActionBar_Update", K.PetBarUpdate)
	elseif event == "PET_BAR_UPDATE" or event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED"
	or event == "UNIT_FLAGS" or (event == "UNIT_PET" and arg1 == "player") or (arg1 == "pet" and event == "UNIT_AURA") then
		K.PetBarUpdate()
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		PetActionBar_UpdateCooldowns()
	end
end)

-- Mouseover bar
if C["ActionBar"].RightBarsMouseover == true and C["ActionBar"].PetBarHorizontal == false then
	for i = 1, NUM_PET_ACTION_SLOTS do
		local b = _G["PetActionButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function()
			RightBarMouseOver(1)
		end)
		b:HookScript("OnLeave", function()
			if not HoverBind.enabled then
				RightBarMouseOver(0)
			end
		end)
	end
end

if C["ActionBar"].PetBarMouseover == true and C["ActionBar"].PetBarHorizontal == true then
	for i = 1, NUM_PET_ACTION_SLOTS do
		local b = _G["PetActionButton"..i]
		b:SetAlpha(0)
		b:HookScript("OnEnter", function()
			PetBarMouseOver(1) end)
		b:HookScript("OnLeave", function()
			if not HoverBind.enabled then
				PetBarMouseOver(0)
			end
		end)
	end
end