precision lowp int; 
precision lowp float;

uniform sampler2D DiffuseMap;

varying mediump vec2 uv;

uniform mediump float velocity;
uniform mediump float gamma;
uniform mediump float rgamma;
uniform mediump float eyeX;
uniform mediump float eyeY;
uniform mediump float reverseAspectRatio;
uniform mediump float horizontalOffset;
uniform mediump float time;

// all wavelengths are offsets from the blue
const float WL_G = 0.17058537870138357; // (log(640) - log(455)) * 0.5
const float WL_R = 0.34117075740276714; // log(640) - log(455)
const float WL_I = 9.208270595949712; // acos(-1.0) * 0.5 / (WL_G)
const float ATAN_NORM = -0.3183098861837907; // -1.0 / acos(-1.0)

// TUNING:  consts
const float DOPPLER_POWER = 1.7;
const float DOPPLER_ADDITIONAL_SHIFT = 0.05;
const float DOPPLER_VELOCITY_THRESHOLD = 10.0;
const float MASK_CURVATURE1 = 2.0;
const float MASK_OFFSET1 = -1.5;
const float MASK_SHARPNESS1 = 5.0;
const float MASK_CURVATURE2 = 2.0;
const float MASK_OFFSET2 = 0.2;
const float MASK_SHARPNESS2 = 25.0;
const float OPACITY_MIN = 0.4;
const float OPACITY_DELTA = 0.45;

vec3 toRgb(in float wl) {
    float red = 0.0;
    float wl_r = wl - WL_R;
    if (abs(wl_r) < WL_G)
        red = cos(wl_r * WL_I);
    float blue = 0.0;
    if (abs(wl) < WL_G)
        blue = cos(wl * WL_I);
	red *= red;
	blue *= blue;
    float green = 0.0;
    if (0.0 < wl && wl < WL_R)
        green = 1.0 - red - blue;
    return vec3(red, green, blue);
}

vec4 star(
    const in vec2 uv,
    const in float SPEED_BASE,
    const in float SPEED_DELTA,
    const in float WHITE_BASE,
    const in float WHITE_DELTA,
    const in float LEN
) {
    float speedRnd = mod(mod(uv.y * 1.27935, 0.17) * 9.9, 0.435) * 2.3; // rnd(y) [0; 1)
    float speed = speedRnd * SPEED_DELTA + SPEED_BASE;
    float start = mod(exp(mod(uv.y * 1.82354, 0.13) * 5.7), 0.19) * 5.25; // rnd(y) [0; 1)
    float offset = fract((time + uv.x * speed) * 0.25);
    float d = fract(start - offset + 1.0);
    float color = 0.0;
    float val = d / LEN * speed;
    if (val > 1.0)
        return vec4(0.0);
    float opacity = val * speedRnd * (1.0 - speedRnd) * 4.0;
    float whiteRnd = mod(uv.y * 1.43825, 0.27) * 3.7; // rnd(y) [0; 1)
    float white = whiteRnd * WHITE_DELTA + WHITE_BASE;
    return vec4(vec2(white), 1.0, opacity);
}

void main() 
{
	vec2 off = uv - vec2(eyeX, eyeY);
	off.y *= reverseAspectRatio;
	float ol = max(length(off), 0.01);

	float xs2 = gamma * (off.x - velocity * ol);
	vec2 pos1 = vec2(eyeX + xs2 + horizontalOffset, 1.0 - uv.y);
	vec3 col = texture2D(DiffuseMap, pos1).rgb;
	
	// TUNING: comment out next two lines to disable stars in background. Also feel free to play with constants here
	vec4 star1 = star(pos1, 0.4 / velocity, 0.2 / velocity, 0.4, 0.4, 0.03);
	col = mix(col, star1.rgb, star1.a * 0.4);

	float lambdaRelation = rgamma * (1.0 - velocity * off.x / ol);
    float k = log(lambdaRelation) * DOPPLER_POWER + DOPPLER_ADDITIONAL_SHIFT * min(1.0, velocity * DOPPLER_VELOCITY_THRESHOLD);
	vec3 changedColor = toRgb(WL_R + k) * col.r + toRgb(WL_G + k) * col.g + toRgb(k) * col.b;

	// TUNING: choose one line for mask curvature orientation, comment out the other one
	// float opacity = OPACITY_MIN + OPACITY_DELTA * (atan((ol + off.x * MASK_CURVATURE1 + MASK_OFFSET1) * MASK_SHARPNESS1) * ATAN_NORM + 0.5);
	float opacity = OPACITY_MIN + OPACITY_DELTA * (-atan((ol - off.x * MASK_CURVATURE2 - MASK_OFFSET2) * MASK_SHARPNESS2) * ATAN_NORM + 0.5);

	col = mix(col, changedColor, opacity);
	// TUNING: comment out next two lines to disable stars in foreground. Also feel free to play with constants here
	vec4 star2 = star(uv, 0.1 / velocity, 0.2 / velocity, 0.6, 0.3, 0.03);
	col = mix(col, star2.rgb, star2.a * 0.7);

	gl_FragColor.rgb = col;
	gl_FragColor.a = 1.0;
}
