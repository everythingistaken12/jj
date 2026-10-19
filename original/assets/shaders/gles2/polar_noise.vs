precision lowp int; 
precision highp float;

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;
attribute mediump vec4 IN_vertexcolour;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

uniform vec3 resolutionAndAspect;
uniform vec3 bottomLeft;

varying mediump vec2 v_uv;

void main()
{
	v_uv = (IN_position.xy - bottomLeft.xy) / resolutionAndAspect.xy;

	gl_Position = (projectionmatrix * viewmatrix * worldmatrix) * IN_position;
}
