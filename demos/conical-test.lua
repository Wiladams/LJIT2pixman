package.path = package.path..";../?.lua"

local ffi = require("ffi")
local bit = require("bit")
local band = bit.band
local lshift, rshift = bit.lshift, bit.rshift

local pixman = require("pixman")()
local pixlib = pixman.Lib_pixman;
local ENUM = ffi.C
local utils = require("utils")
local save_image = utils.save_image;
local libc = require("libc")

local SIZE = 128
local GRADIENTS_PER_ROW = 7
local NUM_GRADIENTS = 35

local NUM_ROWS = ((NUM_GRADIENTS + GRADIENTS_PER_ROW - 1) / GRADIENTS_PER_ROW)
local WIDTH = (SIZE * GRADIENTS_PER_ROW)
local HEIGHT = (SIZE * NUM_ROWS)

local function double_to_color(x)
    return (x*65536) - rshift( (x*65536), 16)
end

local function PIXMAN_STOP(offset,r,g,b,a)		
   return ffi.new("pixman_gradient_stop_t", { pixman_double_to_fixed (offset),		
	{					
	    double_to_color (r),		
		double_to_color (g),		
		double_to_color (b),		
		double_to_color (a)		
	}					
    });
end

local stops = ffi.new("pixman_gradient_stop_t[4]",{
    PIXMAN_STOP (0.25,       1, 0, 0, 0.7),
    PIXMAN_STOP (0.5,        1, 1, 0, 0.7),
    PIXMAN_STOP (0.75,       0, 1, 0, 0.7),
    PIXMAN_STOP (1.0,        0, 0, 1, 0.7)
});

local  NUM_STOPS = (ffi.sizeof (stops) / ffi.sizeof (stops[0]))


local function create_conical (index)
    local c = ffi.new("pixman_point_fixed_t")
    c.x = pixman_double_to_fixed (0);
    c.y = pixman_double_to_fixed (0);

    local angle = (0.5 / NUM_GRADIENTS + index / NUM_GRADIENTS) * 720 - 180;

    return pixlib.pixman_image_create_conical_gradient (c, pixman_double_to_fixed (angle), stops, NUM_STOPS);
end


local function main (argc, argv)

    local transform = ffi.new("pixman_transform_t");

    local dest_img = pixlib.pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8,
					 WIDTH, HEIGHT,
					 nil, 0);
 
    utils.draw_checkerboard (dest_img, 25, 0xffaaaaaa, 0xff888888);

    pixlib.pixman_transform_init_identity (transform);

    pixlib.pixman_transform_translate (NULL, transform,
				pixman_double_to_fixed (0.5),
				pixman_double_to_fixed (0.5));

    pixlib.pixman_transform_scale (nil, transform,
			    pixman_double_to_fixed (SIZE),
			    pixman_double_to_fixed (SIZE));
    pixlib.pixman_transform_translate (nil, transform,
				pixman_double_to_fixed (0.5),
				pixman_double_to_fixed (0.5));

    for i = 0, NUM_GRADIENTS-1 do
    
	   local column = i % GRADIENTS_PER_ROW;
	   local row = i / GRADIENTS_PER_ROW;

	   local src_img = create_conical (i); 
	   pixlib.pixman_image_set_repeat (src_img, ENUM.PIXMAN_REPEAT_NORMAL);
   
	   pixlib.pixman_image_set_transform (src_img, transform);
	
	   pixlib.pixman_image_composite32 (
	       ENUM.PIXMAN_OP_OVER, src_img, nil,dest_img,
	       0, 0, 0, 0, column * SIZE, row * SIZE,
	       SIZE, SIZE);
	
	   pixlib.pixman_image_unref (src_img);
    end

    save_image (dest_img, "conical-test.ppm");

    pixlib.pixman_image_unref (dest_img);

    return true;
end


main(#arg, arg)