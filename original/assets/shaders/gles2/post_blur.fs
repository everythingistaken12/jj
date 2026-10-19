precision lowp int; 
precision lowp float;

uniform sampler2D DiffuseMap;

varying mediump vec4 uvs0;
varying mediump vec4 uvs1;
varying mediump vec4 uvs2;
varying mediump vec4 uvs3;
varying mediump vec4 uvs4;
varying mediump vec4 uvs5;
varying mediump vec4 uvs6;

void main()
{
	//sneeky abuse of texture filtering 
	mediump vec4 acc;
	acc =   texture2D(DiffuseMap, uvs0.xy) * 0.06944444;
	acc +=  texture2D(DiffuseMap, uvs1.xy) * 0.13888888;
	acc +=  texture2D(DiffuseMap, uvs2.xy) * 0.1875;
	acc +=  texture2D(DiffuseMap, uvs3.xy) * 0.20833333;
	acc +=  texture2D(DiffuseMap, uvs4.xy) * 0.1875;
	acc +=  texture2D(DiffuseMap, uvs5.xy) * 0.13888888;
	acc +=  texture2D(DiffuseMap, uvs6.xy) * 0.06944444;

	gl_FragColor.xyz = acc.xyz;
	gl_FragColor.a = 1.0;
}

