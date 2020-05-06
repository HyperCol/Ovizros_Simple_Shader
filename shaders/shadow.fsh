#version 330 compatibility
#include "/libs/compat.glsl"
#pragma optimize(on)

layout (location = 0) out vec4 Color0;
layout (location = 1) out vec4 Color1;

uniform sampler2D tex;

in GS_Material { 
	flat int t;
	flat vec4 vColor;
	vec2 texcoord;
	float flag;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	
	vec3 normal;
	vec2 n2;
} fs_in;

#include "/libs/GlslConfig"
#include "/libs/utility.glsl"

void main() {
	if (fs_in.t == 1) {
		Color0 = texture(tex, fs_in.texcoord) * fs_in.vColor;
		Color1 = vec4(1.0);
	} else {
		Color0 = texture(tex, fs_in.texcoord) * fs_in.vColor;//vec4(fs_in.texcoord, 0.0, 1.0);//
		Color1 = vec4(1.0);
	}
}