precision lowp int; 
precision lowp float;

uniform sampler2D DiffuseMap;
uniform sampler2D AlphaMap;

varying lowp vec4 uvs;
varying mediump vec3 normal;
varying lowp vec4 vertexColour;

void main() 
{
    float alpha = texture2D(AlphaMap, uvs.xy).a;
    lowp vec4 fragCol = vec4(texture2D(DiffuseMap, uvs.xy).xyz, alpha) * vertexColour;

    mediump vec3 col = fragCol.xyz + normal;
    gl_FragColor = vec4(col.x , col.y , col.z , fragCol.a);
}
