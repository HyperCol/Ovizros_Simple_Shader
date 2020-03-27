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

#define NORMALS
//#define EYE_3D

#ifdef _VERTEX_SHADER_

/*
 *==============================================================================
 *------------------------------------------------------------------------------
 *
 * 								~Vertex stuff~
 *
 *------------------------------------------------------------------------------
 *==============================================================================
 */

#define attribute in

#ifdef UN
vec2 normalEncode(vec3 n) {return sqrt(-n.z*0.125+0.125) * normalize(n.xy) + 0.5;}
attribute vec4 at_tangent;
#endif

out VS_Material { 
	flat vec4 vColor;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	
	#if (defined UT || defined UN || defined US)
	vec2 texcoord;
	#endif
	#ifdef UL
	vec2 lmcoord;
	#endif
	#ifdef UF
	float flag;
	#endif
	
	#ifdef UN
	vec3 normal;
	vec2 n2;
		#ifdef NORMALS
		vec3 tangent;
		vec3 binormal;
		#endif
	#endif
} vs_out;

#ifdef UF
attribute vec3 mc_Entity;

#define blockID mc_Entity.x
#endif

#ifndef UOS
void main() {
	vs_out.wpos = gl_Vertex;
	vs_out.vpos = gl_ModelViewMatrix * vs_out.wpos;
	vs_out.NDC = gl_ProjectionMatrix * vs_out.vpos;
	gl_Position = vs_out.NDC;
#else
void gbufferCommons() {
#endif
	vs_out.vColor = gl_Color;
	#if (defined UT || defined UN || defined US)
	vs_out.texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).st;
	#endif
	#ifdef UL
	vs_out.lmcoord = (gl_TextureMatrix[1] *  gl_MultiTexCoord1).xy;
	#endif
	
	#ifdef UN
	vs_out.normal = gl_NormalMatrix * gl_Normal;
		#ifdef NORMALS
		vs_out.tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
		vs_out.binormal = cross(vs_out.normal, vs_out.tangent);
		#endif
	vs_out.n2 = normalEncode(vs_out.normal);
	#endif
}

#elif defined _GEOMETRY_SHADER_

/*
 *==============================================================================
 *------------------------------------------------------------------------------
 *
 * 								~Grometry stuff~
 *
 *------------------------------------------------------------------------------
 *==============================================================================
 */

#ifdef EYE_3D
#define EYE_3D_VIEW_WIDE 0.5 //[0.3 0.35 0.4 0.42 0.45 0.47 0.48 0.49 0.498 0.5 0.55 0.6 0.65 0.7 0.75 0.8 0.85 0.9 0.95 1.0]
#define SEPARATE_VIEWPORT_INDEX 0.0 //[0.0 0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0]
#define HALF_PUPIL_DISTANCE 0.1 //[0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.1 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.2 0.22 0.25 0.27 0.3 0.35 0.4 0.45 0.5]
#define VIEWPORT_SCALE 1.0 //[0.5 0.6 0.7 0.8 0.85 0.9 0.92 0.95 0.97 0.99 1.0]

layout (triangles, invocations = 2) in;
#else
layout (triangles, invocations = 1) in;
#endif
layout (triangle_strip, max_vertices = 3) out;

in VS_Material {
	flat vec4 vColor;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	
	#if (defined UT || defined UN || defined US)
	vec2 texcoord;
	#endif
	#ifdef UL
	vec2 lmcoord;
	#endif
	#ifdef UF
	float flag;
	#endif
	
	#ifdef UN
	vec3 normal;
	vec2 n2;
		#ifdef NORMALS
		vec3 tangent;
		vec3 binormal;
		#endif
	#endif
} gs_in[];

out GS_Material {
	flat int t;
	flat vec4 vColor;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	
	#if (defined UT || defined UN || defined US)
	vec2 texcoord;
	#endif
	#ifdef UL
	vec2 lmcoord;
	#endif
	#ifdef UF
	float flag;
	#endif
	
	#ifdef UN
	vec3 normal;
	vec2 n2;
		#ifdef NORMALS
		vec3 tangent;
		vec3 binormal;
		#endif
	#endif
} gs_out;

void gsCommons(int n) {
	gs_out.vColor = gs_in[n].vColor;
	
	gs_out.wpos = gs_in[n].wpos;
	gs_out.vpos = gs_in[n].vpos;
	gs_out.NDC = gs_in[n].NDC;
	//gs_out.NDC /= gs_out.NDC.w;
	
	#if (defined UT || defined UN || defined US)
	gs_out.texcoord = gs_in[n].texcoord;
	#endif
	#ifdef UL
	gs_out.lmcoord = gs_in[n].lmcoord;
	#endif
	#ifdef UF
	gs_out.flag = gs_in[n].flag;
	#endif
	#ifdef UN
	gs_out.normal = gs_in[n].normal;
		#ifdef NORMALS
		gs_out.tangent = gs_in[n].tangent;
		gs_out.binormal = gs_in[n].binormal;
		#endif
	gs_out.n2 = gs_in[n].n2;
	#endif
}

uniform mat4 gbufferProjection;

void main() {
	gs_out.t = gl_InvocationID;
	
	#ifdef EYE_3D
	int i = sign(gs_out.t * 2 - 1);
	const float s0 = EYE_3D_VIEW_WIDE * VIEWPORT_SCALE;
	const float s = mix(s0 , max(s0, 0.5), SEPARATE_VIEWPORT_INDEX);
	#endif
	
	for (int n = 0; n < gl_in.length(); ++n) {
		gsCommons(n);
		#ifdef EYE_3D
			gs_out.vpos.x += i * HALF_PUPIL_DISTANCE;
			gs_out.NDC = gbufferProjection * gs_out.vpos;
			gl_Position = gs_out.NDC;
			gl_Position.xy *= VIEWPORT_SCALE;
			gl_Position.x -= i * s * gl_Position.w;
		#else
			gl_Position = gl_in[n].gl_Position;
		#endif
		
		EmitVertex();
	}
	#ifdef UOS
	gsh();
	#endif
	EndPrimitive();
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

#ifdef UT
uniform sampler2D texture;
#endif

#if defined NORMALS && defined UN
uniform sampler2D normals;
vec2 normalEncode(vec3 n) {return sqrt(-n.z*0.125+0.125) * normalize(n.xy) + 0.5;}
#endif

#ifdef US
//#define SPECULAR_TO_PBR_CONVERSION
//#define CONTINUUM2_TEXTURE_FORMAT

uniform sampler2D specular;
#endif

#define EYE_3D_VIEW_WIDE 0.5 //[0.3 0.35 0.4 0.42 0.45 0.47 0.48 0.49 0.498 0.5]

#ifdef NUGSH
in VS_Material {
#else
in GS_Material {
	flat int t;
#endif
	flat vec4 vColor;
	
	vec4 wpos;
	vec4 vpos;
	vec4 NDC;
	
	#if (defined UT || defined UN || defined US)
	vec2 texcoord;
	#endif
	#ifdef UL
	vec2 lmcoord;
	#endif
	#ifdef UF
	float flag;
	#endif
	
	#ifdef UN
	vec3 normal;
	vec2 n2;
		#ifdef NORMALS
		vec3 tangent;
		vec3 binormal;
		#endif
	#endif
} fs_in;

#include "/libs/Program/outTex.inc"

#ifndef UOS
void main() {
#else
void gbufferCommons() {
#endif
	#ifdef EYE_3D
	vec3 ndc = fs_in.NDC.xyz / fs_in.NDC.w;
	if (ndc.xy != clamp(ndc.xy, -vec2(EYE_3D_VIEW_WIDE, 1.0), vec2(EYE_3D_VIEW_WIDE, 1.0))) discard;
	#endif
	
	#ifdef UT
	Color0 = texture2D(texture, fs_in.texcoord.st) * fs_in.vColor;
	#else
	Color0 = fs_in.vColor;
	#endif
	
	/*#ifndef NUAT
	if (Color0.a < 0.8) discard;
	#endif*/
	
	#ifdef UF
	float flag = fs_in.flag;
	#endif
	
	#ifdef UL
	Color1 = vec4(fs_in.lmcoord, flag, 1.0f);
	#else
	Color1 = vec4(0.0, 0.0, flag, 1.0f);
	#endif
	
	#ifdef US
	vec4 sp;
		#ifdef SPECULAR_TO_PBR_CONVERSION
			vec3 spec = texture2D(specular, fs_in.texcoord).rgb;
			float spec_strength = dot(spec, mix(vec3(0.4, 0.4, 0.2), vec3(0.3, 0.6, 0.1), wetness));
			sp = vec4(spec_strength, spec_strength, 0.0, 1.0);
		#else
			#ifdef CONTINUUM2_TEXTURE_FORMAT
			sp = texture2D(specular, fs_in.texcoord).brga;
			#else
			sp = texture2D(specular, fs_in.texcoord);
			#endif
		#endif
	Color2 = sp;
	#endif
	
	#ifdef UN
		#ifdef NORMALS
		vec3 normal2 = texture2D(normals, fs_in.texcoord).xyz * 2.0 - 1.0;
		const float bumpmult = 0.5;
		normal2 = normal2 * bumpmult + vec3(0.0f, 0.0f, 1.0f - bumpmult);
		mat3 tbnMatrix = mat3(
			fs_in.tangent.x, fs_in.binormal.x, fs_in.normal.x,
			fs_in.tangent.y, fs_in.binormal.y, fs_in.normal.y,
			fs_in.tangent.z, fs_in.binormal.z, fs_in.normal.z);
		normal2 = normal2 * tbnMatrix;
		vec2 d = normalEncode(normal2);
		if (!(d.x > 0.0 && d.y > 0.0)) d = fs_in.n2;
		Color3 = vec4(d, 0.0, 1.0f);
		#else
		Color3 = vec4(fs_in.n2, 0.0, 1.0f);
		#endif
	#endif
}
#endif
