#version 150

/* RENDERTARGETS: 0,3 */

uniform sampler2D colortex0, colortex3, colortex4;
uniform float     viewWidth, viewHeight;
uniform int       frameMod2;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex3Out;

#define TAA // Enable or disable TAA. 

#ifdef TAA
    #include "lib/samplers.glsl"
	#include "lib/TAA/TAABlending.glsl"
#endif

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
    #ifdef TAA
        vec4 temporalColor;
        vec4 color = TAABlending(temporalColor, colortex0, colortex3, colortex4, frameMod2, uv, screenSize);

        colortex0Out = color;
        colortex3Out = temporalColor;
    #else
        colortex0Out = texelFetch(colortex0, ivec2(floor(uv * screenSize)), 0);
        colortex3Out = vec4(0.0);
    #endif
}
