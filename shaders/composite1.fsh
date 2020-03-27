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

void main() {
	float flag = texture2D(gaux1, texcoord).q;
	if (flag == 0) discard;
	float depth = texture2D(depthtex0, texcoord).x;
	float fog = smoothstep(0.9996, 1.0, depth);
	
	vec4 vpos = fetch_vpos(texcoord, depth);
	vec4 wpos = gbufferModelViewInverse * vpos;
	float h = (cameraPosition.y - 64.0) * 0.29;
	wpos.y += h;
	vec3 nwpos = normalize(wpos.xyz);
	vec3 color = texture2D(colortex3, texcoord).rgb;
	vec3 sky = color * step(0.98, flag);
	sky += texture2D(colortex0, project_skybox2uv(nwpos)).rgb;
	Color0 = vec4(mix(color, sky, fog), 1.0f);
}