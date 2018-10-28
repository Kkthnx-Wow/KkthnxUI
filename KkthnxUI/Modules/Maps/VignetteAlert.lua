local K, C = unpack(select(2, ...))
if C["Minimap"].VignetteAlert ~= true then
	return
end

local Module = K:NewModule("VignetteAlert", "AceEvent-3.0")

local _G = _G

function Module:VIGNETTE_MINIMAP_UPDATED(_, id)
	if not id then
		return
	end

	self.vignettes = self.vignettes or {}
	if self.vignettes[id] then
		return
	end

	local vignetteInfo = _G.C_VignetteInfo.GetVignetteInfo(id)
	if not vignetteInfo then
		return
	end

	local filename, width, height, txLeft, txRight, txTop, txBottom = _G.GetAtlasInfo(vignetteInfo.atlasName)
	if not filename then
		return
	end
	local atlasWidth = width / (txRight-txLeft)
	local atlasHeight = height / (txBottom-txTop)
	local str = string.format("|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t", filename, 0, 0, atlasWidth, atlasHeight, atlasWidth * txLeft, atlasWidth * txRight, atlasHeight * txTop, atlasHeight * txBottom)

	_G.PlaySoundFile("Sound\\Interface\\RaidWarning.ogg")
	_G.RaidNotice_AddMessage(RaidWarningFrame, str .. " " .. vignetteInfo.name .. " spotted!", _G.ChatTypeInfo["RAID_WARNING"])
	_G.print(str.." "..vignetteInfo.name,"spotted!")

	self.vignettes[id] = true
end

function Module:OnEnable()
	self:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
end