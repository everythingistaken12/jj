precision lowp int; 
precision highp float;

attribute mediump vec4 IN_position;
attribute lowp vec2 IN_uv;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

uniform mediump float pixelX;
uniform mediump float pixelY;

varying mediump vec4 uvs0;
varying mediump vec4 uvs1;
varying mediump vec4 uvs2;
varying mediump vec4 uvs3;


void main()
{
	// 1/4 downsample innate
	uvs0 = vec4(IN_uv.x, IN_uv.y, 0.0, 0.0) + vec4(pixelX * 0.5, pixelY * 0.5, 0, 0);
	uvs1 = vec4(IN_uv.x ,IN_uv.y, 0.0, 0.0) + vec4(pixelX * 2.5, pixelY * 0.5, 0, 0);
	uvs2 = vec4(IN_uv.x, IN_uv.y, 0.0, 0.0) + vec4(pixelX * 0.5, pixelY * 2.5, 0, 0);
	uvs3 = vec4(IN_uv.x, IN_uv.y, 0.0, 0.0) + vec4(pixelX * 2.5, pixelY * 2.5, 0, 0);

	gl_Position = (projectionmatrix * viewmatrix * worldmatrix  ) *  IN_position;
}

