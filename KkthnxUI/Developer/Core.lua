local K, C, L = unpack(select(2, ...))

-- Currenly Being Voted on @ KkthnxUI Discord
-- 8 = Yes | 8 = No

-- local function HideMadeByName(self)
-- 	for i = 2, self:NumLines() do
-- 		local line = _G[self:GetName().."TextLeft"..i]
-- 		local text = line and line:GetText()
-- 		if text and text ~= "" and string.match(text, string.gsub(_G.ITEM_CREATED_BY, "%%s", ".+")) then
-- 			line:SetText("")
-- 			break
-- 		end
-- 	end
-- end
-- GameTooltip:HookScript("OnTooltipSetItem", HideMadeByName)