local K, C, L = unpack(select(2, ...))
if C.ActionBar.Enable ~= true or C.ActionBar.SelfCast ~= true then return end

-- Lua API
local _G = _G
local ipairs = ipairs

-- Wow API
local CreateFrame = CreateFrame
local UIParent = UIParent
local InCombatLockdown = InCombatLockdown
local IsLoggedIn = IsLoggedIn

local SelfCast = CreateFrame("frame", "RightClickSelfCast", UIParent)
SelfCast:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)

function SelfCast:PLAYER_REGEN_ENABLED()
	self:PLAYER_LOGIN()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self.PLAYER_REGEN_ENABLED = nil
end

function SelfCast:PLAYER_LOGIN()
	-- if we load/reload in combat don't try to set secure attributes or we get action_blocked errors
	 if InCombatLockdown() then self:RegisterEvent("PLAYER_REGEN_ENABLED") return end

	for id = 1, 12 do
		local button = _G["ActionButton"..id]
		if button ~= nil then
			button:SetAttribute("unit2", "player")
		end
	end

	self:UnregisterEvent("PLAYER_LOGIN")
	self.PLAYER_LOGIN = nil
end

if IsLoggedIn() then SelfCast:PLAYER_LOGIN() else SelfCast:RegisterEvent("PLAYER_LOGIN") end