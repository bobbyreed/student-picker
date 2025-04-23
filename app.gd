extends CanvasGroup

@export var configWindow : Panel
@export var pickerPanel : Panel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_config_button_pressed() -> void:
	configWindow.show()
	pickerPanel.hide()
