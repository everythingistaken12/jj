precision lowp int; 
precision lowp float;

uniform sampler2D DiffuseMap;
uniform sampler2D textureTintTexture;

varying lowp vec4 uvs;
varying mediump vec3 normal;
varying lowp vec4 vertexColour;


void main() 
{
	lowp vec4 texSample = texture2D(DiffuseMap, uvs.xy);
	
	lowp float alpha = texSample.a * 2.0;
	lowp vec4 finalColour = vec4(texSample.r, texSample.g, texSample.b,  clamp(alpha, 0.0, 1.0));
	
	float useShader = clamp(alpha - 1.0, 0.0, 1.0);
	
	//Dependent texture read. Gasp!
	lowp float refColour = texSample.r; //Approximately the luminance.
	
	
	lowp vec4 textureTintSample = texture2D(textureTintTexture, vec2(normal.y, refColour + normal.z));
	lowp vec4 newColour = vec4(textureTintSample.r, textureTintSample.g, textureTintSample.b, 1.0);

	//Blend it in.
	finalColour = mix(finalColour, newColour, useShader);
	
		
	finalColour = finalColour * vertexColour;
	
	//boost colour
	finalColour.rgb += (finalColour.rgb * normal.x);
	
	
	gl_FragColor = finalColour;

}
