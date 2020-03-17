#version 430 compatibility
#pragma optimize(on)

out vec2 texcoord;

void main() {
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	texcoord = gl_MultiTexCoord0.st;
}