precision mediump int; 
precision mediump float; 


//Passed through from the VS
varying vec2 uvs;
varying vec3 worldnormal;
varying vec4 vertexcolour;
varying vec3 worldpos;


//Various uniforms ahoy
uniform sampler2D IN_texture_diffuse;
uniform sampler2D IN_texture_skymap;
uniform sampler2D IN_texture_skymap_specular;


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
uniform vec3  IN_material_colour;
uniform vec3  IN_material_ambientcolour;


vec3 DoImageBasedLighting(vec3 reflect, vec3 normal, float specLevel,  out vec3 specular)
{
    vec3 lighting=vec3(0,0,0);
    
    vec2  uv;
    uv.x = ((atan(normal.y,normal.x) * 0.1591549430))+0.5; //1/2pi
    uv.y = (-normal.z * 0.5) +0.5;

    lighting += texture2D( IN_texture_skymap, uv ).xyz;

    uv.x = ((atan(reflect.y,reflect.x) * 0.1591549430))+0.5; //1/2pi
    uv.y = (-reflect.z * 0.5) +0.5;

    specular += texture2D( IN_texture_skymap_specular, uv ).xyz * specLevel;

    return lighting;

}


vec3 DoLighting(vec3 reflectionVec, vec3 normal,float specPow, float specLevel,  out vec3 specular )
{
    //Suns
    vec3 lighting=vec3(0,0,0);
    
    for (int j=0;j< MAX_SUNS ;j++)
    {
        
        float brightness =  IN_scene_sunlight_brightness[j];
        float specBrightness =  specLevel * brightness;

        lighting += IN_scene_sunlight_colour[j] * clamp( dot( -IN_scene_sunlight_dir[j],worldnormal),0.0,1.0) *  brightness; 
    
    
    	float reflectVal = dot(normal,reflectionVec);	
			
		specular+= (  pow(clamp(reflectVal,0.0,1.0 ), specPow  ) *  IN_scene_sunlight_specularcolour[j]  ) * specBrightness;
		//Vec3 Spec =  ((g_SunSpec[j].rgb*pow(saturate(ReflectVal), g_FixedSpecular ))*  (NormalEncoded.a * g_SpecMul) );
    
    }    
    return lighting;

}


void main() 
{
    
    vec4 diffuseSample = texture2D( IN_texture_diffuse, uvs);

    vec3 diffuse= diffuseSample.xyz * IN_material_colour * vertexcolour.xyz;
    vec3 specular=vec3(0,0,0);
    
    vec3 normal = normalize(worldnormal);


    vec3 ref  = -normalize( reflect( normalize( IN_scene_eye_pos - worldpos ), normal ));

    
    vec3 lighting = DoImageBasedLighting( ref  , normal  ,IN_material_speclevel, specular   );
    lighting += DoLighting( ref, worldnormal, IN_material_specpow , IN_material_speclevel , specular );
    
    gl_FragColor.xyz = (lighting * diffuse) + specular;
    gl_FragColor.w= diffuseSample.w * vertexcolour.w;
}
