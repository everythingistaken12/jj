//
//  gles1_vertex_unlit.metal
//  Metal
//
//  Created by Administrator on 28/05/2015.
//
//

#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

struct Uniforms
{
	// vertex
    matrix_float4x4 worldmatrix;
    matrix_float4x4 viewmatrix;
    matrix_float4x4 projectionmatrix;
  
	float pixelX;
	float pixelY;
	
	// fragment
	float clip;
};

struct VertexIn
{
    float3 pos  [[ attribute( 0 ) ]];
    float2 uv   [[ attribute( 1 ) ]];
};

struct VertexOutIn
{
    float4 pos [[ position ]];
	float4 uvs0;
	float4 uvs1;
	float4 uvs2;
	float4 uvs3;
};

vertex VertexOutIn ID_post_bright_v(VertexIn in [[ stage_in ]], constant Uniforms& uni [[ buffer(1)]])
{
    VertexOutIn out;
    
	out.pos = (uni.projectionmatrix * uni.viewmatrix * uni.worldmatrix  ) *  float4(in.pos, 1.0);

	// 1/4 downsample innate
	out.uvs0 = float4(in.uv.x, in.uv.y, 0.0, 0.0) + float4(uni.pixelX * 0.5, uni.pixelY * 0.5, 0, 0);
	out.uvs1 = float4(in.uv.x ,in.uv.y, 0.0, 0.0) + float4(uni.pixelX * 2.5, uni.pixelY * 0.5, 0, 0);
	out.uvs2 = float4(in.uv.x, in.uv.y, 0.0, 0.0) + float4(uni.pixelX * 0.5, uni.pixelY * 2.5, 0, 0);
	out.uvs3 = float4(in.uv.x, in.uv.y, 0.0, 0.0) + float4(uni.pixelX * 2.5, uni.pixelY * 2.5, 0, 0);
	
	return out;
}

fragment float4 ID_post_bright_f(VertexOutIn in [[ stage_in ]], texture2d<float> DiffuseMap [[ texture(0) ]], sampler sam [[ sampler(0) ]], constant Uniforms& uni [[ buffer(1)]])
{
	float4 rgb = (DiffuseMap.sample(sam, in.uvs0.xy) * 0.25) +
				 (DiffuseMap.sample(sam, in.uvs1.xy) * 0.25) +
				 (DiffuseMap.sample(sam, in.uvs2.xy) * 0.25) +
				 (DiffuseMap.sample(sam, in.uvs3.xy) * 0.25);

	float lum = (0.333 * rgb.x) + (0.333 * rgb.y) + (0.333 * rgb.z);
	
	float fraction = ceil( clamp(lum - uni.clip, 0.0, 1.0) );

	return float4(rgb.xyz * fraction, 1.0);
}
