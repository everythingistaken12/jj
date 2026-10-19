precision lowp int; 
precision lowp float; 

uniform sampler2D diffusetexture;

varying lowp vec2 uvs;
varying lowp vec4 vertexcolour;

void main() 
{
	gl_FragColor = vertexcolour;
#if defined(OVERDRAW_TEST)
	gl_FragColor = vec4(0.05, 0.0 ,0.0, 1.0);
#endif
}
