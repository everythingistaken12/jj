attribute vec4 IN_position;
attribute vec3 IN_normal;

attribute vec2 IN_uv;
attribute vec4 IN_vertexcolour;


uniform mat4 worldmatrix;
uniform mat3 worldmatrixrot;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

uniform vec4 displaycolour;

varying vec2 uvs;
varying vec4 vertexcolour;
varying vec3 worldnormal;
varying vec3 worldpos;

uniform vec3 IN_scene_eye_dir;
uniform vec3 IN_scene_eye_pos;




//////


void main()
{
	uvs=IN_uv;


	vertexcolour=(IN_vertexcolour) * (displaycolour / 255.0);
	
	worldnormal = normalize(IN_normal) *worldmatrixrot; 
	
	mat4  modelView = mat4(viewmatrix * worldmatrix);
	
	worldpos = (worldmatrix * IN_position).xyz;


	gl_Position = (projectionmatrix *modelView ) *  IN_position;



   
	
	
}

