local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")
local TT = K:GetModule("Tooltip")

function Module:ReskinWorldQuestTab()
	if not IsAddOnLoaded("WorldQuestTab") then
		return
	end

	-- for _, Button in ipairs(WQT_QuestScrollFrame.buttons) do
    --     Button.Rewards:SetSize(26, 26)
    --     Button.Rewards:CreateBorder()
    --     Button.Rewards.Icon:SetTexCoord(unpack(K.TexCoords))
	-- 	Button.Rewards.IconBorder:SetAlpha(0)
    --     hooksecurefunc(Button.Rewards.IconBorder, "SetVertexColor", function(self, r, g, b)
    --         Button.Rewards:SetBackdropBorderColor(r, g, b)
    --     end)
	-- end

	for _, Tooltip in pairs({WQT_CompareTooltip1, WQT_CompareTooltip2, WQT_Tooltip}) do
        TT.ReskinTooltip(Tooltip)
	end
end