/*
These jitter offsets are fixed and should not be changed when using with SMAA, as the T2x mode 
gives the subsample offsets for the area and search textures of SMAA, and only specifically 
with these jitter offsets so that the samples line up after blending. Also note that in the 
SMAA implementation, these offsets were given in GLSL coordinate system and accounted for in the 
HLSL coordinate system in the blending weight calculation stage. Since we are doing the blending weight
calculation in our GLSL coordinate system, these offsets will have to be in HLSL coordinates; so the 
y offsets are inverted here. 
*/

const vec2 TAAJitterOffsets[2] = vec2[2](
    vec2( 0.25,  0.25),
    vec2(-0.25, -0.25)
);

void TAAJitter(inout vec2 positionXY, float perspectiveScalar, int frameMod2, ivec2 screenSize) {
    positionXY += perspectiveScalar * TAAJitterOffsets[frameMod2] / screenSize;
}
