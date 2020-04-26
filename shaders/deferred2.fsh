#version 430 core
#include "/libs/compat.glsl"
#pragma optimize(on)

/* DRAWBUFFERS:3 */
#define OUT_TEX 3
#include "/libs/Program/deferred.inc"

uniform sampler2D composite;
uniform sampler2D gaux1;

uniform sampler2D shadowcolor0;
const bool shadowtex0Mipmap = true;
const bool shadowtex1Mipmap = true;
const bool shadowcolor0Mipmap = true;

#include "/libs/material.glsl"
#include "/libs/lighting.frag"

Material frag;
Lighting light;

void main() {
	vec4 specular = texture(gaux1, texcoord);
	init_Material(frag, texcoord, specular.q);
	/*float depth = texture(depthtex1, texcoord).x;
	vec4 vpos = fetch_vpos(texcoord, depth);
	vec3 wpos = fetch_wpos(vpos);*/
	vec3 wN = fetch_wpos(frag.normal);
	float l;
	vec3 spos = wpos2shadowpos(frag.wpos.xyz + wN * 0.07, l);
	vec3 sun = suncolor;
	//float s = texture(shadowtex0, spos.xy).x;
	
	float shadow = 0.0;
	shadow = light_fetch_shadow(shadowcolor0, spos, sun, (1.0 - max(0.0, dot(frag.normal, shadowLightVectorView))) * 0.5 + 0.05, l);
	//shadow = step(s, spos.z);
	init_lighting(light, texture(composite, texcoord).rgb, specular.rgb, sun, shadow);
	Color0 = vec4(light_calc_PBR(frag, light), 0.0f);
	//Color0.rgb *= 1.0 - shadow * 0.8;
	//Color0 = pow(textureLod(shadowtex0,spos.xy, 0.0), vec4(2.0));
	//Color0 = .aaaa;
}