-- utils.lua
local pixman = require("pixman")
local pixlib = pixman.Lib_pixman

-- write the image out as a ppm file
local function show_image(img)
	print("=+ showing image +=")
	print(string.format("  Size: %dx%d", pixlib.pixman_image_get_width(img), pixlib.pixman_image_get_height(img)))
	print(string.format("Stride: %d", pixlib.pixman_image_get_stride(img)));
	print(string.format(" Depth: %d", pixlib.pixman_image_get_depth(img)));
	print(string.format("Format: %#x", tonumber(pixlib.pixman_image_get_format(img))));
	print(string.format("  Data: %p", tonumber(pixlib.pixman_image_get_data(img))));
end

local exports = {
	show_image = show_image;
}

return exports
