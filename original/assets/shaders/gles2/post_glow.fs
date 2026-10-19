#ifdef GL_ES
precision highp int;
precision highp float;
#endif

uniform sampler2D DiffuseMap;
uniform sampler2D DistanceMap;
uniform float screenWidth;
uniform float screenHeight;
uniform float strength;

uniform vec3 timeFactor;
uniform vec3 noiseScaleAndStrength;
uniform float distortionFactor;
uniform float distanceMapPower;
uniform float distanceMapAdditivePower;
uniform float distanceMapAdditiveScale;
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;

varying mediump vec2 v_uv0;
varying mediump vec2 v_uv1;

float random (vec2 _st)
{
    return fract(sin(fract(dot(_st.xy, vec2(12.9898, 78.233)))) * 43758.5453123);
}

float noise (vec2 _st) {
    vec2 i = floor(_st);
    vec2 f = fract(_st);

    // Four corners in 2D of a tile
    float a = random(i);
    float b = random(i + vec2(1.0, 0.0));
    float c = random(i + vec2(0.0, 1.0));
    float d = random(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
            (c - a)* u.y * (1.0 - u.x) +
            (d - b) * u.x * u.y;
}

#define NUM_OCTAVES 5

float fbm(vec2 _st) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    // Rotate to reduce axial bias
    mat2 rot = mat2(cos(0.5), sin(0.5),
                    -sin(0.5), cos(0.50));
    for (int i = 0; i < NUM_OCTAVES; ++i) {
        v += a * noise(_st);
        _st = rot * _st * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

void main()
{
    vec2 resolution = vec2(screenWidth, screenHeight);

    float aspect = resolution.x / resolution.y;

    vec2 st = gl_FragCoord.xy / resolution * noiseScaleAndStrength.x;

    vec3 color = vec3(0.0);

    vec2 q = vec2(0.0);
    q.x = fbm(st);
    q.y = fbm(st + vec2(1.0));

    vec2 r = vec2(0.0);

    r.x = fbm(st + 1.0*q + vec2(1.7, 9.2) + timeFactor.x);
    r.y = fbm(st + 1.0*q + vec2(8.3, 2.8) + timeFactor.y);

    float f = fbm(st + r);

    color = mix(vec3(1.0, 0.0, 0.0), color1, clamp((f * f) * 4.0, 0.0, 1.0));
    color = mix(color, color2, clamp(length(q), 0.0, 1.0));
    color = mix(color, color3, clamp(length(r.x), 0.0, 1.0));

    float c;
    float k;

    k = texture2D(DistanceMap, v_uv1).a;
    c = strength * pow(abs(k), distanceMapPower);
    k = strength * pow(abs(k), distanceMapAdditivePower) * distanceMapAdditiveScale;

    color = color * c * noiseScaleAndStrength.y;

    vec2 distortion = vec2(color.r / screenWidth, color.g / screenHeight);
    vec4 diffuse = texture2D(DiffuseMap, v_uv0 + distortion * distortionFactor);
    gl_FragColor = diffuse + vec4((f * f * f + 0.6 * f * f + 0.5 * f) * color + vec3(k), 0.0);
}
