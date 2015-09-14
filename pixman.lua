local ffi = require("ffi")
local bit = require("bit")
local band, bor, bnot = bit.band, bit.bor, bit.bnot;
local lshift, rshift = bit.lshift, bit.rshift;

local Lib_pixman = require("pixman_ffi")

local Constants = {}
local Functions = {}

function Functions.pixman_fixed_to_int(f) return ffi.cast("int", rshift((f), 16)) end;
function Functions.pixman_int_to_fixed(i) return ffi.cast("pixman_fixed_t", lshift(i, 16)) end;
function Functions.pixman_fixed_to_double(f) return	ffi.cast("double", (f / ffi.cast("double", Constants.pixman_fixed_1))) end;
function Functions.pixman_double_to_fixed(d) return	ffi.cast("pixman_fixed_t", d * 65536.0) end;
function Functions.pixman_fixed_frac(f)	return	band(f, Constants.pixman_fixed_1_minus_e) end;
function Functions.pixman_fixed_floor(f) return	band(f, bnot(Constants.pixman_fixed_1_minus_e)) end;
function Functions.pixman_fixed_ceil(f)	return	Functions.pixman_fixed_floor (f + Constants.pixman_fixed_1_minus_e) end;
function Functions.pixman_fixed_fraction(f)	return band(f, Constants.pixman_fixed_1_minus_e) end;
function Functions.pixman_fixed_mod_2(f) return		band(f, bor(Constants.pixman_fixed1, Constants.pixman_fixed_1_minus_e)) end




Constants.pixman_fixed_e	= ffi.cast("pixman_fixed_t", 1);
Constants.pixman_fixed_1	= Functions.pixman_int_to_fixed(1);
Constants.pixman_fixed_1_minus_e	=	Constants.pixman_fixed_1 - Constants.pixman_fixed_e;
Constants.pixman_fixed_minus_1	=	Functions.pixman_int_to_fixed(-1);
Constants.pixman_max_fixed_48_16	=	tonumber(ffi.cast("pixman_fixed_48_16_t", 0x7fffffff));
Constants.pixman_min_fixed_48_16	=	tonumber(-ffi.cast("pixman_fixed_48_16_t", lshift(1, 31)));



--/* whether 't' is a well defined not obviously empty trapezoid */
function Functions.pixman_trapezoid_valid(t)   
    return (t.left.p1.y ~= t.left.p2.y and			   
     t.right.p1.y ~= t.right.p2.y and
     (t.bottom > t.top))
end


local exports = {
	Lib_pixman = Lib_pixman;

    Constants = Constants;
    Functions = Functions;
}

setmetatable(exports, {
    __call = function(self, tbl)
        tbl = tbl or _G;
        for k,v in pairs(self.Constants) do
            tbl[k] = v;
        end

        return self;
    end,
})

return exports
