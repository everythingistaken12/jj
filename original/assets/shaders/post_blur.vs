precision lowp int; 
precision highp float;

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;
attribute mediump vec4 IN_vertexcolour;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;
uniform mediump vec4 displaycolour;

varying mediump vec4 uvs0;
varying mediump vec4 uvs1;
varying mediump vec4 uvs2;
varying mediump vec4 uvs3;
varying mediump vec4 uvs4;
varying mediump vec4 uvs5;
varying mediump vec4 uvs6;

uniform mediump float xscale;
uniform mediump float yscale;

void main()
{
	gl_Position = (projectionmatrix * viewmatrix * worldmatrix  ) *  IN_position;

	mediump vec4 blurDir = vec4(xscale, yscale, 0, 0) ;
	mediump vec4 origin = vec4(IN_uv.x, IN_uv.y, 0.0, 0.0);
	
	uvs0 = origin - (blurDir * 3.0);
	uvs1 = origin - (blurDir * 2.0);
	uvs2 = origin - (blurDir * 1.0);
	uvs3 = origin;
	uvs4 = origin + (blurDir * 1.0);
	uvs5 = origin + (blurDir * 2.0);
	uvs6 = origin + (blurDir * 3.0);
}

