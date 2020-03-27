#version 430 core
#pragma optimize(on)

//#define EYE_3D

#ifdef EYE_3D
#define EYE_3D_VIEW_WIDE 0.5 //[0.3 0.35 0.4 0.42 0.45 0.47 0.48 0.49 0.498 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define SEPARATE_VIEWPORT_INDEX 0.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define HALF_PUPIL_DISTANCE 0.1 //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.22 0.25 0.27 0.3 0.35 0.4 0.45 0.5]
#define VIEWPORT_SCALE 1.0 //[0.5 0.6 0.7 0.8 0.85 0.9 0.92 0.95 0.97 0.99 1.0]

layout (lines, invocations = 2) in;
#else
layout (lines, invocations = 1) in;
#endif
layout (line_strip, max_vertices = 2) out;

in VS_Material {
	flat vec4 vColor;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
} gs_in[];

out GS_Material {
	flat int t;
	flat vec4 vColor;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
} gs_out;

uniform mat4 gbufferProjection;

void main() {
	gs_out.t = gl_InvocationID;
	
	#ifdef EYE_3D
	int i = sign(gs_out.t * 2 - 1);
	const float s0 = EYE_3D_VIEW_WIDE * VIEWPORT_SCALE;
	const float s = mix(s0 , max(s0, 0.5), SEPARATE_VIEWPORT_INDEX);
	#endif
	
	for (int n = 0; n < gl_in.length(); ++n) {
		gs_out.vColor = gs_in[n].vColor;
		
		gs_out.wpos = gs_in[n].wpos;
		gs_out.vpos = gs_in[n].vpos;
		
		#ifdef EYE_3D
			gs_out.vpos.x += i * HALF_PUPIL_DISTANCE;
			gs_out.NDC = gbufferProjection * gs_out.vpos;
			gl_Position = gs_out.NDC;
			gl_Position.xy *= VIEWPORT_SCALE;
			gl_Position.x -= i * s * gl_Position.w;
		#else
			gl_Position = gl_in[n].gl_Position;
		#endif
		
		EmitVertex();
	}
	EndPrimitive();
}