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
    matrix_float4x4 worldmatrix;
    matrix_float4x4 viewmatrix;
    matrix_float4x4 projectionmatrix;
    
    float4 displaycolour;
	
	float xscale;
	float yscale;
};

struct VertexIn
{
    float3 pos  [[ attribute( 0 ) ]];
    float2 uv   [[ attribute( 1 ) ]];
    float4 col  [[ attribute( 2 ) ]];
};

struct VertexOutIn
{
    float4 pos [[ position ]];
	float4 uvs0;
	float4 uvs1;
	float4 uvs2;
	float4 uvs3;
	float4 uvs4;
	float4 uvs5;
	float4 uvs6;
};

vertex VertexOutIn ID_post_blur_v(VertexIn in [[ stage_in ]], constant Uniforms& uni [[ buffer(1)]])
{
    VertexOutIn out;
    
	out.pos = (uni.projectionmatrix * uni.viewmatrix * uni.worldmatrix  ) *  float4(in.pos, 1.0);

	float4 blurDir = float4(uni.xscale, uni.yscale, 0, 0) ;
	float4 origin = float4(in.uv.x, in.uv.y, 0.0, 0.0);
	
	out.uvs0 = origin - (blurDir * 3.0);
	out.uvs1 = origin - (blurDir * 2.0);
	out.uvs2 = origin - (blurDir * 1.0);
	out.uvs3 = origin;
	out.uvs4 = origin + (blurDir * 1.0);
	out.uvs5 = origin + (blurDir * 2.0);
	out.uvs6 = origin + (blurDir * 3.0);
	
	return out;
}

fragment float4 ID_post_blur_f(VertexOutIn in [[ stage_in ]], texture2d<float> DiffuseMap [[ texture(0) ]], sampler sam [[ sampler(0) ]])
{
	//sneeky abuse of texture filtering 
	float4 acc;
	acc =   DiffuseMap.sample(sam, in.uvs0.xy) * 0.06944444;
	acc +=  DiffuseMap.sample(sam, in.uvs1.xy) * 0.13888888;
	acc +=  DiffuseMap.sample(sam, in.uvs2.xy) * 0.1875;
	acc +=  DiffuseMap.sample(sam, in.uvs3.xy) * 0.20833333;
	acc +=  DiffuseMap.sample(sam, in.uvs4.xy) * 0.1875;
	acc +=  DiffuseMap.sample(sam, in.uvs5.xy) * 0.13888888;
	acc +=  DiffuseMap.sample(sam, in.uvs6.xy) * 0.06944444;
	
	return float4(acc.xyz, 1.0);
}
