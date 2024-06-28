#version 150

/* RENDERTARGETS: 0,4 */

uniform sampler2D colortex0, depthtex1;
uniform mat4      gbufferPreviousProjection, gbufferProjectionInverse, gbufferPreviousModelView, gbufferModelViewInverse;
uniform vec3      cameraPosition, previousCameraPosition;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex4Out;

#define TAA // Enable or disable TAA. 

#include "lib/optifineSettings.glsl"
#include "lib/common.glsl" 

#ifdef TAA
	#include "lib/TAA/TAACalculateVelocity.glsl"
#endif

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
	vec4 color = texelFetch(colortex0, ivec2(floor(uv * screenSize)), 0);

	#ifdef TAA
		vec2 velocity = TAACalculateVelocity(depthtex1, uv, screenSize);

		colortex4Out = vec4(velocity, 0.0, 0.0);
	#else
		colortex4Out = vec4(0.0);
	#endif
	
	colortex0Out = vec4(LINRGB_TO_OKLAB(SRGB_TO_LINRGB(color.rgb)), color.a);
}