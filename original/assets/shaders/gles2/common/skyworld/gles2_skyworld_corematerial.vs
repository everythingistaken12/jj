precision lowp int; 
precision lowp float;

attribute mediump vec2 IN_uv;
attribute lowp vec4 IN_vertexcolour;

uniform highp mat4 worldmatrix;
uniform highp mat3 worldmatrixrot;
uniform highp mat4 viewmatrix;
uniform highp mat4 projectionmatrix;

#if defined(USE_UV_ANIMATION)
uniform lowp vec2 IN_material_uvoffset;
#endif

varying mediump vec4 uvs;
varying lowp vec4 vertexcolour;
varying lowp vec3 worldnormal;
varying lowp vec3 viewdirection;
varying mediump vec4 position;

uniform lowp vec3 IN_scene_eye_dir;
uniform highp vec3 IN_scene_eye_pos;

uniform lowp vec4  IN_material_colour;

#if defined( USE_SKINNING)

attribute mediump vec4  IN_bone_pos0;  //automatic upcast to vec4 with w=1
attribute mediump vec3  IN_bone_norm0;

attribute lowp vec3 IN_boneWeights;
attribute mediump vec3 IN_boneIndexs;

uniform mediump mat4 IN_bone_mats[ MAX_BONES_TOTAL ];

#elif defined(USE_CROWD_RENDERING)

attribute mediump vec4  IN_bone_pos0;  //automatic upcast to vec4 with w=1
attribute mediump vec3  IN_bone_norm0;
attribute mediump vec4  IN_bone_pos1;  //automatic upcast to vec4 with w=1
attribute mediump vec3  IN_bone_norm1;

attribute mediump vec3 IN_boneIndexs;

uniform lowp float IN_scene_lerp;
uniform mediump mat4 IN_bone_mats[ MAX_BONES_TOTAL ];

#elif defined(USE_CROWD_RENDERING_SIMPLE)

attribute mediump vec4  IN_bone_pos0;  //automatic upcast to vec4 with w=1
attribute mediump vec3  IN_bone_norm0;  

attribute mediump vec3 IN_boneIndexs;

uniform mediump mat4 IN_bone_mats[ MAX_BONES_TOTAL ];

#else

attribute mediump vec4 IN_position;
attribute lowp vec3 IN_normal;

#endif 

#if defined(USE_PP_LIGHTING)

uniform mediump vec3 IN_omnilight_pos[ OMNILIGHT_COUNT ];
varying mediump vec3 omniLightDir[ OMNILIGHT_COUNT ];

#endif


#if defined(USE_IMAGE_BASED_LIGHTING)
const float C1 = 0.429043;
const float C2 = 0.511664;
const float C3 = 0.743125;
const float C4 = 0.886227;
const float C5 = 0.247708;

uniform mediump vec3 IN_diffuse_L00;
uniform mediump vec3 IN_diffuse_L1m1;
uniform mediump vec3 IN_diffuse_L10;
uniform mediump vec3 IN_diffuse_L11;
uniform mediump vec3 IN_diffuse_L2m2;
uniform mediump vec3 IN_diffuse_L2m1;
uniform mediump vec3 IN_diffuse_L20;
uniform mediump vec3 IN_diffuse_L21;
uniform mediump vec3 IN_diffuse_L22;

highp vec3 SphericalHarmonicLight(highp vec3 tnorm)
{
	//Had to break this into several variables because the Kindle Fire was getting confused about how many registers it has when compiling this.
	
	mediump vec3 running = C1 * IN_diffuse_L22 * (tnorm.x * tnorm.x - tnorm.y * tnorm.y);
	
	mediump vec3 face = C3 * IN_diffuse_L20 * tnorm.z * tnorm.z +
						C4 * IN_diffuse_L00 -
						C5 * IN_diffuse_L20;
						
						 
	mediump vec3 back =	2.0 * C1 * IN_diffuse_L2m2 * tnorm.x * tnorm.y +
						2.0 * C1 * IN_diffuse_L21  * tnorm.x * tnorm.z +
						2.0 * C1 * IN_diffuse_L2m1 * tnorm.y * tnorm.z +
						2.0 * C2 * IN_diffuse_L11  * tnorm.x +
						2.0 * C2 * IN_diffuse_L1m1 * tnorm.y +   
						2.0 * C2 * IN_diffuse_L10  * tnorm.z;
		
						
						
						
	mediump vec3 total = running + face + back;
	return total;

}
#endif 



//////
mat3 mat3FromMat4(mat4 inMat)
{
	return mat3 (inMat[0].x, inMat[0].y, inMat[0].z,
				inMat[1].x, inMat[1].y, inMat[1].z,
				inMat[2].x, inMat[2].y, inMat[2].z);
}


void main()
{
#if defined(USE_UV_ANIMATION)
	uvs=vec4(IN_uv.x + IN_material_uvoffset.x ,IN_uv.y + IN_material_uvoffset.y ,0.0,0.0);
#else
	uvs=vec4(IN_uv.x,IN_uv.y,0.0,0.0);
#endif
	
	mediump mat4 modelView = viewmatrix * worldmatrix;
		

#if defined(USE_CROWD_RENDERING)

	highp vec4 bonePos = (IN_bone_pos0 * (1.0 - IN_scene_lerp)) + (IN_bone_pos1 * IN_scene_lerp);
	lowp vec3 boneNorm = (IN_bone_norm0 * (1.0 - IN_scene_lerp)) + (IN_bone_norm1 * IN_scene_lerp);
	
	highp vec4 vertexPos = IN_bone_mats[ int(IN_boneIndexs) ] * bonePos;


	//Fixme: This is completely wrong.
	worldnormal = worldmatrixrot * normalize(boneNorm); 

#elif defined( USE_SKINNING)

#if defined(BONEWEIGHTS_USED_1)

	mediump vec4 vertexPos;
	vertexPos= (( IN_bone_mats[ int( IN_boneIndexs[0]) ] * IN_bone_pos0) * IN_boneWeights[0]);

	//Create useful matrixes from the scaled ones
	//These normals are going to be wrong once you start doing non-uniform scales, but honestly the error is pretty low
	mediump mat3 matrix0 = mat3FromMat4( IN_bone_mats[ int( IN_boneIndexs[0]) ]);

	lowp vec3 normal =   (( matrix0 * IN_bone_norm0) * IN_boneWeights[0]);
	
	worldnormal = ( worldmatrixrot * normalize( normal )); //This normalize fixes alot of the drama
	
#elif defined(BONEWEIGHTS_USED_2)

	mediump vec4 vertexPos;
	vertexPos= (( IN_bone_mats[ int( IN_boneIndexs[0]) ] * IN_bone_pos0) * IN_boneWeights[0]) +
			   (( IN_bone_mats[ int( IN_boneIndexs[1]) ] * IN_bone_pos0) * IN_boneWeights[1]);
	
	//Create useful matrixes from the scaled ones
	//These normals are going to be wrong once you start doing non-uniform scales, but honestly the error is pretty low
	mediump mat3 matrix0 = mat3FromMat4(IN_bone_mats[ int( IN_boneIndexs[0]) ]);
	mediump mat3 matrix1 = mat3FromMat4(IN_bone_mats[ int( IN_boneIndexs[1]) ]);
	
	lowp vec3 normal =   (( matrix0 * IN_bone_norm0) * IN_boneWeights[0]) +
						 (( matrix1 * IN_bone_norm0) * IN_boneWeights[1]);
	
	worldnormal = ( worldmatrixrot * normalize( normal )); //This normalize fixes alot of the drama
	
#else

	mediump vec4 vertexPos;
	vertexPos= (( IN_bone_mats[ int( IN_boneIndexs[0]) ] * IN_bone_pos0) * IN_boneWeights[0]) +
			   (( IN_bone_mats[ int( IN_boneIndexs[1]) ] * IN_bone_pos0) * IN_boneWeights[1]) +
			   (( IN_bone_mats[ int( IN_boneIndexs[2]) ] * IN_bone_pos0) * IN_boneWeights[2]);

	//Create useful matrixes from the scaled ones
	//These normals are going to be wrong once you start doing non-uniform scales, but honestly the error is pretty low
	mediump mat3 matrix0 = mat3FromMat4( IN_bone_mats[ int( IN_boneIndexs[0]) ]);
	mediump mat3 matrix1 = mat3FromMat4( IN_bone_mats[ int( IN_boneIndexs[1]) ]);
	mediump mat3 matrix2 = mat3FromMat4( IN_bone_mats[ int( IN_boneIndexs[2]) ]);

	lowp vec3 normal =   (( matrix0 * IN_bone_norm0) * IN_boneWeights[0]) +
						 (( matrix1 * IN_bone_norm0) * IN_boneWeights[1]) +
						 (( matrix2 * IN_bone_norm0) * IN_boneWeights[2]);
	
	worldnormal = ( worldmatrixrot * normalize( normal )); //This normalize fixes alot of the drama
	

#endif 
	

#elif defined(USE_CROWD_RENDERING_SIMPLE)

	mediump vec4 bonePos = (IN_bone_pos0 );
	lowp vec3 boneNorm = (IN_bone_norm0);
	
	mediump vec4 vertexPos =  IN_bone_mats[ int(IN_boneIndexs) ] * bonePos;

	mediump mat3 matrix0 = mat3FromMat4( IN_bone_mats[ int(IN_boneIndexs) ] );
	worldnormal = matrix0 * normalize(boneNorm); 
#else

	mediump vec4 vertexPos = IN_position;
	worldnormal = worldmatrixrot * normalize(IN_normal) ; 
	
#endif

	viewdirection = normalize( IN_scene_eye_pos - (worldmatrix * vertexPos ).xyz );

#if defined(USE_IMAGE_BASED_LIGHTING)
	vec3 lighting = SphericalHarmonicLight( worldnormal );
#else
	vec3 lighting = vec3(1.0, 1.0, 1.0);
#endif



	vertexcolour = IN_vertexcolour * IN_material_colour  * vec4(lighting.x, lighting.y, lighting.z, 1.0);




#if defined(USE_PP_LIGHTING)

	for (int j = 0; j < OMNILIGHT_COUNT; j++)
	{
		omniLightDir[ j ] = IN_omnilight_pos[ j ] - (worldmatrix * vertexPos ).xyz;
	}

#endif

	position = modelView * vertexPos;

	gl_Position = (projectionmatrix * modelView ) *  vertexPos;
	
		
	
}

