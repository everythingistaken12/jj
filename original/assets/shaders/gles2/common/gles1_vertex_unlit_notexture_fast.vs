precision lowp int; 
precision highp float; 

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;
attribute mediump vec4 IN_vertexcolour;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

uniform lowp vec4 displaycolour;
varying lowp vec4 vertexcolour;

uniform vec4 _scale[15*4];

void main()
{
	vec4 aux;
	int offset = int(IN_position.z);
	aux.xy = IN_position.xx*_scale[offset].xz + IN_position.yy*_scale[offset].yw;
	aux.xy += _scale[offset+2].xy;
	aux.z = _scale[offset+2].z;
	aux.w = 1.0;
		
	vertexcolour=(_scale[offset+3])*IN_vertexcolour*displaycolour;
	gl_Position = (projectionmatrix * viewmatrix * worldmatrix  ) *  aux;
}

