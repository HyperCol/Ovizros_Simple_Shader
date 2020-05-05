#ifndef _INCLUDE_VOXEL_
#define _INCLUDE_VOXEL_

const float shadowMapPixel = 1.0 / shadowMapResolution;
const float vRange = floor(pow(shadowMapResolution, 2.0 / 3.0) * 0.25);

dvec2 toVoxelSpase(in vec3 wpos) {
	//discard useless surface
	//valid = (fract(wpos) < vec3(0.05));
	//wpos = round(wpos);
	
	const double mapsize = double(4.0 * vRange / shadowMapResolution);
	wpos.y += vRange;
	dvec2 uv = dvec2(wpos.xz) + dvec2(vRange * wpos.y * 2.0, 0.0);
	uv *= 2.0 * shadowMapPixel;
	
	return uv;
}

/* dvec3 voxelSpace
 *
 */
#endif 