#ifdef GL_ES
precision highp float;
#endif

varying mediump vec2 v_uv;

uniform float screenWidth;
uniform float screenHeight;
uniform float time;
uniform sampler2D DiffuseMap;
uniform float jetpackX;
uniform float jetpackY;

uniform float disturbance;
uniform float speed;
uniform float glowFactor;
uniform float distortionFactor;
uniform vec3 glowColor;
uniform float maxSpread;
uniform float textureSharpness;

float projectSpaceToScreenSpace(float v) {
    return (v + 1.0) * screenWidth * 0.5;
}

float hash(vec2 p) {
    return 2.0 * fract(sin(dot(p, vec2(1.0, 1.0)))) - 1.0;
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f;

    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float perlin(vec2 p) {
    float v = 0.0;
    float s = 0.8;
    for (int i = 0; i < 5; i++) {
        v += s * noise(p);
        s *= disturbance;
        p *= 2.0;
    }
    return v;
}

void main() {
    vec2 resolution = vec2(screenWidth, screenHeight);

    vec2 jetpackPos = vec2(
        projectSpaceToScreenSpace(jetpackX),
        projectSpaceToScreenSpace(jetpackY)
    );
    jetpackPos += vec2(resolution.x * 0.013, 0.0);

    float aspect = resolution.x / resolution.y;
    vec2 uv = (gl_FragCoord.xy - jetpackPos) / resolution.y;
    uv.x *= aspect * textureSharpness;

    uv = vec2(uv.y, uv.x);

    float maxDistance = 2.0;
    float totalGlow = 0.0;

    for (int i = 0; i < 4; i++) {
        float offset = float(i) * 0.5;
        float noiseValue = perlin(vec2(uv.x, (time * speed) / (1.0 + offset)));

        float spreadFactor = uv.x * maxSpread;

        float wavyEffect = mix(
            0.0,
            noiseValue * spreadFactor,
            smoothstep(0.0, 0.3, uv.x)
        );

        float dist = abs(uv.y - wavyEffect);
        float falloff = exp(-sqrt(dist * 60.0));
        falloff *= step(dist, maxDistance);

        totalGlow += falloff;
    }

    float verticalFadeIn = smoothstep(0.05, 0.2, uv.x);
    float horizontalFade = 1.0 - smoothstep(0.0, 3.5, abs(uv.y));
    float bottomCutoff = smoothstep(0.5, uv.y, uv.y);

    totalGlow *= verticalFadeIn * horizontalFade * bottomCutoff;

    vec2 distortion = vec2(
        totalGlow * uv.x / screenWidth,
        totalGlow * uv.y / screenHeight
    );
    
    vec2 safeDistortion = (distortion * distortionFactor);

    vec4 prevFrame = texture2D(DiffuseMap, v_uv + safeDistortion);
    vec4 color = vec4(glowColor, 1.0);

    gl_FragColor = color * totalGlow;
}
