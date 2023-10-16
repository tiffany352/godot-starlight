shader_type spatial;
render_mode blend_add,depth_draw_never,cull_front,shadows_disabled,skip_vertex_transform,unshaded;

#include "common.gdshaderinc"

uniform sampler2D texture_emission;
uniform bool clamp_output = false;
uniform bool debug_show_rects = false;


void fragment() {
	vec3 emission_tex = texture(texture_emission, UV).rgb;

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
