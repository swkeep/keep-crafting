function RandomID(length)
    local string = ''
    for i = 1, length do
        local str = string.char(math.random(97, 122))
        if math.random(1, 2) == 1 then
            if math.random(1, 2) == 1 then str = str:upper() else str = str:lower() end
        else
            str = tostring(math.random(0, 9))
        end
        string = string .. str
    end
    return string
end
