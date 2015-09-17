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


local function main (argc, argv)

    WIDTH = 40
    HEIGHT = 40
    
    local src1 = ffi.cast("uint32_t *", libc.malloc (WIDTH * HEIGHT * 4));
    local src2 = ffi.cast("uint32_t *", libc.malloc (WIDTH * HEIGHT * 4));
    local src3 = ffi.cast("uint32_t *", libc.malloc (WIDTH * HEIGHT * 4));
    local dest = ffi.cast("uint32_t *", libc.malloc (3 * WIDTH * 2 * HEIGHT * 4));

    for i = 0, (WIDTH * HEIGHT)-1 do
	   src1[i] = 0x7ff00000;
	   src2[i] = 0x7f00ff00;
	   src3[i] = 0x7f0000ff;
    end

    for i = 0, (3 * WIDTH * 2 * HEIGHT)-1 do
	   dest[i] = 0x0;
    end

    local simg1 = pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src1, WIDTH * 4);
    local simg2 = pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src2, WIDTH * 4);
    local simg3 = pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src3, WIDTH * 4);
    local dimg  = pixman_image_create_bits (ENUM.PIXMAN_a8r8g8b8, 3 * WIDTH, 2 * HEIGHT, dest, 3 * WIDTH * 4);

    pixman_image_composite (ENUM.PIXMAN_OP_SCREEN, simg1, NULL, dimg, 0, 0, 0, 0, WIDTH, HEIGHT / 4, WIDTH, HEIGHT);
    pixman_image_composite (ENUM.PIXMAN_OP_SCREEN, simg2, NULL, dimg, 0, 0, 0, 0, (WIDTH/2), HEIGHT / 4 + HEIGHT / 2, WIDTH, HEIGHT);
    pixman_image_composite (ENUM.PIXMAN_OP_SCREEN, simg3, NULL, dimg, 0, 0, 0, 0, (4 * WIDTH) / 3, HEIGHT, WIDTH, HEIGHT);

    save_image (dimg, "screen-test.ppm");
    
    return true;
end

main(#arg, arg)
