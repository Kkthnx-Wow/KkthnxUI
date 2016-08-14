local K, C, L, _ = select(2, ...):unpack()
if C.Minimap.Enable ~= true then return end

-- Minimap Farmmode
local Farm = false
local MiniSize = 150
local FarmSize = 230
function SlashCmdList.FARMMODE(msg, editbox)
	if Farm == false then
		if InCombatLockdown() then
			K.Print("|cffffe02e"..ERR_NOT_IN_COMBAT.."|r") return
		end
		Minimap:SetSize(FarmSize, FarmSize)
		MinimapAnchor:SetSize(FarmSize, FarmSize)
		Farm = true
		K.Print(L_MINIMAP_FARMMODE_ON)
	else
		Minimap:SetSize(MiniSize, MiniSize)
		MinimapAnchor:SetSize(MiniSize, MiniSize)
		Farm = false
		K.Print(L_MINIMAP_FARMMODE_OFF)
	end
end
SLASH_FARMMODE1 = "/farmmode"
SLASH_FARMMODE2 = "/fm"