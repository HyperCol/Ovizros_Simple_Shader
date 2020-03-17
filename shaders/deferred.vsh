#version 430 compatibility
#pragma optimize(on)

#define AT_LSTEP

#define UOS
#define OUT_TEX 0
#define _VERTEX_SHADER_
#include "/libs/Program/deferred.inc"
#include "libs/atmosphere.glsl"

out vec3 sunLight;
out vec3 sunraw;
out vec3 ambientU;

void main() {
	deferredCommons();
	vec3 worldLightPosition = sunVector;
	float f = pow(max(abs(worldLightPosition.y), 0.0), 1.5);
	sunraw = scatter(vec3(0., 25e2, 0.), worldLightPosition, worldLightPosition, Ra) * (1.0 - cloud_coverage * 0.9) + vec3(0.003, 0.005, 0.009) * max(0.0, -worldLightPosition.y) * (1.0 - cloud_coverage * 0.8);
	sunLight = (sunraw) * f;

	ambientU = scatter(vec3(0., 25e2, 0.), vec3( 0.0,  1.0,  0.0), worldLightPosition, Ra) * 0.8;
}