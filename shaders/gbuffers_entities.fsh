#version 430 compatibility
#pragma optimize(on)

/* DRAWBUFFERS:3142 */
const float flag = 0.2;
#define UT
#define UL
#define US
#define UN
#define UOS
#define OUT_TEX 3
#include "/libs/Program/gbuffers.inc"

uniform vec4 entityColor;

void main() {
	gbufferCommons();
	Color0 = Color0 + entityColor * Color0.a * vec4(fs_in.vColor.rgb, 1.0);
}