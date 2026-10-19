precision lowp int; 
precision highp float;

uniform sampler2D DiffuseMap;
uniform vec4 OutlineColour;
uniform float AtlasWidth;
uniform float AtlasHeight;

varying mediump vec2 v_uv;
varying mediump vec2 v_minUv;
varying mediump vec2 v_maxUv;
varying mediump float v_borderWidth;

float clampedTexture2D(in vec2 uv)
{
    if (uv.x > v_minUv.x && uv.y > v_minUv.y
            && uv.x < v_maxUv.x && uv.y < v_maxUv.y) {
        return texture2D(DiffuseMap, uv).a;
    }
    return 0.0;
}

void main()
{
    float a = clampedTexture2D(v_uv);
    float i = step(0.5, a);

    const int md = 8;
    const int h_md = md / 2;

    float d = float(md);

    vec2 atlasSize = vec2(AtlasWidth, AtlasHeight);

    for (int x = -h_md; x != h_md; ++x)
    {
        for (int y = -h_md; y != h_md; ++y)
        {
            vec2 o = vec2(float(x), float(y));
            vec2 s = v_uv + o / atlasSize;

            float o_a = clampedTexture2D(s);
            float o_i = step(0.5, o_a);

            // arithmetic xor
            float f = step(0.5, (i - o_i) * (i - o_i));
            d = min(d, mix(d, length(o), f));
        }
    }

    d = clamp(d / float(md), 0.0, 1.0);
    d = mix(d, -d, i);
    d = d * 0.5 + 0.5;
    d = 1.0 - d;

    float outer = smoothstep(0.5 - v_borderWidth, 0.5, d);
    vec4 color = mix(vec4(0.0), OutlineColour, outer);

    float border_fade_inner = 0.01;
    float inner = smoothstep(0.5, 0.5 + border_fade_inner, d);

    color = mix(color, vec4(0.0), inner);

    gl_FragColor = vec4(color.rgb, color.a);
}
