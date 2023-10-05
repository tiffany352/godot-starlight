shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,shadows_disabled,ambient_light_disabled,skip_vertex_transform,unshaded;


uniform sampler2D texture_emission : hint_default_black;
uniform float emission_energy;
uniform float billboard_size_deg : hint_range(0, 90) = 90;
uniform float min_size_ratio : hint_range(0, 1.0) = 1.0;
uniform float max_luminosity;
uniform float meters_per_lightyear = 100.0;
uniform float distance_limit = 1.0;
uniform float camera_vertical_fov = 70;
uniform bool debug_show_rects = false;


varying vec3 STAR_COLOR;


const float luminosity_sun = 3.846e26;
const float lightyear_length = 9.460730e15;


void vertex() {
	// Find distance from camera
	float dist = -(MODELVIEW_MATRIX * vec4(vec3(0.0), 1.0)).z;
	dist = max(dist, distance_limit);
	// Use lightyear scaling ratio, then convert back to meters.
	highp float dist_adj = dist * (lightyear_length / meters_per_lightyear);

	highp float dimming = 1.0 / (dist_adj * dist_adj);
	// Combine these first because one is very large and one is very small.
	highp float emission = luminosity_sun * dimming;
	float luminosity = INSTANCE_CUSTOM.r * emission_energy * emission;
	STAR_COLOR = COLOR.rgb * luminosity;

	// Next do cropping, which is important for performance. Otherwise rendering thousands of PSF textures overlapping will create tons of overdraw.
	// The idea here is that the PSF texture is not scaled down, instead it's cropped towards the center, based on how bright we expect it to be.
	// Values towards the edges are extremely dim, so if the luminance is not high then they will round to zero.
	float size = mix(min_size_ratio * billboard_size_deg, billboard_size_deg, clamp(luminosity / max_luminosity, 0.0, 1.0));
	float crop = size / billboard_size_deg;
	UV = (UV - vec2(0.5)) * crop + vec2(0.5);

	// Billboard rotation locking.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	// Use zero instead of VERTEX position because we want to position the quad in clip space instead.
	vec3 modelview_pos = (MODELVIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;

	// Do actual perspective projection.
	vec4 projected = PROJECTION_MATRIX * vec4(modelview_pos, 1.0);
	// Figure out the scaling to use in clip space so that we can measure in degrees instead of device pixels.
	vec2 one_degree = vec2(1.0, VIEWPORT_SIZE.x / VIEWPORT_SIZE.y) / camera_vertical_fov;
	// Offset the projected position to form the quad.
	POSITION = projected + vec4(VERTEX.xy * projected.w * size * one_degree, 0.0, 0.0);
	// Force Z value to far clip plane so that it will always render behind everything else.
	// This also prevents it being clipped, which lets stars be seen from much further away than the camera far plane would normally allow.
	POSITION.z = 1.0 * projected.w;
}


vec3 to_srgb(vec3 linearRGB)
{
    bvec3 cutoff = lessThan(linearRGB, vec3(0.0031308));
    vec3 higher = vec3(1.055)*pow(linearRGB, vec3(1.0/2.4)) - vec3(0.055);
    vec3 lower = linearRGB * vec3(12.92);

    return vec3(mix(higher, lower, cutoff));
}


void fragment() {
	vec3 emission_tex = texture(texture_emission, UV).rgb;
	vec3 color = STAR_COLOR * emission_tex;
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
