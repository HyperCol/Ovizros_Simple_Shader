#if !(defined _INCLUDE_ANIMATION)
#define _INCLUDE_ANIMATION

/* 
 * Copyright 2019 Ovizro
 *
 * This is the first shader effect made by myself.
 * It includes a quantity of animation.
 * Some of them might seem to be a little crazy.
 * Wish you can enjoy it.
 */

uniform float aspectRatio;
uniform bool hideGUI;

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

vec2 fuv_build(in vec2 uv) {                //Establish coordinate system with screen as center
    vec2 fuv = uv * 2.0 - 1.0;
    fuv.x *= aspectRatio;
    return fuv;
}

/*
 *==============================================================================
 *[																				]
 *[		----------------		Simple Animation		----------------		]
 *[																				]
 *==============================================================================
 */

mat2 mRotate(float theter) {
	float s = sin(theter);
	float c = cos(theter);
	return mat2(c, -s,
				s,  c);
}

void rotate(inout vec2 uv, in float theter) {
	uv = mRotate(theter) * uv;
}

float lozenge(in vec2 puv, float edge) {
	float e0 = puv.x + puv.y;
	return smoothstep(edge - 0.01, edge + 0.01, e0);
}

float round(in vec2 puv, float r) {
	float e0 = dot(puv, puv);
	r *= r;
	return smoothstep(r - 0.01, r + 0.01, e0);
}

float triangle(in vec2 puv, float aa) {					//Build an equilateral triangle
	float e1 = 0.57735 * (1.0 - puv.x) - abs(puv.y);
	float e2 = puv.x + 1.0; 
	aa *= 0.2;
	return min(smoothstep(0.0, 0.05 * aa, e1), smoothstep(0.0, 0.0443 * aa, e2));
}

float triangle(in vec2 puv) {
	return triangle(puv, 5.0);
}

float func3(in float x, float m, float mY) {
	float a = mY / pow3(m);
	float b = -a * m * 3.0;
	float c = -b * m;
	return fma(x, fma(x, a, b), c) * x;
}
#endif
#endif 
