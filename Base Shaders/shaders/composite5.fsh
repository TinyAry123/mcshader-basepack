#version 150

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;

#define AMD_CAS // Enable or disable CAS. 

#ifdef AMD_CAS
	#include "lib/common.glsl"
	#include "lib/CAS.glsl"
#endif

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
	vec4 color = texelFetch(colortex0, ivec2(floor(uv * screenSize)), 0);

	#ifdef AMD_CAS
		CAS(color.rgb, colortex0, uv, screenSize);
	#endif

	colortex0Out = color;
}