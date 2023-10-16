shader_type spatial;
render_mode blend_add,depth_draw_never,cull_front,shadows_disabled,skip_vertex_transform,unshaded;

#include "common.gdshaderinc"

uniform sampler2D texture_emission;
uniform bool clamp_output = false;
// defines how sharp vs blurry the psf will be
uniform float falloff_offset : hint_range(0.0, 1.0) = 0.0;
uniform bool debug_show_rects = false;


void fragment() {
	vec2 size = vec2(textureSize(texture_emission, 0));

	// pixel-art antialiasing method from https://www.youtube.com/watch?v=d6tp43wZqps
	vec2 box_size = clamp(fwidth(UV) * size, 1.0e-5, 1.0);
	vec2 tx = UV * size - 0.5 * box_size;
	vec2 tx_offset = smoothstep(vec2(1.0) - box_size, vec2(1.0), fract(tx));
	vec2 uv = (floor(tx) + 0.5 + tx_offset) / size;

	// dist^2 falloff from the center of the texture is needed for hand-authored psf textures to
	// work, they are too high dynamic range otherwise
	vec2 centered_uv = floor(uv * size) - size * 0.5;
	float falloff = dot(centered_uv, centered_uv) + falloff_offset;
	vec3 emission_tex = texture(texture_emission, uv).rgb / falloff;

	vec3 color = STAR_COLOR * emission_tex;
	if (clamp_output)
		color = clamp(color, 0.0, 1.0);

	// Useful when debugging min_size_deg/max_luminance:
	if (debug_show_rects)
		color += vec3(0.1);

	// In compatibility renderer we need to convert to sRGB manually.
	// Otherwise the result will look washed out.
	if (OUTPUT_IS_SRGB)
		color = to_srgb(color);

	if (color.x < 0.001 && color.y < 0.001 && color.z < 0.001)
		discard;

	ALBEDO = color;
}
