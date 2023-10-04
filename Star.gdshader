shader_type spatial;
render_mode blend_add,depth_draw_opaque,cull_disabled,diffuse_burley,specular_schlick_ggx,shadows_disabled,ambient_light_disabled,skip_vertex_transform,unshaded;
uniform sampler2D texture_emission : hint_default_black;
uniform float emission_energy;
uniform float billboard_size : hint_range(0, 1024);
uniform float min_size : hint_range(0, 1024);
uniform float max_luminosity;
uniform float dimming_multiplier;
uniform float depth_value = 1e3;

varying vec3 STAR_COLOR;


void vertex() {
	// Billboard rotation locking.
	float dist = -(MODELVIEW_MATRIX * vec4(vec3(0.0), 1.0)).z;
	MODELVIEW_MATRIX = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
	vec3 modelview_pos = (MODELVIEW_MATRIX * vec4(vec3(0.0), 1.0)).xyz;
	float dimming = dimming_multiplier / (dist * dist);
	float luminosity = INSTANCE_CUSTOM.r * emission_energy * dimming;
	STAR_COLOR = COLOR.rgb * luminosity;
	float size = mix(min_size, billboard_size, clamp(luminosity / max_luminosity, 0.0, 1.0));
	float crop = size / billboard_size;
	UV = (UV - vec2(0.5)) * crop + vec2(0.5);
	vec4 projected = PROJECTION_MATRIX * vec4(modelview_pos, 1.0);
	POSITION = projected + vec4(VERTEX.xy * projected.w * size / VIEWPORT_SIZE, depth_value, 0.0);
	POSITION.z = depth_value;
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
