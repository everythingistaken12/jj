precision lowp int; 
precision highp float;

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;
attribute mediump vec4 IN_vertexcolour;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

varying mediump vec2 uv0;
varying mediump vec4 uv12;

void main()
{
	uv0 = IN_uv;
	uv12 = vec4(IN_vertexcolour);

	gl_Position = (projectionmatrix * viewmatrix * worldmatrix) * IN_position;
}

