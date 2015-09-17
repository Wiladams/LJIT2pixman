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


local function ARRAY_LENGTH(arr)
return ffi.sizeof(arr)/ffi.sizeof(arr[0])
end


local function main (argc, argv)

local WIDTH = 200
local HEIGHT = 200

    local function  POINT(x,y)
        return ffi.new("pixman_point_fixed_t", pixman_double_to_fixed (x), pixman_double_to_fixed (y) )
    end

    local tris = ffi.new("pixman_triangle_t[4]",
    {
	{ POINT (100, 100), POINT (10, 50), POINT (110, 10) },
	{ POINT (100, 100), POINT (150, 10), POINT (200, 50) },
	{ POINT (100, 100), POINT (10, 170), POINT (90, 175) },
	{ POINT (100, 100), POINT (170, 150), POINT (120, 190) },
    });
    local color = ffi.new("pixman_color_t", { 0x4444, 0x4444, 0xffff, 0xffff });
    local bits = ffi.cast("uint32_t *", libc.malloc (WIDTH * HEIGHT * 4));
    
    --local i = 0;
    --while (i < WIDTH * HEIGHT) do
    --    i = i + 1;
    --    bits[i] = (i / HEIGHT) * 0x01010000;
    --end

    --for (i = 0; i < WIDTH * HEIGHT; ++i)
    --bits[i] = (i / HEIGHT) * 0x01010000;


    
    local src_img = pixlib.pixman_image_create_solid_fill (color);
    local dest_img = pixlib.pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8, WIDTH, HEIGHT, bits, WIDTH * 4);
    
    pixlib.pixman_composite_triangles (ENUM.PIXMAN_OP_ATOP_REVERSE,
				src_img,
				dest_img,
				ENUM.PIXMAN_a8,
				200, 200,
				-5, 5,
              ARRAY_LENGTH (tris), tris);

    save_image (dest_img, "tri-test.ppm");
    
    pixlib.pixman_image_unref (src_img);
    pixlib.pixman_image_unref (dest_img);
    libc.free (bits);
    
    return true;
end

main(#arg, arg)