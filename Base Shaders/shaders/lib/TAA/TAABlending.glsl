void TAAFetchPreviousPixelsCatmullRom(out vec4 previous1, out vec4 previous2, sampler2D previousColorTex, int direction, vec2 uv, ivec2 screenSize) { // CatmullRom could be used twice for two samples spaced by one diagonal pixel, or taps could be pooled together for optimisation, which is what I have done here. See lib/samplers.glsl for more info. 
    vec2 xy      = uv * screenSize - 0.5;
    vec2 weights = fract(xy);

    if (weights.x + weights.y == 0.0) {
        previous1 = texelFetch(previousColorTex, ivec2(xy), 0);
        previous2 = texelFetchOffset(previousColorTex, ivec2(xy), 0, direction * ivec2( 1,  1));
    } else if (weights.x == 0.0) {
        ivec2 xy10 = ivec2(xy.x, floor(xy.y - 1.0));

        vec4 color10 = texelFetch(previousColorTex, xy10, 0);
        vec4 color11 = texelFetchOffset(previousColorTex, xy10, 0, ivec2( 0,  1));
        vec4 color12 = texelFetchOffset(previousColorTex, xy10, 0, ivec2( 0,  2));
        vec4 color13 = texelFetchOffset(previousColorTex, xy10, 0, ivec2( 0,  3));

        previous1 = catmullRom(color10, color11, color12, color13, weights.y);

        vec4 colorDir0 = texelFetchOffset(previousColorTex, xy10, 0, ivec2( 0,  0) + direction);
        vec4 colorDir1 = texelFetchOffset(previousColorTex, xy10, 0, ivec2( 0,  1) + direction);
        vec4 colorDir2 = texelFetchOffset(previousColorTex, xy10, 0, ivec2( 0,  2) + direction);
        vec4 colorDir3 = texelFetchOffset(previousColorTex, xy10, 0, ivec2( 0,  3) + direction);

        previous2 = catmullRom(colorDir0, colorDir1, colorDir2, colorDir3, weights.y);
    } else if (weights.y == 0.0) {
        ivec2 xy01 = ivec2(floor(xy.x - 1.0), xy.y);

        vec4 color01 = texelFetch(previousColorTex, xy01, 0);
        vec4 color11 = texelFetchOffset(previousColorTex, xy01, 0, ivec2( 1,  0));
        vec4 color21 = texelFetchOffset(previousColorTex, xy01, 0, ivec2( 2,  0));
        vec4 color31 = texelFetchOffset(previousColorTex, xy01, 0, ivec2( 3,  0));

        previous1 = catmullRom(color01, color11, color21, color31, weights.x);

        vec4 colorDir0 = texelFetchOffset(previousColorTex, xy01, 0, ivec2( 0,  0) + direction);
        vec4 colorDir1 = texelFetchOffset(previousColorTex, xy01, 0, ivec2( 1,  0) + direction);
        vec4 colorDir2 = texelFetchOffset(previousColorTex, xy01, 0, ivec2( 2,  0) + direction);
        vec4 colorDir3 = texelFetchOffset(previousColorTex, xy01, 0, ivec2( 3,  0) + direction);

        previous2 = catmullRom(colorDir0, colorDir1, colorDir2, colorDir3, weights.x);
    } else {
        ivec2 xy00 = ivec2(floor(xy)) - 1;

        vec4 color00 = texelFetch(previousColorTex, xy00, 0);
        vec4 color01 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 0,  1));
		vec4 color02 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 0,  2));
		vec4 color03 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 0,  3));
        vec4 color10 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 1,  0));
        vec4 color11 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 1,  1));
		vec4 color12 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 1,  2));
		vec4 color13 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 1,  3));
		vec4 color20 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 2,  0));
        vec4 color21 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 2,  1));
		vec4 color22 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 2,  2));
		vec4 color23 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 2,  3));
		vec4 color30 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 3,  0));
        vec4 color31 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 3,  1));
		vec4 color32 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 3,  2));
		vec4 color33 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 3,  3));

        vec4 interp0Y = catmullRom(color00, color01, color02, color03, weights.y);
        vec4 interp1Y = catmullRom(color10, color11, color12, color13, weights.y);
        vec4 interp2Y = catmullRom(color20, color21, color22, color23, weights.y);
        vec4 interp3Y = catmullRom(color30, color31, color32, color33, weights.y);

        previous1 = catmullRom(interp0Y, interp1Y, interp2Y, interp3Y, weights.x);
        
        if (direction == 1) {
            vec4 color14 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 1,  4));
            vec4 color24 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 2,  4));
            vec4 color34 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 3,  4));
            vec4 color44 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 4,  4));
            vec4 color43 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 4,  3));
            vec4 color42 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 4,  2));
            vec4 color41 = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 4,  1));

            vec4 interpDir0 = catmullRom(color11, color12, color13, color14, weights.y);
            vec4 interpDir1 = catmullRom(color21, color22, color23, color24, weights.y);
            vec4 interpDir2 = catmullRom(color31, color32, color33, color34, weights.y);
            vec4 interpDir3 = catmullRom(color41, color42, color43, color44, weights.y);

            previous2 = catmullRom(interpDir0, interpDir1, interpDir2, interpDir3, weights.x);
        } else {
            vec4 colorMinus12      = texelFetchOffset(previousColorTex, xy00, 0, ivec2(-1,  2));
            vec4 colorMinus11      = texelFetchOffset(previousColorTex, xy00, 0, ivec2(-1,  1));
            vec4 colorMinus10      = texelFetchOffset(previousColorTex, xy00, 0, ivec2(-1,  0));
            vec4 colorMinus1Minus1 = texelFetchOffset(previousColorTex, xy00, 0, ivec2(-1, -1));
            vec4 color0Minus1      = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 0, -1));
            vec4 color1Minus1      = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 1, -1));
            vec4 color2Minus1      = texelFetchOffset(previousColorTex, xy00, 0, ivec2( 2, -1));

            vec4 interpDir0 = catmullRom(colorMinus1Minus1, colorMinus10, colorMinus11, colorMinus12, weights.y);
            vec4 interpDir1 = catmullRom(color0Minus1, color00, color01, color02, weights.y);
            vec4 interpDir2 = catmullRom(color1Minus1, color10, color11, color12, weights.y);
            vec4 interpDir3 = catmullRom(color2Minus1, color20, color21, color22, weights.y);

            previous2 = catmullRom(interpDir0, interpDir1, interpDir2, interpDir3, weights.x);
        }
    }
}

vec4 TAABlending(out vec4 temporalColor, sampler2D currentColorTex, sampler2D previousColorTex, sampler2D velocityTex, int frameMod2, vec2 uv, ivec2 screenSize) {
    ivec2 texelCoord = ivec2(floor(uv * screenSize));
    int direction    = 1 - 2 * frameMod2; // 0th frame --> 1, 1st frame --> -1. 

    vec4 current1 = texelFetch(currentColorTex, texelCoord, 0); // (+0.25, +0.25) * jitterDirection. Local coord system accounts for +0.25 or -0.25 render offset. These values here represent net jitter on screen. 
    
    temporalColor = current1; // Output current pixel to save for non-clearing previousColorTex. 

    vec4 previous1, previous2; // (-0.25, -0.25) * jitterDirection, (+0.75, +0.75) * jitterDirection. 

    vec2 velocity = texelFetch(velocityTex, texelCoord, 0).xy; // Tells how to go from previous uv to current uv, so should be subtracted from current uv. 

    TAAFetchPreviousPixelsCatmullRom(previous1, previous2, previousColorTex, direction, uv - velocity, screenSize); // Sample the previous pixels. 

    float weight = min(sqrt(abs(current1.a - previous1.a)) * 16.0 + 0.5, 1.0); // Attenuate the blending if difference in magnitudes of current and previous velocities are large. 

    if (weight == 1.0) return current1; // Optimised early exit for reducing unnecessary operations. 

    vec4 current2 = texelFetchOffset(currentColorTex, texelCoord, 0, direction * ivec2(-1, -1)); // (-0.75, -0.75) * jitterDirection. This sample does not need to be taken if blending weight is 1.0 and current1 will be returned anyways. 
    
    return catmullRom(current2, previous1, current1, previous2, weight); // Idea here is to interlace two current and two previous samples so that they are spatially equidistant and carry the same weights temporally, as well as are blended symmetrically over-time as jitter direction alternates. Interlacing also allows a difference of one diagonal pixel for the current samples, meaning point sampling can be used twice instead of one point sample and one catmullRom sample. 
}
