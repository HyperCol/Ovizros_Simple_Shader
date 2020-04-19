#version 430 compatibility
#pragma optimize(on)

/* DRAWBUFFERS:31 */
const float flag = 0.0;
#define UOS
#define OUT_TEX 1
#include "/libs/Program/gbuffers.inc"

uniform vec4 Time;

void main() {
	gbufferCommons();
	Color0 *= Time.w * smoothstep(0.02, 0.2, fs_in.wpos.y);
}