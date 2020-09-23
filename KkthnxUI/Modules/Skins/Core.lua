local K, C = unpack(select(2, ...))
local Module = K:NewModule("Skins")

local _G = _G
local pairs = _G.pairs
local type = _G.type

Module.NewSkin = {}
Module.NewSkin["KkthnxUI"] = {}
K:RegisterEvent("ADDON_LOADED", function(_, addon)
	if IsAddOnLoaded("Skinner") or IsAddOnLoaded("Aurora") or not C["Skins"].BlizzardFrames then
		K:UnregisterEvent("ADDON_LOADED")
		return
	end

	for _addon, skinfunc in pairs(Module.NewSkin) do
		if type(skinfunc) == "function" then
			if _addon == addon then
				if skinfunc then
					skinfunc()
				end
			end
		elseif type(skinfunc) == "table" then
			if _addon == addon then
				for _, skinfunc in pairs(Module.NewSkin[_addon]) do
					if skinfunc then
						skinfunc()
					end
				end
			end
		end
	end
end)

function Module:OnEnable()
	self:ReskinBartender4()
	self:ReskinBigWigs()
	self:ReskinBugSack()
	self:ReskinChocolateBar()
	self:ReskinDeadlyBossMods()
	self:ReskinDetails()
	self:ReskinHekili()
	self:ReskinImmersion()
	-- self:ReskinOPie() -- Broken atm
	self:ReskinRaiderIO()
	self:ReskinSimulationcraft()
	self:ReskinSkada()
	self:ReskinSpy()
	self:ReskinTellMeWhen()
	self:ReskinTitanPanel()
	self:ReskinWeakAuras()
end