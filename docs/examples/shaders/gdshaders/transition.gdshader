// Original : Shader By Zacksly - https://zacksly.itch.io/
shader_type canvas_item;

uniform float AspectRatio = 1.5;
uniform float Diamonds = 10.0;
const float _min = -1.0;
const float _max = 1.0;
uniform float pixel_size = 0.08;

uniform float height = -1.0;
uniform bool disable_pixel;

void fragment() {

	vec3 uv_grid = fract(vec3(UV, 0.0) * vec3(AspectRatio * Diamonds, Diamonds, 0.0));
	if(! disable_pixel)uv_grid = round(uv_grid / pixel_size) * pixel_size;
	float grid = abs(uv_grid.x - 0.5) + abs(uv_grid.y - 0.5);
	vec3 raw_cam_image = vec3(UV.y + height)*1.5;
	vec3 grayscale;
	{
		float max1 = max(raw_cam_image.r, raw_cam_image.g);
		float max2 = max(max1, raw_cam_image.b);
		grayscale = vec3(max(max1, max2));
	}
	vec3 clamped;
	if( disable_pixel)
		clamped = clamp(grayscale, vec3(_min), vec3(_max));
	else
		clamped = round(clamp(grayscale, vec3(_min), vec3(_max))/0.1)*0.1;

	bool black_dot_grid = grid > dot(vec3(1.0) - clamped, vec3(0.333333));

	vec4 texture_uv = texture(TEXTURE,UV);
	vec4 grid_result = black_dot_grid? texture_uv : vec4(0.0);

	COLOR.rgb = grid_result.rgb;
	COLOR.a = grid_result.a;
}