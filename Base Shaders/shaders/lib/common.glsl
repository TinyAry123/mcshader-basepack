float SRGB_TO_LINRGB(float channel) { // sRGB to linear RGB. 
	return channel <= 0.04045 ? channel / 12.92 : pow((channel + 0.055) / 1.055, 2.4);
}

vec3 SRGB_TO_LINRGB(vec3 color) { // sRGB to linear RGB. 
	return vec3(SRGB_TO_LINRGB(color.r), SRGB_TO_LINRGB(color.g), SRGB_TO_LINRGB(color.b));
}

float LINRGB_TO_SRGB(float channel) { // Linear RGB to sRGB. 
	return channel <= 0.00313080495356 ? channel * 12.92 : pow(channel, 1.0 / 2.4) * 1.055 - 0.055;
}

vec3 LINRGB_TO_SRGB(vec3 color) { // Linear RGB to sRGB. 
	return vec3(LINRGB_TO_SRGB(color.r), LINRGB_TO_SRGB(color.g), LINRGB_TO_SRGB(color.b));
}

const mat3 LINRGB_TO_LMS = mat3( // Linear RGB to Bjorn Ottoson's Long-Medium-Short response. 
	 0.4122214708,  0.5363325363,  0.0514459929,
	 0.2119034982,  0.6806995451,  0.1073969566,
	 0.0883024619,  0.2817188376,  0.6299787005
);

const mat3 LMSCBRT_TO_OKLAB = mat3( // Bjorn Ottoson's non-linear LMS to OkLab. 
	 0.2104542553,  0.7936177850, -0.0040720468,
	 1.9779984951, -2.4285922050,  0.4505937099,
	 0.0259040371,  0.7827717662, -0.8086757660
);

vec3 LINRGB_TO_OKLAB(vec3 color) { // Linear RGB to OkLab. 
	return pow(color * LINRGB_TO_LMS, vec3(1.0 / 3.0)) * LMSCBRT_TO_OKLAB; // OkLab output is in [0, 1], [-1, 1], [-1, 1] for L, a, b respectively. 
}

const mat3 OKLAB_TO_LMSCBRT = mat3( // Inverse from OkLab to non-linear LMS. 
	 1.0,  0.3963377774,  0.2158037573,
	 1.0, -0.1055613458, -0.0638541728,
	 1.0, -0.0894841775, -1.2914855480
);

const mat3 LMS_TO_LINRGB = mat3( // Inverse from linear LMS to linear RGB. 
	 4.0767416621, -3.3077115913,  0.2309699292,
	-1.2684380046,  2.6097574011, -0.3413193965,
	-0.0041960863, -0.7034186147,  1.7076147010
);

vec3 OKLAB_TO_LINRGB(vec3 color) { // OkLab to linear RGB. 
	vec3 LMSCBRT = color * OKLAB_TO_LMSCBRT; // OkLab input is in [0, 1], [-1, 1], [-1, 1] for L, a, b respectively. 

	return (LMSCBRT * LMSCBRT * LMSCBRT) * LMS_TO_LINRGB;
}

float LINRGB_TO_LINLUMA(vec3 color) { // Linear RGB to linear OkLab luminosity. 
	float lumaOkLab = dot(pow(color * LINRGB_TO_LMS, vec3(1.0 / 3.0)), vec3( 0.2104542553,  0.7936177850, -0.0040720468));

	return lumaOkLab * lumaOkLab * lumaOkLab; // Evaluated by converting a OkLab sample with a & b components set to zero. Simplifies the matMuls to all L components, just with the power curve linearised. 
}

float OKLAB_TO_LINLUMA(vec3 color) { // OkLab to linear OkLab luminosity. 
	return color.r * color.r * color.r; // Linearise the power curve of L. 
}