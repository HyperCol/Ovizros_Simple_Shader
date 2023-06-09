#version 430 compatibility
#pragma optimize(on)

#define attribute in

attribute vec3 mc_Entity;
attribute vec4 at_tangent;

uniform mat4 shadowModelView;
uniform mat4 shadowProjection;
uniform mat4 shadowModelViewInverse;
uniform mat4 shadowProjectionInverse;

#include "/libs/GlslConfig"
#include "/libs/voxels.glsl"

float logistics(float x) {
	return pow(2.0 / (1.0 + exp(-3.0*x)) - 1.0, 0.7);
}

out VS_Material { 
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
} vs_out;

vec2 normalEncode(vec3 n) {return sqrt(-n.z*0.125+0.125) * normalize(n.xy) + 0.5;}

void main() {
	vs_out.wpos = gl_Vertex;
	//if (mc_Entity.x == 8 || mc_Entity.y == 9) vs_out.wpos.y += 0.03;
	vs_out.vpos = gl_ModelViewMatrix * vs_out.wpos;
	vs_out.NDC = gl_ProjectionMatrix * vs_out.vpos;
	vs_out.vpos = shadowProjectionInverse * vs_out.NDC;
	vs_out.wpos = shadowModelViewInverse * vs_out.vpos;
	gl_Position = vs_out.NDC;
	
	float l = sqrt(dot(gl_Position.xy, gl_Position.xy));
	gl_Position.xy /= l * SHADOW_MAP_BIAS + negShadowBias;
	//gl_Position.xy /= l;
	//gl_Position.xy *= logistics(l);
	gl_Position.xy = gl_Position.xy * 0.5 - 0.5 * gl_Position.w;
	
	if (mc_Entity.x == 8 || mc_Entity.x == 9) vs_out.step = 1;
	else if (mc_Entity.x == 95 || mc_Entity.x == 160 || mc_Entity.x == 90 || mc_Entity.x == 165 || mc_Entity.x == 79) vs_out.step = 2;
	else if (mc_Entity.y == 0 && !(mc_Entity.x == 10 || mc_Entity.x == 11)) vs_out.step = 3;
	else vs_out.step = 0;
	
	vs_out.vColor = gl_Color;
	vs_out.texcoord = gl_MultiTexCoord0.st;
	
	vs_out.normal = mat3(shadowModelViewInverse) * gl_NormalMatrix * gl_Normal;
	vs_out.n2 = normalEncode(vs_out.normal);
	
	vs_out.ModelViewMatrix = gl_ModelViewMatrix;
	vs_out.ProjectionMatrix = gl_ProjectionMatrix;
}
