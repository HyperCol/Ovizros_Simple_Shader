#ifndef _INCLUDE_MATERIAL_
#define _INCLUDE_MATERIAL_

struct Mask {
	float flag;
	
	bool block;
	bool particle;
	bool lit_particle;
	bool sky;
	bool hand;
	bool entity;
	bool plant;
	bool trans;
	bool water;
};

struct Material {
	vec3 NDC;
	vec3 vpos;
	vec3 wpos;
	
	vec3 normal;
	vec2 lmcoord;
	
	Mask mask;
};

const float maskFlag[] = float[10](
	1.0,		//0	void
	0.0,		//1	sky
	0.95,		//2	lit_particle
	0.9,		//3	particle
	0.2,		//4	entity
	0.1,		//5	hand
	0.7,		//6	trans
	0.4,		//7 plant
	0.5,		//8 block
	0.65		//9	water
);

uniform sampler2D gnormal;

bool fetch_mask(float flag, const int F) {
	float F0 = maskFlag[F];
	return (flag > (F0 - 0.08) && flag < (F0 + 0.08));
}

void init_mask(inout Mask mask, float flag) {
	mask.flag = flag;
	if (flag > 0.97) discard;
	
	mask.sky 		= 	fetch_mask(flag, 1);
	mask.lit_particle = fetch_mask(flag, 2);
	mask.particle 	= 	fetch_mask(flag, 3) || mask.lit_particle;
	mask.entity 	= 	fetch_mask(flag, 4);
	mask.hand 		= 	fetch_mask(flag, 5);
	mask.trans 		= 	fetch_mask(flag, 6);
	mask.plant 		= 	fetch_mask(flag, 7);
	mask.block 		= 	fetch_mask(flag, 8) || mask.plant;
	
	mask.water = (flag > 0.53 && flag < 0.67);
}

vec3 normalDecode(vec2 enc) {
	vec4 nn = vec4(2.0 * enc - 1.0, 1.0, -1.0);
	float l = dot(nn.xyz,-nn.xyw);
	nn.z = l;
	nn.xy *= sqrt(l);
	return nn.xyz * 2.0 + vec3(0.0, 0.0, -1.0);
}

vec2 normalEncode(vec3 n) {
	vec2 enc = normalize(n.xy) * (sqrt(-n.z*0.5+0.5));
	enc = enc*0.5+0.5;
	return enc;
}

void init_Material(inout Material m, vec2 texcoord, float flag) {
	vec4 nlm = texture(gnormal, texcoord);
	m.normal = normalDecode(nlm.xy);
	m.lmcoord = nlm.pq;
	
	m.NDC.xy = texcoord;
	m.NDC.z = texture(depthtex0, texcoord).x;
	m.vpos = fetch_vpos(m.NDC).xyz;
	m.wpos = fetch_wpos(m.vpos);
	
	init_mask(m.mask, flag);
}

#endif 