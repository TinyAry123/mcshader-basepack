vec4 TAABlending(out vec4 temporalColor, sampler2D currentColorTex, sampler2D previousColorTex, sampler2D velocityTex, int frameMod2, vec2 uv, ivec2 screenSize) {
    ivec2 texelCoord = ivec2(floor(uv * screenSize));
    int direction    = 1 - 2 * frameMod2; // 0th frame --> 1, 1st frame --> -1. 
    
    vec2 velocity = texelFetch(velocityTex, texelCoord, 0).xy; // Tells how to go from previous uv to current uv, so should be subtracted from current uv. 

    vec4 current1  = texelFetch(currentColorTex, texelCoord, 0);           // (+0.25, +0.25) * jitterDirection. Local coord system accounts for +0.25 or -0.25 render offset. These values here represent net jitter on screen. 
    vec4 previous1 = catmullRomTexture2D(previousColorTex, uv - velocity); // (-0.25, -0.25) * jitterDirection. 

    temporalColor = current1; // Output current pixel to save for non-clearing previousColorTex. 

    float weight = min(sqrt(abs(current1.a - previous1.a)) * 16.0 + 0.5, 1.0); // Attenuate blending if difference in magnitudes of current and previous velocities are large. 

    if (weight == 1.0) return current1; // Do not sample additional control points for catmullRom blending if weight is already 1.0. 

    vec4 current2 = texelFetchOffset(currentColorTex, texelCoord, 0, direction * ivec2(-1, -1));          // (-0.75, -0.75) * jitterDirection. 
    vec4 current3 = catmullRomTexture2D(currentColorTex, uv + direction * vec2( 0.5,  0.5) / screenSize); // (+0.75, +0.75) * jitterDirection. 

    return catmullRom(current2, previous1, current1, current3, weight); // Idea here is to interlace three current samples and one previous sample so that they are spatially equidistant and more bias is put on retaining current sharpness, as well as these samples will be blended symmetrically over-time as jitter direction alternates. 
}
