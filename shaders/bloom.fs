extern vec2 IMAGE_SIZE;
extern int RADIUS = 5; // radius of the glow
extern int SAMPLES = 3; // number of samples to use in each axis extent, proportional to quality and and inversely proportional to performance
extern float GLOW = 5.0; // amount of glow effect to apply

vec4 effect(vec4 color, Image texture, vec2 texture_coordinate, vec2 screen_coordinate)
{
    int side_length = SAMPLES * 2 + 1;
    vec4 source = Texel(texture, texture_coordinate);
    vec4 sum = vec4(0);
    vec2 blur_factor = vec2(RADIUS / SAMPLES) / IMAGE_SIZE;
    for (int x = -SAMPLES; x <= SAMPLES; x ++)
    {
        for (int y = -SAMPLES; y <= SAMPLES; y ++)
        {
            vec2 offset = vec2(x, y) * blur_factor;
            vec4 texel = Texel(texture, texture_coordinate + offset);
            int x1 = x < 1 ? x - 1 : x + 1, y1 = y < 1 ? y - 1 : y + 1;
            sum += texel / (x1 * x1 + y1 * y1);
        }
    }
    return source + vec4(sum.rgb * GLOW, 0);
}