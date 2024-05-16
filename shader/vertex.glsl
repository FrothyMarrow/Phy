#version 330 core

layout(location = 0) in vec3 aPos;

uniform mat4 uProjection;
uniform mat4 uView;

out vec2 fragColor;

void main() { gl_Position = uProjection * uView * vec4(aPos.xyz, 1.0f); }
