#version 150

/* RENDERTARGETS: 0,1 */

uniform sampler2D gtexture, lightmap;
uniform float     alphaTestRef;

in vec4 tint;
in vec3 normal;
in vec2 uv, uvLightMap;

layout(location = 0) out vec4 colortex0Out;
layout(location = 1) out vec4 colortex1Out;

void main() {
	vec4 color = texture(gtexture, uv) * tint;

	if (color.a < alphaTestRef) discard;
	
	color *= texture(lightmap, uvLightMap);

	colortex0Out = color;
	colortex1Out = vec4(normal, 1.0);
}