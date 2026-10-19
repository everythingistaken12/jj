attribute vec4 IN_position;
attribute vec2 IN_uv;
attribute vec4 IN_vertexcolour;

uniform mat4 worldmatrix;
uniform mat4 viewmatrix;
uniform mat4 projectionmatrix;

uniform vec4 displaycolour;
varying vec2 uvs;
varying vec4 vertexcolour;


void main()
{
	uvs=IN_uv;
	vertexcolour= (IN_vertexcolour / 255.0) * (displaycolour / 255.0);
	gl_Position = (projectionmatrix * viewmatrix * worldmatrix  ) *  IN_position;
}

