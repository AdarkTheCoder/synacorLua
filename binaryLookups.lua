lookup = {}

local oct2bin = {
	["0"] = "000";
	["1"] = "001";
	["2"] = "010";
	["3"] = "011";
	["4"] = "100";
	["5"] = "101";
	["6"] = "110";
	["7"] = "111";
}
local bin2dec = {}
local dec2bin = {}

--Technically, the below loop should be converted to two metatable __index functions, as was done below,
--but I'm lazy and 2^16 - 1 is a small enough range that the runtime is barely affected.
for i = 0, 2^16 - 1 do
	local oct = string.format("%o", i)
	oct = ('0'):rep(6 - #oct) .. oct

	local t = {}
	table.insert(t, tonumber(oct:sub(1,1)))
	for l = 2, 6 do
		local oc = oct2bin[oct:sub(l,l)]
		for d = 1, 3 do
			table.insert(t, tonumber(oc:sub(d,d)))
		end
	end

	dec2bin[i] = t
	bin2dec[table.concat(t)] = i
end 

lookup.NOT = {}
lookup.AND = {}
lookup.OR  = {}

setmetatable(lookup.NOT, {__index = function(NOT, v)
	local a = dec2bin[v]
	local nt = {}
	table.insert(nt, a[1])
	for i = 2, 16 do
		table.insert(nt, (a[i] == 1) and 0 or 1)
	end

	local n = bin2dec[table.concat(nt)]
	NOT[v] = n
	return n
end})

setmetatable(lookup.AND, {__index = function(AND, row)
	local t = setmetatable({}, {__index = function(a, v)
		local a = dec2bin[row]
		local b = dec2bin[v]
		local nt = {}
		for i = 1, 16 do
			table.insert(nt, (a[i] == 1 and b[i] == 1) and 1 or 0)
		end

		local n = bin2dec[table.concat(nt)]
		AND[row][v] = n
		return n
	end})
	AND[row] = t
	return t
end})
setmetatable(lookup.OR,  {__index = function(OR, row)
	local t = setmetatable({}, {__index = function(a, v)
		local a = dec2bin[row]
		local b = dec2bin[v]
		local nt = {}
		for i = 1, 16 do
			table.insert(nt, (a[i] == 1 or  b[i] == 1) and 1 or 0)
		end

		local n = bin2dec[table.concat(nt)]
		OR[row][v] = n
		return n
	end})
	OR[row] = t
	return t
end})
