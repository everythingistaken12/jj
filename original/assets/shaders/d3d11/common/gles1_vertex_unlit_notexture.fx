
Texture2D DiffuseMap : register(t0);
SamplerState linearSampler : register(s0);


cbuffer simpleConstantBuffer : register( b0 )
{
	matrix worldmatrix;
	matrix viewmatrix;
	matrix projectionmatrix;
	matrix texturematrix;

	float4 displayColour;
};


struct VertexShaderInput
{
    float3 IN_position : POSITION0;
    float3 IN_normal : NORMAL0;
	float3 IN_tangent :  NORMAL1; 
	float3 IN_bitangent :   NORMAL2; 
	float4 IN_vertexcolour :   COLOR0;
	float2 IN_uv : TEXCOORD0;
	
};

struct PixelShaderInput
{
    float4 position : SV_POSITION;
    float2 uv : TEXCOORD0;
	float4 colour: COLOR0;
	
};

//--------------------------------------------------------------------------------------
// Vertex Shader
//--------------------------------------------------------------------------------------
PixelShaderInput VS( VertexShaderInput Input )
{
		PixelShaderInput result;

		float4 pos;
		
		pos.xyz=Input.IN_position;
		pos.w=1.0;

		// Transform the vertex position into projection space.
		pos = mul(pos, worldmatrix);
		pos = mul(pos, viewmatrix);
		pos = mul(pos, projectionmatrix);
		
		result.uv = Input.IN_uv;

		result.colour = (Input.IN_vertexcolour / 255.0f) * (displayColour / 255.0f);

		result.position = pos;
		return result;
}


//--------------------------------------------------------------------------------------
// Pixel Shader
//--------------------------------------------------------------------------------------
float4 PS( PixelShaderInput input ) : SV_Target
{
    //float4 textureSample = DiffuseMap.Sample(linearSampler, input.uv) *  input.colour ;
	float4 textureSample = input.colour ;
	

	return textureSample;
///	return float4( 1.0f, 1.0f, 0.0f, 1.0f );    // Yellow, with Alpha = 1
}
