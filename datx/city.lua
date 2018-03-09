local City = {data = ""}

City.__index = City

local function byteToUint32(a,b,c,d)
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

local function string.split(input, delimiter)
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

-- 返回数据模版
local _template = {
    "country", -- // 国家
    "province", -- // 省会或直辖市（国内）
    "city", -- // 地区或城市 （国内）
    "org", -- // 学校或单位 （国内）
    "isp", -- // 运营商字段（只有购买了带有运营商版本的数据库才会有）
    "lat", -- // 纬度     （每日版本提供）
    "lng", -- // 经度     （每日版本提供）
    "time_zone", -- // 时区一, 可能不存在  （每日版本提供）
    "time_zone_2", -- // 时区二, 可能不存在  （每日版本提供）
    "china_code", -- // 中国行政区划代码    （每日版本提供）
    "phone_prefix", -- // 国际电话代码        （每日版本提供）
    "iso_2", -- // 国家二位代码        （每日版本提供）
    "continent", -- // 世界大洲代码        （每日版本提供）
    "is_idc", -- // 三合一版本提供
    "is_base_station" -- // 三合一版本提供
}

-- 用模版格式化数据
local function to_table(data)
    local r = {}
    for k, v in ipairs(data) do
        r[_template[k]] = v
    end

    return r
end

function City:new(name)
    local self = {}
    local file = io.open(name)

    local data = file:read("*all")
    setmetatable(self, City)
    self.data = data

    return self
end

function City:find(ip)

    local data = self.data
    local indexSize = byteToUint32(string.byte(data, 1), string.byte(data, 2), string.byte(data, 3), string.byte(data, 4))

    local mid = 0
    local pos = 0
    local low = 0
    local high = (indexSize - 262148 - 262144) / 9 - 1
    
    local pos1 = 0
    local suffix = 0 --- end 
    local prefix = 0 --- start
    local ip1, ip2, ip3, ip4 = string.match(ip, "(%d+).(%d+).(%d+).(%d+)")
    local val = byteToUint32(ip1, ip2, ip3, ip4)
    
    while low <= high do
        mid = math.ceil((low + high) / 2)
        pos = mid * 9 + 262148
        if mid > 0 then
            pos1 = math.ceil(mid - 1) * 9 + 262148
            prefix = byteToUint32(
                string.byte(data, pos1+1),
                string.byte(data, pos1+2),
                string.byte(data, pos1+3),
                string.byte(data, pos1+4)
            )
        end
    
        suffix = byteToUint32(
            string.byte(data, pos + 1),
            string.byte(data, pos + 2),
            string.byte(data, pos + 3),
            string.byte(data, pos + 4)
        )
    
        if val < prefix then
            high = mid - 1
        elseif val > suffix then
            low = mid + 1        
        else
            off = byteToUint32(
                0,
                string.byte(data, pos + 7),
                string.byte(data, pos + 6),
                string.byte(data, pos + 5)
            )
            len = byteToUint32(
                0,
                0,
                string.byte(data, pos + 8),
                string.byte(data, pos + 9)
            )
            pos = off - 262144 + indexSize
            
            loc = string.split(string.sub(data, pos+1, pos+len), "\t")

            return loc
        end 
    end
end

function City:location(l)
    return to_table(l)
end

return City