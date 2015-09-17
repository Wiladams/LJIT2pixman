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
    pixman_region_init = Lib_pixman.pixman_region_init;
    pixman_region_init_rect = Lib_pixman.pixman_region_init_rect;
    pixman_region_init_rects = Lib_pixman.pixman_region_init_rects;
    pixman_region_init_with_extents = Lib_pixman.pixman_region_init_with_extents;
    pixman_region_init_from_image = Lib_pixman.pixman_region_init_from_image;
    pixman_region_fini = Lib_pixman.pixman_region_fini;
    pixman_region_translate = Lib_pixman.pixman_region_translate;
    pixman_region_copy = Lib_pixman.pixman_region_copy;
    pixman_region_intersect = Lib_pixman.pixman_region_intersect;
    pixman_region_union = Lib_pixman.pixman_region_union;
    pixman_region_union_rect = Lib_pixman.pixman_region_union_rect;
    pixman_region_intersect_rect = Lib_pixman.pixman_region_intersect_rect;
    pixman_region_subtract = Lib_pixman.pixman_region_subtract;
    pixman_region_inverse = Lib_pixman.pixman_region_inverse;
    pixman_region_contains_point = Lib_pixman.pixman_region_contains_point;
    pixman_region_contains_rectangle = Lib_pixman.pixman_region_contains_rectangle;
    pixman_region_not_empty = Lib_pixman.pixman_region_not_empty;
    pixman_region_extents = Lib_pixman.pixman_region_extents;
    pixman_region_n_rects = Lib_pixman.pixman_region_n_rects;
    pixman_region_rectangles = Lib_pixman.pixman_region_rectangles;
    pixman_region_equal = Lib_pixman.pixman_region_equal;
    pixman_region_selfcheck = Lib_pixman.pixman_region_selfcheck;
    pixman_region_reset = Lib_pixman.pixman_region_reset;
    pixman_region_clear = Lib_pixman.pixman_region_clear;

    -- Region32
    -- Miscellaneous
    -- Image Constructors
    pixman_image_create_solid_fill = Lib_pixman.pixman_image_create_solid_fill;
    pixman_image_create_linear_gradient = Lib_pixman.pixman_image_create_linear_gradient;
    pixman_image_create_radial_gradient = Lib_pixman.pixman_image_create_radial_gradient;
    pixman_image_create_conical_gradient = Lib_pixman.pixman_image_create_conical_gradient;
    pixman_image_create_bits = Lib_pixman.pixman_image_create_bits;
    pixman_image_create_bits_no_clear = Lib_pixman.pixman_image_create_bits_no_clear;

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
