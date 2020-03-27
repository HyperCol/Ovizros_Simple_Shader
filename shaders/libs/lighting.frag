#ifndef _INCLUDE_LIGHT_
#define _INCLUDE_LIGHT_

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

//==============================================================================
// Shadow stuff
//==============================================================================
 
#define SHADOW_FILTER
#define COLOURED_SHADOW

const vec2 shadowPixSize = vec2(1.0 / shadowMapResolution);

float shadowTexSmooth(in sampler2D s, in vec3 spos, out float depth, in float bias) {
	vec2 uv = spos.xy * vec2(shadowMapResolution) - 1.0;
	vec2 iuv = floor(uv);
	vec2 fuv = uv - iuv;

    float g0x = g0(fuv.x);
    float g1x = g1(fuv.x);
    float h0x = h0(fuv.x) * 0.75;
    float h1x = h1(fuv.x) * 0.75;
    float h0y = h0(fuv.y) * 0.75;
    float h1y = h1(fuv.y) * 0.75;

	vec2 p0 = (vec2(iuv.x + h0x, iuv.y + h0y) + 0.5) * shadowPixSize;
	vec2 p1 = (vec2(iuv.x + h1x, iuv.y + h0y) + 0.5) * shadowPixSize;
	vec2 p2 = (vec2(iuv.x + h0x, iuv.y + h1y) + 0.5) * shadowPixSize;
	vec2 p3 = (vec2(iuv.x + h1x, iuv.y + h1y) + 0.5) * shadowPixSize;

	depth = 0.0;
	float texel = texture2D(s, p0).x; depth += texel;
	float res0 = float(texel + bias < spos.z);

	texel = texture2D(s, p1).x; depth += texel;
	float res1 = float(texel + bias < spos.z);

	texel = texture2D(s, p2).x; depth += texel;
	float res2 = float(texel + bias < spos.z);

	texel = texture2D(s, p3).x; depth += texel;
	float res3 = float(texel + bias < spos.z);
	depth *= 0.25;

    return g0(fuv.y) * (g0x * res0  +
                        g1x * res1) +
           g1(fuv.y) * (g0x * res2  +
                        g1x * res3);
}

float light_fetch_shadow(in sampler2D colormap, vec3 spos, inout vec3 suncolor, float pix_bias) 
{
	float shadow = 0.0;
	if (spos != clamp(spos, vec3(0.0), vec3(1.0))) return shadow;
	
	const float bias_pix = 0.002;
	vec2 bias_offcenter = abs((spos.xy - vec2(0.25)) * 4.0);
	float bias = pow2(max(bias_offcenter.x, bias_offcenter.y)) * bias_pix + shadowPixSize.x * pix_bias;
	
	#ifdef SHADOW_FILTER
		// PCSS - step 1 - find blockers
		float dither = bayer_64x64(texcoord, vec2(viewWidth, viewHeight));
		
		vec2 range = vec2(0.25 / shadowDistance);
		vec2 average_depth = vec2(0.0);
		for (int i = 0; i < 4; i++) {
			dither = fract(dither + 0.618);
			vec2 uv = spos.xy + poisson_4[i] * dither * range.s;
			float depth = texture2D(shadowtex1, uv).x;
			#ifdef COLOURED_SHADOW
			float wdepth = texture2D(shadowtex0, uv).x;
			average_depth += vec2(depth, wdepth);
			#else
			average_depth.x += depth;
			#endif
		}
		average_depth *= 0.25;
		vec2 dis = spos.zz - average_depth;
		
		// PCSS - step 2 - filter
		float shadow_depth = 0.0;
		vec3 color_shadow = vec3(0.0);
		if (dis.x - bias > 0 || dis.y - bias > 0) {
			range *= 2.0 * (spos.zz - average_depth + 1.0);
			
			vec4 uv;
			for (int i = 0; i < 4; i++) {
				dither = fract(dither + 0.618);
				uv.st = spos.xy + range.s * poisson_4[i] * dither;
				uv.pq = spos.xy + range.t * poisson_4[i] * dither;

				vec4 depth = textureGather(shadowtex1, uv.st);
				shadow_depth += sum4(depth);
				color_shadow += texture2D(colormap, uv.pq + vec2(0.5, 0.0)).rgb;
				
				vec4 s1 = step(0.0, spos.zzzz - depth - vec4(bias));
				shadow += sum4(s1);
			}
			//const float i = 1.0 / 16.0;
			shadow_depth *= 0.0625; shadow *= 0.0625; color_shadow *= 0.25;
			//shadow *= 1.0 - dis.x;
			#ifdef SHADOW_COLOR
			suncolor *= color_shadow;
			#endif
		} else {
			return 0.0;
		}
	#else
		//spos.xy -= 0.5;
		float M1;
		shadow = shadowTexSmooth(shadowtex1, spos, M1, bias);
		#ifdef SHADOW_COLOR
		float M2;
		float shadow0 = shadowTexSmooth(watershadowmap, spos, M2, bias);
		if (M2 + bias < M1) suncolor = mix(suncolor, texture2D(shadowcolor0, spos.xy) * luma(suncolor) * 0.7, wshadow0);
		#endif
	#endif
	
	return shadow;
}

//==============================================================================
// Light stuff
//==============================================================================

float DistributionGGX(vec3 N, vec3 H, float roughness)
{
    float a      = roughness*roughness;
    float a2     = a*a;
    float NdotH  = max(dot(N, H), 0.0);
    float NdotH2 = NdotH*NdotH;
	
    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
	
    return num / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = (r*r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
	
    return num / denom;
}

float GeometrySmith(vec3 N, vec3 V, vec3 L, float roughness)
{
    float NdotV = max(dot(N, V), 0.0);
    float NdotL = max(dot(N, L), 0.0);
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);
	
    return ggx1 * ggx2;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

#endif 