attribute vec2 IN_uv;
attribute vec4 IN_vertexcolour;

uniform mat4 worldmatrix;
uniform mat3 worldmatrixrot;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

uniform vec4 displaycolour;  //0..255

varying vec4 uvs;
varying vec4 vertexcolour;
varying vec3 worldnormal;

varying vec3 worldpos;


uniform vec3 IN_scene_eye_dir;
uniform vec3 IN_scene_eye_pos;

uniform vec4  IN_material_colour;

#if defined( USE_SKINNING)

attribute vec4  IN_bone_pos0;  //automatic upcast to vec4 with w=1
attribute vec3  IN_bone_norm0;

attribute vec3 IN_boneWeights;
attribute vec3 IN_boneIndexs;

uniform mat4 IN_bone_mats[ MAX_BONES_TOTAL ];

#else

attribute vec4 IN_position;
attribute vec3 IN_normal;

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
	uvs=vec4(IN_uv.x,IN_uv.y,0.0,0.0);
	
	vertexcolour = IN_vertexcolour * IN_material_colour  * ( displaycolour / 255.0 );
	mat4 modelView = mat4(viewmatrix * worldmatrix);
		
#if defined( USE_SKINNING)

#if defined(BONEWEIGHTS_USED_1)

	vec4 vertexPos;
	vertexPos= (( IN_bone_mats[ int( IN_boneIndexs[0]) ] * IN_bone_pos0) * IN_boneWeights[0]);

	//Create useful matrixes from the scaled ones
	//These normals are going to be wrong once you start doing non-uniform scales, but honestly the error is pretty low
	mat3 matrix0 = mat3FromMat4( IN_bone_mats[ int( IN_boneIndexs[0]) ]);

	vec3 normal =   (( matrix0 * IN_bone_norm0) * IN_boneWeights[0]);
	
	worldnormal = ( worldmatrixrot * normalize( normal )); //This normalize fixes alot of the drama
	worldpos = (worldmatrix * vertexPos ).xyz;
	
#elif defined(BONEWEIGHTS_USED_2)

	vec4 vertexPos;
	vertexPos= (( IN_bone_mats[ int( IN_boneIndexs[0]) ] * IN_bone_pos0) * IN_boneWeights[0]) +
			   (( IN_bone_mats[ int( IN_boneIndexs[1]) ] * IN_bone_pos0) * IN_boneWeights[1]);
	
	//Create useful matrixes from the scaled ones
	//These normals are going to be wrong once you start doing non-uniform scales, but honestly the error is pretty low
	mat3 matrix0 = mat3FromMat4(IN_bone_mats[ int( IN_boneIndexs[0]) ]);
	mat3 matrix1 = mat3FromMat4(IN_bone_mats[ int( IN_boneIndexs[1]) ]);
	
	vec3 normal =   (( matrix0 * IN_bone_norm0) * IN_boneWeights[0]) +
						 (( matrix1 * IN_bone_norm0) * IN_boneWeights[1]);
	
	worldnormal = ( worldmatrixrot * normalize( normal )); //This normalize fixes alot of the drama
	worldpos = (worldmatrix * vertexPos ).xyz;

#else

	vec4 vertexPos;
	vertexPos= (( IN_bone_mats[ int( IN_boneIndexs[0]) ] * IN_bone_pos0) * IN_boneWeights[0]) +
			   (( IN_bone_mats[ int( IN_boneIndexs[1]) ] * IN_bone_pos0) * IN_boneWeights[1]) +
			   (( IN_bone_mats[ int( IN_boneIndexs[2]) ] * IN_bone_pos0) * IN_boneWeights[2]);

	//Create useful matrixes from the scaled ones
	//These normals are going to be wrong once you start doing non-uniform scales, but honestly the error is pretty low
	mat3 matrix0 = mat3FromMat4( IN_bone_mats[ int( IN_boneIndexs[0]) ]);
	mat3 matrix1 = mat3FromMat4( IN_bone_mats[ int( IN_boneIndexs[1]) ]);
	mat3 matrix2 = mat3FromMat4( IN_bone_mats[ int( IN_boneIndexs[2]) ]);

	vec3 normal =   (( matrix0 * IN_bone_norm0) * IN_boneWeights[0]) +
						 (( matrix1 * IN_bone_norm0) * IN_boneWeights[1]) +
						 (( matrix2 * IN_bone_norm0) * IN_boneWeights[2]);
	
	worldnormal = ( worldmatrixrot * normalize( normal )); //This normalize fixes alot of the drama
	worldpos = (worldmatrix * vertexPos ).xyz;


#endif 


#else

	vec4 vertexPos = IN_position;
	worldnormal = worldmatrixrot * normalize(IN_normal) ; 
	worldpos = (worldmatrix * vertexPos).xyz;
#endif

	gl_Position = (projectionmatrix *modelView ) *  vertexPos;
}

