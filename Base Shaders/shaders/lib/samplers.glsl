/*
These samplers can be used just like texture2D, so replacing usage of texture2D in code shouldn't be too hard. 
The samplers do require viewWidth and viewHeight uniforms to work. 
*/

vec4 texture2DConcept(sampler2D tex, vec2 uv) {
    vec2 xy      = uv * ivec2(viewWidth, viewHeight) - 0.5; // Texel coord as floats, representing where uv is in terms of pixel coordinates. 
    vec2 weights = fract(xy);                               // Fractional portion of texel coordinate, representing weights of interpolation. 

    if (weights.x + weights.y == 0.0) { // Just sample at uv if uv lies directly on a pixel; no interpolation needed. 
		return texelFetch(tex, ivec2(xy), 0);
	} else if (weights.x == 0.0) { // No interpolation needed on the x-axis. 
        ivec2 xy00 = ivec2(xy.x, floor(xy.y));

        vec4 color00 = texelFetch(tex, xy00, 0);
        vec4 color01 = texelFetchOffset(tex, xy00, 0, ivec2( 0,  1));

        return mix(color00, color01, weights.y);
    } else if (weights.y == 0.0) { // No interpolation needed on the y-axis. 
        ivec2 xy00 = ivec2(floor(xy.x), xy.y);

        vec4 color00 = texelFetch(tex, xy00, 0);
        vec4 color10 = texelFetchOffset(tex, xy00, 0, ivec2( 1,  0));

        return mix(color00, color10, weights.x);
    } else {
        ivec2 xy00 = ivec2(floor(xy));

        vec4 color00 = texelFetch(tex, xy00, 0);
        vec4 color01 = texelFetchOffset(tex, xy00, 0, ivec2( 0,  1));
        vec4 color10 = texelFetchOffset(tex, xy00, 0, ivec2( 1,  0));
        vec4 color11 = texelFetchOffset(tex, xy00, 0, ivec2( 1,  1));

        vec4 interp0Y = mix(color00, color01, weights.y);
        vec4 interp1Y = mix(color10, color11, weights.y);

        return mix(interp0Y, interp1Y, weights.x);
    }
}

vec4 nearestTexture2D(sampler2D tex, vec2 uv) {
    return texelFetch(tex, ivec2(floor(uv * ivec2(viewWidth, viewHeight))), 0);
}

vec4 catmullRom(vec4 a, vec4 b, vec4 c, vec4 d, float t) { // Interpolates in-between samples b and c using t [0, 1]. 
    return b + t * (0.5 * (c - a) + t * (a + 2.0 * c - 2.5 * b - 0.5 * d + t * (1.5 * (b - c) + 0.5 * (d - a))));
}

vec4 catmullRomTexture2D(sampler2D tex, vec2 uv) {
    vec2 xy      = uv * ivec2(viewWidth, viewHeight) - 0.5;
    vec2 weights = fract(xy);

    if (weights.x + weights.y == 0.0) {
		return texelFetch(tex, ivec2(xy), 0);
	} else if (weights.x == 0.0) {
        ivec2 xy10 = ivec2(xy.x, floor(xy.y - 1.0));

        vec4 color10 = texelFetch(tex, xy10, 0);
        vec4 color11 = texelFetchOffset(tex, xy10, 0, ivec2( 0,  1));
		vec4 color12 = texelFetchOffset(tex, xy10, 0, ivec2( 0,  2));
		vec4 color13 = texelFetchOffset(tex, xy10, 0, ivec2( 0,  3));

        return catmullRom(color10, color11, color12, color13, weights.y);
    } else if (weights.y == 0.0) {
        ivec2 xy01 = ivec2(floor(xy.x - 1.0), xy.y);

        vec4 color01 = texelFetch(tex, xy01, 0);
        vec4 color11 = texelFetchOffset(tex, xy01, 0, ivec2( 1,  0));
		vec4 color21 = texelFetchOffset(tex, xy01, 0, ivec2( 2,  0));
		vec4 color31 = texelFetchOffset(tex, xy01, 0, ivec2( 3,  0));

        return catmullRom(color01, color11, color21, color31, weights.x);
    } else {
        ivec2 xy00 = ivec2(floor(xy)) - 1;

        vec4 color00 = texelFetch(tex, xy00, 0);
        vec4 color01 = texelFetchOffset(tex, xy00, 0, ivec2( 0,  1));
		vec4 color02 = texelFetchOffset(tex, xy00, 0, ivec2( 0,  2));
		vec4 color03 = texelFetchOffset(tex, xy00, 0, ivec2( 0,  3));
        vec4 color10 = texelFetchOffset(tex, xy00, 0, ivec2( 1,  0));
        vec4 color11 = texelFetchOffset(tex, xy00, 0, ivec2( 1,  1));
		vec4 color12 = texelFetchOffset(tex, xy00, 0, ivec2( 1,  2));
		vec4 color13 = texelFetchOffset(tex, xy00, 0, ivec2( 1,  3));
		vec4 color20 = texelFetchOffset(tex, xy00, 0, ivec2( 2,  0));
        vec4 color21 = texelFetchOffset(tex, xy00, 0, ivec2( 2,  1));
		vec4 color22 = texelFetchOffset(tex, xy00, 0, ivec2( 2,  2));
		vec4 color23 = texelFetchOffset(tex, xy00, 0, ivec2( 2,  3));
		vec4 color30 = texelFetchOffset(tex, xy00, 0, ivec2( 3,  0));
        vec4 color31 = texelFetchOffset(tex, xy00, 0, ivec2( 3,  1));
		vec4 color32 = texelFetchOffset(tex, xy00, 0, ivec2( 3,  2));
		vec4 color33 = texelFetchOffset(tex, xy00, 0, ivec2( 3,  3));

        vec4 interp0Y = catmullRom(color00, color01, color02, color03, weights.y);
        vec4 interp1Y = catmullRom(color10, color11, color12, color13, weights.y);
		vec4 interp2Y = catmullRom(color20, color21, color22, color23, weights.y);
		vec4 interp3Y = catmullRom(color30, color31, color32, color33, weights.y);

        return catmullRom(interp0Y, interp1Y, interp2Y, interp3Y, weights.x);
    }
}
