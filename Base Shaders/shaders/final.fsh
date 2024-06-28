#version 150

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;

#define ZOOM 1 // Zooming for debug purposes. [1 2 4 8 16 32 64]

#include "lib/common.glsl"

#if ZOOM > 1
	#include "lib/samplers.glsl"
#endif

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
	#if ZOOM == 1
		vec4 color = texelFetch(colortex0, ivec2(floor(uv * screenSize)), 0);
	#else
		vec4 color = catmullRomTexture2D(colortex0, (uv - 0.5) / float(ZOOM) + 0.5);
	#endif

	colortex0Out = vec4(LINRGB_TO_SRGB(OKLAB_TO_LINRGB(color.rgb)), color.a);
}