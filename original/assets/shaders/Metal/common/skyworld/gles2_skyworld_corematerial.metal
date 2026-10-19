#include <metal_stdlib>
#include <simd/simd.h>

using namespace metal;

#if defined(USE_IMAGE_BASED_LIGHTING)
constant float C1 = 0.429043;
constant float C2 = 0.511664;
constant float C3 = 0.743125;
constant float C4 = 0.886227;
constant float C5 = 0.247708;
#endif

struct Uniforms
{
	// Vertex
    matrix_float4x4 worldmatrix;
    matrix_float4x4 viewmatrix;
    matrix_float4x4 projectionmatrix;
    matrix_float4x4 worldmatrixrot;
	
#if defined(USE_UV_ANIMATION)	
	float2 IN_material_uvoffset;
#endif
	
    float3 IN_scene_eye_dir;
    float3 IN_scene_eye_pos; 	

    float4 IN_material_colour;
	
#if defined( USE_SKINNING)	
	matrix_float4x4 IN_bone_mats[MAX_BONES_TOTAL];	
#elif defined(USE_CROWD_RENDERING)
    float IN_scene_lerp;
	matrix_float4x4 IN_bone_mats[MAX_BONES_TOTAL];
#elif defined(USE_CROWD_RENDERING_SIMPLE)
	matrix_float4x4 IN_bone_mats[MAX_BONES_TOTAL];
#endif

#if defined(USE_PP_LIGHTING)	
    float3 IN_omnilight_pos[ OMNILIGHT_COUNT ];
#endif

#if defined(USE_IMAGE_BASED_LIGHTING)
    float3 IN_diffuse_L00;
    float3 IN_diffuse_L1m1;
    float3 IN_diffuse_L10;
    float3 IN_diffuse_L11;
    float3 IN_diffuse_L2m2;
    float3 IN_diffuse_L2m1;
    float3 IN_diffuse_L20;
    float3 IN_diffuse_L21;
    float3 IN_diffuse_L22;	
#endif

	// Fragment
    float zfar;
#if defined(USE_TOON_SHADING)	
	float3 IN_toon_dir;
#endif

#if defined(USE_SPECULAR)
#if defined(USE_SPECULAR_SKIPPING)
	float3 IN_material_model_origin;	
#endif
    float IN_material_specpow;
    float IN_material_speclevel;	
    float3 IN_material_speccolour;
    float3 IN_material_specdir;
#endif
    float IN_scene_ambientscale;

#if defined(USE_RIM_SHADING)	
    float IN_material_rimscale;
    float IN_material_rimpower;	
    float3 IN_material_rimcolour;	
#endif

#if defined(USE_PP_LIGHTING)
	float3 IN_omnilight_colour[ OMNILIGHT_COUNT ];	
    float IN_omnilight_radius[ OMNILIGHT_COUNT ];
#endif
};

struct VertexIn
{
#if defined(USE_SKINNING)
    float3 IN_bone_pos0     [[ attribute( 0 ) ]];
    float3 IN_bone_norm0    [[ attribute( 1 ) ]];
	float3 IN_boneWeights	[[ attribute( 2 ) ]];	
    float3 IN_boneIndexs    [[ attribute( 3 ) ]];
    float4 IN_vertexcolour  [[ attribute( 4 ) ]];	
    float2 IN_uv            [[ attribute( 5 ) ]];	
#elif defined(USE_CROWD_RENDERING)
    float3 IN_bone_pos0     [[ attribute( 0 ) ]];
    float3 IN_bone_norm0    [[ attribute( 1 ) ]];
    float3 IN_bone_pos1     [[ attribute( 2 ) ]];
    float3 IN_bone_norm1    [[ attribute( 3 ) ]];
    float3 IN_boneIndexs    [[ attribute( 4 ) ]];
    float4 IN_vertexcolour  [[ attribute( 5 ) ]];	
    float2 IN_uv            [[ attribute( 6 ) ]];	
#elif defined(USE_CROWD_RENDERING_SIMPLE)
    float3 IN_bone_pos0     [[ attribute( 0 ) ]];
    float3 IN_bone_norm0    [[ attribute( 1 ) ]];
    float3 IN_boneIndexs    [[ attribute( 2 ) ]];
    float4 IN_vertexcolour  [[ attribute( 3 ) ]];	
    float2 IN_uv            [[ attribute( 4 ) ]];		
#else
    float3 IN_position      [[ attribute( 0 ) ]];
    float3 IN_normal        [[ attribute( 1 ) ]];
    float4 IN_vertexcolour  [[ attribute( 2 ) ]];	
    float2 IN_uv            [[ attribute( 3 ) ]];	
#endif
};

struct VertexOutIn
{
    float4 pos [[ position ]];
    float2 uvs;
    float3 worldnormal;
    float3 viewdirection;
    float4 worldPos;
    float4 vertexcolour;

    //float3 omniLightDir[ OMNILIGHT_COUNT ];
};

// declarations
matrix_float3x3 mat3FromMat4(matrix_float4x4 inMat);

#if defined(USE_SPECULAR)
float Polar(float x, float y);
float2 DoImageBasedSpecular(float3 reflect);
#endif

#if defined(USE_IMAGE_BASED_LIGHTING)
float3 SphericalHarmonicLight(float3 tnorm, constant Uniforms& uni);
#endif


#if defined(USE_IMAGE_BASED_LIGHTING)
float3 SphericalHarmonicLight(float3 tnorm, constant Uniforms& uni)
{
    float3 running = C1 * uni.IN_diffuse_L22 * (tnorm.x * tnorm.x - tnorm.y * tnorm.y);
    
    float3 face = C3 * uni.IN_diffuse_L20 * tnorm.z * tnorm.z +
                  C4 * uni.IN_diffuse_L00 -
                  C5 * uni.IN_diffuse_L20;
    
    float3 back = 2.0 * C1 * uni.IN_diffuse_L2m2 * tnorm.x * tnorm.y +
                  2.0 * C1 * uni.IN_diffuse_L21  * tnorm.x * tnorm.z +
                  2.0 * C1 * uni.IN_diffuse_L2m1 * tnorm.y * tnorm.z +
                  2.0 * C2 * uni.IN_diffuse_L11  * tnorm.x +
                  2.0 * C2 * uni.IN_diffuse_L1m1 * tnorm.y +
                  2.0 * C2 * uni.IN_diffuse_L10  * tnorm.z;
    
    float3 total = running + face + back;
    return total;
}
#endif

matrix_float3x3 mat3FromMat4(matrix_float4x4 inMat)
{
    return matrix_float3x3 (float3(inMat[0][0], inMat[0][1], inMat[0][2]),
                            float3(inMat[1][0], inMat[1][1], inMat[1][2]),
                            float3(inMat[2][0], inMat[2][1], inMat[2][2]));
}

vertex VertexOutIn gles2_skyworld_corematerial_v(VertexIn in [[ stage_in ]], constant Uniforms& uni [[ buffer(1)]])
{
    VertexOutIn out;

#if defined(USE_UV_ANIMATION)
    out.uvs = float2(in.IN_uv.x + uni.IN_material_uvoffset.x, in.IN_uv.y + uni.IN_material_uvoffset.y);
#else
    out.uvs = in.IN_uv;
#endif
    
    matrix_float4x4 modelView = uni.viewmatrix * uni.worldmatrix;

#if defined(USE_CROWD_RENDERING)
    float4 bonePos = (float4(in.IN_bone_pos0, 1) * (1.0 - uni.IN_scene_lerp)) + (float4(in.IN_bone_pos1, 1) * uni.IN_scene_lerp);
    float3 boneNorm = (in.IN_bone_norm0 * (1.0 - uni.IN_scene_lerp)) + (in.IN_bone_norm1 * uni.IN_scene_lerp);
    
    float4 vertexPos = uni.IN_bone_mats[ int(in.IN_boneIndexs[0]) ] * bonePos;
    
    out.worldnormal = float3(uni.worldmatrixrot * float4(normalize(boneNorm), 1));

#elif defined(USE_SKINNING)
    
#if defined(BONEWEIGHTS_USED_1)
    float4 vertexPos;
    vertexPos = (( uni.IN_bone_mats[ int( in.IN_boneIndexs[0] )] * float4(in.IN_bone_pos0, 1)) * in.IN_boneWeights[0]);
    
    matrix_float3x3 matrix0 = mat3FromMat4( uni.IN_bone_mats[ int ( in.IN_boneIndexs[0]) ]);
    
    float3 normal = ((matrix0 * in.IN_bone_norm0) * in.IN_boneWeights[0]);
    
    out.worldnormal = float3((uni.worldmatrixrot * float4(normalize(normal), 1)));
    
#elif defined(BONEWEIGHTS_USED_2)
    float4 vertexPos;
    vertexPos = (( uni.IN_bone_mats[ int( in.IN_boneIndexs[0] )] * float4(in.IN_bone_pos0, 1)) * in.IN_boneWeights[0]) +
                (( uni.IN_bone_mats[ int( in.IN_boneIndexs[1] )] * float4(in.IN_bone_pos0, 1)) * in.IN_boneWeights[1]);
    
    matrix_float3x3 matrix0 = mat3FromMat4( uni.IN_bone_mats[ int ( in.IN_boneIndexs[0]) ]);
    matrix_float3x3 matrix1 = mat3FromMat4( uni.IN_bone_mats[ int ( in.IN_boneIndexs[1]) ]);
    
    float3 normal = ((matrix0 * in.IN_bone_norm0) * in.IN_boneWeights[0]) +
                    ((matrix1 * in.IN_bone_norm0) * in.IN_boneWeights[1]);
    
    out.worldnormal = float3((uni.worldmatrixrot * float4(normalize(normal), 1)));
#else
    float4 vertexPos;
    vertexPos = (( uni.IN_bone_mats[ int( in.IN_boneIndexs[0] )] * float4(in.IN_bone_pos0, 1)) * in.IN_boneWeights[0]) +
                (( uni.IN_bone_mats[ int( in.IN_boneIndexs[1] )] * float4(in.IN_bone_pos0, 1)) * in.IN_boneWeights[1]) +
                (( uni.IN_bone_mats[ int( in.IN_boneIndexs[2] )] * float4(in.IN_bone_pos0, 1)) * in.IN_boneWeights[2]);
    
    matrix_float3x3 matrix0 = mat3FromMat4( uni.IN_bone_mats[ int ( in.IN_boneIndexs[0]) ]);
    matrix_float3x3 matrix1 = mat3FromMat4( uni.IN_bone_mats[ int ( in.IN_boneIndexs[1]) ]);
    matrix_float3x3 matrix2 = mat3FromMat4( uni.IN_bone_mats[ int ( in.IN_boneIndexs[2]) ]);
    
    float3 normal = ((matrix0 * in.IN_bone_norm0) * in.IN_boneWeights[0]) +
                    ((matrix1 * in.IN_bone_norm0) * in.IN_boneWeights[1]) +
                    ((matrix2 * in.IN_bone_norm0) * in.IN_boneWeights[2]);
    
    out.worldnormal = float3((uni.worldmatrixrot * float4(normalize(normal), 1)));
#endif
    

    
#elif defined(USE_CROWD_RENDERING_SIMPLE)
    float4 bonePos = float4(in.IN_bone_pos0, 1);
    float3 boneNorm = (in.IN_bone_norm0);
    
    float4 vertexPos =  uni.IN_bone_mats[ int(in.IN_boneIndexs[0]) ] * bonePos;
    
    matrix_float3x3 matrix0 = mat3FromMat4( uni.IN_bone_mats[ int(in.IN_boneIndexs[0]) ] );
    out.worldnormal = matrix0 * normalize(boneNorm);
#else
    float4 vertexPos = float4(in.IN_position, 1);
    out.worldnormal = float3(uni.worldmatrixrot * float4(normalize(in.IN_normal), 1));
#endif
    
    out.viewdirection = normalize( uni.IN_scene_eye_pos - (uni.worldmatrix * vertexPos ).xyz );
    
#if defined(USE_IMAGE_BASED_LIGHTING)
    float3 lighting = SphericalHarmonicLight( out.worldnormal, uni );
#else
    float3 lighting = float3(1.0, 1.0, 1.0);
#endif
    
    out.vertexcolour = in.IN_vertexcolour * uni.IN_material_colour * float4(lighting.x, lighting.y, lighting.z, 1.0);
    
#if defined(USE_PP_LIGHTING)
    for (int j = 0; j < OMNILIGHT_COUNT; j++)
    {
       // out.omniLightDir[ j ] = uni.IN_omnilight_pos[ j ] - (uni.worldmatrix * vertexPos ).xyz;
    }
#endif
    
    out.worldPos = modelView * vertexPos;
    out.pos = (uni.projectionmatrix * modelView) *  vertexPos;
    return out;
}

#if defined(USE_SPECULAR)
float Polar(float x, float y)
{
    float top = float(y > 0.0);
    float right = float(x > 0.0);
    float bottom = float(0.0 >= y);
    float left = float(0.0 >= x);
    
    float yy = y * 0.25;
    
    float quad0  = yy * top * right;
    float quad1 =  (0.5 -yy) * top * left;
    float quad2  = (0.5 -yy) * bottom * left;
    float quad3 =  (1.0 + yy) * bottom * right;
    
    return quad0 + quad1 + quad2 + quad3;
}

float2 DoImageBasedSpecular(float3 reflect)
{
    float2 nx = normalize(float2(reflect.x, -reflect.z));
    return float2( Polar(nx.x, nx.y),  (-reflect.y * 0.5) + 0.5);
}
#endif

fragment float4 gles2_skyworld_corematerial_f(VertexOutIn in [[ stage_in ]], sampler sam [[ sampler(0) ]], constant Uniforms& uni [[ buffer(1) ]], texture2d<float> IN_texture_diffuse [[ texture(0) ]], texture2d<float> IN_texture_toon [[ texture(1) ]], texture2d<float> IN_texture_glossMap [[ texture(2) ]], texture2d<float> IN_texture_secondDiffuse [[ texture(3) ]], texture2d<float> IN_texture_skymap_specular [[ texture(4) ]]
                                            )
{
    float3 normalizedNormal = normalize(in.worldnormal);  //This gets optimized out if noones using it
    float3 viewDir = normalize(in.viewdirection);
    
    
#if defined(USE_SPECULAR)
    float3 specularAccumulation = float3(0.0, 0.0, 0.0);
    float specularScale = uni.IN_material_speclevel;
    
#if defined(USE_GLOSS_MAP)
    float4 glossSample = IN_texture_glossMap.sample(sam, in.uvs.xy);
    specularScale *= glossSample.r;
#endif
#endif
    
#if defined(USE_DIFFUSE_TEXTURE)
    
#if defined(USE_TERRAIN_BLENDING)
    float4 diffuseSample = IN_texture_diffuse.sample(sam, in.uvs.xy);
    float4 secondDiffuseSample = IN_texture_secondDiffuse.sample(sam, in.uvs.xy);
    
    float4 diffuse = mix(diffuseSample, secondDiffuseSample,  secondDiffuseSample.a * in.vertexcolour.a) * in.vertexcolour;
#else
    float4 diffuseSample = IN_texture_diffuse.sample(sam, in.uvs.xy);
    float4 diffuse = diffuseSample * in.vertexcolour;
#endif
    
#else
    float4 diffuse = in.vertexcolour;
#endif
    
    
    
#if defined(USE_ALPHA_TEST)
    if (diffuse.a < 0.5)
    {
        discard_fragment();
    }
#endif
    
#if defined(USE_TOON_SHADING)
    float dotresult = (dot(normalizedNormal, uni.IN_toon_dir) * 0.49) + 0.5;
    float4 toonSample = IN_texture_toon.sample(sam, float2(dotresult, 0.5));
    diffuse.xyz *= toonSample.xyz;
	diffuse.a = in.vertexcolour.a;
#endif
    
#if defined(USE_PP_LIGHTING)
    
    
    float3 lightAccum = float3(0.0, 0.0, 0.0);
    float3 pointLightSpecular = float3(0.0, 0.0, 0.0);
    
    for (int j = 0; j < OMNILIGHT_COUNT; j++)
    {
        float len = length(in.omniLightDir[j]);
        len = max(len, 0.01);
        float3 lightDir = normalize(in.omniLightDir[j]);
        float attenuation =  min(len, uni.IN_omnilight_radius[j] ) / uni.IN_omnilight_radius[j];
        attenuation *= attenuation;
        attenuation = 1.0 - attenuation;
        
        lightAccum += diffuse.xyz * clamp(dot( normalizedNormal, lightDir), 0.0, 1.0) * attenuation * uni.IN_omnilight_colour[j];
        
        
        
#if defined(USE_SPECULAR_MATH) || defined(USE_SPECULAR)
        
        float ref = dot(reflect(-lightDir, normalizedNormal), viewDir);
        float specularValue = pow( max(0.001, ref), uni.IN_material_specpow) * specularScale;
        specularAccumulation +=  specularValue * uni.IN_omnilight_colour[j] * attenuation;  // * attenuation is WRONG. Specular reflections attenuate as a function of their pow (so basically, never).  But we can't have specular from all lights affect all things, so this'll do.
#endif
    }
    
    diffuse.xyz += lightAccum;
    
#endif
    
    
    
    
#if defined(USE_SPECULAR_SKIPPING) //image based with weird inputs to make it facety
    
    float3 weirdReflectVector = -normalize( reflect(-uni.IN_material_model_origin, normalizedNormal ));
    float2 specularLightUV = DoImageBasedSpecular(weirdReflectVector);
    specularAccumulation += IN_texture_skymap_specular.sample(sam, specularLightUV).xyz  * specularScale * uni.IN_material_speccolour;
    
#elif defined(USE_SPECULAR_MATH)  //math based
    
    float reflectValue = dot(reflect(uni.IN_material_specdir, normalizedNormal), viewDir);
    float specularValue = pow( max(0.001, reflectValue), uni.IN_material_specpow) * specularScale;
    specularAccumulation +=  specularValue * uni.IN_material_speccolour;
    
#elif defined(USE_SPECULAR) //image based
    float3 reflectVector = reflect(normalizedNormal, viewDir);
    float2 specularLightUV = DoImageBasedSpecular(reflectVector);
    specularAccumulation += IN_texture_skymap_specular.sample(sam, specularLightUV).xyz * specularScale * uni.IN_material_speccolour;
    
#endif
    
#if defined(USE_RIM_SHADING)
    float3 rim = pow( 1.001 - abs( dot(viewDir, normalizedNormal) ), uni.IN_material_rimpower ) * uni.IN_material_rimscale * uni.IN_material_rimcolour;  // pow(0) == unhappy glsl on ipad 1
    diffuse.xyz += rim;
#endif
    
    
    
    //Gather
    
    float4 out;
#if defined(USE_DEPTH_RENDERING)
    
    float zed = -in.worldPos.z / uni.zfar;
    
    out.xyz = float3(zed, zed, zed);
#else
#if defined(USE_SPECULAR)
    out.xyz = (diffuse.xyz) + specularAccumulation;
    
#else
    out.xyz = diffuse.xyz;
#endif
#endif
    
    out.w = diffuse.w;
    
#if defined(OVERDRAW_TEST)      
    return float4(0.05, 0.0, 0.0, 1.0);
#else
    return out;
#endif 
    
    
}
