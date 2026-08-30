--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/SellJunk.lua
	Purpose:
		Sell grey (Poor) items the moment a merchant opens, through Blizzard's own
		bulk sell so it needs no bag frame of its own. This lives in Automation so it
		works even when the KkthnxUI bags are disabled and another bag addon is in use
		(GitHub #136). The toggle is re-checked on every merchant visit.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Automation")

local C_MerchantFrame = C_MerchantFrame
local GetMoney = GetMoney
local GetCoinTextureString = GetCoinTextureString

function Module:MERCHANT_SHOW_SELLJUNK()
	if not C.Automation.SellJunk or not (C_MerchantFrame and C_MerchantFrame.SellAllJunkItems) then
		return
	end

	local before = GetMoney()
	C_MerchantFrame.SellAllJunkItems()

	-- Report what came in, a frame later so the sale has settled.
	C_Timer.After(0.3, function()
		local gained = GetMoney() - before
		if gained > 0 then
			K.Print("Sold junk for %s", GetCoinTextureString(gained))
		end
	end)
end

function Module:SetupSellJunk()
	self:RegisterEvent("MERCHANT_SHOW", "MERCHANT_SHOW_SELLJUNK")
end
