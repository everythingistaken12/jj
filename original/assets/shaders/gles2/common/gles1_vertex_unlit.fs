precision lowp int;
precision lowp float;

uniform sampler2D DiffuseMap;

varying lowp vec4 uvs;
varying lowp vec3 worldnormal;
varying lowp vec4 vertexcolour;

void main()
{
    gl_FragColor = texture2D(DiffuseMap, uvs.xy) * vertexcolour;

#if defined(OVERDRAW_TEST)
    gl_FragColor = vec4(0.05, 0.0, 0.0, 1.0);
#endif
}
