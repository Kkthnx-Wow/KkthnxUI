local K, C, L, _ = select(2, ...):unpack()
if C.Minimap.Enable ~= true then return end

-- Minimap Farmmode
local farm = false
local minisize = 144
local farmsize = 300
function SlashCmdList.FARMMODE(msg, editbox)
	if farm == false then
		if InCombatLockdown() then
			K.Print("|cffffe02e"..ERR_NOT_IN_COMBAT.."|r") return
		end
		Minimap:SetSize(farmsize, farmsize)
		MinimapAnchor:SetSize(farmsize, farmsize)
		farm = true
		K.Print(L_MINIMAP_FARMMODE_ON)
	else
		Minimap:SetSize(minisize, minisize)
		MinimapAnchor:SetSize(minisize, minisize)
		farm = false
		K.Print(L_MINIMAP_FARMMODE_OFF)
	end

	local defaultBlip = "Interface\\Minimap\\ObjectIcons"
	Minimap:SetBlipTexture(defaultBlip)
end
SLASH_FARMMODE1 = "/farmmode"
SLASH_FARMMODE2 = "/fm"