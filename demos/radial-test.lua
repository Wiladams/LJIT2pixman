package.path = package.path..";../?.lua"

local ffi = require("ffi")
local bit = require("bit")
local lshift, rshift, bor, band = bit.lshift, bit.rshift, bit.bor, bit.band

local pixman = require("pixman")()
local utils = require("utils")()
local libc = require("libc")()
local pixlib = pixman.Lib_pixman;

local NUM_GRADIENTS = 9
local NUM_STOPS = 3
local NUM_REPEAT = 4
local SIZE = 128
local WIDTH = (SIZE * NUM_GRADIENTS)
local HEIGHT = (SIZE * NUM_REPEAT)



local radiuses = ffi.new("double[?]", NUM_GRADIENTS, {
    0.00,
    0.25,
    0.50,
    0.50,
    1.00,
    1.00,
    1.50,
    1.75,
    1.75
});

local function  double_to_color(x)
    return (x*65536) - rshift(x*65536, 16)
end

local function PIXMAN_STOP(offset,r,g,b,a)		
    return pixman_gradient_stop_t({ pixman_double_to_fixed (offset),		
	{					
	double_to_color (r),			
	double_to_color (g),			
	double_to_color (b),			
	double_to_color (a)			
	}					
    });
end

local stops = ffi.new("pixman_gradient_stop_t[?]", NUM_STOPS, {
    PIXMAN_STOP (0.0,        1, 0, 0, 0.75),
    PIXMAN_STOP (0.70710678, 0, 1, 0, 0),
    PIXMAN_STOP (1.0,        0, 0, 1, 1)
});


local function create_radial (index)

    local p0 = pixman_point_fixed();
    local p1 = pixman_point_fixed();

    local x0 = 0;
    local x1 = 1;
    local radius0 = radiuses[index];
    local radius1 = radiuses[NUM_GRADIENTS - index - 1];

    -- center the gradient */
    local left = math.min (x0 - radius0, x1 - radius1);
    local right = math.max (x0 + radius0, x1 + radius1);
    local center = (left + right) * 0.5;
    x0 = x0 - center;
    x1 = x1 - center;

    -- scale to make it fit within a 1x1 rect centered in (0,0) */
    x0 = x0 * 0.25;
    x1 = x1 * 0.25;
    radius0 = radius0 * 0.25;
    radius1 = radius1 * 0.25;

    p0.x = pixman_double_to_fixed (x0);
    p0.y = pixman_double_to_fixed (0);

    p1.x = pixman_double_to_fixed (x1);
    p1.y = pixman_double_to_fixed (0);

    r0 = pixman_double_to_fixed (radius0);
    r1 = pixman_double_to_fixed (radius1);

    return pixman_image_create_radial_gradient (p0, p1,
						r0, r1,
						stops, NUM_STOPS);
end

local repeats = ffi.new("pixman_repeat_t[?]", NUM_REPEAT, {
    PIXMAN_REPEAT_NONE,
    PIXMAN_REPEAT_NORMAL,
    PIXMAN_REPEAT_REFLECT,
    PIXMAN_REPEAT_PAD
});


local function main (argc, argv)

    local transform = pixman_transform();

    local dest_img = pixman_image_create_bits (PIXMAN_a8r8g8b8,
					 WIDTH, HEIGHT,
					 NULL, 0);

    draw_checkerboard (dest_img, 25, 0xffaaaaaa, 0xffbbbbbb);
    
    pixman_transform_init_identity (transform);

    pixman_transform_translate (NULL, transform,
				pixman_double_to_fixed (0.5),
				pixman_double_to_fixed (0.5));

    pixman_transform_scale (NULL, transform,
			    pixman_double_to_fixed (SIZE),
			    pixman_double_to_fixed (SIZE));


    pixman_transform_translate (NULL, transform,
				pixman_double_to_fixed (0.5),
				pixman_double_to_fixed (0.5));

    for i = 0, NUM_GRADIENTS-1 do
    
	   local src_img = create_radial (i);
	   pixman_image_set_transform (src_img, transform);

	   for j = 0, NUM_REPEAT-1 do
	       pixman_image_set_repeat (src_img, repeats[j]);

	       pixman_image_composite32 (PIXMAN_OP_OVER,
				      src_img,
				      NULL,
				      dest_img,
				      0, 0,
				      0, 0,
				      i * SIZE, j * SIZE,
				      SIZE, SIZE);

	   end

	   pixman_image_unref (src_img);
    end

    save_image (dest_img, "radial-test.ppm");

    pixman_image_unref (dest_img);

    return true;
end

main(#arg, arg)
