print()

------- Memory/Stack/Registers -------

local bin, err = io.open("challenge.bin", "rb")
if not bin then print("Could not open file " .. err) os.exit() end

mem = {}
local c = bin:read(1)
while c do
	table.insert(mem, c:byte())
	c = bin:read(1)
end

regs = {0, 0, 0, 0, 0, 0, 0, 0}

local stack = {}
function push(val)
	table.insert(stack, 1, val)
end
function pop()
	if #stack == 0 then
		HALT("popping empty stack", true)
	end
	return table.remove(stack, 1)
end

progC = 0

------- Other Globals --------

function HALT(reason, dump)
	if reason then
		local str = "System Halted: " .. reason
		print(("-"):rep(#str))
		print(str)
		print(("-"):rep(#str))
	end
	if dump then
		DUMPMEM("dump.txt")
	end
	print()
	os.exit()
end

function DUMPMEM(where)
	print("Dumping memory to " .. where)
	print("Not really...")
	print("but here's the offset of the program counter: " .. hex(2*progC))
	--io.open(where, "w")
end

function getVal(n, getReg)
	local val = mem[2*n + 1] + 16*16*mem[2*n + 2] -- Lua is 1-indexed, not 0-indexed
	if val > 32776 then
		HALT("invalid number: " .. hex(val) .. " (" .. val .. ")", true)
	elseif val > 32767 then
		return (getReg and val - 32767 or regs[val - 32767])
	else
		return val
	end
end

------- Pretty Printing -------

function hex(n, w)
	if not w then w = 4 end
	return string.format("%0" .. w .. "X", n)
end
