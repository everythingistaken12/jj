precision lowp int; 
precision lowp float;

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;
attribute mediump vec4 IN_vertexcolour;
attribute mediump vec3 IN_normal;

uniform mediump mat4 worldmatrix;
uniform mediump mat4 viewmatrix;
uniform mediump mat4 projectionmatrix;

uniform lowp vec4 displaycolour;
varying lowp vec4 uvs;
varying lowp vec4 vertexColour;
varying mediump vec3 normal;


void main()
{
	normal = IN_normal;
	uvs=vec4(IN_uv.x, IN_uv.y, 0.0, 0.0);
	vertexColour = (IN_vertexcolour / 255.0) * (displaycolour);
	gl_Position = (projectionmatrix * viewmatrix * worldmatrix  ) *  IN_position;
}

