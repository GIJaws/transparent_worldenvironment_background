shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, unshaded;

void fragment() {
    ALBEDO = vec3(0.0, 0.0, 1.0);
	ALPHA = 0.50;
}