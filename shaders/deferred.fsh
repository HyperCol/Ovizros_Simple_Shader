#version 430 compatibility
#include "/libs/compat.glsl"
#pragma optimize(on)

in vec3 sunLight;
in vec3 sunraw;
in vec3 ambientU;

#define CLOUDS_2D
#define UOS

/* DRAWBUFFERS:3240 */
#define OUT_TEX 3
#include "/libs/Program/deferred.inc"

uniform sampler2D colortex1;
uniform sampler2D gnormal;
uniform sampler2D composite;
uniform sampler2D gaux1;

#include "libs/atmosphere.glsl"

void main() {
	Color0 = fromGamma(texture2D(composite, texcoord));
	vec3 pbr = texture2D(gaux1,texcoord).rgb;
	vec3 lmcoord = texture2D(colortex1, texcoord).rgb;
	vec2 n = texture2D(gnormal, texcoord).xy;
	Color1 = vec4(n, lmcoord.xy);
	Color2 = vec4(pbr, lmcoord.p);
	Color2.r = clamp(Color2.r, 0.01, 0.95);
	
	if (texcoord.y < 0.5) {
		vec3 worldLightPosition = sunVector;
		vec3 nwpos = project_uv2skybox(texcoord);
		
		/*float h = (cameraPosition.y - 64.0) * 0.0625;
		nwpos *= 128.0;
		nwpos.y += h;
		nwpos = normalize(nwpos);*/

		float mu_s = dot(nwpos, worldLightPosition);
		float mu = abs(mu_s);

		vec3 color = scatter(vec3(0., 2e3 + cameraPosition.y, 0.), nwpos, worldLightPosition, Ra);
		float horizon_mask = smoothstep(0.1, 0.3, luma(color));
		
		#ifdef CLOUDS_2D
		float cmie = calc_clouds(nwpos * 512.0, cameraPosition);

		float opmu2 = 1. + mu*mu;
		float phaseM = .1193662 * (1. - g2) * opmu2 / ((2. + g2) * pow(1. + g2 - 2.*g*mu, 1.5));
		color += (luma(ambientU) + sunraw * phaseM * 0.2) * cmie;
		#endif
		
		color += sunraw * 5.0 * step(0.9998, mu_s) * horizon_mask;
		Color3 = vec4(color, 1.0f);
	}
}