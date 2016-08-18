local K, C, L, _ = select(2, ...):unpack()

local format = string.format
local match = string.match
local min, max = math.min, math.max
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local SetCVar = SetCVar

if (C.General.AutoScale) then
    C.General.UIScale = min(2, max(0.32, 768 / string.match(K.Resolution, "%d+x(%d+)")))
end

local function NeedReloadUI()
	local Resolution = Display_ResolutionDropDown
	local x, y = Resolution:getValues()
	local OldRatio = K.ScreenWidth / K.ScreenHeight
	local NewRatio = x / y
	local OldReso = K.Resolution
	local NewReso = x.."x"..y

	if (OldRatio == NewRatio) and (OldReso ~= NewReso) then
		ReloadUI()
	end
end

-- PIXELPERFECT SCRIPT FOR KKTHNXUI.
local PixelPerfect = CreateFrame("Frame")
PixelPerfect:RegisterEvent("PLAYER_ENTERING_WORLD")
PixelPerfect:SetScript("OnEvent", function(self, event)
	-- ENABLE UISCALE FOR KKTHNXUI
	local UseUIScale = GetCVar("useUiScale")
	if (UseUIScale ~= "1") then
		SetCVar("useUiScale", 1)
	end

	-- SET OUR NEW UISCALE NOW IF IT DOESN"T MATCH BLIZZARD SAVED UISCALE.
	if (format("%.2f", GetCVar("uiScale")) ~= format("%.2f", C.General.UIScale)) then
		-- SET NEW UISCALE
		SetCVar("uiScale", C.General.UIScale)
	end

	-- ALLOW 4K AND WQHD RESOLUTION TO HAVE AN UISCALE LOWER THAN 0.64, WHICH IS
	-- THE LOWEST VALUE OF UIPARENT SCALE BY DEFAULT
	if (C.General.UIScale < 0.64) then
		UIParent:SetScale(C.General.UIScale)
	end

	VideoOptionsFrameOkay:HookScript("OnClick", NeedReloadUI)
	VideoOptionsFrameApply:HookScript("OnClick", NeedReloadUI)

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)