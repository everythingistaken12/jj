#ifdef GL_ES
precision highp float;
#endif

const float pi = 3.1415926535;

uniform sampler2D DiffuseMap;
uniform vec3 resolutionAndAspect;
uniform float strength;
uniform float alphaPower;
uniform float uvFactor;

varying mediump vec2 v_uv;

#define COLOR1 vec3(0.28, 0.21, 0.53)
#define COLOR2 vec3(0.71, 0.39, 2)

void main()
{
    vec2 uv = v_uv;
    uv.x *= resolutionAndAspect.z;

    vec2 center = vec2(0.5 * resolutionAndAspect.z, 0.5);

    float dd = distance(uv, center);
    float dd2 = pow(1.0 - dd, 5.0);
    float dd3 = pow(dd * dd2 * 18.0, 3.0);

    uv = uv - center;

    float d = length(uv) ;
    float a = atan(uv.x, uv.y);
    a = a / (2.0 * pi) + 0.5;
    uv = vec2(d * uvFactor, a);

    vec4 noise = texture2D(DiffuseMap, uv);
    float alpha = strength * noise.x * dd3;
    vec3 color = mix(COLOR1, COLOR2, pow(alpha, alphaPower));
    gl_FragColor = vec4(color, alpha);
}
