local K, C, L, _ = select(2, ...):unpack()

local Forbidden = CreateFrame("Frame", nil, UIParent)
function Forbidden:StaticPopup_Show(which, text_arg1, text_arg2, data)
	if which == "ADDON_ACTION_FORBIDDEN" and ((text_arg1 or "")..(text_arg2 or "")):find("IsDisabledByParentalControls") then
		StaticPopup_Hide(which)
	end
end