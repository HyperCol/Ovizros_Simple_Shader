#version 430 compatibility
#include "/libs/compat.glsl"
#pragma optimize(on)

in vec2 texcoord;

/* DRAWBUFFERS:3 */
#define OUT_TEX 0
#include "/libs/Program/outTex.inc"

#include "/libs/GlslConfig"

uniform sampler2D colortex3;

const int RGB8 = 0, R11F_G11F_B10F = 1, RGB10_A2 = 2, RGBA16F = 3, RGBA8 = 4, RGB16 = 5, RGBA32F = 6,RGBA16 = 7, R11_G11_B10 = 8;

const int colortex0Format = RGBA16F;
const int colortex1Format = RGB8;
const int gnormalFormat = RGBA8;
const int compositeFormat = RGBA16;
const int gaux1Format = RGBA8;
const int gaux2Format = RGBA16F;
const int gaux3Format = RGBA8;
const int gaux4Format = RGBA8;
const int noiseTextureResolution = 512;

const float eyeBrightnessHalflife = 13.5f;
const float wetnessHalflife = 600.0f;
const float drynessHalflife = 1200.0f;
const float centerDepthHalflife = 5.0f;

void main() {
	Color0 = texture(colortex3, texcoord);
}