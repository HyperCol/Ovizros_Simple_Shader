#ifndef _INCLUDE_LIGHT_
#define _INCLUDE_LIGHT_

uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;

struct Lighting {
	vec3 sun;
	vec3 ambient;
	float attenuation;
	
	vec3 albedo;
	float metallic;
	float roughness;
	float emmisive;
	
	vec4 handLight[2];
};

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
	if (spos.xy != clamp(spos.xy, vec2(0.0), vec2(0.5))) return shadow;
	
	const float bias_pix = 0.002;
	vec2 bias_offcenter = abs((spos.xy - vec2(0.25)) * 4.0);
	float bias = max(bias_offcenter.x, bias_offcenter.y) * bias_pix + shadowPixSize.x * pix_bias;
	
	#ifdef SHADOW_FILTER
		// PCSS - step 1 - find blockers
		float dither = bayer_64x64(texcoord, vec2(viewWidth, viewHeight));
		
		vec2 range = vec2(0.1 / shadowDistance);
		vec2 average_block = vec2(0.0);vec2 count = vec2(0.0);
		for (int i = 0; i < 4; i++) {
			dither = fract(dither + 0.618);
			vec2 uv = spos.xy + poisson_4[i] * dither * range.s;
			#ifdef COLOURED_SHADOW
			vec2 depth = vec2(dot(textureGather(shadowtex1, uv), vec4(0.25)), dot(textureGather(shadowtex0, uv + vec2(0.5, 0.0)), vec4(0.25)));
			#else
			vec2 depth = vec2(dot(textureGather(shadowtex1, uv), vec4(0.25)), 0.0);
			#endif
			vec2 dis = spos.zz - depth - 2 * vec2(bias, 0.0);
			average_block += dis;
			
			count += 1.0 - step(dis, vec2(0.0));
		}
		average_block /= count;
		
		// PCSS - step 2 - filter
		float shadow_depth = 0.0;
		vec3 color_shadow = vec3(0.0);
		if (average_block.x + bias > 0 || average_block.y > 0) {
			range *= 32.0 * (average_block) + 0.5;
			
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
			//const float i = 1.0 / 48.0;
			shadow_depth *= 0.0625; shadow *= 0.0625; color_shadow *= 0.25;
			//shadow *= 1.0 - dis.x;
			#ifdef COLOURED_SHADOW
			suncolor *= color_shadow;
			#endif
		} else {
			return 0.0;
		}
		//shadow = 1.0 - shadow;
	#else
		//spos.xy -= 0.5;
		float M1;
		shadow = shadowTexSmooth(shadowtex1, spos, M1, bias);
		#ifdef SHADOW_COLOR
		float M2;
		float shadow0 = shadowTexSmooth(shadowtex1, spos, M2, bias);
		if (M2 + bias < M1) suncolor = mix(suncolor, texture2D(shadowcolor0, spos.xy) * luma(suncolor) * 0.7, wshadow0);
		#endif
	#endif
	
	shadow *= 1.0 - smoothstep(0.8, 0.95, max(bias_offcenter.x, bias_offcenter.y));
	return smoothstep(0.3, 1.0, shadow);
}

//==============================================================================
// Light stuff
//==============================================================================

void init_lighting(inout Lighting Li, vec3 color, vec3 specular, vec3 sun, float shadow) 
{
	Li.sun = sun;
	Li.ambient = ambientD;
	Li.attenuation = 1.01 - shadow;
	
	Li.albedo = color;
	Li.metallic = specular.g;
	Li.roughness = pow2(1.0 - specular.r);
	Li.emmisive = specular.b;
}

float DistributionGGX(float NdotH, float roughness)
{
    float a      = pow2(roughness);
    float a2     = pow2(a);
    float NdotH2 = pow2(NdotH);
	
    float num   = a2;
    float denom = (NdotH2 * (a2 - 1.0) + 1.0);
    denom = PI * denom * denom;
	
    return num / denom;
}

float GeometrySchlickGGX(float NdotV, float roughness)
{
    float r = (roughness + 1.0);
    float k = pow2(r) / 8.0;

    float num   = NdotV;
    float denom = NdotV * (1.0 - k) + k;
	
    return num / denom;
}

float GeometrySmith(float NdotV, float NdotL , float roughness)
{
    float ggx2  = GeometrySchlickGGX(NdotV, roughness);
    float ggx1  = GeometrySchlickGGX(NdotL, roughness);
	
    return ggx1 * ggx2;
}

vec3 fresnelSchlick(float cosTheta, vec3 F0)
{
    return F0 + (1.0 - F0) * pow(1.0 - cosTheta, 5.0);
}

void light_hand_calc_PBR(in Material mat, in Lighting Li, inout vec3 Lo, in vec3 V, in vec3 F0)
{
	for (int i = 0; i < 2; ++i) {
		
	}
}

vec3 light_calc_PBR(in Material mat, in Lighting Li) 
{
	vec3 V = -normalize(mat.vpos);
	
	vec3 F0 = vec3(0.04); 
    F0 = mix(F0, Li.albedo, Li.metallic);
	
	//sun light
	vec3 L = shadowLightVectorView;
	vec3 H = normalize(V + L);
	
	float NdotV = Positive(dot(mat.normal, V));
	float NdotL = Positive(dot(mat.normal, L));
	float NdotH = Positive(dot(mat.normal, H));
	float VdotH = Positive(dot(H, V));
	
	vec3 radiance = Li.sun * Li.attenuation;
	
	float NDF = DistributionGGX(NdotH, Li.roughness);        
    float G   = GeometrySmith(NdotV, NdotL, Li.roughness);      
    vec3  F   = fresnelSchlick(VdotH, F0);   
        
    vec3 kS = F;
    vec3 kD = vec3(1.0) - kS;
    kD *= 1.0 - Li.metallic;	  
        
    vec3 numerator    = NDF * G * F;
    float denominator = 4.0 * NdotV * NdotL;
    vec3 specular     = numerator / max(denominator, 0.001);  
            
    // add to outgoing radiance Lo             
    vec3 Lo = (kD * Li.albedo / PI + specular) * radiance * NdotL;
	
	vec3 ambient = vec3(0.03) * Li.albedo * mat.lmcoord.y;
    vec3 color = ambient + Lo;
	
	return color;
}
#endif 