#version 430 core
#include "/libs/compat.glsl"
#pragma optimize(on)

layout (triangles, invocations = 2) in;
layout (triangle_strip, max_vertices = 3) out;

#include "/libs/GlslConfig"
#include "/libs/voxels.glsl"

in VS_Material { 
	flat vec4 vColor;
	vec2 texcoord;
	int step;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	vec3 voxelPos;
	
	vec3 normal;
	vec2 n2;
	
	mat4 ModelViewMatrix;
	mat4 ProjectionMatrix;
} gs_in[];

out GS_Material { 
	flat int t;
	flat vec4 vColor;
	vec2 texcoord;
	float flag;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	
	vec3 normal;
	vec2 n2;
} gs_out;

uniform vec3 cameraPosition;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjectionInverse;

void gsCommons(int n) {
	gs_out.t = gl_InvocationID;
	gs_out.vColor = gs_in[n].vColor;
	gs_out.texcoord = gs_in[n].texcoord;

	gs_out.wpos = gs_in[n].wpos;
	gs_out.vpos = gs_in[n].vpos;
	gs_out.NDC = gs_in[n].NDC;

	gs_out.flag = gs_in[n].voxelPos.p;

	gs_out.normal = gs_in[n].normal;
	gs_out.n2 = gs_in[n].n2;
}

void main() {
	vec3 average_pos = vec3(0.0);
	for (int m = 0; m < gl_in.length(); ++m) {
		average_pos += gs_in[m].wpos.xyz;// / gs_in[m].wpos.w;
	}
	average_pos /= gl_in.length();
	
	for (int n = 0; n < gl_in.length(); ++n) {
		gsCommons(n);
		if (gl_InvocationID == 0) {
			gl_Position = gl_in[n].gl_Position;
			if (gs_in[n].step == 2) gl_Position.x += gl_Position.w;
			EmitVertex();
		} else {
			if (gs_in[n].step == 1) {
				gl_Position = gl_in[n].gl_Position;
				gl_Position.x += gl_Position.w;
				
				EmitVertex();
			} else if (gs_in[n].step != 3) {
				vec3 p = mix(average_pos, gs_in[n].wpos.xyz, 0.8);
				gl_Position = vec4(toVoxelSpace(p), 0.0, 1.0);
				//gl_Position.xy = gl_Position.xy * 0.5 + 0.5 * gl_Position.w;
				EmitVertex();
			}
		}
	}
	EndPrimitive();
}