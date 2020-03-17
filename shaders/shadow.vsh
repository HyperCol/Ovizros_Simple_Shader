#version 430 compatibility
#pragma optimize(on)

in vec3 mc_Entity;
in vec4 at_tangent;
#define blockID mc_Entity.x

#define NORMALS

out VS_Material { 
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
} vs_out;

vec2 normalEncode(vec3 n) {return sqrt(-n.z*0.125+0.125) * normalize(n.xy) + 0.5;}

void main() {
	vs_out.wpos = gl_Vertex;
	vs_out.vpos = gl_ModelViewMatrix * vs_out.wpos;
	vs_out.NDC = gl_ProjectionMatrix * vs_out.vpos;
	gl_Position = vs_out.NDC;
	vs_out.vColor = gl_Color;
	vs_out.texcoord = gl_MultiTexCoord0.st;
	
	vs_out.normal = gl_NormalMatrix * gl_Normal;
		#ifdef NORMALS
		vs_out.tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
		vs_out.binormal = cross(vs_out.normal, vs_out.tangent);
		#endif
	vs_out.n2 = normalEncode(vs_out.normal);
}
