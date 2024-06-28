#version 150

uniform mat4  modelViewMatrix, projectionMatrix;
uniform float viewWidth, viewHeight;
uniform int   frameMod2;

in vec4 vaColor;
in vec3 vaPosition, vaNormal;

out vec4 tint;
out vec3 normal;

#define TAA // Enable or disable TAA. 

#ifdef TAA
	#include "lib/TAA/TAAJitter.glsl"
#endif

const float viewShrink     = 255.0 / 256.0;
const mat4 viewScaleMatrix = mat4(
	viewShrink, 0.0,        0.0,        0.0,
	0.0,        viewShrink, 0.0,        0.0,
	0.0,        0.0,        viewShrink, 0.0,
	0.0,        0.0,        0.0,        1.0
);

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
	vec4 lineStartPosition = projectionMatrix * (viewScaleMatrix * (modelViewMatrix * vec4(vaPosition, 1.0)));
	vec4 lineEndPosition   = projectionMatrix * (viewScaleMatrix * (modelViewMatrix * vec4(vaPosition + vaNormal, 1.0)));

	vec3 startNDC = lineStartPosition.xyz / lineStartPosition.w;

	vec2 lineScreenDirection = normalize((lineEndPosition.xy / lineEndPosition.w - startNDC.xy) * screenSize);
	vec2 lineOffset          = vec2(-lineScreenDirection.y, lineScreenDirection.x) * 2.0 / screenSize;

	if (lineOffset.x < 0.0) lineOffset = -lineOffset;

	if (gl_VertexID % 2 != 0) lineOffset = -lineOffset;

	gl_Position = vec4((startNDC + vec3(lineOffset, 0.0)) * lineStartPosition.w, lineStartPosition.w);

	#ifdef TAA
		gl_Position.xy = TAAJitter(gl_Position.xy, gl_Position.w);
	#endif

	tint   = vaColor;
	normal = vaNormal;
}