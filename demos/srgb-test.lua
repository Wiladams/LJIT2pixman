package.path = package.path..";../?.lua"

local ffi = require("ffi")
local bit = require("bit")
local lshift, rshift, bor, band = bit.lshift, bit.rshift, bit.bor, bit.band

local pixman = require("pixman")()
local save_image = require("utils").save_image;
local libc = require("libc")()


local function linear_argb_to_premult_argb (a, r, g, b)
    r = r*a;
    g = g*a;
    b = b*a;
    return bor(lshift((a * 255.0 + 0.5), 24)
		, lshift((r * 255.0 + 0.5), 16)
		, lshift((g * 255.0 + 0.5),  8)
		, lshift((b * 255.0 + 0.5),  0));
end

local function lin2srgb (linear)
    if (linear < 0.0031308) then
		return linear * 12.92;
    end

	return 1.055 * math.pow (linear, 1.0/2.4) - 0.055;
end


local function linear_argb_to_premult_srgb_argb (a,  r,  g,  b)

    r = lin2srgb (r * a);
    g = lin2srgb (g * a);
    b = lin2srgb (b * a);
    return bor( lshift((a * 255.0 + 0.5), 24)
	 , lshift((r * 255.0 + 0.5), 16)
	 , lshift((g * 255.0 + 0.5),  8)
	 , lshift((b * 255.0 + 0.5),  0));
end


local function main (argc, argv)

	local WIDTH = 400;
	local HEIGHT = 200;
 
    local dest = ffi.cast("uint32_t *", malloc (WIDTH * HEIGHT * 4));
    local src1 = ffi.cast("uint32_t *", malloc (WIDTH * HEIGHT * 4));
    
    local dest_img = pixman_image_create_bits (PIXMAN_a8r8g8b8_sRGB,
					 WIDTH, HEIGHT,
					 dest,
					 WIDTH * 4);
    local src1_img = pixman_image_create_bits (PIXMAN_a8r8g8b8,
					 WIDTH, HEIGHT,
					 src1,
					 WIDTH * 4);

    for y = 0, HEIGHT-1 do
    
		local p = WIDTH * y;
		for x = 0, WIDTH-1 do
	
	    	alpha = x / WIDTH;
	    	src1[p + x] = linear_argb_to_premult_argb (alpha, 1, 0, 1);
	    	dest[p + x] = linear_argb_to_premult_srgb_argb (1-alpha, 0, 1, 0);
		end
    end
    
    pixman_image_composite (PIXMAN_OP_ADD, src1_img, NULL, dest_img,
			    0, 0, 0, 0, 0, 0, WIDTH, HEIGHT);
    pixman_image_unref (src1_img);
    free (src1);

    save_image (dest_img, "srgb-test.ppm");
    pixman_image_unref (dest_img);
    free (dest);
    
    return true;
end

main(#arg, arg)

