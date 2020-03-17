#version 430 compatibility
#pragma optimize(on)

out vec2 tex;

#define _VERTEX_SHADER_
#include "/libs/utility.glsl"
#include "/libs/Program/atmosphere.inc"

void main() {
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	tex = gl_MultiTexCoord0.st;
	
	atmosphereCommons;
}