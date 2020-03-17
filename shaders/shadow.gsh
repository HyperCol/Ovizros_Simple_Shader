#version 430 core
#pragma optimize(on)

layout (triangles, invocations = 2) in;
layout (triangle_strip, max_vertices = 3) out;

in VS_MAT {
	mat4 ModelViewMatrix;
	mat4 ProjectionMatrix;
} gs_m_in[];

#define SHADOW_MAP_BIAS 0.87f
const float negShadowBias = 1.0f - SHADOW_MAP_BIAS;

#define NORMALS

uniform float far;

in VS_Material { 
	flat vec4 vColor;
	vec2 texcoord;
	float flag;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	
	vec3 normal;
	vec2 n2;
		#ifdef NORMALS
		vec3 tangent;
		vec3 binormal;
		#endif
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
		#ifdef NORMALS
		vec3 tangent;
		vec3 binormal;
		#endif
} gs_out;

void gsCommons(int n) {
	gs_out.t = gl_InvocationID;
	gs_out.vColor = gs_in[n].vColor;
	gs_out.texcoord = gs_in[n].texcoord;

	gs_out.wpos = gs_in[n].wpos;
	gs_out.vpos = gs_in[n].vpos;
	gs_out.NDC = gs_in[n].NDC;

	gs_out.flag = gs_in[n].flag;

	gs_out.normal = gs_in[n].normal;
		#ifdef NORMALS
		gs_out.tangent = gs_in[n].tangent;
		gs_out.binormal = gs_in[n].binormal;
		#endif
	gs_out.n2 = gs_in[n].n2;
}

void main() {
	for (int n = 0; n < gl_in.length(); ++n) {
		gsCommons(n);
		gl_Position = gl_in[n].gl_Position;
		
		float l = length(gl_Position.xy);
		gl_Position.xy /= l * SHADOW_MAP_BIAS + negShadowBias;
		EmitVertex();
	}
	EndPrimitive();
}