-- utils.lua
local ffi = require("ffi")
local pixman = require("pixman")
local pixlib = pixman.Lib_pixman
local libc = require("libc")()

local int = ffi.typeof("int")

local function  write_PPM_binary(filename, bits, width, height, stride)

	local fp = libc.fopen(filename, "wb");
	if fp == nil then return false end;


	-- write out the image header
	libc.fprintf(fp, "P6\n%d %d\n255\n", int(width), int(height));

	-- write the individual pixel values in binary form
	local pixelPtr = ffi.cast("uint8_t *", bits);
	local rgb = ffi.new("uint8_t[3]");

	for row = 0, height-1 do
		for col = 0, width-1 do
			rgb[0] = pixelPtr[(col*4)];
			rgb[1] = pixelPtr[(col*4)+1];
			rgb[2] = pixelPtr[(col*4)+2];
			libc.fwrite(rgb, 3, 1, fp);
			--fwrite(&pixelPtr[col], 3, 1, fp);
		end
		pixelPtr = pixelPtr + stride;
	end

	libc.fclose(fp);

	return true;
end

local function print_image(img)
	local width = tonumber(pixlib.pixman_image_get_width(img));
	local height = tonumber(pixlib.pixman_image_get_height(img));
	local stride = tonumber(pixlib.pixman_image_get_stride(img));
	local bits = pixlib.pixman_image_get_data(img);

	print("=+ showing image +=")
	print(string.format("  Size: %dx%d", width, height))
	print(string.format("Stride: %d", stride));
	print(string.format(" Depth: %d", pixlib.pixman_image_get_depth(img)));
	print(string.format("Format: %#x", tonumber(pixlib.pixman_image_get_format(img))));
	print(string.format("  Data: %#x", tonumber(ffi.cast("intptr_t",pixlib.pixman_image_get_data(img)))));

end

-- write the image out as a ppm file
local function save_image(img, filename)
	local width = tonumber(pixlib.pixman_image_get_width(img));
	local height = tonumber(pixlib.pixman_image_get_height(img));
	local stride = tonumber(pixlib.pixman_image_get_stride(img));
	local bits = pixlib.pixman_image_get_data(img);


	write_PPM_binary(filename, bits, width, height, stride)
end


local exports = {
	save_image = save_image;
	print_image = print_image;
}

return exports
