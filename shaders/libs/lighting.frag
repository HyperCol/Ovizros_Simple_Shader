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

#define SHADOW_DISTANCE_EFFECTIVE 15

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
	float texel = texture(s, p0).x; depth += texel;
	float res0 = float(texel + bias < spos.z);

	texel = texture(s, p1).x; depth += texel;
	float res1 = float(texel + bias < spos.z);

	texel = texture(s, p2).x; depth += texel;
	float res2 = float(texel + bias < spos.z);

	texel = texture(s, p3).x; depth += texel;
	float res3 = float(texel + bias < spos.z);
	depth *= 0.25;

    return g0(fuv.y) * (g0x * res0  +
                        g1x * res1) +
           g1(fuv.y) * (g0x * res2  +
                        g1x * res3);
}

vec3 BlendColoredShadow(float shadow0, float shadow1, vec4 shadowC) {
		// Best looking method I've found so far.
		return (shadowC.rgb * shadowC.a - shadowC.a * 0.5) * (-shadow1 * shadow0 + shadow1) + shadow1;
}

//#error shadow
float light_fetch_shadow(in sampler2D colormap, vec3 spos, inout vec3 suncolor, float pix_bias, float l) 
{
	float shadow = 0.0;
	if (spos != clamp(spos, vec3(0.0), vec3(0.5, 0.5, 1.0))) return 0.0;
	
	const float bias_pix = 0.002;
	vec2 bias_offcenter = abs((spos.xy - vec2(0.25)) * 4.0);
	float bias = pow2(max(bias_offcenter.x, bias_offcenter.y)) * bias_pix + shadowPixSize.x * (pix_bias + pow2(l) * 16);
	
	#ifdef SHADOW_FILTER
		// PCSS - step 1 - find blockers
		float dither = bayer_64x64(texcoord, vec2(viewWidth, viewHeight));
		
		float range = 0.25 / shadowDistance;
		vec2 average_blocker = vec2(0.0), count = vec2(0.0);
		for (int i = 0; i < 4; i++) {
			dither = fract(dither + 0.618);
			vec2 uv = spos.xy + poisson_4[i] * dither * range;
			
			float depth0 = textureLod(shadowtex1, uv, 0.0).x;
			float depth1 = textureLod(shadowtex0, uv + vec2(0.5, 0.0), 0.0).x;

			float w0 = step(0.0, spos.z - depth0 - (bias * 2));
			float w1 = step(0.0, spos.z - depth1 - (bias));
			average_blocker += vec2(w0 * depth0, w1 * depth1);
			count += vec2(w0, w1);
		}
		average_blocker /= count;
		float dis = spos.z - average_blocker.x + bias;
		
		// PCSS - step 2 - filter
		//vec3 color_shadow = vec3(0.0);
		if ((average_blocker.x + bias > 0 || average_blocker.y + bias > 0) && count != 0) {
			range *= 32.0 * dis + 0.2;
			
			for (int i = 0; i < 4; i++) {
				dither = fract(dither + 0.618);
				vec2 uv = spos.xy + range * poisson_4[i] * dither;

				vec4 depth = textureGather(shadowtex1, uv.st);
				//float wdepth1 = texture(shadowtex0, uv.st + vec2(0.5, 0.0)).x;
				
				//color_shadow += BlendColoredShadow(wdepth1 * 0.5 + 0.5, depth.w * 0.5 + 0.5, texture(colormap, uv.st + vec2(0.5, 0.0)) * 2.0);
				
				vec4 s1 = step(0.0, spos.zzzz - depth - bias);
				shadow += sum4(s1);
			}
			//const float i = 1.0 / 48.0;
			shadow *= 0.0625;// color_shadow *= 0.0625;
			//shadow *= 1.0 - dis.x;
			#ifdef COLOURED_SHADOW
			if (average_blocker.y + bias > 0) {
				vec4 color_shadow = fromGamma(textureLod(colormap, spos.xy + vec2(0.5, 0.0), 1.0));
				//color_shadow.rgb = BlendColoredShadow(average_blocker.y, average_blocker.x, color_shadow);
				suncolor *= mix(color_shadow.rgb * color_shadow.a - color_shadow.a + 0.5, color_shadow.rgb, pix_bias);// + average_blocker.y;
			}
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
		if (M2 + bias < M1) suncolor = mix(suncolor, texture(shadowcolor0, spos.xy + vec2(0.5, 0.0)) * luma(suncolor) * 0.7, shadow0);
		#endif
	#endif
	
	//shadow *= 1.0 - smoothstep(0.6, 0.9, max(bias_offcenter.x, bias_offcenter.y));
	return smoothstep(0.3, 0.8, shadow);//1.0 - pow(1.0 - average_blocker.x, 100.0);//
}

//==============================================================================
// Light stuff
//==============================================================================

void init_lighting(inout Lighting Li, vec3 color, vec3 specular, vec3 sun, float shadow) 
{
	Li.sun = sun;
	Li.ambient = ambient[5];
	Li.attenuation = 1.0 - shadow;
	
	Li.albedo = color;
	Li.metallic = specular.g;
	Li.roughness = 1.0 - specular.r;
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
    float r = (roughness);
    float k = pow2(r) / 4.0;

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

vec3 light_PBR_fresnelSchlickRoughness(float cosTheta, vec3 F0, float roughness) {
	return F0 + (max(vec3(1.0 - roughness), F0) - F0) * pow(1.0 - cosTheta, 5.0);
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
	vec3 H = normalize(L + V);
	
	float NdotV = Positive(dot(mat.normal, V));
	float NdotL = linearstep(0.01, 1.0, dot(mat.normal, L));
	float NdotH = Positive(dot(mat.normal, H));
	float VdotH = Positive(dot(H, V));
	
	vec3 radiance = Li.sun * Li.attenuation;
	
	float NDF = DistributionGGX(NdotH, Li.roughness);        
    float G   = GeometrySmith(NdotV, NdotL, Li.roughness);      
    vec3  F   = light_PBR_fresnelSchlickRoughness(VdotH, F0, Li.roughness);  //fresnelSchlick(VdotH, F0); vec3(0.04);//
        
    vec3 kS = F;
    vec3 kD = max(vec3(0.0), vec3(1.0) - kS);
    kD *= 1.0 - Li.metallic;	  
        
    vec3 numerator    = NDF * G * F;
    float denominator = 4.0 * NdotV * NdotL;
    vec3 specular     = numerator / max(denominator, 0.001);  
            
    // add to outgoing radiance Lo             
    vec3 Lo = ((kD * (Li.albedo) + kS * Li.ambient * 3.0) / PI + specular) * radiance * NdotL;
	
	vec3 ambient = vec3(0.03) * (Li.albedo) * (mat.lmcoord.y * 0.8 + 0.2);
    vec3 color = ambient + Lo;
	
	color = mix(color, Li.albedo * 1.3, Li.emmisive);
	return color;
}
#endif 