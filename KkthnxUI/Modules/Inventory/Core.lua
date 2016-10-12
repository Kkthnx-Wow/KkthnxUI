local K, C, L = select(2, ...):unpack()
if C.Bags.Enable ~= true then return end

local Inventory = CreateFrame("Frame")

K.Inventory = Inventory
