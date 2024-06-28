#version 150

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0, colortex2, colortex4;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;

#define TAA  // Enable or disable TAA. 
#define SMAA // Enable or disable SMAA. 

#ifdef SMAA
	#include "lib/samplers.glsl"
	#include "lib/SMAA/SMAANeighborhoodBlending.glsl"
#endif

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
	#ifdef SMAA
		vec4 color;

		#ifdef TAA
			SMAANeighborhoodBlending(color, colortex0, colortex4, colortex2, true, uv, screenSize);
		#else
			SMAANeighborhoodBlending(color, colortex0, colortex4, colortex2, false, uv, screenSize);
		#endif

		colortex0Out = color;
	#else
		#ifdef TAA
			ivec2 texelCoord = ivec2(floor(uv * screenSize));

			colortex0Out = vec4(texelFetch(colortex0, texelCoord, 0).rgb, length(texelFetch(colortex4, texelCoord, 0).xy));
		#else
			colortex0Out = texelFetch(colortex0, ivec2(floor(uv * screenSize)), 0);
		#endif
	#endif
}