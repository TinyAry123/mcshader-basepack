#version 150

uniform mat4  modelViewMatrix, projectionMatrix;
uniform float viewWidth, viewHeight;
uniform int   frameMod2;

in vec4 vaColor;
in vec3 vaPosition, vaNormal;

out vec3 starColor, normal;

#define TAA // Enable or disable TAA. 

#ifdef TAA
	#include "lib/TAA/TAAJitter.glsl"
#endif

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
	gl_Position = projectionMatrix * (modelViewMatrix * vec4(vaPosition, 1.0));

	#ifdef TAA
		TAAJitter(gl_Position.xy, gl_Position.w, frameMod2, screenSize);
	#endif

	starColor = vaColor.rgb;
	normal    = vaNormal;
}
