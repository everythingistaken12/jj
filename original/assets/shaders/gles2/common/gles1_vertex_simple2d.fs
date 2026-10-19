precision lowp int; 
precision lowp float; 

uniform sampler2D DiffuseMap;

varying lowp vec4 uvs;
varying lowp vec3 worldnormal;
varying lowp vec4 vertexcolour;


void main() 
{
    gl_FragColor = texture2D(DiffuseMap, uvs.xy  )*  vertexcolour;


	//gl_FragColor.a=1.0f;
}
