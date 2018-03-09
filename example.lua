
local city = require("datx.city")

local c = city:new("/home/frk/Downloads/mydata4vipday4.datx")

local data = c:find("223.221.121.0")

print(data[1])
print(data[2])
print(data[3])

local loc = c:location(data)

print(loc.country)
print(loc.province)
print(loc.city)
print(loc.is_base_station)

local district = require("datx.district")

local dis = district:new("/home/frk/Downloads/quxian.datx")
local loc2 = dis:find("223.255.127.255")
if loc2 == nil then
    print("is nil")
else
    print(loc2[1])
    print(loc2[2])
    print(loc2[3])
    print(loc2[4])
end     

local base_station = require("datx.base_station")

local bst = base_station:new("/home/frk/Downloads/station_ip.datx")

local loc3 = bst:find("223.221.121.0")

print(loc3[5])
print(loc3[6])