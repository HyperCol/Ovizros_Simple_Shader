#version 430 compatibility
#pragma optimize(on)

/* DRAWBUFFERS:31 */
const float flag = 0.0;
#define UT
#define UOS
#define OUT_TEX 1
#include "/libs/Program/gbuffers.inc"

void main() {
	gbufferCommons();
	Color0 *= smoothstep(0.0, 0.2, fs_in.wpos.y);
}