dofile("init.lua")
dofile("binaryLookups.lua")

local ops = {
	--halt				stop execution and terminate the program
	[0x00] = function()
		HALT()
	end;

	--set <a> <b>		set register <a> to the value of <b>
	[0x01] = function()
		regs[getVal(progC, true)] = getVal(progC + 1)
		progC = progC + 2
	end;
	
	--push <a>			push <a> onto the stack
	[0x02] = function()
		push(getVal(progC))
		progC = progC + 1
	end;
	
	--pop <a>			remove the top element from the stack and write it into <a>; empty stack = error
	[0x03] = function()
		regs[getVal(progC, true)] = pop()
		progC = progC + 1
	end;
	
	--eq <a> <b> <c>	set <a> to 1 if <b> is equal to <c>; set it to 0 otherwise
	[0x04] = function()
		regs[getVal(progC, true)] = getVal(progC + 1) == getVal(progC + 2) and 1 or 0
		progC = progC + 3
	end;

	--gt <a> <b> <c>	set <a> to 1 if <b> is greater than <c>; set it to 0 otherwise
	[0x05] = function()
		regs[getVal(progC, true)] = getVal(progC + 1) >  getVal(progC + 2) and 1 or 0
		progC = progC + 3
	end;

	--jmp <a>			jump to <a>
	[0x06] = function()
		progC = getVal(progC)
	end;

	--jt <a> <b>		if <a> is nonzero, jump to <b>
	[0x07] = function()
		if getVal(progC) ~= 0 then
			progC = getVal(progC + 1)
		else
			progC = progC + 2
		end
	end;

	--jf <a> <b>		if <a> is zero, jump to <b>
	[0x08] = function()
		if getVal(progC) == 0 then
			progC = getVal(progC + 1)
		else
			progC = progC + 2
		end
	end;

	--add <a> <b> <c>	assign into <a> the sum of <b> and <c> (modulo 32768)
	[0x09] = function()
		regs[getVal(progC, true)] = (getVal(progC + 1) + getVal(progC + 2))%32768
		progC = progC + 3
	end;

	--mult <a> <b> <c>	store into <a> the product of <b> and <c> (modulo 32768)
	[0x0A] = function()
		regs[getVal(progC, true)] = (getVal(progC + 1) * getVal(progC + 2))%32768
		progC = progC + 3
	end;

	--mod <a> <b> <c>	store into <a> the remainder of <b> divided by <c>
	[0x0B] = function()
		regs[getVal(progC, true)] = getVal(progC + 1) % getVal(progC + 2)
		progC = progC + 3
	end;

	--and <a> <b> <c>	stores into <a> the bitwise and of <b> and <c>
	[0x0C] = function()
		regs[getVal(progC, true)] = lookup.AND[getVal(progC + 1)][getVal(progC + 2)]
		progC = progC + 3
	end;

	--or <a> <b> <c>	stores into <a> the bitwise or of <b> and <c>
	[0x0D] = function()
		regs[getVal(progC, true)] =  lookup.OR[getVal(progC + 1)][getVal(progC + 2)]
		progC = progC + 3
	end;

	--not <a> <b>		stores 15-bit bitwise inverse of <b> in <a>
	[0x0E] = function() 
		regs[getVal(progC, true)] = lookup.NOT[getVal(progC + 1)]
		progC = progC + 2
	end;

	--rmem <a> <b>		read memory at address <b> and write it to <a>
	[0x0F] = function()
		regs[getVal(progC, true)] = getVal(getVal(progC + 1))
		progC = progC + 2
	end;

	--wmem <a> <b>		write the value from <b> into memory at address <a>
	[0x10] = function()
		local addr = getVal(progC)
		local val = getVal(progC + 1)
		local low = val%(16*16)

		mem[2*addr + 1] = low
		mem[2*addr + 2] = (val - low)/(16*16)

		progC = progC + 2
	end;

	--call <a>			write the address of the next instruction to the stack and jump to <a>
	[0x11] = function()
		push(progC + 1)
		progC = getVal(progC)
	end;

	--ret				remove the top element from the stack and jump to it; empty stack = halt
	[0x12] = function()
		progC = pop()
	end;

	--out <a>			write the character represented by ascii code <a> to the terminal
	[0x13] = function()
		io.write(string.char(getVal(progC)))
		progC = progC + 1
	end;

	--in <a>			read a character from the terminal and write its ascii code to <a>
	[0x14] = function()
		regs[getVal(progC, true)] = io.read(1):byte()
		progC = progC + 1
	end;

	--noop				no operation
	[0x15] = function()
	end;
}

setmetatable(ops, {__index = function(_, op) HALT("unknown opcode: 0x" .. hex(op) .. " (" .. op .. ")", true) end})

while true do
	local op = getVal(progC)
	progC = progC + 1
	ops[op]()
end
