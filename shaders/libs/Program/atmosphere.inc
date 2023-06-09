#ifndef _INCLUDE_ATOMOSPHERE_INC_
#define _INCLUDE_ATOMOSPHERE_INC_

/*
 *==============================================================================
 *------------------------------------------------------------------------------
 *
 * 								~Vertex stuff~
 *
 *------------------------------------------------------------------------------
 *==============================================================================
 */
#ifdef _VERTEX_SHADER_

out vec3 suncolor;

#ifndef UOS
uniform sampler2D colortex0;

out vec3 ambient[6];
#endif

#include "/libs/Utilities/noise.glsl"

//#include "/libs/atmosphere.glsl"

#define SUN_COLOR_TEMPERATURE_DEBUG 0 //[0 500 750 1000 1250 1500 1750 2000 2250 2500 2750 3000 3250 3500 3750 4000 4250 4500 4750 5000 5250 5500 5750 6000 6250 6500 6750 7000 7250 7500 7750 8000 8250 8500 8750 9000 10000 15000 20000 30000 40000]

#define SUN_LIGHT_COLOR 0 	//[0 1 2 3]
//0 Orginal || 1 New || 2 Cold || 3 Costom

#define MORNING_LIGHT 3.1 	//[2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define NOON_LIGHT 3.7		//[3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0 4.1 4.2 4.3 4.4 4.5 4.6 4.7 4.8 4.9 5.0]
#define EVENING_LIGHT 3.2	//[2.5 2.6 2.7 2.8 2.9 3.0 3.1 3.2 3.3 3.4 3.5 3.6 3.7 3.8 3.9 4.0]
#define NIGHT_LIGHT 0.15 	//[0.0001 0.01 0.05 0.1 0.15 0.2 0.25 0.3 0.35 0.4 0.45 0.5 0.55 0.6 0.65 0.7 0.75 0.8]

#define BASIC_SUN_COLOR_TEMPERATURE 5500.0 		//[4000.0 4500.0 5000.0 5500.0 6000.0 6500.0 7000.0]
#define MORNING_COLOR_TEMPERATURE 2000.0 		//[1000.0 1250.0 1500.0 1750.0 2000.0 2250.0 2500.0 2750.0 3000.0 3250.0 3500.0]
#define NOON_COLOR_TEMPERATURE 6500.0 			//[5000.0 5250.0 5500.0 5750.0 6000.0 6250.0 6500.0 6750.0 7000.0 7500.0]
#define EVENING_COLOR_TEMPERATURE 1500.0 		//[1000.0 1250.0 1500.0 1750.0 2000.0 2250.0 2500.0 2750.0 3000.0 3250.0 3500.0]
#define BASIC_MOON_COLOR_TEMPERATURE 6250.0 	//[3000.0 3250.0 3500.0 3750.0 4000.0 4250.0 4500.0 4750.0 5000.0 5250.0 5500.0 5750.0 6000.0 6250.0 6500.0 6750.0 7000.0 7250.0 7500.0 7750.0 8000.0 8250.0 8500.0 8750.0 9000.0 10000.0 12000.0 15000.0 20000.0 30000.0 40000.0]
#define MIDNIGHT_COLOR_TEMPERATURE 7750.0 		//[6000.0 6250.0 6500.0 6750.0 7000.0 7250.0 7500.0 7750.0 8000.0 8250.0 8500.0 8750.0 9000.0 10000.0 12000.0 15000.0 20000.0 30000.0 40000.0]
#define CLOUDY_COLOR_TEMPERATURE 7500.0 		//[6000.0 6250.0 6500.0 6750.0 7000.0 7250.0 7500.0 7750.0 8000.0]

float getSunColorTemperature(in vec4 time) {
	#if SUN_LIGHT_COLOR == 0
    float base = 5500.0;
	float i1 = 3500.0;
	float i2 = 750.0;
	float i3 = 3750.0;
	float i4 = 2000.0;
	float i5 = 1000.0;
	float i6 = 1500.0;
	#elif SUN_LIGHT_COLOR == 1
	float base = 4000.0;
	float i1 = 2250.0;
	float i2 = 1500.0;
	float i3 = 1000.0;
	float i4 = 1500.0;
	float i5 = 1000.0;
	float i6 = 1500.0;
	#elif SUN_LIGHT_COLOR == 2
	float base = 6000.0;
	float i1 = 3250.0;
	float i2 = 14250.0;
	float i3 = 3250.0;
	float i4 = 2500.0;
	float i5 = 1250.0;
	float i6 = 2250.0;
	#elif SUN_LIGHT_COLOR == 3
	float base 	= 	BASIC_SUN_COLOR_TEMPERATURE;
	float i1 	= 	BASIC_SUN_COLOR_TEMPERATURE 	- MORNING_COLOR_TEMPERATURE;
	float i2 	= 	NOON_COLOR_TEMPERATURE 			- BASIC_SUN_COLOR_TEMPERATURE;
	float i3 	= 	BASIC_SUN_COLOR_TEMPERATURE 	- EVENING_COLOR_TEMPERATURE;
	float i4 	= 	BASIC_MOON_COLOR_TEMPERATURE 	- BASIC_SUN_COLOR_TEMPERATURE;
	float i5 	= 	CLOUDY_COLOR_TEMPERATURE 		- BASIC_SUN_COLOR_TEMPERATURE;
	float i6 	= 	MIDNIGHT_COLOR_TEMPERATURE 		- BASIC_MOON_COLOR_TEMPERATURE;
	#endif

	float timeNoon = step(1.0, time.y);
	float timeNight = step(1.0, time.w);
	
	float ColorTemperature = (base + mix(((1.0 - cos(PI / 4000.0 * (float(worldTime) - 2000.0))) / 2.0 * i2 * timeNoon - i1 * time.x - i3 * time.z), (i4 + (1.0 - cos(PI / 5125.0 * (float(worldTime) - 12750.0))) / 2.0 * i6), timeNight) + i5 * rain0);
	
	return ColorTemperature;
}

void atmosphereCommons() {
	#if SUN_COLOR_TEMPERATURE_DEBUG == 0
	float colorTemperature = getSunColorTemperature(SunTime0);
	#else
	float colorTemperature = float(SUN_COLOR_TEMPERATURE_DEBUG);
	#endif
	
	float f = pow(max(abs(shaderLightVector.y), 0.0), 1.5);
	suncolor = getLightColor(colorTemperature);
    suncolor *= max((1.0 - cloud_coverage * 1.2 - rain0 * 0.4), 0.0) * dot(SunTime0, vec4(MORNING_LIGHT, NOON_LIGHT, EVENING_LIGHT, NIGHT_LIGHT));
	
	#ifndef UOS
	vec3 worldLightPosition = sunVector;

	ambient[0] = texture(colortex0, vec2(0.5, 0.49999)).rgb;
	ambient[1] = texture(colortex0, vec2(0.0, 0.06586)).rgb;
	ambient[2] = texture(colortex0, vec2(0.5, 0.06586)).rgb;
	ambient[3] = texture(colortex0, vec2(0.25,0.06586)).rgb;
	ambient[4] = texture(colortex0, vec2(0.75,0.06586)).rgb;
	ambient[5] = vec3(0.0);
	for (int i = 0; i < 5; ++i) {
		ambient[5] += ambient[i];
	}
	ambient[5] *= 0.2;
	#endif
}

#else

/*
 *==============================================================================
 *------------------------------------------------------------------------------
 *
 * 								~Fragment stuff~
 *
 *------------------------------------------------------------------------------
 *==============================================================================
 */

in vec3 suncolor;

#ifndef UOS
in vec3 ambient[6];
#endif

#endif
#endif 