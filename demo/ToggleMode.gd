extends Button


func _ready():
	pressed.connect(self._button_pressed)


func _button_pressed():
	%PixelStars.visible = not %PixelStars.visible
	%Stars.visible = not %Stars.visible
