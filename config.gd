extends Panel

@export var textEditor : TextEdit
@export var title : RichTextLabel
@export var subtitle : RichTextLabel
@export var list : ItemList
@export var pickList : ItemList
@export var deleteButton : Button
@export var exitButton : Button
@export var timer : Timer
@export var configPanel : Panel
@export var pickerPanel : Panel
var isReady = true
var deleteReady = true
var intToRemove = -1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#clear out old inputs
	textEditor.clear()
	if list.item_count == 0: list.clear()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	##need to figure out how to combine the next two if statements
	if Input.is_key_pressed(KEY_COMMA) && isReady: addStudents()
	if Input.is_key_pressed(KEY_ENTER) && isReady: addStudents()
	if timer.is_stopped(): isReady = true
	if intToRemove == null: print("intToRemove is null")
	
func addStudents():
	isReady = false
	##strips extra spaces (lstrip) and adds the item to the list
	list.add_item(textEditor.get_line(0).replace(' ','').replace(',',''))
	##clears any left over input
	textEditor.clear()
	timer.start()
	
func delete(toRemove: int):
	if deleteReady == true:
		print(toRemove)
		list.remove_item(toRemove)
	deleteReady = false
	
func _on_student_list_item_selected(index: int) -> void:
	deleteReady = true
	intToRemove = index
	
func _on_delete_student_button_pressed() -> void:
	if deleteReady == true:
		list.remove_item(intToRemove)
	deleteReady = false

func _on_exit_button_pressed() -> void:
	#closes the config window
	configPanel.hide()
	pickerPanel.show()
	
	# Clear the picker list completely to prevent duplication
	pickList.clear()
	
	# Now add all current students from config list to picker list
	for n in list.item_count:
		pickList.add_item(list.get_item_text(n))
	
