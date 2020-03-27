#version 430 compatibility
#pragma optimize(on)

#define attribute in

attribute vec3 mc_Entity;
attribute vec4 at_tangent;

#define NORMALS

out VS_Material { 
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
} vs_out;

vec2 normalEncode(vec3 n) {return sqrt(-n.z*0.125+0.125) * normalize(n.xy) + 0.5;}

void main() {
	vs_out.wpos = gl_Vertex;
	vs_out.vpos = gl_ModelViewMatrix * vs_out.wpos;
	vs_out.NDC = gl_ProjectionMatrix * vs_out.vpos;
	gl_Position = vs_out.NDC;
	//gl_Position.z = gl_Position.z * 0.5 + 0.25;
	vs_out.vColor = gl_Color;
	vs_out.texcoord = gl_MultiTexCoord0.st;
	vs_out.blockID = mc_Entity.xyz;
	
	vs_out.normal = gl_NormalMatrix * gl_Normal;
	vs_out.n2 = normalEncode(vs_out.normal);
	
	vs_out.ModelViewMatrix = gl_ModelViewMatrix;
	vs_out.ProjectionMatrix = gl_ProjectionMatrix;
}
