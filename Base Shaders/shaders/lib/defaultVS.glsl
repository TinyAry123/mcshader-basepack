#version 150

uniform mat4 modelViewMatrix, projectionMatrix;

in vec3 vaPosition;
in vec2 vaUV0;

out vec2 uv;

void main() {
	gl_Position = projectionMatrix * (modelViewMatrix * vec4(vaPosition, 1.0));
	
	uv = vaUV0;
}