local K, C, L = unpack(select(2, ...))
if not K.IsDeveloper and not K.IsDeveloperRealm then return end

-- Always debug our temp code.
if LibDebug then LibDebug() end