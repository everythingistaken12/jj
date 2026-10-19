//
//  gles1_vertex_unlit_fast.metal
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
    float4 scale[15*4];
    
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

vertex VertexOutIn gles1_vertex_unlit_notexture_fast_v(VertexIn in [[ stage_in ]], constant Uniforms& uni [[ buffer(1)]])
{
    VertexOutIn out;
    
    float4 aux;
    int offset = int(in.pos.z);
    aux.xy = in.pos.xx * uni.scale[offset].xz + in.pos.yy * uni.scale[offset].yw;
    aux.xy += uni.scale[offset + 2].xy;
    aux.z = uni.scale[offset + 2].z;
    aux.w = 1.0;
    
    float2 uv;
    uv.xy = uni.scale[offset + 1].xz * in.uv + uni.scale[offset + 1].yw;
    out.uv = uv;
    out.col = (uni.scale[offset + 3]) * in.col * uni.displaycolour;
    out.pos = (uni.projectionmatrix * uni.viewmatrix * uni.worldmatrix) * aux;
    return out;
}

fragment float4 gles1_vertex_unlit_notexture_fast_f(VertexOutIn in [[ stage_in ]])
{
    return in.col;
}
