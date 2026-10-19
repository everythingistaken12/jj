uniform sampler2D diffusetexture;

varying vec2 uvs;
varying vec4 vertexcolour;

void main() 
{
	gl_FragColor = vertexcolour;
	//gl_FragColor.a=1.0f;
}
