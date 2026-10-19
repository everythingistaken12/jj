precision lowp int;
precision lowp float;

uniform sampler2D DiffuseMap;
uniform sampler2D WarpMap;
uniform float strength;

varying mediump vec2 uv0;
varying mediump vec4 uv12;

void main()
{
	float warpStrength = 0.5 * strength;
	float warpColorStrength = 6.25 * strength;
	vec4 warpValue = texture2D(WarpMap, vec2(uv12.x / uv12.w, uv12.y));
	vec4 warpColorValue = texture2D(WarpMap, vec2(uv12.z / uv12.w, uv12.y));
	vec2 offset = (warpValue.xy - vec2(119.0 / 255.0)) * warpStrength;
	vec3 diffuse = texture2D(DiffuseMap, uv0.xy + offset).xyz;
	gl_FragColor.xyz = diffuse + warpColorValue.xyz * warpColorValue.w * warpColorStrength;
	//gl_FragColor.xyz = texture2D(DiffuseMap, uv0.xy).xyz;
	gl_FragColor.a = warpValue.z;

	// gl_FragColor = vec4(1.0);
	// gl_FragColor = warpValue;
	// gl_FragColor = warpColorValue;
}
