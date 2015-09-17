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



local WIDTH = 1024
local HEIGHT = 640

--[[
if false then
        /* These colors make it very obvious that dithering
         * is useful even for 8-bit gradients
         */
    { 0x00000, { 0x6666, 0x3333, 0x3333, 0xffff } },
    { 0x10000, { 0x3333, 0x6666, 0x6666, 0xffff } },
end
--]]

local function main (argc, argv)

    local stops = ffi.new("pixman_gradient_stop_t[2]", {
        { 0x00000, { 0x0000, 0x0000, 0x4444, 0xdddd } },
        { 0x10000, { 0xeeee, 0xeeee, 0x8888, 0xdddd } },

    });

    local p1 = ffi.new("pixman_point_fixed_t")
    local p2 = ffi.new("pixman_point_fixed_t")

    local dest_img = pixlib.pixman_image_create_bits (ENUM.PIXMAN_x8r8g8b8,
					 WIDTH, HEIGHT,
					 nil, 0);

    p1.x = 0x0000;
    p1.y = 0x0000;
    p2.x = lshift(WIDTH, 16);
    p2.y = lshift(HEIGHT, 16);
    
    local src_img = pixlib.pixman_image_create_linear_gradient (p1, p2, stops, utils.ARRAY_LENGTH (stops));

    pixlib.pixman_image_composite32 (ENUM.PIXMAN_OP_OVER,
			      src_img,
			      nil,
			      dest_img,
			      0, 0,
			      0, 0,
			      0, 0,
			      WIDTH, HEIGHT);

    save_image (dest_img, "linear-gradient.ppm");

    pixlib.pixman_image_unref (dest_img);

    return true;
end

main(#arg, arg)
