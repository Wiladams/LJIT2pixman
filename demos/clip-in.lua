package.path = package.path..";../?.lua"

local ffi = require("ffi")
local bit = require("bit")
local band = bit.band

local pixman = require("pixman")()
local pixlib = pixman.Lib_pixman;
local ENUM = ffi.C
local utils = require("utils")
local save_image = utils.save_image;
local libc = require("libc")



--[[
 This test demonstrates that clipping is done totally different depending
 on whether the source is transformed or not.
--]]
local function D2F(d) return (pixman_double_to_fixed(d)) end


local function main (argc, argv)

    local WIDTH = 400
    local HEIGHT = 400

    local SMALL = 25
    
    local sbits = libc.malloc (SMALL * SMALL * 4);
    local bits = libc.malloc (WIDTH * HEIGHT * 4);
    local trans = ffi.new("pixman_transform_t", {
    {
	{ D2F (1.0), D2F (0), D2F (-0.1), },
	{ D2F (0), D2F (1), D2F (-0.1), },
	{ D2F (0), D2F (0), D2F (1.0) }
    } });
	  
    local src_img = pixlib.pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8, SMALL, SMALL, sbits, 4 * SMALL);
    local dest_img = pixlib.pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8, WIDTH, HEIGHT, bits, 4 * WIDTH);

    libc.memset (bits, 0xff, WIDTH * HEIGHT * 4);
    libc.memset (sbits, 0x7f, SMALL * SMALL * 4);

    pixlib.pixman_image_composite (ENUM.PIXMAN_OP_IN,
			    src_img, nil, dest_img,
			    0, 0, 0, 0, SMALL, SMALL, 200, 200);
    
    pixlib.pixman_image_set_transform (src_img, trans);
    
    pixlib.pixman_image_composite (ENUM.PIXMAN_OP_IN,
			    src_img, nil, dest_img,
			    0, 0, 0, 0, SMALL * 2, SMALL * 2, 200, 200);
    
    save_image (dest_img, "clip-in.ppm");
    
    pixlib.pixman_image_unref (src_img);
    pixlib.pixman_image_unref (dest_img);
    libc.free (bits);
    
    return true;
end

main(#arg, arg)
