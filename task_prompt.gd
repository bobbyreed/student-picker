extends PopupMenu

@export var promptTitle : RichTextLabel
@export var studentLabel : RichTextLabel
@export var promptText : RichTextLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func setupPrompt(title, student, prompt, options):
	promptTitle.text = title
	studentLabel.text = prompt
	promptText.text = prompt
	# TODO create switch case for options to display correct buttons
	
