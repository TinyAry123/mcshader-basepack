#version 150

/* RENDERTARGETS: 2 */

uniform sampler2D colortex0;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex2Out;

#define SMAA // Enable or disable SMAA. 

#ifdef SMAA
    #include "lib/SMAA/SMAAEdgeDetection.glsl"
#endif

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
    #ifdef SMAA
        vec2 SMAAEdges;
        SMAAEdgeDetection(SMAAEdges, colortex0, uv, screenSize);

        colortex2Out = vec4(SMAAEdges, 0.0, 0.0);
    #else
        colortex2Out = vec4(0.0);
    #endif
}