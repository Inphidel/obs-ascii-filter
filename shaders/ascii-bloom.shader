// ASCII bloom for obs-shaderfilter.
// Glyphs are 16x16 bitmaps rasterized from DejaVu Sans Mono Bold.
// OpenGL and Direct3D want different array syntax. OBS defines OPENGL on that renderer.
// Background opacity 0 keeps the letters and the glow, and drops the black.

uniform texture2d previous_output;

uniform string note <
    string widget_type = "info";
> = "These sliders color the ASCII letters. Camera brightness and exposure are on the ASCII Camera source, Properties, under Camera Controls. Pick the camera there, on Device.";

uniform int cell_size <
    string label = "Cell size";
    string group = "Glyphs";
    string widget_type = "slider";
    int minimum = 8;
    int maximum = 48;
    int step = 1;
> = 18;

uniform float contrast <
    string label = "Contrast";
    string group = "Glyphs";
    string widget_type = "slider";
    float minimum = 0.40;
    float maximum = 3.00;
    float step = 0.01;
> = 1.35;

uniform float brightness <
    string label = "Brightness";
    string group = "Glyphs";
    string widget_type = "slider";
    float minimum = -0.40;
    float maximum = 0.40;
    float step = 0.01;
> = 0.02;

uniform float gamma <
    string label = "Gamma";
    string group = "Glyphs";
    string widget_type = "slider";
    float minimum = 0.40;
    float maximum = 2.20;
    float step = 0.01;
> = 0.85;

uniform bool invert <
    string label = "Invert";
    string group = "Glyphs";
> = false;

uniform float bloom_strength <
    string label = "Amount";
    string group = "Bloom";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 2.00;
    float step = 0.01;
> = 1.05;

uniform float bloom_radius <
    string label = "Radius";
    string group = "Bloom";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 28.0;
    float step = 0.1;
> = 11.0;

uniform float bloom_threshold <
    string label = "Cutoff";
    string group = "Bloom";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.80;
    float step = 0.01;
> = 0.12;

uniform float glyph_hue <
    string label = "Hue";
    string group = "Color";
    string widget_type = "slider";
    float minimum = -180.0;
    float maximum = 180.0;
    float step = 1.0;
> = 0.0;

uniform float glyph_saturation <
    string label = "Saturation";
    string group = "Color";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 2.50;
    float step = 0.01;
> = 1.0;

uniform float color_amount <
    string label = "Camera tint";
    string group = "Color";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 0.82;

uniform float4 ink_color <
    string label = "Ink color";
    string group = "Color";
> = {1.0, 0.95, 0.88, 1.0};

uniform float ink_gain <
    string label = "Ink brightness";
    string group = "Color";
    string widget_type = "slider";
    float minimum = 0.30;
    float maximum = 2.00;
    float step = 0.01;
> = 1.10;

uniform float chroma <
    string label = "Color fringe";
    string group = "Color";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 8.0;
    float step = 0.1;
> = 1.4;

uniform float trail <
    string label = "Trail";
    string group = "Color";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 0.80;
    float step = 0.01;
> = 0.20;

uniform float4 background <
    string label = "Background";
    string group = "Color";
> = {0.0, 0.0, 0.0, 1.0};

uniform float background_opacity <
    string label = "Background opacity";
    string group = "Color";
    string widget_type = "slider";
    float minimum = 0.0;
    float maximum = 1.0;
    float step = 0.01;
> = 1.0;

// 12 glyphs, light to dense. Each glyph is 16x16, stored as 8 signed words.
int glyph_word(int gi, int w)
{
    int i = clamp(gi, 0, 11) * 8 + clamp(w, 0, 7);
#ifdef OPENGL
    const int[96] words = int[96](
#else
    const int words[96] = {
#endif
        0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 25165824, 384, 0, 0, 0,
        0, 0, 62914560, 62915520, 0, 0, 0, 0,
        0, 0, 25166208, 384, 25165824, 25166208, 0, 0,
        0, 0, 25166208, 0, 25166208, 29360576, 0, 0,
        0, 25165824, 132122592, 132121536, 384, 0, 0, 0,
        0, 0, 25166208, 267387264, 25169904, 16777600, 0, 0,
        0, 0, 132122208, 62915520, 130024384, 106956768, 0, 0,
        0, 0, 132121536, 241174496, 132124256, 62916576, 0, 0,
        0, 125829120, 132122496, 132124640, 133171168, 65013728, 352, 0,
        0, 130023680, 267388640, 217059248, 263195888, 81793008, 16779200, 0,
        2147352576, 2147385342, 2147385342, 2147385342, 2147385342, 2147385342, 2147385342, 32766
#ifdef OPENGL
    );
#else
    };
#endif
    return words[i];
}

float bit_at(int gi, int x, int y)
{
    if (x < 0 || y < 0 || x > 15 || y > 15)
        return 0.0;
    int index = y * 16 + x;
    int w = int(floor(float(index) / 32.0));
    int s = index - w * 32;
    int n = glyph_word(gi, w);
    return float((n >> s) & 1);
}

float glyph_mask(int gi, float2 local)
{
    float2 g = local * 16.0 - 0.5;
    int x0 = int(floor(g.x));
    int y0 = int(floor(g.y));
    float fx = g.x - floor(g.x);
    float fy = g.y - floor(g.y);
    float top = lerp(bit_at(gi, x0, y0), bit_at(gi, x0 + 1, y0), fx);
    float bot = lerp(bit_at(gi, x0, y0 + 1), bit_at(gi, x0 + 1, y0 + 1), fx);
    return smoothstep(0.08, 0.72, lerp(top, bot, fy));
}

float tone_of(float3 cam)
{
    float y = dot(cam, float3(0.2126, 0.7152, 0.0722));
    y = clamp((y - 0.5) * contrast + 0.5 + brightness, 0.0, 1.0);
    y = pow(max(y, 0.001), gamma);
    if (invert)
        y = 1.0 - y;
    return clamp(y, 0.0, 1.0);
}

int glyph_index(float y)
{
    // Stop at @. The last bitmap is a solid tile, and it turns highlights into bricks.
    return clamp(int(floor(y * 10.999)), 0, 10);
}

float3 ink_of(float3 cam)
{
    float peak = max(cam.r, max(cam.g, cam.b));
    float3 hue = cam / max(peak, 0.04);
    float3 bright = lerp(float3(1.0, 1.0, 1.0), hue, 0.92);
    return lerp(ink_color.rgb, bright, clamp(color_amount, 0.0, 1.0)) * ink_gain;
}

float3 cross3(float3 a, float3 b)
{
    return float3(a.y * b.z - a.z * b.y, a.z * b.x - a.x * b.z, a.x * b.y - a.y * b.x);
}

float3 grade(float3 c)
{
    float lum = dot(c, float3(0.2126, 0.7152, 0.0722));
    c = lerp(float3(lum, lum, lum), c, glyph_saturation);
    float a = glyph_hue * 0.01745329252;
    float s = sin(a);
    float co = cos(a);
    float3 axis = float3(0.57735026919, 0.57735026919, 0.57735026919);
    return c * co + cross3(axis, c) * s + axis * dot(axis, c) * (1.0 - co);
}

float3 camera_cell(float2 cell_id, float cell)
{
    float2 center = (cell_id + 0.5) * cell / uv_size;
    float2 d = (cell * 0.22) / uv_size;
    float3 c = image.Sample(textureSampler, center + float2(-d.x, -d.y)).rgb;
    c += image.Sample(textureSampler, center + float2(d.x, -d.y)).rgb;
    c += image.Sample(textureSampler, center + float2(-d.x, d.y)).rgb;
    c += image.Sample(textureSampler, center + float2(d.x, d.y)).rgb;
    return c * 0.25;
}

float neighbor_glow(float2 px, float2 cell_id, float cell)
{
    float2 center = (cell_id + 0.5) * cell;
    float reach = cell * 0.45 + bloom_radius;
    float dist = length(px - center);
    float fall = smoothstep(reach, cell * 0.15, dist);
    float3 cam = image.Sample(textureSampler, center / uv_size).rgb;
    return max(tone_of(cam) - bloom_threshold, 0.0) * fall;
}

float4 mainImage(VertData v_in) : TARGET
{
    float cell = max(float(cell_size), 6.0);
    float2 px = v_in.uv * uv_size;
    float2 cell_id = floor(px / cell);
    float2 local = (px - cell_id * cell) / cell;

    float3 cam = camera_cell(cell_id, cell);
    float tone = tone_of(cam);
    int gi = glyph_index(tone);
    float mask = glyph_mask(gi, local);
    float3 ink = ink_of(cam);

    float spread = clamp(bloom_radius / cell, 0.0, 1.6) * 0.18;
    float wide = glyph_mask(gi, local + float2(spread, 0.0));
    wide += glyph_mask(gi, local + float2(-spread, 0.0));
    wide += glyph_mask(gi, local + float2(0.0, spread));
    wide += glyph_mask(gi, local + float2(0.0, -spread));
    wide *= 0.25;
    float letter_glow = max(wide - mask, 0.0);

    float halo = 0.0;
    if (bloom_strength > 0.001 && bloom_radius > 0.1) {
        halo += neighbor_glow(px, cell_id + float2(1.0, 0.0), cell);
        halo += neighbor_glow(px, cell_id + float2(-1.0, 0.0), cell);
        halo += neighbor_glow(px, cell_id + float2(0.0, 1.0), cell);
        halo += neighbor_glow(px, cell_id + float2(0.0, -1.0), cell);
        halo *= 0.35;
    }

    float shift = chroma * uv_pixel_interval.x;
    float2 center_uv = (cell_id + 0.5) * cell / uv_size;
    float3 ink_r = ink_of(image.Sample(textureSampler, center_uv + float2(shift, 0.0)).rgb);
    float3 ink_b = ink_of(image.Sample(textureSampler, center_uv - float2(shift, 0.0)).rgb);
    float3 fringe = float3(ink_r.r, ink.g, ink_b.b);

    float3 glow = grade(fringe) * (letter_glow + halo) * bloom_strength;
    float3 sharp = lerp(background.rgb, grade(ink), mask);
    float3 color = min(sharp + glow, float3(1.0, 1.0, 1.0));

    float3 prev = previous_output.Sample(textureSampler, v_in.uv).rgb;
    color = lerp(color, prev, clamp(trail, 0.0, 0.80));

    float glow_a = clamp((letter_glow + halo) * bloom_strength * 1.6, 0.0, 1.0);
    float alpha = lerp(background_opacity, 1.0, clamp(max(mask, glow_a), 0.0, 1.0));
    return float4(color, alpha);
}
