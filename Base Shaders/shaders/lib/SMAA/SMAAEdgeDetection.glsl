/*
Note that SMAA was natively implemented in HLSL, using a top-to-bottom y-axis, 
so these y-coordinates are actually sampling in the opposite direction for our GLSL app. 
This still works and is implemented correctly if you stick with the flipped coordinate system 
throughout all three passes of SMAA. The comments and naming semantics here and for the next 
two stages still follow in a top-to-bottom y-axis though, so keep that in mind. 

SMAA runs in three passes:
    1. SMAAEdgeDetection             --> produces edgesTex (colortex2)
    2. SMAABlendingWeightCalculation --> produces blendTex (colortex2)
    3. SMAANeighborhoodBlending      --> produces final color (colortex0)

Other notes:
    1. Source SMAA used a maximum derivative method for edge detection, where change in red, green
       and blue is calculated, then the maximum of the deltas is used for thresholding. This 
       technique was developed before the open-source release of the OkLab color space, which 
       is a perceptually uniform space for representing color. I made changes to the edge detection 
       technique, where instead of using linear RGB, linear OkLab is used and the change in luminosity 
       is scaled down to match a general average edge activation count of the thresholded a and b 
       channels. This provides a much better perceptual approximation of where edges are located. 
    2. OkLab is non-linear, and to linearise it, the L, a & b components have to be evaluated 
       separately with the other components set to zero, and back-tracked through the inverse matrix 
       multiplications to find an optimised method of linearising the data. For L, it is 
       straight-forward as applying a cubic function will linearise it. For a and b, the linearisation
       is also to apply a cubic function, but there is an additional constant which is not relative with 
       the L component, which is why you see here that the difference in L is multiplied by 0.078125 to match
       a similar average edge activation amount using just a and b. 
    3. Linearising all the OkLab color data here can be optimised if you rewrite the color before
       edge detection to be linearised, but i've found it less of a hassle to just code it this way. 
    4. SMAA T2x requires specific offsets to work properly so that the area and search textures of SMAA 
       are also offset with each sub-pixel jitter. 
*/

void SMAAEdgeDetection(out vec2 edges, sampler2D colorTex, vec2 uv, ivec2 screenSize) {
    ivec2 texelCoord = ivec2(floor(uv * screenSize));
    vec4 delta;
    vec3 currentColor, difference;

    vec3 colorCenter = pow(texelFetch(colorTex, texelCoord, 0).rgb, ivec3(3));

    currentColor = pow(texelFetch(colorTex, texelCoord + ivec2(-1,  0), 0).rgb, ivec3(3)); // Left texel. 
    difference   = abs(colorCenter - currentColor);
    delta.x      = max(max(difference.r * 0.0078125, difference.g), difference.b);

    currentColor = pow(texelFetch(colorTex, texelCoord + ivec2( 0, -1), 0).rgb, ivec3(3)); // Top texel. 
    difference   = abs(colorCenter - currentColor);
    delta.y      = max(max(difference.r * 0.0078125, difference.g), difference.b);

    edges = step(0.00048828125, delta.xy);

    if (edges.x + edges.y > 0.0) {
        currentColor = pow(texelFetch(colorTex, texelCoord + ivec2( 1,  0), 0).rgb, ivec3(3)); // Right texel. 
        difference   = abs(colorCenter - currentColor);
        delta.z      = max(max(difference.r * 0.0078125, difference.g), difference.b);
        
        currentColor = pow(texelFetch(colorTex, texelCoord + ivec2( 0,  1), 0).rgb, ivec3(3)); // Bottom texel. 
        difference   = abs(colorCenter - currentColor);
        delta.w      = max(max(difference.r * 0.0078125, difference.g), difference.b);

        vec2 maxDelta = max(delta.xy, delta.zw);

        currentColor = pow(texelFetch(colorTex, texelCoord + ivec2(-2,  0), 0).rgb, ivec3(3)); // Left x2 texel. 
        difference   = abs(colorCenter - currentColor);
        delta.z      = max(max(difference.r * 0.0078125, difference.g), difference.b);

        currentColor = pow(texelFetch(colorTex, texelCoord + ivec2( 0, -2), 0).rgb, ivec3(3)); // Top x2 texel. 
        difference   = abs(colorCenter - currentColor);
        delta.w      = max(max(difference.r * 0.0078125, difference.g), difference.b);

        maxDelta         = max(maxDelta.xy, delta.zw);
        float finalDelta = max(maxDelta.x, maxDelta.y);

        edges = step(finalDelta, 2.0 * delta.xy);
    } else edges = vec2(0.0);
}
