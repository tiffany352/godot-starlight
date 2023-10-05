extends Label


func _process(delta):
	text = "%d" % Engine.get_frames_per_second()
