#version 150

/* RENDERTARGETS: 0,1 */

uniform float alphaTestRef;

in vec4 tint;
in vec3 normal;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex1Out;

void main() {
	vec4 color = tint;

	if (color.a < alphaTestRef) discard;

	colortex0Out = color;
	colortex1Out = vec4(normal, 1.0);
}