--test_pixman.lua
package.path = package.path..";../?.lua"

local pixman = require("pixman")()
local Lib = pixman.Lib_pixman;

local function printf(fmt, ...)
	io.write(string.format(fmt, ...))
end

local function test_constants()
	printf("pixman_max_fixed_48_16: %#x\n", pixman_max_fixed_48_16);
	printf("pixman_min_fixed_48_16: %#x\n", pixman_min_fixed_48_16);
end

test_constants();
