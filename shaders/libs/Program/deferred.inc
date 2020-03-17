/*
 * Copyright 2020 Ovizro
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
 
out vec2 texcoord;

#include "/libs/utility.glsl"
#include "/libs/Program/atmosphere.inc"

#ifndef UOS
void main() {
#else
void deferredCommons() {
#endif
	gl_Position = gl_ProjectionMatrix * (gl_ModelViewMatrix * gl_Vertex);
	texcoord = gl_MultiTexCoord0.st;
	
	atmosphereCommons();
}

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
 
in vec2 texcoord;
#include "/libs/Program/outTex.inc"

#include "/libs/GlslConfig"

#include "/libs/utility.glsl"
#include "/libs/Program/atmosphere.inc"
#endif 