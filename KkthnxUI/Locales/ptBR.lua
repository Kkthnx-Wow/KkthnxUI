local K, _, L = unpack(select(2, ...))

local _G = _G

local GetLocale = _G.GetLocale

if GetLocale() ~= "ptBR" then
    return
end