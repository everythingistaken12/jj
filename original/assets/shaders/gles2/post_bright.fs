precision lowp int; 
precision lowp float;

uniform sampler2D DiffuseMap;

varying mediump vec4 uvs0;
varying mediump vec4 uvs1;
varying mediump vec4 uvs2;
varying mediump vec4 uvs3;

uniform mediump float clip;

void main() 
{
	vec4 rgb = (texture2D(DiffuseMap, uvs0.xy) * 0.25) +
			(texture2D(DiffuseMap, uvs1.xy) * 0.25) +
			(texture2D(DiffuseMap, uvs2.xy) * 0.25) +
			(texture2D(DiffuseMap, uvs3.xy) * 0.25);

	float lum = (0.333 * rgb.x) + (0.333 * rgb.y) + (0.333 * rgb.z);
	
	float fraction = ceil( clamp(lum-clip, 0.0, 1.0) );

	gl_FragColor.xyz = rgb.xyz * fraction;
	gl_FragColor.a = 1.0;
}
