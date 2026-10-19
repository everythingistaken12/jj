precision mediump float;
precision lowp int;

attribute vec4 IN_position;
attribute vec2 IN_uv;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

varying highp vec2 v_uv;

void main()
{
	v_uv = IN_uv;
	gl_Position = projectionmatrix * viewmatrix * worldmatrix * IN_position;
}
