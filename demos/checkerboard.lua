package.path = package.path..";../?.lua"

local ffi = require("ffi")
local bit = require("bit")
local band = bit.band

local pixman = require("pixman")()
local pixlib = pixman.Lib_pixman;
local ENUM = ffi.C
local utils = require("utils")
local save_image = utils.save_image;

local function D2F(d) return (pixman_double_to_fixed(d)) end

local function main (argc, argv)

	local WIDTH = 400;
	local HEIGHT = 400;
	local TILE_SIZE = 25;

    local trans = ffi.new("pixman_transform_t", { {
	    { D2F (-1.96830), D2F (-1.82250), D2F (512.12250)},
	    { D2F (0.00000), D2F (-7.29000), D2F (1458.00000)},
	    { D2F (0.00000), D2F (-0.00911), D2F (0.59231)},
	}});

    local checkerboard = pixlib.pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8,
					     WIDTH, HEIGHT,
					     nil, 0);

    local destination = pixlib.pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8,
					    WIDTH, HEIGHT,
					    nil, 0);

    for i = 0, (HEIGHT / TILE_SIZE)-1  do
		for j = 0, (WIDTH / TILE_SIZE)-1 do
	    	local u = (j + 1) / (WIDTH / TILE_SIZE);
	    	local v = (i + 1) / (HEIGHT / TILE_SIZE);
	    	local black = ffi.new("pixman_color_t", { 0, 0, 0, 0xffff });
	    	local white = ffi.new("pixman_color_t", {
				v * 0xffff,
				u * 0xffff,
				(1 - u) * 0xffff,
				0xffff });
	    	
	    	local c = white;

	    	if (band(j, 1) ~= band(i, 1)) then
				c = black;
	    	end

	    	local fill = pixlib.pixman_image_create_solid_fill (c);

	    	pixlib.pixman_image_composite (ENUM.PIXMAN_OP_SRC, fill, nil, checkerboard,
				    0, 0, 0, 0, j * TILE_SIZE, i * TILE_SIZE,
				    TILE_SIZE, TILE_SIZE);
		end
    end

    pixlib.pixman_image_set_transform (checkerboard, trans);
    pixlib.pixman_image_set_filter (checkerboard, ENUM.PIXMAN_FILTER_BEST, nil, 0);
    pixlib.pixman_image_set_repeat (checkerboard, ENUM.PIXMAN_REPEAT_NONE);

    pixlib.pixman_image_composite (ENUM.PIXMAN_OP_SRC,
			    checkerboard, nil, destination,
			    0, 0, 0, 0, 0, 0,
			    WIDTH, HEIGHT);

	save_image (destination, "checkerboard.ppm");

    return true;
end


main(#arg, arg)

