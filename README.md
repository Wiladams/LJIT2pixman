# LJIT2pixman
LuaJIT binding to pixman, the pixel rendering engine of Cairo

This binding can operate at two levels
* A raw ffi.cdef binding (pixman_ffi.lua) - gives you access to everything as raw C
* Lua tables binding - promotes functions, types, constants and enums to tables

Using the Lua tables bindings, you can write code which looks almost identical to the 
original C equivalent.

Example:

'screen-test.c'
```C
#include <stdio.h>
#include <stdlib.h>
#include "pixman.h"
#include "gtk-utils.h"

int
main (int argc, char **argv)
{
#define WIDTH 40
#define HEIGHT 40
    
    uint32_t *src1 = malloc (WIDTH * HEIGHT * 4);
    uint32_t *src2 = malloc (WIDTH * HEIGHT * 4);
    uint32_t *src3 = malloc (WIDTH * HEIGHT * 4);
    uint32_t *dest = malloc (3 * WIDTH * 2 * HEIGHT * 4);
    pixman_image_t *simg1, *simg2, *simg3, *dimg;

    int i;

    for (i = 0; i < WIDTH * HEIGHT; ++i)
    {
	src1[i] = 0x7ff00000;
	src2[i] = 0x7f00ff00;
	src3[i] = 0x7f0000ff;
    }

    for (i = 0; i < 3 * WIDTH * 2 * HEIGHT; ++i)
    {
	dest[i] = 0x0;
    }

    simg1 = pixman_image_create_bits (PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src1, WIDTH * 4);
    simg2 = pixman_image_create_bits (PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src2, WIDTH * 4);
    simg3 = pixman_image_create_bits (PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src3, WIDTH * 4);
    dimg  = pixman_image_create_bits (PIXMAN_a8r8g8b8, 3 * WIDTH, 2 * HEIGHT, dest, 3 * WIDTH * 4);

    pixman_image_composite (PIXMAN_OP_SCREEN, simg1, NULL, dimg, 0, 0, 0, 0, WIDTH, HEIGHT / 4, WIDTH, HEIGHT);
    pixman_image_composite (PIXMAN_OP_SCREEN, simg2, NULL, dimg, 0, 0, 0, 0, (WIDTH/2), HEIGHT / 4 + HEIGHT / 2, WIDTH, HEIGHT);
    pixman_image_composite (PIXMAN_OP_SCREEN, simg3, NULL, dimg, 0, 0, 0, 0, (4 * WIDTH) / 3, HEIGHT, WIDTH, HEIGHT);

    show_image (dimg);
    
    return 0;
}
```

Now, the same thing in Lua, using the Lua tables binding

```lua
local ffi = require("ffi")
local bit = require("bit")
local band = bit.band
local lshift, rshift = bit.lshift, bit.rshift

local pixman = require("pixman")()
local save_image = require("utils").save_image;
local libc = require("libc")()


local function main (argc, argv)

    local WIDTH = 40
    local HEIGHT = 40
    
    local src1 = ffi.cast("uint32_t *", malloc (WIDTH * HEIGHT * 4));
    local src2 = ffi.cast("uint32_t *", malloc (WIDTH * HEIGHT * 4));
    local src3 = ffi.cast("uint32_t *", malloc (WIDTH * HEIGHT * 4));
    local dest = ffi.cast("uint32_t *", malloc (3 * WIDTH * 2 * HEIGHT * 4));

    for i = 0, (WIDTH * HEIGHT)-1 do
	   src1[i] = 0x7ff00000;
	   src2[i] = 0x7f00ff00;
	   src3[i] = 0x7f0000ff;
    end

    for i = 0, (3 * WIDTH * 2 * HEIGHT)-1 do
	   dest[i] = 0x0;
    end

    local simg1 = pixman_image_create_bits (PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src1, WIDTH * 4);
    local simg2 = pixman_image_create_bits (PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src2, WIDTH * 4);
    local simg3 = pixman_image_create_bits (PIXMAN_a8r8g8b8, WIDTH, HEIGHT, src3, WIDTH * 4);
    local dimg  = pixman_image_create_bits (PIXMAN_a8r8g8b8, 3 * WIDTH, 2 * HEIGHT, dest, 3 * WIDTH * 4);

    pixman_image_composite (PIXMAN_OP_SCREEN, simg1, NULL, dimg, 0, 0, 0, 0, WIDTH, HEIGHT / 4, WIDTH, HEIGHT);
    pixman_image_composite (PIXMAN_OP_SCREEN, simg2, NULL, dimg, 0, 0, 0, 0, (WIDTH/2), HEIGHT / 4 + HEIGHT / 2, WIDTH, HEIGHT);
    pixman_image_composite (PIXMAN_OP_SCREEN, simg3, NULL, dimg, 0, 0, 0, 0, (4 * WIDTH) / 3, HEIGHT, WIDTH, HEIGHT);

    save_image (dimg, "screen-test.ppm");
    
    return true;
end

main(#arg, arg)

```
'screentest.lua'

When converting the C demo into Lua, mostly it's about removing type declarations, the function
calls are pretty much the same.  Some care is needed for things like object allocations, malloc
and the like, but they are relatively painless.  As this library does not deal with Window
displays, it does not use 'show_image()', but rather 'save_image()', which will generate a 
.ppm file for the image, which is about as simple as can be for image archiving formats.  Good
enough for these demo images.


For Reference, Other Bindings:
* Python - https://github.com/ldo/python_pixman/
