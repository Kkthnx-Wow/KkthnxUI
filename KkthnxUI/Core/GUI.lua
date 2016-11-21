local K, C, L = select(2, ...):unpack()
if not IsAddOnLoaded("KkthnxUI_Config") then return end

local realm = K.Realm
local name = UnitName("player")

if not KkthnxUIConfigAll then KkthnxUIConfigAll = {} end

local tca = KkthnxUIConfigAll
local private = KkthnxUIConfigPrivate
local public = KkthnxUIConfigPublic

if not tca[realm] then tca[realm] = {} end
if not tca[realm][name] then tca[realm][name] = false end

if tca[realm][name] == true and not private then return end
if tca[realm][name] == false and not public then return end

local setting
if tca[realm][name] == true then setting = private else setting = public end

for group,options in pairs(setting) do
	if C[group] then
		local count = 0
		for option,value in pairs(options) do
			if C[group][option] ~= nil then
				if C[group][option] == value then
					setting[group][option] = nil
				else
					count = count + 1
					C[group][option] = value
				end
			end
		end
		if count == 0 then setting[group] = nil end
	else
		setting[group] = nil
	end
end