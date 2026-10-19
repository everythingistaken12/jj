precision lowp int; 
precision highp float;

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

varying mediump vec2 uv;

void main()
{
	uv = vec2(IN_uv.x, IN_uv.y);

	gl_Position = (projectionmatrix * viewmatrix * worldmatrix  ) *  IN_position;
}

