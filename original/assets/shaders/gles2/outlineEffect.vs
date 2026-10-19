precision lowp int; 
precision highp float;

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;
attribute mediump vec4 IN_vertexcolour;
attribute mediump vec3 IN_normal;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

varying mediump vec2 v_uv;
varying mediump vec2 v_minUv;
varying mediump vec2 v_maxUv;
varying mediump float v_borderWidth;

void main()
{
	v_uv = IN_uv;

	v_minUv = IN_vertexcolour.xy;
	v_maxUv = IN_vertexcolour.zw;

	v_borderWidth = IN_normal.x;

	gl_Position = (projectionmatrix * viewmatrix * worldmatrix  ) *  IN_position;
}

