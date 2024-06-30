/*
These samplers can be used just like texture2D, so replacing usage of texture2D in code shouldn't be too hard. 
The samplers do require viewWidth and viewHeight uniforms to work. 
*/

vec4 texture2DConcept(sampler2D tex, vec2 uv) {
    ivec2 screenSize = ivec2(viewWidth, viewHeight);
    
    vec2 xy      = uv * screenSize - 0.5; // Texel coord as floats, representing where uv is in terms of pixel coordinates. 
    vec2 weights = fract(xy);             // Fractional portion of texel coordinate, representing weights of interpolation. 

    if (weights.x + weights.y == 0.0) { // Just sample at uv if uv lies directly on a pixel; no interpolation needed. 
		return texelFetch(tex, ivec2(xy), 0);
	} else if (weights.x == 0.0) { // No interpolation needed on the x-axis. 
        int y0 = int(floor(xy.y));

        vec4 color00 = texelFetch(tex, ivec2(xy.x, y0    ), 0);
        vec4 color01 = texelFetch(tex, ivec2(xy.x, y0 + 1), 0);

        return mix(color00, color01, weights.y);
    } else if (weights.y == 0.0) { // No interpolation needed on the y-axis. 
        int x0 = int(floor(xy.x));

        vec4 color00 = texelFetch(tex, ivec2(x0    , xy.y), 0);
        vec4 color10 = texelFetch(tex, ivec2(x0 + 1, xy.y), 0);

        return mix(color00, color10, weights.x);
    } else {
        ivec2 xy00 = ivec2(floor(xy));

        vec4 color00 = texelFetch(tex, xy00              , 0);
        vec4 color01 = texelFetch(tex, xy00 + ivec2(0, 1), 0);
        vec4 color10 = texelFetch(tex, xy00 + ivec2(1, 0), 0);
        vec4 color11 = texelFetch(tex, xy00 + ivec2(1, 1), 0);

        vec4 interp0Y = mix(color00, color01, weights.y);
        vec4 interp1Y = mix(color10, color11, weights.y);

        return mix(interp0Y, interp1Y, weights.x);
    }
}

float mitchellBalancedFilterWeight(float x) {
	float c0 = abs(x);

	if (c0 < 1.0) return (7.0 * c0 * c0 * c0 - 12.0 * c0 * c0 + (16.0 / 3.0)) / 6.0;
	
	if (c0 < 2.0) return (12.0 * c0 * c0 - (7.0 / 3.0) * c0 * c0 * c0 - 20.0 * c0 + (32.0 / 3.0)) / 6.0;
	
	return 0.0;
}

vec4 mitchellBalanced(vec4 a, vec4 b, vec4 c, vec4 d, float t) { // Interpolates in-between samples b and c using t [0, 1]. 
	vec4 A = a * mitchellBalancedFilterWeight(t + 1.0);
	vec4 B = b * mitchellBalancedFilterWeight(t      );
	vec4 C = c * mitchellBalancedFilterWeight(t - 1.0);
	vec4 D = d * mitchellBalancedFilterWeight(t - 2.0);

	return A + B + C + D;
}

vec4 mitchellBalancedTexture2D(sampler2D tex, vec2 uv) { // This sampler cannot be optimised for less samples in x and y axis since the mitchellBalanced filter does not exactly represent pixel values directly on their coordinates. 
    ivec2 screenSize = ivec2(viewWidth, viewHeight);
    
    vec2 xy      = uv * screenSize - 0.5;
    vec2 weights = fract(xy);

	ivec2 xy00 = ivec2(floor(xy)) - 1;

	vec4 color00 = texelFetch(tex, xy00              , 0);
	vec4 color01 = texelFetch(tex, xy00 + ivec2(0, 1), 0);
	vec4 color02 = texelFetch(tex, xy00 + ivec2(0, 2), 0);
	vec4 color03 = texelFetch(tex, xy00 + ivec2(0, 3), 0);
	vec4 color10 = texelFetch(tex, xy00 + ivec2(1, 0), 0);
	vec4 color11 = texelFetch(tex, xy00 + ivec2(1, 1), 0);
	vec4 color12 = texelFetch(tex, xy00 + ivec2(1, 2), 0);
	vec4 color13 = texelFetch(tex, xy00 + ivec2(1, 3), 0);
	vec4 color20 = texelFetch(tex, xy00 + ivec2(2, 0), 0);
	vec4 color21 = texelFetch(tex, xy00 + ivec2(2, 1), 0);
	vec4 color22 = texelFetch(tex, xy00 + ivec2(2, 2), 0);
	vec4 color23 = texelFetch(tex, xy00 + ivec2(2, 3), 0);
	vec4 color30 = texelFetch(tex, xy00 + ivec2(3, 0), 0);
	vec4 color31 = texelFetch(tex, xy00 + ivec2(3, 1), 0);
	vec4 color32 = texelFetch(tex, xy00 + ivec2(3, 2), 0);
	vec4 color33 = texelFetch(tex, xy00 + ivec2(3, 3), 0);

	vec4 interp0Y = mitchellBalanced(color00, color01, color02, color03, weights.y);
	vec4 interp1Y = mitchellBalanced(color10, color11, color12, color13, weights.y);
	vec4 interp2Y = mitchellBalanced(color20, color21, color22, color23, weights.y);
	vec4 interp3Y = mitchellBalanced(color30, color31, color32, color33, weights.y);

	return mitchellBalanced(interp0Y, interp1Y, interp2Y, interp3Y, weights.x);
}

vec4 catmullRom(vec4 a, vec4 b, vec4 c, vec4 d, float t) { // Interpolates in-between samples b and c using t [0, 1]. 
    vec4 A = -0.5 * a + 1.5 * b - 1.5 * c + 0.5 * d;
    vec4 B = a - 2.5 * b + 2.0 * c - 0.5 * d;
    vec4 C = -0.5 * a + 0.5 * c;
    vec4 D = b;

    return A * t * t * t + B * t * t + C * t + D;
}

vec4 catmullRomTexture2D(sampler2D tex, vec2 uv) {
    ivec2 screenSize = ivec2(viewWidth, viewHeight);
    
    vec2 xy      = uv * screenSize - 0.5;
    vec2 weights = fract(xy);

    if (weights.x + weights.y == 0.0) {
		return texelFetch(tex, ivec2(xy), 0);
	} else if (weights.x == 0.0) {
        int y0 = int(floor(xy.y)) - 1;

        vec4 color00 = texelFetch(tex, ivec2(xy.x, y0    ), 0);
        vec4 color01 = texelFetch(tex, ivec2(xy.x, y0 + 1), 0);
		vec4 color02 = texelFetch(tex, ivec2(xy.x, y0 + 2), 0);
		vec4 color03 = texelFetch(tex, ivec2(xy.x, y0 + 3), 0);

        return catmullRom(color00, color01, color02, color03, weights.y);
    } else if (weights.y == 0.0) {
        int x0 = int(floor(xy.x)) - 1;

        vec4 color00 = texelFetch(tex, ivec2(x0    , xy.y), 0);
        vec4 color10 = texelFetch(tex, ivec2(x0 + 1, xy.y), 0);
		vec4 color20 = texelFetch(tex, ivec2(x0 + 2, xy.y), 0);
		vec4 color30 = texelFetch(tex, ivec2(x0 + 3, xy.y), 0);

        return catmullRom(color00, color10, color20, color30, weights.x);
    } else {
        ivec2 xy00 = ivec2(floor(xy)) - 1;

        vec4 color00 = texelFetch(tex, xy00              , 0);
        vec4 color01 = texelFetch(tex, xy00 + ivec2(0, 1), 0);
		vec4 color02 = texelFetch(tex, xy00 + ivec2(0, 2), 0);
		vec4 color03 = texelFetch(tex, xy00 + ivec2(0, 3), 0);
        vec4 color10 = texelFetch(tex, xy00 + ivec2(1, 0), 0);
        vec4 color11 = texelFetch(tex, xy00 + ivec2(1, 1), 0);
		vec4 color12 = texelFetch(tex, xy00 + ivec2(1, 2), 0);
		vec4 color13 = texelFetch(tex, xy00 + ivec2(1, 3), 0);
		vec4 color20 = texelFetch(tex, xy00 + ivec2(2, 0), 0);
        vec4 color21 = texelFetch(tex, xy00 + ivec2(2, 1), 0);
		vec4 color22 = texelFetch(tex, xy00 + ivec2(2, 2), 0);
		vec4 color23 = texelFetch(tex, xy00 + ivec2(2, 3), 0);
		vec4 color30 = texelFetch(tex, xy00 + ivec2(3, 0), 0);
        vec4 color31 = texelFetch(tex, xy00 + ivec2(3, 1), 0);
		vec4 color32 = texelFetch(tex, xy00 + ivec2(3, 2), 0);
		vec4 color33 = texelFetch(tex, xy00 + ivec2(3, 3), 0);

        vec4 interp0Y = catmullRom(color00, color01, color02, color03, weights.y);
        vec4 interp1Y = catmullRom(color10, color11, color12, color13, weights.y);
		vec4 interp2Y = catmullRom(color20, color21, color22, color23, weights.y);
		vec4 interp3Y = catmullRom(color30, color31, color32, color33, weights.y);

        return catmullRom(interp0Y, interp1Y, interp2Y, interp3Y, weights.x);
    }
}

vec4 nearestTexture2D(sampler2D tex, vec2 uv) {
    ivec2 screenSize = ivec2(viewWidth, viewHeight);
    
    return texelFetch(tex, ivec2(floor(uv * screenSize)), 0);
}
