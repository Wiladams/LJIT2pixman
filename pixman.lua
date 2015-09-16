local ffi = require("ffi")
local bit = require("bit")
local band, bor, bnot = bit.band, bit.bor, bit.bnot;
local lshift, rshift = bit.lshift, bit.rshift;

local Lib_pixman = require("pixman_ffi")

local Constants = {}

--[[
    Filling out this list of functions is a convenience for putting the 
    functions pointers into the global namespace.  This table is needed
    in the least, as you can access the functions more quickly using the
    library references directly.
--]]
local Functions = {
    -- Transforms
    -- Regions
    -- Compositing
    pixman_compute_composite_region = Lib_pixman.pixman_compute_composite_region;
    pixman_image_composite = Lib_pixman.pixman_image_composite;
    pixman_image_composite32 = Lib_pixman.pixman_image_composite32;

    -- Glyphs

    -- Trapezoid Library Functions
    pixman_sample_ceil_y = Lib_pixman.pixman_sample_ceil_y;
    pixman_sample_floor_y = Lib_pixman.pixman_sample_floor_y;
    pixman_edge_step = Lib_pixman.pixman_edge_step;
    pixman_edge_init = Lib_pixman.pixman_edge_init;
    pixman_line_fixed_edge_init = Lib_pixman.pixman_line_fixed_edge_init;
    pixman_rasterize_edges = Lib_pixman.pixman_rasterize_edges;
    pixman_add_traps = Lib_pixman.pixman_add_traps;
    pixman_add_trapezoids = Lib_pixman.pixman_add_trapezoids;
    pixman_rasterize_trapezoid = Lib_pixman.pixman_rasterize_trapezoid;
    pixman_composite_trapezoids = Lib_pixman.pixman_composite_trapezoids;
    pixman_composite_triangles = Lib_pixman.pixman_composite_triangles;
    pixman_add_triangles = Lib_pixman.pixman_add_triangles;
}

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

        for k,v in pairs(self.Functions) do
            tbl[k] = v;
        end
        
        return self;
    end,
})

return exports
