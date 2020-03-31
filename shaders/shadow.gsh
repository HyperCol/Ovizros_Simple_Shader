#version 430 core
#pragma optimize(on)

layout (triangles, invocations = 2) in;
layout (triangle_strip, max_vertices = 3) out;

#define SHADOW_MAP_BIAS 0.87f
const float negShadowBias = 1.0f - SHADOW_MAP_BIAS;

float logistics(float x) {
	return pow(2.0 / (1.0 + exp(-3.0*x)) - 1.0, 0.7);
}


in VS_Material { 
	flat vec4 vColor;
	vec2 texcoord;
	float flag;
	vec3 blockID;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	
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

void gsCommons(int n) {
	gs_out.t = gl_InvocationID;
	gs_out.vColor = gs_in[n].vColor;
	gs_out.texcoord = gs_in[n].texcoord;

	gs_out.wpos = gs_in[n].wpos;
	gs_out.vpos = gs_in[n].vpos;
	gs_out.NDC = gs_in[n].NDC;

	gs_out.flag = gs_in[n].flag;

	gs_out.normal = gs_in[n].normal;
	gs_out.n2 = gs_in[n].n2;
}

void main() {
	for (int n = 0; n < gl_in.length(); ++n) {
		gsCommons(n);
		if (gl_InvocationID == 0) {
			gl_Position = gl_in[n].gl_Position;
			
			float l = sqrt(dot(gl_Position.xy, gl_Position.xy));
			gl_Position.xy /= l * SHADOW_MAP_BIAS + negShadowBias;
			//gl_Position.xy /= l;
			//gl_Position.xy *= logistics(l);
			gl_Position.xy = gl_Position.xy * 0.5 - 0.5 * gl_Position.w;
			
			if (!(gs_in[n].blockID.x == 95 || gs_in[n].blockID.x == 160 || gs_in[n].blockID.x == 90 || gs_in[n].blockID.x == 165 || gs_in[n].blockID.x == 79)) 
				EmitVertex();
		} else {
			if (gs_in[n].blockID.x == 8 || gs_in[n].blockID.x == 9 || gs_in[n].blockID.x == 95 || gs_in[n].blockID.x == 160 || gs_in[n].blockID.x == 90 || gs_in[n].blockID.x == 165 || gs_in[n].blockID.x == 79) {
				gl_Position = gl_in[n].gl_Position;
				
				float l = sqrt(dot(gl_Position.xy, gl_Position.xy));
				gl_Position.xy /= l * SHADOW_MAP_BIAS + negShadowBias;
				//gl_Position.xy /= l;
				//gl_Position.xy *= logistics(l);
				gl_Position.xy = gl_Position.xy * 0.5 - 0.5 * gl_Position.w;
				gl_Position.x += gl_Position.w;
				
				EmitVertex();
			}
		}
	}
	EndPrimitive();
}