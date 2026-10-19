precision lowp int; 
precision lowp float;

uniform sampler2D DiffuseMap;

varying lowp vec4 uvs;
varying mediump vec3 normal;
varying lowp vec4 vertexColour;


void main() 
{
    lowp vec4 fragCol = texture2D(DiffuseMap, uvs.xy) *  vertexColour;

	mediump vec3 col = fragCol.xyz + normal;
    gl_FragColor = vec4( col.x , col.y , col.z , fragCol.a );

}
