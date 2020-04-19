#version 430 compatibility
#include "/libs/compat.glsl"
#pragma optimize(on)

in vec2 texcoord;

/* DRAWBUFFERS:3 */
#define OUT_TEX 0
#include "/libs/Program/outTex.inc"

#include "/libs/GlslConfig"

uniform sampler2D colortex0;
uniform sampler2D colortex3;
uniform sampler2D gaux1;

#include "/libs/utility.glsl"
#include "/libs/material.glsl"

Material frag;

void main() {
	float flag = texture(gaux1, texcoord).q;
	
	init_Material(frag, texcoord, flag);
	float fog = smoothstep(0.99954, 1.0, frag.NDC.z);
	
	vec3 wpos = frag.wpos;
	float h = (cameraPosition.y - 64.0) * 0.19;
	wpos.y += h;
	vec3 nwpos = normalize(wpos.xyz);
	vec3 color = texture(colortex3, texcoord).rgb;
	vec3 sky = color * float(frag.mask.sky) * 32.0;
	sky += texture(colortex0, project_skybox2uv(nwpos)).rgb;
	Color0 = vec4(mix(color, sky, fog), 1.0f);
}