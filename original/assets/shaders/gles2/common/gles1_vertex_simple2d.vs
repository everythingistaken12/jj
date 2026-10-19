precision lowp int; 
precision highp float; 

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;
attribute lowp vec4 IN_vertexcolour;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

uniform lowp vec4 displaycolour;
varying lowp vec4 uvs;
varying lowp vec4 vertexcolour;


void main()
{
	uvs.xy=IN_uv;
	uvs.z = 0.0;
	uvs.w = 0.0;
	vertexcolour = (displaycolour);
	gl_Position = (projectionmatrix * viewmatrix * worldmatrix  ) *  IN_position;
}

