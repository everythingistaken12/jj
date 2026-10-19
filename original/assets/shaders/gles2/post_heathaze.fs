precision lowp int;
precision lowp float;

uniform sampler2D DiffuseMap;
uniform sampler2D WarpMap;
uniform float strength;

varying mediump vec2 v_uv0;
varying mediump vec2 v_uv1;
varying mediump vec2 v_uv2;
varying mediump float v_alpha;

void main()
{
	float warpStrength = strength;
	float warpColorStrength = 0.5 * strength;
	
	vec4 warpValue = texture2D(WarpMap, v_uv1);
	vec4 warpColorValue = texture2D(WarpMap, v_uv2);

	vec2 offset = (warpValue.xy - vec2(119.0 / 255.0)) * warpStrength * v_alpha;
	vec3 diffuse = texture2D(DiffuseMap, v_uv0 + offset).xyz;
	gl_FragColor.xyz = diffuse + warpColorValue.xyz * warpColorValue.w * warpColorStrength;
	
	// gl_FragColor.xyz = diffuse;
	gl_FragColor.a = v_alpha * warpColorValue.a;

	// gl_FragColor = vec4(1.0);
	// gl_FragColor = warpValue;
	// gl_FragColor = warpColorValue;
}
