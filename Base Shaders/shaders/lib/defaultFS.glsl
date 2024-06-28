#version 150

/* RENDERTARGETS: 0 */

uniform sampler2D colortex0;
uniform float     viewWidth, viewHeight;

in vec2 uv;

layout(location = 0) out vec4 colortex0Out;

ivec2 screenSize = ivec2(viewWidth, viewHeight);

void main() {
	ivec2 texelCoord = ivec2(floor(uv * screenSize));

	colortex0Out = texelFetch(colortex0, texelCoord, 0);
}