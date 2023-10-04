shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,shadows_disabled,ambient_light_disabled,skip_vertex_transform,unshaded;


uniform sampler2D texture_emission : hint_default_black;
uniform float emission_energy;
uniform float billboard_size : hint_range(0, 1024);
uniform float min_size : hint_range(0, 1024);
uniform float max_luminosity;
uniform float meters_per_lightyear = 100.0;
uniform float distance_limit = 1.0;


varying vec3 STAR_COLOR;


const float luminosity_sun = 3.846e26;
const float lightyear_length = 9.460730e15;


void vertex() {
	float dist = -(MODELVIEW_MATRIX * vec4(vec3(0.0), 1.0)).z;
	dist = max(dist, distance_limit);
	highp float dist_adj = dist * (lightyear_length / meters_per_lightyear);

	// Billboard rotation locking.
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	vec3 modelview_pos = (MODELVIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	highp float dimming = 1.0 / (dist_adj * dist_adj);
	highp float emission = luminosity_sun * dimming;
	float luminosity = INSTANCE_CUSTOM.r * emission_energy * emission;
	STAR_COLOR = COLOR.rgb * luminosity;

	float size = mix(min_size, billboard_size, clamp(luminosity / max_luminosity, 0.0, 1.0));
	float crop = size / billboard_size;
	UV = (UV - vec2(0.5)) * crop + vec2(0.5);
	vec4 projected = PROJECTION_MATRIX * vec4(modelview_pos, 1.0);
	POSITION = projected + vec4(VERTEX.xy * projected.w * size / VIEWPORT_SIZE, 0.0, 0.0);
	POSITION.z = 0.0;
}


vec3 aces_transform(vec3 x) {
	float a = 2.51f;
	float b = 0.03f;
	float c = 2.43f;
	float d = 0.59f;
	float e = 0.14f;
	return clamp((x*(a*x+b))/(x*(c*x+d)+e), 0.0, 1.0);
}


void fragment() {
	vec3 emission_tex = texture(texture_emission, UV).rgb;
	ALBEDO = clamp(STAR_COLOR * emission_tex, 0.0, 1.0);
	if (ALBEDO.x < 0.001 || ALBEDO.y < 0.001 || ALBEDO.z < 0.001)
		discard;
	//ALBEDO = vec3(0, 0, 0.1);
	DEPTH = 1.0;
}
