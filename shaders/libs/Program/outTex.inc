#if !(defined _INCLUD_OUTTEX_ || defined _GEOMETRY_SHADER_ || defined _VERTEX_SHADER_)
#define _INCLUD_OUTTEX_

//default output gl_FragData[0]
layout (location = 0) out vec4 Color0;

//enable gl_FragData[1]
#if OUT_TEX > 0
layout (location = 1) out vec4 Color1;
#else
vec4 Color1 = vec4(0.0, 0.0, 0.0, 1.0f);
#endif

//enable gl_FragData[2]
#if OUT_TEX > 1
layout (location = 2) out vec4 Color2;
#else
vec4 Color2 = vec4(0.0, 0.0, 0.0, 1.0f);
#endif

//enable gl_FragData[3]
#if OUT_TEX > 2
layout (location = 3) out vec4 Color3;
#else
vec4 Color3 = vec4(0.0, 0.0, 0.0, 1.0f);
#endif

//enable gl_FragData[4]
#if OUT_TEX > 3
layout (location = 4) out vec4 Color4;
#else
vec4 Color4 = vec4(0.0, 0.0, 0.0, 1.0f);
#endif

//enable gl_FragData[5]
#if OUT_TEX > 4
layout (location = 5) out vec4 Color5;
#else
vec4 Color5 = vec4(0.0, 0.0, 0.0, 1.0f);
#endif 

#endif 