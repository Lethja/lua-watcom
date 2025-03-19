#!/usr/bin/env lua

sides = tonumber(arg[2]) or 6 dice = tonumber(arg[1]) or 1 roll = {}
for _ = 1, dice do table.insert(roll, math.floor(math.random(1, sides))) end
print("Dice rolled: " .. table.concat(roll, ", "))
