#version 150

/* RENDERTARGETS: 2 */

uniform sampler2D colortex2, colortex14, colortex15;
uniform float     viewWidth, viewHeight;
uniform int       frameMod2;

in vec2 uv;

layout(location = 0) out vec4 colortex2Out;

#define TAA  // Enable or disable TAA. 
#define SMAA // Enable or disable SMAA. 

#ifdef SMAA
	#include "lib/SMAA/SMAABlendingWeightCalculation.glsl"
#endif

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
	#ifdef SMAA
		vec4 SMAAWeights;

		#ifdef TAA
			SMAABlendingWeightCalculation(SMAAWeights, colortex2, colortex14, colortex15, true, frameMod2, uv, screenSize);
		#else
			SMAABlendingWeightCalculation(SMAAWeights, colortex2, colortex14, colortex15, false, 0, uv, screenSize);
		#endif

		colortex2Out = SMAAWeights;
	#else
		colortex2Out = vec4(0.0);
	#endif
}