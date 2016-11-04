local K, C, L = select(2, ...):unpack()

-- LUA API
local _G = _G

-- WOW API
local CreateFrame = CreateFrame

-- Based on fane(by haste)
if C.Chat.TabsMouseover == true then
	CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
	CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
	CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
end

local Fane = CreateFrame("Frame")

local updateFS = function(self, inc, ...)
	local fstring = self:GetFontString()

	-- FONT AND FONT STYLE FOR CHAT
	if C.Chat.TabsOutline == true then
		fstring:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		fstring:SetShadowOffset(0, -0)
	else
		fstring:SetFont(C.Media.Font, C.Media.Font_Size)
		fstring:SetShadowOffset(K.Mult, -K.Mult) -- Temp
	end

	if (...) then
		fstring:SetTextColor(...)
	end
end

local OnEnter = function(self)
	local emphasis = _G["ChatFrame"..self:GetID().."TabFlash"]:IsShown()
	updateFS(self, emphasis, K.Color.r, K.Color.g, K.Color.b)
end

local OnLeave = function(self)
	local r, g, b
	local id = self:GetID()
	local emphasis = _G["ChatFrame"..id.."TabFlash"]:IsShown()

	if _G["ChatFrame"..id] == SELECTED_CHAT_FRAME then
		r, g, b = K.Color.r, K.Color.g, K.Color.b
	elseif emphasis then
		r, g, b = 1, 0, 0
	else
		r, g, b = 1, 1, 1
	end

	updateFS(self, emphasis, r, g, b)
end

local ChatFrame2_SetAlpha = function(self, alpha)
	if CombatLogQuickButtonFrame_Custom then
		CombatLogQuickButtonFrame_Custom:SetAlpha(alpha)
	end
end

local ChatFrame2_GetAlpha = function(self)
	if CombatLogQuickButtonFrame_Custom then
		return CombatLogQuickButtonFrame_Custom:GetAlpha()
	end
end

local faneifyTab = function(frame, sel)
	local i = frame:GetID()

	if not frame.Fane then
		frame:HookScript("OnEnter", OnEnter)
		frame:HookScript("OnLeave", OnLeave)
		if C.Chat.TabsMouseover ~= true then
			frame:SetAlpha(1)

			if i ~= 2 then
				-- MIGHT NOT BE THE BEST SOLUTION, BUT WE AVOID HOOKING INTO THE UIFRAMEFADE
				-- SYSTEM THIS WAY.
				frame.SetAlpha = UIFrameFadeRemoveFrame
			else
				frame.SetAlpha = ChatFrame2_SetAlpha
				frame.GetAlpha = ChatFrame2_GetAlpha

				-- WE DO THIS HERE AS PEOPLE MIGHT BE USING ADDONLOADER TOGETHER WITH FANE
				if CombatLogQuickButtonFrame_Custom then
					CombatLogQuickButtonFrame_Custom:SetAlpha(0.4)
				end
			end
		end

		frame.Fane = true
	end

	-- WE CAN'T TRUST SEL
	if i == SELECTED_CHAT_FRAME:GetID() then
		updateFS(frame, nil, K.Color.r, K.Color.g, K.Color.b)
	else
		updateFS(frame, nil, 1, 1, 1)
	end
end

hooksecurefunc("FCF_StartAlertFlash", function(frame)
	local tab = _G["ChatFrame"..frame:GetID().."Tab"]
	updateFS(tab, true, 1, 0, 0)
end)

hooksecurefunc("FCFTab_UpdateColors", faneifyTab)

for i = 1, NUM_CHAT_WINDOWS do
	faneifyTab(_G["ChatFrame"..i.."Tab"])
end

function Fane:ADDON_LOADED(event, addon)
	if addon == "Blizzard_CombatLog" then
		self:UnregisterEvent(event)
		self[event] = nil

		return CombatLogQuickButtonFrame_Custom:SetAlpha(0.4)
	end
end
Fane:RegisterEvent("ADDON_LOADED")