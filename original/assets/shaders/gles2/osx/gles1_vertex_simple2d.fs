
uniform sampler2D DiffuseMap;

varying vec4 uvs;
varying vec3 worldnormal;
varying vec4 vertexcolour;


void main() 
{
    gl_FragColor = texture2D(DiffuseMap, uvs.xy  )*  vertexcolour;


	//gl_FragColor.a=1.0f;
}
