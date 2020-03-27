#version 430 compatibility
#pragma optimize(on)

#define UT
#define UOS
#define OUT_TEX 1
#define _VERTEX_SHADER_
#include "/libs/Program/gbuffers.inc"

uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;

uniform vec3 cameraPosition;

void main() {
	gbufferCommons();
	vs_out.vpos = gl_ModelViewMatrix * gl_Vertex;
	
	vs_out.wpos =  gbufferModelViewInverse * vs_out.vpos;
	
	float h = (cameraPosition.y - 64.0) * 0.03125;
	vs_out.wpos.y -= h;
	vs_out.vpos = gbufferModelView * vs_out.wpos;
	vs_out.NDC = gl_ProjectionMatrix * vs_out.vpos;
	vs_out.wpos.y += h;
	
	vs_out.wpos = vec4(normalize(vs_out.wpos.xyz), 1.0f);
	gl_Position = vs_out.NDC;
}