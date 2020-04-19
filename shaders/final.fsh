#version 430 compatibility
#include "/libs/compat.glsl"
#pragma optimize(on)

in vec2 tex;
vec2 texcoord = tex;

out vec4 Color;

#include "/libs/GlslConfig"

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D gnormal;
uniform sampler2D composite;
uniform sampler2D gaux1;
uniform sampler2D gaux2;
uniform sampler2D gaux4;

uniform sampler2D shadowtex0;
uniform sampler2D shadowcolor0;

//#define EYE_3D

#ifdef EYE_3D
	#define FOCUSSING_HELP
	
	#define EYE_3D_VIEW_WIDE 0.5 //[0.3 0.35 0.4 0.42 0.45 0.47 0.48 0.49 0.498 0.5]
	#define SEPARATE_VIEWPORT_INDEX 0.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
	#define VIEWPORT_SCALE 1.0 //[0.5 0.6 0.7 0.8 0.85 0.9 0.92 0.95 0.97 0.99 1.0]
#endif

#include "/libs/utility.glsl"
#include "/libs/Program/atmosphere.inc"
#include "/libs/effect.frag"
#include "/libs/tone.frag"
#include "/libs/animation.glsl"

Tone tone;

void main() {
	init_tone(tone, texcoord);
	Hue_Adjustment(tone);
	Color = vec4(tone.color, 1.0f);
	
	#ifdef EYE_3D
	#ifdef FOCUSSING_HELP
	vec2 fuv = fma(tex, vec2(2.0), vec2(-1.0));
	fuv.x = abs(fuv.x);
	
	const float s = mix(EYE_3D_VIEW_WIDE * VIEWPORT_SCALE, 0.5, SEPARATE_VIEWPORT_INDEX);
	const vec2 p = vec2(s, -0.8 * VIEWPORT_SCALE);
	fuv -= p;
	fuv.x *= aspectRatio;
	Color = mix(vec4(0.75), Color, round(fuv, 0.1 * VIEWPORT_SCALE));
	Color.rgb += 0.4 * (1.0 - round(fuv, 0.08 * VIEWPORT_SCALE));
	#endif
	#endif
	//Color = texture(shadowtex0, tex);
	//Color = texture(gaux1, tex).qqqq;
}