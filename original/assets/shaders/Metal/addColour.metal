//
//  addColour.metal
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
};

struct VertexIn
{
    float3 pos  [[ attribute( 0 ) ]];
    float2 uv   [[ attribute( 1 ) ]];
    float4 col  [[ attribute( 2 ) ]];
    float3 norm [[ attribute( 3 ) ]];
};

struct VertexOutIn
{
    float4 pos [[ position ]];
    float2 uv;
    float4 col;
    float3 norm;
};

vertex VertexOutIn addColour_v(VertexIn in [[ stage_in ]], constant Uniforms& uni [[ buffer(1)]])
{
    VertexOutIn out;
    
    out.pos = (uni.projectionmatrix * uni.viewmatrix * uni.worldmatrix) * float4(in.pos, 1.0);
    out.col = (in.col / 255.0) * uni.displaycolour;
    out.uv = in.uv;
    out.norm = in.norm;
    return out;
}

fragment float4 addColour_f(VertexOutIn in [[ stage_in ]], texture2d<float> DiffuseMap [[ texture(0) ]], sampler sam [[ sampler(0) ]])
{
    float4 fragCol = DiffuseMap.sample(sam, in.uv) * in.col;

	float3 col = fragCol.rgb + in.norm;
	return float4(col, fragCol.a);
}
