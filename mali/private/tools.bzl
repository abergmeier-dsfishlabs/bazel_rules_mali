

ASTC_SRC_IMAGE_EXTENSIONS = [
	".png",
	".tga",
	".jpg",
	".gif",
	".bmp",
	".hdr",
	".ktx",
	".dds",
	".htga",
]

ASTC_SRC_TEXTURE_EXTENSIONS = [
	".astc",
]

ASTC_SUBMODE_MAP = {
	"" : "",
	"default": "",
	"srgb": "s",
	"linear": "l",
}

_COMPRESSOR_LABEL = attr.label(default = Label("@com_arm_mali_texture_compression_tool//:astcenc"), allow_single_file=True, executable = True)

def _astc_action(ctx, mode, input, output, mnemonic, progress_message):

	submode = ctx.attr.submode
	if not submode in ASTC_SUBMODE_MAP.keys():
		fail("Invalid submode %s has to be one of %s" % (submode, ASTC_SUBMODE_MAP.keys()), attr = "submode")

	args = ["-" + mode + ASTC_SUBMODE_MAP[submode], input, output]
	custom_args = ctx.attr.args

	ctx.action(
		outputs = [output],
		inputs = ctx.files._compressor
			+ input,
		executable = ctx.file._compressor,
		arguments = args + custom_args,
		mnemonic = mnemonic,
		progress_message = progress_message,
	)

def _astc_compress_image_impl(ctx):

	src = ctx.file.src
	output = ctx.outputs.out

	action = _astc_action(
		ctx = ctx,
		mode = "c",
		input = src,
		output = output,
		mnemonic = "MaliAstcTexture",
		progress_message = "Compressing ASTC texture from %s" % src.path,
	)

	return struct()

def _astc_decompress_texture_impl(ctx):

	src = ctx.file.src
	output = ctx.outputs.out
	ext = ctx.attr.ext

	# Camel all the things
	if len(ext) == 1:
		ext = ext.upper
	else:
		ext = ext[0].upper() + ext[1:].lower()

	action = _astc_action(
		ctx = ctx,
		mode = "d",
		input = src,
		output = output,
		mnemonic = "Mali%sImage" % ext,
		progress_message = "Decompressing %s image from %s" % (ext.upper(), src.path),
	)

	return struct()

astc_texture = rule(
	implementation = _astc_compress_image_impl,
	attrs = {
		"_compressor": _COMPRESSOR_LABEL,
		"args": attr.string_list(),
		"src": attr.label(allow_files = ASTC_SRC_IMAGE_EXTENSIONS, single_file = True, allow_empty = False, mandatory = True),
		"submode": attr.string(default = "default"),
	},
	outputs = {
		"out": "%{name}.astc",
	},
)

_astc_decompress_texture = rule(
	implementation = _astc_decompress_texture_impl,
	attrs = {
		"_compressor": _COMPRESSOR_LABEL,
		"args": attr.string_list(),
		"etc": attr.string(allow_empty = False, mandatory = True),
		"src": attr.label(allow_files = ASTC_SRC_TEXTURE_EXTENSIONS, single_file = True, allow_empty = False, mandatory = True),
	},
	outputs = {
		"out": "%{name}.%{etc}",
	},
)


def tga_image(name, src):
	return _astc_decompress_texture(
		name = name,
		src = src,
		ext = "tga",
	)

def ktx_image(name, src):
	return _astc_decompress_texture(
		name = name,
		src = src,
		ext = "ktx",
	)

def dds_image(name, src):
	return _astc_decompress_texture(
		name = name,
		src = src,
		ext = "dds",
	)

def htga_image(name, src):
	return _astc_decompress_texture(
		name = name,
		src = src,
		ext = "htga",
	)