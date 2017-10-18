local K, C = unpack(select(2, ...))

-- local oldprint = print
-- function print(text, ...)
--     text = tostring(text)
--     for n = 1, select('#', ...) do
--         local e = select(n, ...)
--         text = text.." "..tostring(e)
--     end
--     local source = gsub(strtrim(debugstack(2, 1, 0), ".\n"), "Interface\\AddOns\\", "")
--     text = "KkthnxUI_Debug: print(\""..text.."\") called from "..source
--     return oldprint(text)
-- end

local string_format = string.format

local debugprofilestop = _G.debugprofilestop

local LoadedTime = debugprofilestop()
K.Print(string_format("Loaded in %dms (%.2f sec)", LoadedTime, LoadedTime / 1000))