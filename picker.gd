extends Panel

@export var list : ItemList
var chosenAlreadyArray = []
var roundCount : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	chosenAlreadyArray.clear()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func pick():
	var count = list.item_count
	var selection = randi_range(0, count - 1)
	checkChosenList(selection)
	
func checkChosenList(n: int):
	if chosenAlreadyArray.has(n): 
		pick()
	else:
		list.select(n)
		roundCount += 1
		crossoff(n)
		#print("crossing off ", n)
		if roundCount == list.item_count: 
			chosenAlreadyArray.clear()
			roundCount = 0
			#print("all selections occurred. clearing already chosen list.")

func crossoff(n: int):
	chosenAlreadyArray.append(n)

func _on_pick_button_pressed() -> void:
	pick()
