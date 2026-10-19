precision lowp int; 
precision lowp float;

uniform sampler2D DiffuseMap;
uniform float OverrideColour;

varying lowp vec4 uvs;
varying lowp vec3 worldnormal;
varying lowp vec4 vertexcolour;

void main() 
{
    lowp vec4 fragCol = texture2D(DiffuseMap, uvs.xy) *  vertexcolour;

	vec3 col = fragCol.xyz + ( fragCol.xyz * OverrideColour );
    gl_FragColor = vec4( col.x , col.y , col.z , fragCol.a );

}
