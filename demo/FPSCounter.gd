extends Label


func _ready():
	RenderingServer.viewport_set_measure_render_time(get_viewport().get_viewport_rid(), true)


func _process(_delta):
	var rid = get_viewport().get_viewport_rid()
	var fps = Engine.get_frames_per_second()
	var cpu = RenderingServer.viewport_get_measured_render_time_cpu(rid)
	var gpu = RenderingServer.viewport_get_measured_render_time_gpu(rid)
	if gpu != 0.0:
		text = "%d\ncpu: %.2fms\ngpu: %.2fms" % [fps, cpu, gpu]
	else:
		text = "%d\ncpu: %.2fms" % [fps, cpu]
