
precision lowp int; 
precision lowp float; 


//Passed through from the VS
varying mediump vec4 uvs;
varying lowp vec3 worldnormal;
varying lowp vec4 vertexcolour;
varying lowp vec3 viewdirection;
varying mediump vec4 position;

//Various uniforms ahoy
uniform sampler2D IN_texture_diffuse;

uniform mediump float zfar;

#if defined(USE_TOON_SHADING)
uniform sampler2D IN_texture_toon;
uniform vec3 IN_toon_dir;
#endif

#if defined(USE_GLOSS_MAP)
uniform sampler2D IN_texture_glossMap;
#endif

#if defined(USE_TERRAIN_BLENDING)
uniform sampler2D IN_texture_secondDiffuse;
#endif
    
#if defined(USE_SPECULAR)
uniform sampler2D IN_texture_skymap_specular;

#if defined(USE_SPECULAR_SKIPPING)
uniform mediump vec3 IN_material_model_origin;
#endif 

uniform mediump float IN_material_specpow;
uniform lowp float IN_material_speclevel;
uniform lowp vec3 IN_material_speccolour;
uniform lowp vec3 IN_material_specdir;
#endif



uniform mediump vec3 IN_scene_eye_pos;
uniform lowp vec3 IN_scene_eye_dir;
uniform lowp float IN_scene_ambientscale;



#if defined(USE_RIM_SHADING)

uniform lowp float IN_material_rimscale;
uniform mediump float IN_material_rimpower;
uniform lowp vec3 IN_material_rimcolour;
#endif

#if defined(USE_PP_LIGHTING)

uniform mediump vec3 IN_omnilight_colour[ OMNILIGHT_COUNT ];
uniform mediump float IN_omnilight_radius[ OMNILIGHT_COUNT ];
varying mediump vec3 omniLightDir[ OMNILIGHT_COUNT ];

#endif



lowp float Polar(lowp float x, lowp float y)
{
    lowp float top = float(y > 0.0);
    lowp float right = float(x > 0.0);
    lowp float bottom = float(0.0 >= y);
    lowp float left = float(0.0 >= x);

    lowp float yy = y * 0.25;

    lowp float quad0  = yy * top * right;
    lowp float quad1 =  (0.5 -yy) * top * left;
    lowp float quad2  = (0.5 -yy) * bottom * left;
    lowp float quad3 =  (1.0 + yy) * bottom * right;

    return quad0 + quad1 + quad2 + quad3;
}




#if defined(USE_SPECULAR)





lowp vec2 DoImageBasedSpecular(lowp vec3 reflect)
{   
	//float y = ( atan(reflect.z,reflect.x) * 0.1591549430 + 0.5);
    lowp vec2 nx = normalize(vec2(reflect.x, -reflect.z));
    return vec2( Polar(nx.x, nx.y),  (-reflect.y * 0.5) + 0.5);
}
#endif 


void main() 
{
	lowp vec3 normalizedNormal = normalize(worldnormal);  //This gets optimized out if noones using it
    lowp vec3 viewDir = normalize(viewdirection);
    

#if defined(USE_SPECULAR)
    lowp vec3 specularAccumulation = vec3(0.0, 0.0, 0.0);
    lowp float specularScale = IN_material_speclevel;
#if defined(USE_GLOSS_MAP)
    lowp vec4 glossSample = texture2D(IN_texture_glossMap, uvs.xy);
    specularScale *= glossSample.r;
#endif
#endif

#if defined(USE_DIFFUSE_TEXTURE)
 
#if defined(USE_TERRAIN_BLENDING)
	lowp vec4 diffuseSample = texture2D(IN_texture_diffuse, uvs.xy);
	lowp vec4 secondDiffuseSample = texture2D(IN_texture_secondDiffuse, uvs.xy);
	
	lowp vec4 diffuse = mix(diffuseSample, secondDiffuseSample,  secondDiffuseSample.a * vertexcolour.a) * vertexcolour;
#else
	lowp vec4 diffuseSample = texture2D(IN_texture_diffuse, uvs.xy);
	lowp vec4 diffuse = diffuseSample * vertexcolour;
#endif
  
#else
   lowp vec4 diffuse = vertexcolour;
#endif



#if defined(USE_ALPHA_TEST)
	if (diffuse.a < 0.5)
	{
		discard;
	}
#endif	

#if defined(USE_TOON_SHADING)
	lowp float dotresult = (dot(normalizedNormal, IN_toon_dir) * 0.49) + 0.5;
	lowp vec4 toonSample = texture2D(IN_texture_toon, vec2(dotresult, 0.5));
	diffuse.xyz *= toonSample.xyz;
    diffuse.a *= vertexcolour.a;
#endif

#if defined(USE_PP_LIGHTING)
    

    mediump vec3 lightAccum = vec3(0.0, 0.0, 0.0);
    mediump vec3 pointLightSpecular = vec3(0.0, 0.0, 0.0);
    
    for (int j = 0; j < OMNILIGHT_COUNT; j++)
    {
        mediump float len = length(omniLightDir[j]);
        len = max(len, 0.01);
        lowp vec3 lightDir = normalize(omniLightDir[j]);
        mediump float attenuation =  min(len, IN_omnilight_radius[j] ) / IN_omnilight_radius[j];
        attenuation *= attenuation;
        attenuation = 1.0 - attenuation;

        lightAccum += diffuse.xyz * clamp(dot( normalizedNormal, lightDir), 0.0, 1.0) * attenuation * IN_omnilight_colour[j];

   

#if defined(USE_SPECULAR_MATH) || defined(USE_SPECULAR)
     
        lowp float ref = dot(reflect(-lightDir, normalizedNormal), viewDir);
        lowp float specularValue = pow( max(0.001, ref), IN_material_specpow) * specularScale;
        specularAccumulation +=  specularValue * IN_omnilight_colour[j] * attenuation;  // * attenuation is WRONG. Specular reflections attenuate as a function of their pow (so basically, never).  But we can't have specular from all lights affect all things, so this'll do.
#endif
    }

    diffuse.xyz += lightAccum;

#endif




#if defined(USE_SPECULAR_SKIPPING) //image based with weird inputs to make it facety
    
	lowp vec3 weirdReflectVector = -normalize( reflect(-IN_material_model_origin, normalizedNormal ));
    lowp vec2 specularLightUV = DoImageBasedSpecular(weirdReflectVector);
    specularAccumulation += texture2D(IN_texture_skymap_specular, specularLightUV).xyz  * specularScale * IN_material_speccolour;

#elif defined(USE_SPECULAR_MATH)  //math based
                              
	lowp float reflectValue = dot(reflect(IN_material_specdir, normalizedNormal), viewDir);
    lowp float specularValue = pow( max(0.001, reflectValue), IN_material_specpow) * specularScale;
    specularAccumulation +=  specularValue * IN_material_speccolour;

#elif defined(USE_SPECULAR) //image based
    lowp vec3 reflectVector = reflect(normalizedNormal, viewDir); 
    lowp vec2 specularLightUV = DoImageBasedSpecular(reflectVector);
    specularAccumulation += texture2D(IN_texture_skymap_specular, specularLightUV).xyz * specularScale * IN_material_speccolour;

#endif

#if defined(USE_RIM_SHADING)
    lowp vec3 rim = pow( 1.001 - abs( dot(viewDir, normalizedNormal) ), IN_material_rimpower ) * IN_material_rimscale * IN_material_rimcolour;  // pow(0) == unhappy glsl on ipad 1
    diffuse.xyz += rim;
#endif



    //Gather

#if defined(USE_DEPTH_RENDERING)

    lowp float zed = -position.z /  zfar;

    gl_FragColor.xyz = vec3(zed,zed,zed);
#else
    #if defined(USE_SPECULAR) 
        gl_FragColor.xyz = (diffuse.xyz) + specularAccumulation;
        
    #else
        gl_FragColor.xyz = diffuse.xyz;
    #endif 
#endif
    
    gl_FragColor.w = diffuse.w;

#if defined(OVERDRAW_TEST)      
    gl_FragColor.rgba = vec4(0.05, 0.0, 0.0, 1.0);
#endif 

    
}
