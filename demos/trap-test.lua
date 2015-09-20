package.path = package.path..";../?.lua"

local ffi = require("ffi")

local pixman = require("pixman")()
local save_image = require("utils").save_image;
local libc = require("libc")()



local function main (argc, argv)

    local WIDTH = 200;
    local HEIGHT = 200;

    local white = pixman_color({ 0x0000, 0xffff, 0x0000, 0xffff });
    local bits = ffi.cast("uint32_t *", malloc (WIDTH * HEIGHT * 4));
    local mbits = ffi.cast("uint32_t *", malloc (WIDTH * HEIGHT));

    memset (mbits, 0, WIDTH * HEIGHT);
    memset (bits, 0xff, WIDTH * HEIGHT * 4);
    
    local trap = ffi.new("pixman_trap_t");
    trap.top.l = pixman_int_to_fixed (70) + 0x8000;
    trap.top.r = pixman_int_to_fixed (130) + 0x8000;
    trap.top.y = pixman_int_to_fixed (30);

    trap.bot.l = pixman_int_to_fixed (50) + 0x8000;
    trap.bot.r = pixman_int_to_fixed (150) + 0x8000;
    trap.bot.y = pixman_int_to_fixed (150);

    local mask_img = pixman_image_create_bits (PIXMAN_a8, WIDTH, HEIGHT, mbits, WIDTH);
    local src_img = pixman_image_create_solid_fill (white);
    local dest_img = pixman_image_create_bits (PIXMAN_a8r8g8b8, WIDTH, HEIGHT, bits, WIDTH * 4);
    
    pixman_add_traps (mask_img, 0, 0, 1, trap);

    pixman_image_composite (PIXMAN_OP_OVER,
			    src_img, mask_img, dest_img,
			    0, 0, 0, 0, 0, 0, WIDTH, HEIGHT);
    
    save_image (dest_img, "trap-test.ppm");
    
    pixman_image_unref (src_img);
    pixman_image_unref (dest_img);
    free(bits);
    free(mbits);

    return true;
end

main(#arg, argv)

