#ifndef _INCLUDE_VECTOR_
#define _INCLUDE_VECTOR_

//#define EYE_3D

#ifdef EYE_3D
	#define EYE_3D_VIEW_WIDE 0.5 //[0.3 0.35 0.4 0.42 0.45 0.47 0.48 0.49 0.498 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
	#define SEPARATE_VIEWPORT_INDEX 0.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
	#define HALF_PUPIL_DISTANCE 0.1 //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.22 0.25 0.27 0.3 0.35 0.4 0.45 0.5]
	#define VIEWPORT_SCALE 1.0 //[0.5 0.6 0.7 0.8 0.85 0.9 0.92 0.95 0.97 0.99 1.0]
	
	const float s0 = EYE_3D_VIEW_WIDE * VIEWPORT_SCALE;
	const float s = mix(s0 , max(s0, 0.5), SEPARATE_VIEWPORT_INDEX);
#endif

uniform float fov;
uniform float mulfov;

vec4 fetch_vpos(vec3 spos) {
	spos = fma(spos, vec3(2.0f), vec3(-1.0));
	#ifdef EYE_3D
	float i = sign(spos.x);
	spos.x -= s * i;
	spos.xy /= VIEWPORT_SCALE;
	#endif
	
	vec4 v = gbufferProjectionInverse * vec4(spos, 1.0);
	v /= v.w;
	v.xy *= mulfov;
	#ifdef EYE_3D
	v.x += HALF_PUPIL_DISTANCE * i;
	#endif
	return v;
}

vec4 fetch_vpos(vec2 uv, float z) {
	return fetch_vpos(vec3(uv, z));
}

vec4 fetch_vpos(vec2 uv, sampler2D sam) {
	return fetch_vpos(uv, texture(sam, uv).x);
}

vec3 fetch_wpos(vec3 vpos) {
	vec3 wpos = mat3(gbufferModelViewInverse) * vpos;
	return wpos + gbufferModelViewInverse[3].xyz;
}

vec3 fetch_wpos(vec4 vpos) {
	return fetch_wpos(vpos.xyz);
}

float linearizeDepth(float depth) { return (2.0 * near) / (far + near - depth * (far - near));}

float getLinearDepthOfViewCoord(vec3 viewCoord) {
	vec4 p = vec4(viewCoord, 1.0);
	p = gbufferProjection * p;
	p /= p.w;
	return linearizeDepth(fma(p.z, 0.5f, 0.5f));
}

float distanceSquared(vec3 a, vec3 b) {
	a -= b;
	return distance2(a);
}

vec2 screen_project (vec3 vpos) {
	vec4 p = mat4(gbufferProjection) * vec4(vpos, 1.0f);
	p /= p.w;
	if(abs(p.z) > 1.0)
		return vec2(-1.0);
	return fma(p.st, vec2(0.5f), vec2(0.5f));
}

vec3 screen_project_depth (vec3 vpos) {
	vec4 p = mat4(gbufferProjection) * vec4(vpos, 1.0f);
	p /= p.w;
	if(abs(p.z) > 1.0)
		return vec3(-1.0);
	return fma(p.xyz, vec3(0.5f), vec3(0.5f));
}

//==============================================================================
// Shadow Stuff
//==============================================================================

#ifndef _VERTEX_SHADER_
/*vec3 shadowpos_transform(in vec3 wpos) {
	vec4 shadowposition = shadowModelView * vec4(wpos, 1.0f);
	shadowposition = shadowProjection * shadowposition;
	shadowposition /= shadowposition.w;

	return shadowposition.xyz;
}

float logistics(float x) {
	return pow(2.0 / (1.0 + exp(-3.0*x)) - 1.0, 0.7);
}

vec3 shadowpos_distort(in vec3 shadowposition) {
	float distb = length(shadowposition.xy);
	shadowposition.xy /= distb;
	shadowposition.xy *= logistics(distb);

	shadowposition.z = shadowposition.z * 0.5 + 0.25;

	return shadowposition.xyz * 0.5f + 0.5f;
}*/

vec3 wpos2shadowpos(in vec3 wpos, out float l) {
	vec4 shadowposition = shadowModelView * vec4(wpos, 1.0f);
	shadowposition = shadowProjection * shadowposition;
	shadowposition /= shadowposition.w;

	float distb = length(shadowposition.xy);
	l = distb;
	float distortFactor = negShadowBias + distb * SHADOW_MAP_BIAS;
	shadowposition.xy /= distortFactor;

	shadowposition.xyz = shadowposition.xyz * 0.5f + 0.5f;
	//vec3 spos = shadowpos_distort(shadowpos_transform(wpos));
	//shadowposition.z -= 0.00008;
	shadowposition.xy *= 0.5;
	return shadowposition.xyz;
}

vec3 wpos2shadowpos(in vec3 wpos) {
	float l;
	return wpos2shadowpos(wpos, l);
}

vec3 wpos2shadowpos(in vec3 wpos, const bool transparent) {
	vec3 spos = wpos2shadowpos(wpos);
	if (transparent) spos.x += 0.5;
	return spos;
}
#endif

//==============================================================================
// Sky Stuff
//==============================================================================

vec3 project_uv2skybox(vec2 uv) {
	vec2 rad = uv * 2.0 * PI;
    rad.y -= PI * 0.5;
    return normalize(vec3(cos(rad.x) * cos(rad.y), sin(rad.y), sin(rad.x) * cos(rad.y)));
}

vec2 project_skybox2uv(vec3 nwpos) {
	vec2 rad = vec2(atan(nwpos.z, nwpos.x), asin(nwpos.y));
	rad += vec2(step(0.0, -rad.x) * (PI * 2.0), PI * 0.5);
	rad *= 0.5 / PI;
	return rad;
}
#endif 