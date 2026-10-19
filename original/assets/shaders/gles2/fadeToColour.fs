precision lowp int; 
precision lowp float;

uniform sampler2D DiffuseMap;
uniform vec4 OverrideColour;

varying lowp vec4 uvs;
varying lowp vec3 worldnormal;
varying lowp vec4 vertexcolour;

void main() 
{
    lowp vec4 fragCol = texture2D(DiffuseMap, uvs.xy) *  vertexcolour;

    vec3 col = mix(fragCol.xyz , OverrideColour.xyz , OverrideColour.a);
    gl_FragColor = vec4( col.x , col.y , col.z , fragCol.a );

	//gl_FragColor.a=1.0f;
}
