#ifndef _INCLUDE_EFFECT_
#define _INCLUDE_EFFECT_

#define EXPOSURE 1.2 // [0.1 0.2 0.3 0.4 0.5 0.6 0.7 0.8 0.9 1.0 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 2.0]

float get_exposure() {
	return EXPOSURE * (1.8 - clamp(pow(eyeBrightnessSmooth.y / 240.0, 6.0) * luma(suncolor), 0.0, 1.2));
}
#endif 