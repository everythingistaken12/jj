//
//  post_warp.metal
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
    float strength;
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
	float2 uv0;
	float4 uv12;
};

vertex VertexOutIn ID_post_warp_v(VertexIn in [[ stage_in ]], constant Uniforms& uni [[ buffer(1)]])
{
    VertexOutIn out;

	out.pos = (uni.projectionmatrix * uni.viewmatrix * uni.worldmatrix  ) *  float4(in.pos, 1.0);
	out.uv0 = in.uv;
	out.uv12 = in.col;

	return out;
}

fragment float4 ID_post_warp_f(VertexOutIn in [[ stage_in ]],
	constant Uniforms& uni [[ buffer(1)]],
	texture2d<float> DiffuseMap [[ texture(0) ]],
	texture2d<float> WarpMap [[ texture(1) ]],
	sampler sam [[ sampler(0) ]])
{
	constexpr sampler warpSampler (mag_filter::linear, min_filter::linear);

	float warpStrength = 0.5 * uni.strength;
	float warpColorStrength = 0.65 * uni.strength;

	float4 warpValue = WarpMap.sample(warpSampler, float2(in.uv12.x / in.uv12.w, in.uv12.y));
	float4 warpColorValue = WarpMap.sample(warpSampler, float2(in.uv12.z / in.uv12.w, in.uv12.y));
	float2 offset = (float2(warpValue.x, warpValue.y) - float2(0.5)) * warpStrength;
	float3 diffuse = DiffuseMap.sample(sam, in.uv0 + offset).xyz;
	return float4(diffuse + warpColorValue.xyz * warpColorValue.w * warpColorStrength, warpValue.z);
}
