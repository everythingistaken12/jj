#ifdef GL_ES
precision highp float;
#endif

uniform vec3 resolutionAndAspect;

uniform float time;

float hash(vec2 p, float scale)
{
    // This is tiling part, adjusts with the scale...
    p = mod(p, scale);
    return fract(sin(fract(dot(p, vec2(27.16898, 38.90563)))) * 5151.5473453);
}

float noise(vec2 p, float scale )
{
    vec2 f;

    p *= scale;

    // Separate integer from fractional
    f = fract(p);
    p = floor(p);

    // Cosine interpolation approximation
    f = f * f * (3.0 - 2.0 * f);

    float res = mix(mix(hash(p,                  scale),
                        hash(p + vec2(1.0, 0.0), scale), f.x),
                    mix(hash(p + vec2(0.0, 1.0), scale),
                        hash(p + vec2(1.0, 1.0), scale), f.x), f.y);
    return res;
}

float fbm(vec2 p)
{
    float f = 0.0;

    // Change starting scale to any integer value
    float scale = 10.0;
    p = mod(p, scale);
    float amp   = 0.6;

    for (int i = 0; i < 5; i++)
    {
        f += noise(p, scale) * amp;
        amp *= 0.5;
        // Scale must be multiplied by an integer value
        scale *= 2.0;
    }

    // Clamp it just in case
    return min(f, 1.0);
}

void main()
{
    // gl_FragColor = vec4(1.0, 0.0, 0.0, 1.0);
    // return;

    vec2 uv = gl_FragCoord.xy / resolutionAndAspect.xy - vec2(time * 0.25, 0.0);
    uv = uv - vec2(0.5, 0.5);

    uv.x = uv.x * resolutionAndAspect.z;
    uv += vec2(sin(time * 0.7), cos(time * 0.45)) * 0.1;

    gl_FragColor = vec4(fbm(uv));
}
