#if !(defined _INCLUDE_COMPAT)
#define _INCLUDE_COMPAT

#extension GL_ARB_shader_texture_lod : require

// GPU Shader 4
#ifdef MC_GL_EXT_gpu_shader4

#extension GL_EXT_gpu_shader4 : require
#define HIGH_LEVEL_SHADER

#endif

// GPU Shader 5
#ifdef MC_GL_ARB_gpu_shader5
#extension GL_ARB_gpu_shader5 : require
#else
#define fma(a,b,c) ((a)*(b)+c)
#endif

// Texture gather
#ifdef MC_GL_ARB_texture_gather
#extension GL_ARB_texture_gather : require
#else

#ifndef VIEW_WIDTH
#define VIEW_WIDTH
uniform float viewWidth;                        // viewWidth
uniform float viewHeight;                       // viewHeight
uniform vec2 pixel;
#endif

vec4 textureGather(sampler2D sampler, vec2 coord) {
  vec2 c = coord * vec2(viewWidth, viewHeight);
  c = round(c) * pixel;
  return vec4(
    texture(sampler, c + vec2(.0,pixel.y)     ).r,
    texture(sampler, c + vec2(pixel.x,pixel.y)).r,
    texture(sampler, c + vec2(.0,pixel.y)     ).r,
    texture(sampler, c                        ).r
  );
}

vec4 textureGatherOffset(sampler2D sampler, vec2 coord, ivec2 offset) {
  vec2 c = coord * vec2(viewWidth, viewHeight);
  c = (round(c) + vec2(offset)) * pixel;
  return vec4(
    texture(sampler, c + vec2(.0,pixel.y)     ).r,
    texture(sampler, c + vec2(pixel.x,pixel.y)).r,
    texture(sampler, c + vec2(.0,pixel.y)     ).r,
    texture(sampler, c                        ).r
  );
}
#endif
#endif 