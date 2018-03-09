local District = {data = ""}

District.__index = District

function byteToUint32(a,b,c,d)
    local _int = 0
    if a then
        _int = _int +  bit32.lshift(a, 24)
    end
    _int = _int + bit32.lshift(b, 16)
    _int = _int + bit32.lshift(c, 8)
    _int = _int + d
    if _int >= 0 then
        return _int
    else
        return _int + math.pow(2, 32)
    end
end

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter=='') then return false end
    local pos,arr = 0, {}
    for st,sp in function() return string.find(input, delimiter, pos, true) end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function District:new(name)
    -- body
    local self = {}
    local file = io.open(name)

    local data = file:read("*all")
    setmetatable(self, District)
    self.data = data

    return self
end

function District:find(ip)

    local data = self.data

    local indexSize = byteToUint32(string.byte(data, 1), string.byte(data, 2), string.byte(data, 3), string.byte(data, 4))

    local mid = 0
    local pos = 0
    local low = 0
    local high = (indexSize - 262148 - 262144) / 13 - 1
    
    local pos1 = 0
    local suffix = 0 --- end 
    local prefix = 0 --- start
    local ip1, ip2, ip3, ip4 = string.match(ip, "(%d+).(%d+).(%d+).(%d+)")
    local val = byteToUint32(ip1, ip2, ip3, ip4)
    
    while low <= high do
        mid = math.ceil((low + high) / 2)
        pos = mid * 13 + 262148
        
        prefix = byteToUint32(
            string.byte(data, pos + 1),
            string.byte(data, pos + 2),
            string.byte(data, pos + 3),
            string.byte(data, pos + 4)
        )
        suffix = byteToUint32(
            string.byte(data, pos + 5),
            string.byte(data, pos + 6),
            string.byte(data, pos + 7),
            string.byte(data, pos + 8)
        )
    
        if val < prefix then
            high = mid - 1
        elseif val > suffix then
            low = mid + 1        
        else
            off = byteToUint32(
                string.byte(data, pos + 12),
                string.byte(data, pos + 11),
                string.byte(data, pos + 10),
                string.byte(data, pos + 9)
            )
            len = string.byte(data, pos + 13)
            pos = off - 262144 + indexSize
            
            loc = string.split(string.sub(data, pos+1, pos+len), "\t")

            return loc
        end 
    end
end

return District