//Passed through from the VS
varying vec4 uvs;
varying vec3 worldnormal;
varying vec4 vertexcolour;
varying vec3 worldpos;



//Various uniforms ahoy
uniform sampler2D IN_texture_diffuse;

#if defined(USE_IMAGE_BASED_LIGHTING)
    uniform sampler2D IN_texture_skymap;
    
    #if defined(USE_SPECULAR)
    uniform sampler2D IN_texture_skymap_specular;
    #endif

#endif

const int MAX_SUNS = 3;

uniform vec3  IN_scene_sunlight_dir[MAX_SUNS];
uniform vec3  IN_scene_sunlight_colour[MAX_SUNS];
uniform float IN_scene_sunlight_brightness[MAX_SUNS];
uniform vec3  IN_scene_sunlight_specularcolour[MAX_SUNS];


uniform vec3 IN_scene_eye_pos;
uniform vec3 IN_scene_eye_dir;
uniform float IN_scene_ambientscale;

uniform float IN_material_specpow;
uniform float IN_material_speclevel;
uniform float IN_material_ambientscale;

uniform vec3  IN_material_ambientcolour;



//vec3 g_diffuseAccumulation = vec3(0.0,0.0,0.0);
//vec3 g_specularAccumulation = vec3(0.0,0.0,0.0);
//vec4 g_finalColour = vec4(0.0 , 0.0 , 0.0, 0.0);



#if defined(USE_IMAGE_BASED_LIGHTING)
vec2 DoImageBasedLighting(vec3 normal)
{
    return vec2( ((atan(normal.z,normal.x) * 0.1591549430))+0.5  , (-normal.y * 0.5) +0.5);
}

#if defined(USE_SPECULAR)
vec2 DoImageBasedSpecular(vec3 reflect)
{   
	return vec2(  ((atan(reflect.z,reflect.x) * 0.1591549430))+0.5 ,  (-reflect.y * 0.5) +0.5 );
}
#endif
#endif

void main() 
{
   
#if defined(USE_DIFFUSE_TEXTURE)

   vec4 diffuseSample = texture2D(IN_texture_diffuse, uvs.xy);
   vec4 diffuse= diffuseSample * vertexcolour;
#else
   vec4 diffuse= vertexcolour;
#endif


#if defined(USE_IMAGE_BASED_LIGHTING)
	
    //dependent texture reads are bad
    vec2 lightUV = DoImageBasedLighting(worldnormal);
    vec3 diffuseAccumulation = texture2D(IN_texture_skymap, lightUV).xyz;

#if defined(USE_SPECULAR)
    //dependent texture reads and a bunch of normalizes are bad too!
    vec3 reflectVector = -normalize( reflect( normalize(IN_scene_eye_pos - worldpos), worldnormal ));
    vec2 specularLightUV = DoImageBasedSpecular(reflectVector);
    vec3 specularAccumulation = texture2D(IN_texture_skymap_specular, specularLightUV).xyz * IN_material_speclevel;
#endif
#endif



    //Gather
#if defined(USE_IMAGE_BASED_LIGHTING)
#if defined(USE_SPECULAR)
    gl_FragColor.xyz = (diffuse.xyz * diffuseAccumulation) + specularAccumulation;
#else
    gl_FragColor.xyz = (diffuse.xyz * diffuseAccumulation);
#endif
#else
    gl_FragColor.xyz = diffuse.xyz;
#endif 
    
    
    
  //fs  gl_FragColor.xyz =  texture2D( IN_texture_diffuse, uvs.xy).xyz;
    
    gl_FragColor.w = diffuse.w;

    
}
