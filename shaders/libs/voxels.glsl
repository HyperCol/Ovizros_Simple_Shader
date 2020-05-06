#ifndef _INCLUDE_VOXEL_
#define _INCLUDE_VOXEL_

const float shadowMapPixel = 1.0 / shadowMapResolution;
const float vRange = floor(pow(shadowMapResolution * shadowMapResolution * 0.5 , 1.0 / 3.0) * 0.5);



vec2 toVoxelSpace(in vec3 wpos) {
	//discard useless surface
	//valid = (fract(wpos) < vec3(0.05));
	//wpos = round(wpos);
	
	wpos = wpos + vRange;
	
	vec2 uv = wpos.xz + vec2(vRange * wpos.y * 2.0, 0.0);
	float s1, s2;
	uv.y = modf(uv.y, s1);
	uv.x += s1 * 4.0 * vRange * vRange;
	uv *= shadowMapPixel;
	uv.x = modf(uv.x, s2);
	uv.y += s2 * shadowMapPixel;
	//uv = mod(uv, vec2(shadowMapPixel));
	
	return uv * 2.0 + vec2(-1.0, 0.0);
}

/*dvec3 voxelSpace
*/
#endif 