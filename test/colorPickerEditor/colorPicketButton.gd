extends ColorPickerButton

func _ready() -> void:
	get_picker().presets_visible = false
	get_picker().color_modes_visible = false
	get_picker().edit_alpha = false
