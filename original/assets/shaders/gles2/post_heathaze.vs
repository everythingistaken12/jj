precision lowp int; 
precision highp float;

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;
attribute mediump vec4 IN_vertexcolour;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

varying mediump vec2 v_uv0;
varying mediump vec2 v_uv1;
varying mediump vec2 v_uv2;
varying mediump float v_alpha;

void main()
{
	v_uv0 = IN_uv;

	v_uv1 = IN_vertexcolour.xy;

	v_uv2.x = IN_vertexcolour.z;
	v_uv2.y = IN_vertexcolour.y;

	v_alpha = IN_vertexcolour.w;

	gl_Position = (projectionmatrix * viewmatrix * worldmatrix) * IN_position;
}
