// Scrambled premium-channel pass for obs-shaderfilter.
// Horizontal bands slide out of sync, the way an unpaid cable channel used to.
// Put this filter under ASCII Bloom. OBS runs the filter list from top to bottom.

uniform string note <
    string widget_type = "info";
> = "Strength 0 leaves the picture alone. Place this filter under ASCII Bloom so it scrambles the letters.";

uniform float strength <
    string label = "Strength";
    string group = "Scramble";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.75;

uniform float band_size <
    string label = "Band height";
    string group = "Scramble";
    string widget_type = "slider";
    float minimum = 2.0;
    float maximum = 48.0;
    float step = 1.0;
> = 8.0;

uniform float slide <
    string label = "Slide";
    string group = "Scramble";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.45;
    float step = 0.01;
> = 0.18;

uniform float roll_speed <
    string label = "Roll";
    string group = "Scramble";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 8.0;
    float step = 0.01;
> = 1.40;

uniform float jitter <
    string label = "Line jitter";
    string group = "Scramble";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.08;
    float step = 0.001;
> = 0.012;

uniform float snow <
    string label = "Snow";
    string group = "Signal";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.60;
    float step = 0.01;
> = 0.08;

uniform float fringe <
    string label = "Color split";
    string group = "Signal";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 12.0;
    float step = 0.1;
> = 2.4;

uniform float search_bar <
    string label = "Search bar";
    string group = "Signal";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.35;

float hash11(float n)
{
    return frac(sin(n * 127.1) * 43758.5453);
}

float4 mainImage(VertData v_in) : TARGET
{
    float2 uv = v_in.uv;
    if (strength <= 0.001) {
        return image.Sample(textureSampler, uv);
    }

    float ypx = uv.y * uv_size.y;
    float band = max(band_size, 2.0);
    float band_id = floor(ypx / band);
    float line_id = floor(ypx);
    float roll = elapsed_time * roll_speed;

    // Each band has its own constant speed, so the strip glides instead of
    // holding still and then jumping to a new offset.
    float raw = hash11(band_id * 0.73) - 0.5;
    float band_dir = raw >= 0.0 ? 1.0 : -1.0;
    float band_speed = band_dir * (abs(raw) * 2.4 + 1.1);
    float wander = sin(roll * 0.65 + band_id * 0.47);
    float shift = (band_speed * roll + wander * 0.55) * slide * strength;

    float2 suv;
    suv.x = uv.x + shift + sin(line_id * 0.85 + roll * 14.0) * jitter * strength;
    suv.x = suv.x - floor(suv.x);
    suv.y = clamp(uv.y + sin(line_id * 1.7 + roll * 11.0) * jitter * strength * 0.35, 0.0, 1.0);

    float4 sample = image.Sample(textureSampler, suv);
    float split = fringe * strength * uv_pixel_interval.x;
    float r = image.Sample(textureSampler, float2(suv.x + split, suv.y) - float2(floor(suv.x + split), 0.0)).r;
    float b = image.Sample(textureSampler, float2(suv.x - split, suv.y) - float2(floor(suv.x - split), 0.0)).b;
    float3 col = float3(r, sample.g, b);

    float flake = hash11(line_id * 19.1 + uv.x * 180.0 + floor(elapsed_time * 24.0));
    col += (flake - 0.5) * snow * strength;

    float scan = frac(uv.y + elapsed_time * 0.07 * max(roll_speed, 0.2));
    float bar = smoothstep(0.08, 0.0, abs(scan - 0.5) - 0.42);
    col *= 1.0 - bar * search_bar * strength * 0.72;

    col = clamp(col, 0.0, 1.0);
    return float4(col, sample.a);
}
