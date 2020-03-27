#version 430 compatibility
#include "/libs/compat.glsl"
#pragma optimize(on)

/* DRAWBUFFERS:3 */
#define OUT_TEX 3
#include "/libs/Program/deferred.inc"

uniform sampler2D composite;
uniform sampler2D gaux1;
uniform sampler2D shadowcolor0;

#include "/libs/lighting.frag"
#include "/libs/material.glsl"

Material frag;

void main() {
	vec4 s = texture2D(gaux1, texcoord);
	init_Material(frag, texcoord, s.q);
	/*float depth = texture2D(depthtex1, texcoord).x;
	vec4 vpos = fetch_vpos(texcoord, depth);
	vec3 wpos = fetch_wpos(vpos);*/
	vec3 wN = fetch_wpos(frag.normal);
	vec3 spos = wpos2shadowpos(frag.wpos.xyz + wN * 0.12);
	vec3 sun = suncolor;
	float shadow = light_fetch_shadow(shadowcolor0, spos, sun, (1.0 - max(0.0, dot(frag.normal, shadowLightVectorView))) * 0.5 + 0.05);
	Color0 = texture2D(composite, texcoord);
	Color0.rgb *= 1.0 - shadow * 0.8;
}