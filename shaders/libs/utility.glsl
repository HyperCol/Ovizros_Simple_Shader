/*
 * Copyright 2020 Ovizro
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
 
#ifndef _INCLUDE_UTILITIES_
#define _INCLUDE_UTILITIES_

#define sum4(x) (dot(vec4(1.0), x))
#define sum3(x) (dot(vec3(1.0), x))
#define sum2(x) (x.x + x.y)
#define distance2(x) dot(x, x)

#define plus(m, n) ((m + n) - m * n)
#define nor(m, n) ((m + n) - 2 * m * n)

#define select(x, def) float(x == def)
#define Cselect(x, edge0, edge1) float(x == clamp(x, edge0, edge1))

#define Positive(a) clamp(a, 0.0000001, 1.0)

const float PI = 3.141592653f;
const float gamma = 2.2f;
const vec3 agamma = vec3(0.8 / 2.2f);

float pow2(float a) { return a*a; }
float pow3(float a) { return (a*a)*a; }

vec2 pow2(vec2 a) { return a*a; }
vec2 pow3(vec2 a) { return (a*a)*a; }

vec3 pow2(vec3 a) { return a*a; }
vec3 pow3(vec3 a) { return (a*a)*a; }

vec4 pow2(vec4 a) { return a*a; }
vec4 pow3(vec4 a) { return (a*a)*a; }

float linearstep(float edge0, float edge1, float x) {
    float t = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);
	return t;
}

#include "Utilities/uniform.glsl"
#include "Utilities/noise.glsl"
#include "Utilities/vector.glsl"

//==============================================================================
// Color utilities
//==============================================================================

vec3 fromGamma(vec3 c) {
	return pow(c, vec3(gamma));
}

vec4 fromGamma(vec4 c) {
	return pow(c, vec4(gamma));
}

#define SRGB_CLAMP

vec3 toGamma(vec3 c) {
	c = c / (c + 1.0);
	#ifdef SRGB_CLAMP
	vec3 g = pow(c, vec3(agamma));
	return vec3(0.0625) + g * vec3(0.9375);
	#else
	return pow(c, vec3(agamma));
	#endif
}

float luma(in vec3 color) { return dot(color,vec3(0.2126, 0.7152, 0.0722)); }

//==============================================================================
// Light utilities
//==============================================================================

vec3 getLightColor(float ColorTemperature) {

    const vec3 c10 = vec3(1.0, 0.0337, 0.0);
	const vec3 c15 = vec3(1.0, 0.1578, 0.0);
	const vec3 c20 = vec3(1.0, 0.2647, 0.0033);
	const vec3 c30 = vec3(1.0, 0.487, 0.1411);
	const vec3 c35 = vec3(1.0, 0.5809, 0.2433);
	const vec3 c40 = vec3(1.0, 0.6636, 0.3583);
	const vec3 c50 = vec3(1.0, 0.7992, 0.6045); 
	const vec3 c60 = vec3(1.0, 0.9019, 0.8473);
	const vec3 c66 = vec3(0.9917, 0.9513, 0.9844);
	const vec3 c70 = vec3(0.9337, 0.9150, 1.0);
	const vec3 c80 = vec3(0.7874, 0.8187, 1.0);
	const vec3 c90 = vec3(0.6925, 0.7522, 1.0);
	const vec3 c120 = vec3(0.5431, 0.6389, 1.0);
	const vec3 c200 = vec3(0.4196, 0.5339, 1.0);
	const vec3 c400 = vec3(0.3563, 0.4745, 1.0);

    vec3 lightColor = ((linearstep(500.0, 950.0, ColorTemperature)\
		- linearstep(1000.0, 1500.0, ColorTemperature)) * c10\
		+ (linearstep(1000.0, 1500.0, ColorTemperature)\
		- linearstep(1500.0, 2000.0, ColorTemperature)) * c15\
		+ (linearstep(1500.0, 2000.0, ColorTemperature)\
		- linearstep(2000.0, 3000.0, ColorTemperature)) * c20\
		+ (linearstep(2000.0, 3000.0, ColorTemperature)\
		- linearstep(3000.0, 3500.0, ColorTemperature)) * c30\
		+ (linearstep(3000.0, 3500.0, ColorTemperature)\
		- linearstep(3500.0, 4000.0, ColorTemperature)) * c35\
		+ (linearstep(3500.0, 4000.0, ColorTemperature)\
		- linearstep(4000.0, 5000.0, ColorTemperature)) * c40\
		+ (linearstep(4000.0, 5000.0, ColorTemperature)\
		- linearstep(5000.0, 6000.0, ColorTemperature)) * c50\
		+ (linearstep(5000.0, 6000.0, ColorTemperature)\
		- linearstep(6000.0, 6600.0, ColorTemperature)) * c60\
		+ (linearstep(6000.0, 6600.0, ColorTemperature)\
		- linearstep(6600.0, 7000.0, ColorTemperature)) * c66\
		+ (linearstep(6600.0, 7000.0, ColorTemperature)\
		- linearstep(7000.0, 8000.0, ColorTemperature)) * c70\
		+ (linearstep(7000.0, 8000.0, ColorTemperature)\
		- linearstep(8000.0, 9000.0, ColorTemperature)) * c80\
		+ (linearstep(8000.0, 9000.0, ColorTemperature)\
		- linearstep(9000.0, 12000.0, ColorTemperature)) * c90\
		+ (linearstep(9000.0, 12000.0, ColorTemperature)\
		- linearstep(12000.0, 20000.0, ColorTemperature)) * c120\
		+ (linearstep(12000.0, 20000.0, ColorTemperature)\
		- linearstep(20000.0, 40000.0, ColorTemperature)) * c200\
		+ (linearstep(20000.0, 40000.0, ColorTemperature)) * c400);

	//lightColor /= max(dot(lightColor, vec3(0.3333)), (1.0 - smoothstep(500.0, 800.0, ColorTemperature)));

    return lightColor;
}
#endif 